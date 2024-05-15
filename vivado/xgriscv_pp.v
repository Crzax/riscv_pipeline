`include "xgriscv_defines.v"
module xgriscv_pipeline(clk, reset, pcW);
  input             clk, reset;
  output[31:0]    pcW;
   wire [31:0]    instr; //instruction
  wire[31:0]    pc;
  wire           memwrite;
  wire [3:0]     amp;
  wire [31:0]    addr, writedata, readdata;
  imem U_imem(pc, instr); // I mem, get instruction
  dmem U_dmem(clk, memwrite, amp, addr, writedata, readdata); // D mem
  xgriscv_480 U_xgriscv(clk, reset, pc, instr, memwrite, amp, addr, writedata, readdata,pcW); //Middle part

endmodule

//pp cpu
module xgriscv_480(input         			        clk, reset,
               output [31:0] 			        pc, //new pc
               input  [`INSTR_SIZE-1:0]   instr,
               output					            memwrite, //write or not
               output [3:0]  			        amp, //access memory pattern
               output [`ADDR_SIZE-1:0] 	  daddr, 
               output [`XLEN-1:0] 		    writedata,
               input  [`XLEN-1:0] 		    readdata,
               output [`XLEN-1:0]         pcWW,
               input [4:0] reg_sel,
               output [31:0] reg_data
               );
               
  wire [6:0]  opD;
 	wire [2:0]  funct3D;
	wire [6:0]  funct7D;
  wire [4:0]  rdD, rs1D;
  wire [11:0] immD;
  wire        zeroD, ltD;
  wire [4:0]  immctrlD;
  wire        itypeD, jalD, jalrD, bunsignedD, pcsrcD;
  wire [3:0]  aluctrlD;
  wire [1:0]  alusrcaD;
  wire        alusrcbD;
  wire        memwriteD, lunsignedD;
  wire [1:0]  swhbD, lwhbD;
  wire        memtoregD, regwriteD;

ctrl_480  ctl(clk, reset, opD, funct3D, funct7D, rdD, rs1D, immD, zeroD, ltD,
              immctrlD, itypeD, jalD, jalrD, bunsignedD, pcsrcD, 
              aluctrlD, alusrcaD, alusrcbD, 
              memwriteD, lunsignedD, lwhbD, swhbD, 
              memtoregD, regwriteD);

xgriscv_cpu_480   cpu(clk, reset,
              instr, pc, //new pc
              readdata, daddr, writedata, memwrite, amp,
              immctrlD, itypeD, jalD, jalrD, bunsignedD, pcsrcD, 
              aluctrlD, alusrcaD, alusrcbD, 
              memwriteD, lunsignedD, lwhbD, swhbD, 
              memtoregD, regwriteD, 
              opD, funct3D, funct7D, rdD, rs1D, immD, zeroD, ltD,pcWW,reg_sel, reg_data);

endmodule

