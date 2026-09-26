# 32-bit Single-Cycle MIPS Processor

A 32-bit single-cycle MIPS processor implemented in Verilog HDL, with modular RTL blocks for the program counter, instruction memory, register file, control unit, ALU, and data memory.

The project includes individual module-level testbenches and a top-level processor testbench for simulation and waveform-based verification.

## Overview

This project implements a simplified 32-bit MIPS processor using a single-cycle datapath.

Each instruction is processed through the complete datapath within a single clock cycle. The processor is built from separate RTL modules that are integrated through the top-level `mips_core` module.

The implementation covers:

- Program counter management
- Instruction fetching
- Instruction decoding
- Register file operations
- ALU operations
- Data memory access
- Branch control
- Jump control
- Register write-back
- Module-level simulation
- Processor-level simulation
- VCD waveform generation

## Processor Architecture

The processor consists of the following major components:

```text
                         +----------------+
                         |      PC        |
                         +-------+--------+
                                 |
                                 v
                    +----------------------+
                    |  Instruction Memory |
                    +----------+-----------+
                               |
                            Instruction
                               |
              +----------------+----------------+
              |                                 |
              v                                 v
      +---------------+                  +---------------+
      | Control Unit  |                  | Register File |
      +-------+-------+                  +-------+-------+
              |                                 |
              | Control Signals                 |
              |                                 |
              +----------------+----------------+
                               |
                               v
                         +-----------+
                         |    ALU    |
                         +-----+-----+
                               |
                         ALU Result
                               |
                    +----------+----------+
                    |                     |
                    v                     v
             +-------------+       +-------------+
             | Data Memory |       | PC Control  |
             +-------------+       +-------------+
                    |
                    v
              Write-Back MUX
                    |
                    v
              Register File
