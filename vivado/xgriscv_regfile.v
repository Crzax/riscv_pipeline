`include "xgriscv_defines.v"

module regfile(
  input                      	clk,
  input  [`RFIDX_WIDTH-1:0]  	ra1, ra2,
  output [`XLEN-1:0]          rd1, rd2,

  input [4:0] reg_sel,
  output[31:0] reg_data,
  input                      	we3, 
  input  [`RFIDX_WIDTH-1:0]  	wa3,
  input  [`XLEN-1:0]          wd3,
  input [31:0] pc
  );

  reg [`XLEN-1:0] rf[`RFREG_NUM-1:0];

  // three ported register file
  // read two ports combinationally
  // write third port on falling edge of clock
  // register 0 hardwired to 0

  always @(negedge clk)
    if (we3&&(wa3!=0))
      begin
        rf[wa3] <= wd3;
        // DO NOT CHANGE THIS display LINE!!!
        // 不要修改下面这行display语句！！�?
        /**********************************************************************/
        //$display("pc = %h: x%d = %h", pc, wa3, wd3);
        /**********************************************************************/
      end

  assign rd1 = (ra1 != 0) ? rf[ra1] : 0;
  assign rd2 = (ra2 != 0) ? rf[ra2] : 0;
  assign reg_data = (reg_sel != 0) ? rf[reg_sel] : 0;

endmodule
