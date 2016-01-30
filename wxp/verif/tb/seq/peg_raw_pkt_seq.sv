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
 -- Sequence Name     : peg_raw_pkt_seq
 -- Author            : mammenx
 -- Function          : This sequence generates a raw packet for transmission
 --------------------------------------------------------------------------
*/

`ifndef __PEG_RAW_PKT_SEQ
`define __PEG_RAW_PKT_SEQ

  class peg_raw_pkt_seq   #(
                             type  PKT_TYPE  =  peg_pkt_base,
                             type  SEQR_TYPE =  peg_rmii_rx_seqr#(PKT_TYPE)
                          ) extends ovm_sequence  #(PKT_TYPE);

    /*  Adding the parameterized sequence to the registery  */
    typedef peg_raw_pkt_seq#(PKT_TYPE,SEQR_TYPE) this_type;
    typedef ovm_object_registry#(this_type)type_id;

    /*  Linking with p_sequencer  */
    `ovm_declare_p_sequencer(SEQR_TYPE)


    /*  Constructor */
    function new(string name  = "peg_raw_pkt_seq");
      super.new(name);
    endfunction

    /*  Body of sequence  */
    task  body();
      PKT_TYPE  pkt;

      p_sequencer.ovm_report_info(get_name(),"Start of peg_raw_pkt_seq",OVM_LOW);

      $cast(pkt,create_item(PKT_TYPE::get_type(),m_sequencer,$psprintf("raw_pkt")));

      start_item(pkt);  //start_item has wait_for_grant()

      pkt.payload = new[100];

      for(int i=0;  i<7; i++)
      begin
        pkt.payload[i]  = 'h55;
      end

      pkt.payload[7]    = 'hd5;

      for(int i=8;  i<pkt.payload.size; i++)
      begin
        pkt.payload[i]  = $random;
      end

      p_sequencer.ovm_report_info(get_name(),$psprintf("Generated pkt - \n%s", pkt.sprint()),OVM_LOW);

      finish_item(pkt);

      #1;
    endtask : body


  endclass  : peg_raw_pkt_seq

`endif

/*
 --------------------------------------------------------------------------

 -- <Header>
 

 -- <Log>

[28-05-14 20:18:21] [mammenx] Moved log section to bottom of file

 --------------------------------------------------------------------------
*/
