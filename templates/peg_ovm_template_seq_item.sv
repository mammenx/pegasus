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
 -- Component Name    : <agent_name>
 -- Author            : 
 -- Function          : 
 --------------------------------------------------------------------------
*/

`ifndef __<seq_item_name>
`define __<seq_item_name>


  class <seq_item_name> extends ovm_sequence_item;

    //fields

    //registering with factory
    `ovm_object_param_utils_begin(seq_item_name)
    `ovm_object_utils_end

    /*  Constructor */
    function new(string name = "<seq_item_name>");
      super.new(name);
    endfunction : new


    /*  Constraint  Block */


  endclass  : syn_lb_seq_item

`endif


/*
 --------------------------------------------------------------------------

 -- <Header>
 

 -- <Log>

[29-01-2016  06:42:38 PM][mammenx] Initial Commit

 --------------------------------------------------------------------------
*/


