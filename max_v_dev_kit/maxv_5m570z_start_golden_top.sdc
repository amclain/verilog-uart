set_time_format -unit ns -decimal_places 3

derive_pll_clocks
derive_clock_uncertainty

create_clock -name CLK_SE_AR -period 100 [get_ports { CLK_SE_AR }]

set_input_delay -clock CLK_SE_AR -max 1 [get_ports AGPIO[2]]
set_input_delay -clock CLK_SE_AR -min 1 [get_ports AGPIO[2]]

set_input_delay -clock CLK_SE_AR -max 1 [get_ports USER_PB0]
set_input_delay -clock CLK_SE_AR -min 1 [get_ports USER_PB0]

set_output_delay -clock CLK_SE_AR -max 1 [get_ports AGPIO[1]]
set_output_delay -clock CLK_SE_AR -min 1 [get_ports AGPIO[1]]

set_output_delay -clock CLK_SE_AR -max 1 [get_ports USER_LED0]
set_output_delay -clock CLK_SE_AR -min 1 [get_ports USER_LED0]
