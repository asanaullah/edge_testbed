open_project rv_img_proc_demo.xpr

set_property  ip_repo_paths ../hls/rv_img_proc_demo/solution1/impl/ip  [current_project]

create_ip -name clk_wiz -vendor xilinx.com -library ip -module_name clk_wiz_0
set_property -dict [list CONFIG.CLKOUT2_USED {true} CONFIG.CLKOUT3_USED {true} CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {166.667} CONFIG.CLKOUT3_REQUESTED_OUT_FREQ {200.000} CONFIG.USE_RESET {false} CONFIG.MMCM_DIVCLK_DIVIDE {1} CONFIG.MMCM_CLKOUT0_DIVIDE_F {6.000} CONFIG.MMCM_CLKOUT1_DIVIDE {10} CONFIG.MMCM_CLKOUT2_DIVIDE {5} CONFIG.NUM_OUT_CLKS {3} CONFIG.CLKOUT1_JITTER {118.758} CONFIG.CLKOUT2_JITTER {130.958} CONFIG.CLKOUT2_PHASE_ERROR {98.575} CONFIG.CLKOUT3_JITTER {114.829} CONFIG.CLKOUT3_PHASE_ERROR {98.575}] [get_ips clk_wiz_0]

create_ip -name mig_7series -vendor xilinx.com -library ip  -module_name mig_7series_0
set_property -dict [list CONFIG.XML_INPUT_FILE {../../../../../ip/mig_params.prj}] [get_ips mig_7series_0]

