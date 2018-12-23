`include "defines.v"
module ex_mem (
    input wire clk,
    input wire rst,

    input wire [`RegAddrBus] ex_wd,
    input wire ex_wreg,
    input wire[`RegBus] ex_wdata,


    input wire[4:0] lock,

    output reg[`RegAddrBus] mem_wd,
    output reg              mem_wreg,
    output reg[`RegBus]     mem_wdata,

    //about LOAD and STORE
    input wire[`RamAddrBus] mem_addr_i,
    input wire[`RegBus] mem_write_data_i,
    input wire mem_rw_i,
    input wire[`AluOpBus] aluop_i,

    output reg[`RamAddrBus] mem_addr_o,
    output reg[`RegBus] mem_write_data_o,
    output reg mem_rw_o,
    output reg[`AluOpBus] aluop_o
);

    always @(posedge clk) begin
      if (rst == `RstEnable) begin
        mem_wd <= `NOPRegAddr;
        mem_wreg <= `WriteDisable;
        mem_wdata <= `ZeroWord;

        mem_addr_o <= `ZeroRamAddr;
        mem_write_data_o <= `ZeroWord;
        mem_rw_o <= 1'b0;
        aluop_o <= `EXE_NOP_OP;
      end 
      else if (lock[3] == 1'b0) 
      begin
        mem_wd <= ex_wd;
        mem_wreg <= ex_wreg;
        mem_wdata <= ex_wdata;
        mem_addr_o <= mem_addr_i;
        mem_write_data_o <= mem_write_data_i;
        mem_rw_o <= mem_rw_i;
        aluop_o <= aluop_i;
      end
    end

endmodule