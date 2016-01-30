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
 -- Component Name    : peg_l2_pkt
 -- Author            : mammenx
 -- Function          : This is a generic Ethernet Layer 2 packet
 --------------------------------------------------------------------------
*/

`ifndef __PEG_L2_PKT
`define __PEG_L2_PKT


  class peg_l2_pkt extends peg_pkt_base;

    //fields
          bit [(7*8)-1:0] l2_preamble;
          bit [(1*8)-1:0] l2_sfd;
    rand  bit [(6*8)-1:0] l2_daddr;
    rand  bit [(6*8)-1:0] l2_saddr;
    rand  bit [(2*8)-1:0] l2_len_type;
    rand  bit [(4*8)-1:0] l2_fcs;
          int l2_hdr_size = $bits(l2_preamble) +
                            $bits(l2_sfd)  +
                            $bits(l2_daddr)  +
                            $bits(l2_saddr)  +
                            $bits(l2_len_type) ;


    //registering with factory
    `ovm_object_utils_begin(peg_l2_pkt)
      `ovm_field_int(l2_preamble,  OVM_ALL_ON|OVM_HEX) 
      `ovm_field_int(l2_sfd,       OVM_ALL_ON|OVM_HEX) 
      `ovm_field_int(l2_daddr,     OVM_ALL_ON|OVM_HEX) 
      `ovm_field_int(l2_saddr,     OVM_ALL_ON|OVM_HEX) 
      `ovm_field_int(l2_len_type,  OVM_ALL_ON|OVM_HEX) 
      `ovm_field_int(l2_fcs,       OVM_ALL_ON|OVM_HEX) 
      `ovm_field_int(l2_hdr_size,  OVM_ALL_ON|OVM_DEC) 
    `ovm_object_utils_end

    /*  Constructor */
    function new(string name = "peg_l2_pkt");
      super.new(name);

      l2_preamble  = 56'h55_55_55_55_55_55_55;
      l2_sfd       = 8'hd5;
      payload_offset  = l2_hdr_size;
    endfunction : new


    function  void  packHeaderBits();
      super.packHeaderBits();

      packFieldBits(l2_preamble, $bits(l2_preamble));
      packFieldBits(l2_sfd,      $bits(l2_sfd));
      packFieldBits(l2_daddr,    $bits(l2_daddr));
      packFieldBits(l2_saddr,    $bits(l2_saddr));
      packFieldBits(l2_len_type, $bits(l2_len_type));

    endfunction : packHeaderBits


    function  void  packBits();
      packHeaderBits();

      foreach(payload[i])
        packFieldBits(payload[i], $bits(byte));

    endfunction : packBits


    function  void  unpackHeaderBits();
      l2_len_type  = unpackFieldBits($bits(l2_len_type));
      l2_saddr     = unpackFieldBits($bits(l2_saddr));
      l2_daddr     = unpackFieldBits($bits(l2_daddr));
      l2_sfd       = unpackFieldBits($bits(l2_sfd));
      l2_preamble  = unpackFieldBits($bits(l2_preamble));

      super.unpackHeaderBits();
    endfunction : unpackHeaderBits


    function  void  unpackBits();
      int payloadSize;

      l2_fcs = unpackFieldBits($bits(l2_fcs));

      payloadSize = (mbits.size - l2_hdr_size)  / $bits(byte);
      payload = new[payloadSize];

      foreach(payload[i])
        payload[i]  = unpackFieldBits($bits(byte));

      unpackHeaderBits();
    endfunction : unpackBits


  endclass  : peg_l2_pkt

`endif


/*
 --------------------------------------------------------------------------

 -- <Header>
 

 -- <Log>

 --------------------------------------------------------------------------
*/


