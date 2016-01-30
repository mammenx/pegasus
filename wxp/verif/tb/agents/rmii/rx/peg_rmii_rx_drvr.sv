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
 -- Component Name    : peg_rmii_rx_drvr
 -- Author            : mammenx
 -- Function          : This class drives packets onto RMII RX interface
 --------------------------------------------------------------------------
*/

`ifndef __PEG_peg_rmii_rx_drvr
`define __PEG_peg_rmii_rx_drvr

  class peg_rmii_rx_drvr  #(type  PKT_TYPE  = peg_pkt_base,
                            type  INTF_TYPE = virtual peg_rmii_intf.TB_RX
                          ) extends ovm_driver  #(PKT_TYPE,PKT_TYPE); //request, response

    INTF_TYPE intf;

    OVM_FILE  f;

    shortint  enable;
    shortint  speed_100_n_10;


    /*  Register with factory */
    `ovm_component_param_utils_begin(peg_rmii_rx_drvr#(PKT_TYPE, INTF_TYPE))
      `ovm_field_int(enable,  OVM_ALL_ON);
      `ovm_field_int(speed_100_n_10,  OVM_ALL_ON);
    `ovm_component_utils_end


    /*  Constructor */
    function new( string name = "peg_rmii_rx_drvr" , ovm_component parent = null) ;
      super.new( name , parent );

      enable    = 1;  //by default enabled; disable from test case
      speed_100_n_10  = 1;
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

        forever
        begin
          ovm_report_info({get_name(),"[run]"},"Waiting for seq_item",OVM_LOW);
          seq_item_port.get_next_item(pkt);

          ovm_report_info({get_name(),"[run]"},$psprintf("Got seq_item - \n%s",pkt.sprint()),OVM_LOW);

          if(speed_100_n_10)
            drive_100(pkt);
          else
            drive_10(pkt);

          seq_item_port.item_done();
        end
      end
      else
      begin
        ovm_report_info({get_name(),"[run]"},"peg_rmii_rx_drvr is disabled",OVM_LOW);
        ovm_report_info({get_name(),"[run]"},"Shutting down .....",OVM_LOW);
      end
    endtask : run


    /*  Drive */
    task  drive_100(PKT_TYPE  pkt);

      ovm_report_info({get_name(),"[drive_100]"},"Start of drive ",OVM_LOW);

      pkt.packBits();

      @(intf.cb_rx);

      intf.cb_rx.crs_dv <=  1;

      for(int i=0;  i<pkt.mbits.size; i=i+2)
      begin
        intf.cb_rx.rxd  <=  {pkt.mbits[i+1],pkt.mbits[i]};
        @(intf.cb_rx);
      end

      intf.cb_rx.crs_dv <=  0;

      ovm_report_info({get_name(),"[drive_100]"},"End of drive ",OVM_LOW);

    endtask : drive_100


    task  drive_10(PKT_TYPE  pkt);

      ovm_report_info({get_name(),"[drive_10]"},"Start of drive ",OVM_LOW);

      pkt.packBits();

      @(intf.cb_rx);

      intf.cb_rx.crs_dv <=  1;

      for(int i=0;  i<pkt.mbits.size; i=i+2)
      begin
        intf.cb_rx.rxd  <=  {pkt.mbits[i+1],pkt.mbits[i]};
        repeat(10)  @(intf.cb_rx);
      end

      intf.cb_rx.crs_dv <=  0;

      ovm_report_info({get_name(),"[drive_10]"},"End of drive ",OVM_LOW);

    endtask : drive_10


    task  drive_rst();
      ovm_report_info({get_name(),"[drive_rst]"},"Driving reset values",OVM_LOW);

      intf.cb_rx.rx_er  <= 0;
      intf.cb_rx.crs_dv <= 0;
      intf.cb_rx.rxd    <= 0;

    endtask : drive_rst

  endclass  : peg_rmii_rx_drvr

`endif

/*
 --------------------------------------------------------------------------

 -- <Header>
 

 -- <Log>

[28-05-14 20:18:21] [mammenx] Moved log section to bottom of file

 --------------------------------------------------------------------------
*/
