/*
 * This file must be used under the terms of the CeCILL.
 * This source file is licensed as described in the file COPYING, which
 * you should have received as part of this distribution. The terms
 * are also available at
 * http://www.cecill.info/licences/Licence_CeCILL_V2.1-en.txt
 */

/* SAB4Z software library. Provides functions to interact with the interface
 * registers of SAB4Z. */

#ifndef LIBSAB4Z_H
#define LIBSAB4Z_H

#include "sab4z_driver.h"
#include <stdint.h>

uint32_t
sab4z_read_status();

uint32_t
sab4z_read_r();

void
sab4z_write_r(uint32_t data);

#endif
