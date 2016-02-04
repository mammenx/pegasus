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
 -- Component Name    : peg_rmii_sb
 -- Author            : mammenx
 -- Function          : This scoreboard checks RMII data.
 --------------------------------------------------------------------------
*/

`ifndef __PEG_RMII_SB
`define __PEG_RMII_SB

//Implicit port declarations
`ovm_analysis_imp_decl(_tx_rcvd_pkt)
`ovm_analysis_imp_decl(_tx_sent_pkt)
`ovm_analysis_imp_decl(_rx_rcvd_pkt)
`ovm_analysis_imp_decl(_rx_sent_pkt)

  class peg_rmii_sb #(type  SENT_PKT_TYPE = peg_pkt_base,
                      type  RCVD_PKT_TYPE = peg_pkt_base
                    ) extends ovm_scoreboard;

    /*  Register with Factory */
    `ovm_component_param_utils(peg_rmii_sb#(SENT_PKT_TYPE, RCVD_PKT_TYPE))

    //Queue to hold the sent pkts, till rcvd pkts come
    SENT_PKT_TYPE tx_sent_que[$];
    RCVD_PKT_TYPE tx_rcvd_que[$];
    SENT_PKT_TYPE rx_sent_que[$];
    RCVD_PKT_TYPE rx_rcvd_que[$];

    //Ports
    ovm_analysis_imp_tx_sent_pkt #(SENT_PKT_TYPE,peg_rmii_sb#(SENT_PKT_TYPE, RCVD_PKT_TYPE))  Mon_tx_sent_2Sb_port;
    ovm_analysis_imp_tx_rcvd_pkt #(RCVD_PKT_TYPE,peg_rmii_sb#(SENT_PKT_TYPE, RCVD_PKT_TYPE))  Mon_tx_rcvd_2Sb_port;
    ovm_analysis_imp_rx_sent_pkt #(SENT_PKT_TYPE,peg_rmii_sb#(SENT_PKT_TYPE, RCVD_PKT_TYPE))  Mon_rx_sent_2Sb_port;
    ovm_analysis_imp_rx_rcvd_pkt #(RCVD_PKT_TYPE,peg_rmii_sb#(SENT_PKT_TYPE, RCVD_PKT_TYPE))  Mon_rx_rcvd_2Sb_port;

    OVM_FILE  f;


    /*  Constructor */
    function new(string name = "peg_rmii_sb", ovm_component parent);
      super.new(name, parent);
    endfunction : new


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

      Mon_tx_sent_2Sb_port = new("Mon_tx_sent_2Sb_port", this);
      Mon_tx_rcvd_2Sb_port = new("Mon_tx_rcvd_2Sb_port", this);
      Mon_rx_sent_2Sb_port = new("Mon_rx_sent_2Sb_port", this);
      Mon_rx_rcvd_2Sb_port = new("Mon_rx_rcvd_2Sb_port", this);

      ovm_report_info(get_name(),"End of build ",OVM_LOW);
    endfunction


    /*
      * Write TX Sent Pkt
      * This function will be called each time a pkt is written into [ovm_analysis_imp_tx_sent_pkt]Mon_tx_sent_2Sb_port
    */
    virtual function void write_tx_sent_pkt(input SENT_PKT_TYPE  pkt);
      ovm_report_info({get_name(),"[write_tx_sent_pkt]"},$psprintf("Received pkt\n%s",pkt.sprint()),OVM_LOW);

      //Push packet into sent queue
      tx_sent_que.push_back(pkt);

      ovm_report_info({get_name(),"[write_tx_sent_pkt]"},$psprintf("There are %d items in sent_que[$]",tx_sent_que.size()),OVM_LOW);
    endfunction : write_tx_sent_pkt


    /*
      * Write TX Rcvd Pkt
      * This function will be called each time a pkt is written into [ovm_analysis_imp_tx_rcvd_pkt]Mon_tx_rcvd_2Sb_port
    */
    virtual function void write_tx_rcvd_pkt(input RCVD_PKT_TYPE pkt);
      ovm_report_info({get_name(),"[write_tx_rcvd_pkt]"},$psprintf("Received pkt\n%s",pkt.sprint()),OVM_LOW);

      //Push packet into rcvd queue
      tx_rcvd_que.push_back(pkt);

      ovm_report_info({get_name(),"[write_tx_rcvd_pkt]"},$psprintf("There are %d items in rcvd_que[$]",tx_rcvd_que.size()),OVM_LOW);
    endfunction : write_tx_rcvd_pkt


    /*
      * Write RX Sent Pkt
      * This function will be called each time a pkt is written into [ovm_analysis_imp_rx_sent_pkt]Mon_rx_sent_2Sb_port
    */
    virtual function void write_rx_sent_pkt(input SENT_PKT_TYPE  pkt);
      ovm_report_info({get_name(),"[write_rx_sent_pkt]"},$psprintf("Received pkt\n%s",pkt.sprint()),OVM_LOW);

      //Push packet into sent queue
      rx_sent_que.push_back(pkt);

      ovm_report_info({get_name(),"[write_rx_sent_pkt]"},$psprintf("There are %d items in sent_que[$]",rx_sent_que.size()),OVM_LOW);
    endfunction : write_rx_sent_pkt


    /*
      * Write RX Rcvd Pkt
      * This function will be called each time a pkt is written into [ovm_analysis_imp_rx_rcvd_pkt]Mon_rx_rcvd_2Sb_port
    */
    virtual function void write_rx_rcvd_pkt(input RCVD_PKT_TYPE pkt);
      ovm_report_info({get_name(),"[write_rx_rcvd_pkt]"},$psprintf("Received pkt\n%s",pkt.sprint()),OVM_LOW);

      //Push packet into rcvd queue
      rx_rcvd_que.push_back(pkt);

      ovm_report_info({get_name(),"[write_rx_rcvd_pkt]"},$psprintf("There are %d items in rcvd_que[$]",rx_rcvd_que.size()),OVM_LOW);
    endfunction : write_rx_rcvd_pkt


    task  check_tx();
      SENT_PKT_TYPE exp_pkt;
      RCVD_PKT_TYPE act_pkt;
      string        res;

      forever
      begin
        ovm_report_info({get_name(),"[check_tx]"},"Waiting on tx_rcvd_que",OVM_LOW);
        while(!tx_rcvd_que.size())  #1;

        act_pkt = tx_rcvd_que.pop_front();

        if(tx_sent_que.size())
        begin
          exp_pkt = tx_sent_que.pop_front();
        end
        else
        begin
          ovm_report_error({get_name(),"[check_tx]"},"Unexpected xtn!",OVM_LOW);
          continue;
        end

        res = act_pkt.checkFields(exp_pkt);

        if(res  ==  "")
          ovm_report_info({get_name(),"[check_tx]"},$psprintf("Packets match"),OVM_LOW);
        else
          ovm_report_error({get_name(),"[check_tx]"},$psprintf("Packets do not match:\n%s",res),OVM_LOW);

      end
    endtask : check_tx


    task  check_rx();
      SENT_PKT_TYPE exp_pkt;
      RCVD_PKT_TYPE act_pkt;
      string        res;

      forever
      begin
        ovm_report_info({get_name(),"[check_rx]"},"Waiting on rx_rcvd_que",OVM_LOW);
        while(!rx_rcvd_que.size())  #1;

        act_pkt = rx_rcvd_que.pop_front();

        if(rx_sent_que.size())
        begin
          exp_pkt = rx_sent_que.pop_front();
        end
        else
        begin
          ovm_report_error({get_name(),"[check_rx]"},"Unexpected xtn!",OVM_LOW);
          continue;
        end

        res = act_pkt.checkFields(exp_pkt);

        if(res  ==  "")
          ovm_report_info({get_name(),"[check_rx]"},$psprintf("Packets match"),OVM_LOW);
        else
          ovm_report_error({get_name(),"[check_rx]"},$psprintf("Packets do not match:\n%s",res),OVM_LOW);

      end
    endtask : check_rx


    /*  Run */
    task run();
      ovm_report_info({get_name(),"[run]"},"Start of run",OVM_LOW);

      fork
        begin
          check_tx();
        end

        begin
          check_rx();
        end
      join

    endtask : run


    /*  Report  */
    virtual function void report();
      ovm_report_info({get_type_name(),"[report]"},$psprintf("Report -\n%s", this.sprint()), OVM_LOW);
    endfunction : report

  endclass : peg_rmii_sb

`endif

/*
 --------------------------------------------------------------------------

 -- <Header>
 

 -- <Log>

[04-02-2016  04:04:33 PM][mammenx] Added peg_pkt_agent & RMII SB

[28-05-14 20:18:21] [mammenx] Moved log section to bottom of file

 --------------------------------------------------------------------------
*/
