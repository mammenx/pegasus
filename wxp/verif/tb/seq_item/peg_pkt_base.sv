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
 -- Component Name    : peg_pkt_base
 -- Author            : mammenx
 -- Function          : This is a base class for constructing packet based
                        sequence items.
 --------------------------------------------------------------------------
*/

`ifndef __PEG_PKT_BASE
`define __PEG_PKT_BASE

  import  peg_tb_common_pkg::*;


  class peg_pkt_base extends ovm_sequence_item;

    //fields
    int pack_idx;
    int payload_offset;
    byte  unsigned  payload [];
    bit mbits [];

    //registering with factory
    `ovm_object_utils_begin(peg_pkt_base)
      `ovm_field_int(pack_idx, OVM_ALL_ON|OVM_DEC) 
      `ovm_field_array_int(mbits, OVM_ALL_ON|OVM_BIN) 
      `ovm_field_array_int(payload, OVM_ALL_ON|OVM_HEX) 
    `ovm_object_utils_end

    /*  Constructor */
    function new(string name = "peg_pkt_base");
      super.new(name);
      pack_idx  = 0;
      payload_offset  = 0;

    endfunction : new


    static  function  peg_integral_t  genRandField(int  size);
      bit tmp [];
      
      tmp = new[size];

      randBitVec(tmp);

      for(int i=0; i<size; i++)
        genRandField[i] = tmp[i];

      tmp.delete;

    endfunction : genRandField

    function  void  packFieldBits (peg_integral_t val, int size);

      if(size > PEG_MAX_FIELD_LEN)
        ovm_report_error({get_name(),"[packFieldBits]"},$psprintf("Size(%1d)i is greater than max(%1d)",size,PEG_MAX_FIELD_LEN),OVM_LOW);

      //Extend the size of the array
      mbits = new[pack_idx+size](mbits);

      for(int i=0;  i<size; i++)
      begin
        mbits[pack_idx+i] = val[i];
      end

      pack_idx  +=  size;
    endfunction : packFieldBits


    function  peg_integral_t  unpackFieldBits (int size);

      if(size > pack_idx)
        ovm_report_error({get_name(),"[unpackFieldBits]"},$psprintf("Size(%1d)i is greater than pack_idx(%1d)",size,pack_idx),OVM_LOW);

      unpackFieldBits = 'b0;
      pack_idx  -=  size;

      for(int i=0;  i<size; i++)
      begin
        unpackFieldBits[i]  = mbits[pack_idx+i];
      end

      mbits = new[pack_idx](mbits);

    endfunction : unpackFieldBits


    //These functions have to be overriden by children
    virtual function  void  packHeaderBits();
      mbits.delete;
      pack_idx  = 0;
    endfunction : packHeaderBits


    virtual function  void  packBits();
      packHeaderBits();

      foreach(payload[i])
        packFieldBits(payload[i], $bits(byte));

    endfunction : packBits


    virtual function  void  unpackHeaderBits();
      mbits.delete;
      pack_idx  = 0;
    endfunction : unpackHeaderBits


    virtual function  void  unpackBits();
      int payloadSize = mbits.size  / $bits(byte);  //At this stage, only payload should remain

      payload = new[payloadSize];

      foreach(payload[i])
        payload[i]  = unpackFieldBits($bits(byte));

    endfunction : unpackBits


  endclass  : peg_pkt_base

`endif


/*
 --------------------------------------------------------------------------

 -- <Header>
 

 -- <Log>

[01-02-2016  12:32:18 AM][mammenx] Added DPI-C randomisation support

[31-01-2016  04:28:51 PM][mammenx] Modifications for adding RMII L2 test


 --------------------------------------------------------------------------
*/


