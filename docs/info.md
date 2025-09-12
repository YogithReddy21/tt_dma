<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

# Project Name
DMA Controller (TinyTapeout)

## How it works
This design implements a tiny DMA (Direct Memory Access) controller.
It copies data from a source address to a destination address in either
single-transfer or burst-transfer mode. A small scratchpad memory inside
the module is preloaded with test values, and transfers are triggered by
config inputs.

## How to test
- Simulation: Run `make test` to execute cocotb tests.
- Hardware: Configure inputs via `ui_in` to set source, destination,
  transfer mode, and start bit. Observe outputs via `uo_out`.

## External hardware
No external hardware is required. The design runs standalone with the
TinyTapeout framework.
