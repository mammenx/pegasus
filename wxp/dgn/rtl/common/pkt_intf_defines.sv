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
 -- Module Name       : pkt_intf_defines
 -- Author            : mammenx
 -- Associated modules: 
 -- Function          : This file contains definitions for packet interface
                        to be used for wiring & connecting ports.
 --------------------------------------------------------------------------
*/

`ifndef __PKT_INTF_DEFINES
`define __PKT_INTF_DEFINES

  //To build port list in module definition
  `define pkt_intf_ports_m(prefix,suffix,WIDTH) \
            output              prefix``valid``suffix,\
            output              prefix``sop``suffix,\
            output              prefix``eop``suffix,\
            output  [WIDTH-1:0] prefix``data``suffix,\
            input               prefix``ready``suffix,\
            output              prefix``error``suffix

  `define pkt_intf_ports_s(prefix,suffix,WIDTH) \
            input               prefix``valid``suffix,\
            input               prefix``sop``suffix,\
            input               prefix``eop``suffix,\
            input  [WIDTH-1:0]  prefix``data``suffix,\
            output              prefix``ready``suffix,\
            input               prefix``error``suffix

  //For creating wires
  `define pkt_intf_wires(prefix,suffix,WIDTH) \
            wire               prefix``valid``suffix;\
            wire               prefix``sop``suffix;\
            wire               prefix``eop``suffix;\
            wire  [WIDTH-1:0]  prefix``data``suffix;\
            wire               prefix``ready``suffix;\
            wire               prefix``error``suffix;

  //FOr connecting ports
  `define pkt_intf_port_connect(port_prefix,port_suffix,wire_prefix,wire_suffix) \
            .port_prefix``valid``port_suffix  (wire_prefix``valid``wire_suffix),\
            .port_prefix``sop``port_suffix    (wire_prefix``sop``wire_suffix),\
            .port_prefix``eop``port_suffix    (wire_prefix``eop``wire_suffix),\
            .port_prefix``data``port_suffix   (wire_prefix``data``wire_suffix),\
            .port_prefix``ready``port_suffix  (wire_prefix``ready``wire_suffix),\
            .port_prefix``error``port_suffix  (wire_prefix``error``wire_suffix)


`endif

/*
 --------------------------------------------------------------------------

 -- <Header>
 

 -- <Log>

[28-07-2014  01:52:09 PM][mammenx] Removed WIDTH from pkt_intf_port_connect macro

[28-07-2014  01:50:55 PM][mammenx] Initial Commit


 --------------------------------------------------------------------------
*/
