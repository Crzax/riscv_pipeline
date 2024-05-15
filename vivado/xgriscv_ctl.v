`include "xgriscv_defines.v"

module ctrl_480(
    input                     clk, reset,
    input [6:0] Op,  //Op
    
    input [2:0] funct3,    // funct3 
    input [6:0] funct7,  //funct7 
    input [`RFIDX_WIDTH-1:0]  rd, rs1,
    input [11:0] imm,
    input Zero,lt,
    
    output [4:0]              immctrl,
    output                    itype, jal, jalr, bunsigned, pcsrc, 
    output reg  [3:0]         aluctrl,            // EX 
    output [1:0]              alusrca,
    output                    alusrcb,
    output                    memwrite, lunsigned,//MEM 
    output [1:0]              lwhb, swhb,

    output                    memtoreg, regwrite  //WB
);
    
  wire lui		= (Op == `OP_LUI);
  wire auipc	= (Op == `OP_AUIPC);
  wire _jal		= (Op == `OP_JAL);
  wire _jalr	= (Op == `OP_JALR);
  wire branch= (Op == `OP_BRANCH);
  wire load	= (Op == `OP_LOAD); 
  wire store	= (Op == `OP_STORE);
  wire addri	= (Op == `OP_ADDI);
  wire addrr = (Op == `OP_ADD);

  wire beq		= ((Op == `OP_BRANCH) & (funct3 == `FUNCT3_BEQ));
  wire bne		= ((Op == `OP_BRANCH) & (funct3 == `FUNCT3_BNE));
  wire blt		= ((Op == `OP_BRANCH) & (funct3 == `FUNCT3_BLT));
  wire bge		= ((Op == `OP_BRANCH) & (funct3 == `FUNCT3_BGE));
  wire bltu	= ((Op == `OP_BRANCH) & (funct3 == `FUNCT3_BLTU));
  wire bgeu	= ((Op == `OP_BRANCH) & (funct3 == `FUNCT3_BGEU));

  wire lb		= ((Op == `OP_LOAD) & (funct3 == `FUNCT3_LB));
  wire lh		= ((Op == `OP_LOAD) & (funct3 == `FUNCT3_LH));
  wire lw		= ((Op == `OP_LOAD) & (funct3 == `FUNCT3_LW));
  wire lbu		= ((Op == `OP_LOAD) & (funct3 == `FUNCT3_LBU));
  wire lhu		= ((Op == `OP_LOAD) & (funct3 == `FUNCT3_LHU));

  wire sb		= ((Op == `OP_STORE) & (funct3 == `FUNCT3_SB));
  wire sh		= ((Op == `OP_STORE) & (funct3 == `FUNCT3_SH));
  wire sw		= ((Op == `OP_STORE) & (funct3 == `FUNCT3_SW));

  wire addi	= ((Op == `OP_ADDI) & (funct3 == `FUNCT3_ADDI));
  wire slti	= ((Op == `OP_ADDI) & (funct3 == `FUNCT3_SLTI));
  wire sltiu	= ((Op == `OP_ADDI) & (funct3 == `FUNCT3_SLTIU));
  wire xori	= ((Op == `OP_ADDI) & (funct3 == `FUNCT3_XORI));
  wire ori	= ((Op == `OP_ADDI) & (funct3 == `FUNCT3_ORI));
  wire andi	= ((Op == `OP_ADDI) & (funct3 == `FUNCT3_ANDI));
  wire slli	= ((Op == `OP_ADDI) & (funct3 == `FUNCT3_SL) & (funct7 == `FUNCT7_SLLI));
  wire srli	= ((Op == `OP_ADDI) & (funct3 == `FUNCT3_SR) & (funct7 == `FUNCT7_SRLI));
  wire srai	= ((Op == `OP_ADDI) & (funct3 == `FUNCT3_SR) & (funct7 == `FUNCT7_SRAI));

  wire add		= ((Op == `OP_ADD) & (funct3 == `FUNCT3_ADD) & (funct7 == `FUNCT7_ADD));
  wire sub		= ((Op == `OP_ADD) & (funct3 == `FUNCT3_ADD) & (funct7 == `FUNCT7_SUB));
  wire sll		= ((Op == `OP_ADD) & (funct3 == `FUNCT3_SLL));
  wire slt		= ((Op == `OP_ADD) & (funct3 == `FUNCT3_SLT));
  wire sltu	= ((Op == `OP_ADD) & (funct3 == `FUNCT3_SLTU));
  wire _xor		= ((Op == `OP_ADD) & (funct3 == `FUNCT3_XOR));
  wire srl		= ((Op == `OP_ADD) & (funct3 == `FUNCT3_SR) & (funct7 == `FUNCT7_SRL));
  wire sra		= ((Op == `OP_ADD) & (funct3 == `FUNCT3_SR) & (funct7 == `FUNCT7_SRA));
  wire _or		= ((Op == `OP_ADD) & (funct3 == `FUNCT3_OR));
  wire _and		= ((Op == `OP_ADD) & (funct3 == `FUNCT3_AND));

  wire rs1_x0= (rs1 == 5'b00000);
  wire rd_x0 = (rd  == 5'b00000);
  wire nop		= addi & rs1_x0 & rd_x0 & (imm == 12'b0); //add x0,x0,0

  // I-type
  assign itype = addri | load | _jalr;

  // S-type
  wire stype = store;

  // B-type 
  wire btype = branch;

  // U-type 
  wire utype = lui | auipc;

  // J-type 
  wire jtype = _jal;

  assign immctrl = {itype, stype, btype, utype, jtype};

  assign jal = _jal | _jalr;
  
  assign jalr = _jalr;

  assign bunsigned = bltu | bgeu; 

   assign pcsrc = _jal | _jalr | (beq & Zero) | (bge & (! lt)) | (bgeu & (! lt)) | (blt & lt) | (bltu & lt) | (bne & (! Zero));

  assign alusrca = lui ? 2'b01 : (auipc ? 2'b10 : 2'b00);

  assign alusrcb = lui | auipc | addri | store | load;

  assign memwrite = store;

  assign swhb = ({2{sw}}&2'b01) | ({2{sh}}&2'b10) | ({2{sb}}&2'b11);

  assign lwhb = ({2{lw}}&2'b00) | ({2{lh | lhu}}&2'b01) | ({2{lb | lbu}}&2'b10);

  assign lunsigned = lhu | lbu; 

  assign memtoreg = load; 

  assign regwrite = lui | auipc | addri | load | addrr | _jal | _jalr;

  always @(*)
    case(Op)
      `OP_LUI: 	  aluctrl <= `ALU_CTRL_ADD;
      `OP_AUIPC:	 aluctrl <= `ALU_CTRL_ADD;

      `OP_ADDI:	  case(funct3)
						        `FUNCT3_ADDI:	aluctrl <= `ALU_CTRL_ADD;
						        `FUNCT3_SLTI:	aluctrl <= `ALU_CTRL_SLT;
						        `FUNCT3_SLTIU:aluctrl <= `ALU_CTRL_SLTU;
						        `FUNCT3_XORI:	aluctrl <= `ALU_CTRL_XOR;
    	                        `FUNCT3_ORI:	aluctrl <= `ALU_CTRL_OR;
          	                    `FUNCT3_ANDI:	aluctrl <= `ALU_CTRL_AND;
        						`FUNCT3_SLL: aluctrl <= `ALU_CTRL_SLL;
                                `FUNCT3_SR:   case (funct7)
              											    `FUNCT7_SRLI:	aluctrl <= `ALU_CTRL_SRL;
              											 	`FUNCT7_SRAI:	aluctrl <= `ALU_CTRL_SRA;
              											    default:		aluctrl <= `ALU_CTRL_ZERO;
              										        endcase
						        default:		aluctrl <= `ALU_CTRL_ZERO;	
                  endcase

      `OP_STORE: case (funct3)
        `FUNCT3_SB: aluctrl <= `ALU_CTRL_ADD;
        `FUNCT3_SH: aluctrl <= `ALU_CTRL_ADD;
        `FUNCT3_SW: aluctrl <= `ALU_CTRL_ADD;
        default: aluctrl <= `ALU_CTRL_ZERO;
      endcase
      default:  aluctrl <= `ALU_CTRL_ZERO;

      `OP_LOAD: case (funct3)
        `FUNCT3_LB: aluctrl <= `ALU_CTRL_ADD;
        `FUNCT3_LH: aluctrl <= `ALU_CTRL_ADD;
        `FUNCT3_LW: aluctrl <= `ALU_CTRL_ADD;
        `FUNCT3_LBU: aluctrl <= `ALU_CTRL_ADDU;
        `FUNCT3_LWU: aluctrl <= `ALU_CTRL_ADDU;
        `FUNCT3_LHU: aluctrl <= `ALU_CTRL_ADDU;
        default: aluctrl <= `ALU_CTRL_ZERO;
      endcase

      `OP_ADD: case (funct3)

        `FUNCT3_ADD: case (funct7)
          `FUNCT7_ADD: aluctrl <= `ALU_CTRL_ADD;
          `FUNCT7_SUB: aluctrl <= `ALU_CTRL_SUB;
          default: aluctrl <= `ALU_CTRL_ZERO;
        endcase

        `FUNCT3_XOR: aluctrl <= `ALU_CTRL_XOR;
        `FUNCT3_OR: aluctrl <= `ALU_CTRL_OR;
        `FUNCT3_AND: aluctrl <= `ALU_CTRL_AND;

        `FUNCT3_SR: case (funct7)
          `FUNCT7_SRL: aluctrl <= `ALU_CTRL_SRL;
          `FUNCT7_SRA: aluctrl <= `ALU_CTRL_SRA;
          default: aluctrl <= `ALU_CTRL_ZERO;
        endcase

        `FUNCT3_SLL: aluctrl <= `ALU_CTRL_SLL;
        `FUNCT3_SLT: aluctrl <= `ALU_CTRL_SLT;
        `FUNCT3_SLTU: aluctrl <= `ALU_CTRL_SLTU;

        default: aluctrl <= `ALU_CTRL_ZERO;
      endcase
	 endcase

endmodule