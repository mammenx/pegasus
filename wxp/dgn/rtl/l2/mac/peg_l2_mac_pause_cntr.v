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
 -- Module Name       : peg_l2_mac_pause_cntr
 -- Author            : mammenx
 -- Associated modules: 
 -- Function          : This block is a counter used to generate pause
                        intervals.
 --------------------------------------------------------------------------
*/

`timescale 1ns / 10ps


module peg_l2_mac_pause_cntr  #(
  
  parameter BPCLK             = 64,         //Bits per clock cycle
  parameter MAC_SPEED         = 100000000   //bps

)

(
  input         clk,
  input         rst_n,

  //Config
  input         pause_en,

  //Inputs from Parser
  input         pause_time_valid,
  input [15:0]  pause_time,

  //Pause Status
  output        pause_valid

);

//----------------------- Global parameters Declarations ------------------
  localparam  PAUSE_SCALE_FAC = $clog(512 / BPCLK);
  localparam  CNTR_W          = 16  + PAUSE_SCALE_FAC;

//----------------------- Input Declarations ------------------------------


//----------------------- Inout Declarations ------------------------------


//----------------------- Output Declarations -----------------------------


//----------------------- Output Register Declaration ---------------------


//----------------------- Internal Register Declarations ------------------
  reg   [15:0]                pause_time_f;
  reg   [CNTR_W-1:0]          pause_cntr_f;

//----------------------- Internal Wire Declarations ----------------------


//----------------------- Input/Output Registers --------------------------

//----------------------- Start of Code -----------------------------------

  always@(posedge clk,  negedge rst_n)
  begin
    if(~rst_n)
    begin
      pause_time_f            <=  0;
      pause_cntr_f            <=  0;
    end
    else
    begin
      //Register the pause time from parser
      pause_time_f            <=  pause_time_valid  ? pause_time  : pause_time_f;

      //Counter logic
      if(pause_valid)
      begin
        pause_cntr_f          <=  0;
      end
      else if(pause_en)
      begin
        pause_cntr_f          <=  pause_cntr_f  + 1'b1;
      end
      else
      begin
        pause_cntr_f          <=  pause_cntr_f;
      end
    end
  end

  //Generate status
  assign  pause_en            =   (pause_time_f > pause_cntr_f[CNTR_W-1:PAUSE_SCALE_FAC]) ? 1'b1  : 1'b0;

endmodule // peg_l2_mac_pause_cntr


/*
 --------------------------------------------------------------------------

 -- <Header>
 

 -- <Log>

[02-07-2014  12:52:58 AM][mammenx] Initial version

[28-05-14 20:18:21] [mammenx] Moved log section to bottom of file

 --------------------------------------------------------------------------
*/
