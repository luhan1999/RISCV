module openmips_min_sopc(
    input wire clk,
    input wire rst
);

  wire[`InstAddrBus] inst_addr;
  wire[`InstBus] inst;
  wire  rom_ce;

  wire[`ByteBus] output_data;
  wire mem_wr;

  openmips openmips0(
      .clk(clk),   .rst(rst),
      .rom_addr_o(inst_addr),
      .rom_data_i(inst),
      .rom_ce_o(rom_ce),
      .rom_data_o(output_data),
      .mem_wr(mem_wr)
  );
  ram ram0(
      .clk_in(clk),
      .en_in(rom_ce),
      .r_nw_in(mem_wr),  .a_in(inst_addr),  .d_in(output_data),
        
      .d_out(inst)
  );
endmodule