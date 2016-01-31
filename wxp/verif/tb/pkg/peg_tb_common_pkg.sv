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
 -- Package Name      : peg_tb_common_pkg
 -- Author            : mammenx
 -- Description       : This package contains common resources used by TB.
 --------------------------------------------------------------------------
*/

package peg_tb_common_pkg;

  //Parameters
  parameter PEG_MAX_FIELD_LEN = 256;

  //DPI-C functions
  import  "DPI-C" function void randBitVec(inout bit arr []);
  import  "DPI-C" function byte unsigned  randByte();

  //Data Types
  typedef bit [PEG_MAX_FIELD_LEN-1:0]  peg_integral_t;

endpackage  //  peg_tb_common_pkg

/*
 --------------------------------------------------------------------------

 -- <Header>
 

 -- <Log>

[01-02-2016  12:32:18 AM][mammenx] Added DPI-C randomisation support

 --------------------------------------------------------------------------
*/
