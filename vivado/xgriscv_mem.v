`include "xgriscv_defines.v"

module dmem(input                     clk, we,
            input  [3:0]              amp, 
            input  [`XLEN-1:0]        a, wd,
            output [`XLEN-1:0]        rd);

  reg  [31:0] RAM[127:0];

  assign rd = RAM[a[6:0]]; // word aligned

  always @(posedge clk)
    if (we)
      begin
        case (amp)
        4'b1111: RAM[a[6:0]] <= wd;          	  // sw
        4'b0011: RAM[a[6:0]][15:0] <= wd[15:0];  // sh
        4'b1100: RAM[a[6:0]][31:16] <= wd[15:0]; // sh
        4'b0001: RAM[a[6:0]][7:0] <= wd[7:0];    // sb
    	 	4'b0010: RAM[a[6:0]][15:8] <= wd[7:0];   // sb
        4'b0100: RAM[a[6:0]][23:16] <= wd[7:0];  // sb
       	4'b1000: RAM[a[6:0]][31:24] <= wd[7:0];  // sb
       	default: RAM[a[6:0]] <= wd;
  	   endcase
        // DO NOT CHANGE THIS display LINE!!!
        // 不要修改下面这行display语句！！�?
        // 对于�?有的store指令，都输出位于写入目标地址四字节对齐处�?32位数据，不需要修改下面的display语句
        /**********************************************************************/
        // $display("pc = %h: dataaddr = %h, memdata = %h", pc, {a[31:2],2'b00}, RAM[a[11:2]]);
        /**********************************************************************/
  	  end
endmodule