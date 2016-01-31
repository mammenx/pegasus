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
 -- Sequence Name     : peg_l2_pkt_seq
 -- Author            : mammenx
 -- Function          : This sequence generates a l2 packet for transmission
 --------------------------------------------------------------------------
*/

`ifndef __PEG_L2_PKT_SEQ
`define __PEG_L2_PKT_SEQ

  class peg_l2_pkt_seq   #(
                             type  PKT_TYPE  =  peg_l2_pkt,
                             type  SEQR_TYPE =  peg_rmii_rx_seqr#(PKT_TYPE)
                          ) extends ovm_sequence  #(PKT_TYPE);

    /*  Adding the parameterized sequence to the registery  */
    typedef peg_l2_pkt_seq#(PKT_TYPE,SEQR_TYPE) this_type;
    typedef ovm_object_registry#(this_type)type_id;

    /*  Linking with p_sequencer  */
    `ovm_declare_p_sequencer(SEQR_TYPE)

    //Fields to be set from test case
    bit [(6*8)-1:0] l2_daddr;
    bit [(6*8)-1:0] l2_saddr;
    bit [(2*8)-1:0] l2_len_type;
    bit [(4*8)-1:0] l2_fcs;

    /*  Constructor */
    function new(string name  = "peg_l2_pkt_seq");
      super.new(name);

    endfunction

    /*  Body of sequence  */
    task  body();
      PKT_TYPE  pkt;

      p_sequencer.ovm_report_info(get_name(),"Start of peg_l2_pkt_seq",OVM_LOW);

      $cast(pkt,create_item(PKT_TYPE::get_type(),m_sequencer,$psprintf("l2_pkt")));

      pkt.l2_daddr    = l2_daddr;
      pkt.l2_saddr    = l2_saddr;
      pkt.l2_len_type = l2_len_type;
      pkt.l2_fcs      = l2_fcs;


      start_item(pkt);  //start_item has wait_for_grant()

      p_sequencer.ovm_report_info(get_name(),$psprintf("Generated pkt - \n%s", pkt.sprint()),OVM_LOW);

      finish_item(pkt);

      #1;
    endtask : body


  endclass  : peg_l2_pkt_seq

`endif

/*
 --------------------------------------------------------------------------

 -- <Header>
 

 -- <Log>

[01-02-2016  12:32:18 AM][mammenx] Added DPI-C randomisation support

[31-01-2016  04:27:46 PM][mammenx] Initial Commit

[28-05-14 20:18:21] [mammenx] Moved log section to bottom of file

 --------------------------------------------------------------------------
*/
