`define RstEnable    1'b1            //复位信号有效
`define RstDisable   1'b0            //复位信号无效
`define ZeroWord     32'h00000000    //32位的数�??0
`define WriteEnable  1'b1            //使能�?????
`define WriteDisable 1'b0            //禁止�?????
`define ReadEnable   1'b1            //使能�?????
`define ReadDisable  1'b0            //禁止�?????
`define AluOpBus     7:0             //
`define AluSelBus    2:0             
`define Instvalid    1'b0            //指令有效
`define InstInvalid  1'b1            //指令无效
`define True_v       1'b1            //逻辑“真�?????
`define False_v      1'b0            //逻辑“假�?????
`define ChipEnable   1'b1            //芯片使能
`define ChipDisable  1'b0            //芯片禁止

//op2
`define EXE_NOP      3'b000
`define EXE_ADDI     3'b000
`define EXE_ADD      3'b000
`define EXE_SLT      3'b010
`define EXE_SLTI     3'b010
`define EXE_SLTIU    3'b011
`define EXE_SLTU     3'b011 
`define EXE_XORI     3'b100
`define EXE_XOR      3'b100
`define EXE_ORI      3'b110
`define EXE_OR       3'b110
`define EXE_ANDI     3'b111
`define EXE_AND      3'b111
`define EXE_SLLI     3'b001
`define EXE_SLL      3'b001
`define EXE_SR       3'b101
`define EXE_BEQ      3'b000
`define EXE_BNE      3'b001
`define EXE_BLT      3'b100
`define EXE_BGE      3'b101
`define EXE_BLTU     3'b110
`define EXE_BGEU     3'b111      
`define EXE_LB       3'b000
`define EXE_LH       3'b001
`define EXE_LW       3'b010
`define EXE_LBU      3'b100
`define EXE_LHU      3'b101
`define EXE_SB       3'b000
`define EXE_SH       3'b001
`define EXE_SW       3'b010

//AluOp
//lack AUIPC
`define EXE_NOP_OP   8'b00000000
`define EXE_ADD_OP   8'b00000001
`define EXE_SLT_OP   8'b00000010
`define EXE_SLTU_OP  8'b00000011
`define EXE_XOR_OP   8'b00000100
`define EXE_OR_OP    8'b00000101
`define EXE_AND_OP   8'b00000110
`define EXE_SLL_OP   8'b00000111
`define EXE_SRL_OP   8'b00001000
`define EXE_SRA_OP   8'b00001001 
`define EXE_SUB_OP   8'b00001010 
`define EXE_LUI_OP   8'b00001101 
`define EXE_AUIPC_OP 8'b00001110
`define EXE_JAL_OP   8'b00001111
`define EXE_JALR_OP  8'b00010000 
`define EXE_BEQ_OP   8'b00010001
`define EXE_BNE_OP   8'b00010010
`define EXE_BLT_OP   8'b00010011
`define EXE_BGE_OP   8'b00010100
`define EXE_BLTU_OP  8'b00010101
`define EXE_BGEU_OP  8'b00010110
`define EXE_AUIPC_OP 8'b00010111
`define EXE_LB_OP    8'b00011000
`define EXE_LH_OP    8'b00011001
`define EXE_LW_OP    8'b00011010
`define EXE_LBU_OP   8'b00011011
`define EXE_LHU_OP   8'b00011100
`define EXE_SB_OP    8'b00011101
`define EXE_SH_OP    8'b00011110
`define EXE_SW_OP    8'b00011111

//AluSel
`define EXE_RES_NOP      3'b000
`define EXE_RES_LOGIC    3'b001
`define EXE_RES_COMPARE  3'b010
`define EXE_RES_SHIFT    3'b011
`define EXE_RES_JUMP     3'b100
`define EXE_RES_LOAD     3'b101
`define EXE_RES_STORE    3'b110



// ---------------definition of ROM---------------
`define RamAddrBus     32:0
`define ZeroRamAddr    32'b0
`define InstAddrBus    31:0           //ROM的地�?????总线宽度
`define InstBus        31:0
`define InstMemNum     131071           
`define InstMemNumLog2 17

//---------------Regfile-------------
`define RegAddrBus     4:0  
`define RegBus         31:0
`define ByteBus        7:0
`define RegWidth       32
`define DoubleRegWidth 64
`define DoubleRegBus   63:0
`define RegNum         32
`define RegNumLog2     5
`define NOPRegAddr     5'b00000

/*defines about mem_buffer state*/

`define     Inst_1          4'b0000
`define     Inst_2          4'b0001
`define     Inst_3          4'b0010
`define     Inst_4          4'b0011
`define     Inst_5          4'b0100
`define     Mem_1           4'b0101
`define     Mem_2           4'b0110
`define     Mem_3           4'b0111
`define     Mem_4           4'b1000
`define     Mem_5           4'b1001
`define     Write_1         4'b1010
`define     Write_2         4'b1011
`define     Write_3         4'b1100
`define     Write_4         4'b1101