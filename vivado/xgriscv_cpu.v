`include "xgriscv_defines.v"
module xgriscv_cpu_480(
    input      clk,           
    input      reset,         
    input [31:0]  instrF,    
	output [31:0] pcF,
    input [31:0]  readdataM,     
   	output[`XLEN-1:0] 		aluoutM,
	output[`XLEN-1:0]		writedataM,
    output    memwriteM,          
    output[3:0]  	ampM,

    //ctl
    input [4:0]				immctrlD,
	  input					itype, jalD, jalrD, bunsignedD, pcsrcD,
	  input [3:0]				aluctrlD,
	  input [1:0]				alusrcaD,
	  input					alusrcbD,
	  input					memwriteD, lunsignedD,
	  input [1:0]				lwhbD, swhbD,  
	  input          			memtoregD, regwriteD,

    output [6:0]			opD,
	  output [2:0]			Funct3,
	  output [6:0]			Funct7,
	  output [4:0] 			rdD, rs1D,
	  output [11:0]  			immD,
  	output 	       			zeroD, ltD,
	output [31:0]pcWW,
		input [4:0] reg_sel,
	output [31:0] reg_data
);
 //=============IF/ID阶段===============================
  //IF decode
  wire [6:0] opF = instrF[6:0]; //opcode
  wire [4:0]rdF;
   assign rdF = instrF[11:7];  // rd
   wire [4:0]rs1F;
   assign rs1F = instrF[19:15];  // rs1
   wire [4:0]rs2F ;
   assign rs2F = instrF[24:20];  // rs2
   wire [6:0] funct7F = instrF[31:25];   //funcnt7
   	wire [3:0] funct3F = instrF[14:12];
   //funct3
  	wire [11:0]immF;      
   assign immF = instrF[31:20]; //i型指令的立即数解析方式生成的立即�?

  //决定下一个跳�?
  //next_pc
  	wire [`ADDR_SIZE-1:0]	 pcplus4F, nextpcF, pcbranchD, pcadder2aD, pcadder2bD, pcbranch0D, pcadder2bD1;
	mux2 #(`ADDR_SIZE)	pcsrcmux(pcplus4F, pcbranchD, pcsrcD, nextpcF);
  	//IF
  	pcenr pcreg(clk, reset,en, nextpcF, pcF); //pc
	wire hazard;
	assign en = !hazard;
	addr_adder  pcadder1 (pcF, `ADDR_SIZE'b100, pcplus4F);

  //=========================ID/EX阶段=================================================
  wire [`INSTR_SIZE-1:0]	instrD; 
	wire [`ADDR_SIZE-1:0]	pcD, pcplus4D,nowPCD;
	wire flushD = pcsrcD | hazard;//控制冒险
   
  floprc #(`INSTR_SIZE) 	pr1D(clk, reset, flushD, instrF, instrD); // instruction
	floprc #(`ADDR_SIZE)	pr2D(clk, reset, flushD, pcF, pcD); // pc now
	floprc #(`ADDR_SIZE)	pr3D(clk, reset, flushD, pcplus4F, pcplus4D); // pc+4, maybe used to choose
  //ID-decode
	wire [`RFIDX_WIDTH-1:0] rs2D;
	assign  opD 	= instrD[6:0];
	assign  rdD     = instrD[11:7];
	assign  Funct3 = instrD[14:12];
	assign  rs1D    = instrD[19:15];
	assign  rs2D   	= instrD[24:20];
	assign  Funct7 = instrD[31:25];
	assign  immD    = instrD[31:20];

   wire [11:0]simmD;
   assign simmD = {instrD[31:25],instrD[11:7]};   //s型指令立即数解析方式生成的立即数
   wire [19:0] jimmD;
   assign jimmD = {instrD[31],instrD[19:12],instrD[20],instrD[30:21]};  //UJ型指令立即数
   wire [11:0] bimmD;
   assign bimmD = {instrD[31],instrD[7],instrD[30:25],instrD[11:8]};    //SB型指令立即数
   wire [19:0] uimmD;
   assign uimmD = instrD[31:12]; //U型指令立即数 
	wire [11:0]	iimmD 	= instrD[31:20];

  wire [`XLEN-1:0]	immoutD, shftimmD;
	wire [`XLEN:0] immoutD_sl1;
	wire [`XLEN-1:0]	rdata1D, rdata2D, wdataW, wdataW1, rdata1D1, rdata2D1;
	wire [`RFIDX_WIDTH-1:0]	waddrW;

  //立即数�?�择
	imm 	im(iimmD, simmD, bimmD, uimmD, jimmD, immctrlD, immoutD);
 //立即数生�?
  sl1 immGen(immoutD, immoutD_sl1); 
	addr_adder pcadder2(pcD, immoutD_sl1, pcadder2aD); //jal

  //rf
  wire [`XLEN-1:0] pcW;
	regfile rf(clk, rs1D, rs2D, rdata1D, rdata2D, reg_sel, reg_data, regwriteW, waddrW, wdataW,pcW);
	assign pcWW = pcW;
  // shift amount
	wire [4:0]	shamt0D = instrD[24:20];
	wire [4:0] shamtD;
	mux2 #(5) shamtmux(rdata2D[4:0], shamt0D, itype, shamtD); 
   //===============================================

//========Mem->ID=================== 
//决定参与Ex计算的是�?
  wire regwriteM;
	wire [`RFIDX_WIDTH-1:0]	rdM;
	wire forwardaD = (regwriteM && rdM != 5'b0 && rdM == rs1D);
	wire forwardbD = (regwriteM && rdM != 5'b0 && rdM == rs2D);
	mux2 #(`XLEN)  rdata1Dmux(rdata1D, aluoutM, forwardaD, rdata1D1);
	mux2 #(`XLEN)  rdata2Dmux(rdata2D, aluoutM, forwardbD, rdata2D1);

	addr_adder pcadder3(rdata1D1, immoutD, pcadder2bD1); //jalr_1
	set_last_zero set_zero(pcadder2bD1, pcadder2bD); //jalr_2

	mux2 #(`XLEN) pcsrcmux2(pcadder2aD, pcadder2bD, jalrD, pcbranchD);
	

	cmp cmp(rdata1D1, rdata2D1, bunsignedD, zeroD, ltD);
 //========================================

//======================================================
//================冒险�?�?===============
	wire memtoregE;
	wire [`RFIDX_WIDTH-1:0] rdE;

	assign hazard = (memtoregD & rdD != 5'b0 & (
		(opF == `OP_JALR) & (rdD == rs1F) |
		(opF == `OP_LOAD) & (rdD == rs1F) |
		(opF == `OP_ADDI) & (rdD == rs1F) |
		(opF == `OP_ADD) & ((rdD == rs1F) | (rdD == rs2F)) |
		(opF == `OP_BRANCH) & ((rdD == rs1F) | (rdD == rs2F))) 
	)|
	(regwriteD & rdD != 5'b0 & (
		(opF == `OP_JALR) & (rdD == rs1F) |
		(opF == `OP_BRANCH) & ((rdD == rs1F) | (rdD == rs2F))
	) )|
	(memtoregE & rdE != 5'b0 & (
		(opF == `OP_JALR) & (rdE == rs1F) |
		(opF == `OP_BRANCH) & ((rdE == rs1F) | (rdE == rs2F))
	) );
   //==============================================================

   //================ID/EX===================
//=========================ID/EX========================
	wire regwriteE, memwriteE, lunsignedE, alusrcbE, jalE;
	wire [1:0] swhbE, lwhbE, alusrcaE;
	wire [3:0] aluctrlE;

  //flush信号
  wire 	   flushE= 0;
  //控制信号流水线寄存器
  floprc #(16) regE(clk, reset, flushE,
                  {memtoregD, regwriteD, memwriteD, swhbD, lwhbD, lunsignedD, alusrcaD, alusrcbD, aluctrlD, jalD}, 
                  {memtoregE, regwriteE, memwriteE, swhbE, lwhbE, lunsignedE, alusrcaE, alusrcbE, aluctrlE, jalE});
	wire [1:0] forwardaE, forwardbE;

  wire [`XLEN-1:0]		srca1E, srcb1E, immoutE, srca2E, srca3E, srcb2E, srcb3E, aluoutE;
	wire [`RFIDX_WIDTH-1:0] rs1E, rs2E;
	wire [4:0] 				shamtE;
	wire [`ADDR_SIZE-1:0] 	pcE, pcplus4E;
	wire [6:0] opE;
  //数据流水线寄存器
	floprc #(`XLEN) 		pr1E(clk, reset, flushE, rdata1D, srca1E); 	
	floprc #(`XLEN) 		pr2E(clk, reset, flushE, rdata2D, srcb1E); 	
	floprc #(`XLEN) 		pr3E(clk, reset, flushE, immoutD, immoutE); 
	floprc #(`RFIDX_WIDTH)	pr4E(clk, reset, flushE, rs1D, rs1E); 		
  floprc #(`RFIDX_WIDTH)  pr5E(clk, reset, flushE, rs2D, rs2E); 		
  floprc #(`RFIDX_WIDTH)  pr6E(clk, reset, flushE, rdD, rdE);			
  floprc #(5)  			pr7E(clk, reset, flushE, shamtD, shamtE);	
  floprc #(`ADDR_SIZE)	pr8E(clk, reset, flushE, pcD, pcE); 		
  floprc #(`ADDR_SIZE)	pr9E(clk, reset, flushE, pcplus4D, pcplus4E); 
	floprc #(7)			pr10E(clk, reset, flushE, opD, opE);
  //EX
  mux3 #(`XLEN)  srca1mux(srca1E, wdataW, aluoutM, forwardaE, srca2E);// srca1mux
	mux3 #(`XLEN)  srca2mux(srca2E, 0, pcE, alusrcaE, srca3E);			// srca2mux
	mux3 #(`XLEN)  srcb1mux(srcb1E, wdataW, aluoutM, forwardbE, srcb2E);// srcb1mux
	mux2 #(`XLEN)  srcb2mux(srcb2E, immoutE, alusrcbE, srcb3E);			// srcb2mux
  
  //==============ALU===================
  alu_480 alu(srca3E, srcb3E, shamtE, aluctrlE, aluoutE, overflowE, zeroE, ltE, geE, opE);

//================================================ 

//=================Mem->EX or WB->EX的forward信号=================================
  wire aM = (regwriteM && rdM != 5'b0 && rdM == rs1E);
	wire aW = (regwriteW && waddrW != 5'b0 && waddrW == rs1E && !(regwriteM && rdM != 5'b0 && rdM == rs1E));
	wire bM = (regwriteM && rdM != 5'b0 && rdM == rs2E);
	wire bW = (regwriteW && waddrW != 5'b0 && waddrW == rs2E && !(regwriteM && rdM != 5'b0 && rdM == rs2E));
	mux3 #(2) forwardaEmux(2'b00, 2'b01, 2'b10, {aM, aW}, forwardaE);
	mux3 #(2) forwardbEmux(2'b00, 2'b01, 2'b10, {bM, bW}, forwardbE);

//================EX/Mem流水线寄存器================================
//控制信号
  wire 		memtoregM, jalM, lunsignedM;
	wire [1:0] 	swhbM, lwhbM;
	wire 		flushM = 0;
	floprc #(9) regM(clk, reset, flushM,
                  {memtoregE, regwriteE, memwriteE, lunsignedE, swhbE, lwhbE, jalE},
                  {memtoregM, regwriteM, memwriteM, lunsignedM, swhbM, lwhbM, jalM});
  //数据部分
  wire [`ADDR_SIZE-1:0] 	pcplus4M,pcM;
	wire [`RFIDX_WIDTH-1:0] rs2M; 
	wire [`XLEN-1:0] writedataM1; 
	floprc #(`XLEN) 		pr1M(clk, reset, flushM, aluoutE, aluoutM);
	floprc #(`XLEN) 		pr2M(clk, reset, flushM, srcb1E, writedataM1);
	floprc #(`RFIDX_WIDTH) 	pr3M(clk, reset, flushM, rdE, rdM);
	floprc #(`ADDR_SIZE)	pr4M(clk, reset, flushM, pcplus4E, pcplus4M); 
	floprc #(`RFIDX_WIDTH)  pr5M(clk, reset, flushM, rs2E, rs2M); 
	floprc #(`ADDR_SIZE)	pr6M(clk, reset, flushM, pcE, pcM); 		

//================================================================
  //WB->Mem
  wire forwardM = ((waddrW != 0) && (rs2M == waddrW) && regwriteW);
  mux2 #(`XLEN) memOrwbmux(writedataM1, wdataW, forwardM, writedataM);
//===============================Mem===================================
ampattern   amp(aluoutM[1:0], swhbM, ampM); // for sw, sh and sb, ampM to data memory
  	
wire [`XLEN-1:0] membyteM, memhalfM, readdatabyteM, readdatahalfM, memdataM;
	
  	mux2 #(16) lhmux(readdataM[15:0], readdataM[31:16], aluoutM[1], memhalfM[15:0]); // for lh and lhu
  	wire[`XLEN-1:0] signedhalfM = {{16{memhalfM[15]}}, memhalfM[15:0]}; // for lh
  	wire[`XLEN-1:0] unsignedhalfM = {16'b0, memhalfM[15:0]}; // for lhu
  	mux2 #(32) lhumux(signedhalfM, unsignedhalfM, lunsignedM, readdatahalfM);//半字->确定无符号数还是有符号数

  	mux4 #(8) lbmux(readdataM[7:0], readdataM[15:8], readdataM[23:16], readdataM[31:24], aluoutM[1:0], membyteM[7:0]);
  	wire[`XLEN-1:0] signedbyteM = {{24{membyteM[7]}}, membyteM[7:0]}; // for lb
  	wire[`XLEN-1:0] unsignedbyteM = {24'b0, membyteM[7:0]}; // for lbu
  	mux2 #(`XLEN) lbumux(signedbyteM, unsignedbyteM, lunsignedM, readdatabyteM);//字节->有符号数/无符号数

  	mux3 #(`XLEN) lwhbmux(readdataM, readdatahalfM, readdatabyteM, lwhbM, memdataM);//�?->有符�?/无符�?

//=============================Mem/WB流水线寄存器======================================
// 控制信号
  	wire flushW = 0;
	floprc #(3) regW(clk, reset, flushW,
                  {memtoregM, regwriteM, jalM},
                  {memtoregW, regwriteW, jalW});

  	// 数据
  	wire[`XLEN-1:0]			aluoutW, memdataW, wdata0W, pcplus4W;

	floprc #(`XLEN) 		pr1W(clk, reset, flushW, aluoutM, aluoutW);
	floprc #(`XLEN) 		pr2W(clk, reset, flushW, memdataM, memdataW);
	floprc #(`RFIDX_WIDTH) 	pr3W(clk, reset, flushW, rdM, waddrW);
	floprc #(`ADDR_SIZE)	pr4W(clk, reset, flushW, pcplus4M, pcplus4W); // pc+4, for JAL(store pc+4 to rd)
	floprc #(`ADDR_SIZE)	pr5W(clk, reset, flushW, pcM, pcW); 		

//===============================WB=========================================
mux2 #(`XLEN) wbmux1(aluoutW, memdataW, memtoregW, wdataW1);
mux2 #(`XLEN) wbmux2(wdataW1, pcplus4W, jalW, wdataW);
endmodule