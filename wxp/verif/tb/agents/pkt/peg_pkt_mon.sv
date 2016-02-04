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
 -- Component Name    : peg_pkt_mon
 -- Author            : mammenx
 -- Function          : This class monitors the packet interface & captures
                        packet transactions.
 --------------------------------------------------------------------------
*/

`ifndef __PEG_PKT_MON
`define __PEG_PKT_MON

  import  peg_tb_common_pkg::*;

  class peg_pkt_mon #(parameter DATA_W    = 8,
                      type      PKT_TYPE  = peg_pkt_base,
                      type      INTF_TYPE = virtual peg_pkt_intf#(DATA_W)
                    ) extends ovm_component;

    INTF_TYPE intf;

    ovm_analysis_port #(PKT_TYPE) Mon2Sb_port;

    OVM_FILE  f;

    shortint  enable;
    peg_pkt_data_mode_t  data_mode;

    /*  Register with factory */
    `ovm_component_param_utils_begin(peg_pkt_mon#(DATA_W, PKT_TYPE, INTF_TYPE))
      `ovm_field_int(enable,  OVM_ALL_ON);
      `ovm_field_enum(peg_pkt_data_mode_t,  data_mode, OVM_ALL_ON);
    `ovm_component_utils_end


    /*  Constructor */
    function new( string name = "peg_pkt_mon" , ovm_component parent = null) ;
      super.new( name , parent );

      enable  = 1;  //Enabled by default; disable from test case
      data_mode = PACKET;

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

      Mon2Sb_port = new("Mon2Sb_port", this);

      //void'(get_config_int("enable",enable));
      //void'(get_config_int("mode",mode));

      ovm_report_info(get_name(),"End of build ",OVM_LOW);
    endfunction : build


    task  run_pkt();
      PKT_TYPE  pkt;

      ovm_report_info({get_name(),"[run_pkt]"},"Start of run_pkt",OVM_LOW);

      forever
      begin
        ovm_report_info({get_name(),"[run_pkt]"},"Waiting for SOP",OVM_LOW);
        @(posedge intf.clk  iff intf.valid==1 &&  intf.sop==1 &&  intf.ready==1);

        ovm_report_info({get_name(),"[run_pkt]"},"Detected SOP",OVM_LOW);

        pkt = new("peg_pkt_mon");
        pkt.updateId();

        pkt.mbits = new[pkt.mbits.size+DATA_W](pkt.mbits);

        for(int i=0;  i<DATA_W; i++)
          pkt.mbits[pkt.mbits.size-DATA_W+i]  = intf.data[i];

        do
        begin
          @(posedge intf.clk  iff intf.valid==1 &&  intf.ready==1);

          pkt.mbits = new[pkt.mbits.size+DATA_W](pkt.mbits);

          for(int i=0;  i<DATA_W; i++)
            pkt.mbits[pkt.mbits.size-DATA_W+i]  = intf.data[i];

        end
        while(intf.valid==1 &&  intf.eop==0 &&  intf.ready==1);

        ovm_report_info({get_name(),"[run_pkt]"},"Detected EOP",OVM_LOW);
        pkt.unpackBits();

        ovm_report_info({get_name(),"[run_pkt]"},$psprintf("Sending pkt to SB -\n%s", pkt.sprint()),OVM_LOW);
        Mon2Sb_port.write(pkt);
        #1;
      end
    endtask : run_pkt


    task  run_bytes();
      PKT_TYPE  pkt;

      ovm_report_info({get_name(),"[run_bytes]"},"Start of run_bytes",OVM_LOW);

      forever
      begin
        ovm_report_info({get_name(),"[run_bytes]"},"Waiting for valid",OVM_LOW);
        @(posedge intf.clk  iff intf.valid==1 &&  intf.ready==1);

        ovm_report_info({get_name(),"[run_bytes]"},"Detected valid",OVM_LOW);

        pkt = new("peg_pkt_mon");
        pkt.updateId();

        pkt.mbits = new[DATA_W];
        pkt.pack_idx  = DATA_W;

        for(int i=0;  i<DATA_W; i++)
          pkt.mbits[i]  = intf.data[i];

        pkt.unpackBits();

        ovm_report_info({get_name(),"[run_bytes]"},$psprintf("Sending pkt to SB -\n%s", pkt.sprint()),OVM_LOW);
        Mon2Sb_port.write(pkt);
        #1;
      end
    endtask : run_bytes


    /*  Run */
    task run();

      ovm_report_info({get_name(),"[run]"},"Start of run ",OVM_LOW);

      //wait for reset
      @(posedge intf.rst_n);

      if(enable)
      begin
        if(data_mode ==  PACKET)
          run_pkt();
        else
          run_bytes();
      end
      else
      begin
        ovm_report_info({get_name(),"[run]"},"peg_pkt_mon  is disabled",OVM_LOW);
        ovm_report_info({get_name(),"[run]"},"Shutting down .....",OVM_LOW);
      end
    endtask : run


  endclass  : peg_pkt_mon

`endif

/*
 --------------------------------------------------------------------------

 -- <Header>
 

 -- <Log>

[04-02-2016  04:04:32 PM][mammenx] Added peg_pkt_agent & RMII SB

[28-05-14 20:18:21] [mammenx] Moved log section to bottom of file

 --------------------------------------------------------------------------
*/
