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
 -- Component Name    : peg_pkt_drvr
 -- Author            : mammenx
 -- Function          : This class drives pkt data onto the interface.
 --------------------------------------------------------------------------
*/

`ifndef __PEG_PKT_DRVR
`define __PEG_PKT_DRVR

  import  peg_tb_common_pkg::*;

  class peg_pkt_drvr  #(parameter DATA_W    = 8,
                        type      PKT_TYPE  = peg_pkt_base,
                        type      INTF_TYPE = virtual peg_pkt_intf#(DATA_W)
                      ) extends ovm_driver  #(PKT_TYPE,PKT_TYPE); //request, response

    INTF_TYPE intf;

    OVM_FILE  f;

    shortint  enable;
    peg_pkt_data_mode_t data_mode;
    peg_pkt_mode_t      mode;

    /*  Register with factory */
    `ovm_component_param_utils_begin(peg_pkt_drvr#(DATA_W, PKT_TYPE, INTF_TYPE))
      `ovm_field_int(enable,  OVM_ALL_ON);
      `ovm_field_enum(peg_pkt_mode_t,  mode, OVM_ALL_ON);
      `ovm_field_enum(peg_pkt_data_mode_t,  data_mode, OVM_ALL_ON);
    `ovm_component_utils_end


    /*  Constructor */
    function new( string name = "peg_pkt_drvr" , ovm_component parent = null) ;
      super.new( name , parent );

      enable    = 1;  //by default enabled; disable from test case
      mode      = MASTER;
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

      //void'(get_config_int("enable",enable));
      //void'(get_config_int("mode",mode));

      ovm_report_info(get_name(),"End of build ",OVM_LOW);
    endfunction : build


    /*  Run */
    task run();
      PKT_TYPE  pkt = new();
      PKT_TYPE  pkt_rsp;

      ovm_report_info({get_name(),"[run]"},"Start of run ",OVM_LOW);

      if(enable)
      begin
        //Wait for reset  ...
        drive_rst();
        @(posedge intf.rst_n);

        if(mode ==  SLAVE)
        begin
          ovm_report_info({get_name(),"[run]"},"Entering SLAVE mode",OVM_LOW);
        end
        else
        begin
          forever
          begin
            ovm_report_info({get_name(),"[run]"},"Waiting for seq_item",OVM_LOW);
            seq_item_port.get_next_item(pkt);

            ovm_report_info({get_name(),"[run]"},$psprintf("Got seq_item - \n%s",pkt.sprint()),OVM_LOW);

            if(data_mode ==  PACKET)
              drive_pkt(pkt);
            else
              drive_bytes(pkt);

            seq_item_port.item_done();
          end
        end
      end
      else
      begin
        ovm_report_info({get_name(),"[run]"},"peg_pkt_drvr is disabled",OVM_LOW);
        ovm_report_info({get_name(),"[run]"},"Shutting down .....",OVM_LOW);
      end
    endtask : run


    /*  Drive */
    task  drive_pkt(PKT_TYPE  pkt);

      ovm_report_info({get_name(),"[drive_pkt]"},"Start of drive_pkt ",OVM_LOW);

      pkt.packBits();

      if(!pkt.mbits.size)
      begin
        ovm_report_warning({get_name(),"[drive_pkt]"},"Null Payload size",OVM_LOW);
        return;
      end

      if(pkt.mbits.size  % DATA_W)
        ovm_report_warning({get_name(),"[drive_pkt]"},$psprintf("Packet size(%1d) is not aligned to data width(%1d)",pkt.mbits.size,DATA_W),OVM_LOW);


      @(posedge intf.clk);
      intf.valid    <=  1;

      for(int i=0;  i<pkt.mbits.size; i=i+DATA_W)
      begin
        intf.sop  <=  (i==0)  ? 1 : 0;
        intf.sop  <=  (i>=pkt.mbits.size-DATA_W)  ? 1 : 0;
        for(int j=0;  j<DATA_W; j++)
        begin
          intf.data[j]  <=  pkt.mbits[i+j];
        end
        @(posedge intf.clk  iff intf.ready  ==  1);
      end

      intf.valid    <=  1;
      @(posedge intf.clk);

      ovm_report_info({get_name(),"[drive_pkt]"},"End of drive_pkt ",OVM_LOW);
    endtask : drive_pkt


    task  drive_bytes(PKT_TYPE  pkt);

      ovm_report_info({get_name(),"[drive_bytes]"},"Start of drive_bytes ",OVM_LOW);

      pkt.packBits();

      if(!pkt.mbits.size)
      begin
        ovm_report_warning({get_name(),"[drive_bytes]"},"Null Payload size",OVM_LOW);
        return;
      end

      if(pkt.mbits.size  % DATA_W)
        ovm_report_warning({get_name(),"[drive_bytes]"},$psprintf("Packet size(%1d) is not aligned to data width(%1d)",pkt.mbits.size,DATA_W),OVM_LOW);


      @(posedge intf.clk);
      intf.sop      <=  0;
      intf.sop      <=  0;
      intf.valid    <=  1;

      for(int i=0;  i<pkt.mbits.size; i=i+DATA_W)
      begin
        for(int j=0;  j<DATA_W; j++)
        begin
          intf.data[j]  <=  pkt.mbits[i+j];
        end
        @(posedge intf.clk  iff intf.ready  ==  1);
      end

      intf.valid    <=  1;
      @(posedge intf.clk);

      ovm_report_info({get_name(),"[drive_bytes]"},"End of drive_bytes ",OVM_LOW);
    endtask : drive_bytes


    task  drive_rst();
      ovm_report_info({get_name(),"[drive_rst]"},"Driving reset values",OVM_LOW);

      if(mode ==  MASTER)
      begin
        intf.valid    <=  0;
        intf.sop      <=  0;
        intf.eop      <=  0;
        intf.data     <=  0;
        intf.error    <=  0;
      end
      else
      begin
        intf.ready    <=  1;
      end

    endtask : drive_rst

  endclass  : peg_pkt_drvr

`endif

/*
 --------------------------------------------------------------------------

 -- <Header>
 

 -- <Log>

[04-02-2016  04:04:32 PM][mammenx] Added peg_pkt_agent & RMII SB

[28-05-14 20:18:21] [mammenx] Moved log section to bottom of file

 --------------------------------------------------------------------------
*/
