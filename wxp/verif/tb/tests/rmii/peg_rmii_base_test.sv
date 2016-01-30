/*
 --------------------------------------------------------------------------
   Synesthesia-Moksha - Copyright (C) 2012 Gregory Matthew James.

   This file is part of Synesthesia-Moksha.

   Synesthesia-Moksha is free; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 3 of the License, or
   (at your option) any later version.

   Synesthesia-Moksha is distributed in the hope that it will be useful,
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
 -- Test Name         : peg_rmii_base_test
 -- Author            : mammenx
 -- Function          : Base test that instantiates the cortex env & makes
                        connections from DUT to TB interfaces.
 --------------------------------------------------------------------------
*/


class peg_rmii_base_test extends ovm_test;

    //Parameters
    parameter type  RMII_PKT_TYPE     = peg_pkt_base;
    parameter type  RMII_TX_INTF_TYPE = virtual peg_rmii_intf.TB_TX;
    parameter type  RMII_RX_INTF_TYPE = virtual peg_rmii_intf.TB_RX;
    parameter type  RMII_RX_SEQR_TYPE = peg_rmii_rx_seqr#(RMII_PKT_TYPE);

    `ovm_component_utils(peg_rmii_base_test)

    //Declare environment
    peg_rmii_env#(RMII_PKT_TYPE,RMII_TX_INTF_TYPE,RMII_RX_INTF_TYPE)   env;

    //Sequences

    OVM_FILE  f;
    ovm_table_printer printer;


    /*  Constructor */
    function new (string name="peg_rmii_base_test", ovm_component parent=null);
        super.new (name, parent);
    endfunction : new 


    /*  Build */
    function  void  build();
      super.build();

      f = $fopen({"./logs/",get_full_name(),".log"});

      set_report_default_file(f);
      set_report_severity_action(OVM_INFO,  OVM_DISPLAY | OVM_LOG);
      set_report_severity_action(OVM_WARNING, OVM_DISPLAY | OVM_LOG);
      set_report_severity_action(OVM_ERROR,  OVM_COUNT | OVM_DISPLAY | OVM_LOG);
      set_report_severity_action(OVM_FATAL,  OVM_EXIT | OVM_DISPLAY | OVM_LOG);


      ovm_report_info(get_full_name(),"Start of build",OVM_LOW);

      env = new("peg_rmii_env", this);


      printer = new();
      printer.knobs.name_width  = 50; //width of Name collumn
      printer.knobs.type_width  = 50; //width of Type collumn
      printer.knobs.size_width  = 5;  //width of Size collumn
      printer.knobs.value_width = 30; //width of Value collumn
      printer.knobs.depth = -1;       //print all levels

      ovm_report_info(get_full_name(),"End of build",OVM_LOW);
    endfunction : build


    /*  Connect */
    function  void  connect();
      super.connect();

      ovm_report_info(get_full_name(),"Start of connect",OVM_LOW);

      //Make connections from DUT to TB components
      this.env.rmii_agent.tx.mon.intf   = $root.peg_rmii_tb_top.rmii_intf;
      this.env.rmii_agent.rx.drvr.intf  = $root.peg_rmii_tb_top.rmii_intf;

      ovm_report_info(get_full_name(),"End of connect",OVM_LOW);
    endfunction : connect


    /*  End of Elaboration  */
    function void end_of_elaboration();
      ovm_report_info(get_full_name(),"End_of_elaboration", OVM_LOG);

      ovm_report_info(get_full_name(),$psprintf("OVM Hierarchy -\n%s",  this.sprint(printer)), OVM_LOG);
      print();
    endfunction


    /*  Run */
    virtual task run ();
      ovm_report_info(get_full_name(),"Start of run",OVM_LOW);

      env.sprint();

      #1000;

      global_stop_request();

      ovm_report_info(get_full_name(),"End of run",OVM_LOW);
    endtask : run 


endclass : peg_rmii_base_test

/*
 --------------------------------------------------------------------------

 -- <Header>
 

 -- <Log>


 --------------------------------------------------------------------------
*/


