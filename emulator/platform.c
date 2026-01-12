#include "platform.h"
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#define MEMORY_SIZE (32 * 1024 * 1024)
#define MEMORY_BASE 0x80000000
#define CHAROUT_BASE 0x10000000

platform_t* platform_new() {
    platform_t *plt = (platform_t*)malloc(sizeof(platform_t));
    if (!plt) {
        fprintf(stderr, "Error: Failed to allocate platform\n");
        return NULL;
    }
    
    plt->memory = (uint8_t*)calloc(MEMORY_SIZE, 1);
    if (!plt->memory) {
        fprintf(stderr, "Error: Failed to allocate memory\n");
        free(plt);
        return NULL;
    }
    
    plt->memory_base = MEMORY_BASE;
    plt->memory_size = MEMORY_SIZE;
    plt->charout_base = CHAROUT_BASE;
    
    return plt;
}

void platform_free(platform_t *platform) {
    if (platform) {
        if (platform->memory) {
            free(platform->memory);
        }
        free(platform);
    }
}

int platform_read(platform_t *plt, access_type_t access_type, uint32_t addr, uint32_t *data) {
    if (addr >= plt->charout_base && addr < plt->charout_base + 12) {
        *data = 0;
        return 0;
    }
    
    if (addr < plt->memory_base || addr >= plt->memory_base + plt->memory_size) {
        fprintf(stderr, "Error: Read from invalid address 0x%08x\n", addr);
        return -1;
    }
    
    uint32_t offset = addr - plt->memory_base;
    
    switch (access_type) {
        case ACCESS_BYTE:
            *data = plt->memory[offset];
            break;
            
        case ACCESS_HALF:
            if (addr & 0x1) {
                fprintf(stderr, "Error: Misaligned half-word read at 0x%08x\n", addr);
                return -1;
            }
            *data = *(uint16_t*)(&plt->memory[offset]);
            break;
            
        case ACCESS_WORD:
            if (addr & 0x3) {
                fprintf(stderr, "Error: Misaligned word read at 0x%08x\n", addr);
                return -1;
            }
            *data = *(uint32_t*)(&plt->memory[offset]);
            break;
            
        default:
            fprintf(stderr, "Error: Invalid access type\n");
            return -1;
    }
    
    return 0;
}

int platform_write(platform_t *plt, access_type_t access_type, uint32_t addr, uint32_t data) {
    if (addr >= plt->charout_base && addr < plt->charout_base + 12) {
        if (addr == plt->charout_base) {
            printf("%c", (char)(data & 0xFF));
            fflush(stdout);
        } else if (addr == plt->charout_base + 4) {
            printf("%d", (int32_t)data);
            fflush(stdout);
        } else if (addr == plt->charout_base + 8) {
            printf("%x", data);
            fflush(stdout);
        }
        return 0;
    }
    
    if (addr < plt->memory_base || addr >= plt->memory_base + plt->memory_size) {
        fprintf(stderr, "Error: Write to invalid address 0x%08x\n", addr);
        return -1;
    }
    
    uint32_t offset = addr - plt->memory_base;
    
    switch (access_type) {
        case ACCESS_BYTE:
            plt->memory[offset] = (uint8_t)data;
            break;
            
        case ACCESS_HALF:
            if (addr & 0x1) {
                fprintf(stderr, "Error: Misaligned half-word write at 0x%08x\n", addr);
                return -1;
            }
            *(uint16_t*)(&plt->memory[offset]) = (uint16_t)data;
            break;
            
        case ACCESS_WORD:
            if (addr & 0x3) {
                fprintf(stderr, "Error: Misaligned word write at 0x%08x\n", addr);
                return -1;
            }
            *(uint32_t*)(&plt->memory[offset]) = data;
            break;
            
        default:
            fprintf(stderr, "Error: Invalid access type\n");
            return -1;
    }
    
    return 0;
}

int platform_load_program(platform_t *plt, const char *file_name) {
    FILE *f = fopen(file_name, "rb");
    if (!f) {
        fprintf(stderr, "Error: Cannot open file '%s'\n", file_name);
        return -1;
    }
    
    fseek(f, 0, SEEK_END);
    long file_size = ftell(f);
    fseek(f, 0, SEEK_SET);
    
    if (file_size > plt->memory_size) {
        fprintf(stderr, "Error: Program too large (%ld bytes)\n", file_size);
        fclose(f);
        return -1;
    }
    
    size_t bytes_read = fread(plt->memory, 1, file_size, f);
    fclose(f);
    
    if (bytes_read != (size_t)file_size) {
        fprintf(stderr, "Error: Failed to read complete file\n");
        return -1;
    }
    
    printf("Loaded %ld bytes from '%s' into memory at 0x%08x\n", 
           file_size, file_name, plt->memory_base);
    
    return 0;
}