# APB-SPI Master

## 📌 Project Overview

This project implements an **APB-Based SPI Master Controller** using synthesizable **Verilog HDL**.

The design integrates an **APB Slave Interface, SPI Shift Register, Baud Rate Generator, and Slave Select Controller** into a single **SPI Core**.

The APB interface provides register-based control and configuration of the SPI Master, while the SPI-related modules handle clock generation, serial data transmission/reception, and slave-select control.

The design was developed at RTL level and verified through simulation and waveform analysis.

---

## 🎯 Objectives

- Design an SPI Master controller using Verilog HDL.
- Integrate the SPI Master with an APB interface.
- Implement APB read and write transactions.
- Implement SPI serial data transmission and reception.
- Generate a programmable SPI clock.
- Support CPOL and CPHA based SPI timing.
- Support MSB-first and LSB-first data transfer.
- Implement active-low slave-select control.
- Implement SPI control, status, baud-rate, and data registers.
- Integrate multiple RTL modules into a complete SPI Core.
- Verify the integrated design through simulation and waveform analysis.

---

# 🏗️ Architecture

The **SPI Core** is the top-level RTL block that integrates four major functional modules:

                         APB MASTER
                             │
                             │ APB Signals
                             ▼
                  ┌────────────────────────┐
                  │        SPI CORE        │
                  │                        │
                  │  ┌──────────────────┐  │
                  │  │ APB Slave        │  │
                  │  │ Interface        │  │
                  │  └────────┬─────────┘  │
                  │           │            │
                  │  ┌────────▼─────────┐  │
                  │  │  SPI Shift       │  │
                  │  │  Register        │  │
                  │  └────────┬─────────┘  │
                  │           │            │
                  │  ┌────────▼─────────┐  │
                  │  │ Baud Rate        │  │
                  │  │ Generator        │  │
                  │  └────────┬─────────┘  │
                  │           │            │
                  │  ┌────────▼─────────┐  │
                  │  │ Slave Select     │  │
                  │  │ Controller       │  │
                  │  └──────────────────┘  │
                  │                        │
                  └───────────┬────────────┘
                              │
                    ┌─────────┼─────────┐
                    │         │         │
                    ▼         ▼         ▼
                  SCLK       MOSI       SS
                              ▲
                              │
                             MISO

---

## 🔹 APB Slave Interface

The APB Slave Interface manages communication between the APB master and the SPI Core.

It performs:

- APB setup and access phase handling
- APB read and write operations
- Address decoding
- SPI register access
- SPI configuration through control registers
- Transfer of transmit data to the SPI Shift Register
- Transfer of received data back to the APB Data Register
- PREADY generation
- PSLVERR generation

---

## 🔹 SPI Shift Register

The Shift Register handles parallel-to-serial and serial-to-parallel data operations.

It performs:

- Loading transmit data from the SPI Data Register
- Serial transmission through MOSI
- Serial reception through MISO
- MSB-first and LSB-first data handling
- Sampling based on CPOL and CPHA configuration
- Storing received serial data before transferring it back to the APB interface

The design uses an internal transmit shift register and a temporary receive register.

---

## 🔹 Baud Rate Generator

The Baud Rate Generator generates the SPI serial clock based on programmable baud-rate control fields.

The baud-rate divisor is calculated using:

    BaudRateDivisor = (SPPR + 1) × 2^(SPR + 1)

The generated SPI clock is toggled based on the calculated divisor to provide the required SPI clock timing.

The module also generates timing control signals used by the Shift Register for:

- MISO sampling
- MOSI transmission
- Positive-edge timing
- Negative-edge timing

---

## 🔹 Slave Select Controller

The Slave Select Controller generates the active-low `SS` signal when the SPI Master starts a data transfer.

It:

- Activates `SS` when transmit data is available
- Keeps the slave selected during the transfer
- Uses the baud-rate timing for transfer control
- Generates the receive-data control signal after the transfer
- Deasserts `SS` after the transfer is completed
- Generates the `TIP` (Transfer In Progress) indication

---

# 🚌 APB Interface

The design uses an **APB-based interface** for accessing and configuring the SPI Master.

## APB Signals

| Signal | Description |
|--------|-------------|
| `PCLK` | APB clock |
| `PRESET_n` | Active-low reset |
| `PSEL` | Peripheral select |
| `PENABLE` | APB enable signal |
| `PWRITE` | Read/write control |
| `PADDR` | APB address |
| `PWDATA` | APB write data |
| `PRDATA` | APB read data |
| `PREADY` | Transfer ready indication |
| `PSLVERR` | Slave error indication |

---

## APB Transfer Phases

The APB interface implements the following state sequence:

    IDLE → SETUP → ENABLE → IDLE

### IDLE

Waiting for a peripheral selection.

### SETUP

`PSEL` is asserted and `PENABLE` is low.

### ENABLE

`PSEL` and `PENABLE` are asserted and the read/write operation is performed.

---

# 🗃️ SPI Register Map

The SPI Core contains the following registers:

| Address | Register | Description |
|---------|----------|-------------|
| `0x00` | `SPI_CR_1` | SPI Control Register 1 |
| `0x01` | `SPI_CR_2` | SPI Control Register 2 |
| `0x02` | `SPI_BR` | SPI Baud Rate Register |
| `0x03` | `SPI_SR` | SPI Status Register |
| `0x05` | `SPI_DR` | SPI Data Register |

---

## SPI_CR_1

Controls the main SPI configuration.

Implemented control fields include:

- SPI interrupt enable
- SPI enable
- SPI transmit interrupt enable
- Master mode selection
- Clock polarity (`CPOL`)
- Clock phase (`CPHA`)
- Slave-select output enable
- LSB-first selection

---

## SPI_CR_2

Provides additional SPI configuration.

The implemented configuration includes:

- `SPISWAI` control

---

## SPI_BR

The Baud Rate Register contains programmable baud-rate fields:

- `SPPR`
- `SPR`

These fields determine the SPI clock divisor.

The baud-rate calculation is:

    BaudRateDivisor = (SPPR + 1) × 2^(SPR + 1)

---

## SPI_SR

The Status Register provides SPI operating status information including:

- SPI transfer status
- Transmit buffer status
- Mode fault indication

---

## SPI_DR

The SPI Data Register is used for:

- Loading transmit data
- Reading received data

---

# 🔄 Data Transfer Flow

## APB Write → SPI Transmission

    APB Master
        │
        │ PADDR + PWDATA
        ▼
    APB Slave Interface
        │
        ▼
    SPI Data Register
        │
        ▼
    Shift Register
        │
        ▼
       MOSI
        │
        ▼
    External SPI Slave

When data is written to `SPI_DR`, the SPI Core initiates the transfer when the required SPI configuration and master-enable conditions are satisfied.

---

## SPI Reception → APB Read

    External SPI Slave
            │
            │ MISO
            ▼
      Shift Register
            │
            ▼
    Temporary Receive Register
            │
            ▼
      SPI Data Register
            │
            ▼
    APB Slave Interface
            │
            ▼
        APB Master

Received serial data is sampled according to the configured CPOL/CPHA and bit-order settings.

---

# ⚙️ SPI Features

- SPI Master operation
- 8-bit data transfer
- MOSI data transmission
- MISO data reception
- Programmable SPI baud rate
- CPOL configuration
- CPHA configuration
- MSB-first data transfer
- LSB-first data transfer
- Active-low Slave Select generation
- SPI RUN, WAIT, and STOP modes
- APB-controlled SPI registers
- Programmable control and status registers
- Integrated APB-to-SPI control path

---

# 🔁 SPI Operating Modes

The SPI Core contains an internal mode controller with three states:

    RUN
     │
     ▼
    WAIT
     │
     ▼
    STOP

### RUN

SPI operation is enabled and the controller can perform transfers.

### WAIT

SPI operation waits for the required enable or operating conditions.

### STOP

SPI operation is stopped when the configured wait condition is active.

---

# 🧩 RTL Modules

| Module | Function |
|--------|----------|
| `spi_core.v` | Top-level SPI Core integrating all modules |
| `spi_apb_interface.v` | APB interface and SPI register control |
| `spi_shifter.v` | Serial data transmission and reception |
| `spi_baud_generator.v` | SPI clock and timing generation |
| `spi_slave_select.v` | Slave-select and transfer control |

---

# 🧪 Verification

The project includes individual testbenches for the major RTL modules as well as an integrated SPI Core testbench.

## Module-Level Verification

The following modules have dedicated testbenches:

- APB Slave Interface
- Baud Rate Generator
- SPI Shift Register
- Slave Select Controller

The corresponding testbenches are located inside the `tb/` directory.

---

## Integrated Verification

The `spi_core_tb.v` testbench verifies the integrated SPI Core through:

- APB register write transactions
- SPI control-register configuration
- Baud-rate register configuration
- SPI Data Register write
- SPI transfer initiation
- SCLK generation
- MOSI transmission
- MISO reception
- Slave Select generation
- Received-data transfer back to the APB interface

For MISO verification, the testbench drives serial response data onto the `MISO` input of the SPI Master.

---

# 📊 Simulation Flow

The integrated testbench performs operations such as:

    1. Reset the SPI Core
            ↓
    2. Configure SPI Control Registers
            ↓
    3. Configure Baud Rate
            ↓
    4. Write Transmit Data to SPI_DR
            ↓
    5. Activate Slave Select
            ↓
    6. Generate SPI Clock
            ↓
    7. Transmit Data through MOSI
            ↓
    8. Sample Data through MISO
            ↓
    9. Store Received Data
            ↓
    10. Read Received Data through APB

Simulation waveforms are used to analyze and debug the behavior of both APB and SPI signals.

A representative waveform is available in:

    simulation/waveform.png

---

# 🛠️ Tools & Technologies

## HDL

- Verilog HDL

## Protocols

- AMBA APB
- SPI

## Simulation

- ModelSim
- VCD waveform generation

## Development

- Linux
- GitHub

---

# 📚 Key Concepts Demonstrated

- RTL Design
- APB Protocol
- SPI Protocol
- FSM Design
- Register Design
- Clock Generation
- Baud Rate Generation
- Serial Data Transmission
- Serial Data Reception
- CPOL / CPHA Based Timing
- MSB / LSB Data Ordering
- RTL Module Integration
- Simulation
- Waveform Debugging

---

# 🚀 Learning Outcomes

Through this project, I gained hands-on experience in:

- Designing synthesizable RTL using Verilog HDL
- Implementing an APB slave interface
- Understanding APB setup and access phases
- Designing an SPI Master controller
- Integrating multiple RTL modules into a complete SPI Core
- Implementing programmable SPI clock generation
- Handling serial data transmission and reception
- Implementing CPOL and CPHA based timing
- Implementing MSB-first and LSB-first data handling
- Designing control, status, baud-rate, and data registers
- Verifying RTL functionality using simulation
- Debugging RTL behavior using waveforms
- Managing RTL source code and testbenches using Git and GitHub

---

# 📁 Repository Structure

    APB-SPI-Master/
    │
    ├── rtl/
    │   ├── spi_core.v
    │   ├── spi_apb_interface.v
    │   ├── spi_shifter.v
    │   ├── spi_baud_generator.v
    │   └── spi_slave_select.v
    │
    ├── tb/
    │   ├── spi_core_tb.v
    │   ├── spi_apb_interface_tb.v
    │   ├── spi_shifter_tb.v
    │   ├── spi_baud_generator_tb.v
    │   └── spi_slave_select_tb.v
    │
    ├── simulation/
    │   └── waveform.png
    │
    └── README.md

---

## 📂 Directory Description

| Directory/File | Description |
|----------------|-------------|
| `rtl/` | Contains all synthesizable RTL design files |
| `tb/` | Contains module-level and integrated testbenches |
| `simulation/` | Contains simulation waveform results |
| `README.md` | Project documentation |

---

# 🔍 Verification Scope

The verification focuses on the interaction between the APB interface and the SPI Master functionality.

The following signal-level behavior is observed during simulation:

    APB
     │
     ├── PSEL
     ├── PENABLE
     ├── PWRITE
     ├── PADDR
     ├── PWDATA
     ├── PRDATA
     ├── PREADY
     └── PSLVERR
              │
              ▼
           SPI CORE
              │
        ┌─────┼─────┐
        ▼     ▼     ▼
       SCLK  MOSI   SS
               ▲
               │
              MISO

The waveform is analyzed to ensure correct sequencing of APB transactions and SPI transfers.

---

# 💡 Project Highlights

- Complete RTL-level APB-SPI Master implementation
- Modular architecture
- Separate APB and SPI functional blocks
- Programmable SPI baud-rate generation
- Configurable CPOL and CPHA
- Configurable MSB-first / LSB-first operation
- Serial transmit and receive functionality
- Active-low slave-select generation
- Dedicated module-level testbenches
- Integrated SPI Core verification
- Waveform-based debugging and analysis

---

# 👨‍💻 Author

## SHIVA KIRAN MV

**RTL Design & Verification Engineer**

📧 **Email:** shivakiranmv007@gmail.com

🔗 **GitHub:** https://github.com/shivakiranmv007/APB-SPI-Master

---

## ⭐ Project

If you find this project useful for learning RTL Design, APB, SPI, or Design Verification, feel free to explore the repository and give it a ⭐.
