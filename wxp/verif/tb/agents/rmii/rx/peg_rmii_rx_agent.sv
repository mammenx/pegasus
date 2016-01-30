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
 -- Component Name    : peg_rmii_rx_agent
 -- Author            : mammenx
 -- Function          : This is the RMII RX Agent
 --------------------------------------------------------------------------
*/

`ifndef __PEG_peg_rmii_rx_agent
`define __PEG_peg_rmii_rx_agent

  class peg_rmii_rx_agent #(  parameter type  PKT_TYPE  = peg_pkt_base,
                              parameter type  INTF_TYPE = virtual peg_rmii_intf.TB_RX
                          ) extends ovm_component;

    /*  Register with factory */
    `ovm_component_param_utils(peg_rmii_rx_agent#(PKT_TYPE,INTF_TYPE))


    //Declare Seqr, Drvr, Mon, Sb objects
    peg_rmii_rx_drvr#(PKT_TYPE,INTF_TYPE)   drvr;
    peg_rmii_rx_seqr#(PKT_TYPE)             seqr;


    OVM_FILE  f;


    /*  Constructor */
    function new(string name  = "peg_rmii_rx_agent", ovm_component parent = null);
      super.new(name, parent);
    endfunction: new


    /*  Build */
    function void build();
      super.build();

      f = $fopen({"./logs/",get_full_name(),".log"},  "w");

      set_report_default_file(f);
      set_report_severity_action(OVM_INFO,  OVM_DISPLAY | OVM_LOG);
      set_report_severity_action(OVM_WARNING, OVM_DISPLAY | OVM_LOG);
      set_report_severity_action(OVM_ERROR,  OVM_COUNT | OVM_DISPLAY | OVM_LOG);
      set_report_severity_action(OVM_FATAL,  OVM_EXIT | OVM_DISPLAY | OVM_LOG);

      ovm_report_info(get_name(),"Start of build ",OVM_LOW);

      //Build Seqr, Drvr, Mon, Sb objects using Factory
      drvr  = peg_rmii_rx_drvr#(PKT_TYPE,INTF_TYPE)::type_id::create("rmii_rx_drvr",  this);
      seqr  = peg_rmii_rx_seqr#(PKT_TYPE)::type_id::create("rmii_rx_seqr",  this);

      ovm_report_info(get_name(),"End of build ",OVM_LOW);
    endfunction


    /*  Connect */
    function void connect();
      super.connect();

      ovm_report_info(get_name(),"START of connect ",OVM_LOW);

        //Make port connections
        //eg. : mon.Mon2Sb_port.connect(sb.Mon2Sb_port);
        drvr.seq_item_port.connect(seqr.seq_item_export);

      ovm_report_info(get_name(),"END of connect ",OVM_LOW);
    endfunction


    /*  Disable Agent */
    function  void  disable_agent();

      //Disable sub-components by setting obj.enable to 0, or calling obj.disable_agent() function

    endfunction : disable_agent



  endclass  : peg_rmii_rx_agent

`endif

/*
 --------------------------------------------------------------------------

 -- <Header>
 

 -- <Log>

[28-05-14 20:18:21] [mammenx] Moved log section to bottom of file

 --------------------------------------------------------------------------
*/