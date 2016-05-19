/*
 * This file must be used under the terms of the CeCILL.
 * This source file is licensed as described in the file COPYING, which
 * you should have received as part of this distribution. The terms
 * are also available at
 * http://www.cecill.info/licences/Licence_CeCILL_V2.1-en.txt
 */

#ifndef LIBSAB4Z_H
#define LIBSAB4Z_H
#include "sab4z_driver.h"
#include <stdint.h>

// Those 2 addresses are relative to the base address of sab4z
#define SAB4Z_STATUS_ADDR 0x0
#define SAB4Z_GP_ADDR 0x4

void sab4z_write_GeneralPurpose(uint32_t data);
uint32_t sab4z_read_status();
uint32_t sab4z_read_GeneralPurpose();
#endif
