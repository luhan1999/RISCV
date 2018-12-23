`include "defines.v"
module if_id(
    input wire clk,
    input wire rst,

    input wire[`InstAddrBus] if_pc,
    input wire[`InstBus]     if_inst,

    input wire[4:0] lock,

    input wire IFID_clean_i,

    output reg[`InstAddrBus] id_pc,
    output reg[`InstBus]     id_inst
);

always @ (posedge clk)
begin
  if (rst == `RstEnable || IFID_clean_i == 1'b1)
  begin
    id_pc <= `ZeroWord;
    id_inst <= `ZeroWord;
  end 
  else
  if (lock[1] == 1'b0)
  begin
    id_pc <= if_pc;
    id_inst <= if_inst;
    /*id_inst[31:24] <= if_inst[7:0];
    id_inst[23:16] <= if_inst[15:8];
    id_inst[15:8]  <= if_inst[23:16];
    id_inst[7:0]   <= if_inst[31:24];*/
  end
end

endmodule