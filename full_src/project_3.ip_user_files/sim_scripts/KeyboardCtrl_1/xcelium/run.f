-makelib xcelium_lib/xil_defaultlib -sv \
  "C:/Xilinx/Vivado/2018.2/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \
-endlib
-makelib xcelium_lib/xpm \
  "C:/Xilinx/Vivado/2018.2/data/ip/xpm/xpm_VCOMP.vhd" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  "../../../../project_3.srcs/sources_1/ip/KeyboardCtrl_1/src/Ps2Interface.v" \
  "../../../../project_3.srcs/sources_1/ip/KeyboardCtrl_1/src/KeyboardCtrl.v" \
  "../../../../project_3.srcs/sources_1/ip/KeyboardCtrl_1/sim/KeyboardCtrl_1.v" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  glbl.v
-endlib

