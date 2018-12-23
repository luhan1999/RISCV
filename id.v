`include "defines.v"
module id(
    input wire  rst,
    input wire[`InstAddrBus] pc_i,
    input wire[`InstBus]     inst_i,

    //read regfile
    input wire[`RegBus]     reg1_data_i,
    input wire[`RegBus]     reg2_data_i,

    //write Regfile
    output reg      reg1_read_o,
    output reg      reg2_read_o,
    output reg[`RegAddrBus] reg1_addr_o,
    output reg[`RegAddrBus] reg2_addr_o,

    //info which deliver to exe.
    output reg[`AluOpBus]   aluop_o,
    output reg[`AluSelBus]  alusel_o,
    output reg[`RegBus]     reg1_o,
    output reg[`RegBus]     reg2_o,
    output reg[`RegAddrBus] wd_o,
    output reg              wreg_o,

     //exe result
    input wire  ex_wreg_i,
    input wire[`RegBus] ex_wdata_i,
    input wire[`RegAddrBus] ex_wd_i,

    //mem result
    input wire mem_wreg_i,
    input wire[`RegBus] mem_wdata_i,
    input wire[`RegAddrBus] mem_wd_i,

    //branch
    output reg[`InstAddrBus] link_pc_o,
    output reg[31:0]         branch_offset_o
);

wire[6:0] op  = inst_i[6:0];
wire[2:0] op2 = inst_i[14:12];
wire[5:0] op3 = inst_i[31:25];

reg[`RegBus] imm;
reg instvalid;

//1
always @(*) begin 
if (rst == `RstEnable) begin
  aluop_o <= `EXE_NOP_OP;
  alusel_o <= `EXE_RES_NOP;
  wd_o <= `NOPRegAddr;
  wreg_o <= `WriteDisable;
  instvalid <= `Instvalid;
  reg1_read_o <= 1'b0;
  reg2_read_o <= 1'b0;
  reg1_addr_o <= `NOPRegAddr;
  reg2_addr_o <= `NOPRegAddr;
  imm <= 32'h0;
end else begin
  case (op)
    7'b0110111:
      //LUI  TOCHECK
      begin
        wd_o   <= inst_i[11:7];
        wreg_o <= `WriteEnable;
        aluop_o <= `EXE_ADD_OP;
        alusel_o <= `EXE_RES_LOGIC;
        reg1_read_o <= 1'b1;               
        reg2_read_o <= 1'b0;
        imm <= {inst_i[31:12],12'h0};
        instvalid <= `Instvalid;
        reg1_addr_o <= `NOPRegAddr;
        reg2_addr_o <= `NOPRegAddr;
      end
    7'b0010111:
      //AUIPC TODO  send pc to next to solve the problem?
      begin
        wd_o   <= inst_i[11:7];
        wreg_o <= `WriteEnable;
        aluop_o <= `EXE_AUIPC_OP;
        alusel_o <= `EXE_RES_JUMP;
        reg1_read_o <= 1'b0;               
        reg2_read_o <= 1'b0;
        imm <= {inst_i[31:12],12'h0};
        instvalid <= `Instvalid;
        reg1_addr_o <= `NOPRegAddr;
        reg2_addr_o <= `NOPRegAddr;
        link_pc_o <= pc_i + 4;
        branch_offset_o <= `ZeroWord;
      end
    7'b1101111:
      //JAL
      begin
        alusel_o <= `EXE_RES_JUMP; 
        aluop_o <= `EXE_JAL_OP;
        wreg_o <= `WriteEnable;
        wd_o <= inst_i[11:7];
        reg1_read_o <= 1'b0;
        reg2_read_o <= 1'b0;
        imm <= {{11{inst_i[31]}}, inst_i[31], inst_i[19:12], inst_i[20], inst_i[30:21], 1'b0};
        instvalid <= `Instvalid;
        link_pc_o <= pc_i + 4;
        branch_offset_o <= `ZeroWord;
      end
    7'b1100111:
      //JALR
      begin
        alusel_o <= `EXE_RES_JUMP;
        aluop_o <= `EXE_JALR_OP;
        wreg_o <= `WriteEnable;
        wd_o <= inst_i[11:7];
        reg1_read_o <= 1'b1;
        reg2_read_o <= 1'b0;
        reg1_addr_o <= inst_i[19:15];
        imm <= {20'd0, inst_i[31:20]};
        instvalid <= `Instvalid;
        link_pc_o <= pc_i + 4;
        branch_offset_o <= `ZeroWord;
      end
    7'b1100011:
      begin
        alusel_o <= `EXE_RES_JUMP;
        case (op2)
          `EXE_BEQ:begin
                     aluop_o <= `EXE_BEQ_OP;
                     wreg_o <= `WriteDisable;
                     reg1_read_o <= 1'b1;
                     reg2_read_o <= 1'b1;
                     reg1_addr_o <= inst_i[19:15];
                     reg2_addr_o <= inst_i[24:20];
                     branch_offset_o <= {{19{inst_i[31]}}, inst_i[31], inst_i[7], inst_i[30:25], inst_i[11:8], 1'b0};
                     imm <= `ZeroWord;
                     instvalid <= `Instvalid;
                     link_pc_o <= pc_i + 4;
                   end
          `EXE_BNE:begin
                     aluop_o <= `EXE_BNE_OP;
                     wreg_o <= `WriteDisable;
                     reg1_read_o <= 1'b1;
                     reg2_read_o <= 1'b1;
                     reg1_addr_o <= inst_i[19:15];
                     reg2_addr_o <= inst_i[24:20];
                     branch_offset_o <= {{19{inst_i[31]}}, inst_i[31], inst_i[7], inst_i[30:25], inst_i[11:8], 1'b0};
                     imm <= `ZeroWord;
                     instvalid <= `Instvalid;
                     link_pc_o <= pc_i + 4;
                   end
           `EXE_BLT:begin
                      wreg_o <= `WriteDisable;
                      aluop_o <= `EXE_BLT_OP;
                      reg1_read_o <= 1'b1;
                      reg2_read_o <= 1'b1;
                      reg1_addr_o <= inst_i[19:15];
                      reg2_addr_o <= inst_i[24:20];
                      branch_offset_o <= {{19{inst_i[31]}}, inst_i[31], inst_i[7], inst_i[30:25], inst_i[11:8], 1'b0};
                      imm <= `ZeroWord;
                      instvalid <= `Instvalid;
                      link_pc_o <= pc_i + 4;
                    end
           `EXE_BGE:begin
                      wreg_o <= `WriteDisable;
                      aluop_o <= `EXE_BGE_OP;
                      reg1_read_o <= 1'b1;
                      reg2_read_o <= 1'b1;
                      reg1_addr_o <= inst_i[19:15];
                      reg2_addr_o <= inst_i[24:20];
                      branch_offset_o <= {{19{inst_i[31]}}, inst_i[31], inst_i[7], inst_i[30:25], inst_i[11:8], 1'b0};
                      imm <= `ZeroWord;
                      instvalid <= `Instvalid;
                      link_pc_o <= pc_i + 4;
                    end
            `EXE_BLTU:begin
                        wreg_o <= `WriteDisable;
                        aluop_o <= `EXE_BLTU_OP;
                        reg1_read_o <= 1'b1;
                        reg2_read_o <= 1'b1;
                        reg1_addr_o <= inst_i[19:15];
                        reg2_addr_o <= inst_i[24:20];
                        branch_offset_o <= {{19{inst_i[31]}}, inst_i[31], inst_i[7], inst_i[30:25], inst_i[11:8], 1'b0};
                        imm <= `ZeroWord;
                        instvalid <= `Instvalid;
                        link_pc_o <= pc_i + 4;
                      end
            `EXE_BGEU:begin
                        wreg_o <= `WriteDisable;
                        aluop_o <= `EXE_BGEU_OP;
                        reg1_read_o <= 1'b1;
                        reg2_read_o <= 1'b1;
                        reg1_addr_o <= inst_i[19:15];
                        reg2_addr_o <= inst_i[24:20];
                        branch_offset_o <= {{19{inst_i[31]}}, inst_i[31], inst_i[7], inst_i[30:25], inst_i[11:8], 1'b0};
                        imm <= `ZeroWord;
                        instvalid <= `Instvalid;
                        link_pc_o <= pc_i + 4;
                    end
        endcase
      end
    7'b0000011:
      begin
        wd_o        <= inst_i[11:7];
        reg1_addr_o <= inst_i[19:15];
        case (op2)
          `EXE_LB:begin
                    aluop_o <= `EXE_LB_OP;
                    alusel_o <= `EXE_RES_LOAD;
                    wreg_o <= `WriteEnable;
                    reg1_read_o <= 1'b1;
                    reg2_read_o <= 1'b0;
                    imm <= {{20{inst_i[31]}},inst_i[31:20]};
                    instvalid <= `Instvalid;
                  end
          `EXE_LH:begin
                    aluop_o <= `EXE_LH_OP;
                    alusel_o <= `EXE_RES_LOAD;
                    wreg_o <= `WriteEnable;
                    reg1_read_o <= 1'b1;
                    reg2_read_o <= 1'b0;
                    imm <= {{20{inst_i[31]}},inst_i[31:20]};
                    instvalid <= `Instvalid;
                  end
          `EXE_LW:begin
                    aluop_o <= `EXE_LW_OP;
                    alusel_o <= `EXE_RES_LOAD;
                    wreg_o <= `WriteEnable;
                    reg1_read_o <= 1'b1;
                    reg2_read_o <= 1'b0;
                    imm <= {{20{inst_i[31]}},inst_i[31:20]};
                    instvalid <= `Instvalid;
                  end
          `EXE_LBU:begin
                     aluop_o <= `EXE_LBU_OP;
                     alusel_o <= `EXE_RES_LOAD;
                     wreg_o <= `WriteEnable;
                     reg1_read_o <= 1'b1;
                     reg2_read_o <= 1'b0;
                     imm <= {{20{inst_i[31]}},inst_i[31:20]};
                     instvalid <= `Instvalid;
                   end
          `EXE_LHU:begin
                     aluop_o <= `EXE_LHU_OP;
                     alusel_o <= `EXE_RES_LOAD;
                     wreg_o <= `WriteEnable;
                     reg1_read_o <= 1'b1;
                     reg2_read_o <= 1'b0;
                     imm <= {{20{inst_i[31]}},inst_i[31:20]};
                     instvalid <= `Instvalid;
                   end
        endcase
      end
    7'b0100011:
      begin
        reg1_addr_o <= inst_i[19:15];
        reg2_addr_o <= inst_i[24:20];
        case (op2)
          `EXE_SB:begin
                    aluop_o <= `EXE_SB_OP;
                    alusel_o <= `EXE_RES_STORE;
                    wreg_o <= `WriteDisable;
                    reg1_read_o <= 1'b1;
                    reg2_read_o <= 1'b1;
                    imm <= `ZeroWord;
                    instvalid <= `Instvalid;
                    link_pc_o <= `ZeroWord;
                    branch_offset_o <= {{20{inst_i[31]}},inst_i[31:25],inst_i[11:7]};
                  end
          `EXE_SH:begin
                    aluop_o <= `EXE_SH_OP;
                    alusel_o <= `EXE_RES_STORE;
                    wreg_o <= `WriteDisable;
                    reg1_read_o <= 1'b1;
                    reg2_read_o <= 1'b1;
                    imm <= `ZeroWord;
                    instvalid <= `Instvalid;
                    link_pc_o <= `ZeroWord;
                    branch_offset_o <= {{20{inst_i[31]}},inst_i[31:25],inst_i[11:7]};
                  end
          `EXE_SW:begin
                    aluop_o <= `EXE_SW_OP;
                    alusel_o <= `EXE_RES_STORE;
                    wreg_o <= `WriteDisable;
                    reg1_read_o <= 1'b1;
                    reg2_read_o <= 1'b1;
                    imm <= `ZeroWord;
                    instvalid <= `Instvalid;
                    link_pc_o <= `ZeroWord;
                    branch_offset_o <= {{20{inst_i[31]}},inst_i[31:25],inst_i[11:7]};
                  end
        endcase            
      end
    7'b0010011:
      begin
        wd_o <= inst_i[11:7];
        wreg_o <= `WriteEnable;
        reg1_read_o <= 1'b1;
        reg2_read_o <= 1'b0;
        reg1_addr_o <= inst_i[19:15];
        reg2_addr_o <= `NOPRegAddr;
        instvalid <=  `Instvalid;
        case (op2)
          `EXE_ADDI:begin
                      aluop_o <= `EXE_ADD_OP;
                      alusel_o <= `EXE_RES_LOGIC;
                      imm <= {{20{inst_i[31]}},inst_i[31:20]};
                    end
          `EXE_SLTI:begin
                      aluop_o <= `EXE_SLT_OP;
                      alusel_o <= `EXE_RES_COMPARE;
                      imm <= {{20{inst_i[31]}},inst_i[31:20]};
                    end
          `EXE_SLTIU:begin
                      aluop_o <= `EXE_SLTU_OP;
                      alusel_o <= `EXE_RES_COMPARE;
                      imm <= {{20{inst_i[31]}},inst_i[31:20]};
                    end
          `EXE_XORI: begin  
                      aluop_o <= `EXE_XOR_OP;
                      alusel_o <= `EXE_RES_LOGIC;
                      imm     <= {20'h0, inst_i[31:20]};
                    end
          `EXE_ORI: begin  
                      aluop_o <= `EXE_OR_OP;
                      alusel_o <= `EXE_RES_LOGIC;
                      imm     <= {20'h0, inst_i[31:20]};
                    end
          `EXE_ANDI:begin  
                      aluop_o <= `EXE_AND_OP;
                      alusel_o <= `EXE_RES_LOGIC;
                      imm     <= {20'h0, inst_i[31:20]};
                    end
          `EXE_SLLI:begin
                      aluop_o <=`EXE_SLL_OP;
                      alusel_o <= `EXE_RES_SHIFT;
                      imm     <= {27'h0, inst_i[24:20]};
                    end
          `EXE_SR:  begin
                      if (inst_i[30] == 1'b0)
                      //SRLI
                      begin
                        aluop_o <=`EXE_SRL_OP;
                        alusel_o <= `EXE_RES_SHIFT;
                        imm <= {27'h0,inst_i[24:20]};
                      end 
                      else
                      //SRAI
                      begin
                        aluop_o <=`EXE_SRA_OP;
                        alusel_o <= `EXE_RES_SHIFT;
                        imm <= {27'h0,inst_i[24:20]};
                      end
                    end
        endcase
      end
    7'b0110011:
      begin
        wd_o <= inst_i[11:7];
        wreg_o <= `WriteEnable;
        reg1_read_o <= 1'b1;
        reg2_read_o <= 1'b1;
        reg1_addr_o <= inst_i[19:15];
        reg2_addr_o <= inst_i[24:20];
        instvalid <=  `Instvalid;
        imm <= 32'h0;
        case (op2)
          3'b000:begin
                   if (inst_i[30] == 1'b0)
                      //ADD
                      begin
                         aluop_o <= `EXE_ADD_OP;
                         alusel_o <= `EXE_RES_LOGIC;   
                      end
                    else
                      //SUB
                      begin
                        aluop_o <= `EXE_SUB_OP;
                        alusel_o <= `EXE_RES_LOGIC;
                      end
                 end
           `EXE_SLL:begin
                      aluop_o <= `EXE_SLL_OP;
                      alusel_o <= `EXE_RES_SHIFT;  
                    end
           `EXE_SLT:begin
                      aluop_o <= `EXE_SLT_OP;
                      alusel_o <= `EXE_RES_COMPARE;
                    end
           `EXE_SLTU:begin
                      aluop_o <= `EXE_SLTU_OP;
                      alusel_o <= `EXE_RES_COMPARE;
                    end
           `EXE_AND:begin
                      aluop_o <= `EXE_AND_OP;
                      alusel_o <= `EXE_RES_LOGIC;
                    end 
           `EXE_OR:begin
                      aluop_o <= `EXE_OR_OP;
                      alusel_o <= `EXE_RES_LOGIC;
                    end 
           `EXE_XOR:begin
                      aluop_o <= `EXE_XOR_OP;
                      alusel_o <= `EXE_RES_LOGIC;
                    end
           `EXE_SR: begin
                      if (inst_i[30] == 1'b0)
                      //SRL
                      begin
                        aluop_o <=`EXE_SRL_OP;
                        alusel_o <= `EXE_RES_SHIFT;
                      end 
                      else
                      //SRA
                      begin
                        aluop_o <=`EXE_SRA_OP;
                        alusel_o <= `EXE_RES_SHIFT;
                      end
                    end      
        endcase
      end
    default:
    begin
      aluop_o <= `EXE_NOP_OP;
      alusel_o <= `EXE_RES_NOP;
      wreg_o <= `WriteDisable;
      instvalid <= `InstInvalid;
      reg1_read_o <= 1'b0;
      reg2_read_o <= 1'b0;
      imm <= `ZeroWord;
    end
  endcase
end
end


//2
always @(*) begin
  if (rst == `RstEnable) begin
    reg1_o <= `ZeroWord;
  end else if ((reg1_read_o == 1'b1) && (ex_wreg_i == 1'b1)
               &&(ex_wd_i == reg1_addr_o)) begin
    reg1_o <= ex_wdata_i;  
  end else if ((reg1_read_o == 1'b1) && (mem_wreg_i == 1'b1)
    &&(mem_wd_i == reg1_addr_o)) begin
    reg1_o <= mem_wdata_i; 
  end else if(reg1_read_o == 1'b1) begin
    reg1_o <= reg1_data_i;
  end else if(reg1_read_o == 1'b0) begin
    reg1_o <= imm;
  end else begin
    reg1_o <= `ZeroWord;
  end
end


//3
always @(*) begin
  if (rst == `RstEnable) begin
    reg2_o <= `ZeroWord;
  end else if ((reg2_read_o == 1'b1) && (ex_wreg_i == 1'b1)
               &&(ex_wd_i == reg2_addr_o)) begin
    reg2_o <= ex_wdata_i;  
  end else if ((reg2_read_o == 1'b1) && (mem_wreg_i == 1'b1)
    &&(mem_wd_i == reg2_addr_o)) begin
    reg2_o <= mem_wdata_i; 
  end else if(reg2_read_o == 1'b1) begin
    reg2_o <= reg2_data_i;
  end else if(reg2_read_o == 1'b0) begin
    reg2_o <= imm;
  end else begin
    reg2_o <= `ZeroWord;
  end
end

endmodule