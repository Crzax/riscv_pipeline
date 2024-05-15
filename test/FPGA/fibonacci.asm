#################################################
#	x1		stack pointer
#	x5		return addr
#	x6		n = SW[14:10]
#	x7		fib(n)
#	x31		0xFFFF0000
#################################################
#	fib(n)
#		n		fib			n		fib
#		0		0x1			16		0x63d
#		1		0x1			17		0xa18
#		2		0x2			18		0x1055
#		3		0x3			19		0x1a6d
#		4		0x5			20		0x2ac2
#		5		0x8			21		0x452f
#		6		0xd			22		0x6ff1
#		7		0x15		23		0xb520
#		8		0x22		24		0x12511
#		9		0x37		25		0x1da31
#		10		0x59		26		0x2ff42
#		11		0x90		27		0x4d973
#		12		0xe9		28		0x7d8b5
#		13		0x179		29		0xcb228
#		14		0x262		30		0x148add
#		15		0x3db		31		0x213d05
#################################################


	lui		x31, 0xFFFF0
	addi	x1, x0, -4

main:
	lw		x6, 0x004(x31)
	srli	x6, x6, 10
	andi	x6, x6, 0x01F
	jal		x5, fib
	sw		x7, 0x00C(x31)
	jal		x0, main

fib:
	addi	x7, x0, 1
	bge		x7, x6, ret
	addi	x1, x1, -8
	sw		x5, 4(x1)
	addi	x6, x6, -1
	jal		x5, fib
	sw		x7, 0(x1)
	addi	x6, x6, -1
	jal		x5, fib
	lw		x8, 0(x1)
	add		x7, x7, x8
	addi	x6, x6, 2
	lw		x5, 4(x1)
	addi	x1, x1, 8
ret:
	jalr	x0, x5, 0
