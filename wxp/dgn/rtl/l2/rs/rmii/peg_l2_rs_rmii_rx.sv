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
 -- Module Name       : peg_l2_rs_rmii_rx
 -- Author            : mammenx
 -- Associated modules: 
 -- Function          : This module implements the receive side of L2
                        reconcilliation sub-layer based on RMII. It converts
                        incoming data to byte stream.
 --------------------------------------------------------------------------
*/

`timescale 1ns / 10ps

`include  "pkt_intf_defines.sv"

module peg_l2_rs_rmii_rx  #(
  
  parameter PKT_DATA_W        = 8

)

(

  //--------------------- Misc Ports (Logic)  -----------
  input                       rst_n,

  //Config signals
  input                       config_rs_mii_speed_100_n_10,

  //RMII Interface to PHY
  input                       rmii_rx_er,
  input                       rmii_crs_dv,
  input   [1:0]               rmii_rxd,
  input                       rmii_ref_clk,

  //Packet interface to MAC RX
  output  reg                     pkt_valid,
  output                          pkt_sop,
  output                          pkt_eop,
  output  reg   [PKT_DATA_W-1:0]  pkt_data,
  input                           pkt_ready,
  output  reg                     pkt_error


  //--------------------- Interfaces --------------------

  );

//----------------------- Global parameters Declarations ------------------


//----------------------- Input Declarations ------------------------------


//----------------------- Inout Declarations ------------------------------


//----------------------- Output Declarations -----------------------------


//----------------------- Output Register Declaration ---------------------


//----------------------- Internal Register Declarations ------------------
  reg   [3:0]                 sample_cntr_f;
  reg   [1:0]                 byte_cntr_f;

//----------------------- Internal Wire Declarations ----------------------
  wire                        sample_rdy_c;

//----------------------- Internal Interface Declarations -----------------


//----------------------- FSM Declarations --------------------------------



//----------------------- Start of Code -----------------------------------

  always@(posedge rmii_ref_clk, negedge rst_n)
  begin
    if(~rst_n)
    begin
      sample_cntr_f           <=  0;
      byte_cntr_f             <=  0;
    end
    else
    begin
      if(config_rs_mii_speed_100_n_10)
      begin
        sample_cntr_f         <=  4'd9;
      end
      else
      begin
        sample_cntr_f         <=  sample_rdy_c  ? 0 : sample_cntr_f + rmii_crs_dv;
      end

      byte_cntr_f             <=  byte_cntr_f + sample_rdy_c;
    end
  end

  //Generate signal to indicate that sampe is ready
  assign  sample_rdy_c  = (sample_cntr_f  ==  4'd9) ? rmii_crs_dv : 1'b0;

  /*
    * Form byte-stream
  */
  always@(posedge rmii_ref_clk, negedge rst_n)
  begin
    if(~rst_n)
    begin
      pkt_valid               <=  0;
      pkt_data                <=  0;
      pkt_error               <=  0;
    end
    else
    begin
      pkt_valid               <=  (byte_cntr_f  ==  2'd3) ? sample_rdy_c  : 1'b0;
      pkt_data                <=  sample_rdy_c  ? {rmii_rxd,pkt_data[PKT_DATA_W-1:2]} : pkt_data;
      pkt_error               <=  rmii_rx_er;
    end
  end

  assign  pkt_sop       =   1'b0;
  assign  pkt_eop       =   1'b0;


endmodule // peg_l2_rs_rmii_rx

/*
 --------------------------------------------------------------------------

 -- <Header>
 

 -- <Log>

[31-01-2016  06:13:35 PM][mammenx] Simplified design to handle only byte-streams

[31-01-2016  04:30:07 PM][mammenx] Fixed compilation errors

[30-06-2014  03:37:45 PM][mammenx] Changed packet data width to 8

[29-06-2014  10:22:22 PM][mammenx] Added size field to packet interface

[28-06-2014  04:42:07 PM][mammenx] Removed System Verilog stuff except fsm enum

[18-06-2014  07:27:24 PM][mammenx] Initial Commit

[28-05-14 20:18:21] [mammenx] Moved log section to bottom of file

 --------------------------------------------------------------------------
*/
