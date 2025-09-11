/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */
`default_nettype none

module tt_um_dma (
    input  wire [7:0] ui_in,    // dedicated inputs
    output wire [7:0] uo_out,   // dedicated outputs
    input  wire [7:0] uio_in,   // IOs: input path
    output wire [7:0] uio_out,  // IOs: output path
    output wire [7:0] uio_oe,   // IOs: enable path
    input  wire       ena,      // always 1 when powered
    input  wire       clk,      // clock
    input  wire       rst_n     // active-low reset
);

    // Internal wires
    wire [7:0] cfg_in  = ui_in;     // take config from dedicated input
    wire [6:0] data_out;
    wire       dma_done;

    // Instantiate your DMA core
    tiny_dma dma_core (
        .clk(clk),
        .rst(rst_n),      // directly connect, no inversion needed
        .cfg_in(cfg_in),
        .data_out(data_out),
        .dma_done(dma_done)
    );

    // Drive outputs (pack into 8-bit for TT)
    assign uo_out = {dma_done, data_out}; // bit7 = dma_done, bits[6:0] = data_out

    // Not using uio_in/out -> tie off
    assign uio_out = 8'b0;
    assign uio_oe  = 8'b0;

    // Avoid unused warnings
    wire _unused = &{ena, uio_in, 1'b0};

endmodule
