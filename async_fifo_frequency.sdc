create_clock -name WCLK -period 4 [get_ports wclk]
create_clock -name RCLK -period 6 [get_ports rclk]

set_clock_uncertainty 0.2 [all_clocks]

