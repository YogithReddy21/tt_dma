# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, RisingEdge


@cocotb.test()
async def test_dma(dut):
    dut._log.info("Starting DMA cocotb test")

    # Clock: 100 kHz (10us period)
    clock = Clock(dut.clk, 10, units="us")
    cocotb.start_soon(clock.start())

    # Reset
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 5)
    dut.rst_n.value = 1
    dut._log.info("Reset released")

    # Helper to wait until dma_done
    async def wait_done():
        while dut.uo_out.value.integer >> 7 == 0:  # dma_done is bit[7]
            await RisingEdge(dut.clk)

    # --------------------------
    # Single transfer test
    # --------------------------
    dut._log.info("Starting single transfer test")
    # Format: {start[7], src[6:4], dst[3:1], mode[0]}
    dut.ui_in.value = int("10001000", 2)  # start=1, src=000, dst=100, mode=0
    await ClockCycles(dut.clk, 1)
    dut.ui_in.value = 0  # clear start

    await wait_done()
    dma_done = (dut.uo_out.value.integer >> 7) & 1
    data_out = dut.uo_out.value.integer & 0x7F
    dut._log.info(f"Single transfer done, dma_done={dma_done}, data_out=0x{data_out:02X}")

    # Example assertion: after single transfer, expect mem[4] == mem[0] ("a")
    # You can't directly peek mem[] here, only outputs.
    # So check at least dma_done asserted and data_out matches.
    assert dma_done == 1, "DMA did not complete single transfer"
    assert data_out == ord("a"), f"Expected data_out='a' (0x61), got 0x{data_out:02X}"

    # --------------------------
    # Burst transfer test
    # --------------------------
    dut._log.info("Starting burst transfer test")
    dut.ui_in.value = int("10001001", 2)  # start=1, src=000, dst=100, mode=1
    await ClockCycles(dut.clk, 1)
    dut.ui_in.value = 0  # clear start

    await wait_done()
    dma_done = (dut.uo_out.value.integer >> 7) & 1
    data_out = dut.uo_out.value.integer & 0x7F
    dut._log.info(f"Burst transfer done, dma_done={dma_done}, last data_out=0x{data_out:02X}")

    assert dma_done == 1, "DMA did not complete burst transfer"
    # In burst, last word copied was "d" (0x64)
    assert data_out == ord("d"), f"Expected data_out='d' (0x64), got 0x{data_out:02X}"

    dut._log.info("DMA cocotb test PASSED")
