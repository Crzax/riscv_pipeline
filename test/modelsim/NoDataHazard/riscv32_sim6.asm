# Test the RISC-V processor in simulation
# 已经能正确执行：addi, lui, jal
# 待验证：beq, bne, blt, bge, bltu, bgeu
# 本测试只验证单条指令的功能，不考察转发和冒险检测的功能，所以在相关指令之间添加了足够多的nop指令

#		Assembly                Description
main:   addi    x5, x0, 0               #x5 <== 0x0
        addi    x6, x0, 0               #x6 <== 0x0
        lui     x7, 0xfffff             #x7 <== 0xFFFFF000
        addi    x0, x0, 0               #instr 00000013
        addi    x0, x0, 0
        addi    x0, x0, 0

        beq     x6, x0, br1             #beq taken
        addi    x0, x0, 0
        addi    x0, x0, 0
        addi    x0, x0, 0
        addi    x0, x0, 0
br1ret: beq     x7, x0, br2ret          #beq not taken
        addi    x0, x0, 0
        addi    x0, x0, 0
        addi    x0, x0, 0
        addi    x0, x0, 0          
        addi    x5, x5, 1               #x5 = 2
        addi    x0, x0, 0
        addi    x0, x0, 0
        addi    x0, x0, 0
br2ret: bne     x7, x0, br3             #bne taken
        addi    x0, x0, 0
        addi    x0, x0, 0
        addi    x0, x0, 0
        addi    x0, x0, 0
br3ret: bne     x6, x0, br4             #bne not taken
        addi    x0, x0, 0
        addi    x0, x0, 0
        addi    x0, x0, 0
        addi    x0, x0, 0
        addi    x5, x5, 1               #x5 = 4
        addi    x0, x0, 0
        addi    x0, x0, 0
        addi    x0, x0, 0
br4ret: blt     x7, x6, br5             #blt taken
        addi    x0, x0, 0
        addi    x0, x0, 0
        addi    x0, x0, 0
        addi    x0, x0, 0
br5ret: blt     x6, x7, br6             #blt not taken
        addi    x0, x0, 0
        addi    x0, x0, 0
        addi    x0, x0, 0
        addi    x0, x0, 0
        addi    x5, x5, 1               #x5 = 6
        addi    x0, x0, 0
        addi    x0, x0, 0
        addi    x0, x0, 0
br6ret: bge     x6, x0, br7             #bge taken
        addi    x0, x0, 0
        addi    x0, x0, 0
        addi    x0, x0, 0
        addi    x0, x0, 0
br7ret: bge     x6, x7, br8             #bge taken
        addi    x0, x0, 0
        addi    x0, x0, 0
        addi    x0, x0, 0
        addi    x0, x0, 0
br8ret: bge     x7, x0, br9             #bge not taken
        addi    x0, x0, 0
        addi    x0, x0, 0
        addi    x0, x0, 0
        addi    x0, x0, 0
        addi    x5, x5, 1               #x5 = 9
        addi    x0, x0, 0
        addi    x0, x0, 0
        addi    x0, x0, 0
br9ret: bltu    x6, x7, br10            #bltu taken
        addi    x0, x0, 0
        addi    x0, x0, 0
        addi    x0, x0, 0
        addi    x0, x0, 0
br10ret:bltu    x7, x6, br11            #bltu not taken
        addi    x0, x0, 0
        addi    x0, x0, 0
        addi    x0, x0, 0
        addi    x0, x0, 0
        addi    x5, x5, 1               #x5 = 0xB
        addi    x0, x0, 0
        addi    x0, x0, 0
        addi    x0, x0, 0
br11ret:bgeu    x7, x6, br12            #bgtu taken
        addi    x0, x0, 0
        addi    x0, x0, 0
        addi    x0, x0, 0
        addi    x0, x0, 0
br12ret:bgeu    x6, x7, br13            #bgtu not taken
        addi    x0, x0, 0
        addi    x0, x0, 0
        addi    x0, x0, 0
        addi    x0, x0, 0
        addi    x5, x5, 1               #x5 = 0xD
        addi    x0, x0, 0
        addi    x0, x0, 0
        addi    x0, x0, 0
br13ret:jal     x0, end                  #x5 should be 0xD for correct implementation
        addi    x0, x0, 0
        addi    x0, x0, 0
        addi    x0, x0, 0

br1:    addi    x5, x5, 1               #x5 = 1
        addi    x0, x0, 0
        addi    x0, x0, 0
        addi    x0, x0, 0
        jal     x0, br1ret
        addi    x0, x0, 0
        addi    x0, x0, 0
        addi    x0, x0, 0
        addi    x0, x0, 0

br2:    jal     x0, br2ret
        addi    x0, x0, 0
        addi    x0, x0, 0
        addi    x0, x0, 0
        addi    x0, x0, 0

br3:    addi    x5, x5, 1               #x5 = 3
        addi    x0, x0, 0
        addi    x0, x0, 0
        addi    x0, x0, 0
        jal     x0, br3ret
        addi    x0, x0, 0
        addi    x0, x0, 0
        addi    x0, x0, 0
        addi    x0, x0, 0

br4:    jal     x0, br4ret
        addi    x0, x0, 0
        addi    x0, x0, 0
        addi    x0, x0, 0
        addi    x0, x0, 0

br5:    addi    x5, x5, 1               #x5 = 5
        addi    x0, x0, 0
        addi    x0, x0, 0
        addi    x0, x0, 0
        jal     x0, br5ret
        addi    x0, x0, 0
        addi    x0, x0, 0
        addi    x0, x0, 0
        addi    x0, x0, 0

br6:    jal     x0, br6ret
        addi    x0, x0, 0
        addi    x0, x0, 0
        addi    x0, x0, 0
        addi    x0, x0, 0

br7:    addi    x5, x5, 1               #x5 = 7
        addi    x0, x0, 0
        addi    x0, x0, 0
        addi    x0, x0, 0
        jal     x0, br7ret
        addi    x0, x0, 0
        addi    x0, x0, 0
        addi    x0, x0, 0
        addi    x0, x0, 0

br8:    addi    x5, x5, 1               #x5 = 8
        addi    x0, x0, 0
        addi    x0, x0, 0
        addi    x0, x0, 0
        jal     x0, br8ret
        addi    x0, x0, 0
        addi    x0, x0, 0
        addi    x0, x0, 0
        addi    x0, x0, 0

br9:    jal     x0, br9ret
        addi    x0, x0, 0
        addi    x0, x0, 0
        addi    x0, x0, 0
        addi    x0, x0, 0

br10:   addi    x5, x5, 1               #x5 = 0xA
        addi    x0, x0, 0
        addi    x0, x0, 0
        addi    x0, x0, 0
        jal     x0, br10ret
        addi    x0, x0, 0
        addi    x0, x0, 0
        addi    x0, x0, 0
        addi    x0, x0, 0

br11:   jal     x0, br11ret
        addi    x0, x0, 0
        addi    x0, x0, 0
        addi    x0, x0, 0
        addi    x0, x0, 0

br12:   addi    x5, x5, 1               #x5 = 0xC
        addi    x0, x0, 0
        addi    x0, x0, 0
        addi    x0, x0, 0
        jal     x0, br12ret
        addi    x0, x0, 0
        addi    x0, x0, 0
        addi    x0, x0, 0
        addi    x0, x0, 0

br13:   jal     x0, br13ret
        addi    x0, x0, 0
        addi    x0, x0, 0
        addi    x0, x0, 0
        addi    x0, x0, 0

end:    addi    x5, x5, 1