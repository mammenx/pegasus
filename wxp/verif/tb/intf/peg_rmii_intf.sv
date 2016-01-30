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
 -- Interface Name    : peg_rmii_intf
 -- Author            : mammenx
 -- Function          : This interface contains all the signals in RMII
 --------------------------------------------------------------------------
*/

interface peg_rmii_intf (input logic ref_clk, rst_n);

  //Logic signals
  logic       rx_er;
  logic       crs_dv;
  logic [1:0] rxd;
  logic [1:0] txd;
  logic       tx_en;
 
  //Clocking Blocks
  clocking  cb_tx@(posedge ref_clk);
    default input #2ns output #2ns;

    input       txd;
    input       tx_en;
 
  endclocking : cb_tx

  clocking  cb_rx@(posedge ref_clk);
    default input #2ns output #2ns;

    inout       rx_er;
    inout       crs_dv;
    inout       rxd;
 
  endclocking : cb_rx


  //Modports
  modport TB_TX (clocking cb_tx, input ref_clk,  rst_n);
  modport TB_RX (clocking cb_rx, input ref_clk,  rst_n);


endinterface  //  peg_rmii_intf

/*
 --------------------------------------------------------------------------

 -- <Header>
 

 -- <Log>

[28-05-14 20:18:21] [mammenx] Moved log section to bottom of file

 --------------------------------------------------------------------------
*/
