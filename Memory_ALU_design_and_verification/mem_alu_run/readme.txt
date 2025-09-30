# ----------------------------------------
# Compile & Elaborate
# ----------------------------------------
vcs -sverilog -full64 -timescale=1ns/1ps \
    -f rtl.fs -f dv.fs \
    -l vcs_comp.log \
    -o mem_alu_tb.simv \
    -debug_access+all -kdb -lca

# ----------------------------------------
# Run Simulation (Batch Mode)
# ----------------------------------------
./mem_alu_tb.simv +MSG_VERB=HIGH -ucli -do run.do -l test.log

# ----------------------------------------
# Run Simulation (Interactive GUI with Verdi)
# ----------------------------------------
./mem_alu_tb.simv +MSG_VERB=HIGH -do run_gui.do -verdi &

# ----------------------------------------
# Load Verdi and View Waves Separately
# ----------------------------------------
verdi -ssf waves.fsdb &
