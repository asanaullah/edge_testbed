##LEDs: Red
set_property PACKAGE_PIN G6 [get_ports led_r[0]]
set_property PACKAGE_PIN G3 [get_ports led_r[1]]
set_property PACKAGE_PIN J3 [get_ports led_r[2]]
set_property PACKAGE_PIN K1 [get_ports led_r[3]]
set_property IOSTANDARD LVCMOS33 [get_ports led_r[0]]
set_property IOSTANDARD LVCMOS33 [get_ports led_r[1]]
set_property IOSTANDARD LVCMOS33 [get_ports led_r[2]]
set_property IOSTANDARD LVCMOS33 [get_ports led_r[3]]


##LEDs: Green
set_property PACKAGE_PIN F6 [get_ports led_g[0]]
set_property PACKAGE_PIN J4 [get_ports led_g[1]]
set_property PACKAGE_PIN J2 [get_ports led_g[2]]
set_property PACKAGE_PIN H6 [get_ports led_g[3]]
set_property IOSTANDARD LVCMOS33 [get_ports led_g[0]]
set_property IOSTANDARD LVCMOS33 [get_ports led_g[1]]
set_property IOSTANDARD LVCMOS33 [get_ports led_g[2]]
set_property IOSTANDARD LVCMOS33 [get_ports led_g[3]]


##LEDs: Blue
set_property PACKAGE_PIN E1 [get_ports led_b[0]]
set_property PACKAGE_PIN G4 [get_ports led_b[1]]
set_property PACKAGE_PIN H4 [get_ports led_b[2]]
set_property PACKAGE_PIN K2 [get_ports led_b[3]]
set_property IOSTANDARD LVCMOS33 [get_ports led_b[0]]
set_property IOSTANDARD LVCMOS33 [get_ports led_b[1]]
set_property IOSTANDARD LVCMOS33 [get_ports led_b[2]]
set_property IOSTANDARD LVCMOS33 [get_ports led_b[3]]


##LEDs: Second row
set_property PACKAGE_PIN H5 [get_ports led[0]]
set_property PACKAGE_PIN J5 [get_ports led[1]]
set_property PACKAGE_PIN T9 [get_ports led[2]]
set_property PACKAGE_PIN T10 [get_ports led[3]]
set_property IOSTANDARD LVCMOS33 [get_ports led[0]]
set_property IOSTANDARD LVCMOS33 [get_ports led[1]]
set_property IOSTANDARD LVCMOS33 [get_ports led[2]]
set_property IOSTANDARD LVCMOS33 [get_ports led[3]]


##Switches
set_property PACKAGE_PIN A8 [get_ports sw[0]]
set_property PACKAGE_PIN C11 [get_ports sw[1]]
set_property PACKAGE_PIN C10 [get_ports sw[2]]
set_property PACKAGE_PIN A10 [get_ports sw[3]]
set_property IOSTANDARD LVCMOS33 [get_ports sw[0]]
set_property IOSTANDARD LVCMOS33 [get_ports sw[1]]
set_property IOSTANDARD LVCMOS33 [get_ports sw[2]]
set_property IOSTANDARD LVCMOS33 [get_ports sw[3]]

# Buttons
set_property -dict { PACKAGE_PIN D9    IOSTANDARD LVCMOS33 } [get_ports { btn[0] }]; #IO_L6N_T0_VREF_16 Sch=btn[0]
set_property -dict { PACKAGE_PIN C9    IOSTANDARD LVCMOS33 } [get_ports { btn[1] }]; #IO_L11P_T1_SRCC_16 Sch=btn[1]
set_property -dict { PACKAGE_PIN B9    IOSTANDARD LVCMOS33 } [get_ports { btn[2] }]; #IO_L11N_T1_SRCC_16 Sch=btn[2]
set_property -dict { PACKAGE_PIN B8    IOSTANDARD LVCMOS33 } [get_ports { btn[3] }]; #IO_L12P_T1_MRCC_16 Sch=btn[3]

##Clock Input
set_property PACKAGE_PIN E3 [get_ports clk_i]
set_property IOSTANDARD LVCMOS33 [get_ports clk_i]


##USB-UART Interface 
set_property -dict { PACKAGE_PIN P17 IOSTANDARD LVCMOS33} [get_ports uart_tx]
set_property -dict { PACKAGE_PIN R17 IOSTANDARD LVCMOS33} [get_ports uart_rx]
# set_property PACKAGE_PIN A9 [get_ports uart_rx]
# set_property IOSTANDARD LVCMOS33 [get_ports uart_rx]


##I2C Interface
set_property PACKAGE_PIN M18 [get_ports i2c_sda]
set_property IOSTANDARD LVCMOS33 [get_ports i2c_sda]
set_property PACKAGE_PIN L18   [get_ports i2c_scl]
set_property IOSTANDARD LVCMOS33 [get_ports i2c_scl]
set_property PACKAGE_PIN A14  [get_ports i2c_sda_pup]
set_property IOSTANDARD LVCMOS33 [get_ports i2c_sda_pup]
set_property PACKAGE_PIN A13  [get_ports i2c_scl_pup]
set_property IOSTANDARD LVCMOS33 [get_ports i2c_scl_pup]

create_pblock pblock_cl
add_cells_to_pblock [get_pblocks pblock_cl] [get_cells -quiet [list cl]]
resize_pblock [get_pblocks pblock_cl] -add {SLICE_X8Y105:SLICE_X57Y144}
resize_pblock [get_pblocks pblock_cl] -add {DSP48_X0Y42:DSP48_X1Y57}
resize_pblock [get_pblocks pblock_cl] -add {RAMB18_X0Y42:RAMB18_X1Y57}
resize_pblock [get_pblocks pblock_cl] -add {RAMB36_X0Y21:RAMB36_X1Y28}
set_property CONTAIN_ROUTING 1 [get_pblocks pblock_cl]
set_property EXCLUDE_PLACEMENT 1 [get_pblocks pblock_cl]                              

