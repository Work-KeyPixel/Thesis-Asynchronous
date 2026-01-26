create_clock -name WCLK -period 4 [get_ports wclk_raw]
create_clock -name RCLK -period 6 [get_ports rclk_raw]

set_clock_uncertainty 0.2 [all_clocks]

