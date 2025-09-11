`default_nettype none
`timescale 1ns/1ps

module tb;

  // VCD dump
  initial begin
    $dumpfile("tb.vcd");
    $dumpvars(0, tb);
    #1;
  end

  // Signals for TT wrapper
  reg        clk;
  reg        rst_n;
  reg        ena;
  reg  [7:0] ui_in;
  reg  [7:0] uio_in;
  wire [7:0] uo_out;
  wire [7:0] uio_out;
  wire [7:0] uio_oe;

  // For convenience
  wire       dma_done = uo_out[7];
  wire [6:0] data_out = uo_out[6:0];

`ifdef GL_TEST
  wire VPWR = 1'b1;
  wire VGND = 1'b0;
`endif

  // DUT instance (TinyTapeout wrapper)
  tt_um_dma dut (
`ifdef GL_TEST
    .VPWR(VPWR),
    .VGND(VGND),
`endif
    .ui_in  (ui_in),
    .uo_out (uo_out),
    .uio_in (uio_in),
    .uio_out(uio_out),
    .uio_oe (uio_oe),
    .ena    (ena),
    .clk    (clk),
    .rst_n  (rst_n)
  );

  // Clock generator
  always #10 clk = ~clk;

  // Dump DUT memory contents (reach inside wrapper -> core)
  task dump_memory;
    integer i;
    begin
      $display("---- MEMORY DUMP ----");
      for (i = 0; i < 8; i = i + 1) begin
        $display("mem[%0d] = %s (0x%0h)",
                  i, dut.dma_core.mem[i], dut.dma_core.mem[i]);
      end
      $display("----------------------");
    end
  endtask

  initial begin
    clk   = 0;
    rst_n = 0;
    ena   = 1;   // design enabled
    ui_in = 8'b0;
    uio_in= 8'b0;

    #50 rst_n = 1;  // release reset

    // --------------------
    // Single transfer test
    // --------------------
    #20 ui_in = 8'b1_000_100_0;  // start=1, src=0, dst=4, mode=0
    #20 ui_in = 8'b0;

    wait(dma_done);
    $display("Single transfer done at time %0t, data_out=%s (0x%0h)",
             $time, data_out, data_out);
    dump_memory();

    // --------------------
    // Burst transfer test
    // --------------------
    #100 ui_in = 8'b1_000_100_1; // start=1, src=0, dst=4, mode=1
    #20  ui_in = 8'b0;

    wait(dma_done);
    $display("Burst transfer done at time %0t, data_out=%s (0x%0h)",
             $time, data_out, data_out);
    dump_memory();

    $display("FINAL MEMORY (from TB view):");
    dump_memory();
    #10;
    $finish;
  end
endmodule
