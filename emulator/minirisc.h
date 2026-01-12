#ifndef MINIRISC_H
#define MINIRISC_H

#include <inttypes.h>
#include "platform.h"

typedef struct {
    uint32_t    PC;
    uint32_t    IR;
    uint32_t    next_PC;
    uint32_t    regs[32];
    platform_t *platform;
    int         halt;
    uint64_t    inst_count;
} minirisc_t;

minirisc_t* minirisc_new(uint32_t initial_PC, platform_t *platform);
void minirisc_free(minirisc_t *mr);
void minirisc_fetch(minirisc_t *mr);
void minirisc_decode_and_execute(minirisc_t *mr);
void minirisc_run(minirisc_t *mr);
void minirisc_disassemble(minirisc_t *mr);

#endif