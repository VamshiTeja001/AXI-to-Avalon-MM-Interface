`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Raghavendra Vamshi Chathurajupalli
// 
// Create Date: 05.06.2025 15:23:21
// Design Name: Avalon to AXI Lite Bridge
// Module Name: Avalon_to_AXILInterface
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.02 - File Modified
// Additional Comments: Added Buffer, made states as 2 bits, Updated wait_request assertion, added next state, made other process block to combinational block with * and blocking assigninments
//  
//////////////////////////////////////////////////////////////////////////////////


module rv_avmm2axi #(
    parameter ADDR_WIDTH     = 14,    // AXI address width
    parameter DATA_WIDTH     = 32,    // Data width
    parameter BYTEENABLE_WIDTH = DATA_WIDTH/8   // Byte enable width
)(
    input  wire                  clk,
    input  wire                  rst_n,

    // Avalon-MM (slave side)
    input  wire [ADDR_WIDTH-1:0] d_address,
    input  wire [BYTEENABLE_WIDTH-1:0] d_byteenable,
    input  wire                  d_read,
    output      [DATA_WIDTH-1:0] d_readdata,
    output reg                   d_waitrequest,  // Input
    input  wire                  d_write,
    input  wire [DATA_WIDTH-1:0] d_writedata,

    // AXI-Lite (master side)

    // Write Address Channel
    output      [ADDR_WIDTH-1:0] m_axi_awaddr,
    output reg                   m_axi_awvalid,
    input  wire                  m_axi_awready,

    // Write Data Channel
    output      [DATA_WIDTH-1:0] m_axi_wdata,
    output      [BYTEENABLE_WIDTH-1:0] m_axi_wstrb,
    output reg                   m_axi_wvalid,
    input  wire                  m_axi_wready,

    // Write Response Channel
    input  wire [1:0]            m_axi_bresp,
    input  wire                  m_axi_bvalid,
    output reg                   m_axi_bready,

    // Read Address Channel
    output      [ADDR_WIDTH-1:0] m_axi_araddr,
    output reg                   m_axi_arvalid,
    input  wire                  m_axi_arready,

    // Read Data Channel
    input  wire [DATA_WIDTH-1:0] m_axi_rdata,
    input  wire [1:0]            m_axi_rresp,
    input  wire                  m_axi_rvalid,
    output reg                   m_axi_rready
);

    //Write State    
    localparam IDLE_W = 0;
    localparam ADDR_W =1;
    localparam DATA_W =2;
    localparam RESP_W =3;
    reg [1:0] wstate = IDLE_W, wstate_next;    // Initialized State of Write FSM
    
    //Read States
    localparam IDLE_R =0;
    localparam ADDR_R =1;
    localparam WAIT_R =2;
    reg [1:0] rstate = IDLE_R, rstate_next;   //Initialized State of Read FSM
    
  //  reg rpull_wt, wpull_wt;
    
// Write FSM
    always @(posedge clk) begin
      if (!rst_n)
        wstate <= IDLE_W;
      else
        wstate <= wstate_next;
    end

    always @(*) begin
        if (!rst_n) begin
            wstate_next = IDLE_W;
        end else begin
            case (wstate)
                IDLE_W: begin
                    if (d_write) begin
                        wstate_next = ADDR_W;
                    end
                    else
                      wstate_next = IDLE_W;
                end
                ADDR_W: begin
                    if (m_axi_awready) begin
                        wstate_next = DATA_W;
                    end
                    else
                        wstate_next = ADDR_W;
                end
                DATA_W: begin
                    if (m_axi_wready) begin
                        wstate_next = RESP_W; 
                    end
                    else
                        wstate_next = DATA_W;
                end
                RESP_W: begin
                    if (m_axi_bvalid) begin
                        wstate_next = IDLE_W;
                    end
                    else
                        wstate_next = RESP_W;
                end
                default:
                    wstate_next = IDLE_W;
            endcase
        end
    end
    always @(posedge clk) begin
        if (!rst_n) begin
            m_axi_awvalid <= 0;
            m_axi_wvalid  <= 0;
            m_axi_bready  <= 0;
        end else begin
            m_axi_awvalid <= 0;
            m_axi_wvalid  <= 0;
            m_axi_bready  <= 1;
            case (wstate)
                IDLE_W: begin
                    if (d_write) begin
                        m_axi_awvalid <= 1;
                    end
                end
                ADDR_W: begin
                    m_axi_awvalid <= 1;
                    if (m_axi_awready) begin
                        m_axi_wvalid  <= 1;
                    end
                end
                DATA_W: begin
                    m_axi_wvalid <= 1;
                end
            endcase
        end
    end
    assign m_axi_awaddr =  d_address;
    assign m_axi_wstrb = d_byteenable;
    assign m_axi_wdata = d_writedata;
 
 // Read FSM
    always @(posedge clk) begin
    if (!rst_n)
        rstate <= IDLE_R;
    else        
        rstate <= rstate_next;
    end

    always @(*) begin
        if (!rst_n) begin
            rstate_next = IDLE_R;         
        end 
        else begin    
            case (rstate)
                IDLE_R: begin
                    if (d_read) begin
                        rstate_next = ADDR_R;
                    end
                    else
                        rstate_next = IDLE_R;
                end
                ADDR_R: begin
                    if (m_axi_arready) begin
                        rstate_next = WAIT_R;
                    end
                    else 
                        rstate_next = ADDR_R;
                end
                WAIT_R: begin
                    if (m_axi_rvalid) begin
                        rstate_next = IDLE_R;
                    end
                    else
                        rstate_next = WAIT_R;
                end
                default : rstate_next = IDLE_R;
            endcase
        end
    end

    always @(posedge clk) begin
        if (!rst_n) begin
            m_axi_arvalid <= 0;
            m_axi_rready  <= 0;
        end else begin
            m_axi_arvalid <= 0;
            m_axi_rready  <= 1;
            case (rstate)
                IDLE_R: begin
                    if (d_read) begin
                        m_axi_arvalid <= 1;
                    end
                end
                ADDR_R: begin
                    m_axi_arvalid <= 1;
                end
            endcase
        end
    end
    assign d_readdata = m_axi_rdata;
    assign m_axi_araddr = d_address;
    // Avalon waitrequest generation
    always @(*) begin
        if (wstate_next != IDLE_W || rstate_next != IDLE_R )//|| wpull_wt || rpull_wt || (!rst_n)) // || s_axi_awready || s_axi_wready ||  s_axi_rready )
            d_waitrequest = 1; 
        else
            d_waitrequest = 0;
    end
    
    
 
endmodule