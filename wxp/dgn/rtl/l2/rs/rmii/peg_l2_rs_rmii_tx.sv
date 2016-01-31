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
 -- Module Name       : peg_l2_rs_rmii_tx
 -- Author            : mammenx
 -- Associated modules: 
 -- Function          : This module contains logic for driving an ethernet
                        packet on RMII interface. It converts an incoming
                        byte-stream to RMII.
 --------------------------------------------------------------------------
*/

`timescale 1ns / 10ps


module peg_l2_rs_rmii_tx #(
  parameter   PKT_DATA_W        = 8

)

(

  //--------------------- Misc Ports (Logic)  -----------
  input                       rst_n,

  //Config signals
  input                       config_rs_mii_speed_100_n_10,

  //Packet interface from MAC TX
  input                           pkt_valid,
  input                           pkt_sop,
  input                           pkt_eop,
  input       [PKT_DATA_W-1:0]    pkt_data,
  output                          pkt_ready,
  input                           pkt_error,

  //RMII interface to PHY
  output  reg [1:0]               rmii_txd,
  output  reg                     rmii_tx_en,
  input                           rmii_ref_clk


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
  wire                        sample_done_c;


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
        sample_cntr_f         <=  sample_done_c ? 0 : sample_cntr_f + rmii_tx_en;
      end

      byte_cntr_f             <=  byte_cntr_f + sample_done_c;
    end
  end

  assign  sample_done_c       =   (sample_cntr_f  ==  4'd9) ? rmii_tx_en  : 1'b0;

  assign  pkt_ready           =   (byte_cntr_f  ==  2'd3) ? sample_done_c & pkt_valid : 1'b0;

  /*
    * RMII  Interface
  */
  always@(posedge rmii_ref_clk, negedge rst_n)
  begin
    if(~rst_n)
    begin
      rmii_txd                <=  0;
      rmii_tx_en              <=  0;
    end
    else
    begin
      rmii_tx_en              <=  pkt_valid;
      rmii_txd                <=  pkt_valid ? pkt_data[byte_cntr_f  +:  2]  : 0;
    end
  end



endmodule // peg_l2_rs_rmii_tx

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
