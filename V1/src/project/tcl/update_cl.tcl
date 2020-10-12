open_project rv_img_proc_demo.xpr

update_ip_catalog -rebuild -scan_changes

upgrade_ip -srcset customlogic_axi_0 -vlnv xilinx.com:hls:customlogic_axi:1.0 [get_ips  customlogic_axi_0]


generate_target all [get_files  rv_img_proc_demo.srcs/sources_1/ip/customlogic_axi_0/customlogic_axi_0.xci]

catch { config_ip_cache -export [get_ips -all customlogic_axi_0] }

export_ip_user_files -of_objects [get_files rv_img_proc_demo.srcs/sources_1/ip/customlogic_axi_0/customlogic_axi_0.xci] -no_script -sync -force -quiet

create_ip_run [get_files -of_objects [get_fileset sources_1] rv_img_proc_demo.srcs/sources_1/ip/customlogic_axi_0/customlogic_axi_0.xci]

launch_runs -jobs 24 customlogic_axi_0_synth_1

reset_run impl_1

launch_runs -to_step write_bitstream impl_1 -jobs 24

wait_on_run impl_1
