`include "defines.v"
module ctrl(
    input wire rst,
    input wire lock_from_cpu,
    input wire lock_from_IF,
    input wire lock_from_MEM,
    
    output reg[4:0] lock
    //pc_reg 0
    //IF_ID 1 ID_EX 2 EX_MEM 3 MEM_WB 4
);
   always @(*)
   begin
     if (rst == `RstEnable)
     begin
       lock <= 5'b00000;     
     end
     else if ((lock_from_MEM == 1 && lock_from_IF == 1) || (lock_from_cpu == 0))
     begin
       lock <= 5'b11111;
     end
     else if (lock_from_MEM == 1)
     begin
       lock <= 5'b11111;
     end 
     else if (lock_from_IF == 1)
     begin
       lock <= 5'b00001;
     end
     else
     begin
       lock <= 5'b00000;
     end  
   end
endmodule