.section .text
.globl _start

_start:
    # Initialize stack pointer
    lui     x2, 0x80001        # Stack at 0x80001000
    
    lui     x5, 0x10000        # Output device base address
    
    # Print header
    la      x6, header
    jal     x1, print_string
    
    # Test 1: Addition (15 + 27 = 42)
    la      x6, test1_msg
    jal     x1, print_string
    addi    x10, x0, 15
    addi    x11, x0, 27
    add     x12, x10, x11      # x12 = 15 + 27 = 42
    addi    x10, x12, 0
    jal     x1, print_number
    jal     x1, print_newline
    
    # Test 2: Subtraction (100 - 42 = 58)
    la      x6, test2_msg
    jal     x1, print_string
    addi    x10, x0, 100
    addi    x11, x0, 42
    sub     x12, x10, x11      # x12 = 100 - 42 = 58
    addi    x10, x12, 0
    jal     x1, print_number
    jal     x1, print_newline
    
    # Test 3: Multiplication (7 * 8 = 56)
    la      x6, test3_msg
    jal     x1, print_string
    addi    x10, x0, 7
    addi    x11, x0, 8
    mul     x12, x10, x11      # x12 = 7 * 8 = 56
    addi    x10, x12, 0
    jal     x1, print_number
    jal     x1, print_newline
    
    # Test 4: Division (144 / 12 = 12)
    la      x6, test4_msg
    jal     x1, print_string
    addi    x10, x0, 144
    addi    x11, x0, 12
    div     x12, x10, x11      # x12 = 144 / 12 = 12
    addi    x10, x12, 0
    jal     x1, print_number
    jal     x1, print_newline
    
    # Test 5: Modulo (17 % 5 = 2)
    la      x6, test5_msg
    jal     x1, print_string
    addi    x10, x0, 17
    addi    x11, x0, 5
    rem     x12, x10, x11      # x12 = 17 % 5 = 2
    addi    x10, x12, 0
    jal     x1, print_number
    jal     x1, print_newline
    
    # Test 6: Negative numbers (-20 + 30 = 10)
    la      x6, test6_msg
    jal     x1, print_string
    addi    x10, x0, -20
    addi    x11, x0, 30
    add     x12, x10, x11      # x12 = -20 + 30 = 10
    addi    x10, x12, 0
    jal     x1, print_number
    jal     x1, print_newline
    
    # Test 7: Negative multiplication (-6 * 7 = -42)
    la      x6, test7_msg
    jal     x1, print_string
    addi    x10, x0, -6
    addi    x11, x0, 7
    mul     x12, x10, x11      # x12 = -6 * 7 = -42
    addi    x10, x12, 0
    jal     x1, print_number
    jal     x1, print_newline
    
    # Print completion message
    la      x6, complete_msg
    jal     x1, print_string
    
    # Exit
    ecall

# Subroutine: Print string (address in x6)
print_string:
    addi    x2, x2, -4         # Allocate stack
    sw      x1, 0(x2)          # Save return address
print_string_loop:
    lbu     x7, 0(x6)
    beq     x7, x0, print_string_done
    sw      x7, 0(x5)          # Print character
    addi    x6, x6, 1
    jal     x0, print_string_loop
print_string_done:
    lw      x1, 0(x2)          # Restore return address
    addi    x2, x2, 4          # Deallocate stack
    jalr    x0, 0(x1)

# Subroutine: Print number (value in x10)
print_number:
    sw      x10, 4(x5)         # Print as decimal
    jalr    x0, 0(x1)

# Subroutine: Print newline
print_newline:
    addi    x7, x0, 10         # Newline character
    sw      x7, 0(x5)
    jalr    x0, 0(x1)

.section .rodata
header:
    .string "=== Arithmetic Operations Test ===\n"
test1_msg:
    .string "15 + 27 = "
test2_msg:
    .string "100 - 42 = "
test3_msg:
    .string "7 * 8 = "
test4_msg:
    .string "144 / 12 = "
test5_msg:
    .string "17 % 5 = "
test6_msg:
    .string "-20 + 30 = "
test7_msg:
    .string "-6 * 7 = "
complete_msg:
    .string "\nAll arithmetic tests complete!\n"