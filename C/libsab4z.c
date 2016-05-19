/*
 * This file must be used under the terms of the CeCILL.
 * This source file is licensed as described in the file COPYING, which
 * you should have received as part of this distribution. The terms
 * are also available at
 * http://www.cecill.info/licences/Licence_CeCILL_V2.1-en.txt
 */

#include "libsab4z.h"
#include <stdio.h>
#include <sys/types.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/ioctl.h>
#include <string.h>

void sab4z_write_GeneralPurpose(uint32_t data)
{
	int fd = open("/dev/sab4z", O_RDWR);
	access_struct acc = {.addr = SAB4Z_GP_ADDR, .data = (unsigned long)(data)};
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

uint32_t sab4z_read_status()
{
	access_struct acc = {.addr = SAB4Z_STATUS_ADDR, .data = 0};
	int fd = open("/dev/sab4z", O_RDWR);
	int ret = 0;
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

uint32_t sab4z_read_GeneralPurpose()
{
	access_struct acc = {.addr = SAB4Z_GP_ADDR, .data = 0};
	int fd = open("/dev/sab4z", O_RDWR);
	int ret = 0;
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

