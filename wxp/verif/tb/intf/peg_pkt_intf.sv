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
 -- Interface Name    : peg_pkt_intf
 -- Author            : mammenx
 -- Function          : This interface contains all the signals for transferring
                        packets.
 --------------------------------------------------------------------------
*/

interface peg_pkt_intf  #(parameter WIDTH=8)  (input logic clk, rst_n);

  //Logic signals
  logic             valid;
  logic             sop;
  logic             eop;
  logic [WIDTH-1:0] data;
  logic             ready;
  logic             error;

  //Wire Signals


  //Tasks & Functions


  //Modports


endinterface  //  peg_pkt_intf

/*
 --------------------------------------------------------------------------

 -- <Header>
 

 -- <Log>

[04-02-2016  04:04:33 PM][mammenx] Added peg_pkt_agent & RMII SB

[28-05-14 20:18:21] [mammenx] Moved log section to bottom of file

 --------------------------------------------------------------------------
*/
