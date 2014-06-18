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


module peg_l2_rs_rmii_tx (

  //--------------------- Misc Ports (Logic)  -----------


  //--------------------- Interfaces --------------------
  clk_rst_sync_intf           cr_intf,

  peg_l2_config_intf          config_intf,  //rs

  peg_pkt_xfr_intf            pkt_intf,     //slave, 64b

  peg_l2_rmii_intf            mii_intf      //mac_tx

                );

//----------------------- Global parameters Declarations ------------------
  import  peg_l2_pkg::*;

  parameter   PKT_DATA_W        = 64;
  parameter   IFG               = 96;
  localparam  IFG_100MBPS       = (96 / 2)  - 1;
  localparam  IFG_10MBPS        = (IFG_100MBPS * 10)  - 1;
  localparam  IFG_CNTR_W        = $clog2(IFG_10MBPS); //worst case

//----------------------- Input Declarations ------------------------------


//----------------------- Inout Declarations ------------------------------


//----------------------- Output Declarations -----------------------------


//----------------------- Output Register Declaration ---------------------


//----------------------- Internal Register Declarations ------------------
  logic [3:0]                 sample_cntr_f;
  logic                       sample_cntr_en_c;
  logic [4:0]                 data_cntr_f;

  logic [IFG_CNTR_W-1:0]      ifg_cntr_f;

//----------------------- Internal Wire Declarations ----------------------
  logic                       sample_rdy_c;
  logic                       wrap_data_cntr_c;
  logic [2:0]                 data_cntr_byte_w;

  logic [IFG_CNTR_W-1:0]      ifg_val_c;
  logic                       ifg_rdy_c;

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
  always_ff@(posedge  mii_intf.ref_clk, negedge cr_intf.rst_n)
  begin
    if(~cr_intf.rst_n)
    begin
      fsm_pstate              <=  IDLE_S;
      sample_cntr_f           <=  0;
      data_cntr_f             <=  0;
      ifg_cntr_f              <=  0;
    end
    else
    begin
      fsm_pstate              <=  next_state;

      if(config_intf.rs_mii_speed_100_n_10) //100Mbps mode
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
  assign  wrap_data_cntr_c    =   (data_cntr_f  ==  ((PKT_DATA_W >>  1) - 1)) ? sample_rdy_c  : 1'b0;
  assign  data_cntr_byte_w    =   data_cntr_f[4:2]; //get num of bytes

  //Select the ifg value based on configuration
  assign  ifg_val_c           =   config_intf.rs_mii_speed_100_n_10 ? IFG_100MBPS : IFG_10MBPS;

  //Check if the IFG condition is met -> counter is zero
  assign  ifg_rdy_c           =   (ifg_cntr_f ==  {IFG_CNTR_W{1'b0}})  ? 1'b1  : 1'b0;

  always_comb
  begin
    next_state    =   fsm_pstate;

    case(fsm_pstate)

      IDLE_S  :
      begin
        pkt_intf.ready        =   ~pkt_intf.valid;

        if(pkt_intf.valid  & pkt_intf.sop)
        begin
          next_state          =   XMT_S;
        end
      end

      XMT_S :
      begin
        pkt_intf.ready        =   wrap_data_cntr_c;

        if(pkt_intf.valid & pkt_intf.eop  & wrap_data_cntr_c)
        begin
          next_state          =   IFG_S;
        end
      end

      IFG_S :
      begin
        pkt_intf.ready        =   1'b0;

        if(ifg_rdy_c)
        begin
          next_state          =   IDLE_S;
        end
      end

    endcase
  end

  /*  RMII Interface logic  */
  always_ff@(posedge  mii_intf.ref_clk, negedge cr_intf.rst_n)
  begin
    if(~cr_intf.rst_n)
    begin
      mii_intf.txd            <=  0;
      mii_intf.tx_en          <=  0;
    end
    else
    begin
      case(fsm_pstate)

        IDLE_S  :
        begin
          if(pkt_intf.valid  & pkt_intf.sop)
          begin
            mii_intf.txd      <=  pkt_intf.data[data_cntr_f +:  2];
            mii_intf.tx_en    <=  1'b1;
          end
        end

        XMT_S :
        begin
          mii_intf.tx_en      <=  (pkt_intf.valid & pkt_intf.eop) : ~wrap_data_cntr_c : 1'b1;
          mii_intf.txd        <=  pkt_intf.data[data_cntr_f +:  2];
        end

        default :
        begin
          mii_intf.tx_en      <=  0;
          mii_intf.txd        <=  0;
        end

      endcase
    end
  end

endmodule // peg_l2_rs_rmii_tx

/*
 --------------------------------------------------------------------------

 -- <Header>
 

 -- <Log>

[18-06-2014  07:27:24 PM][mammenx] Initial Commit

[28-05-14 20:18:21] [mammenx] Moved log section to bottom of file

 --------------------------------------------------------------------------
*/
