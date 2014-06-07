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
 -- Module Name       : gry_cntr
 -- Author            : mammenx
 -- Associated modules: 
 -- Function          : A parameterized gray code counter.
 --------------------------------------------------------------------------
*/

`timescale 1ns / 10ps


module gry_cntr #(WIDTH = 8)

  (

  //--------------------- Misc Ports (Logic)  -----------
    clk,
    rst_n,

    en,
    gry_cnt


  //--------------------- Interfaces --------------------


  );

//----------------------- Global parameters Declarations ------------------


//----------------------- Input Declarations ------------------------------
  input                       clk;
  input                       rst_n;

  input                       en;

//----------------------- Inout Declarations ------------------------------


//----------------------- Output Declarations -----------------------------
  output  logic [WIDTH-1:0]   gry_cnt;

//----------------------- Output Register Declaration ---------------------


//----------------------- Internal Register Declarations ------------------
  logic [WIDTH-1:0]           bin_cnt_f;

//----------------------- Internal Wire Declarations ----------------------
  logic [WIDTH-1:0]           bin_cnt_nxt_c;

//----------------------- Internal Interface Declarations -----------------


//----------------------- FSM Declarations --------------------------------


//----------------------- Start of Code -----------------------------------

  always@(posedge clk,  negedge rst_n)
  begin
    if(~rst_n)
    begin
      bin_cnt_f               <=  0;
      gry_cnt                 <=  0;
    end
    else
    begin
      bin_cnt_f               <=  bin_cnt_nxt_c;
      gry_cnt                 <=  bin_cnt_nxt_c ^ {1'b0,bin_cnt_nxt_c[WIDTH-1:1]};
    end
  end

  assign  bin_cnt_nxt_c = bin_cnt_f + en;

endmodule // gry_cntr

/*
 --------------------------------------------------------------------------

 -- <Header>
 

 -- <Log>

[07-06-2014  09:55:48 PM][mammenx] Initial version

[28-05-14 20:18:21] [mammenx] Moved log section to bottom of file

 --------------------------------------------------------------------------
*/
