.section .text
.globl _start

_start:
    # Initialize stack pointer
    lui     x2, 0x80001        # Stack at 0x80001000
    lui     x5, 0x10000        # Output device base address
    
    # Print header
    la      x6, header
    jal     x1, print_string
    
    # Test 1: Store and Load Byte
    la      x6, test1_msg
    jal     x1, print_string
    la      x10, data_area     # Get address
    addi    x11, x0, 0xAB      # Value to store
    sb      x11, 0(x10)        # Store byte
    lbu     x12, 0(x10)        # Load byte unsigned
    addi    x10, x12, 0
    jal     x1, print_hex
    jal     x1, print_newline
    
    # Test 2: Store and Load Half-word
    la      x6, test2_msg
    jal     x1, print_string
    la      x10, data_area
    addi    x11, x0, 0x340     # 0x340 (fits in 12 bits)
    sh      x11, 4(x10)        # Store half at offset 4
    lhu     x12, 4(x10)        # Load half unsigned
    addi    x10, x12, 0
    jal     x1, print_hex
    jal     x1, print_newline
    
    # Test 3: Store and Load Word (FIXED: proper handling of large immediate)
    la      x6, test3_msg
    jal     x1, print_string
    la      x10, data_area
    lui     x11, 0xDEADB       # Load upper 20 bits: 0xDEADB000
    addi    x11, x11, -273     # Add -273 (0xEEF = 3823, but we need sign extension)
    # Alternative: use ori instruction
    # lui     x11, 0xDEADC      # 0xDEADC000
    # addi    x11, x11, -1041   # 0xDEADC000 - 1041 = 0xDEADBBEF (close)
    # Better: Build it properly
    li      x11, 0xDEADBEEF    # Assembler will expand this correctly
    sw      x11, 8(x10)        # Store word at offset 8
    lw      x12, 8(x10)        # Load word
    addi    x10, x12, 0
    jal     x1, print_hex
    jal     x1, print_newline
    
    # Test 4: Array operations - Initialize array
    la      x6, test4_msg
    jal     x1, print_string
    la      x10, array_area
    addi    x11, x0, 10        # Start value
    addi    x13, x0, 5         # Counter
init_loop:
    sw      x11, 0(x10)
    addi    x11, x11, 5        # Increment by 5
    addi    x10, x10, 4        # Next array element
    addi    x13, x13, -1
    bne     x13, x0, init_loop
    
    # Print array elements
    la      x10, array_area
    addi    x13, x0, 5
print_array:
    lw      x14, 0(x10)
    addi    x15, x14, 0
    sw      x15, 4(x5)         # Print number
    addi    x7, x0, 32         # Space
    sw      x7, 0(x5)
    addi    x10, x10, 4
    addi    x13, x13, -1
    bne     x13, x0, print_array
    jal     x1, print_newline
    
    # Test 5: Memory copy
    la      x6, test5_msg
    jal     x1, print_string
    la      x10, src_data      # Source
    la      x11, dst_data      # Destination
    addi    x13, x0, 4         # Copy 4 words
copy_loop:
    lw      x14, 0(x10)
    sw      x14, 0(x11)
    addi    x10, x10, 4
    addi    x11, x11, 4
    addi    x13, x13, -1
    bne     x13, x0, copy_loop
    
    # Verify copy
    la      x10, dst_data
    addi    x13, x0, 4
verify_loop:
    lw      x14, 0(x10)
    sw      x14, 4(x5)
    addi    x7, x0, 32
    sw      x7, 0(x5)
    addi    x10, x10, 4
    addi    x13, x13, -1
    bne     x13, x0, verify_loop
    jal     x1, print_newline
    
    # Test 6: Signed load (LB with sign extension)
    la      x6, test6_msg
    jal     x1, print_string
    la      x10, data_area
    addi    x11, x0, -1        # 0xFF
    sb      x11, 0(x10)
    lb      x12, 0(x10)        # Load byte signed
    addi    x10, x12, 0
    jal     x1, print_number
    jal     x1, print_newline
    
    # Print completion message
    la      x6, complete_msg
    jal     x1, print_string
    
    ecall

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

print_number:
    sw      x10, 4(x5)
    jalr    x0, 0(x1)

print_hex:
    sw      x10, 8(x5)
    jalr    x0, 0(x1)

print_newline:
    addi    x7, x0, 10
    sw      x7, 0(x5)
    jalr    x0, 0(x1)

.section .data
data_area:
    .space 64
array_area:
    .space 64
src_data:
    .word 100, 200, 300, 400
dst_data:
    .space 16

.section .rodata
header:
    .string "=== Memory Operations Test ===\n"
test1_msg:
    .string "Store/Load Byte (0xAB): 0x"
test2_msg:
    .string "Store/Load Half (0x340): 0x"
test3_msg:
    .string "Store/Load Word (0xDEADBEEF): 0x"
test4_msg:
    .string "Array [10, 15, 20, 25, 30]: "
test5_msg:
    .string "Memory Copy [100, 200, 300, 400]: "
test6_msg:
    .string "Signed Load (-1): "
complete_msg:
    .string "\nAll memory tests complete!\n"