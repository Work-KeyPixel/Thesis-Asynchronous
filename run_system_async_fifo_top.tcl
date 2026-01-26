read_liberty lib/sky130_fd_sc_hd__tt_025C_1v80.lib
read_verilog system_async_fifo_top_sta.v
link_design  system_async_fifo_top

read_sdc async_fifo_frequency.sdc

set_clock_groups -asynchronous \
  -group [get_clocks WCLK] \
  -group [get_clocks RCLK]

report_checks -path_delay max
report_power
