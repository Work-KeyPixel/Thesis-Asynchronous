`timescale 1ns/1ps

module producer #(
    parameter DSIZE = 8,
    parameter BURST_LEN = 16,
    parameter IDLE_LEN  = 200
)(
    input              wclk_raw,        // clock hệ thống
    input              rst_n,
    input              producer_event,
    input              wfull,
    output reg         winc,
    output reg [DSIZE-1:0] wdata,
    output reg         producer_active, 
    output reg [31:0] active_cycles  
);

    reg state;
    integer burst_cnt;
    integer idle_cnt;

    localparam IDLE  = 1'b0;
    localparam BURST = 1'b1;

    // FSM chạy trên clock hệ thống (nhẹ)
always @(posedge wclk_raw or negedge rst_n) begin
    if (!rst_n) begin
        state <= IDLE;
        idle_cnt <= 0;
        producer_active <= 0;
        active_cycles <= 0;
    end else begin
        // FSM
        case (state)
            IDLE: begin
                producer_active <= 0;
                idle_cnt <= idle_cnt + 1;
                if (producer_event && idle_cnt == IDLE_LEN-1) begin
                    idle_cnt <= 0;
                    state <= BURST;
                    producer_active <= 1;
                end
            end

            BURST: begin
                producer_active <= 1;
                if (burst_cnt == BURST_LEN-1) begin
                    state <= IDLE;
                    producer_active <= 0;
                end
            end
        endcase

        // activity counter
        if (producer_active)
            active_cycles <= active_cycles + 1;
    end
end


    // clock gated
    wire wclk = wclk_raw & producer_active;

    // logic TIÊU THỤ NĂNG LƯỢNG chạy trên wclk
    always @(posedge wclk or negedge rst_n) begin
        if (!rst_n) begin
            burst_cnt <= 0;
            winc <= 0;
            wdata <= 0;
        end else begin
            if (!wfull) begin
                winc <= 1;
                wdata <= wdata + 1;
                burst_cnt <= burst_cnt + 1;
            end else begin
                winc <= 0;
            end
        end
    end

endmodule
