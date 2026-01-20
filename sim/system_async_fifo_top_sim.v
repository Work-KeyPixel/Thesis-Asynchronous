`timescale 1ns/1ps

module system_async_fifo_top_sim;

    reg wclk_raw, rclk_raw;
    reg wrst_n, rrst_n;
    reg w_event, r_event;

    wire [7:0] rdata_o;
    wire rempty_o, wfull_o;

    // ================= DUT =================
    system_async_fifo_top dut (
        .wclk_raw (wclk_raw),
        .rclk_raw (rclk_raw),
        .wrst_n   (wrst_n),
        .rrst_n   (rrst_n),
        .w_event  (w_event),
        .r_event  (r_event),
        .rdata_o  (rdata_o),
        .rempty_o (rempty_o),
        .wfull_o  (wfull_o)
    );

    // ============== RAW CLOCKS (ALWAYS RUN) ============
    always #2 wclk_raw = ~wclk_raw; // 250 MHz
    always #3 rclk_raw = ~rclk_raw; // ~166 MHz

    // ============== RESET ==================
    initial begin
        wclk_raw = 0;
        rclk_raw = 0;
        wrst_n   = 0;
        rrst_n   = 0;
        w_event  = 0;
        r_event  = 0;
        #20;
        wrst_n   = 1;
        rrst_n   = 1;
    end

    // ============== WRITE EVENTS ===========
    initial begin
        #40;
        forever begin
            w_event = 1;
            #200;          // active window
            w_event = 0;
            #2000;         // idle window
        end
    end

    // ============== READ EVENTS ============
    initial begin
        #80;
        forever begin
            r_event = 1;
            #160;
            r_event = 0;
            #2400;
        end
    end

    // ============== VCD ====================
    initial begin
        $dumpfile("system_async_fifo_top_power.vcd");
        #30;
        $dumpvars(0, dut);
        #50000;
        $finish;
    end

    // ============== DEBUG ==================
    initial begin
        #50000;
        $display("ASYNC producer active cycles = %0d",
                 dut.u_prod.active_cycles);
        $display("ASYNC consumer active cycles = %0d",
                 dut.u_cons.active_cycles);
    end

endmodule
