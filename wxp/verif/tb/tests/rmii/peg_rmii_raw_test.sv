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
 -- Test Name         : peg_rmii_raw_test
 -- Author            : mammenx
 -- Function          : Base test that instantiates the cortex env & makes
                        connections from DUT to TB interfaces.
 --------------------------------------------------------------------------
*/


class peg_rmii_raw_test extends peg_rmii_base_test;

    `ovm_component_utils(peg_rmii_raw_test)

    //Sequences
    peg_raw_pkt_seq#(super.RMII_PKT_TYPE,super.RMII_RX_SEQR_TYPE)   seq;

    OVM_FILE  f;
    ovm_table_printer printer;


    /*  Constructor */
    function new (string name="peg_rmii_raw_test", ovm_component parent=null);
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

      seq = peg_raw_pkt_seq#(super.RMII_PKT_TYPE,super.RMII_RX_SEQR_TYPE)::type_id::create("raw_pkt_seq", this);

      ovm_report_info(get_full_name(),"End of build",OVM_LOW);
    endfunction : build



    /*  Run */
    virtual task run ();
      ovm_report_info(get_full_name(),"Start of run",OVM_LOW);

      seq.start(super.env.rmii_agent.rx.seqr);

      #1000;

      global_stop_request();

      ovm_report_info(get_full_name(),"End of run",OVM_LOW);
    endtask : run 


endclass : peg_rmii_raw_test

/*
 --------------------------------------------------------------------------

 -- <Header>
 

 -- <Log>


 --------------------------------------------------------------------------
*/


