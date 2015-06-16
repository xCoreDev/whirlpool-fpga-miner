# whirlpool-fpga-miner
Implementation Of A FPGA Miner Using The Whirlpool Hashing Algorithm


This branch is for the Spartan9 LX9 chip (approx 5720 LUTs, 1430 Slices).

The latest change switches the Theta calculations (matrix multiplication using GF(256)) to XOR at the bit level instead of the byte level.

TODO: Determine if low level calls (i.e. call the LUT6 logic directly) can be made to reduce the area enough to increase throughput.
