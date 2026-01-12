.section .text
.globl _start

_start:
    # Print "Hello, Mini-RISC World!"
    lui     x5, 0x10000        # Base address of output device
    la      x6, string          # Load address of string

print_loop:
    lbu     x7, 0(x6)          # Load byte from string
    beq     x7, x0, print_newline
    sw      x7, 0(x5)          # Write to output
    addi    x6, x6, 1
    jal     x0, print_loop

print_newline:
    addi    x7, x0, 10         # Newline character
    sw      x7, 0(x5)
    ecall

.section .rodata
string:
    .string "Hello, Mini-RISC World!"
