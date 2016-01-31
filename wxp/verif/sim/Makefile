
TEST_NAME=peg_rmii_l2_test

TB_TOP=peg_rmii_tb_top

DGN_LIB=dgn.lib
LINT_OPT=-lint
PREPROCESS_OPT=
#PREPROCESS_OPT=-Epretty dgn.preprocess.v

MSIM_DIR=/altera/modelsim/6.5e/modelsim_ase
MSIM_INC_DIR=$(MSIM_DIR)/include
MSIM_WIN32_DIR=$(MSIM_DIR)/linuxaloem

all: clean show_dir dgn tb dpi dll sim

clean:
	rm -rf work
	rm -rf logs
	rm -f *.ini transcript* *.wlf *.obj *.log *.h *.v *.dll *.so *.ppm *.raw *.gif
	rm -rf $(DGN_LIB)
	mkdir logs
	vlib work
	vmap work work

show_dir:
	echo  MSIM_DIR : $(MSIM_DIR)
	echo  MSIM_INC_DIR : $(MSIM_INC_DIR)
	echo  MSIM_WIN32_DIR : $(MSIM_WIN32_DIR)

git:
	rm -rf work
	rm -rf logs
	rm -rf snaps
	rm -f *.ini transcript* *.wlf *.obj *.log *.h *.dll *.so *.ppm *.raw
	rm -rf $(DGN_LIB)

dgn_lib:
	echo	"Compiling RTL into $(DGN_LIB) library"
	vlib $(DGN_LIB)
	vmap $(DGN_LIB) work
	vlog -work $(DGN_LIB) -sv +define+SIMULATION	-f dgn.list -timescale "1ns / 10ps" $(LINT_OPT) $(PREPROCESS_OPT) | tee dgn.vlog.log

dgn:
	echo	"Compiling RTL"
	vlog +define+SIMULATION -incr -sv -f dgn.list -timescale "1ns / 10ps" $(LINT_OPT) $(PREPROCESS_OPT) | tee dgn.vlog.log

tb:
	echo "Compiling TB"
	vlog -f verif.list +define+SIMULATION -sv -incr -timescale "1ns / 10ps"  | tee	tb.vlog.log

dpi:
	echo  Compiling DPI-C files

dll:
	echo  Building DLLs

sim:
	echo  Running test : $(TEST_NAME)
	vsim -c -novopt +OVM_TESTNAME=$(TEST_NAME) $(TB_TOP) +define+SIMULATION -l $(TEST_NAME).vsim.log -permit_unmatched_virtual_intf -do "set WildcardFilter none;add wave -r /*;run -all;radix -hex" -suppress 8233

gui:
	vsim -do "radix -hex" vsim.wlf
