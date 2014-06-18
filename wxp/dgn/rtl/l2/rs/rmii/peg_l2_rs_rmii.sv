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
 -- Module Name       : peg_l2_rs_rmii
 -- Author            : mammenx
 -- Associated modules: 
 -- Function          : The top level wrapper for RMII reconciliation layer.
 --------------------------------------------------------------------------
*/

`timescale 1ns / 10ps


module peg_l2_rs_rmii (

  //--------------------- Misc Ports (Logic)  -----------


  //--------------------- Interfaces --------------------
  clk_rst_sync_intf           cr_intf,

  peg_l2_config_intf          config_intf,  //rs

  peg_pkt_xfr_intf            tx_pkt_intf,  //slave, 64b
  peg_pkt_xfr_intf            rx_pkt_intf,  //master, 64b

  peg_l2_rmii_intf            rmii_intf

  );

//----------------------- Global parameters Declarations ------------------


//----------------------- Input Declarations ------------------------------


//----------------------- Inout Declarations ------------------------------


//----------------------- Output Declarations -----------------------------


//----------------------- Output Register Declaration ---------------------


//----------------------- Internal Register Declarations ------------------


//----------------------- Internal Wire Declarations ----------------------


//----------------------- Internal Interface Declarations -----------------


//----------------------- FSM Declarations --------------------------------


//----------------------- Start of Code -----------------------------------

  /*  TX  */
  peg_l2_rs_rmii_tx           u_rmii_tx
  (

    .cr_intf                  (cr_intf),

    .config_intf              (config_intf),

    .pkt_intf                 (tx_pkt_intf),

    .mii_intf                 (rmii_intf.mac_tx)

  );


  /*  RX  */
  peg_l2_rs_rmii_rs           u_rmii_rx
  (

    .cr_intf                  (cr_intf),

    .config_intf              (config_intf),

    .mii_intf                 (rmii_intf.mac_rx),

    .pkt_intf                 (rx_pkt_intf)

  );


endmodule // peg_l2_rs_rmii

/*
 --------------------------------------------------------------------------

 -- <Header>
 

 -- <Log>

[18-06-2014  07:27:24 PM][mammenx] Initial Commit

[28-05-14 20:18:21] [mammenx] Moved log section to bottom of file

 --------------------------------------------------------------------------
*/
