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
 -- Module Name       : peg_l2_mac_rx_parser
 -- Author            : mammenx
 -- Associated modules: 
 -- Function          : This module parses an ingress packet stream to 
                        extract the different fields in an L2 frame. This
                        has an 8b pipeline that is intended for upto 1Gbps
                        speeds @ 125MHz clock.
 --------------------------------------------------------------------------
*/

`timescale 1ns / 10ps


module peg_l2_mac_rx_parser #(
  parameter PKT_DATA_W      = 8,
  parameter PKT_SIZE_W      = 16,
  parameter NUM_FIELDS      = 8,
  parameter BFFR_SIZE       = 48
)

(
  input                       clk,
  input                       rst_n,

  //Config interface
  input                       config_l2_mac_rx_en,
  input                       config_l2_mac_rx_fcs_en,
  input                       config_l2_mac_rx_strip_preamble_sfd,
  input                       config_l2_mac_rx_strip_fcs,

  //Status interface
  output  [3:0]               l2_mac_rx_fsm_state,

  //Interface to RX Filter & Pause Gen
  output  [NUM_FIELDS-1:0]    rx_field_valid_vec,
  output  [BFFR_SIZE-1:0]     rx_bffr,

  //Interface to FCS Calculator
  output                      rx_fcs_calc_en,
  output  [PKT_DATA_W-1:0]    rx_fcs_calc_data,

  //RS packet interface
  input                       rs_rx_valid,
  input                       rs_rx_sop,
  input                       rs_rx_eop,
  input   [PKT_DATA_W-1:0]    rs_rx_data,
  output                      rs_rx_ready,
  input                       rs_rx_error,

  //LLC packet interface
  output                      llc_rx_valid,
  output                      llc_rx_sop,
  output                      llc_rx_eop,
  output  [PKT_DATA_W-1:0]    llc_rx_data,
  input                       llc_rx_ready,
  output                      llc_rx_error

);

//----------------------- Global parameters Declarations ------------------
  `include  "peg_l2_params.v"

  parameter PKT_SIZE_INC_VAL  = PKT_DATA_W  / 8;

//----------------------- Input Declarations ------------------------------


//----------------------- Inout Declarations ------------------------------


//----------------------- Output Declarations -----------------------------


//----------------------- Output Register Declaration ---------------------
  reg   [NUM_FIELDS-1:0]      rx_field_valid_vec;
  reg   [BFFR_SIZE-1:0]       rx_bffr;

  reg                         rx_fcs_calc_en;

  reg                         llc_rx_valid;
  reg                         llc_rx_sop;
  reg                         llc_rx_eop;

//----------------------- Internal Register Declarations ------------------
  reg   [15:0]                data_cntr_f;
  reg                         vlan_frm_f;
  reg                         ctrl_frm_f;
  reg                         pause_frm_f;
  reg   [2:0]                 fcs_en_delay_vec_f;
  reg                         fcs_en_nxt_c;
  reg   [2:0]                 llc_rx_valid_del_vec_f;
  reg                         llc_rx_valid_nxt_c;
  reg   [2:0]                 llc_rx_sop_del_vec_f;
  reg                         llc_rx_sop_nxt_c;

//----------------------- Internal Wire Declarations ----------------------
  wire                        rx_data_valid_c;
  wire  [15:0]                data_bytes_w;
  wire  [BFFR_SIZE-1:0]       bffr_nxt_w;

  wire                        preamble_valid_c;
  wire                        sfd_valid_c;


//----------------------- FSM Parameters --------------------------------------
//only for FSM state vector representation
parameter     [3:0]                  // synopsys enum fsm_pstate
IDLE_S              = 4'd0,
PREAMBLE_S          = 4'd1,
SFD_S               = 4'd2,
DA_S                = 4'd3,
SA_S                = 4'd4,
LEN_TYPE_S          = 4'd5,
VLAN_TAG_S          = 4'd6,
DATA_S              = 4'd7,
FCS_S               = 4'd8;

//----------------------- FSM Register Declarations ------------------
reg           [3:0]                            // synopsys enum fsm_pstate
fsm_pstate, next_state;

//----------------------- FSM String Declarations ------------------
//synthesis translate_off
reg           [8*16:0]      state_name;//"state name" is user defined
//synthesis translate_on

//----------------------- FSM Debugging Logic Declarations ------------------
//synthesis translate_off
always @ (fsm_pstate)
begin
case (fsm_pstate)

IDLE_S            : state_name = "IDLE_S";

PREAMBLE_S        : state_name = "PREAMBLE_S";

SFD_S             : state_name = "SFD_S";

DA_S              : state_name = "DA_S";

SA_S              : state_name = "SA_S";

LEN_TYPE_S        : state_name = "LEN_TYPE_S";

VLAN_TAG_S        : state_name = "VLAN_TAG_S";

DATA_S            : state_name = "DATA_S";

FCS_S             : state_name = "FCS_S";

default           : state_name = "INVALID STATE!";
endcase
end
//synthesis translate_on

//----------------------- Input/Output Registers --------------------------

//----------------------- Start of Code -----------------------------------

  always@(posedge clk,  negedge rst_n)
  begin
    if(~rst_n)
    begin
      fsm_pstate              <=  IDLE_S;
      data_cntr_f             <=  0;
      vlan_frm_f              <=  0;
      ctrl_frm_f              <=  0;
      pause_frm_f             <=  0;
      fcs_en_delay_vec_f      <=  0;
      llc_rx_valid_del_vec_f  <=  0;
      llc_rx_sop_del_vec_f    <=  0;

      rx_fcs_calc_en          <=  0;

      llc_rx_valid            <=  0;
      llc_rx_sop              <=  0;
      llc_rx_eop              <=  0;
    end
    else
    begin
      fsm_pstate              <=  next_state;

      if(fsm_pstate ==  IDLE_S)
      begin
        fcs_en_delay_vec_f    <=  0;
        llc_rx_valid_del_vec_f<=  0;
        llc_rx_sop_del_vec_f  <=  0;
      end
      else if(fsm_pstate  ==  FCS_S)
      begin
        fcs_en_delay_vec_f    <=  0;
        llc_rx_sop_del_vec_f  <=  0;
        llc_rx_valid_del_vec_f<=  {llc_rx_valid_del_vec_f[1:0],1'b0};
      end
      else
      begin
        fcs_en_delay_vec_f    <=  rx_data_valid_c ? {fcs_en_delay_vec_f[1:0], fcs_en_nxt_c} : fcs_en_delay_vec_f;
        llc_rx_valid_del_vec_f<=  rx_data_valid_c ? {llc_rx_valid_del_vec_f[1:0],llc_rx_valid_nxt_c}  : llc_rx_valid_del_vec_f;
        llc_rx_sop_del_vec_f  <=  rx_data_valid_c ? {llc_rx_sop_del_vec_f[1:0],llc_rx_sop_nxt_c}  : llc_rx_sop_del_vec_f;
      end

      rx_fcs_calc_en          <=  rx_data_valid_c & fcs_en_delay_vec_f[2] & (fsm_pstate !=  IDLE_S);

      llc_rx_valid            <=  (fsm_pstate ==  FCS_S)  ? llc_rx_valid_del_vec_f[2] : rx_data_valid_c & llc_rx_valid_del_vec_f[2];

      llc_rx_sop              <=  rx_data_valid_c & llc_rx_valid_del_vec_f[2] & (fsm_pstate !=  IDLE_S);

      if((fsm_pstate  ==  DATA_S) & rx_data_valid_c & rs_rx_eop)
      begin
        llc_rx_eop            <=  config_l2_mac_rx_strip_fcs;
      end
      else if(fsm_pstate  ==  FCS_S)
      begin
        llc_rx_eop            <=  (llc_rx_valid_del_vec_f ==  3'b100) ? 1'b1  : 1'b0;
      end
      else
      begin
        llc_rx_eop            <=  1'b0;
      end

      if(fsm_pstate ==  IDLE_S)
      begin
        data_cntr_f           <=  0;
      end
      else if(rx_data_valid_c)
      begin
        data_cntr_f           <=  data_cntr_f + PKT_SIZE_INC_VAL;
      end

      if(fsm_pstate ==  IDLE_S)
      begin
        vlan_frm_f            <=  0;
      end
      else if(data_bytes_w ==  MAC_DATA_OFFSET-1)
      begin
        vlan_frm_f            <=  (bffr_nxt_w[15:0] ==  VLAN_TYPE_VALUE)  ? rx_data_valid_c : 1'b0;
      end

      if(fsm_pstate ==  IDLE_S)
      begin
        ctrl_frm_f            <=  0;
      end
      else if(data_bytes_w ==  MAC_DATA_OFFSET-1)
      begin
        ctrl_frm_f            <=  (bffr_nxt_w[15:0] ==  CTRL_TYPE_VALUE)  ? rx_data_valid_c : 1'b0;
      end

      if(fsm_pstate ==  IDLE_S)
      begin
        pause_frm_f           <=  0;
      end
      else if(data_bytes_w ==  MAC_PAUSE_TIME_OFFSET+1)
      begin
        pause_frm_f           <=  (bffr_nxt_w[15:0] ==  PAUSE_CTRL_OPCODE) ? rx_data_valid_c & ctrl_frm_f : 1'b0;
      end
    end
  end

  assign  rx_fcs_calc_data    =   rx_bffr[(2*PKT_DATA_W)  +:  PKT_DATA_W];

  assign  rx_data_valid_c     =   rs_rx_valid & rs_rx_ready;
  assign  rs_rx_ready         =   1'b1;

  assign  data_bytes_w        =   {{(PKT_SIZE_INC_VAL-1){1'b0}},data_cntr_f[15:PKT_SIZE_INC_VAL-1]};

  always@(*)
  begin
    next_state                =   fsm_pstate;
    fcs_en_nxt_c              =   1'b0;
    llc_rx_valid_nxt_c        =   1'b0;
    llc_rx_sop_nxt_c          =   1'b0;

    case(fsm_pstate)

      IDLE_S  :
      begin
        if(rx_data_valid_c  & rs_rx_sop & config_l2_mac_rx_en)
        begin
          llc_rx_valid_nxt_c  =   ~config_l2_mac_rx_strip_preamble_sfd;
          llc_rx_sop_nxt_c    =   ~config_l2_mac_rx_strip_preamble_sfd;
          next_state          =   PREAMBLE_S;
        end
      end

      PREAMBLE_S  :
      begin
        llc_rx_valid_nxt_c    =   ~config_l2_mac_rx_strip_preamble_sfd;

        if(rx_data_valid_c  & (data_bytes_w ==  MAC_SFD_OFFSET-1))
        begin
          next_state          =   preamble_valid_c  ? SFD_S : IDLE_S;
        end
      end

      SFD_S :
      begin
        llc_rx_valid_nxt_c    =   ~config_l2_mac_rx_strip_preamble_sfd;

        if(rx_data_valid_c  & (data_bytes_w ==  MAC_SA_OFFSET-1))
        begin
          llc_rx_sop_nxt_c    =   config_l2_mac_rx_strip_preamble_sfd;
          next_state          =   sfd_valid_c ? DA_S  : IDLE_S;
        end
      end

      DA_S  :
      begin
        llc_rx_valid_nxt_c    =   1'b1;
        fcs_en_nxt_c          =   config_l2_mac_rx_fcs_en;

        if(rx_data_valid_c  & (data_bytes_w ==  MAC_SA_OFFSET-1))
        begin
          next_state          =   SA_S;
        end
      end

      SA_S  :
      begin
        llc_rx_valid_nxt_c    =   1'b1;
        fcs_en_nxt_c          =   config_l2_mac_rx_fcs_en;

        if(rx_data_valid_c  & (data_bytes_w ==  MAC_LEN_TYPE_OFFSET-1))
        begin
          next_state          =   LEN_TYPE_S;
        end
      end

      LEN_TYPE_S  :
      begin
        llc_rx_valid_nxt_c    =   1'b1;
        fcs_en_nxt_c          =   config_l2_mac_rx_fcs_en;

        if(rx_data_valid_c  & (data_bytes_w ==  MAC_DATA_OFFSET))
        begin
          next_state          =   (bffr_nxt_w ==  VLAN_TYPE_VALUE)  ? VLAN_TAG_S  : DATA_S;
        end
      end

      VLAN_TAG_S  :
      begin
        llc_rx_valid_nxt_c    =   1'b1;
        fcs_en_nxt_c          =   config_l2_mac_rx_fcs_en;

        if(rx_data_valid_c  & (data_bytes_w ==  MAC_VLAN_DATA_OFFSET))
        begin
          next_state          =   DATA_S;
        end
      end

      DATA_S  :
      begin
        llc_rx_valid_nxt_c    =   1'b1;
        fcs_en_nxt_c          =   config_l2_mac_rx_fcs_en;

        if(rx_data_valid_c  & rs_rx_eop)
        begin
          next_state          =   config_l2_mac_rx_strip_fcs  ? IDLE_S  : FCS_S;
        end
      end

      FCS_S :
      begin
        if(llc_rx_valid_del_vec_f ==  3'b000)
        begin
          next_state          =   IDLE_S;
        end
      end

    endcase
  end

  assign  preamble_valid_c    =   (bffr_nxt_w[55:0] ==  {7{PREAMBLE_VALUE}})  ? 1'b1  : 1'b0;
  assign  sfd_valid_c         =   (bffr_nxt_w[7:0]  ==  SFD_VALUE)  ? 1'b1  : 1'b0;

  /*  Output Buffer logic */
  always@(posedge clk,  negedge rst_n)
  begin
    if(~rst_n)
    begin
      rx_field_valid_vec      <=  0;
      rx_bffr                 <=  0;
    end
    else
    begin
      rx_bffr           <=  rx_data_valid_c ? bffr_nxt_w  : rx_bffr;

      rx_field_valid_vec[MAC_FIDX_DADDR]        <=  (data_bytes_w ==  MAC_SA_OFFSET-1)  ? rx_data_valid_c : 1'b0;
      rx_field_valid_vec[MAC_FIDX_SADDR]        <=  (data_bytes_w ==  MAC_LEN_TYPE_OFFSET-1)  ? rx_data_valid_c : 1'b0;
      rx_field_valid_vec[MAC_FIDX_LEN_TYPE]     <=  (data_bytes_w ==  MAC_DATA_OFFSET-1)  ? rx_data_valid_c : 1'b0;
      rx_field_valid_vec[MAC_FIDX_VLAN_TAG]     <=  (data_bytes_w ==  MAC_VLAN_DATA_OFFSET-1)  ? rx_data_valid_c  & vlan_frm_f  : 1'b0;
      rx_field_valid_vec[MAC_FIDX_CTRL_OPCODE]  <=  (data_bytes_w ==  MAC_PAUSE_TIME_OFFSET-1) ? rx_data_valid_c  & ctrl_frm_f  : 1'b0;
      rx_field_valid_vec[MAC_FIDX_PAUSE_TIME]   <=  (data_bytes_w ==  MAC_PAUSE_TIME_OFFSET+1) ? rx_data_valid_c  & pause_frm_f : 1'b0;
      rx_field_valid_vec[MAC_FIDX_FCS]          <=  (fsm_pstate ==  DATA_S) ? rx_data_valid_c  & rs_rx_eop  : 1'b0;
    end
  end

  assign  bffr_nxt_w          =   {rx_bffr[BFFR_SIZE-PKT_DATA_W-1:0],rs_rx_data};

endmodule // peg_l2_mac_rx_parser


/*
 --------------------------------------------------------------------------

 -- <Header>
 

 -- <Log>

[28-07-2014  12:13:48 PM][mammenx] Initial Commit

[28-05-14 20:18:21] [mammenx] Moved log section to bottom of file

 --------------------------------------------------------------------------
*/
