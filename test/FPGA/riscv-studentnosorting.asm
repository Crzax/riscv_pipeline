#############################################
# C program for sorting the student no.
#############################################
#   sortedstuno = stuno;
#   mask0 = 0x0f; 
#   for (int i= 0; i < 8; i++) {
#       a = sortedstuno & mask0; //每次处理一个十六进制位，析出来
#       a = a >> (4 * i); //移到最后一位，a即待排序的数字
#       mask1 = mask0 << 4; 
#       bestj = i;
#       tmpMax = a; 
#		for (int j = i + 1; j < 8) {
#       	b = sortedstuno & mask1;
#       	b = b >> (4 * j);
#       	if (tmpMax < b) {
#          		tmpMax = b;
#          		bestj = j;
#       	}
#       	mask1 = mask1 << 4;
#     	}
#     	if (a < tmpMax) { //准备交换位置i的数字和位置bestj的数字，分别是a和tmpMax
#         	mask1 = 0x0f;
#         	bestj4 = bestj << 2;
#         	mask1 = mask1 << bestj4
#         	mask2 = mask0 | mask1;
#         	mask2 = ~mask2;
#         	sortedstuno = sortedstuno & mask2; //i位和j位都置0，其他为保持不变
#         	tmpMax = tmpMax << (4 * i);
#         	sortedstuno = sortedstuno | tmpMax;
#         	a = a << bestj4;
#         	sortedstuno = sortedstuno | a;
#       }
#     	mask0 = mask0 << 4;
#   }
#############################################
# the uasge of the registers
#############################################
# mem[0], student no.
# mem[4], sorted student no
# x15, partially sorted student number
# x1, the address of switch 
# x2, the outer loop variable i / the address of seg7
# x3, the inner loop variable j / the switch input 
# x4, mask0
# x5, mask1
# x6, mask2
# x7, a
# x8, b
# x9, 4 * i
# x10, 4 * j
# x11, N = 8
# x12, bestj
# x13, tmpMax
# x14, compare result
#############################################
改汇编要注意的点：
1. 汇编的伪指令j变成jal或者jalr，会自动使用x1寄存器，容易冲突，尽量避免使用x1寄存器，或者自行都修改为x0
	但是如果是函数调用必须就会比较麻烦，所以推荐：不使用x1寄存器
2. lui立即数字段比mip32小，只有12位，所以设置大常数比较麻烦，就两个十六进制位一设置，简单一点
3. mips32的sll指令需要改为slli，sllv指令可以直接用sll指令替换
4. Venus不会翻译nor，自行用xori x2, x2, -1实现
#############################################
	addi 	x2, x0, 0x87		# This is the BCD encoding for the studnet no: a hex digit for each decimal digit
	slli 	x2, x2, 8
	addi 	x2, x2, 0x65
	slli 	x2, x2, 16

	addi 	x3, x0, 0x43
	slli 	x3, x3, 8
	addi 	x3, x3, 0x21
	add	 	x2, x2, x3			# set the student no., USE YOUR OWN STUDENT NO.!!!

	sw 		x2, 0(x0)           # store the original stuno at data memory
	addi    x11, x0, 8          # the size of stuno, N = 8
	lw      x15, 0(x0)         	# x15 = [0x0] = stuno
	add     x2, x0, x0          # the outer loop variable initilization, i = 0,                                         
	addi    x4, x0, 0x0f        # mask0 = 0xf                                                                           
loop1:
	and     x7, x15, x4         # a = sortedstuno & mask0, get the BCD to be processed                                 
	slli 	x9, x2, 2           # (4 * i)                                                                               
	srl 	x7, x7, x9          # a = a >> (4 * i), shift the BCD to the LSB 4 bits                                     
	slli    x5, x4, 4           # mask1 = mask0 << 4                                                       
    add     x12, x2, x0         # bestj = i, remmember the position of the largest BCD in this loop                   
    add     x13, x7, x0         # tmpMax = a, remember the last BCD in this loop                                        
    addi    x3, x2, 1           # j = i + 1, the inner loop variable initilization, j = i + 1                          
loop2:
    beq     x3, x11, checkswap  #  to check if j == 8                                                                    
    and     x8, x15, x5 		#  b = sortedstuno & mask1                                                               
    slli 	x10, x3, 2          #  (4 * j)                                                                              
    srl 	x8, x8, x10         #  b = b >> (4 * j), shift the BCD to the LSB 4 bits                                    
    slt     x14, x13, x8        #                                                                                        
    beq     x14, x0, incrLoop2  # if (tmpMax >= b), increase j                                                           
    add     x13, x8, x0         #  tmpMax = b, remember the last BCD in this loop                                        
    add     x12, x3, x0         #  bestj = j, remmember the position of the largest BCD in this loop                     
incrLoop2:
    slli 	x5, x5, 4           #  mask1 = mask1 << 4                                                                   
    addi    x3, x3, 1           #  j = j + 1                                                                           
    jal     x0, loop2                                                                                                   
checkswap:
    slt     x14, x2, x12        #  to check if the position of the largest BCD in the this loop has been changed        
    beq     x14, x0, incrLoop1                                                                                          
    jal     x1, swap                                                                                                    
incrLoop1:
    slli 	x4, x4, 4           #  mask0 = mask0 << 4                                                                    
    addi    x2, x2, 1           #  i = i + 1                                                                             
    bne     x2, x11, loop1      #  to check if i <> 8                                                                    

result:
    sw      x15, 4(x0)        	#  [0x04] = sortedstuno                                                                  
########################  
#排序完成，准备显示
########################       
    addi    x2, x0, 0xff
    slli    x2, x2, 8
    addi    x2, x2, 0xff
    slli    x2, x2, 16          #  x2 = 0xffff0000                                                                     
    ori     x1, x2, 0x0004 	    #  x1 = 0xffff0004 # switch as input                                                    
    ori     x2, x2, 0x000c      #  x2 = 0xffff000c # seg7 as output                                                     

display:
    lw      x5, 0(x1)  																									 
    andi    x5, x5, 0x100       #  test if bit 8 is 1                                                                    
    beq     x5, x0, dispstuno   #  if bit 8 = 0, display the original stu no. if bit 8 = 1, display the sorted stu no. 	 
dispsortedstuno:
    lw      x3, 4(x0) 			#  load the sorted student no.                                                           
    jal     x0, displayseg7label                                                                                         
dispstuno:
    lw      x3, 0(x0) 			#  load the orginal student no.                                                          
displayseg7label: 
    sw      x3,  0(x2) 			#  output to seg7                                                                       
    jal     x0, display                                                                                                  
############
#上述为：显示死循环
############
#swap函数
############  
swap: 							#  change the nibble at i with the nibble at bestj
    addi    x5, x0, 0x0f                                                                                                
    slli 	x10, x12, 2         #  4 * bestj                                                                           
    sll 	x5, x5, x10         #  mask1 = mask (4 * bestj)                                                              
    or      x6, x4, x5          #  mask2 = mask0 | mask1                                                               
    xori    x6, x6, -1          #  mask2 = ~mask2                                                                       
    and     x15, x15, x6 		#  sortedstuno = sortedstuno & mask2                                                    
    sll 	x8, x13, x9         #  tmpmax = tmpmax << (4*i)                                                             
    or      x15, x15, x8 		#  sortedstuno = sortedstuno | tmpmax                                                   
    sll 	x7, x7, x10         #  a = a << (4 * bestj)                                                              
    or      x15, x15, x7 		#  sortedstuno = sortedstuno | a                                                      
    jalr    x0, x1, 0  
