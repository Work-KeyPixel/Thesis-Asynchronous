`timescale 1ns/1ps

module system_async_fifo_top #(
    parameter DSIZE = 8,
    parameter ASIZE = 4
)(
    input  wire              wclk_raw,
    input  wire              rclk_raw,
    input  wire              wrst_n,
    input  wire              rrst_n,
    input  wire              w_event,
    input  wire              r_event,

    output wire [DSIZE-1:0]  rdata_o,
    output wire              rempty_o,
    output wire              wfull_o
);

    /* ================= INTERNAL ================= */
    wire                 winc;
    wire [DSIZE-1:0]     wdata;
    wire                 rinc;
    
    wire producer_active_cycles, consumer_active_cycles;
    wire                 prod_active ;
    wire                 cons_active ;

    /* ================= CLOCK GATING (SYSTEM LEVEL) ================= */
    wire wclk_gated = wclk_raw & prod_active;
    wire rclk_gated = rclk_raw & cons_active;

    /* ================= PRODUCER (LIGHT FSM) ================= */
    producer #(
        .DSIZE(DSIZE),
        .BURST_LEN(16),
        .IDLE_LEN(50)
    ) u_prod (
        .wclk_raw(wclk_raw),
        .rst_n(wrst_n),
        .producer_event(w_event),
        .wfull(wfull_o),
        .winc(winc),
        .wdata(wdata),
        .producer_active(prod_active), 
        .producer_active_cycles(producer_active_cycles)
    );

    /* ================= CONSUMER (LIGHT FSM) ================= */
    consumer #(
        .DSIZE(DSIZE),
        .BURST_LEN(16),
        .IDLE_LEN(80)
    ) u_cons (
        .rclk_raw(rclk_raw),
        .rst_n(rrst_n),
        .consumer_event(r_event),
        .rempty(rempty_o),
        .rinc(rinc),
        .rdata(rdata_o),
        .consumer_active(cons_active), 
        .consumer_active_cycles(consumer_active_cycles)
    );

    /* ================= ASYNC FIFO ================= */
    async_fifo #(
        .DSIZE(DSIZE),
        .ASIZE(ASIZE)
    ) u_fifo (
        .wclk(wclk_gated),
        .wrst_n(wrst_n),
        .winc(winc),
        .wdata(wdata),
        .wfull(wfull_o),

        .rclk(rclk_gated),
        .rrst_n(rrst_n),
        .rinc(rinc),
        .rdata(rdata_o),
        .rempty(rempty_o)
    );

endmodule
