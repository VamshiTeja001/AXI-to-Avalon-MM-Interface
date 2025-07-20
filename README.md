# AXI-to-Avalon-MM-Interface
The rv_avmm2axi block is a Verilog implementation of an Avalon‑MM (slave) to AXI‑Lite (master) bridge. It converts Avalon‑style transactions (single‑beat reads and writes with byte enables) into AXI‑Lite transactions using two simple finite‑state machines (FSMs)


# rv_avmm2axi

A parameterizable Verilog bridge converting Avalon‑MM slave transfers into AXI‑Lite master transactions, suitable for FPGA designs that need to interface legacy Avalon peripherals with AXI‑Lite-based IP.

## Features

- **Single‑beat reads and writes** with byte-enable support  
- **Separate FSMs** for read and write channels  
- **Synchronous, active‑low reset**  
- **Parameters** for address and data width customization  

## Parameters

| Name               | Default | Description                       |
|--------------------|---------|-----------------------------------|
| `ADDR_WIDTH`       | 14      | Width of the address bus          |
| `DATA_WIDTH`       | 32      | Width of the data buses           |
| `BYTEENABLE_WIDTH` | `DATA_WIDTH/8` | Width of byte-enable signals |

## Ports

### Clock & Reset
- `clk` : Clock input  
- `rst_n` : Active‑low synchronous reset  

### Avalon‑MM Slave Interface
- `d_address`        : Address input  
- `d_byteenable`     : Byte‑enable input  
- `d_read`           : Read strobe  
- `d_readdata`       : Read data output  
- `d_waitrequest`    : Waitrequest output  
- `d_write`          : Write strobe  
- `d_writedata`      : Write data input  

### AXI‑Lite Master Interface

#### Write Address Channel
- `m_axi_awaddr` : Write address output  
- `m_axi_awvalid`: Write address valid  
- `m_axi_awready`: Write address ready  

#### Write Data Channel
- `m_axi_wdata` : Write data output  
- `m_axi_wstrb` : Write strobe (byte enables)  
- `m_axi_wvalid`: Write data valid  
- `m_axi_wready`: Write data ready  

#### Write Response Channel
- `m_axi_bresp` : Write response input (2‑bit)  
- `m_axi_bvalid`: Write response valid  
- `m_axi_bready`: Write response ready  

#### Read Address Channel
- `m_axi_araddr` : Read address output  
- `m_axi_arvalid`: Read address valid  
- `m_axi_arready`: Read address ready  

#### Read Data Channel
- `m_axi_rdata` : Read data input  
- `m_axi_rresp` : Read response input (2‑bit)  
- `m_axi_rvalid`: Read data valid  
- `m_axi_rready`: Read data ready  

## Usage

1. **Instantiation**
   ```verilog
   rv_avmm2axi #(
     .ADDR_WIDTH(16),
     .DATA_WIDTH(64)
   ) u_bridge (
     .clk           (clk),
     .rst_n         (rst_n),
     .d_address     (avmm_addr),
     .d_byteenable  (avmm_byteen),
     .d_read        (avmm_read),
     .d_readdata    (avmm_rdata),
     .d_waitrequest (avmm_waitreq),
     .d_write       (avmm_write),
     .d_writedata   (avmm_wdata),
     // AXI‑Lite signals…
   );
