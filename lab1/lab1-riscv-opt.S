.data
# -------------------------------------- TODO: FILL IN YOUR FILE PATH !!! -------------------------------------------
read_path:
        .string "/home/arch_stu2021010726/yao-archlab-f22/lab1/sample/turing_before.pixel"
write_path:
        .string "/home/arch_stu2021010726/yao-archlab-f22/lab1/run/turing-rv-opt.pixel"
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
.text
main:
        addi    sp,sp,-16
        sw      ra,12(sp)
        jal     image_input
        jal     image_process
        jal     image_output
        jal     image_to_file
        lw      ra,12(sp)
        li      a0,0
        li      a7, 10
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
# CYCLE: 2315602
# --------------------------------------- TODO: FILL IN CODE HERE ---------------------------------------
        addi    sp,sp,-48
        # store registers
        sw      ra,(44)sp
        sw      s1,(40)sp       # s1: n
        sw      s2,(36)sp       # s2: m
        sw      s3,(32)sp       # s3: *img
        sw      s4,(28)sp       # s4: *result_img
        sw      s5,(24)sp
        sw      s6,(20)sp
        sw      s7,(16)sp
        sw      s8,(12)sp
        sw      s9,(8)sp
        # load n from memory to s1
        lw      s1,n
        # load m from memory to s2
        lw      s2,m
        # load *img from memory to s3
        la      s3,img
        # load *result_img from memory to s4
        la      s4,result_img
        # border cases: x==0 || x== n-1 || y==0 || y==m-1
        # (cache - branch trade-off)
        # case1: x == 0 || n-1
        addi    t2,zero,0       # t2: 4*y
        slli    t3,s2,2
        addi    t3,t3,-3        # t3: 4*m-3
        mul     t6,s1,s2
        sub     t6,t6,s2        # t6: n*(m-1)
        slli    t6,t6,2         # t6: 4*n*(m-1)
        j CONDIITION_ONE
LOOP_ONE:
        # x==0
        add     t4,t2,s3        # t4: &img[y]
        add     t5,t2,s4        # t5: &result_img[y]
        lw      a7,0(t4)        # a7: img[y]
        sw      a7,0(t5)        # result_img[y] = img[y]
        # x== n-1
        add     t4,t4,t6        # t4: &img[(n-1)*m+y]
        add     t5,t5,t6        # t5: t5: &result_img[(n-1)*m+y]
        lw      a7,0(t4)        # a7: img[(n-1)*my]
        sw      a7,0(t5)        # result_img[(n-1)*my] = img[(n-1)*my]
        addi    t2,t2,4         
CONDIITION_ONE:
        blt     t2,t3,LOOP_ONE

        # case2: y == 0 || m-1
        addi    t1,zero,0       # t1: 4*x*m
        addi    t3,s1,-1
        mul     t3,t3,s2
        slli    t3,t3,2         # t3: 4*(n-1)*m
        slli    t2,s2,2         # t2: 4*m
        addi    t4,s2,-1        
        slli    t4,t4,2         # t4: 4*(m-1)
        j       CONDITION_TWO
LOOP_TWO:
        # y==0
        add     t5,t1,s3        # t5: &img[x*m]
        add     t6,t1,s4        # t6: &result_img[x*m]
        lw      a7,0(t5)        # a7: img[x*m]
        sw      a7,0(t6)        # result_img[x*m] = img[x*m]
        # y==m-1
        add     t5,t5,t4        # t5: &img[x*m+m-1]
        add     t6,t6,t4        # t6: &result_img[x*m+m-1]
        lw      a7,0(t5)
        sw      a7,0(t6)

        add    t1,t1,t2         # 4*x*m + 4*m
CONDITION_TWO:
        bge     t3,t1,LOOP_TWO  # 4*(n-1)*m >= 4*x*m


        # OUTERLOOP: for(int x=1; x<n-1; x+=3)
        addi    t1,zero,1       # t1: x
        addi    a2,s1,-3        # a2: n-3
        addi    a7,s2,1
        slli    a7,a7,2         # a7: (x*m+y)*4, x=1, y=1
        add     a7,a7,s3        # a7: (x*m+y)*4 + img, x=1, y=1
        slli    a6,s2,2         # a6: 4*m
        j       OUTER_CONDITION
OUTER_LOOP:
        # INNERLOOP: for(int j=1; j<m-1; j+=2)
        addi    t2,zero,1       # t2: y
        addi    a3,s2,-3        # a3: m-3
        j       INNER_CONDITION

INNER_LOOP:
        # LOOP TILING: 3 x 3 BLOCK
        addi    t3,zero,0   # t3: store res for result_img[x*m+y]
        addi    t4,zero,0   # t4: store res for result_img[x*m+(y+1)]
        addi    t5,zero,0   # t5: store res for result_img[x*m+(y+2)]
        addi    t6,zero,0   # t6: store res for result_img[(x+1)*m+y]
        addi    s5,zero,0   # s5: store res for result_img[(x+1)*m+(y+1)]
        addi    s6,zero,0   # s6: store res for result_img[(x+1)*m+(y+2)]
        addi    s7,zero,0   # s7: store res for result_img[(x+2)*m+y]
        addi    s8,zero,0   # s8: store res for result_img[(x+2)*m+(y+1)]
        addi    s9,zero,0   # s9: store res for result_img[(x+2)*m+(y+2)]
        # (x-1,y-1): a7 - 4*m - 4 #
        sub     a4,a7,a6
        addi    a4,a4,-4
        lw      a5,0(a4)
        add     t3,t3,a5
        # (x-1,y): a7 - 4*m #
        addi    a4,a4,4
        lw      a5,0(a4)
        add     t4,t4,a5
        slli    a5,a5,1
        add     t3,t3,a5
        # (x-1,y+1): a7 - 4*m + 4 #
        addi    a4,a4,4
        lw      a5,0(a4)
        add     t3,t3,a5
        add     t5,t5,a5
        slli    a5,a5,1
        add     t4,t4,a5
        # (x-1,y+2): a7 - 4*m + 8 #
        addi    a4,a4,4
        lw      a5,0(a4)
        add     t4,t4,a5
        slli    a5,a5,1
        add     t5,t5,a5
        # (x-1,y+3): a7 - 4*m + 12 #
        addi    a4,a4,4
        lw      a5,0(a4)
        add     t5,t5,a5
        # (x,y-1): a7 - 4 #
        addi    a4,a7,-4
        lw      a5,0(a4)
        add     t6,t6,a5
        slli    a5,a5,1
        add     t3,t3,a5
        # (x,y): a7 #
        addi    a4,a4,4
        lw      a5,0(a4)
        add     s5,s5,a5
        slli    a5,a5,1
        add     t4,t4,a5
        add     t6,t6,a5
        slli    a5,a5,1
        add     t3,t3,a5
        # (x,y+1): a7 + 4 #
        addi    a4,a4,4
        lw      a5,0(a4)
        add     t6,t6,a5
        add     s6,s6,a5
        slli    a5,a5,1
        add     t3,t3,a5
        add     t5,t5,a5
        add     s5,s5,a5
        slli    a5,a5,1
        add     t4,t4,a5
        # (x,y+2): a7 + 8 #
        addi    a4,a4,4
        lw      a5,0(a4)
        add     s5,s5,a5
        slli    a5,a5,1
        add     t4,t4,a5
        add     s6,s6,a5
        slli    a5,a5,1
        add     t5,t5,a5
        # (x,y+3): a7 + 12 #
        addi    a4,a4,4
        lw      a5,0(a4)
        add     s6,s6,a5
        slli    a5,a5,1
        add     t5,t5,a5
        # (x+1,y-1): a7 + 4*m - 4 #
        add     a4,a7,a6
        addi    a4,a4,-4
        lw      a5,0(a4)
        add     t3,t3,a5
        add     s7,s7,a5
        slli    a5,a5,1
        add     t6,t6,a5 
        # (x+1,y): a7 + 4*m #
        addi    a4,a4,4
        lw      a5,0(a4)
        add     t4,t4,a5
        add     s8,s8,a5
        slli    a5,a5,1
        add     t3,t3,a5
        add     s5,s5,a5
        add     s7,s7,a5
        slli    a5,a5,1
        add     t6,t6,a5
        # (x+1,y+1): a7 + 4*m + 4 #
        addi    a4,a4,4
        lw      a5,0(a4)
        add     t3,t3,a5
        add     t5,t5,a5
        add     s7,s7,a5
        add     s9,s9,a5
        slli    a5,a5,1
        add     t4,t4,a5
        add     t6,t6,a5
        add     s6,s6,a5
        add     s8,s8,a5
        slli    a5,a5,1
        add     s5,s5,a5
        # (x+1,y+2): a7 + 4*m + 8 #
        addi    a4,a4,4
        lw      a5,0(a4)
        add     t4,t4,a5
        add     s8,s8,a5
        slli    a5,a5,1
        add     t5,t5,a5
        add     s5,s5,a5
        add     s9,s9,a5
        slli    a5,a5,1
        add     s6,s6,a5
        # (x+1,y+2): a7 + 4*m + 12 #
        addi    a4,a4,4
        lw      a5,0(a4)
        add     t5,t5,a5
        add     s9,s9,a5
        slli    a5,a5,1
        add     s6,s6,a5
        # (x+2,y-1): a7 + 8*m - 4 #
        add     a4,a7,a6
        add     a4,a4,a6
        addi    a4,a4,-4
        lw      a5,0(a4)
        add     t6,t6,a5
        slli    a5,a5,1
        add     s7,s7,a5
        # (x+2,y): a7 + 8*m #
        addi    a4,a4,4
        lw      a5,0(a4)
        add     s5,s5,a5
        slli    a5,a5,1
        add     t6,t6,a5
        add     s8,s8,a5
        slli    a5,a5,1
        add     s7,s7,a5
        # (x+2,y+1): a7 + 8*m + 4 #
        addi    a4,a4,4
        lw      a5,0(a4)
        add     t6,t6,a5
        add     s6,s6,a5
        slli    a5,a5,1
        add     s5,s5,a5
        add     s7,s7,a5
        add     s9,s9,a5
        slli    a5,a5,1
        add     s8,s8,a5
        # (x+2,y+2): a7 + 8*m + 8 #
        addi    a4,a4,4
        lw      a5,0(a4)
        add     s5,s5,a5
        slli    a5,a5,1
        add     s6,s6,a5
        add     s8,s8,a5
        slli    a5,a5,1
        add     s9,s9,a5
        # (x+2,y+2): a7 + 8*m + 12 #
        addi    a4,a4,4
        lw      a5,0(a4)
        add     s6,s6,a5
        slli    a5,a5,1
        add     s9,s9,a5
        # (x+3,y-1): a7 + 12*m - 4 #
        add     a4,a7,a6
        add     a4,a4,a6
        add     a4,a4,a6
        addi    a4,a4,-4
        lw      a5,0(a4)
        add     s7,s7,a5
        # (x+3,y): a7 + 12*m #
        addi    a4,a4,4
        lw      a5,0(a4)
        add     s8,s8,a5
        slli    a5,a5,1
        add     s7,s7,a5
        # (x+3,y+1): a7 + 12*m + 4 #
        addi    a4,a4,4
        lw      a5,0(a4)
        add     s7,s7,a5
        add     s9,s9,a5
        slli    a5,a5,1
        add     s8,s8,a5
        # (x+3,y+2): a7 + 12*m + 8 #
        addi    a4,a4,4
        lw      a5,0(a4)
        add     s8,s8,a5
        slli    a5,a5,1
        add     s9,s9,a5
        # (x+3,y+3): a7 + 12*m + 12 #
        addi    a4,a4,4
        lw      a5,0(a4)
        add     s9,s9,a5
        # save t3,t4,t5,t6,s5,s6,s7,s8,s9 to result_image
        # res/16
        srli    t3,t3,4
        srli    t4,t4,4
        srli    t5,t5,4
        srli    t6,t6,4
        srli    s5,s5,4
        srli    s6,s6,4
        srli    s7,s7,4
        srli    s8,s8,4
        srli    s9,s9,4
        # a7 = 4*(x*m+y) + result_img
        sub     a7,a7,s3
        add     a7,a7,s4
        # save t3
        sw      t3,0(a7)
        # save t4
        addi    a7,a7,4
        sw      t4,0(a7)
        # save t5
        addi    a7,a7,4
        sw      t5,0(a7)
        # save s6
        add     a7,a7,a6
        sw      s6,0(a7)
        # save s5
        addi    a7,a7,-4
        sw      s5,0(a7)
        # save t6
        addi    a7,a7,-4
        sw      t6,0(a7)
        # save s7
        add     a7,a7,a6
        sw      s7,0(a7)
        # save s8
        addi    a7,a7,4
        sw      s8,0(a7)
        # save s9
        addi    a7,a7,4
        sw      s9,0(a7)
        # update y
        addi    t2,t2,3
        # update a7
        sub     a7,a7,s4
        add     a7,a7,s3
        addi    a7,a7,4
        sub     a7,a7,a6
        sub     a7,a7,a6
        
        
        

INNER_CONDITION:
        blt     t2,a3,INNER_LOOP    # y < m-3
        addi    a3,a3,1             # a3: m-2
        blt     a3,t2,OUTER_UPDATE  # m-2 < y

RIGHTBORDER:
        # y == m-2 or m-3
        addi    t3,zero,0   # t3: store res for result_img[x*m+y]
        addi    t4,zero,0   # t4: store res for result_img[(x+1)*m+y]
        addi    t5,zero,0   # t5: store res for result_img[(x+2)*m+y]
        # (x-1,y-1): a7 - 4*m - 4 #
        sub     a4,a7,a6
        addi    a4,a4,-4
        lw      a5,0(a4)
        add     t3,t3,a5
        # (x-1,y): a7 - 4*m #
        addi    a4,a4,4
        lw      a5,0(a4)
        slli    a5,a5,1
        add     t3,t3,a5
        # (x-1,y+1): a7 - 4*m + 4 #
        addi    a4,a4,4
        lw      a5,0(a4)
        add     t3,t3,a5
        # (x,y-1): a7 - 4 #
        addi    a4,a7,-4
        lw      a5,0(a4)
        add     t4,t4,a5
        slli    a5,a5,1
        add     t3,t3,a5
        # (x,y): a7 #
        addi    a4,a4,4
        lw      a5,0(a4)
        slli    a5,a5,1
        add     t4,t4,a5
        slli    a5,a5,1
        add     t3,t3,a5
        # (x,y+1): a7 + 4 #
        addi    a4,a4,4
        lw      a5,0(a4)
        add     t4,t4,a5
        slli    a5,a5,1
        add     t3,t3,a5
        # (x+1,y-1): a7 + 4*m - 4 #
        add     a4,a7,a6
        addi    a4,a4,-4
        lw      a5,0(a4)
        add     t3,t3,a5
        add     t5,t5,a5
        slli    a5,a5,1
        add     t4,t4,a5 
        # (x+1,y): a7 + 4*m #
        addi    a4,a4,4
        lw      a5,0(a4)
        slli    a5,a5,1
        add     t3,t3,a5
        add     t5,t5,a5
        slli    a5,a5,1
        add     t4,t4,a5
        # (x+1,y+1): a7 + 4*m + 4 #
        addi    a4,a4,4
        lw      a5,0(a4)
        add     t3,t3,a5
        add     t5,t5,a5
        slli    a5,a5,1
        add     t4,t4,a5
        # (x+2,y-1): a7 + 8*m - 4 #
        add     a4,a7,a6
        add     a4,a4,a6
        addi    a4,a4,-4
        lw      a5,0(a4)
        add     t4,t4,a5
        slli    a5,a5,1
        add     t5,t5,a5
        # (x+2,y): a7 + 8*m #
        addi    a4,a4,4
        lw      a5,0(a4)
        slli    a5,a5,1
        add     t4,t4,a5
        slli    a5,a5,1
        add     t5,t5,a5
        # (x+2,y+1): a7 + 8*m + 4 #
        addi    a4,a4,4
        lw      a5,0(a4)
        add     t4,t4,a5
        slli    a5,a5,1
        add     t5,t5,a5
        # (x+3,y-1): a7 + 12*m - 4 #
        add     a4,a7,a6
        add     a4,a4,a6
        add     a4,a4,a6
        addi    a4,a4,-4
        lw      a5,0(a4)
        add     t5,t5,a5
        # (x+3,y): a7 + 12*m #
        addi    a4,a4,4
        lw      a5,0(a4)
        slli    a5,a5,1
        add     t5,t5,a5
        # (x+3,y+1): a7 + 12*m + 4 #
        addi    a4,a4,4
        lw      a5,0(a4)
        add     t5,t5,a5

        # save t3,t5 to result_image
        # res/16
        srli    t3,t3,4
        srli    t4,t4,4
        srli    t5,t5,4
        # a7 = 4*(x*m+y) + result_img
        sub     a7,a7,s3
        add     a7,a7,s4
        # save t3
        sw      t3,0(a7)
        # save t4
        add     a7,a7,a6
        sw      t4,0(a7)
        # save t5
        add     a7,a7,a6
        sw      t5,0(a7)
        # update y
        addi    t2,t2,1
        # restore a7
        sub     a7,a7,s4
        add     a7,a7,s3
        sub     a7,a7,a6
        sub     a7,a7,a6
        addi    a7,a7,4

        beq     t2,a3,RIGHTBORDER


        
OUTER_UPDATE:
        addi    t1,t1,3                 # x += 3
        addi    a7,a7,8
        add     a7,a7,a6
        add     a7,a7,a6


OUTER_CONDITION: 
        blt     t1,a2,OUTER_LOOP        # x < n-3
        addi    a2,a2,1                 # a2: n-2
        blt     a2,t1,PROCESS_END       # n-2 < x

BOTTOM:
        # x == n-2 or n-3: for (int j=1; j<m-1; j+=1), NO LOOP TILING 
        addi    t2,zero,1       # t2: y
        addi    a3,s2,-1        # a3: m-1
        j       BOTTOM_CONDITION
BOTTOM_LOOP:
        addi    t3,zero,0       # t3: res
        # left-up
        sub     a4,a7,a6
        addi    a4,a4,-4
        lw      a5,0(a4)
        add     t3,t3,a5
        # up
        addi    a4,a4,4
        lw      a5,0(a4)
        slli    a5,a5,1
        add     t3,t3,a5
        # right-up
        addi    a4,a4,4
        lw      a5,0(a4)
        add     t3,t3,a5
        # left
        addi    a4,a7,-4
        lw      a5,0(a4)
        slli    a5,a5,1
        add     t3,t3,a5
        # center
        addi    a4,a4,4
        lw      a5,0(a4)
        slli    a5,a5,2
        add     t3,t3,a5
        # right
        addi    a4,a4,4
        lw      a5,0(a4)
        slli    a5,a5,1
        add     t3,t3,a5
        # left-down
        add     a4,a7,a6
        addi    a4,a4,-4
        lw      a5,0(a4)
        add     t3,t3,a5
        # down
        addi    a4,a4,4
        lw      a5,0(a4)
        slli    a5,a5,1
        add     t3,t3,a5
        # right-down
        addi    a4,a4,4
        lw      a5,0(a4)
        add     t3,t3,a5
        # save 
        srli    t3,t3,4
        sub     a7,a7,s3
        add     a7,a7,s4
        sw      t3,0(a7)
        # update y
        addi    t2,t2,1
        # update a7
        sub     a7,a7,s4
        add     a7,a7,s3
        addi    a7,a7,4
BOTTOM_CONDITION:
        blt     t2,a3,BOTTOM_LOOP    # y < m-1

        addi    t1,t1,1
        addi    a7,a7,8
        beq     t1,a2,BOTTOM



PROCESS_END:       
        # restore registers
        lw      s9,(8)sp
        lw      s8,(12)sp
        lw      s7,(16)sp
        lw      s6,(20)sp
        lw      s5,(24)sp
        lw      s4,(28)sp
        lw      s3,(32)sp
        lw      s2,(36)sp
        lw      s1,(40)sp
        lw      ra,(44)sp
        addi    sp,sp,48
        jr      ra 
        ret




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