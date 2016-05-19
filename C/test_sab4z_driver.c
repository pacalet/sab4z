#include <stdio.h>
#include <stdlib.h>
#include "libsab4z.h"

int main()
{
	uint32_t data;
	data = sab4z_read_status();
	printf("status register : 0x%08lx\n", data);
	data = sab4z_read_GeneralPurpose();
	printf("General purpose register : 0x%08lx\n", data);
	data = 0x12345678;
	printf("writing some ultra secret code in General purpose register...\n");
	sab4z_write_GeneralPurpose(data);
	data = sab4z_read_GeneralPurpose();
	printf("General purpose register : 0x%08lx\n", data);
	data = sab4z_read_status();
	printf("status register : 0x%08lx\n", data);
}
