.section .text
.globl _start

_start:
    # Initialize stack pointer
    lui     x2, 0x80001        # Stack at 0x80001000
    lui     x5, 0x10000        # Output device base address
    
    # Print header
    la      x6, header
    jal     x1, print_string
    
    # Test 1: AND (0xF0 & 0x3C = 0x30)
    la      x6, test1_msg
    jal     x1, print_string
    addi    x10, x0, 0xF0
    addi    x11, x0, 0x3C
    and     x12, x10, x11
    addi    x10, x12, 0
    jal     x1, print_hex
    jal     x1, print_newline
    
    # Test 2: OR (0x0F | 0xF0 = 0xFF)
    la      x6, test2_msg
    jal     x1, print_string
    addi    x10, x0, 0x0F
    addi    x11, x0, 0xF0
    or      x12, x10, x11
    addi    x10, x12, 0
    jal     x1, print_hex
    jal     x1, print_newline
    
    # Test 3: XOR (0xAA ^ 0x55 = 0xFF)
    la      x6, test3_msg
    jal     x1, print_string
    addi    x10, x0, 0xAA
    addi    x11, x0, 0x55
    xor     x12, x10, x11
    addi    x10, x12, 0
    jal     x1, print_hex
    jal     x1, print_newline
    
    # Test 4: Shift Left Logical (0x01 << 4 = 0x10)
    la      x6, test4_msg
    jal     x1, print_string
    addi    x10, x0, 0x01
    addi    x11, x0, 4
    sll     x12, x10, x11
    addi    x10, x12, 0
    jal     x1, print_hex
    jal     x1, print_newline
    
    # Test 5: Shift Right Logical (0x80 >> 2 = 0x20)
    la      x6, test5_msg
    jal     x1, print_string
    addi    x10, x0, 0x80
    addi    x11, x0, 2
    srl     x12, x10, x11
    addi    x10, x12, 0
    jal     x1, print_hex
    jal     x1, print_newline
    
    # Test 6: Shift Right Arithmetic (-16 >> 1 = -8)
    la      x6, test6_msg
    jal     x1, print_string
    addi    x10, x0, -16
    addi    x11, x0, 1
    sra     x12, x10, x11
    addi    x10, x12, 0
    jal     x1, print_number
    jal     x1, print_newline
    
    # Test 7: NOT using XOR with -1 (~0x0F = 0xFFFFFFF0)
    la      x6, test7_msg
    jal     x1, print_string
    addi    x10, x0, 0x0F
    addi    x11, x0, -1
    xor     x12, x10, x11
    addi    x10, x12, 0
    jal     x1, print_hex
    jal     x1, print_newline
    
    # Test 8: Set bit 5 in 0x00 (0x00 | 0x20 = 0x20)
    la      x6, test8_msg
    jal     x1, print_string
    addi    x10, x0, 0x00
    addi    x11, x0, 0x20
    or      x12, x10, x11
    addi    x10, x12, 0
    jal     x1, print_hex
    jal     x1, print_newline
    
    # Test 9: Clear bit 4 in 0xFF (0xFF & ~0x10 = 0xEF)
    la      x6, test9_msg
    jal     x1, print_string
    addi    x10, x0, 0xFF
    addi    x11, x0, 0x10
    addi    x13, x0, -1
    xor     x11, x11, x13      # NOT x11
    and     x12, x10, x11
    addi    x10, x12, 0
    jal     x1, print_hex
    jal     x1, print_newline
    
    # Print completion message
    la      x6, complete_msg
    jal     x1, print_string
    
    ecall

# Subroutine: Print string (address in x6)
print_string:
    addi    x2, x2, -4
    sw      x1, 0(x2)
print_string_loop:
    lbu     x7, 0(x6)
    beq     x7, x0, print_string_done
    sw      x7, 0(x5)
    addi    x6, x6, 1
    jal     x0, print_string_loop
print_string_done:
    lw      x1, 0(x2)
    addi    x2, x2, 4
    jalr    x0, 0(x1)

# Subroutine: Print number (value in x10)
print_number:
    sw      x10, 4(x5)
    jalr    x0, 0(x1)

# Subroutine: Print hex (value in x10)
print_hex:
    sw      x10, 8(x5)
    jalr    x0, 0(x1)

# Subroutine: Print newline
print_newline:
    addi    x7, x0, 10
    sw      x7, 0(x5)
    jalr    x0, 0(x1)

.section .rodata
header:
    .string "=== Logic Operations Test ===\n"
test1_msg:
    .string "0xF0 AND 0x3C = 0x"
test2_msg:
    .string "0x0F OR 0xF0 = 0x"
test3_msg:
    .string "0xAA XOR 0x55 = 0x"
test4_msg:
    .string "0x01 SLL 4 = 0x"
test5_msg:
    .string "0x80 SRL 2 = 0x"
test6_msg:
    .string "-16 SRA 1 = "
test7_msg:
    .string "NOT 0x0F = 0x"
test8_msg:
    .string "Set bit 5: 0x"
test9_msg:
    .string "Clear bit 4 in 0xFF: 0x"
complete_msg:
    .string "\nAll logic tests complete!\n"