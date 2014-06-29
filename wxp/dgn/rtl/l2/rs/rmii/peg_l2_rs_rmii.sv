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


module peg_l2_rs_rmii #(

  parameter PKT_DATA_W  = 64,
  parameter PKT_SIZE_W  = 16

)

(
  //--------------------- Misc Ports (Logic)  -----------
  input                       rst_n,

  //Config signals
  input                       config_rs_mii_speed_100_n_10,

  //Packet interface from MAC TX
  input                       pkt_tx_valid,
  input                       pkt_tx_sop,
  input                       pkt_tx_eop,
  input   [PKT_DATA_W-1:0]    pkt_tx_data,
  input   [PKT_SIZE_W-1:0]    pkt_tx_size,
  output                      pkt_tx_ready,
  input                       pkt_tx_error,

  //Packet interface to MAC RX
  output                      pkt_rx_valid,
  output                      pkt_rx_sop,
  output                      pkt_rx_eop,
  output  [PKT_DATA_W-1:0]    pkt_rx_data,
  output  [PKT_SIZE_W-1:0]    pkt_rx_size,
  input                       pkt_rx_ready,
  output                      pkt_rx_error,

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
  peg_l2_rs_rmii_tx#(.PKT_DATA_W(PKT_DATA_W), .PKT_SIZE_W(PKT_SIZE_W))  u_rmii_tx
  (

    .rst_n                        (rst_n),

    .config_rs_mii_speed_100_n_10 (config_rs_mii_speed_100_n_10),

    .pkt_valid                    (pkt_tx_valid),
    .pkt_sop                      (pkt_tx_sop),
    .pkt_eop                      (pkt_tx_eop),
    .pkt_data                     (pkt_tx_data),
    .pkt_ready                    (pkt_tx_ready),
    .pkt_error                    (pkt_tx_error),

    .rmii_txd                     (rmii_txd),
    .rmii_tx_en                   (rmii_tx_en),
    .rmii_ref_clk                 (rmii_ref_clk)

  );


  /*  RX  */
  peg_l2_rs_rmii_rs#(.PKT_DATA_W(PKT_DATA_W), .PKT_SIZE_W(PKT_SIZE_W))   u_rmii_rx
  (

    .rst_n                        (rst_n),

    .config_rs_mii_speed_100_n_10 (config_rs_mii_speed_100_n_10),

    .rmii_rx_er                   (rmii_rx_er),
    .rmii_crs_dv                  (rmii_crs_dv),
    .rmii_rxd                     (rmii_rxd),
    .rmii_ref_clk                 (rmii_ref_clk),

    .pkt_valid                    (pkt_rx_valid),
    .pkt_sop                      (pkt_rx_sop),
    .pkt_eop                      (pkt_rx_eop),
    .pkt_data                     (pkt_rx_data),
    .pkt_ready                    (pkt_rx_ready),
    .pkt_error                    (pkt_rx_error)

  );


endmodule // peg_l2_rs_rmii

/*
 --------------------------------------------------------------------------

 -- <Header>
 

 -- <Log>

[29-06-2014  10:22:22 PM][mammenx] Added size field to packet interface

[28-06-2014  04:42:07 PM][mammenx] Removed System Verilog stuff except fsm enum

[18-06-2014  07:27:24 PM][mammenx] Initial Commit

[28-05-14 20:18:21] [mammenx] Moved log section to bottom of file

 --------------------------------------------------------------------------
*/
