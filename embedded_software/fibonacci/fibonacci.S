.section .text
.globl _start

_start:
    # Initialize registers
    lui     x5, 0x10000        # Output device base
    lui     x6, 0x80000        # Header string address
    addi    x6, x6, 0x100      # Offset to header
    addi    x10, x0, 10        # Number of Fibonacci numbers
    addi    x11, x0, 0         # First Fibonacci number
    addi    x12, x0, 1         # Second Fibonacci number

print_header:
    lbu     x7, 0(x6)
    beq     x7, x0, fib_start
    sw      x7, 0(x5)
    addi    x6, x6, 1
    jal     x0, print_header
    
fib_start:
    addi    x13, x0, 0
    
fib_loop:
    bge     x13, x10, print_complete
    sw      x11, 4(x5)
    addi    x7, x0, 44
    sw      x7, 0(x5)
    addi    x7, x0, 32
    sw      x7, 0(x5)
    add     x14, x11, x12
    addi    x11, x12, 0
    addi    x12, x14, 0
    addi    x13, x13, 1
    jal     x0, fib_loop
    
print_complete:
    addi    x7, x0, 10
    sw      x7, 0(x5)
    lui     x6, 0x80000
    addi    x6, x6, 0x120
    
print_msg:
    lbu     x7, 0(x6)
    beq     x7, x0, halt
    sw      x7, 0(x5)
    addi    x6, x6, 1
    jal     x0, print_msg
    
halt:
    ecall

.section .rodata
header:
    .string "Fibonacci sequence:\n"
complete_msg:
    .string "Calculation complete!"