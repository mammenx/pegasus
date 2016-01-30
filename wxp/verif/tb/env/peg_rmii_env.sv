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
 -- Component Name    : peg_rmii_env
 -- Author            : mammenx
 -- Function          : This is the RMII Environment
 --------------------------------------------------------------------------
*/

`ifndef __PEG_RMII_ENV
`define __PEG_RMII_ENV


  class peg_rmii_env  #(  parameter type  RMII_PKT_TYPE     = peg_pkt_base,
                          parameter type  RMII_TX_INTF_TYPE = virtual rmii_intf.TB_TX,
                          parameter type  RMII_RX_INTF_TYPE = virtual rmii_intf.TB_RX
                      ) extends ovm_env;


    /*  Register with factory */
    `ovm_component_param_utils(peg_rmii_env#(RMII_PKT_TYPE,RMII_TX_INTF_TYPE,RMII_RX_INTF_TYPE))


    //Declare agents, scoreboards
    peg_rmii_agent#(RMII_PKT_TYPE,RMII_TX_INTF_TYPE,RMII_RX_INTF_TYPE) rmii_agent;


    OVM_FILE  f;


    /*  Constructor */
    function new(string name  = "peg_rmii_env", ovm_component parent = null);
      super.new(name, parent);
    endfunction: new


    /*  Build */
    function void build();
      super.build();

      f = $fopen({"./logs/",get_full_name(),".log"});

      set_report_default_file(f);
      set_report_severity_action(OVM_INFO,  OVM_DISPLAY | OVM_LOG);
      set_report_severity_action(OVM_WARNING, OVM_DISPLAY | OVM_LOG);
      set_report_severity_action(OVM_ERROR,  OVM_COUNT | OVM_DISPLAY | OVM_LOG);
      set_report_severity_action(OVM_FATAL,  OVM_EXIT | OVM_DISPLAY | OVM_LOG);

      ovm_report_info(get_name(),"Start of build ",OVM_LOW);

      rmii_agent  = peg_rmii_agent#(RMII_PKT_TYPE,RMII_TX_INTF_TYPE,RMII_RX_INTF_TYPE)::type_id::create("rmii_agent",  this);

      ovm_report_info(get_name(),"End of build ",OVM_LOW);
    endfunction


    /*  Connect */
    function void connect();
      super.connect();

      ovm_report_info(get_name(),"START of connect ",OVM_LOW);


      ovm_report_info(get_name(),"END of connect ",OVM_LOW);
    endfunction



  endclass  : peg_rmii_env

`endif

/*
 --------------------------------------------------------------------------

 -- <Header>
 

 -- <Log>

[28-05-14 20:18:21] [mammenx] Moved log section to bottom of file

 --------------------------------------------------------------------------
*/
