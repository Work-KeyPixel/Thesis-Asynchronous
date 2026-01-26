module consumer #(
    parameter DSIZE = 8,
    parameter BURST_LEN = 16,
    parameter IDLE_LEN  = 10
)(
    input              rclk_raw,
    input              rst_n,
    input              consumer_event,
    input              rempty,
    output reg         rinc,
    input  [DSIZE-1:0] rdata,
    output reg         consumer_active,
    output reg consumer_active_cycles
);

    reg state;
    integer idle_cnt;
    integer burst_cnt;

    localparam IDLE  = 1'b0;
    localparam BURST = 1'b1;

    // FSM + activity counter (clock RAW)
    always @(posedge rclk_raw or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            idle_cnt <= 0;
            burst_cnt <= 0;
            consumer_active <= 0;
            consumer_active_cycles <= 0;
        end else begin
            case (state)
                IDLE: begin
                    consumer_active <= 0;
                    burst_cnt <= 0;
                    idle_cnt <= idle_cnt + 1;
                    if (consumer_event && idle_cnt == IDLE_LEN-1 && !rempty) begin
                        idle_cnt <= 0;
                        state <= BURST;
                        consumer_active <= 1;
                    end
                end

                BURST: begin
                    consumer_active <= 1;
                    if (burst_cnt == BURST_LEN-1 || rempty) begin
                        state <= IDLE;
                        consumer_active <= 0;
                    end else begin
                        burst_cnt <= burst_cnt + 1;
                    end
                end
            endcase

            if (consumer_active)
                consumer_active_cycles <= consumer_active_cycles + 1;
        end
    end

    // gated clock (datapath only)
    wire rclk = rclk_raw & consumer_active;

    always @(posedge rclk or negedge rst_n) begin
        if (!rst_n)
            rinc <= 0;
        else
            rinc <= !rempty;
    end

endmodule
