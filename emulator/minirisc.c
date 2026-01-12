#include "minirisc.h"
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

// Instruction format masks
#define OPCODE(inst) (inst & 0x7F)
#define RD(inst)     ((inst >> 7) & 0x1F)
#define FUNCT3(inst) ((inst >> 12) & 0x7)
#define RS1(inst)    ((inst >> 15) & 0x1F)
#define RS2(inst)    ((inst >> 20) & 0x1F)
#define FUNCT7(inst) ((inst >> 25) & 0x7F)

// Sign extension helper
static inline int32_t sign_extend(uint32_t value, int bits) {
    int32_t m = 1U << (bits - 1);
    return (value ^ m) - m;
}

// Extract immediate values
static inline int32_t get_imm_I(uint32_t inst) {
    return sign_extend(inst >> 20, 12);
}

static inline int32_t get_imm_S(uint32_t inst) {
    uint32_t imm = ((inst >> 7) & 0x1F) | ((inst >> 20) & 0xFE0);
    return sign_extend(imm, 12);
}

static inline int32_t get_imm_B(uint32_t inst) {
    uint32_t imm = ((inst >> 7) & 0x1E) | ((inst >> 20) & 0x7E0) |
                   ((inst << 4) & 0x800) | ((inst >> 19) & 0x1000);
    return sign_extend(imm, 13);
}

static inline int32_t get_imm_U(uint32_t inst) {
    return inst & 0xFFFFF000;
}

static inline int32_t get_imm_J(uint32_t inst) {
    uint32_t imm = ((inst >> 20) & 0x7FE) | ((inst >> 9) & 0x800) |
                   (inst & 0xFF000) | ((inst >> 11) & 0x100000);
    return sign_extend(imm, 21);
}

minirisc_t* minirisc_new(uint32_t initial_PC, platform_t *platform) {
    minirisc_t *mr = (minirisc_t*)malloc(sizeof(minirisc_t));
    if (!mr) {
        fprintf(stderr, "Error: Failed to allocate processor\n");
        return NULL;
    }
    
    memset(mr, 0, sizeof(minirisc_t));
    mr->PC = initial_PC;
    mr->next_PC = initial_PC + 4;
    mr->platform = platform;
    mr->halt = 0;
    mr->inst_count = 0;
    
    return mr;
}

void minirisc_free(minirisc_t *mr) {
    if (mr) {
        free(mr);
    }
}

void minirisc_fetch(minirisc_t *mr) {
    if (platform_read(mr->platform, ACCESS_WORD, mr->PC, &mr->IR) != 0) {
        fprintf(stderr, "Error: Failed to fetch instruction at 0x%08x\n", mr->PC);
        mr->halt = 1;
    }
}

void minirisc_decode_and_execute(minirisc_t *mr) {
    uint32_t inst = mr->IR;
    uint32_t opcode = OPCODE(inst);
    uint32_t rd = RD(inst);
    uint32_t funct3 = FUNCT3(inst);
    uint32_t rs1 = RS1(inst);
    uint32_t rs2 = RS2(inst);
    uint32_t funct7 = FUNCT7(inst);
    
    // Default: increment PC by 4
    mr->next_PC = mr->PC + 4;
    
    switch (opcode) {
        case 0x37: { // LUI
            mr->regs[rd] = get_imm_U(inst);
            break;
        }
        case 0x17: { // AUIPC
            mr->regs[rd] = mr->PC + get_imm_U(inst);
            break;
        }
        case 0x6F: { // JAL
            mr->regs[rd] = mr->PC + 4;
            mr->next_PC = mr->PC + get_imm_J(inst);
            break;
        }
        case 0x67: { // JALR
            uint32_t target = (mr->regs[rs1] + get_imm_I(inst)) & ~1;
            mr->regs[rd] = mr->PC + 4;
            mr->next_PC = target;
            break;
        }
        case 0x63: { // Branch
            int32_t offset = get_imm_B(inst);
            int take_branch = 0;
            
            switch (funct3) {
                case 0x0: take_branch = (mr->regs[rs1] == mr->regs[rs2]); break; // BEQ
                case 0x1: take_branch = (mr->regs[rs1] != mr->regs[rs2]); break; // BNE
                case 0x4: take_branch = ((int32_t)mr->regs[rs1] < (int32_t)mr->regs[rs2]); break; // BLT
                case 0x5: take_branch = ((int32_t)mr->regs[rs1] >= (int32_t)mr->regs[rs2]); break; // BGE
                case 0x6: take_branch = (mr->regs[rs1] < mr->regs[rs2]); break; // BLTU
                case 0x7: take_branch = (mr->regs[rs1] >= mr->regs[rs2]); break; // BGEU
            }
            
            if (take_branch) {
                mr->next_PC = mr->PC + offset;
            }
            break;
        }
        case 0x03: { // Load
            uint32_t addr = mr->regs[rs1] + get_imm_I(inst);
            uint32_t data;
            
            switch (funct3) {
                case 0x0: // LB
                    if (platform_read(mr->platform, ACCESS_BYTE, addr, &data) == 0) {
                        mr->regs[rd] = sign_extend(data, 8);
                    }
                    break;
                case 0x1: // LH
                    if (platform_read(mr->platform, ACCESS_HALF, addr, &data) == 0) {
                        mr->regs[rd] = sign_extend(data, 16);
                    }
                    break;
                case 0x2: // LW
                    if (platform_read(mr->platform, ACCESS_WORD, addr, &data) == 0) {
                        mr->regs[rd] = data;
                    }
                    break;
                case 0x4: // LBU
                    if (platform_read(mr->platform, ACCESS_BYTE, addr, &data) == 0) {
                        mr->regs[rd] = data & 0xFF;
                    }
                    break;
                case 0x5: // LHU
                    if (platform_read(mr->platform, ACCESS_HALF, addr, &data) == 0) {
                        mr->regs[rd] = data & 0xFFFF;
                    }
                    break;
            }
            break;
        }
        case 0x23: { // Store
            uint32_t addr = mr->regs[rs1] + get_imm_S(inst);
            uint32_t data = mr->regs[rs2];
            
            switch (funct3) {
                case 0x0: platform_write(mr->platform, ACCESS_BYTE, addr, data); break; // SB
                case 0x1: platform_write(mr->platform, ACCESS_HALF, addr, data); break; // SH
                case 0x2: platform_write(mr->platform, ACCESS_WORD, addr, data); break; // SW
            }
            break;
        }
        case 0x13: { // I-type ALU
            int32_t imm = get_imm_I(inst);
            
            switch (funct3) {
                case 0x0: mr->regs[rd] = mr->regs[rs1] + imm; break; // ADDI
                case 0x2: mr->regs[rd] = ((int32_t)mr->regs[rs1] < imm) ? 1 : 0; break; // SLTI
                case 0x3: mr->regs[rd] = (mr->regs[rs1] < (uint32_t)imm) ? 1 : 0; break; // SLTIU
                case 0x4: mr->regs[rd] = mr->regs[rs1] ^ imm; break; // XORI
                case 0x6: mr->regs[rd] = mr->regs[rs1] | imm; break; // ORI
                case 0x7: mr->regs[rd] = mr->regs[rs1] & imm; break; // ANDI
                case 0x1: mr->regs[rd] = mr->regs[rs1] << (rs2 & 0x1F); break; // SLLI
                case 0x5:
                    if (funct7 == 0x00) { // SRLI
                        mr->regs[rd] = mr->regs[rs1] >> (rs2 & 0x1F);
                    } else { // SRAI
                        mr->regs[rd] = (int32_t)mr->regs[rs1] >> (rs2 & 0x1F);
                    }
                    break;
            }
            break;
        }
        case 0x33: { // R-type ALU
            switch (funct3) {
                case 0x0:
                    if (funct7 == 0x00) { // ADD
                        mr->regs[rd] = mr->regs[rs1] + mr->regs[rs2];
                    } else if (funct7 == 0x20) { // SUB
                        mr->regs[rd] = mr->regs[rs1] - mr->regs[rs2];
                    } else if (funct7 == 0x01) { // MUL
                        mr->regs[rd] = mr->regs[rs1] * mr->regs[rs2];
                    }
                    break;
                case 0x1:
                    if (funct7 == 0x00) { // SLL
                        mr->regs[rd] = mr->regs[rs1] << (mr->regs[rs2] & 0x1F);
                    } else if (funct7 == 0x01) { // MULH
                        int64_t result = (int64_t)(int32_t)mr->regs[rs1] * (int64_t)(int32_t)mr->regs[rs2];
                        mr->regs[rd] = result >> 32;
                    }
                    break;
                case 0x2:
                    if (funct7 == 0x00) { // SLT
                        mr->regs[rd] = ((int32_t)mr->regs[rs1] < (int32_t)mr->regs[rs2]) ? 1 : 0;
                    } else if (funct7 == 0x01) { // MULHSU
                        int64_t result = (int64_t)(int32_t)mr->regs[rs1] * (uint64_t)mr->regs[rs2];
                        mr->regs[rd] = result >> 32;
                    }
                    break;
                case 0x3:
                    if (funct7 == 0x00) { // SLTU
                        mr->regs[rd] = (mr->regs[rs1] < mr->regs[rs2]) ? 1 : 0;
                    } else if (funct7 == 0x01) { // MULHU
                        uint64_t result = (uint64_t)mr->regs[rs1] * (uint64_t)mr->regs[rs2];
                        mr->regs[rd] = result >> 32;
                    }
                    break;
                case 0x4:
                    if (funct7 == 0x00) { // XOR
                        mr->regs[rd] = mr->regs[rs1] ^ mr->regs[rs2];
                    } else if (funct7 == 0x01) { // DIV
                        if (mr->regs[rs2] == 0) {
                            mr->regs[rd] = -1;
                        } else {
                            mr->regs[rd] = (int32_t)mr->regs[rs1] / (int32_t)mr->regs[rs2];
                        }
                    }
                    break;
                case 0x5:
                    if (funct7 == 0x00) { // SRL
                        mr->regs[rd] = mr->regs[rs1] >> (mr->regs[rs2] & 0x1F);
                    } else if (funct7 == 0x20) { // SRA
                        mr->regs[rd] = (int32_t)mr->regs[rs1] >> (mr->regs[rs2] & 0x1F);
                    } else if (funct7 == 0x01) { // DIVU
                        if (mr->regs[rs2] == 0) {
                            mr->regs[rd] = 0xFFFFFFFF;
                        } else {
                            mr->regs[rd] = mr->regs[rs1] / mr->regs[rs2];
                        }
                    }
                    break;
                case 0x6:
                    if (funct7 == 0x00) { // OR
                        mr->regs[rd] = mr->regs[rs1] | mr->regs[rs2];
                    } else if (funct7 == 0x01) { // REM
                        if (mr->regs[rs2] == 0) {
                            mr->regs[rd] = mr->regs[rs1];
                        } else {
                            mr->regs[rd] = (int32_t)mr->regs[rs1] % (int32_t)mr->regs[rs2];
                        }
                    }
                    break;
                case 0x7:
                    if (funct7 == 0x00) { // AND
                        mr->regs[rd] = mr->regs[rs1] & mr->regs[rs2];
                    } else if (funct7 == 0x01) { // REMU
                        if (mr->regs[rs2] == 0) {
                            mr->regs[rd] = mr->regs[rs1];
                        } else {
                            mr->regs[rd] = mr->regs[rs1] % mr->regs[rs2];
                        }
                    }
                    break;
            }
            break;
        }
        case 0x0F: // FENCE
            // No operation for simple emulator
            break;
        case 0x73: // SYSTEM
            if (inst == 0x00000073) { // ECALL
                mr->halt = 1;
            } else if (inst == 0x00100073) { // EBREAK
                mr->halt = 1;
            }
            break;
        default:
            fprintf(stderr, "Error: Unknown opcode 0x%02x at PC=0x%08x\n", opcode, mr->PC);
            mr->halt = 1;
            break;
    }
    
    // x0 is always 0
    mr->regs[0] = 0;
}

void minirisc_run(minirisc_t *mr) {
    printf("\n=== Starting Mini-RISC Emulator ===\n\n");
    
    while (!mr->halt) {
        minirisc_fetch(mr);
        if (mr->halt) break;
        
        minirisc_decode_and_execute(mr);
        mr->PC = mr->next_PC;
        mr->inst_count++;
    }
    
    printf("\n\n=== Emulator Halted ===\n");
    printf("Instructions executed: %lu\n", mr->inst_count);
}