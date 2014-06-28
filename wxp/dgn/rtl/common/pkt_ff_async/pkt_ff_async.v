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
 -- Module Name       : pkt_ff_async
 -- Author            : mammenx
 -- Associated modules: pkt_ff_async_mem, pkt_ff_rptr, pkt_ff_wptr
 -- Function          : The top module for pkt_ff_async.
 --------------------------------------------------------------------------
*/

`timescale 1ns / 10ps


module pkt_ff_async #(WIDTH = 32, DEPTH = 128,  MAX_NO_PKTS=2)
(

  //--------------------- Misc Ports (Logic)  -----------
  input                       ingr_clk,
  input                       ingr_rst_n,

  input                       egr_clk,
  input                       egr_rst_n,

  //Ingress packet interface
  input                       ingr_valid,
  input                       ingr_sop,
  input                       ingr_eop,
  input   [WIDTH-1:0]         ingr_data,
  output                      ingr_ready,
  input                       ingr_error,

  //Egress packet interface
  output                      egr_valid,
  output                      egr_sop,
  output                      egr_eop,
  output  [WIDTH-1:0]         egr_data,
  input                       egr_ready,
  output                      egr_error

  //--------------------- Interfaces --------------------

);

//----------------------- Global parameters Declarations ------------------
  localparam  PTR_W           =   $clog2(DEPTH);

//----------------------- Input Declarations ------------------------------


//----------------------- Inout Declarations ------------------------------


//----------------------- Output Declarations -----------------------------


//----------------------- Output Register Declaration ---------------------


//----------------------- Internal Register Declarations ------------------
  reg   [PTR_W-1:0]           credit_cnt_ingr_f;
  reg                         credit_ingr_push_f;
  reg   [PTR_W-1:0]           credit_cnt_egr_f;


//----------------------- Internal Wire Declarations ----------------------
  wire  [PTR_W-1:0]           wptr_w;
  wire  [PTR_W-1:0]           rptr_w;

  wire                        data_ff_rd_en_c;
  wire                        data_ff_wr_en_c;

  wire                        credit_ff_full_w;
  wire                        credit_ff_empty_w;
  wire  [PTR_W-1:0]           credit_ff_rdata_w;
  wire                        credit_egr_pop_c;

//----------------------- Internal Interface Declarations -----------------


//----------------------- FSM Declarations --------------------------------



//----------------------- Start of Code -----------------------------------

  //Generate read/write signals for data fifo
  assign  data_ff_wr_en_c     = ingr_valid & ingr_ready & ~ingr_error;
  assign  data_ff_rd_en_c     = egr_valid  & egr_ready;

  pkt_ff_wptr                 u_wptr
  (
    .clk                      (ingr_clk),
    .rst_n                    (ingr_rst_n),

    .valid                    (ingr_valid),
    .sop                      (ingr_sop),
    .eop                      (ingr_eop),
    .error                    (ingr_error),

    .wptr                     (wptr_w)

  );
  defparam  u_wptr.PTR_W      = PTR_W;


  pkt_ff_rptr                 u_rptr
  (
    .clk                      (egr_clk),
    .rst_n                    (egr_rst_n),

    .rd_en                    (data_ff_rd_en_c),

    .rptr                     (rptr_w)

  );
  defparam  u_rptr.PTR_W      = PTR_W;


  pkt_ff_async_mem            u_mem
  (
    .data                     (ingr_data),
    .rdaddress                (rptr_w),
    .rdclock                  (egr_clk),
    .wraddress                (wptr_w),
    .wrclock                  (ingr_clk),
    .wren                     (data_ff_wr_en_c),
    .q                        (egr_data)
  );
  defparam  u_mem.DWIDTH      = WIDTH;
  defparam  u_mem.DEPTH       = DEPTH;



  /*
    * Credit management logic
  */
  always@(posedge ingr_clk, negedge ingr_rst_n)
  begin
    if(~ingr_rst_n)
    begin
      credit_cnt_ingr_f       <=  0;
      credit_ingr_push_f      <=  0;
    end
    else
    begin
      if(ingr_valid & ingr_ready)
      begin
        if(ingr_sof)
        begin
          credit_cnt_ingr_f   <=  WIDTH;
        end
        else
        begin
          credit_cnt_ingr_f   <=  credit_cnt_ingr_f + WIDTH;
        end
      end
      else
      begin
        credit_cnt_ingr_f     <=  credit_cnt_ingr_f;
      end

      credit_ingr_push_f      <=  ingr_valid & ingr_ready &
                                  ingr_eof   & ~ingr_error;
    end
  end

  always@(posedge egr_clk, negedge egr_rst_n)
  begin
    if(~egr_rst_n)
    begin
      credit_cnt_egr_f        <=  0;
    end
    else
    begin
      if(credit_cnt_egr_f ==  0)
      begin
        if(~credit_ff_empty_w)
        begin
          credit_cnt_egr_f    <=  credit_ff_rdata_w;
        end
      end
      else if(egr_ready)
      begin
        credit_cnt_egr_f      <=  credit_cnt_egr_f  - WIDTH;
      end
    end
  end

  assign  egr_valid  = (credit_cnt_egr_f > 0)  ? 1'b1  : 1'b0;
  assign  egr_sop    = (credit_cnt_egr_f ==  credit_ff_rdata_w)  ? ~credit_ff_empty_w  : 1'b0;
  assign  egr_eop    = (credit_cnt_egr_f <=  WIDTH)  ? egr_valid  : 1'b0;
  assign  egr_error  = 0;

  assign  credit_egr_pop_c    = egr_eop  & egr_ready;

  assign  ingr_ready = ~credit_ff_full_w;


  credit_ff_async             u_credit_ff
  (
    .aclr                     (~ingr_rst_n  | ~egr_rst_n),
    .data                     (credit_cnt_ingr_f),
    .rdclk                    (egr_clk),
    .rdreq                    (credit_egr_pop_c),
    .wrclk                    (ingr_clk),
    .wrreq                    (credit_ingr_push_f),
    .q                        (credit_ff_rdata_w),
    .rdempty                  (credit_ff_empty_w),
    .wrfull                   (credit_ff_full_w)
  );
  defparam  u_credit_ff.WIDTH = PTR_W;
  defparam  u_credit_ff.DEPTH = MAX_NO_PKTS;



endmodule // pkt_ff_async

/*
 --------------------------------------------------------------------------

 -- <Header>
 

 -- <Log>

[28-06-2014  03:30:57 PM][mammenx] Moved to Verilog

[08-06-2014  04:16:44 PM][mammenx] Initial Commit

[28-05-14 20:18:21] [mammenx] Moved log section to bottom of file

 --------------------------------------------------------------------------
*/
