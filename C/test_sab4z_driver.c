/*
 * Copyright (C) Telecom ParisTech
 * 
 * This file must be used under the terms of the CeCILL. This source
 * file is licensed as described in the file COPYING, which you should
 * have received as part of this distribution. The terms are also
 * available at:
 * http://www.cecill.info/licences/Licence_CeCILL_V1.1-US.txt
*/

/* Example user-space application making use of the libsab4z library. */

#include <stdio.h>
#include <stdlib.h>
#include "libsab4z.h"

int main()
{
	uint32_t data;

	data = sab4z_read_status();
	printf("STATUS register: 0x%08lx\n", data);
	data = sab4z_read_r();
	printf("R register:      0x%08lx\n", data);
	data = 0x42424242;
	printf("Writing 0x%08lx to R register...\n", data);
	sab4z_write_r(data);
	data = sab4z_read_r();
	printf("R register:      0x%08lx\n", data);
	data = sab4z_read_status();
	printf("status register: 0x%08lx\n", data);
}
