.PHONY: all
all:	proj ip compile prog


.PHONY: proj
proj:
	vivado -nojournal -nolog -mode batch -source tcl/create_project.tcl


.PHONY: ip
ip:	
	vivado -nojournal -nolog -mode batch -source tcl/create_ip.tcl


.PHONY: compile
compile: 
	vivado -nojournal -nolog -mode batch -source tcl/compile.tcl
	
	
.PHONY: prog
prog:
	vivado -nojournal -nolog -mode batch -source tcl/program.tcl
	


.PHONY: clean
clean:
	rm -rf rv_comms_proc_demo.*
