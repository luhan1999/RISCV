`include "defines.v"
module pc_reg(
    input wire  clk,
    input wire  rst,

    input wire                  pc_branch_i,
    input wire[`InstAddrBus]    branch_addr_i,
    
    input wire[4:0] lock,

    output reg[`InstAddrBus] pc,
    
    output reg  pc_changed
);
/*
always @ (posedge clk) 
begin
  if (rst == `RstEnable)
    begin
      ce <= `ChipDisable;
    end 
  else 
    begin
      ce <= `ChipEnable;
    end
end*/


always @(posedge clk)
begin
  if (rst == `RstEnable) 
    begin
      pc <= 32'h00000000; 
      pc_changed <= 1'b0;
    end 
  else  
    begin
    if (pc_branch_i == 1'b1)
      begin
        pc <= branch_addr_i;
        pc_changed <= 1'b1;
      end 
    else 
      if (lock[0] == 1'b0)
      begin
        pc <= pc + 4'h4;
        pc_changed <= 1'b1;
      end 
      else
      begin
        pc_changed <= 1'b0;
      end
    end 
  end
  
  /*reg [4:0] cnt;
  reg [`InstAddrBus] next_pc;
  always @(posedge clk)
  begin
  if (rst == `RstEnable) 
    begin
      pc <= 32'h00000000; 
      cnt <= 5'b00000;
    end 
  else  
    begin
    if (cnt == 5'b10000)
      begin
        pc <= next_pc;
        pc_changed <= 1'b1;
        cnt <= 5'b00000;
      end
    else
    begin
      cnt <= cnt + 1;
      if (cnt == 1)
        begin
          next_pc <= pc + 4'h4;
        end
      if (pc_branch_i == 1'b1)
      begin
        next_pc <= branch_addr_i;
      end 
    end  
    end 
  end*/
endmodule