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

#ifndef SAB4Z_H
#define SAB4Z_H
#include <linux/ioctl.h>

/*
 * Definition of the data structure used by the ioctl to read/write the
 * interface registers of the hardware device.
 */
typedef struct {
	unsigned long data;
	unsigned long addr;
} access_struct;

/* Arbitrary 8-bits integer. Must be used by this software driver *only* for the
 * /dev/sab4z file descriptor. */
#define IOCTL_SAB4Z_TYPE 42

/*
 * ioctl command numbers. 6 commands: read and write of 8-, 16- and 32-bits
 * values.
 */
#define SAB4Z_READ8   _IOR(IOCTL_SAB4Z_TYPE, 1, access_struct *)
#define SAB4Z_WRITE8  _IOW(IOCTL_SAB4Z_TYPE, 2, access_struct *)
#define SAB4Z_READ16  _IOR(IOCTL_SAB4Z_TYPE, 3, access_struct *)
#define SAB4Z_WRITE16 _IOW(IOCTL_SAB4Z_TYPE, 4, access_struct *)
#define SAB4Z_READ32  _IOR(IOCTL_SAB4Z_TYPE, 5, access_struct *)
#define SAB4Z_WRITE32 _IOW(IOCTL_SAB4Z_TYPE, 6, access_struct *)
#endif
