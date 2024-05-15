# Test the RISC-V processor in simulation
# 已经能正确执行：addi, add, lw, sw, beq, jal, jalr
# 待验证：能否正确处理转发：MEM-->EX, WB-->EX, WB-->MEM, MEM-->ID

main:	addi x5, x0, 1		#0x0: 00100293
		addi x6, x0, 2		#0x4: 00200313
		add  x7, x5, x6		#EX rs1 from WB, rs2 from MEM, x7 = 3, 0x8: 006283b3
		add  x8, x7, x6		#EX rs1 from MEM, rs2 from WB, x8 = 5, 0xc: 00638433
		sw	 x8, 0(x0)		#MEM write data from WB's arith op, mem[0] = 5, 0x10: 00802023
		lw	 x9, 0(x0)		#0x14: 00002483
		sw	 x9, 4(x0)		#MEM write data from WB's load, mem[4] = 5, 0x18: 00902223
		lw   x10, 4(x0)		#0x1c: 00402503

		addi x5, x0, 3		#0x20: 00300293
		addi x6, x0, 3		#0x24: 00300313
		addi x0, x0, 0		#0x28: 00000013
		beq  x5, x6, br1 	#ID rs1 from MEM, 0x2c: 00628663
		addi x10, x0, 10	#should not run, 0x30: 00a00513
br1ret:	jal	 x0, br2		#0x34: 0100006f

br1: 	addi x11, x0, 0x34	#0x38: 03400593
        addi x0, x0, 0		#0x3c: 00000013
        jalr x0, x11, 0		#jalr x0, br1ret, 0x40: 00058067

br2ret: jal  x0, end		#0x44

br2:	addi x11, x0, 0x44
		sw   x11, 8(x0)
		lw   x12, 8(x0)
		addi x0, x0, 0
		jalr x0, x12, 0

end:	addi x5, x5, 0x100