PROJECT = rv_img_proc_demo
VERILOG_TOP = top

.PHONY: all
all:	check_vivado proj ip compile prog sw


.PHONY: hw
hw:	check_vivado proj ip compile prog


.PHONY: check_vivado
check_vivado:
	$(call checkif-installed,vivado,-V)


.PHONY: check_tcls
check_tcls:
	$(call checkfile,./project/tcl/compile.tcl)
	$(call checkfile,./project/tcl/create_ip.tcl)
	$(call checkfile,./project/tcl/create_project.tcl)
	$(call checkfile,./project/tcl/program.tcl)


.PHONY: check_proj
check_proj:
	$(call checkfile,./project/$(PROJECT).xpr)


.PHONY: check_ip
check_ip:
	$(call checkdirectory,./project/$(PROJECT).srcs/sources_1/ip,"Error: IP blocks not generated")


.PHONY: check_compile
check_compile:
	$(call checkfile,./project/$(PROJECT).runs/impl_1/$(VERILOG_TOP).bit)

.PHONY: check_hex
check_hex:
	$(call checkfile,./sw/firmware.hex)


.PHONY: proj
proj: check_vivado check_tcls
	cd project/ && make proj
	
	
.PHONY: ip
ip: check_vivado check_proj	
	cd project/ && make ip
	
.PHONY: compile
compile: check_vivado check_proj check_ip
	cd project/ && make compile
	
	
.PHONY: prog
prog:	check_vivado check_proj check_ip check_compile
	cd project/ && make prog
	
	
.PHONY: sw
sw:
	cd sw/ && make all


.PHONY: load
load:	check_hex
	cd sw/ && make load	
	


define	checkif-installed
	@bash -c '$(1) $(2) < /dev/null >& /dev/null; if ! type "$1" > /dev/null; then echo "Program not found: $(1)"; exit -1; fi'
endef

	
define checkfile
	@bash -c '$(1) < /dev/null >& /dev/null; if [[ ! -f $1 ]]; then echo "File not found: $(1)"; exit -1; fi'
endef
	
	
	
define checkdirectory
	@bash -c '$(1) $(2) < /dev/null >& /dev/null; if [[ ! -d $1 ]]; then echo $2; exit -1; fi'
endef

	
.PHONY: clean
clean:
	cd project/ && make clean
	cd sw/ && make clean
