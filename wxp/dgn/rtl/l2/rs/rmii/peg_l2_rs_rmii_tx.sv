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
                        packet on RMII interface.
 --------------------------------------------------------------------------
*/

`timescale 1ns / 10ps


module peg_l2_rs_rmii_tx #(

  parameter   PKT_DATA_W        = 8,
  parameter   PKT_SIZE_W        = 16,
  parameter   IFG               = 96

)

(

  //--------------------- Misc Ports (Logic)  -----------
  input                       rst_n,

  //Config signals
  input                       config_rs_mii_speed_100_n_10,

  //Packet interface from MAC TX
  input                       pkt_valid,
  input                       pkt_sop,
  input                       pkt_eop,
  input   [PKT_DATA_W-1:0]    pkt_data,
  input   [PKT_SIZE_W-1:0]    pkt_size;
  output                      pkt_ready,
  input                       pkt_error,

  //RMII interface to PHY
  output  [1:0]               rmii_txd,
  output                      rmii_tx_en,
  input                       rmii_ref_clk


  //--------------------- Interfaces --------------------

);

//----------------------- Global parameters Declarations ------------------
  `include  "peg_l2_params.sv"

  localparam  IFG_100MBPS       = (96 / 2)  - 1;
  localparam  IFG_10MBPS        = (IFG_100MBPS * 10)  - 1;
  localparam  IFG_CNTR_W        = $clog2(IFG_10MBPS); //worst case

//----------------------- Input Declarations ------------------------------


//----------------------- Inout Declarations ------------------------------


//----------------------- Output Declarations -----------------------------


//----------------------- Output Register Declaration ---------------------


//----------------------- Internal Register Declarations ------------------
  reg   [3:0]                 sample_cntr_f;
  reg                         sample_cntr_en_c;
  reg   [4:0]                 data_cntr_f;

  reg   [IFG_CNTR_W-1:0]      ifg_cntr_f;

//----------------------- Internal Wire Declarations ----------------------
  wire                        sample_rdy_c;
  wire                        wrap_data_cntr_c;
  wire  [4:0]                 wrap_data_val_c;
  wire  [2:0]                 data_cntr_byte_w;

  wire  [IFG_CNTR_W-1:0]      ifg_val_c;
  wire                        ifg_rdy_c;

//----------------------- Internal Interface Declarations -----------------


//----------------------- FSM Declarations --------------------------------
enum  logic [1:0] { IDLE_S    = 2'd0,
                    XMT_S     = 2'd1,
                    IFG_S     = 2'd2
                  }  fsm_pstate, next_state;



//----------------------- Start of Code -----------------------------------

  /*
    * Main FSM
  */
  always@(posedge  rmii_ref_clk, negedge rst_n)
  begin
    if(~rst_n)
    begin
      fsm_pstate              <=  IDLE_S;
      sample_cntr_f           <=  0;
      data_cntr_f             <=  0;
      ifg_cntr_f              <=  0;
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
        if(sample_cntr_en_c)
        begin
          sample_cntr_f       <=  sample_rdy_c  ? 0 : sample_cntr_f + 1'b1;
        end
        else
        begin
          sample_cntr_f       <=  0;
        end
      end

      if(fsm_pstate ==  XMT_S)
      begin
        if(wrap_data_cntr_c)
        begin
          data_cntr_f         <=  0;
        end
        else
        begin
          data_cntr_f         <=  sample_rdy_c  ? data_cntr_f + 1'b1  : data_cntr_f;
        end
      end
      else
      begin
        data_cntr_f           <=  0;
      end

      if(fsm_pstate ==  XMT_S)
      begin
        ifg_cntr_f            <=  ifg_val_c;
      end
      else if(fsm_pstate  ==  IFG_S)
      begin
        ifg_cntr_f            <=  ifg_cntr_f  - 1'b1;
      end
      else
      begin
        ifg_cntr_f            <=  ifg_cntr_f;
      end
    end
  end

  assign  sample_cntr_en_c    =   (fsm_pstate == XMT_S) ? 1'b1  : 1'b0;
  assign  sample_rdy_c        =   (sample_cntr_f  ==  'd9)  ? 1'b1  : 1'b0;
  assign  wrap_data_val_c     =   (pkt_valid  & pkt_eop)  ? (pkt_size[PKT_SIZE_W-1:1]  - 1'b1)  : ((PKT_DATA_W >>  1) - 1);
  assign  wrap_data_cntr_c    =   (data_cntr_f  ==  wrap_data_val_c) ? sample_rdy_c  : 1'b0;
  assign  data_cntr_byte_w    =   data_cntr_f[4:2]; //get num of bytes

  //Select the ifg value based on configuration
  assign  ifg_val_c           =   config_rs_mii_speed_100_n_10 ? IFG_100MBPS : IFG_10MBPS;

  //Check if the IFG condition is met -> counter is zero
  assign  ifg_rdy_c           =   (ifg_cntr_f ==  {IFG_CNTR_W{1'b0}})  ? 1'b1  : 1'b0;

  always@(*)
  begin
    next_state    =   fsm_pstate;

    case(fsm_pstate)

      IDLE_S  :
      begin
        pkt_ready        =   ~pkt_valid;

        if(pkt_valid  & pkt_sop)
        begin
          next_state          =   XMT_S;
        end
      end

      XMT_S :
      begin
        pkt_ready        =   wrap_data_cntr_c;

        if(pkt_valid & pkt_eop  & wrap_data_cntr_c)
        begin
          next_state          =   IFG_S;
        end
      end

      IFG_S :
      begin
        pkt_ready        =   1'b0;

        if(ifg_rdy_c)
        begin
          next_state          =   IDLE_S;
        end
      end

    endcase
  end

  /*  RMII Interface logic  */
  always@(posedge  rmii_ref_clk, negedge rst_n)
  begin
    if(~rst_n)
    begin
      rmii_txd            <=  0;
      rmii_tx_en          <=  0;
    end
    else
    begin
      case(fsm_pstate)

        IDLE_S  :
        begin
          if(pkt_valid  & pkt_sop)
          begin
            rmii_txd      <=  pkt_data[data_cntr_f +:  2];
            rmii_tx_en    <=  1'b1;
          end
        end

        XMT_S :
        begin
          rmii_tx_en      <=  (pkt_valid & pkt_eop) : ~wrap_data_cntr_c : 1'b1;
          rmii_txd        <=  pkt_data[data_cntr_f +:  2];
        end

        default :
        begin
          rmii_tx_en      <=  0;
          rmii_txd        <=  0;
        end

      endcase
    end
  end

endmodule // peg_l2_rs_rmii_tx

/*
 --------------------------------------------------------------------------

 -- <Header>
 

 -- <Log>

[30-06-2014  03:37:45 PM][mammenx] Changed packet data width to 8

[29-06-2014  10:22:22 PM][mammenx] Added size field to packet interface

[28-06-2014  04:42:07 PM][mammenx] Removed System Verilog stuff except fsm enum

[18-06-2014  07:27:24 PM][mammenx] Initial Commit

[28-05-14 20:18:21] [mammenx] Moved log section to bottom of file

 --------------------------------------------------------------------------
*/
