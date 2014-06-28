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
 -- Module Name       : peg_l2_rs_rmii_rs
 -- Author            : mammenx
 -- Associated modules: 
 -- Function          : This module implements the receive side of L2
                        reconcilliation sub-layer based on RMII.
 --------------------------------------------------------------------------
*/

`timescale 1ns / 10ps


module peg_l2_rs_rmii_rs  #(
  
  parameter PKT_DATA_W        = 64

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
  output                      pkt_valid,
  output                      pkt_sop,
  output                      pkt_eop,
  output  [PKT_DATA_W-1:0]    pkt_data,
  input                       pkt_ready,
  output                      pkt_error


  //--------------------- Interfaces --------------------

  peg_l2_rmii_intf            mii_intf,     //mac_rx

  );

//----------------------- Global parameters Declarations ------------------
  `include  "peg_l2_params.sv"


//----------------------- Input Declarations ------------------------------


//----------------------- Inout Declarations ------------------------------


//----------------------- Output Declarations -----------------------------


//----------------------- Output Register Declaration ---------------------
  reg                         pkt_valid;
  reg                         pkt_sop;
  reg                         pkt_eop;
  reg   [PKT_DATA_W-1:0]      pkt_data;
  reg                         pkt_error;

//----------------------- Internal Register Declarations ------------------
  reg   [3:0]                 sample_cntr_f;
  reg   [4:0]                 data_cntr_f;

//----------------------- Internal Wire Declarations ----------------------
  wire                        sample_rdy_c;
  wire  [2:0]                 data_cntr_byte_w;
  wire                        wrap_data_cntr_c;

  wire  [PKT_DATA_W-1:0]      pkt_data_nxt_c;
  wire                        valid_preamble_sfd_pattern_c;
  wire                        data_valid_nxt_c;
  wire                        eop_nxt_c;

//----------------------- Internal Interface Declarations -----------------


//----------------------- FSM Declarations --------------------------------
enum  logic [1:0] { IDLE_S        = 2'd0, 
                    VALID_S       = 2'd1,
                    WAIT_IFG_S    = 2'd2
                  }  fsm_pstate, next_state;



//----------------------- Start of Code -----------------------------------

  /*  Main FSM Logic  */
  always@(posedge  rmii_ref_clk, negedge rst_n)
  begin
    if(~rst_n)
    begin
      fsm_pstate              <=  IDLE_S;
      sample_cntr_f           <=  0;
      data_cntr_f             <=  0;
    end
    else
    begin
      fsm_pstate              <=  next_state;

      if(config_rs_mii_speed_100_n_10) //100Mbps mode
      begin
        sample_cntr_f         <=  4'd9;
      end
      else  //10Mbps mode
      begin
        if(rmii_crs_dv)
        begin
          sample_cntr_f       <=  sample_rdy_c  ? 0 : sample_cntr_f + 1'b1;
        end
        else
        begin
          sample_cntr_f       <=  0;
        end
      end

      if(wrap_data_cntr_c)
      begin
        data_cntr_f           <=  0;
      end
      else if(fsm_pstate ==  VALID_S)
      begin
        data_cntr_f           <=  sample_rdy_c  ? data_cntr_f + 1'b1  : data_cntr_f;
      end
      else
      begin
        data_cntr_f           <=  0;
      end
    end
  end

  assign  sample_rdy_c        =   (sample_cntr_f  ==  'd9)  ? rmii_crs_dv : 1'b0;
  assign  data_cntr_byte_w    =   data_cntr_f[4:2]; //get num of bytes
  assign  wrap_data_cntr_c    =   (data_cntr_f  ==  ((PKT_DATA_W >>  1) - 1)) ? sample_rdy_c  : 1'b0;

  always@(*)
  begin
    next_state        = fsm_pstate;
    data_valid_nxt_c  = pkt_valid;
    eop_nxt_c         = 1'b0;

    case(fsm_pstate)

      IDLE_S  :
      begin
        data_valid_nxt_c      =   valid_preamble_sfd_pattern_c;

        if(valid_preamble_sfd_pattern_c)
        begin
          next_state          =   VALID_S;
        end
      end

      VALID_S :
      begin
        data_valid_nxt_c      =   wrap_data_cntr_c  | (~rmii_crs_dv);

        if(~rmii_crs_dv)
        begin
          eop_nxt_c           =   1'b1;
          next_state          =   WAIT_IFG_S;
        end
      end

      WAIT_IFG_S  :
      begin
        next_state            =   IDLE_S;
      end

    endcase
  end


  /*  Prep data into packet format  */
  always@(posedge  rmii_ref_clk, rst_n)
  begin
    if(~rst_n)
    begin
      pkt_sop            <=  0;
      pkt_eop            <=  0;
      pkt_valid          <=  0;
      pkt_data           <=  0;
      pkt_error          <=  0;
    end
    else
    begin
      //Shift in valid data
      pkt_data           <=  pkt_data_nxt_c;

      pkt_sop            <=  valid_preamble_sfd_pattern_c;

      pkt_valid          <=  data_valid_nxt_c;

      pkt_eop            <=  eop_nxt_c;

      //Latch onto error until eop
      if(pkt_error)
      begin
        pkt_error        <=  ~pkt_eop;
      end
      else
      begin
        pkt_error        <=  rmii_rx_er;
      end
    end    
  end

  //Shift in valid data
  assign  pkt_data_nxt_c  = sample_rdy_c  ? {rmii_rxd,  pkt_data[PKT_DATA_W-3:0]}
                                          : pkt_data;

  //Check for valid preamble SFD pattern
  assign  valid_preamble_sfd_pattern_c  = (pkt_data_nxt_c ==  {SFD_VALUE,PREAMBLE_VALUE}) ? sample_rdy_c  : 1'b0;


endmodule // peg_l2_rs_rmii_rs

/*
 --------------------------------------------------------------------------

 -- <Header>
 

 -- <Log>

[28-06-2014  04:42:07 PM][mammenx] Removed System Verilog stuff except fsm enum

[18-06-2014  07:27:24 PM][mammenx] Initial Commit

[28-05-14 20:18:21] [mammenx] Moved log section to bottom of file

 --------------------------------------------------------------------------
*/
