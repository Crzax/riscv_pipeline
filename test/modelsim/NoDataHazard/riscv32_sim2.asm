# Test the RISC-V processor in simulation
# 已经能正确执行：lui, addi
# 待验证：add，sub，xor, or, and, srl, sra, sll
# 本测试只验证单条指令的功能，不考察转发和冒险检测的功能，所以在相关指令之间添加了足够多的nop指令

#		Assembly	     		Description
main:	lui x5, 0x12345          #x5 <== 0x12345
		lui x6, 0xfffff          #x6 <== 0xfffff
		addi	x12, x0, 4
		addi	x0, x0, 0        #nop
		addi	x0, x0, 0
		addi	x0, x0, 0
        add	x7, x5, x6           #x7 <== 0x12344000
        sub	x8, x5, x6           #x8 <== 0x12346000

        xor	x9, x5, x6           #x9 <== 0xEDCBA000
        or	x10, x5, x6          #x10 <== 0xFFFFF000
        and	x11, x5, x6 	     #x11 <== 0x12345000

        srl	x13, x6, x12	     #x13 <== 0x0FFFFF00
        sra	x14, x6, x12	     #x14 <== 0xFFFFFF00
        sll	x15, x5, x12	     #x15 <== 0x23450000

