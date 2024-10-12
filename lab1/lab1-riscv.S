.data
# -------------------------------------- TODO: FILL IN YOUR FILE PATH !!! -------------------------------------------
read_path:
        .string "/home/arch_stu2021010726/yao-archlab-f22/lab1/sample/turing_before.pixel"
write_path:
        .string "/home/arch_stu2021010726/yao-archlab-f22/lab1/run/turing-rv.pixel"
# ------------------------------------------------------------------------------------------------------------------
img:
        .zero   1000000
result_img: 
        .zero   1000000
n:
        .zero   4
m:
        .zero   4
size: 
        .zero   8
K:
        .zero   100
.text
main:
        addi    sp,sp,-16
        sw      ra,12(sp)
        jal    image_input
        jal    image_process
        jal    image_output
        jal    image_to_file
        lw      ra,12(sp)
        li      a0,0
        li a7, 10
        ecall
        addi    sp,sp,16
        jr      ra


_printf_num:
# DO NOT MODIFY THIS!!!
        li a7, 1
        ecall 
        ret


_printf_char:
# DO NOT MODIFY THIS!!!
        li a7, 11
        ecall 
        ret


_read_int:
# DO NOT MODIFY THIS!!!
        mv      a5,a1
        mv      a4,a2
        li a7, 1024
        li a1, 0
        ecall
        mv t3, a0
        li a7, 65
        mv a1, a5
        mv a2, a4
        ecall
        li a7, 57
        mv a0, t3
        ecall
        ret


_write_int:
# DO NOT MODIFY THIS!!! 
        mv a5, a1
        mv a4, a2
        li a7, 1024
        li a1, 1
        ecall
        mv t3, a0
        li a7, 66
        mv a1, a5
        mv a2, a4
        ecall
        li a7, 57
        mv a0, t3
        ecall
        ret 


image_process:
# CYCLES: 8796200  CPI: 1.06  IPC: 0.939
# --------------------------------------- TODO: FILL IN CODE HERE ---------------------------------------
        addi    sp,sp,-32
        # store registers
        sw      ra,(28)sp
        sw      s0,(24)sp       # s0: *K
        sw      s1,(20)sp       # s1: n
        sw      s2,(16)sp       # s2: m
        sw      s3,(12)sp       # s3: *img
        sw      s4,(8)sp        # s4: *result_img
        # load *K=&K[0] from memory to s0
        la      s0,K
        # load n from memory to s1
        lw      s1,n
        # load m from memory to s2
        lw      s2,m
        # load *img from memory to s3
        la      s3,img
        # load *result_img from memory to s4
        la      s4,result_img
        # set Kernel Matrix K in log form
         # K[0][0] = 0
        addi    t1,zero,0
        sw      t1,0(s0)
         # K[0][1] = 1
        addi    t1,zero,1
        sw      t1,4(s0)
         # K[0][2] = 0
        addi    t1,zero,0
        sw      t1,8(s0)
         # K[1][0] = 1
        addi    t1,zero,1
        sw      t1,12(s0)
         # K[1][1] = 2
        addi    t1,zero,2
        sw      t1,16(s0)
         # K[1][2] = 1
        addi    t1,zero,1
        sw      t1,20(s0)
         # K[2][0] = 0
        addi    t1,zero,0
        sw      t1,24(s0)
         # K[2][1] = 1
        addi    t1,zero,1
        sw      t1,28(s0)
         # K[2][2] = 0
        addi    t1,zero,0
        sw      t1,32(s0)
        # outerloop: for(int x=0; x<n; x++)
        addi    t1,zero,0       # t1: x; x=0
        j OUTER_CONDITION       # jump to OUTER_CONDITION
OUTER_LOOP:
        # innerloop: for(int y=0; y<m; y++)
        addi    t2,zero,0       # t2: y; y=0
        j INNER_CONDITION       # jump to INNER_CONDITION
INNER_LOOP:
        mul     t4,t1,s2        # t4 = x*m
        add     t4,t4,t2        # t4 = x*m+y
        # If(x == 0 || x == n-1 || y == 0 || y == m-1)
        beq     t1,zero,BORDER
        beq     t2,zero,BORDER
        addi    t3,s1,-1
        beq     t1,t3,BORDER
        addi    t3,s2,-1
        beq     t2,t3,BORDER
       
        # Else
        # loop unrolling: compute the nine entries directly without using 9 loops
        addi    a7,zero,0       # a7: res
        # 1
        lw      t5,0(s0)        # t5: K[i][j]
        sub     t3,t4,s2
        addi    t3,t3,-1        # t3: x*m+y-m-1
        slli    t6,t3,2
        add     t6,t6,s3        # t6: &img[x*m+y-1]
        lw      a6,0(t6)        # a6: img[x*m+y-1]
        sll     a6,a6,t5
        add     a7,a7,a6
        # 2
        lw      t5,4(s0)
        lw      a6,4(t6)
        sll     a6,a6,t5
        add     a7,a7,a6
        # 3 
        lw      t5,8(s0)
        lw      a6,8(t6)
        sll     a6,a6,t5
        add     a7,a7,a6
        # 4
        lw      t5,12(s0)
        slli    t3,s2,2         # s3 = 4*m
        add     t6,t6,t3        # t6: x*m+y-1
        lw      a6,0(t6)
        sll     a6,a6,t5
        add     a7,a7,a6
        # 5
        lw      t5,16(s0)
        lw      a6,4(t6)
        sll     a6,a6,t5
        add     a7,a7,a6
        # 6
        lw      t5,20(s0)
        lw      a6,8(t6)
        sll     a6,a6,t5
        add     a7,a7,a6
        # 7
        lw      t5,24(s0)
        add     t6,t6,t3
        lw      a6,0(t6)        # i = 2
        sll     a6,a6,t5
        add     a7,a7,a6
        # 8
        lw      t5,28(s0)
        lw      a6,4(t6)
        sll     a6,a6,t5
        add     a7,a7,a6
        # 9
        lw      t5,32(s0)
        lw      a6,8(t6)
        sll     a6,a6,t5
        add     a7,a7,a6
        # res/16
        srli    a7,a7,4
        slli    t4,t4,2
        add     t3,t4,s4
        sw      a7,0(t3)
        
        addi    t2,t2,1         # y++
        j       INNER_CONDITION

BORDER:
        slli    t4,t4,2
        add     a7,s3,t4        # a7 = img[x*m+y]
        lw      a7,0(a7)
        add     a6,s4,t4        # a6 = &result[x*m+y]
        # keep elements on the borders unchanged
        sw      a7,0(a6)
        
        addi    t2,t2,1         # y++

INNER_CONDITION:
        blt     t2,s2,INNER_LOOP        # y<m    

        addi    t1,t1,1                 # x++
OUTER_CONDITION:
        blt     t1,s1,OUTER_LOOP        # x<n
        
        # restore registers
        lw      s4,(8)sp
        lw      s3,(12)sp
        lw      s2,(16)sp
        lw      s1,(20)sp
        lw      s0,(24)sp
        lw      ra,(28)sp
        addi    sp,sp,32
        jr      ra 
        ret
# -------------------------------------------------------------------------------------------------------

# IMAGE OUTPUT
image_output:
# DO NOT MODIFY THIS!!!
        addi    sp,sp,-32
        sw      ra,28(sp)
        sw      s0,24(sp)
        sw      s1,20(sp)
        sw      s2,16(sp)
        sw      s3,12(sp)
        sw      s4,8(sp)
        sw      s5,4(sp)
        lw s1, n
        mv a0, s1
        jal _printf_num 
        li a0, 32
        jal _printf_char
        lw s2, m
        mv a0, s2
        jal _printf_num  
        li a0, 10
        jal _printf_char

        mul s1, s1, s2 
        la s3, result_img
        addi t1, zero, 0 
        addi s5, zero, 0
        bge t1, s1, L1 
L2:     
        lw a0, 0(s3)
        jal _printf_num
        li a0, 32
        jal _printf_char
        addi s5, s5, 1
        bge s5, s2, PRINT_NEXT_LINE
PRINT_END:
        addi s3, s3, 4
        addi t1, t1, 1
        blt t1, s1, L2
L1:
        lw      ra,28(sp)
        lw      s0,24(sp)
        lw      s1,20(sp)
        lw      s2,16(sp)
        lw      s3,12(sp)
        lw      s4,8(sp)
        lw      s5,4(sp)
        addi    sp,sp,32
        jr      ra
PRINT_NEXT_LINE:
        li a0, 10
        jal _printf_char
        addi s5, zero, 0
        jal PRINT_END
# IMAGE_OUTPUT_END

# IMAGE_TO_FILE
image_to_file:
# DO NOT MODIFY THIS!!!
    addi sp,sp,-4
    sw ra,0(sp)

    la a0, write_path
    li a7, 1024
    li a1, 1
    ecall
    mv t3, a0
    lw t0, n
    lw t1, m
    mul t2, t0, t1

    la a1, size
    li a2, 2
    li a7, 66
    ecall
    la t2, result_img
    addi t4, zero, 0
OUTPUT_ONE_LINE: 
    mv a0, t3
    mv a1, t2
    mv a2, t1
    li a7, 66
    ecall
    slli a3, t1, 2
    add t2, t2, a3
    addi t4, t4, 1
    blt t4, t0, OUTPUT_ONE_LINE

    mv a0, t3
    li a7, 57
    ecall
    lw ra,0(sp)
    addi sp,sp,4
    jr ra
# IMAGE_TO_FILE_END

# IMAGE_INPUT
image_input:
# DO NOT MODIFY THIS!!!
    addi sp,sp,-4
    sw ra, 0(sp)
    li a7, 1024
    li a1, 0
    la a0, read_path
    ecall
    mv t3, a0
    li a7, 65
    la a1, size
    li a2, 2
    ecall

    la a1, size
    la a5, n
    lw t4, 0(a1)
    sw t4, 0(a5)
    la a5, m
    lw t5, 4(a1)
    sw t5, 0(a5)
    mul t2, t4, t5
    mv a0, t3
    la a1, img
    mv a2, t2
    ecall
    mv a0, t3
    li a7, 57
    ecall
    lw ra, 0(sp)
    addi sp, sp, 4
    mv a0, t4
    mv a1, t5
    jr ra
# IMAGE_INPUT_END