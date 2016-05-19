/*
 * This file must be used under the terms of the CeCILL.
 * This source file is licensed as described in the file COPYING, which
 * you should have received as part of this distribution. The terms
 * are also available at
 * http://www.cecill.info/licences/Licence_CeCILL_V2.1-en.txt
 */

#ifndef SAB4Z_H
#define SAB4Z_H
#include <linux/ioctl.h>

typedef struct {
	unsigned long data;
	unsigned long addr;
} access_struct;

#define SAB4Z_READ8 _IOR('s', 1, access_struct *)
#define SAB4Z_WRITE8 _IOWR('s', 2, access_struct *)
#define SAB4Z_READ16 _IOR('s', 3, access_struct *)
#define SAB4Z_WRITE16 _IOWR('s', 4, access_struct *)
#define SAB4Z_READ32 _IOR('s', 5, access_struct *)
#define SAB4Z_WRITE32 _IOWR('s', 6, access_struct *)
#endif
