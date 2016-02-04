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
 -- Component Name    : peg_rmii_rx_mon
 -- Author            : mammenx
 -- Function          : This monitor captures RMII RX data into byte packets.
 --------------------------------------------------------------------------
*/

`ifndef __PEG_RMII_RX_MON
`define __PEG_RMII_RX_MON

  class peg_rmii_rx_mon #(type  PKT_TYPE  = peg_pkt_base,
                          type  INTF_TYPE = virtual peg_rmii_intf.TB_RX
                        ) extends ovm_component;

    INTF_TYPE intf;

    ovm_analysis_port #(PKT_TYPE) Mon2Sb_port;

    OVM_FILE  f;

    mailbox#(byte unsigned) byte_mbox;

    shortint  enable;
    shortint  speed_100_n_10;

    /*  Register with factory */
    `ovm_component_param_utils_begin(peg_rmii_rx_mon#(PKT_TYPE, INTF_TYPE))
      `ovm_field_int(enable,  OVM_ALL_ON);
      `ovm_field_int(speed_100_n_10,  OVM_ALL_ON);
    `ovm_component_utils_end


    /*  Constructor */
    function new( string name = "peg_rmii_rx_mon" , ovm_component parent = null) ;
      super.new( name , parent );
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

      enable  = 1;  //Enabled by default; disable from test case

      speed_100_n_10  = 1;

      byte_mbox = new();

      ovm_report_info(get_name(),"End of build ",OVM_LOW);
    endfunction : build


    //This function parses incoming bytes and packetizes them
    task  parse_bytes();
      byte  unsigned  data;
      PKT_TYPE  pkt;

      ovm_report_info({get_name(),"[parse_bytes]"},"Start of parse_bytes",OVM_LOW);

      forever
      begin
        byte_mbox.get(data);

        //Initialise new packet
        pkt = new();
        pkt.updateId();
 
        pkt.payload = new[1];
        pkt.payload[0]  = data;

        //Send captured pkt to SB
        ovm_report_info({get_name(),"[parse_bytes]"},$psprintf("Sending pkt to SB -\n%s", pkt.sprint()),OVM_LOW);
        Mon2Sb_port.write(pkt);
        #1;
      end
    endtask : parse_bytes



    /*  Run */
    task run();
      byte  unsigned  temp;

      ovm_report_info({get_name(),"[run]"},"Start of run ",OVM_LOW);

      //wait for reset
      @(posedge intf.rst_n);

      if(enable)
      begin
        fork
          begin
            //Monitor logic
            if(speed_100_n_10)
            begin
              forever
              begin
                for(int i=0;  i<8;  i=i+2)
                begin
                  @(intf.cb_rx  iff intf.cb_rx.crs_dv ==  1);

                  temp[i  +:  2]  = intf.cb_rx.rxd;
                  ovm_report_info({get_name(),"[run]"},$psprintf("%1d rxd = 0x%x,temp = 0x%x",i,intf.cb_rx.rxd,temp),OVM_LOW);
                end

                byte_mbox.put(temp);
                #1;
              end
            end
            else  //~speed_100_n_10
            begin
              forever
              begin
                for(int i=0;  i<8;  i=i+2)
                begin
                  @(intf.cb_rx  iff intf.cb_rx.crs_dv ==  1);

                  temp[i  +:  2]  = intf.cb_rx.rxd;

                  repeat(9) @(intf.cb_rx);  //sample 1/10 clocks
                end

                byte_mbox.put(temp);
                #1;
              end
            end
          end

          begin
            parse_bytes();
          end

          begin
            forever
            begin
              @(intf.cb_rx.rx_er);
              ovm_report_warning({get_name(),"[run]"},"RX Error detected!",OVM_LOW);
            end
          end
        join
      end
      else
      begin
        ovm_report_info({get_name(),"[run]"},"peg_rmii_rx_mon  is disabled",OVM_LOW);
        ovm_report_info({get_name(),"[run]"},"Shutting down .....",OVM_LOW);
      end
    endtask : run


  endclass  : peg_rmii_rx_mon

`endif

/*
 --------------------------------------------------------------------------

 -- <Header>
 

 -- <Log>

[04-02-2016  04:04:32 PM][mammenx] Added peg_pkt_agent & RMII SB

[28-05-14 20:18:21] [mammenx] Moved log section to bottom of file

 --------------------------------------------------------------------------
*/
