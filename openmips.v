`include "defines.v"
module cpu(
    input  wire                 clk_in,			// system clock signal
    input  wire                 rst_in,			// reset signal
	input  wire					rdy_in,			// ready signal, pause cpu when low

    input  wire [ 7:0]          mem_din,		// data input bus
    output wire [ 7:0]          mem_dout,		// data output bus
    output wire [31:0]          mem_a,			// address bus (only 17:0 is used)
    output wire                 mem_wr,			// write/read signal (1 for write)

	output wire [31:0]			dbgreg_dout		// cpu register output (debugging demo)

    //output wire rom_ce_o,
);
  
  //IF/Id --> ID
  wire[`InstAddrBus] pc;
  wire[`InstAddrBus] id_pc_i;
  wire[`InstBus] id_inst_i;

  //ID --> ID/EX
  wire[`AluOpBus] id_aluop_o;
  wire[`AluSelBus] id_alusel_o;
  wire[`RegBus]  id_reg1_o;
  wire[`RegBus]  id_reg2_o;
  wire  id_wreg_o;
  wire[`RegAddrBus] id_wd_o;
  wire[`InstAddrBus] id_link_pc_o;
  wire[31:0]   id_branch_offset_o;

  //ID/EX --> EX
  wire [`AluOpBus] ex_aluop_i;
  wire [`AluSelBus] ex_alusel_i;
  wire [`RegBus] ex_reg1_i;
  wire [`RegBus] ex_reg2_i;
  wire ex_wreg_i;
  wire [`RegAddrBus] ex_wd_i;
  wire [`InstAddrBus] ex_link_pc_i;
  wire [31:0]   ex_branch_offset_i;

  //EX -->EX/MEM
  wire ex_wreg_o;
  wire [`RegAddrBus] ex_wd_o;
  wire [`RegBus] ex_wdata_o;

  //EX/MEM --> MEM
  wire mem_wreg_i;
  wire[`RegAddrBus] mem_wd_i;
  wire[`RegBus] mem_wdata_i;

  //MEM --> MEM/WB
  wire mem_wreg_o;
  wire [`RegAddrBus] mem_wd_o;
  wire [`RegBus] mem_wdata_o;
  
  //MEM/WB --> WB
  wire wb_wreg_i;
  wire[`RegAddrBus] wb_wd_i;
  wire[`RegBus]  wb_wdata_i;

  //ID -- Regfile
  wire reg1_read;
  wire reg2_read;
  wire[`RegBus] reg1_data;
  wire[`RegBus] reg2_data;
  wire[`RegAddrBus] reg1_addr;
  wire[`RegAddrBus] reg2_addr;

  //clean
  wire IDEX_clean;
  wire IFID_clean;
   
  //PC change
  wire pc_branch;
  wire IF_lock;
  wire MEM_lock;
  wire [`InstAddrBus] branch_addr;
  wire PC_change;
  //lock
  wire [4:0] ctrl_lock;
  
  ctrl ctrl0(
    .rst(rst_in),
    .lock_from_cpu(rdy_in),
    .lock_from_IF(IF_lock),
    .lock_from_MEM(MEM_lock),
    .lock(ctrl_lock)
  );

  //pc_reg
  pc_reg pc_reg0(
      .clk(clk_in),   .rst(rst_in),   
      .pc_branch_i(pc_branch),
      .branch_addr_i(branch_addr),
      .lock(ctrl_lock),
      .pc(pc),   .pc_changed(PC_change)
  );
  
  wire[`InstBus] if_inst_i;
  wire[`InstBus] if_inst_o;
  wire inst_enable;
  wire[`RamAddrBus] mem_ram_addr;
  wire[1:0] mem_read_req;
  wire[`RegBus] ram_write_data;
  wire[1:0] mem_write_req;
  wire[`RegBus] ram_data;
  wire ram_data_enable;

  //TODO
  mem_buffer mem_buffer0(
    .clk(clk_in),  .rst(rst_in),
    .pc_addr_i(pc), .read_data(mem_din),
    .mem_read_addr(mem_ram_addr),
    .mem_write_data(ram_write_data),
    .mem_read_req(mem_read_req),
    .mem_write_req(mem_write_req),

    .pc_changed(PC_change),

    .inst_o(if_inst_i), .inst_enable(inst_enable),
    .mem_data_o(ram_data),
    .mem_data_enable(ram_data_enable),
    .read_addr(mem_a),  .write_data(mem_dout),
    .mem_wr(mem_wr)
);
  
  //assign rom_addr_o = pc;
  wire[`InstAddrBus] if_pc_o;
  //IF
  IF if0(
      .rst(rst_in), .pc(pc),   //true?
      .inst_enable_i(inst_enable),      //TODO
      .inst_i(if_inst_i),

      .inst_o(if_inst_o),
      .pc_o(if_pc_o),
      .IF_lock_out(IF_lock)
  );


  //IF/ID
  if_id if_id0(
      .clk(clk_in),  .rst(rst_in),  
      
      .IFID_clean_i(IFID_clean),

      //from IF
      .if_pc(if_pc_o),
      .if_inst(if_inst_o),  
      
      //send to id
      .id_pc(id_pc_i),
      .id_inst(id_inst_i),

      //lock to stop
      .lock(ctrl_lock)
  );

  //ID
  id id0(
      .rst(rst_in),   .pc_i(id_pc_i),  .inst_i(id_inst_i),

      //from regfile 
      .reg1_data_i(reg1_data),  .reg2_data_i(reg2_data),
      //send to regfile
      .reg1_read_o(reg1_read),  .reg2_read_o(reg2_read),
      .reg1_addr_o(reg1_addr),  .reg2_addr_o(reg2_addr),
      
      //input from ex
      .ex_wreg_i(ex_wreg_o),  .ex_wdata_i(ex_wdata_o),
      .ex_wd_i(ex_wd_o),
      
        //input from mem
      .mem_wreg_i(mem_wreg_o),  .mem_wdata_i(mem_wdata_o),
      .mem_wd_i(mem_wd_o),
      
      //send to ID/EX
      .aluop_o(id_aluop_o),    .alusel_o(id_alusel_o),
      .reg1_o(id_reg1_o),      .reg2_o(id_reg2_o),
      .wd_o(id_wd_o),          .wreg_o(id_wreg_o),
      .link_pc_o(id_link_pc_o),.branch_offset_o(id_branch_offset_o)
   );

   //regfile 
   regfile regfile1(
     .clk(clk_in),          .rst(rst_in),
     .we(wb_wreg_i),     .waddr(wb_wd_i),
     .wdata(wb_wdata_i),  .re1(reg1_read),
     .raddr1(reg1_addr), .rdata1(reg1_data),
     .re2(reg2_read),    .raddr2(reg2_addr),
     .rdata2(reg2_data)
   );

   //ID/EX
   id_ex id_ex0(
     .clk(clk_in),   .rst(rst_in),
     //for ID
     .id_aluop(id_aluop_o),   .id_alusel(id_alusel_o),
     .id_reg1(id_reg1_o),     .id_reg2(id_reg2_o),
     .id_wd(id_wd_o),         .id_wreg(id_wreg_o),
     .id_link_pc(id_link_pc_o),
     .id_branch_offset(id_branch_offset_o),
     
     //from EX check if need clean
     .IDEX_clean_i(IDEX_clean),
     
     //lock to stop
     .lock(ctrl_lock),
     
     //send to EX
     .ex_aluop(ex_aluop_i),  .ex_alusel(ex_alusel_i),
     .ex_reg1(ex_reg1_i),    .ex_reg2(ex_reg2_i),
     .ex_wd(ex_wd_i),        .ex_wreg(ex_wreg_i),
     .ex_link_pc(ex_link_pc_i),
     .ex_branch_offset(ex_branch_offset_i)
   );
   
   wire[`RamAddrBus] ex_mem_addr_o;
   wire[`RegBus] ex_mem_write_data_o;
   wire[`AluOpBus] ex_aluop_o;
   wire ex_mem_rw_o;
   //EX
   ex ex0(
       .rst(rst_in),

       //from ID/EX
       .aluop_i(ex_aluop_i),  .alusel_i(ex_alusel_i),
       .reg1_i(ex_reg1_i),    .reg2_i(ex_reg2_i),
       .wd_i(ex_wd_i),        .wreg_i(ex_wreg_i),
       .link_pc_i(ex_link_pc_i),
       .branch_offset_i(ex_branch_offset_i),
       
       //send to EX/MEM
       .wd_o(ex_wd_o),        .wreg_o(ex_wreg_o),
       .wdata_o(ex_wdata_o),
        
       //output about memory
       .mem_addr(ex_mem_addr_o), .mem_write_data(ex_mem_write_data_o),
       .aluop_o(ex_aluop_o),     .mem_rw(ex_mem_rw_o),

       //pc change
       .pc_branch_o(pc_branch),
       .branch_addr_o(branch_addr),
    
       //about clean
       .IFID_clean_o(IFID_clean),
       .IDEX_clean_o(IDEX_clean)
   );
   
   wire[`RamAddrBus] mem_mem_addr_i;
   wire[`RegBus] mem_mem_write_data_i;
   wire mem_mem_rw_i;
   wire[`AluOpBus] mem_aluop_i;
   //EX/MEM
   ex_mem ex_mem0(
       .clk(clk_in),   .rst(rst_in),
       //from EX
       .ex_wd(ex_wd_o),   .ex_wreg(ex_wreg_o),
       .ex_wdata(ex_wdata_o),
       
       //about LOAD or STORE
       .aluop_i(ex_aluop_o),
       .mem_addr_i(ex_mem_addr_o),
       .mem_write_data_i(ex_mem_write_data_o),
       .mem_rw_i(ex_mem_rw_o), 
       
       //lock to stop
       .lock(ctrl_lock),

       //send to mem
       .mem_wd(mem_wd_i), .mem_wreg(mem_wreg_i),
       .mem_wdata(mem_wdata_i),
       
       //about LOAD or STORE
       .aluop_o(mem_aluop_i),
       .mem_addr_o(mem_mem_addr_i),
       .mem_write_data_o(mem_mem_write_data_i),
       .mem_rw_o(mem_mem_rw_i)  
   );

   //MEM
   mem mem0(
       .rst(rst_in),
       .lock(MEM_lock),
       //from EX/MEM
       .wd_i(mem_wd_i),  .wreg_i(mem_wreg_i),
       .wdata_i(mem_wdata_i),
       
       //LS
       .aluop_i(mem_aluop_i),
       .ex_mem_addr_i(mem_mem_addr_i),
       .ex_mem_data_i(mem_mem_write_data_i),
       .ex_mem_wr_i(mem_mem_rw_i),
       
       //send to MEM/WB
       .wd_o(mem_wd_o),  .wreg_o(mem_wreg_o),
       .wdata_o(mem_wdata_o),
  
       //TODO
       .ram_data_i(ram_data),  .ram_data_enable_i(ram_data_enable),

       .ram_addr_o(mem_ram_addr),  .ram_data_o(ram_write_data),      
       .mem_read_req(mem_read_req), .mem_write_req(mem_write_req)
    );

   //MEM/WB
   mem_wb mem_wb0(
       .clk(clk_in),   .rst(rst_in),

       //from MEM
       .mem_wd(mem_wd_o),  .mem_wreg(mem_wreg_o),
       .mem_wdata(mem_wdata_o),

       //lock to stop
       .lock(ctrl_lock),

       //send to WB
       .wb_wd(wb_wd_i),  .wb_wreg(wb_wreg_i),
       .wb_wdata(wb_wdata_i)
   );
endmodule