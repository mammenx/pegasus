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
 -- Interface Name    : peg_l2_rmii_intf
 -- Author            : mammenx
 -- Function          : The standard 10/100 Mbps RMII interface between
                        MAC & PHY.
 --------------------------------------------------------------------------
*/

interface peg_l2_rmii_intf  (input logic ref_clk);

  //Logic signals
  logic [1:0] txd;
  logic       tx_en;

  logic       rx_er;
  logic       crs_dv;
  logic [1:0] rxd;


  //Wire Signals


  //Tasks & Functions


  //Modports
  modport mac_tx  (
                    output  txd,
                    output  tx_en,
                    input   ref_clk
                  );

  modport mac_rx  (
                    input   rx_er,
                    input   crs_dv,
                    input   rxd,
                    input   ref_clk
                  );

endinterface  //  peg_l2_rmii_intf

/*
 --------------------------------------------------------------------------

 -- <Header>
 

 -- <Log>

[18-06-2014  07:27:24 PM][mammenx] Initial Commit

[28-05-14 20:18:21] [mammenx] Moved log section to bottom of file

 --------------------------------------------------------------------------
*/
