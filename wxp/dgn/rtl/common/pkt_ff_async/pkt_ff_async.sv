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


  //--------------------- Interfaces --------------------
  clk_rst_sync_intf           cr_ingr_intf,
  clk_rst_sync_intf           cr_egr_intf,

  peg_pkt_xfr_intf            pkt_ingr_intf,  //slave
  peg_pkt_xfr_intf            pkt_egr_intf    //master

);

//----------------------- Global parameters Declarations ------------------
  localparam  PTR_W           =   $clog2(DEPTH);

//----------------------- Input Declarations ------------------------------


//----------------------- Inout Declarations ------------------------------


//----------------------- Output Declarations -----------------------------


//----------------------- Output Register Declaration ---------------------


//----------------------- Internal Register Declarations ------------------
  logic [PTR_W-1:0]           credit_cnt_ingr_f;
  logic                       credit_ingr_push_f;
  logic [PTR_W-1:0]           credit_cnt_egr_f;


//----------------------- Internal Wire Declarations ----------------------
  logic [PTR_W-1:0]           wptr_w;
  logic [PTR_W-1:0]           rptr_w;

  logic                       data_ff_rd_en_c;
  logic                       data_ff_wr_en_c;

  logic                       credit_ff_full_w;
  logic                       credit_ff_empty_w;
  logic [PTR_W-1:0]           credit_ff_rdata_w;
  logic                       credit_egr_pop_c;

//----------------------- Internal Interface Declarations -----------------


//----------------------- FSM Declarations --------------------------------



//----------------------- Start of Code -----------------------------------

  //Generate read/write signals for data fifo
  assign  data_ff_wr_en_c     = pkt_ingr_intf.valid & pkt_ingr_intf.ready & ~pkt_ingr_intf.error;
  assign  data_ff_rd_en_c     = pkt_egr_intf.valid  & pkt_egr_intf.ready;

  pkt_ff_wptr                 u_wptr
  (
    .clk                      (cr_ingr_intf.clk),
    .rst_n                    (cr_ingr_intf.rst_n),

    .valid                    (pkt_ingr_intf.valid),
    .sop                      (pkt_ingr_intf.sop),
    .eop                      (pkt_ingr_intf.eop),
    .error                    (pkt_ingr_intf.error),

    .wptr                     (wptr_w)

  );
  defparam  u_wptr.PTR_W      = PTR_W;


  pkt_ff_rptr                 u_rptr
  (
    .clk                      (cr_egr_intf.clk),
    .rst_n                    (cr_egr_intf.rst_n),

    .rd_en                    (data_ff_rd_en_c),

    .rptr                     (rptr_w)

  );
  defparam  u_rptr.PTR_W      = PTR_W;


  pkt_ff_async_mem            u_mem
  (
    .data                     (pkt_ingr_intf.data),
    .rdaddress                (rptr_w),
    .rdclock                  (cr_egr_intf.clk),
    .wraddress                (wptr_w),
    .wrclock                  (cr_ingr_intf.clk),
    .wren                     (data_ff_wr_en_c),
    .q                        (pkt_egr_intf.data)
  );
  defparam  u_mem.DWIDTH      = WIDTH;
  defparam  u_mem.DEPTH       = DEPTH;



  /*
    * Credit management logic
  */
  always@(posedge cr_ingr_intf.clk, negedge cr_ingr_intf.rst_n)
  begin
    if(~cr_ingr_intf.rst_n)
    begin
      credit_cnt_ingr_f       <=  0;
      credit_ingr_push_f      <=  0;
    end
    else
    begin
      if(pkt_ingr_intf.valid & pkt_ingr_intf.ready)
      begin
        if(pkt_ingr_intf.sof)
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

      credit_ingr_push_f      <=  pkt_ingr_intf.valid & pkt_ingr_intf.ready &
                                  pkt_ingr_intf.eof   & ~pkt_ingr_intf.error;
    end
  end

  always@(posedge cr_egr_intf.clk, negedge cr_egr_intf.rst_n)
  begin
    if(~cr_egr_intf.rst_n)
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
      else if(pkt_egr_intf.ready)
      begin
        credit_cnt_egr_f      <=  credit_cnt_egr_f  - WIDTH;
      end
    end
  end

  assign  pkt_egr_intf.valid  = (credit_cnt_egr_f > 0)  ? 1'b1  : 1'b0;
  assign  pkt_egr_intf.sop    = (credit_cnt_egr_f ==  credit_ff_rdata_w)  ? ~credit_ff_empty_w  : 1'b0;
  assign  pkt_egr_intf.eop    = (credit_cnt_egr_f <=  WIDTH)  ? pkt_egr_intf.valid  : 1'b0;
  assign  pkt_egr_intf.error  = 0;

  assign  credit_egr_pop_c    = pkt_egr_intf.eop  & pkt_egr_intf.ready;

  assign  pkt_ingr_intf.ready = ~credit_ff_full_w;


  credit_ff_async             u_credit_ff
  (
    .aclr                     (cr_ingr_intf.rst_n | cr_egr_intf.rst_n),
    .data                     (credit_cnt_ingr_f),
    .rdclk                    (cr_egr_intf.clk),
    .rdreq                    (credit_egr_pop_c),
    .wrclk                    (cr_ingr_intf.clk),
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

[08-06-2014  04:16:44 PM][mammenx] Initial Commit

[28-05-14 20:18:21] [mammenx] Moved log section to bottom of file

 --------------------------------------------------------------------------
*/
