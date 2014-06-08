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
 -- Module Name       : pkt_ff_rptr
 -- Author            : mammenx
 -- Associated modules: 
 -- Function          : This module maintains logic for updating the read
                        pointer.
 --------------------------------------------------------------------------
*/

`timescale 1ns / 10ps


module pkt_ff_rptr  #(PTR_W = 8)
(

  //--------------------- Misc Ports (Logic)  -----------
    clk,
    rst_n,

    rd_en,

    rptr

  //--------------------- Interfaces --------------------


);

//----------------------- Global parameters Declarations ------------------


//----------------------- Input Declarations ------------------------------
  input                       clk;
  input                       rst_n;

  input                       rd_en;

//----------------------- Inout Declarations ------------------------------


//----------------------- Output Declarations -----------------------------
  output  [PTR_W-1:0]         rptr;

//----------------------- Output Register Declaration ---------------------


//----------------------- Internal Register Declarations ------------------


//----------------------- Internal Wire Declarations ----------------------


//----------------------- Internal Interface Declarations -----------------


//----------------------- FSM Declarations --------------------------------


//----------------------- Start of Code -----------------------------------

  //Implement rptr as a gray counter
  gry_cntr        u_rptr_gry_cntr
  (

    .clk          (clk),
    .rst_n        (rst_n),

    .rst_val      ({PTR_W{1'b0}}),

    .en           (rd_en),
    .gry_cnt      (),
    .gry_cnt_nxt  (rptr)

  );

  defparam  u_rptr_gry_cntr.WIDTH   = PTR_W;


endmodule // pkt_ff_rptr

/*
 --------------------------------------------------------------------------

 -- <Header>
 

 -- <Log>

[08-06-2014  02:14:35 PM][mammenx] Initial Commit

[28-05-14 20:18:21] [mammenx] Moved log section to bottom of file

 --------------------------------------------------------------------------
*/
