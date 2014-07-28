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
 -- Module Name       : peg_l2_fcs_gen
 -- Author            : mammenx
 -- Associated modules: 
 -- Function          : This module generates FCS from the data stream.
 --------------------------------------------------------------------------
*/

`timescale 1ns / 10ps


module peg_l2_fcs_gen #(
  parameter DATA_W        = 8,
  parameter CRC_INIT_VAL  = 32'd0
)

(
  input                       clk,
  input                       rst_n,

  input                       fcs_calc_rst,
  input                       fcs_calc_valid,
  input   [DATA_W-1:0]        fcs_calc_data,

  output  [31:0]              fcs

);

//----------------------- Global parameters Declarations ------------------


//----------------------- Input Declarations ------------------------------


//----------------------- Inout Declarations ------------------------------


//----------------------- Output Declarations -----------------------------


//----------------------- Output Register Declaration ---------------------


//----------------------- Internal Register Declarations ------------------
  reg   [31:0]                crc_f;

  genvar  i;

//----------------------- Internal Wire Declarations ----------------------


//----------------------- Input/Output Registers --------------------------

//----------------------- Start of Code -----------------------------------

  always@(posedge clk,  negedge rst_n)
  begin
    if(~rst_n)
    begin
      crc_f                   <=  CRC_INIT_VAL;
    end
    else
    begin
      if(fcs_calc_rst)
      begin
        crc_f                 <=  CRC_INIT_VAL;
      end
      else if(fcs_calc_valid)
      begin
        crc_f                 <=  nextCRC32_D8(fcs_calc_data,crc_f);
      end
    end
  end

  //FCS is bit reversed & complimented version of CRC
  generate
    for(i=0;  i<32; i++)
    begin
      assign  fcs[i]        =   ~crc_f[31-i];
    end
  endgenerate


endmodule // peg_l2_fcs_gen


/*
 --------------------------------------------------------------------------

 -- <Header>
 

 -- <Log>

[28-07-2014  04:18:29 PM][mammenx] Created basic wrapper

[28-05-14 20:18:21] [mammenx] Moved log section to bottom of file

 --------------------------------------------------------------------------
*/
