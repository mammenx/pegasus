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
 -- Module Name       : pkt_ff_wptr
 -- Author            : mammenx
 -- Associated modules: 
 -- Function          : This module maintains the write pointer logic for
                        the fifo.
 --------------------------------------------------------------------------
*/

`timescale 1ns / 10ps


module pkt_ff_wptr  #(PTR_W = 8)

(

  //--------------------- Misc Ports (Logic)  -----------
    clk,
    rst_n,

    valid,
    sop,
    eop,
    error.

    wptr

  //--------------------- Interfaces --------------------


);

//----------------------- Global parameters Declarations ------------------


//----------------------- Input Declarations ------------------------------
  input                       clk;
  input                       rst_n;

  input                       valid;
  input                       sop;
  input                       eop;
  input                       error;

//----------------------- Inout Declarations ------------------------------


//----------------------- Output Declarations -----------------------------
  output  [PTR_W-1:0]         wptr;

//----------------------- Output Register Declaration ---------------------


//----------------------- Internal Register Declarations ------------------
  logic   [PTR_W-1:0]         sop_ptr_f;

//----------------------- Internal Wire Declarations ----------------------
  logic                       wptr_rewind_n_c;
  logic                       wptr_inc_en_c;

//----------------------- Internal Interface Declarations -----------------


//----------------------- FSM Declarations --------------------------------


//----------------------- Start of Code -----------------------------------


  always@(posedge clk,  negedge rst_n)
  begin
    if(~rst_n)
    begin
      sop_ptr_f               <=  0;
    end
    else
    begin
      //Record the start of packet location for future rewind
      sop_ptr_f               <=  (valid  & sop)  ? wptr  : sop_ptr_f;

    end
  end

  //Reset the wptr to last SOP location
  assign  wptr_rewind_n_c     =   (valid & error) ? 1'b0  : rst_n;

  //Logic to decide when to increment wptr
  assign  wptr_inc_en_c       =   valid & ~error;

  //Implement wptr as a gray counter
  gry_cntr        u_wptr_gry_cntr
  (

    .clk          (clk),
    .rst_n        (wptr_rewind_n_c),

    .rst_val      (sop_ptr_f),

    .en           (wptr_inc_en_c),
    .gry_cnt      (wptr),
    .gry_cnt_nxt  ()

  );

  defparam  u_wptr_gry_cntr.WIDTH   = PTR_W;



endmodule // pkt_ff_wptr

/*
 --------------------------------------------------------------------------

 -- <Header>
 

 -- <Log>

[08-06-2014  02:11:10 PM][mammenx] Modified gry_cntr reset signal

[08-06-2014  02:07:20 PM][mammenx] Brought out gry_cnt_nxt port

[08-06-2014  12:54:08 PM][mammenx] Initial Commit

[28-05-14 20:18:21] [mammenx] Moved log section to bottom of file

 --------------------------------------------------------------------------
*/
