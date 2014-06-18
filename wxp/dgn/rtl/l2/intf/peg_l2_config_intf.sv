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
 -- Interface Name    : peg_l2_config_intf
 -- Author            : mammenx
 -- Function          : This interface has all the signals needed for
                        the configuration of L2 block.
 --------------------------------------------------------------------------
*/

interface peg_l2_config_intf (input logic clk,rst_n);

  //Logic signals
  logic               rs_mii_speed_100_n_10;

  //Wire Signals


  //Tasks & Functions


  //Modports
  modport   master  (
                      output  rs_mii_speed_100_n_10
                    );

  modport   rs      (
                      input   rs_mii_speed_100_n_10
                    );


endinterface  //  peg_l2_config_intf

/*
 --------------------------------------------------------------------------

 -- <Header>
 

 -- <Log>

[18-06-2014  07:27:24 PM][mammenx] Initial Commit

[28-05-14 20:18:21] [mammenx] Moved log section to bottom of file

 --------------------------------------------------------------------------
*/
