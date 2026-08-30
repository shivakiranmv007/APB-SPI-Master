# 🔌 APB-SPI Master

## 📌Overview

This project implements an **APB-to-SPI Master interface** using synthesizable **Verilog RTL**.

The design provides an interface between an **AMBA APB bus** and an **SPI peripheral**, allowing an APB master to configure the SPI controller and perform serial data transfers with an SPI slave.

The project demonstrates practical concepts in **RTL Design, APB & SPI protocols, FSM-based control, register design, clock generation, serial data transfer, and functional verification**.

---

## ✨ Features

*  APB-based register interface
*  SPI Master functionality
*  APB read and write transactions
*  Configurable SPI control
*  CPOL and CPHA configuration
*  MSB/LSB-first data transfer
*  Programmable SPI clock generation
*  Serial data transmission through MOSI
*  Serial data reception through MISO
*  Slave Select (SS) control
*  Control, data, baud-rate, and status registers
*  Simulation-based functional verification

---

## 🏗️ Architecture

```text
                    APB Master
                        │
                        │ APB
                        ▼
              ┌─────────────────────┐
              │    APB Interface    │
              │                     │
              │  Register Access    │
              └──────────┬──────────┘
                         │
                         ▼
              ┌─────────────────────┐
              │      SPI Core       │
              │                     │
              │  Control Logic      │
              │  Shift Register     │
              │  Baud Generator     │
              │  Slave Select       │
              └──────────┬──────────┘
                         │
                  ┌──────┼──────┐
                  │      │      │
                 SCLK   MOSI    SS
                  │      │      │
                  └──────┼──────┘
                         │
                        MISO
                         ▲
                         │
                    SPI Slave
```

---

## 🧩 Main Modules

### 🔹 APB Interface

Handles communication between the APB master and SPI registers.

**Responsibilities:**

* APB setup and enable phase handling
* Register address decoding
* APB read operations
* APB write operations
* Control and data register access

### 🔹 SPI Core

Acts as the main control block of the SPI Master.

**Responsibilities:**

* Controls SPI transactions
* Coordinates SPI sub-blocks
* Manages transmit and receive operations
* Controls SPI configuration and status

### 🔹 SPI Shift Register

Handles serial data transmission and reception.

**Responsibilities:**

* Parallel data loading
* Serial data transmission
* Serial data reception
* Bit shifting
* MSB/LSB-first data handling

### 🔹 Baud Rate Generator

Generates the SPI serial clock using a programmable clock division value.

**Output:**

```text
SCLK
```

### 🔹 Slave Select

Controls the SPI:

```text
SS
```

signal during a transaction and selects the SPI slave device.

---

## 🔗 APB Interface

The SPI controller uses the **AMBA APB protocol** for register configuration and data access.

The basic APB transaction sequence is:

```text
IDLE → SETUP → ENABLE
```

The APB master performs register read/write operations to configure and control the SPI Master.

---

## 🔄 SPI Interface

The SPI Master communicates with an SPI slave using four main signals:

| Signal | Direction | Description         |
| ------ | --------- | ------------------- |
| `SCLK` | Output    | SPI serial clock    |
| `MOSI` | Output    | Master Out Slave In |
| `MISO` | Input     | Master In Slave Out |
| `SS`   | Output    | Slave Select        |

The SPI Master generates `SCLK`, `MOSI`, and `SS`, while receiving serial data through `MISO`.

---

## ⚙️ SPI Modes

SPI operation is configured using **CPOL** and **CPHA**.

| SPI Mode | CPOL | CPHA |
| -------- | ---: | ---: |
| Mode 0   |    0 |    0 |
| Mode 1   |    0 |    1 |
| Mode 2   |    1 |    0 |
| Mode 3   |    1 |    1 |

These settings determine the SPI clock polarity and the clock edge used for data sampling and transmission.

---

## 📝 Registers

The SPI controller contains registers for configuration, data transfer, clock control, and status monitoring.

| Register   | Purpose                              |
| ---------- | ------------------------------------ |
| `SPI_CR_1` | SPI control and configuration        |
| `SPI_CR_2` | Additional SPI control configuration |
| `SPI_BR`   | SPI baud-rate / clock configuration  |
| `SPI_DR`   | Transmit and receive data            |
| `SPI_SR`   | SPI status information               |

---

## 🔁 Data Transfer Flow

```text
       APB Master
            │
            ▼
   Configure SPI Registers
            │
            ▼
      Write TX Data
            │
            ▼
     Select SPI Slave
            │
            ▼
     Generate SPI Clock
            │
       ┌────┴────┐
       ▼         ▼
      MOSI      MISO
       │         │
       ▼         ▲
    Transmit   Receive
       │         │
       └────┬────┘
            ▼
     Transfer Complete
            │
            ▼
      Update Status
            │
            ▼
      Read RX Data
       through APB
```

---

## 🧪 Verification

The design is verified through **simulation-based functional verification**.

### Verification includes:

* Reset operation
* APB write transactions
* APB read transactions
* Register read/write functionality
* SPI configuration
* SPI clock generation
* Slave-select operation
* MOSI transmission
* MISO reception
* Serial data shifting
* SPI transaction completion
* Status register behavior

Simulation waveforms are analyzed to verify correct interaction between the APB interface and SPI signals.

---

## 🛠️ Tools & Technologies

### 💻 HDL

* Verilog HDL
* SystemVerilog

### 🧪 Simulation & Verification

* ModelSim

### 🖥️ Development Environment

* Linux
* MobaXterm
* Git
* GitHub

---

## 📂 Repository Structure

```text
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

```

---

## 🧠 Key Concepts Demonstrated

**RTL Design** • **APB Protocol** • **SPI Protocol** • **FSM** • **Shift Registers** • **Clock Division** • **Register Design** • **Synchronous Design** • **Serial Communication** • **Functional Verification** • **Simulation** • **Waveform Debugging**

---

## 🚀 Future Enhancements

*  UVM-based verification environment
*  SystemVerilog Assertions (SVA)
*  Functional coverage
*  Code coverage
*  Constrained-random verification
*  Multiple SPI slave support
*  Formal verification
  
---

## 🎯 Learning Outcomes

This project provided hands-on experience in designing and verifying an **APB-based SPI Master at RTL level**.

It strengthened practical understanding of:

* RTL design methodology
* APB and SPI protocols
* FSM-based control
* Register design
* Clock generation
* Serial data transfer
* Functional verification
* Simulation and waveform debugging

---

## 👨‍💻 Author

### Shiva Kiran

**Electronics & Communication Engineering**

**Areas of Interest:**
`VLSI` • `RTL Design` • `Design Verification` • `Verilog` • `SystemVerilog` • `Digital Design`

📧 **Email:** shivakiranmv007@gmail.com

🔗 **LinkedIn:** www.linkedin.com/in/shiva-kiran-mv-335476247

---



