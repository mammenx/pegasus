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
 -- Module Name       : dd_sync
 -- Author            : mammenx
 -- Associated modules: 
 -- Function          : This module synchronizes a signal (of parameterized
                        width) to the destination clock.
 --------------------------------------------------------------------------
*/

`timescale 1ns / 10ps


module dd_sync  #(WIDTH = 1,  STAGES  = 2,  RST_VAL = 0)

(

  //--------------------- Misc Ports (Logic)  -----------
    clk,
    rst_n,

    data_i,
    data_sync_o

  //--------------------- Interfaces --------------------


);

//----------------------- Global parameters Declarations ------------------


//----------------------- Input Declarations ------------------------------
  input                       clk;
  input                       rst_n;

  input   [WIDTH-1:0]         data_i;

//----------------------- Inout Declarations ------------------------------


//----------------------- Output Declarations -----------------------------
  output  [WIDTH-1:0]         data_sync_o;

//----------------------- Output Register Declaration ---------------------


//----------------------- Internal Register Declarations ------------------
  logic   [WIDTH-1:0]         sync_pipe_f [STAGES-1:0];

//----------------------- Internal Wire Declarations ----------------------


//----------------------- Internal Interface Declarations -----------------


//----------------------- FSM Declarations --------------------------------


//----------------------- Start of Code -----------------------------------

  genvar  i;

  generate
    for(i=0;  i<STAGES; i++)
    begin : SYNC
      always@(posedge clk,  negedge rst_n)
      begin
        if(~rst_n)
        begin
          sync_pipe_f[i]      <=  RST_VAL;
        end
        else
        begin
          sync_pipe_f[i]      <=  (i  ==  0)  ? data_i  : sync_pipe_f[i-1];
        end
      end
    end
  endgenerate

  assign  data_sync_o = sync_pipe_f[STAGES-1];

endmodule // dd_sync

/*
 --------------------------------------------------------------------------

 -- <Header>
 

 -- <Log>

[08-06-2014  11:11:26 AM][mammenx] Added RST_VAL parameter

[08-06-2014  11:09:00 AM][mammenx] Initial Version

[28-05-14 20:18:21] [mammenx] Moved log section to bottom of file

 --------------------------------------------------------------------------
*/
