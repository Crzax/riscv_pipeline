# Test the RISC-V processor in simulation
# 已经能正确执行：addi, lw, sw, beq，jal, jalr
# 待验证：能否正确处理需要停顿的数据依赖: load-use, arith-beq, load-beq, arith-jal, load-jalr

main:	addi x5, x0, 5
		sw	 x5, 0(x0)		#mem[0] = 5
		lw	 x6, 0(x0)
		addi x7, x6, 2		#load-use data hazard, stall one cycle, x7 = 7
		addi x8, x0, 7
		beq  x7, x8, br1 	#arith-beq data hazard, stall one cycle
		addi x10, x0, 10	#should not run
br1ret: lw   x7, 0(x0)		#x7 = 5
		beq  x5, x7, br2 	#lw-beq data hazard, stall two cycles
		addi x10, x0, 10	#should not run
br2ret: addi x14, x0, 1
		jal  x0, end

br1:	addi x11, x0, 0x1c
        jalr x0, x11, 0

br2:	addi x12, x0, 40
        sw   x12, 8(x0)
        lw   x13, 8(x0)
        jalr x0, x13, 0		#jalr x0, br2ret

end:	addi x5, x5, 0x100
