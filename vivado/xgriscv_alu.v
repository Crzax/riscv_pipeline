`include "xgriscv_defines.v"

module alu_480( 
    input   [31:0] 	a, b, //不能是符号数！！  
    input [4:0]  			shamt, 
    input [3:0]   aluctrl,

    output reg [31:0] 	aluout, //不能是符号数！！
    output overflow,
	output   		Zero,
    output lt,
    output ge,
	input [6:0] opE
); 
    wire op_unsigned = ~aluctrl[3]&~aluctrl[2]&aluctrl[1]&~aluctrl[0]	//ALU_CTRL_ADDU	4'b0010
				| aluctrl[3]&~aluctrl[2]&aluctrl[1]&~aluctrl[0] 	//ALU_CTRL_SUBU	4'b1010
				| aluctrl[3]&aluctrl[2]&~aluctrl[1]&~aluctrl[0]; 	//ALU_CTRL_SLTU	4'b1100
	
    wire [`XLEN-1:0] 		b2;
	wire [`XLEN:0] 			sum;

    assign b2 = aluctrl[3] ? ~b:b; 
	assign sum = (op_unsigned & ({1'b0, a} + {1'b0, b2} + aluctrl[3]))
				| (~op_unsigned & ({a[`XLEN-1], a} + {b2[`XLEN-1], b2} + aluctrl[3]));


	always@(*)
		case(aluctrl[3:0])
		`ALU_CTRL_MOVEA: 	aluout <= a;
		`ALU_CTRL_ADD: 		aluout <= sum[`XLEN-1:0];
		`ALU_CTRL_ADDU:		aluout <= sum[`XLEN-1:0];

		`ALU_CTRL_OR:		aluout <= a | b;
		`ALU_CTRL_XOR: 		aluout <= a ^ b;
		`ALU_CTRL_AND:		aluout <= a & b;

		`ALU_CTRL_SLL: 		
			case(opE)
			`OP_ADDI:	aluout <= a << shamt;
			`OP_ADD:	aluout <= a << b;
			endcase
		`ALU_CTRL_SRL: 		
			case(opE)
			`OP_ADDI:	aluout <= a >> shamt;
			`OP_ADD:	aluout <= a >> b;
			endcase
		`ALU_CTRL_SRA: 		aluout <= {{(`XLEN-1){a[`XLEN-1]}},a} >> shamt;
		
		
		`ALU_CTRL_SUB: 		aluout <= sum[`XLEN-1:0];
		`ALU_CTRL_SUBU: 	aluout <= sum[`XLEN-1:0];
		`ALU_CTRL_SLT: 		aluout <= sum[31]^overflow;
		`ALU_CTRL_SLTU: 	aluout <= (a < b);
		
		`ALU_CTRL_LUI:		aluout <= sum[`XLEN-1:0]; 
		`ALU_CTRL_AUIPC:	aluout <= sum[`XLEN-1:0]; 

		default: 			aluout <= `XLEN'b0; 
	 endcase
	    
	assign overflow = sum[`XLEN-1] ^ sum[`XLEN];
	assign zero = (aluout == `XLEN'b0);
	assign lt = aluout[`XLEN-1];
	assign ge = ~aluout[`XLEN-1];
endmodule

