#
# Copyright (C) Telecom ParisTech
# Copyright (C) Renaud Pacalet (renaud.pacalet@telecom-paristech.fr)
# 
# This file must be used under the terms of the CeCILL. This source
# file is licensed as described in the file COPYING, which you should
# have received as part of this distribution. The terms are also
# available at:
# http://www.cecill.info/licences/Licence_CeCILL_V1.1-US.txt
#

.NOTPARALLEL:

#############
# Variables #
#############

# General purpose
DEBUG	?= 1
SHELL	:= /bin/bash

ifeq ($(DEBUG),0)
OUTPUT	:= &> /dev/null
else ifeq ($(DEBUG),1)
OUTPUT	:= > /dev/null
else
OUTPUT	:=
endif

rootdir		:= $(realpath .)
BUILD		?= /tmp/sab4z.builds
HDLDIR		:= hdl
HDLSRCS		:= $(addprefix $(HDLDIR)/,axi_pkg.vhd debouncer.vhd sab4z.vhd)
HDLSRCS64	:= $(addprefix $(HDLDIR)/,axi64_pkg.vhd debouncer.vhd sab4u.vhd)
SCRIPTS		:= scripts

# Mentor Graphics Modelsim
MSBUILD		?= $(BUILD)/ms
MSCONFIG	:= $(MSBUILD)/modelsim.ini
MSLIB		:= vlib
MSMAP		:= vmap
MSCOM		:= vcom
MSCOMFLAGS	:= -ignoredefaultbinding -nologo -quiet -2002
MSSIM		:= vsim
MSSIMFLAGS	:= -c -voptargs="+acc" -do 'run -all; quit'
MSTAGS		:= $(patsubst $(HDLDIR)/%.vhd,$(MSBUILD)/%.tag,$(HDLSRCS))

# Xilinx Vivado
ILA		?= 0
VVMODE		?= batch
VIVADO		:= vivado

VVBUILD		?= $(BUILD)/vv
VVSCRIPT	:= $(SCRIPTS)/vvsyn.tcl
# Supported boards: zybo, zed, zc706
VVBOARD		?= zybo
VIVADOFLAGS	:= -mode $(VVMODE) -notrace -source $(VVSCRIPT) -tempDir /tmp -journal $(VVBUILD)/vivado.jou -log $(VVBUILD)/vivado.log -tclargs $(rootdir) $(VVBUILD) $(VVBOARD) $(ILA)
VVIMPL		:= $(VVBUILD)/top.runs/impl_1
VVBIT		:= $(VVIMPL)/top_wrapper.bit

VVBUILD64	?= $(BUILD)/vv64
VVSCRIPT64	:= $(SCRIPTS)/vvsyn64.tcl
# Supported boards: zcu102
VVBOARD64	?= zcu102
VIVADOFLAGS64	:= -mode $(VVMODE) -notrace -source $(VVSCRIPT64) -tempDir /tmp -journal $(VVBUILD64)/vivado.jou -log $(VVBUILD64)/vivado.log -tclargs $(rootdir) $(VVBUILD64) $(VVBOARD64) $(ILA)
VVIMPL64	:= $(VVBUILD64)/top.runs/impl_1
VVBIT64		:= $(VVIMPL64)/top_wrapper.bit

# Software Design Kits
XDTS			?= /opt/downloads/device-tree-xlnx
HSI			:= hsi
SYSDEF			:= $(VVIMPL)/top_wrapper.sysdef
SYSDEF64		:= $(VVIMPL64)/top_wrapper.sysdef
DTSSCRIPT		:= $(SCRIPTS)/dts.tcl
DTSFLAGS		:= -mode batch -quiet -notrace -nojournal -nolog -tempDir /tmp
DTSBUILD		?= $(BUILD)/dts
DTSTOP			:= $(DTSBUILD)/system.dts
FSBLSCRIPT		:= $(SCRIPTS)/fsbl.tcl
FSBLFLAGS		:= -mode batch -quiet -notrace -nojournal -nolog -tempDir /tmp
FSBLBUILD		?= $(BUILD)/fsbl
FSBLTOP			:= $(FSBLBUILD)/main.c

# Messages
define HELP_message
make targets:
  make help       print this message (default goal)
  make ms-all     compile all VHDL source files with Modelsim ($(MSBUILD))
  make ms-sim     simulate SAB4Z with Modelsim
  make ms-clean   delete all files and directories automatically created by Modelsim
  make vv-all     synthesize 32 bits design with Vivado ($(VVBUILD))
  make vv-clean   delete all 32 bits files and directories automatically created by Vivado
  make vv64-all   synthesize 64 bits design with Vivado ($(VVBUILD))
  make vv64-clean delete all 64 bits files and directories automatically created by Vivado
  make dts        generate device tree sources ($(DTSBUILD))
  make dts-clean  delete device tree sources
  make fsbl       generate First Stage Boot Loader (FSBL) sources ($(FSBLBUILD))
  make fsbl-clean delete FSBL sources
  make doc        generate documentation images
  make doc-clean  delete generated documentation images
  make clean      delete all automatically created files and directories

directories:
  hdl sources          ./$(HDLDIR)
  build                $(BUILD)
  Modelsim build       $(MSBUILD)
  Vivado 32 bits build $(VVBUILD)
  Vivado 64 bits build $(VVBUILD64)
  Device Tree Sources  $(DTSBUILD)
  FSBL sources         $(FSBLBUILD)

customizable make variables:
  DEBUG       debug level: 0=none, 1: some, 2: verbose ($(DEBUG))
  BUILD       main build directory ($(BUILD))
  MSBUILD     build directory for Mentor Graphics Modelsim ($(MSBUILD))
  ILA         embed Integrated Logic Analyzer (0 or 1) ($(ILA))"
  VVMODE      Vivado running mode (gui, tcl or batch) ($(VVMODE))"
  VVBUILD     build directory for Xilinx Vivado ($(VVBUILD))
  VVBOARD     target board (zybo, zed or zc706) ($(VVBOARD))"
  VVBUILD64   build directory for Xilinx Vivado ($(VVBUILD64))
  VVBOARD64   target board (zybo, zed or zc706) ($(VVBOARD64))"
  XDTS        clone of Xilinx device trees git repository ($(XDTS))
  DTSBUILD    build directory for the device tree ($(DTSBUILD))
  FSBLBUILD   build directory for the First Stage Boot Loader ($(FSBLBUILD))
endef
export HELP_message

################
# Make targets #
################

# Help
help:
	@echo "$$HELP_message"

# Mentor Graphics Modelsim
ms-all: $(MSTAGS)

$(MSTAGS): $(MSBUILD)/%.tag: $(HDLDIR)/%.vhd
	@echo '[MSCOM] $<' && \
	cd $(MSBUILD) && \
	$(MSCOM) $(MSCOMFLAGS) $(rootdir)/$< && \
	touch $@

$(MSTAGS): $(MSCONFIG)

$(MSCONFIG):
	@echo '[MKDIR] $(MSBUILD)' && \
	mkdir -p $(MSBUILD) && \
	cd $(MSBUILD) && \
	$(MSLIB) .work $(OUTPUT) && \
	$(MSMAP) work .work $(OUTPUT)

$(MSBUILD)/sab4z_sim.tag: $(MSBUILD)/sab4z.tag

.PHONY: sim

ms-sim: $(MSBUILD)/sab4z_sim.tag
	@echo '[MSSIM] $<' && \
	cd $(MSBUILD) && \
	$(MSSIM) $(MSSIMFLAGS) work.sab4z_sim

ms-clean:
	@echo '[RM] $(MSBUILD)' && \
	rm -rf $(MSBUILD)

# Xilinx Vivado
vv-all: $(VVBIT)

$(VVBIT): $(HDLSRCS) $(VVSCRIPT)
	@echo '[VIVADO] $(VVSCRIPT)' && \
	mkdir -p $(VVBUILD) && \
	$(VIVADO) $(VIVADOFLAGS)

$(SYSDEF):
	@$(MAKE) vv-all

vv-clean:
	@echo '[RM] $(VVBUILD)' && \
	rm -rf $(VVBUILD)

vv64-all: $(VVBIT64)

$(VVBIT64): $(HDLSRCS64) $(VVSCRIPT64)
	@echo '[VIVADO] $(VVSCRIPT64)' && \
	mkdir -p $(VVBUILD64) && \
	$(VIVADO) $(VIVADOFLAGS64)

$(SYSDEF64):
	@$(MAKE) vv64-all

vv64-clean:
	@echo '[RM] $(VVBUILD64)' && \
	rm -rf $(VVBUILD64)

# Device tree
dts: $(DTSTOP)

$(DTSTOP): $(SYSDEF) $(DTSSCRIPT)
	@if [ ! -d $(XDTS) ]; then \
		echo 'Xilinx device tree source directory $(XDTS) not found.' && \
		exit -1; \
	fi && \
	echo '[HSI] $< --> $(DTSBUILD)' && \
	$(HSI) $(DTSFLAGS) -source $(DTSSCRIPT) -tclargs $(SYSDEF) $(XDTS) $(DTSBUILD) $(OUTPUT)

dts-clean:
	@echo '[RM] $(DTSBUILD)' && \
	rm -rf $(DTSBUILD)

# First Stage Boot Loader (FSBL)
fsbl: $(FSBLTOP)

$(FSBLTOP): $(SYSDEF) $(FSBLSCRIPT)
	@echo '[HSI] $< --> $(FSBLBUILD)' && \
	$(HSI) $(FSBLFLAGS) -source $(FSBLSCRIPT) -tclargs $(SYSDEF) $(FSBLBUILD) $(OUTPUT)

fsbl-clean:
	@echo '[RM] $(FSBLBUILD)' && \
	rm -rf $(FSBLBUILD)

# Documentation
FIG2DEV		:= fig2dev
FIG2DEVFLAGS	:= -Lpng -m2.0 -S4
FIGS		:= $(wildcard images/*.fig)
PNGS		:= $(patsubst %.fig,%.png,$(FIGS))

doc: $(PNGS)

$(PNGS): %.png: %.fig
	$(FIG2DEV) $(FIG2DEVFLAGS) $< $@

doc-clean:
	@echo '[RM] $(PNGS)' && \
	rm -rf $(PNGS)

# Full clean
clean: ms-clean vv-clean vv64-clean dts-clean fsbl-clean
