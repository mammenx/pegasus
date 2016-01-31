
TEST_NAME=peg_rmii_l2_test

TB_TOP=peg_rmii_tb_top

DGN_LIB=dgn.lib
LINT_OPT=-lint
PREPROCESS_OPT=
#PREPROCESS_OPT=-Epretty dgn.preprocess.v

MSIM_DIR=/altera/modelsim/6.5e/modelsim_ase
MSIM_INC_DIR=$(MSIM_DIR)/include
MSIM_WIN32_DIR=$(MSIM_DIR)/linuxaloem

#Uncomment this to generate sv_dpi.h
#DPI_HDR_GEN_OPTS=\
-dpiheader peg_dpi.h \

all: clean show_dir dgn tb dpi dll sim

clean:
	rm -rf work
	rm -rf logs
	rm -rf obj
	rm -f *.ini transcript* *.wlf *.obj *.log *.h *.v *.dll *.so *.ppm *.raw *.gif
	rm -rf $(DGN_LIB)
	mkdir logs
	mkdir obj
	vlib work
	vmap work work

show_dir:
	@echo  MSIM_DIR : $(MSIM_DIR)
	@echo  MSIM_INC_DIR : $(MSIM_INC_DIR)
	@echo  MSIM_WIN32_DIR : $(MSIM_WIN32_DIR)

git:
	rm -rf work
	rm -rf logs
	rm -rf snaps
	rm -f *.ini transcript* *.wlf *.obj *.log *.h *.dll *.so *.ppm *.raw
	rm -rf $(DGN_LIB)

dgn_lib:
	@echo	"Compiling RTL into $(DGN_LIB) library"
	vlib $(DGN_LIB)
	vmap $(DGN_LIB) work
	vlog -work $(DGN_LIB) -sv +define+SIMULATION	-f dgn.list -timescale "1ns / 10ps" $(LINT_OPT) $(PREPROCESS_OPT) | tee dgn.vlog.log

dgn:
	@echo	"Compiling RTL"
	vlog +define+SIMULATION -incr -sv -f dgn.list -timescale "1ns / 10ps" $(LINT_OPT) $(PREPROCESS_OPT) | tee dgn.vlog.log

tb:
	@echo "Compiling TB"
	vlog -f verif.list +define+SIMULATION $(DPI_HDR_GEN_OPTS) -sv -incr -timescale "1ns / 10ps"  | tee	tb.vlog.log


dpi:
	@echo  Compiling DPI-C files
	gcc -m32 -c -g -fPIC ../tb/dpi/peg_common.c -I$(MSIM_INC_DIR) -o ./obj/peg_common.obj

dll:
	@echo  Building DLLs
	gcc -m32 -shared -g -Bsymbolic -I. -I$(MSIM_INC_DIR) -L. -L./obj  -L../tb/dpi -L$(MSIM_WIN32_DIR) -o peg_dpi_lib.so ./obj/peg_common.obj

sim:
	@echo  Running test : $(TEST_NAME)
	vsim -c -novopt +OVM_TESTNAME=$(TEST_NAME) $(TB_TOP) -sv_lib peg_dpi_lib +define+SIMULATION -l $(TEST_NAME).vsim.log -permit_unmatched_virtual_intf -do "set WildcardFilter none;add wave -r /*;run -all;radix -hex" -suppress 8233

gui:
	vsim -do "radix -hex" vsim.wlf
