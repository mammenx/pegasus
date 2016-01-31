/*
 --------------------------------------------------------------------------
   Pegasus - Copyright (C) 2012 Gregory Matthew James.

   This file is part of Pegasus.

   Pegasus is free; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 3 of the License, or
   (at your option) any later version.

   Pegasus is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program. If not, see <http://www.gnu.org/licenses/>.
 --------------------------------------------------------------------------
*/

/*
 --------------------------------------------------------------------------
 -- Project Code      : pegasus
 -- File Name         : peg_common.c
 -- Author            : mammenx
 -- Description       : This file defines most of the common DPI-C functions
                        used by TB.                        
 --------------------------------------------------------------------------
*/

#include  <stdlib.h>
#include  <math.h>
#include  <stdio.h>
#include  "peg_dpi.h"

unsigned char randByte()  {
  unsigned char res = rand();
  //printf("|c|randByte|res = %d\n",res);
  return  res;
}

void  randBitVec(const svOpenArrayHandle arr) {
  int i;
  unsigned char *bitArr;

  bitArr  = (unsigned char *) svGetArrayPtr(arr);

  for(i=svLow(arr,1); i<svHigh(arr,1); i++)  {
    bitArr[i] = rand();
  }
}

/*
 --------------------------------------------------------------------------

 -- <Header>
 

 -- <Log>

[01-02-2016  12:32:18 AM][mammenx] Added DPI-C randomisation support

 --------------------------------------------------------------------------
*/
