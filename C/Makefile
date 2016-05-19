#
# Copyright (C) Telecom ParisTech
# 
# This file must be used under the terms of the CeCILL. This source
# file is licensed as described in the file COPYING, which you should
# have received as part of this distribution. The terms are also
# available at:
# http://www.cecill.info/licences/Licence_CeCILL_V1.1-US.txt
#

export SAB4Z		:= ..
export CROSS_COMPILE	:= arm-buildroot-linux-uclibcgnueabi-
export ARCH		:= arm
export KDIR		:= $(SAB4Z)/build/kernel
OBJS			:= $(wildcard *.o *.ko)
CMDS			:= $(patsubst %,.%.cmd,$(OBJS))
EXECS			:= hello_world sab4z test_sab4z_driver
OTHERS			:= .tmp_versions modules.order Module.symvers sab4z_driver.mod.c

define HELP_message
make help: this message
make foo: compile foo.c
make ARCH=arm KDIR=<path-to-linux-build> sab4z_module: build sab4z module
endef
export HELP_message

ifneq ($(KERNELRELEASE),)

# Kbuild
obj-m  := sab4z_driver.o

else

help:
	@echo "$$HELP_message"

module:
	$(MAKE) -C $(KDIR) M=$(PWD)

all: hello_world sab4z module test_sab4z_driver

%.o: %.c
	$(CROSS_COMPILE)gcc -c -o $@ $<

libsab4z.o: libsab4z.h

hello_world sab4z: %: %.o
	$(CROSS_COMPILE)gcc -o $@ $^

test_sab4z_driver: test_sab4z_driver.o libsab4z.o
	$(CROSS_COMPILE)gcc -o $@ $^

endif

clean :
	rm -rf $(OBJS) $(CMDS) $(EXECS) $(OTHERS)

