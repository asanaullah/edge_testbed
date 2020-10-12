############################################################
## This file is generated automatically by Vivado HLS.
## Please DO NOT edit it.
## Copyright (C) 1986-2017 Xilinx, Inc. All Rights Reserved.
############################################################
open_project rv_img_proc_demo
set_top customlogic_axi
add_files customlogic_axi.cpp
open_solution "solution1"
set_part {xc7a35ticsg324-1l} -tool vivado
create_clock -period 12 -name default
#source "./custom_logic/solution1/directives.tcl"
#csim_design -compiler gcc
csynth_design
#cosim_design
export_design -format ip_catalog
