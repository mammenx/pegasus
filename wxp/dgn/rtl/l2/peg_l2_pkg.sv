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
 -- Package Name      : peg_l2_pkg
 -- Author            : mammenx
 -- Description       : This package contains the different parameters
                        and definitions used in L2 block.
 --------------------------------------------------------------------------
*/

package peg_l2_pkg;

  parameter PREAMBLE_VALUE    = 56'b01010101_01010101_01010101_01010101_01010101_01010101_01010101;
  parameter SFD_VALUE         = 8'b11010101;

  parameter RS_TYPE           = "RMII";


  //802.1 VLAN Tag Control information structure
  typedef struct  packed  {
    logic [2:0]   pcp;
    logic         dei;
    logic [11:0]  vid;
  } vlan_tci_t;

  //MAC Header structure
  typedef struct  packed  {
    logic [47:0]  da;
    logic [47:0]  sa;
    logic [15:0]  len;
    logic [15:0]  ptype;
    vlan_tci_t    vlan_tci;
  } l2_mac_hdr_t;

endpackage  //  peg_l2_pkg

/*
 --------------------------------------------------------------------------

 -- <Header>
 

 -- <Log>

[18-06-2014  08:39:55 PM][mammenx] Added VLAN Tag & MAC Header structure types

[18-06-2014  07:27:24 PM][mammenx] Initial Commit

 --------------------------------------------------------------------------
*/
