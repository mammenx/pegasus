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
 -- Module Name       : peg_l2_mac_tx_framer
 -- Author            : mammenx
 -- Associated modules: 
 -- Function          : This module contains the logic to frame L2 MAC frames
                        for transmission. This has a 8b pipeline that is
                        intended for upto 1Gbps speeds @ 125MHz clock.
 --------------------------------------------------------------------------
*/

`timescale 1ns / 10ps


module peg_l2_mac_tx_framer #(

  parameter PKT_DATA_W        = 8,
  parameter PKT_SIZE_W        = 16

)

(

  input                       clk,
  input                       rst_n,

  //Config interface
  input                       config_l2_mac_tx_en,
  input                       config_l2_mac_tx_padding_en,
  input                       config_l2_mac_tx_fcs_en,
  input   [47:0]              config_l2_mac_addr,
  input                       config_l2_mac_tx_pause_gen,
  input   [15:0]              config_l2_mac_tx_pause_time,

  //Status interface
  output  [3:0]               l2_mac_tx_fsm_state,

  //Pause Interface from MAC RX
  input                       mac_pause_en,

  //MAC Logic Link Control packet interface
  input                       llc_tx_valid,
  input                       llc_tx_sop,
  input                       llc_tx_eop,
  input   [PKT_DATA_W-1:0]    llc_tx_data,
  output                      llc_tx_ready,
  input                       llc_tx_error,

  //RS packet interface
  output                      rs_tx_valid,
  output                      rs_tx_sop,
  output                      rs_tx_eop,
  output  [PKT_DATA_W-1:0]    rs_tx_data,
  input                       rs_tx_ready,
  output                      rs_tx_error

);

//----------------------- Global parameters Declarations ------------------
  `include  "peg_l2_params.v"

  parameter PKT_SIZE_INC_VAL  = PKT_DATA_W  / 8;
  parameter DATA_BFFR_SIZE    = 5*8;

//----------------------- Input Declarations ------------------------------


//----------------------- Inout Declarations ------------------------------


//----------------------- Output Declarations -----------------------------


//----------------------- Output Register Declaration ---------------------
  reg                         llc_tx_ready;

//----------------------- Internal Register Declarations ------------------
  reg   [15:0]                data_cntr_f;
  reg   [DATA_BFFR_SIZE-1:0]  data_bffr_f;
  reg   [15:0]                final_pkt_size_f;
  reg                         crc_en_f;
  reg   [31:0]                crc_f;
  reg                         pause_frm_f;

//----------------------- Internal Wire Declarations ----------------------
  wire  [15:0]                data_bytes_w;
  wire  [DATA_BFFR_SIZE+PKT_DATA_W-1:0] data_bffr_w;
  wire                        padding_required_c;
  wire  [PKT_DATA_W-1:0]      crc_data_c;
  wire                        state_change_c;
  wire  [31:0]                fcs_c;
  wire  [2:0]                 fcs_index_c;

  genvar i;

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
PAUSE_OPCODE_S      = 4'd7,
PAUSE_TIME_S        = 4'd8,
DATA_S              = 4'd9,
PADDING_S           = 4'd10,
FCS_S               = 4'd11;

//----------------------- FSM Register Declarations ------------------
reg           [3:0]                            // synopsys enum fsm_pstate
fsm_pstate, next_state;

//----------------------- FSM String Declarations ------------------
//synthesis translate_off
reg           [8*16:0]     state_name;//"state name" is user defined
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

PAUSE_OPCODE_S    : state_name = "PAUSE_OPCODE_S";

PAUSE_TIME_S      : state_name = "PAUSE_TIME_S";

VLAN_TAG_S        : state_name = "VLAN_TAG_S";

DATA_S            : state_name = "DATA_S";

PADDING_S         : state_name = "PADDING_S";

FCS_S             : state_name = "FCS_S";

default           : state_name = "INVALID STATE!";
endcase
end
//synthesis translate_on

//----------------------- Input/Output Registers --------------------------

//----------------------- Start of Code -----------------------------------


  /*  Main FSM Logic  */
  always@(posedge clk,  negedge rst_n)
  begin
    if(~rst_n)
    begin
      fsm_pstate              <=  IDLE_S;
      data_cntr_f             <=  0;
      data_bffr_f             <=  0;
      final_pkt_size_f        <=  0;
      pause_frm_f             <=  0;
    end
    else
    begin
      fsm_pstate              <=  next_state;

      if(fsm_pstate ==  IDLE_S)
      begin
        pause_frm_f           <=  config_l2_mac_tx_en & config_l2_mac_tx_pause_gen; 
      end
      else if(fsm_pstate  ==  FCS_S)
      begin
        pause_frm_f           <=  1'b0;
      end

      if(fsm_pstate ==  IDLE_S)
      begin
        data_cntr_f           <=  0;
      end
      else if(rs_tx_valid & rs_tx_ready)
      begin
        data_cntr_f           <=  data_cntr_f + 1'b1;
      end

      if(rs_tx_valid  & rs_tx_ready)
      begin
        data_bffr_f           <=  {data_bffr_f[DATA_BFFR_SIZE-PKT_DATA_W-1:0],rs_tx_data};
      end

      if((fsm_pstate  !=  FCS_S)  & (next_state ==  FCS))
      begin
        final_pkt_size_f      <=  data_cntr_f + 3'd4;
      end
    end
  end

  assign  data_bffr_w         =   {data_bffr_f,rs_tx_data};

  assign  data_bytes_w        =   data_cntr_f;

  //Check if pkt has minimum size
  assign  padding_required_c  =   (data_bytes_w < MAC_MIN_FRM_LEN)  ? (config_l2_mac_tx_padding_en  | pause_frm_f)  : 1'b0;

  assign  state_change_c      =   (next_state !=  fsm_pstate) ? 1'b1  : 1'b0;

  always@(*)
  begin
    next_state                =   fsm_pstate;
    llc_tx_ready              =   1'b0;

    case(fsm_pstate)

      IDLE_S  :
      begin
        if(((llc_tx_valid & llc_tx_sop) | config_l2_mac_tx_pause_gen)   & config_l2_mac_tx_en)
        begin
          next_state          =   PREAMBLE_S;
        end
      end

      PREAMBLE_S  :
      begin
        if((llc_tx_valid | pause_frm_f) & rs_tx_ready & (data_bytes_w  ==  (MAC_SFD_OFFSET-1)))
        begin
          next_state          =   SFD_S;
        end
      end

      SFD_S :
      begin
        if((llc_tx_valid | pause_frm_f) & rs_tx_ready & (data_bytes_w  ==  (MAC_DA_OFFSET-1)))
          llc_tx_ready        =   ~pause_frm_f;
          next_state          =   DA_S;
        end
      end

      DA_S  :
      begin
        if((llc_tx_valid | pause_frm_f) & rs_tx_ready & (data_bytes_w  ==  (MAC_SA_OFFSET-1)))
        begin
          llc_tx_ready        =   ~pause_frm_f;
          next_state          =   SA_S;
        end
      end

      SA_S  :
      begin
        if((llc_tx_valid | pause_frm_f) & rs_tx_ready & (data_bytes_w  ==  (MAC_LEN_TYPE_OFFSET-1)))
        begin
          llc_tx_ready        =   ~pause_frm_f;
          next_state          =   LEN_TYPE_S;
        end
      end

      LEN_TYPE_S  :
      begin
        if(rs_tx_ready & (data_bytes_w  ==  (MAC_DATA_OFFSET-1)))
        begin
          llc_tx_ready        =   llc_tx_valid  & ~pause_frm_f;

          if(pause_frm_f)
          begin
            next_state        =   PAUSE_OPCODE_S;
          end
          else if(llc_tx_valid)
          begin
            if(data_bffr_w[15:0]  ==  VLAN_TYPE_VALUE)
            begin
              next_state      =   VLAN_TAG_S;
            end
            else
            begin
              next_state      =   DATA_S;
            end
          end
        end
      end

      PAUSE_OPCODE_S  :
      begin
        if(rs_tx_ready  & (data_bytes_w  ==  MAC_PAUSE_TIME_OFFSET-1))
        begin
          next_state          =   PAUSE_TIME_S;
        end
      end

      PAUSE_TIME_S  :
      begin
        if(rs_tx_ready  & (data_bytes_w  ==  MAC_PAUSE_TIME_OFFSET+1))
        begin
          next_state          =   PADDING_S;
        end
      end

      VLAN_TAG_S  :
      begin
        if(llc_tx_valid & rs_tx_ready & (data_bytes_w  ==  (MAC_VLAN_DATA_OFFSET-1)))
        begin
          llc_tx_ready        =   1'b1;
          next_state          =   DATA_S;
        end
      end

      DATA_S  :
      begin
        if(llc_tx_valid & llc_tx_eop  & rs_tx_ready)
        begin
          llc_tx_ready        =   1'b1;

          if(padding_required_c)
          begin
            next_state        =   PADDING_S;
          end
          else if(config_l2_mac_tx_fcs_en)
          begin
            next_state        =   FCS_S;
          end
          else
          begin
            next_state        =   IDLE_S;
          end
        end
      end

      PADDING_S :
      begin
        if(~padding_required_c  & rs_tx_ready)
        begin
          next_state          =   FCS_S;
        end
      end

      FCS :
      begin
        if((data_bytes_w ==  final_pkt_size_f) & rs_tx_ready))
        begin
          next_state          =   IDLE_S;
        end
      end

    endcase
  end

  //First 32b of CRC data input should be complimented
  assign  crc_data_c          =   (data_cntr_f  <=  4)  ? ~llc_tx_data  :
                                    ((fsm_pstate == PADDING_S)  ? 0 : llc_tx_data);

  /*  FCS Calculation Logic */
  always@(posedge clk,  negedge rst_n)
  begin
    if(~rst_n)
    begin
      crc_en_f                <=  0;
      crc_f                   <=  0;
    end
    else
    begin
      if(next_state ==  FCS_S)
      begin
        crc_en_f              <=  state_change_c  ? 1'b0  : crc_en_f;
      end
      else if(fsm_pstate ==  PREAMBLE_S)
      begin
        crc_en_f              <=  state_change_c  & config_l2_mac_tx_fcs_en;
      end

      if(fsm_pstate ==  IDLE_S)
      begin
        crc_f                 <=  0;
      end
      else if(crc_en_f & llc_tx_valid)
      begin
        crc_f                 <=  nextCRC32_D8(crc_data_c, crc_f);
      end
    end
  end

  //FCS is bit reversed & complimented version of CRC
  generate
    for(i=0;  i<32; i++)
    begin
      assign  fcs_c[i]        =   ~crc_f[31-i];
    end
  endgenerate

  assign  fcs_index_c         =   {(final_pkt_size_f[2:0] - data_cntr_f[2:0]),  {$clog2(PKT_DATA_W){1'b0}}};

  /*  Data framing logic  */
  always@(posedge clk,  negedge rst_n)
  begin
    if(~rst_n)
    begin
      rs_tx_valid             <=  0;
      rs_tx_sop               <=  0;
      rs_tx_eop               <=  0;
      rs_tx_data              <=  0;
      rs_tx_error             <=  0;
    end
    else
    begin
      case(fsm_pstate)

        IDLE_S  :
        begin
          rs_tx_valid         <=  state_change_c  ? 1'b1  : 1'b0;
          rs_tx_sop           <=  state_change_c  ? 1'b1  : 1'b0;
          rs_tx_eop           <=  0;
          rs_tx_data          <=  PREAMBLE_VALUE;
          rs_tx_error         <=  0;
        end

        PREAMBLE_S  :
        begin
          rs_tx_valid         <=  1'b1;
          rs_tx_sop           <=  rs_tx_sop & ~rs_tx_ready;
          rs_tx_eop           <=  0;
          rs_tx_data          <=  state_change_c  ? SFD_VALUE  : rs_tx_data;
          rs_tx_error         <=  0;
        end

        SFD_S,
        SA_S,
        DA_S,
        LEN_TYPE_S,
        VLAN_TAG_S  :
        begin
          rs_tx_valid         <=  1'b1;
          rs_tx_sop           <=  0;
          rs_tx_eop           <=  0;

          if(pause_frm_f)
          begin
            rs_tx_data        <=  (data_bytes_w ==  MAC_LEN_TYPE_OFFSET)  ? CTRL_TYPE_VALUE[7:0]  : CTRL_TYPE_VALUE[15:8];
          end
          else if(state_change_c)
          begin
            rs_tx_data        <=  llc_tx_data;
          end
          else
          begin
            rs_tx_data        <=  rs_tx_data;
          end

          rs_tx_error         <=  0;
        end

        PAUSE_OPCODE_S  :
        begin
          rs_tx_valid         <=  1'b1;
          rs_tx_sop           <=  0;
          rs_tx_eop           <=  1'b0;
          rs_tx_data          <=  (data_cntr_f  ==  MAC_CTRL_OPCODE_OFFSET) ? PAUSE_CTRL_OPCODE[7:0]  : PAUSE_CTRL_OPCODE[15:8];
          rs_tx_error         <=  0;
        end

        PAUSE_TIME_S  :
        begin
          rs_tx_valid         <=  1'b1;
          rs_tx_sop           <=  0;
          rs_tx_eop           <=  1'b0;
          rs_tx_data          <=  (data_cntr_f  ==  MAC_PAUSE_TIME_OFFSET) ?
                                      config_l2_mac_tx_pause_time[7:0] :
                                      config_l2_mac_tx_pause_time[15:8];
          rs_tx_error         <=  0;
        end

        DATA_S  :
        begin
          rs_tx_valid         <=  1'b1;
          rs_tx_sop           <=  0;
          rs_tx_eop           <=  (next_state ==  IDLE_S) 1'b1  : 1'b0;
          rs_tx_data          <=  state_change_c  ? llc_tx_data : rs_tx_data;
          rs_tx_error         <=  0;
        end

        PADDING_S :
        begin
          rs_tx_valid         <=  1'b1;
          rs_tx_sop           <=  0;
          rs_tx_eop           <=  0;
          rs_tx_data          <=  0;
          rs_tx_error         <=  0;
        end

        FCS :
        begin
          rs_tx_valid         <=  state_change_c  ? 1'b0  : 1'b1;
          rs_tx_sop           <=  0;
          rs_tx_eop           <=  state_change_c  ? 1'b1  : 1'b0;
          rs_tx_data          <=  crc_f[fcs_index_c +:  PKT_DATA_W];
          rs_tx_error         <=  0;
        end

      endcase
    end
  end

endmodule // peg_l2_mac_tx_framer


/*
 --------------------------------------------------------------------------

 -- <Header>
 

 -- <Log>

[28-07-2014  12:12:47 PM][mammenx] Added Pause Frame support

[02-07-2014  12:52:58 AM][mammenx] Initial version

[28-05-14 20:18:21] [mammenx] Moved log section to bottom of file

 --------------------------------------------------------------------------
*/
