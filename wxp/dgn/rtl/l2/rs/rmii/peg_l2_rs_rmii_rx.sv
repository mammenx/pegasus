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


module peg_l2_rs_rmii_rs (

  //--------------------- Misc Ports (Logic)  -----------


  //--------------------- Interfaces --------------------
  clk_rst_sync_intf           cr_intf,

  peg_l2_config_intf          config_intf,  //rs

  peg_l2_rmii_intf            mii_intf,     //mac_rx

  peg_pkt_xfr_intf            pkt_intf      //master, 64b

  );

//----------------------- Global parameters Declarations ------------------
  import  peg_l2_pkg::*;

  parameter PKT_DATA_W        = 64;

//----------------------- Input Declarations ------------------------------


//----------------------- Inout Declarations ------------------------------


//----------------------- Output Declarations -----------------------------


//----------------------- Output Register Declaration ---------------------


//----------------------- Internal Register Declarations ------------------
  logic [3:0]                 sample_cntr_f;
  logic [4:0]                 data_cntr_f;

//----------------------- Internal Wire Declarations ----------------------
  logic                       sample_rdy_c;
  logic [2:0]                 data_cntr_byte_w;
  logic                       wrap_data_cntr_c;

  logic [PKT_DATA_W-1:0]      pkt_data_nxt_c;
  logic                       valid_preamble_sfd_pattern_c;
  logic                       data_valid_nxt_c;
  logic                       eop_nxt_c;

//----------------------- Internal Interface Declarations -----------------


//----------------------- FSM Declarations --------------------------------
enum  logic [1:0] { IDLE_S        = 2'd0, 
                    VALID_S       = 2'd1,
                    WAIT_IFG_S    = 2'd2
                  }  fsm_pstate, next_state;



//----------------------- Start of Code -----------------------------------

  /*  Main FSM Logic  */
  always_ff@(posedge  mii_intf.ref_clk, negedge cr_intf.rst_n)
  begin
    if(~cr_intf.rst_n)
    begin
      fsm_pstate              <=  IDLE_S;
      sample_cntr_f           <=  0;
      data_cntr_f             <=  0;
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
        if(mii_intf.crs_dv)
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

  assign  sample_rdy_c        =   (sample_cntr_f  ==  'd9)  ? mii_intf.crs_dv : 1'b0;
  assign  data_cntr_byte_w    =   data_cntr_f[4:2]; //get num of bytes
  assign  wrap_data_cntr_c    =   (data_cntr_f  ==  ((PKT_DATA_W >>  1) - 1)) ? sample_rdy_c  : 1'b0;

  always_comb
  begin
    next_state        = fsm_pstate;
    data_valid_nxt_c  = pkt_intf.valid;
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
        data_valid_nxt_c      =   wrap_data_cntr_c  | (~mii_intf.crs_dv);

        if(~mii_intf.crs_dv)
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
  always_ff@(posedge  mii_intf.ref_clk, cr_intf.rst_n)
  begin
    if(~cr_intf.rst_n)
    begin
      pkt_intf.sop            <=  0;
      pkt_intf.eop            <=  0;
      pkt_intf.valid          <=  0;
      pkt_intf.data           <=  0;
      pkt_intf.error          <=  0;
    end
    else
    begin
      //Shift in valid data
      pkt_intf.data           <=  pkt_data_nxt_c;

      pkt_intf.sop            <=  valid_preamble_sfd_pattern_c;

      pkt_intf.valid          <=  data_valid_nxt_c;

      pkt_intf.eop            <=  eop_nxt_c;

      //Latch onto error until eop
      if(pkt_intf.error)
      begin
        pkt_intf.error        <=  ~pkt_intf.eop;
      end
      else
      begin
        pkt_intf.error        <=  mii_intf.rx_er;
      end
    end    
  end

  //Shift in valid data
  assign  pkt_data_nxt_c  = sample_rdy_c  ? {mii_intf.rxd,  pkt_intf.data[PKT_DATA_W-3:0]}
                                          : pkt_intf.data;

  //Check for valid preamble SFD pattern
  assign  valid_preamble_sfd_pattern_c  = (pkt_data_nxt_c ==  {SFD_VALUE,PREAMBLE_VALUE}) ? sample_rdy_c  : 1'b0;


endmodule // peg_l2_rs_rmii_rs

/*
 --------------------------------------------------------------------------

 -- <Header>
 

 -- <Log>

[18-06-2014  07:27:24 PM][mammenx] Initial Commit

[28-05-14 20:18:21] [mammenx] Moved log section to bottom of file

 --------------------------------------------------------------------------
*/
