.section .text
.globl _start

_start:
    # Initialize stack pointer
    lui     x2, 0x80001        # Stack at 0x80001000
    lui     x5, 0x10000        # Output device base address
    
    # Print header
    la      x6, header
    jal     x1, print_string
    
    # Test 1: BEQ (Branch if Equal)
    la      x6, test1_msg
    jal     x1, print_string
    addi    x10, x0, 42
    addi    x11, x0, 42
    beq     x10, x11, beq_taken
    la      x6, fail_msg
    jal     x0, beq_done
beq_taken:
    la      x6, pass_msg
beq_done:
    jal     x1, print_string
    
    # Test 2: BNE (Branch if Not Equal)
    la      x6, test2_msg
    jal     x1, print_string
    addi    x10, x0, 10
    addi    x11, x0, 20
    bne     x10, x11, bne_taken
    la      x6, fail_msg
    jal     x0, bne_done
bne_taken:
    la      x6, pass_msg
bne_done:
    jal     x1, print_string
    
    # Test 3: BLT (Branch if Less Than signed)
    la      x6, test3_msg
    jal     x1, print_string
    addi    x10, x0, -5
    addi    x11, x0, 10
    blt     x10, x11, blt_taken
    la      x6, fail_msg
    jal     x0, blt_done
blt_taken:
    la      x6, pass_msg
blt_done:
    jal     x1, print_string
    
    # Test 4: BGE (Branch if Greater or Equal signed)
    la      x6, test4_msg
    jal     x1, print_string
    addi    x10, x0, 15
    addi    x11, x0, 10
    bge     x10, x11, bge_taken
    la      x6, fail_msg
    jal     x0, bge_done
bge_taken:
    la      x6, pass_msg
bge_done:
    jal     x1, print_string
    
    # Test 5: Loop counter test (count from 1 to 5)
    la      x6, test5_msg
    jal     x1, print_string
    addi    x10, x0, 1         # Counter
    addi    x11, x0, 5         # Limit
loop_test:
    sw      x10, 4(x5)         # Print number
    addi    x7, x0, 32         # Space
    sw      x7, 0(x5)
    addi    x10, x10, 1
    ble     x10, x11, loop_test
    jal     x1, print_newline
    
    # Test 6: Nested function calls
    la      x6, test6_msg
    jal     x1, print_string
    addi    x10, x0, 5
    jal     x1, factorial      # Call factorial(5)
    # Result in x10
    sw      x10, 4(x5)
    jal     x1, print_newline
    
    # Test 7: BLTU (Branch if Less Than unsigned)
    la      x6, test7_msg
    jal     x1, print_string
    addi    x10, x0, 10
    addi    x11, x0, 200
    bltu    x10, x11, bltu_taken
    la      x6, fail_msg
    jal     x0, bltu_done
bltu_taken:
    la      x6, pass_msg
bltu_done:
    jal     x1, print_string
    
    # Test 8: BGEU (Branch if Greater or Equal unsigned)
    la      x6, test8_msg
    jal     x1, print_string
    addi    x10, x0, -1        # 0xFFFFFFFF (large unsigned)
    addi    x11, x0, 100
    bgeu    x10, x11, bgeu_taken
    la      x6, fail_msg
    jal     x0, bgeu_done
bgeu_taken:
    la      x6, pass_msg
bgeu_done:
    jal     x1, print_string
    
    # Print completion message
    la      x6, complete_msg
    jal     x1, print_string
    
    ecall

# Function: factorial(n) - recursive
# Input: x10 = n
# Output: x10 = n!
factorial:
    addi    x2, x2, -8         # Allocate stack
    sw      x1, 4(x2)          # Save return address
    sw      x10, 0(x2)         # Save n
    
    addi    x11, x0, 1
    bgt     x10, x11, fact_recurse
    
    # Base case: n <= 1, return 1
    addi    x10, x0, 1
    lw      x1, 4(x2)
    addi    x2, x2, 8
    jalr    x0, 0(x1)
    
fact_recurse:
    addi    x10, x10, -1       # n-1
    jal     x1, factorial      # factorial(n-1)
    
    lw      x11, 0(x2)         # Load original n
    mul     x10, x10, x11      # n * factorial(n-1)
    
    lw      x1, 4(x2)
    addi    x2, x2, 8
    jalr    x0, 0(x1)

# Subroutines
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

print_newline:
    addi    x7, x0, 10
    sw      x7, 0(x5)
    jalr    x0, 0(x1)

.section .rodata
header:
    .string "=== Branch and Jump Test ===\n"
test1_msg:
    .string "BEQ (42 == 42): "
test2_msg:
    .string "BNE (10 != 20): "
test3_msg:
    .string "BLT (-5 < 10): "
test4_msg:
    .string "BGE (15 >= 10): "
test5_msg:
    .string "Loop (1 to 5): "
test6_msg:
    .string "Factorial(5) = "
test7_msg:
    .string "BLTU (10 < 200): "
test8_msg:
    .string "BGEU (0xFFFFFFFF >= 100): "
pass_msg:
    .string "PASS\n"
fail_msg:
    .string "FAIL\n"
complete_msg:
    .string "\nAll branch tests complete!\n"