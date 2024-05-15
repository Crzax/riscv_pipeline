`include "xgriscv_defines.v"

// pc 
module pcenr (
	input             		clk, reset,
	input             		en,
	input      [`XLEN-1:0]	d, 
	output reg [`XLEN-1:0]	q);
 
	always @(posedge clk, posedge reset)
    if (reset) 
    	q <= `ADDR_SIZE'h00000000 ;
    else if (en)    
    	q <=  d;
endmodule

// addr_adder
module addr_adder (
	input  [`ADDR_SIZE-1:0] a, b,
	output [`ADDR_SIZE-1:0] y);

	assign  y = a + b;
endmodule


// 流水线寄存器
module floprc #(parameter WIDTH = 8)
              (input                  clk, reset, clear,
               input      [WIDTH-1:0] d, 
               output reg [WIDTH-1:0] q);

  always @(posedge clk, posedge reset)
    if (reset)      q <= 0;
    else if (clear) q <= 0;
    else            q <= d;
endmodule

module flopenrc #(parameter WIDTH = 8)
                 (input                  clk, reset,
                  input                  en, clear,
                  input      [WIDTH-1:0] d, 
                  output reg [WIDTH-1:0] q);
 
  always @(posedge clk, posedge reset)
    if      (reset) q <= 0;
    else if (clear) q <= 0;
    else if (en)    q <= d;
endmodule

module flopenr #(parameter WIDTH = 8)
                (input                  clk, reset,
                 input                  en,
                 input      [WIDTH-1:0] d, 
                 output reg [WIDTH-1:0] q);
 
  always @(posedge clk, posedge reset)
    if      (reset) q <= 0;
    else if (en)    q <=  d;
endmodule

module mux2 #(parameter WIDTH = 8)
             (input  [WIDTH-1:0] d0, d1, 
              input              s, 
              output [WIDTH-1:0] y);

  assign y = s ? d1 : d0; 
endmodule

module mux3 #(parameter WIDTH = 8)
             (input  [WIDTH-1:0] d0, d1, d2,
              input  [1:0]       s, 
              output [WIDTH-1:0] y);

  assign  y = s[1] ? d2 : (s[0] ? d1 : d0); 
endmodule

module mux4 #(parameter WIDTH = 8)
             (input  [WIDTH-1:0] d0, d1, d2, d3,
              input  [1:0]       s, 
              output reg [WIDTH-1:0] y);

	always @( * )
	begin
      case(s)
         2'b00: y <= d0;
         2'b01: y <= d1;
         2'b10: y <= d2;
         2'b11: y <= d3;
      endcase
	end
endmodule

module mux5 #(parameter WIDTH = 8)
             (input		[WIDTH-1:0] d0, d1, d2, d3, d4,
              input		[2:0]       s, 
              output reg	[WIDTH-1:0] y);

	always @( * )
	begin
      case(s)
	    3'b000: y <= d0;
	    3'b001: y <= d1;
	    3'b010: y <= d2;
	    3'b011: y <= d3;
	    3'b100: y <= d4;
      endcase
    end  
endmodule

module mux6 #(parameter WIDTH = 8)
           (input  [WIDTH-1:0] 	d0, d1, d2, d3, d4, d5,
            input  [2:0] 		s,
         	  output reg [WIDTH-1:0]	y);

	always@( * )
	begin
	  case(s)
		3'b000: y <= d0;
		3'b001: y <= d1;
		3'b010: y <= d2;
		3'b011: y <= d3;
		3'b100: y <= d4;
		3'b101: y <= d5;
	  endcase
	end
endmodule

module imm (
	input	[11:0]			iimm, //instr[31:20], 12 bits
	input	[11:0]			simm, //instr[31:25, 11:7], 12 bits
	input	[11:0]			bimm, //instrD[31], instrD[7], instrD[30:25], instrD[11:8], 12 bits
	input	[19:0]			uimm,
	input	[19:0]			jimm,
	input	[4:0]			  immctrl,

	output	reg [`XLEN-1:0] 	immout);
  always  @(*)
	 case (immctrl)
		`IMM_CTRL_ITYPE:	immout <= {{{`XLEN-12}{iimm[11]}}, iimm[11:0]};
		`IMM_CTRL_STYPE:	immout <= {{{`XLEN-12}{simm[11]}}, simm[11:0]};
		`IMM_CTRL_BTYPE:  immout <= {{{`XLEN-12}{bimm[11]}}, bimm[11:0]};
		`IMM_CTRL_UTYPE:	immout <= {uimm[19:0], 12'b0}; 
		`IMM_CTRL_JTYPE:	immout <= {{{`XLEN-20}{jimm[19]}}, jimm[19:0]};
		default:			    immout <= `XLEN'b0;
	 endcase
endmodule

module sl1(
	input  [`ADDR_SIZE-1:0] a,
	output [`ADDR_SIZE-1:0] y);

  assign  y = {a[`ADDR_SIZE-2:0], 1'b0};
endmodule

module set_last_zero(
	input  [`ADDR_SIZE-1:0] a,
	output [`ADDR_SIZE-1:0] y);

  assign  y = {a[`ADDR_SIZE-1:1], 1'b0};
endmodule

module cmp(
  input [`XLEN-1:0] a, b,
  input             op_unsigned,
  output            zero,
  output            lt);

  assign zero = (a == b);
  assign lt = (~op_unsigned & ($signed(a) < $signed(b))) | (op_unsigned & (a < b));
endmodule

module ampattern (input [1:0] addr, input [1:0] swhb, output reg [3:0] amp);
  always@(*)
  case (swhb)
    2'b01: amp <= 4'b1111;
    2'b10: if (addr[1]) amp <= 4'b1100;
           else         amp <= 4'b0011; 
    2'b11: case (addr)
              2'b00: amp <= 4'b0001;
              2'b01: amp <= 4'b0010;
              2'b10: amp <= 4'b0100;
              2'b11: amp <= 4'b1000;
           endcase
    default: amp <= 4'b1111;
  endcase
endmodule