#
# Copyright (C) Telecom ParisTech
# 
# This file must be used under the terms of the CeCILL. This source
# file is licensed as described in the file COPYING, which you should
# have received as part of this distribution. The terms are also
# available at:
# http://www.cecill.info/licences/Licence_CeCILL_V1.1-US.txt
#

proc usage {} {
	puts "usage: vivado -mode batch -source <script> -tclargs <rootdir> <builddir> \[<board>\] \[<ila>\]"
	puts "  <rootdir>:  absolute path of sab4z root directory"
	puts "  <builddir>: absolute path of build directory"
	puts "  <board>:    target board (zybo, zed, zc706 or zcu102, default zybo)"
	puts "  <ila>:      embed Integrated Logic Analyzer (0 or 1, default 0)"
	exit -1
}

if { $argc == 4 } {
	set rootdir [lindex $argv 0]
	set builddir [lindex $argv 1]
	set board [lindex $argv 2]
	set psname "*xilinx.com:ip:zynq_ultra_ps_e:*"
	set bdrule "xilinx.com:bd_rule:zynq_ultra_ps_e"
	set frequency 300
	if { [ string equal $board "zcu102" ] } { 
		set part "xczu9eg-ffvb1156-2-i"
		set board "xilinx.com:zcu102:part0:3.0"
		array set ios {
			"sw[0]"         { "AN14" "LVCMOS33" }
			"sw[1]"         { "AP14" "LVCMOS33" }
			"sw[2]"         { "AM14" "LVCMOS33" }
			"sw[3]"         { "AN13" "LVCMOS33" }
			"sw[4]"         { "AN12" "LVCMOS33" }
			"sw[5]"         { "AP12" "LVCMOS33" }
			"sw[6]"         { "AL13" "LVCMOS33" }
			"sw[7]"         { "AK13" "LVCMOS33" }
			"led[0]"        { "AG14" "LVCMOS33" }
			"led[1]"        { "AF13" "LVCMOS33" }
			"led[2]"        { "AE13" "LVCMOS33" }
			"led[3]"        { "AJ14" "LVCMOS33" }
			"led[4]"        { "AJ15" "LVCMOS33" }
			"led[5]"        { "AH13" "LVCMOS33" }
			"led[6]"        { "AH14" "LVCMOS33" }
			"led[7]"        { "AL12" "LVCMOS33" }
			"btn"           { "AG13" "LVCMOS33" }
		}
	} else {
		usage
	}
	set ila [lindex $argv 3]
	if { $ila != 0 && $ila != 1 } {
		usage
	}
	puts "*********************************************"
	puts "Summary of build parameters"
	puts "*********************************************"
	puts "Board: $board"
	puts "Part: $part"
	puts "Root directory: $rootdir"
	puts "Build directory: $builddir"
	puts -nonewline "Integrated Logic Analyzer: "
	if { $ila == 0 } {
		puts "no"
	} else {
		puts "yes"
	}
	puts "*********************************************"
} else {
	usage
}

cd $builddir
source $rootdir/scripts/ila.tcl

###################
# Create SAB4U IP #
###################
create_project -part $part -force sab4u sab4u
add_files $rootdir/hdl/axi64_pkg.vhd $rootdir/hdl/debouncer.vhd $rootdir/hdl/sab4u.vhd
import_files -force -norecurse
ipx::package_project -root_dir sab4u -vendor www.telecom-paristech.fr -library SAB4U -force sab4u
close_project

############################
## Create top level design #
############################
set top top
create_project -part $part -force $top .
set_property board_part $board [current_project]
set_property ip_repo_paths { ./sab4u } [current_fileset]
update_ip_catalog
create_bd_design "$top"
set sab4u [create_bd_cell -type ip -vlnv [get_ipdefs *www.telecom-paristech.fr:SAB4U:sab4u:*] sab4u]
set ps [create_bd_cell -type ip -vlnv [get_ipdefs $psname] ps]
apply_bd_automation -rule xilinx.com:bd_rule:zynq_ultra_ps_e -config {apply_board_preset "1" } $ps
set_property -dict [list CONFIG.PSU__CRL_APB__PL0_REF_CTRL__FREQMHZ [list $frequency]] $ps
set_property -dict [list CONFIG.PSU__MAXIGP0__DATA_WIDTH {64}] $ps
set_property -dict [list CONFIG.PSU__MAXIGP1__DATA_WIDTH {64}] $ps
set_property -dict [list CONFIG.PSU__USE__S_AXI_GP2 {1}] $ps
set_property -dict [list CONFIG.PSU__SAXIGP2__DATA_WIDTH {64}] $ps

# Interconnections
# Primary IOs
create_bd_port -dir O -from 7 -to 0 led
connect_bd_net [get_bd_pins /sab4u/led] [get_bd_ports led]
create_bd_port -dir I -from 7 -to 0 sw
connect_bd_net [get_bd_pins /sab4u/sw] [get_bd_ports sw]
create_bd_port -dir I btn
connect_bd_net [get_bd_pins /sab4u/btn] [get_bd_ports btn]
# ps - sab4u
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/ps/M_AXI_HPM0_FPD" intc_ip "Auto" Clk_xbar "/ps/pl_clk0" Clk_master "/ps/pl_clk0" Clk_slave "/ps/pl_clk0" } [get_bd_intf_pins sab4u/s0_axi]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/ps/M_AXI_HPM1_FPD" intc_ip "Auto" Clk_xbar "/ps/pl_clk0" Clk_master "/ps/pl_clk0" Clk_slave "/ps/pl_clk0" } [get_bd_intf_pins sab4u/s1_axi]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/sab4u/m_axi" intc_ip "Auto" Clk_xbar "/ps/pl_clk0" Clk_master "/ps/pl_clk0" Clk_slave "/ps/pl_clk0" } [get_bd_intf_pins ps/S_AXI_HP0_FPD]
#
## Addresses ranges
set_property offset 0x2000000000 [get_bd_addr_segs {ps/Data/SEG_sab4u_reg0}]
set_property offset 0x6000000000 [get_bd_addr_segs {ps/Data/SEG_sab4u_reg01}]
set_property offset 0x0000000000 [get_bd_addr_segs {sab4u/m_axi/SEG_ps_HP0_DDR_LOW}]
set_property range 4K [get_bd_addr_segs {ps/Data/SEG_sab4u_reg0}]
set_property range 2G [get_bd_addr_segs {ps/Data/SEG_sab4u_reg01}]
set_property range 2G [get_bd_addr_segs {sab4u/m_axi/SEG_ps_HP0_DDR_LOW}]

# In-circuit debugging
if { $ila == 1 } {
	set_property HDL_ATTRIBUTE.MARK_DEBUG true [get_bd_intf_nets -of_objects [get_bd_intf_pins /sab4u/m_axi]]
}

# Synthesis flow
validate_bd_design
set files [get_files *$top.bd]
generate_target all $files
add_files -norecurse -force [make_wrapper -files $files -top]
save_bd_design
set run [get_runs synth*]
set_property STEPS.SYNTH_DESIGN.ARGS.FLATTEN_HIERARCHY none $run
launch_runs $run
wait_on_run $run
open_run $run

# In-circuit debugging
if { $ila == 1 } {
	set topcell [get_cells $top*]
	set nets {}
	set suffixes {
		ARID ARADDR ARLEN ARSIZE ARBURST ARLOCK ARCACHE ARPROT ARQOS ARVALID
		RREADY
		AWID AWADDR AWLEN AWSIZE AWBURST AWLOCK AWCACHE AWPROT AWQOS AWVALID
		WDATA WSTRB WLAST WVALID
		BREADY
		ARREADY
		RID RDATA RRESP RLAST RVALID
		AWREADY
		WREADY
		BID BRESP BVALID
	}
	foreach suffix $suffixes {
		lappend nets $topcell/sab4u_m_axi_${suffix}
	}
	add_ila_core dc $topcell/ps7_FCLK_CLK0 $nets
}

# IOs
foreach io [ array names ios ] {
	set pin [ lindex $ios($io) 0 ]
	set std [ lindex $ios($io) 1 ]
	set_property package_pin $pin [get_ports $io]
	set_property iostandard $std [get_ports [list $io]]
}

# Timing constraints
set clock [get_clocks]
set_false_path -from $clock -to [get_ports {led[*]}]
set_false_path -from [get_ports {btn sw[*]}] -to $clock

# Implementation
save_constraints
set run [get_runs impl*]
reset_run $run
set_property STEPS.WRITE_BITSTREAM.ARGS.BIN_FILE true $run
launch_runs -to_step write_bitstream $run
wait_on_run $run

# Messages
set rundir ${builddir}/$top.runs/$run
puts ""
puts "*********************************************"
puts "\[VIVADO\]: done"
puts "*********************************************"
puts "Summary of build parameters"
puts "*********************************************"
puts "Board: $board"
puts "Part: $part"
puts "Root directory: $rootdir"
puts "Build directory: $builddir"
puts -nonewline "Integrated Logic Analyzer: "
if { $ila == 0 } {
	puts "no"
} else {
	puts "yes"
}
puts "*********************************************"
puts "  bitstream in $rundir/${top}_wrapper.bit"
puts "  resource utilization report in $rundir/${top}_wrapper_utilization_placed.rpt"
puts "  timing report in $rundir/${top}_wrapper_timing_summary_routed.rpt"
puts "*********************************************"
