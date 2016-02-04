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
 -- Component Name    : peg_pkt_seqr
 -- Author            : mammenx
 -- Function          : This is the sequencer for peg_pkt_agent
 --------------------------------------------------------------------------
*/


`ifndef __PEG_PKT_SEQR
`define __PEG_PKT_SEQR

class peg_pkt_seqr  #(type  PKT_TYPE  = peg_pkt_base
                    )
                    extends ovm_sequencer #(PKT_TYPE,PKT_TYPE); //req, rsp

    /*  Register with factory */
    `ovm_component_param_utils(peg_pkt_seqr#(PKT_TYPE))
  
    OVM_FILE  f;


    /* Constructor  */
    function new (string name = "peg_pkt_seqr", ovm_component parent);
        super.new(name, parent);
    endfunction : new


    /*  Build */
    function  void  build();
      super.build();

      f = $fopen({"./logs/",get_full_name(),".log"},  "w");

      set_report_default_file(f);
      set_report_severity_action(OVM_INFO,  OVM_DISPLAY | OVM_LOG);
      set_report_severity_action(OVM_WARNING, OVM_DISPLAY | OVM_LOG);
      set_report_severity_action(OVM_ERROR,  OVM_COUNT | OVM_DISPLAY | OVM_LOG);
      set_report_severity_action(OVM_FATAL,  OVM_EXIT | OVM_DISPLAY | OVM_LOG);

      ovm_report_info(get_name(),"Start of build ",OVM_LOW);


      ovm_report_info(get_name(),"End of build ",OVM_LOW);
    endfunction : build

 
endclass : peg_pkt_seqr

`endif

/*
 --------------------------------------------------------------------------

 -- <Header>
 

 -- <Log>

[04-02-2016  04:04:32 PM][mammenx] Added peg_pkt_agent & RMII SB

[28-05-14 20:18:21] [mammenx] Moved log section to bottom of file

 --------------------------------------------------------------------------
*/
