.PHONY: all
all:	proj ip compile prog


.PHONY: proj
proj:
	vivado -nojournal -nolog -mode batch -source tcl/create_project.tcl


.PHONY: ip
ip:	
	vivado -nojournal -nolog -mode batch -source tcl/create_ip.tcl


.PHONY: update_cl
update_cl:	
	vivado -nojournal -nolog -mode batch -source tcl/update_cl.tcl	
	
	
.PHONY: compile
compile: 
	vivado -nojournal -nolog -mode batch -source tcl/compile.tcl
	
	
.PHONY: prog
prog:
	vivado -nojournal -nolog -mode batch -source tcl/program.tcl
	


.PHONY: clean
clean:
	rm -rf rv_img_proc_demo.*
