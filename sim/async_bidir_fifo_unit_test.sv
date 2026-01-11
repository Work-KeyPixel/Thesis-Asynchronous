`timescale 1ns/1ps
`default_nettype none

module async_bidir_fifo_unit_test_duplex;

    // ================= PARAMETERS =================
    localparam DW    = 32;
    localparam ASIZE = 4;
    localparam DEPTH = 2**ASIZE; // 16 words
    integer i;
    integer timeout = 0;

    // ================= CLOCK / RESET =================
    reg a_clk = 0;
    reg b_clk = 0;
    always #2 a_clk = ~a_clk;   // 250 MHz
    always #3 b_clk = ~b_clk;   // ~166 MHz

    reg a_rst_n = 0;
    reg b_rst_n = 0;

    // ================= A SIDE =================
    reg  [DW-1:0] a_wdata;
    reg           a_winc;
    reg           a_rinc;
    wire [DW-1:0] a_rdata;
    wire          a_full;
    wire          a_empty;

    // ================= B SIDE =================
    reg  [DW-1:0] b_wdata;
    reg           b_winc;
    reg           b_rinc;
    wire [DW-1:0] b_rdata;
    wire          b_full;
    wire          b_empty;

    // ================= DUT =================
    async_bidir_fifo #(
        .DSIZE(DW),
        .ASIZE(ASIZE)
    ) dut (
        .a_clk(a_clk),
        .a_rst_n(a_rst_n),
        .a_winc(a_winc),
        .a_rinc(a_rinc),
        .a_wdata(a_wdata),
        .a_rdata(a_rdata),
        .a_full(a_full),
        .a_empty(a_empty),

        .b_clk(b_clk),
        .b_rst_n(b_rst_n),
        .b_winc(b_winc),
        .b_rinc(b_rinc),
        .b_wdata(b_wdata),
        .b_rdata(b_rdata),
        .b_full(b_full),
        .b_empty(b_empty)
    );

    // ================= RESET =================
    initial begin
        a_winc = 0; a_rinc = 0;
        b_winc = 0; b_rinc = 0;
        a_wdata = 0; b_wdata = 0;
        #50;
        a_rst_n = 1;
        b_rst_n = 1;
    end

    // ================= DUMP =================
    initial begin
        $dumpfile("async_bidir_fifo_duplex.vcd");
        $dumpvars(0, async_bidir_fifo_unit_test_duplex);
    end

    // ================= MONITOR =================
    initial begin
        $monitor("Time=%0t | a_full=%b a_empty=%b | b_full=%b b_empty=%b", 
                 $time, a_full, a_empty, b_full, b_empty);
    end

    // =========================================================
    // STEP 1: A ghi vòng 1 (0→F)
    // =========================================================
    initial begin
        wait(a_rst_n && b_rst_n);
        @(negedge a_clk);
        for (i = 0; i < DEPTH; i = i + 1) begin
            while (a_full) @(negedge a_clk);
            a_wdata = 32'hA000_0000 | i;
            a_winc = 1;
            @(negedge a_clk);
            a_winc = 0;
        end
    end

    // =========================================================
    // STEP 2: B đọc vòng 1 (0→F)
    // =========================================================
    initial begin
        wait(a_rst_n && b_rst_n);
        @(posedge b_clk);
        repeat(5) @(posedge b_clk); // delay propagate
        for (i = 0; i < DEPTH; i = i + 1) begin
            while (b_empty) @(posedge b_clk);
            b_rinc = 1;
            @(posedge b_clk);
            b_rinc = 0;
        end
    end

    // =========================================================
    // STEP 3: B ghi vòng 1 (0→F)
    // =========================================================
    initial begin
        wait(a_rst_n && b_rst_n);
        @(posedge b_clk);
        repeat(10) @(posedge b_clk); // delay A đọc đủ slot
        for (i = 0; i < DEPTH; i = i + 1) begin
            while (b_full) @(posedge b_clk);
            b_wdata = 32'hB000_0000 | i;
            b_winc = 1;
            @(posedge b_clk);
            b_winc = 0;
        end
    end

    // =========================================================
    // STEP 4: A đọc vòng 2 (16→31)
    // =========================================================
    initial begin
        wait(a_rst_n && b_rst_n);
        @(negedge a_clk);
        repeat(15) @(negedge a_clk); // delay propagate
        for (i = 0; i < DEPTH; i = i + 1) begin
            while (a_empty) @(negedge a_clk);
            a_rinc = 1;
            @(negedge a_clk);
            a_rinc = 0;
        end
    end

    // ================= FINISH =================
    initial begin
        while (timeout < 40000) begin
            timeout = timeout + 1;
            @(posedge a_clk);
        end
        $display("Simulation finished after timeout cycles");
        $finish;
    end

endmodule

`default_nettype wire
