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
    static  int count = 0;
    int id  = count;
    int pack_idx;
    int payload_offset;
    byte  unsigned  payload [];
    bit mbits [];
    byte  unsigned  ipg;

    //registering with factory
    `ovm_object_utils_begin(peg_pkt_base)
      `ovm_field_int(id, OVM_ALL_ON|OVM_DEC) 
      `ovm_field_int(ipg, OVM_ALL_ON|OVM_UNSIGNED) 
      `ovm_field_int(pack_idx, OVM_ALL_ON|OVM_DEC) 
      `ovm_field_array_int(mbits, OVM_ALL_ON|OVM_BIN) 
      `ovm_field_array_int(payload, OVM_ALL_ON|OVM_HEX) 
    `ovm_object_utils_end

    /*  Constructor */
    function new(string name = "peg_pkt_base");
      super.new(name);
      pack_idx  = 0;
      payload_offset  = 0;
      ipg       = 96; //bit-times

    endfunction : new


    function  void  updateId();
      id  = count++;
      this.set_name($psprintf("%s_%1d",this.get_type_name(),id));
    endfunction : updateId


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
        ovm_report_fatal({get_name(),"[packFieldBits]"},$psprintf("Size(%1d)i is greater than max(%1d) in pkt:\n%s",size,PEG_MAX_FIELD_LEN,this.sprint()),OVM_LOW);

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
        ovm_report_fatal({get_name(),"[unpackFieldBits]"},$psprintf("Size(%1d)i is greater than pack_idx(%1d) in pkt:\n%s",size,pack_idx,this.sprint()),OVM_LOW);

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


    virtual function  string  checkFields(peg_pkt_base  exp);
      string  res = "";

      if(this.payload.size  !=  exp.payload.size)
      begin
        res = {res,$psprintf("Mismatch in payload.size : Expected %1d Actual %1d\n",exp.payload.size,this.payload.size)};
        return  res;
      end

      for(int i=0;  i<this.payload.size;  i++)
      begin
        if(this.payload[i]  !=  exp.payload[i])
        begin
          res = {res,$psprintf("Mismatch in payload[%1d] : Expected 0x%x Actual 0x%x\n",i,exp.payload[i],this.payload[i])};
        end
      end

      return  res;

    endfunction : checkFields

  endclass  : peg_pkt_base

`endif


/*
 --------------------------------------------------------------------------

 -- <Header>
 

 -- <Log>

[04-02-2016  04:04:33 PM][mammenx] Added peg_pkt_agent & RMII SB

[01-02-2016  12:32:18 AM][mammenx] Added DPI-C randomisation support

[31-01-2016  04:28:51 PM][mammenx] Modifications for adding RMII L2 test


 --------------------------------------------------------------------------
*/


