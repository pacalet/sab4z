/*
 * Copyright (C) Telecom ParisTech
 * Copyright (C) Renaud Pacalet (renaud.pacalet@telecom-paristech.fr)
 * 
 * This file must be used under the terms of the CeCILL. This source
 * file is licensed as described in the file COPYING, which you should
 * have received as part of this distribution. The terms are also
 * available at:
 * http://www.cecill.info/licences/Licence_CeCILL_V1.1-US.txt
 */

#include "libsab4z.h"
#include <stdio.h>
#include <sys/types.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/ioctl.h>
#include <string.h>

/* Register addresses, relative to SAB4Z base address. */
#define SAB4Z_STATUS_ADDR 0x0
#define SAB4Z_R_ADDR 0x4

uint32_t sab4z_read_status()
{
	access_struct acc = {.addr = SAB4Z_STATUS_ADDR, .data = 0};
	int fd = open("/dev/sab4z", O_RDONLY);
	if (fd == -1)
	{
		perror("sab4z open");
		return -1;
	}
	if(ioctl(fd, SAB4Z_READ32, &acc) == -1)
	{
		perror("read in sab4z");
	}
	close(fd);
	return (uint32_t)(acc.data);
}

uint32_t sab4z_read_r()
{
	access_struct acc = {.addr = SAB4Z_R_ADDR, .data = 0};
	int fd = open("/dev/sab4z", O_RDONLY);
	if (fd == -1)
	{
		perror("sab4z open");
		return -1;
	}
	if(ioctl(fd, SAB4Z_READ32, &acc) == -1)
	{
		perror("read in sab4z");
	}
	close(fd);
	return (uint32_t)(acc.data);
}

void sab4z_write_r(uint32_t data)
{
	int fd = open("/dev/sab4z", O_WRONLY);
	access_struct acc = {.addr = SAB4Z_R_ADDR, .data = (unsigned long)(data)};
	if (fd == -1)
	{
		perror("sab4z open");
		return;
	}
	if(ioctl(fd, SAB4Z_WRITE32, &acc) == -1)
	{
		perror("write in sab4z");
	}
	close(fd);
}

