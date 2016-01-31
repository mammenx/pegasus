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
 -- Module Name       : peg_rmii_tb_top
 -- Author            : mammenx
 -- Associated modules: 
 -- Function          : This is the top level test bench for RMII
 --------------------------------------------------------------------------
*/

`timescale 1ns / 10ps

`ifndef __PEG_RMII_TB_TOP
`define __PEG_RMII_TB_TOP

  /////////////////////////////////////////////////////
  // Importing OVM Packages                          //
  /////////////////////////////////////////////////////

  `include "ovm.svh"
  import ovm_pkg::*;

  `timescale  1ns/100ps


  module peg_rmii_tb_top ();

    //Parameters

    //TB Files
    `include  "rmii_tb.list"

    //Clock, Reset signals
    logic clk_50;
    logic rst_n;

    //Interfaces
    peg_rmii_intf   rmii_intf(clk_50,rst_n);


    /////////////////////////////////////////////////////
    // Clock, Reset Generation                         //
    /////////////////////////////////////////////////////
    initial
    begin
      clk_50    = 1;

      #111;

      forever #10ns clk_50  = ~clk_50;
    end

    initial
    begin
      rst_n   = 1;

      #123;

      rst_n   = 0;

      #321;

      rst_n   = 1;

    end


    /*  DUT */
    peg_l2_rs_rmii #(
      .PKT_DATA_W (8)

    ) u_peg_l2_rs_rmii  (

      .rst_n          (rst_n),

      .config_rs_mii_speed_100_n_10   (1'b1),

      .pkt_tx_valid   ('d0),
      .pkt_tx_sop     ('d0),
      .pkt_tx_eop     ('d0),
      .pkt_tx_data    ('d0),
      .pkt_tx_ready   (),
      .pkt_tx_error   ('d0),

      .pkt_rx_valid   (),
      .pkt_rx_sop     (),
      .pkt_rx_eop     (),
      .pkt_rx_data    (),
      .pkt_rx_ready   (1'b1),
      .pkt_rx_error   (),

      .rmii_rx_er     (rmii_intf.rx_er),
      .rmii_crs_dv    (rmii_intf.crs_dv),
      .rmii_rxd       (rmii_intf.rxd),
      .rmii_txd       (rmii_intf.txd),
      .rmii_tx_en     (rmii_intf.tx_en),
      .rmii_ref_clk   (clk_50)

    );



    initial
    begin
      #1;
      run_test();
    end



  endmodule // peg_rmii_tb_top

`endif

/*
 --------------------------------------------------------------------------

 -- <Header>
 

 -- <Log>

[28-05-14 20:18:21] [mammenx] Moved log section to bottom of file

 --------------------------------------------------------------------------
*/
