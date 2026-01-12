#ifndef PLATFORM_H
#define PLATFORM_H

#include <stdint.h>

typedef enum {
    ACCESS_BYTE = 0,
    ACCESS_HALF = 1,
    ACCESS_WORD = 3
} access_type_t;

typedef struct {
    uint8_t *memory;
    uint32_t memory_base;
    uint32_t memory_size;
    uint32_t charout_base;
} platform_t;

platform_t* platform_new();

void platform_free(platform_t *platform);

int platform_read(platform_t *plt, access_type_t access_type, uint32_t addr, uint32_t *data);

int platform_write(platform_t *plt, access_type_t access_type, uint32_t addr, uint32_t data);

int platform_load_program(platform_t *plt, const char *file_name);

#endif