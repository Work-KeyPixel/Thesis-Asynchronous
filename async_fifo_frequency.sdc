create_clock -name wclk -period 4.0 [get_ports wclk]
create_clock -name rclk -period 6.0 [get_ports rclk]

set_clock_uncertainty 0.2 [all_clocks]
