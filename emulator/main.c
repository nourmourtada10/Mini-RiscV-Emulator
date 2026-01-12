#include <stdio.h>
#include <stdlib.h>
#include "platform.h"
#include "minirisc.h"

int main(int argc, char *argv[]) {
    if (argc < 2) {
        fprintf(stderr, "Usage: %s <program.bin>\n", argv[0]);
        return 1;
    }
    
    platform_t *platform = platform_new();
    if (!platform) {
        return 1;
    }
    
    minirisc_t *minirisc = minirisc_new(0x80000000, platform);
    if (!minirisc) {
        platform_free(platform);
        return 1;
    }
    
    if (platform_load_program(platform, argv[1]) != 0) {
        minirisc_free(minirisc);
        platform_free(platform);
        return 1;
    }
    
    minirisc_run(minirisc);
    
    minirisc_free(minirisc);
    platform_free(platform);
    
    return 0;
}