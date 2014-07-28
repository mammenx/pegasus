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
 -- Module Name       : peg_l2_mac_tx
 -- Author            : mammenx
 -- Associated modules: 
 -- Function          : Wrapper for L2 MAC TX.
 --------------------------------------------------------------------------
*/

`timescale 1ns / 10ps

`inlcude  "pkt_intf_defines.sv"

module peg_l2_mac_tx #(
  parameter PKT_DATA_W        = 8,
  parameter PKT_SIZE_W        = 16
)

(

  input                       clk,
  input                       rst_n,

  //Inputs from L2 MAC RX
  input                       mac_pause_en,

  //MAC Logic Link Control packet interface
  `pkt_intf_ports_s(llc_tx_,,PKT_DATA_W),

  //RS packet interface
  pkt_intf_ports_m(rs_tx_,,PKT_DATA_W)
);

//----------------------- Global parameters Declarations ------------------


//----------------------- Input Declarations ------------------------------


//----------------------- Inout Declarations ------------------------------


//----------------------- Output Declarations -----------------------------


//----------------------- Output Register Declaration ---------------------


//----------------------- Internal Register Declarations ------------------


//----------------------- Internal Wire Declarations ----------------------

//----------------------- Input/Output Registers --------------------------

//----------------------- Start of Code -----------------------------------

  peg_l2_mac_tx_framer #(
    .PKT_DATA_W(PKT_DATA_W),
    .PKT_SIZE_W(PKT_SIZE_W)
  )
    u_l2_mac_tx_framer
  (

    .clk          (clk),
    .rst_n        (rst_n),

    //Config interface
    .config_l2_mac_tx_en          (),
    .config_l2_mac_tx_padding_en  (),
    .config_l2_mac_tx_fcs_en      (),
    .config_l2_mac_addr           (),
    .config_l2_mac_tx_pause_gen   (),
    .config_l2_mac_tx_pause_time  (),

    //Status interface
    .l2_mac_tx_fsm_state          (),

    //Pause Interface from MAC RX
    .mac_pause_en                 (mac_pause_en),

    //MAC Logic Link Control packet interface
    `pkt_intf_port_connect(llc_tx_,,llc_tx_,),

    //RS packet interface
    `pkt_intf_port_connect(rs_tx_,,rs_tx_,)

  );


endmodule // peg_l2_mac_tx


/*
 --------------------------------------------------------------------------

 -- <Header>
 

 -- <Log>

[28-07-2014  04:18:29 PM][mammenx] Created basic wrapper

[28-05-14 20:18:21] [mammenx] Moved log section to bottom of file

 --------------------------------------------------------------------------
*/
