create_project -force rv_img_proc_demo . -part xc7a35ticsg324-1L
add_files -scan_for_includes ../hdl/
update_compile_order -fileset sources_1

add_files -fileset constrs_1 ../constraints/arty.xdc
add_files -fileset sim_1 {../sim/ddr3.v ../sim/1024Mb_ddr3_parameters.vh}

