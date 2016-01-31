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
 -- Module Name       : peg_l2_rs_rmii
 -- Author            : mammenx
 -- Associated modules: 
 -- Function          : The top level wrapper for RMII reconciliation layer.
 --------------------------------------------------------------------------
*/

`timescale 1ns / 10ps

`include  "pkt_intf_defines.sv"

module peg_l2_rs_rmii #(
  parameter PKT_DATA_W  = 8

)

(
  //--------------------- Misc Ports (Logic)  -----------
  input                       rst_n,

  //Config signals
  input                       config_rs_mii_speed_100_n_10,

  //Packet interface from MAC TX
  `pkt_intf_ports_s(pkt_tx_,,PKT_DATA_W)
  ,

  //Packet interface to MAC RX
  `pkt_intf_ports_m(pkt_rx_,,PKT_DATA_W)
  ,

  //RMII Interface to PHY
  input                       rmii_rx_er,
  input                       rmii_crs_dv,
  input   [1:0]               rmii_rxd,
  output  [1:0]               rmii_txd,
  output                      rmii_tx_en,
  input                       rmii_ref_clk


  //--------------------- Interfaces --------------------

);

//----------------------- Global parameters Declarations ------------------


//----------------------- Input Declarations ------------------------------


//----------------------- Inout Declarations ------------------------------


//----------------------- Output Declarations -----------------------------


//----------------------- Output Register Declaration ---------------------


//----------------------- Internal Register Declarations ------------------


//----------------------- Internal Wire Declarations ----------------------


//----------------------- Internal Interface Declarations -----------------


//----------------------- FSM Declarations --------------------------------


//----------------------- Start of Code -----------------------------------

  /*  TX  */
  peg_l2_rs_rmii_tx#(
    .PKT_DATA_W(PKT_DATA_W)

  ) u_rmii_tx (

    .rst_n                        (rst_n),

    .config_rs_mii_speed_100_n_10 (config_rs_mii_speed_100_n_10),

    `pkt_intf_port_connect(pkt_,,pkt_tx_,)
    ,

    .rmii_txd                     (rmii_txd),
    .rmii_tx_en                   (rmii_tx_en),
    .rmii_ref_clk                 (rmii_ref_clk)

  );


  /*  RX  */
  peg_l2_rs_rmii_rx#(
    .PKT_DATA_W(PKT_DATA_W)

  ) u_rmii_rx (

    .rst_n                        (rst_n),

    .config_rs_mii_speed_100_n_10 (config_rs_mii_speed_100_n_10),

    .rmii_rx_er                   (rmii_rx_er),
    .rmii_crs_dv                  (rmii_crs_dv),
    .rmii_rxd                     (rmii_rxd),
    .rmii_ref_clk                 (rmii_ref_clk),

    `pkt_intf_port_connect(pkt_,,pkt_rx_,)

  );


endmodule // peg_l2_rs_rmii

/*
 --------------------------------------------------------------------------

 -- <Header>
 

 -- <Log>

[31-01-2016  06:13:35 PM][mammenx] Simplified design to handle only byte-streams

[30-06-2014  03:37:45 PM][mammenx] Changed packet data width to 8

[29-06-2014  10:22:22 PM][mammenx] Added size field to packet interface

[28-06-2014  04:42:07 PM][mammenx] Removed System Verilog stuff except fsm enum

[18-06-2014  07:27:24 PM][mammenx] Initial Commit

[28-05-14 20:18:21] [mammenx] Moved log section to bottom of file

 --------------------------------------------------------------------------
*/
