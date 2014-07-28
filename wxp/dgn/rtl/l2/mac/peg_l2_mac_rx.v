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
 -- Module Name       : peg_l2_mac_rx
 -- Author            : mammenx
 -- Associated modules: 
 -- Function          : Wrapper for L2 MAC TX.
 --------------------------------------------------------------------------
*/

`timescale 1ns / 10ps

`inlcude  "pkt_intf_defines.sv"

module peg_l2_mac_rx #(
    parameter PKT_DATA_W      = 8,
    parameter PKT_SIZE_W      = 16,
    parameter NUM_FIELDS      = 8,
    parameter BFFR_SIZE       = 48
)

(

  input                       clk,
  input                       rst_n,

  //Outputs to MAC TX
  output                      mac_pause_en,

  //MAC Logic Link packet interface
  `pkt_intf_ports_m(llc_rx_,,PKT_DATA_W),

  //RS packet interface
  `pkt_intf_ports_s(rs_rx_,,PKT_DATA_W)
);

//----------------------- Global parameters Declarations ------------------


//----------------------- Input Declarations ------------------------------


//----------------------- Inout Declarations ------------------------------


//----------------------- Output Declarations -----------------------------


//----------------------- Output Register Declaration ---------------------


//----------------------- Internal Register Declarations ------------------


//----------------------- Internal Wire Declarations ----------------------
  wire  [NUM_FIELDS-1:0]        rx_field_valid_vec_w;
  wire  [BFFR_SIZE-1:0]         rx_bffr_w;

  wire                          fcs_calc_rst_w;
  wire                          fcs_calc_en_w;
  wire  [PKT_DATA_W-1:0]        fcs_calc_data_w;

//----------------------- Input/Output Registers --------------------------

//----------------------- Start of Code -----------------------------------

  peg_l2_mac_rx_parser #(
    .PKT_DATA_W(PKT_DATA_W),
    .PKT_SIZE_W(PKT_SIZE_W),
    .NUM_FIELDS(NUM_FIELDS),
    .BFFR_SIZE(BFFR_SIZE)
  )
    u_l2_mac_rx_parser
  (
    .clk            (clk),
    .rst_n          (rst_n),

    //Config interface
    .config_l2_mac_rx_en,
    .config_l2_mac_rx_fcs_en,
    .config_l2_mac_rx_strip_preamble_sfd,
    .config_l2_mac_rx_strip_fcs,

    //Status interface
    .l2_mac_rx_fsm_state,

    //Interface to RX Filter & Pause Gen
    .rx_field_valid_vec       (rx_field_valid_vec_w),
    .rx_bffr                  (rx_bffr_w),

    //Interface to FCS Calculator
    .rx_fcs_rst               (fcs_calc_rst_w),
    .rx_fcs_calc_en           (fcs_calc_en_w),
    .rx_fcs_calc_data         (fcs_calc_data_w),

    //RS packet interface
    `pkt_intf_port_connect(rs_rx_,,rs_rx_,),

    //LLC packet interface
    `pkt_intf_port_connect(llc_rx_,,llc_rx_,)

  );


  peg_l2_mac_pause_cntr  #(
    .BPCLK(PKT_DATA_W)
  )
    u_pause_cntr
  (
    .clk          (clk),
    .rst_n        (rst_n),

    //Config
    .pause_en     (),

    //Inputs from Parser
    .pause_time_valid   (rx_field_valid_vec_w[MAC_FIDX_PAUSE_TIME]),
    .pause_time         (rx_bffr_w[15:0]),

    //Pause Status
    .pause_valid  (mac_pause_en)

  );


  peg_l2_fcs_gen #(
    .DATA_W(PKT_DATA_W),
    .CRC_INIT_VAL(32'd0)
  )
    u_l2_fcs_gen
  (
    .clk            (clk),
    .rst_n          (rst_n),

    .fcs_calc_rst   (fcs_calc_rst_w),
    .fcs_calc_valid (fcs_calc_en_w),
    .fcs_calc_data  (fcs_calc_data_w),

    .fcs            ()

  );



endmodule // peg_l2_mac_rx


/*
 --------------------------------------------------------------------------

 -- <Header>
 

 -- <Log>

[28-07-2014  04:18:29 PM][mammenx] Created basic wrapper

[28-05-14 20:18:21] [mammenx] Moved log section to bottom of file

 --------------------------------------------------------------------------
*/
