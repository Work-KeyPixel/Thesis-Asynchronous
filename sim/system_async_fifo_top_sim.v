`timescale 1ns/1ps
module system_async_fifo_top_sim;

    parameter DSIZE = 8;
    parameter ASIZE = 2;

    reg wclk, rclk;
    reg wrst_n, rrst_n;
    reg producer_event, consumer_event;

    wire [DSIZE-1:0] rdata;
    wire wfull, awfull, rempty, arempty;
    wire producer_active, consumer_active;

    system_async_fifo_top #(
        .DSIZE(DSIZE),
        .ASIZE(ASIZE)
    ) dut (.*);

    // clocks
    always #2 wclk = ~wclk;
    always #3 rclk = ~rclk;

    initial begin
        wclk = 0; rclk = 0;
        wrst_n = 0; rrst_n = 0;
        producer_event = 0;
        consumer_event = 0;

        #50;
        wrst_n = 1;
        rrst_n = 1;

        // PRODUCE
        #500;
        producer_event = 1;
        repeat (5) @(posedge wclk);
        producer_event = 0;

        // CONSUME
        #50;
        consumer_event = 1;
        repeat (5) @(posedge rclk);
        consumer_event = 0;

        #500;
        $finish;
    end

    initial begin
        $dumpfile("system_async_fifo_top.vcd");
        $dumpvars(0, system_async_fifo_top_sim);
    end
endmodule
