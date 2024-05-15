# Test the RISC-V processor in simulation
# 已经能正确执行：lui, addi
# 待验证：xori, ori, andi, srli, srai, slli
# 本测试只验证单条指令的功能，不考察转发和冒险检测的功能，所以在相关指令之间添加了足够多的nop指令

#		Assembly               Description
main:	lui 	x5, 0xf5f5f            #x5 <== 0xF5F5F000
        addi    x0, x0, 0
        addi    x0, x0, 0 
        addi    x0, x0, 0
        addi    x0, x0, 0

        srli    x6, x5, 12             #x6 <== 0x000F5F5F
        srai    x7, x5, 4              #x7 <== 0xFF5F5F00
        slli    x8, x5, 4              #x8 <== 0x5F5F0000
        addi    x0, x0, 0
        addi    x0, x0, 0

        xori	x9, x6, 0x70f          #x9 <== 0x000F5850
        ori	x10, x6, 0x70f         #x10 <== 0x000F5F5F
        andi	x11, x6, 0x70f         #x11 <== 0x0000070F