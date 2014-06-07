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
 -- Interface Name    : peg_pkt_xfr_intf
 -- Author            : mammenx
 -- Function          : This interface contains all the signals needed to
                        transfer packetized data.
 --------------------------------------------------------------------------
*/

interface peg_pkt_xfr_intf  #(
                                parameter DATA_W  = 16
                            )

                            (input logic clk,rst);

  //Logic signals
  logic               sop;
  logic               eop;
  logic               valid;
  logic [DATA_W-1:0]  data;
  logic               ready;

  //Modports
  modport   master  (
                      output  sop,
                      output  eop,
                      output  valid,
                      output  data,
                      input   ready
                    );

  modport   slave   (
                      input   sop,
                      input   eop,
                      input   valid,
                      input   data,
                      output  ready
                    );



endinterface  //  peg_pkt_xfr_intf

/*
 --------------------------------------------------------------------------

 -- <Header>
 

 -- <Log>


 --------------------------------------------------------------------------
*/
