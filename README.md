# Fault-Tolerant RISC-V Processor with Triple Modular Redundancy (TMR)

This repository contains the Verilog source code for a fault-tolerant RISC-V processor system, designed with Triple Modular Redundancy (TMR) and advanced error detection/correction mechanisms. The project is suitable for research, education, and prototyping of reliable digital systems.

## Project Overview

This project implements a pipelined RISC-V processor core with fault tolerance using Triple Modular Redundancy (TMR). The system replicates the processor core three times and uses majority voting to mask faults. It also integrates Single Error Correction, Double Error Detection (SECDED) for memory reliability, error injection for robust testing, and recovery mechanisms for handling detected errors. The design is modular, making it easy to extend or adapt for different reliability requirements.

## Features

- **Triple Modular Redundancy (TMR):** Replicates the processor core three times and uses majority voting to mask faults.
- **SECDED Memory Protection:** Implements Single Error Correction, Double Error Detection (SECDED) for memory reliability.
- **Error Injection:** Supports configurable error injection for robust testing.
- **Pipeline Architecture:** Implements a pipelined RISC-V core with hazard detection, forwarding, and stalling.
- **Recovery Mechanisms:** Includes lockstep and recovery logic for handling detected errors.
- **Comprehensive Testbench:** Provides a testbench for simulation and verification.

## Directory Structure

- `fault_tolerant_risc_v_processor.v` — Top-level module integrating all subsystems.
- `tmr_risc_v_system.v` — TMR system wrapper with voting and error management.
- `RISC_V_PROCESSOR.v` — Standard RISC-V processor core.
- `error_injection.v` — Error injection module for testing.
- `secded_encoder_new.v` / `secded_decoder_new.v` — SECDED encoder/decoder for memory.
- `ALU.v`, `ALU_CONTROL.v` — Arithmetic Logic Unit and control.
- `CONTROL_UNIT.v` — Main control logic.
- `BRANCH_CONDITION_CHECKER.v`, `jump_detector.v` — Branch and jump logic.
- `FORWARDING_UNIT.v`, `FORWARDING_MUXES.v` — Data forwarding logic.
- `STALLING UNIT.v`, `stalling_mux.v` — Pipeline stalling logic.
- `MEM_STAGE.v`, `MEM_WB.v`, `EX_MEM.v`, `ID_EX.v`, `IF_ID.v` — Pipeline stage registers.
- `data_memory_system.v`, `INSTRUCTION MEMORY.v` — Data and instruction memory.
- `REGFILE.v` — Register file.
- `voter_block.v` — TMR voter logic.
- `lockstep_controller.v`, `recovery_register.v` — Error recovery and lockstep operation.
- `tb_fault_tolerant_risc_v_processor.v` — Testbench for simulation.

## Module Descriptions

| Module(s) | Description |
|-----------|-------------|
| `fault_tolerant_risc_v_processor.v` | Top-level module that integrates the TMR system, SECDED memory, error injection, and recovery logic. Manages overall operation, error detection, and correction. |
| `tmr_risc_v_system.v` | Implements the TMR system by instantiating three RISC-V cores, synchronizing their operation, and using majority voting (via `voter_block.v`) to mask faults. Handles error detection and recovery signaling. |
| `RISC_V_PROCESSOR.v` | Implements a pipelined RISC-V processor core, including instruction fetch, decode, execute, memory, and write-back stages. Supports hazard detection, forwarding, and stalling. |
| `error_injection.v` | Provides mechanisms to inject single, double, or random errors into data or encoded memory for testing the system's fault tolerance. |
| `secded_encoder_new.v`, `secded_decoder_new.v` | Implements Single Error Correction, Double Error Detection (SECDED) encoding and decoding for memory protection. Ensures single-bit errors are corrected and double-bit errors are detected. |
| `ALU.v`, `ALU_CONTROL.v` | Implements the Arithmetic Logic Unit and its control logic, supporting arithmetic, logic, and shift operations as required by the RISC-V ISA. |
| `CONTROL_UNIT.v` | Generates control signals for the processor pipeline based on the current instruction, managing data flow and operation sequencing. |
| `BRANCH_CONDITION_CHECKER.v`, `jump_detector.v` | Implements branch and jump logic, determining when and where to branch or jump in the instruction flow. |
| `FORWARDING_UNIT.v`, `FORWARDING_MUXES.v` | Implements data forwarding logic to resolve data hazards in the pipeline, improving performance by reducing stalls. |
| `STALLING UNIT.v`, `stalling_mux.v` | Implements pipeline stalling logic to handle hazards that cannot be resolved by forwarding. |
| `MEM_STAGE.v`, `MEM_WB.v`, `EX_MEM.v`, `ID_EX.v`, `IF_ID.v` | Pipeline stage registers that hold intermediate values and control signals between pipeline stages. |
| `data_memory_system.v`, `INSTRUCTION MEMORY.v` | Implements data and instruction memory modules, supporting read and write operations as required by the processor. |
| `REGFILE.v` | Implements the register file, providing storage and access for the processor's general-purpose registers. |
| `voter_block.v` | Implements majority voting logic for TMR, selecting the correct output among three redundant modules. |
| `lockstep_controller.v`, `recovery_register.v` | Implements error recovery and lockstep operation, ensuring the system can recover from detected errors and maintain correct operation. |
| `tb_fault_tolerant_risc_v_processor.v` | Testbench for simulating and verifying the fault-tolerant processor, including error injection and recovery scenarios. |

## Getting Started

### Prerequisites
- Verilog simulator (e.g., ModelSim, Vivado, Icarus Verilog)
- Basic knowledge of digital design and RISC-V architecture

### Simulation
1. Open the project in your preferred Verilog simulation environment.
2. Set `tb_fault_tolerant_risc_v_processor.v` as the top-level testbench.
3. Run the simulation to observe processor operation, error injection, and recovery.

### Customization
- Modify `error_injection.v` to change error types and positions.
- Adjust SECDED parameters in `secded_encoder_new.v` and `secded_decoder_new.v` for different memory widths.

## Contributing
Contributions are welcome! Please open issues or submit pull requests for improvements or bug fixes.

## License
This project is licensed under the MIT License.

---
**Note:** For detailed module descriptions, refer to the comments within each Verilog file.
