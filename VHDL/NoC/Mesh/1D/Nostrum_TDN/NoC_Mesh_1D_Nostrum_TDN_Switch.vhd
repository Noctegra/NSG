-------------------------------------------------------------------------------------------------------------------------
-- Copyright (c) 2006-present Johnny Öberg, KTH Royal Institute of Technology, Sweden. 
-- All rights reserved. 
-- 
-- Redistribution and use in source and binary forms, with or without modification, are permitted provided that the
-- following conditions are met: 
--
-- 1.Redistributions of source code must retain the above copyright notice, this list of conditions and the following
-- disclaimer. 
--
-- 2.Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following
-- disclaimer in the documentation and/or other materials provided with the distribution. 
-- 
-- 3.The name of the author may not be used to endorse or promote products derived from this software without specific
-- prior written permission.
-- 
-- THIS SOFTWARE IS PROVIDED BY THE AUTHOR “AS IS” AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
-- THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
-- AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
-- LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
-- HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
-- OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
-------------------------------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_signed.all;
use work.NoC_configuration_package.all;
use work.NoC_Mesh_1D_Nostrum_TDN_package.all;

entity NoC_Mesh_3D_Nostrum_TDN_Switch is
   generic(Col:ColumnAddressType;   -- x position
           Row:RowAddressType;	-- y position
	     Layer:LayerAddressType;  -- z position
	     inbuffer:buffer_type);
   port(clk,reset:IN std_logic;
	  Inport:IN Noc_port; 			-- Array of NoC packets, port 0=N, 1=S, 2=E, 3=W, 4=U, 5=D, 6=R, (7=Empty is not in the list)
	  Outport:OUT NoC_port;			-- Z-direction has lowest priority since it has the slowest links if implemented on a DE3 board
          switch_cycle:OUT std_logic_vector(1 downto 0);
	  read_R:OUT std_logic;
	  write_R:OUT std_logic);
end NoC_Mesh_3D_Nostrum_TDN_Switch;

---------------------------------------------------------------
architecture absolute_addressing of NoC_Mesh_3D_Nostrum_TDN_Switch is
   
   component NoC_Mesh_3D_Nostrum_TDN_Switch_recv is
	generic(inbuffer:buffer_type;
	        Row:RowAddressType;
              Col:ColumnAddressType;
		  Layer:LayerAddressType);
      port(clk,reset:IN std_logic;
	     load_enable:std_logic;
	     D:IN NoC_Packet;
	     Q:OUT NoC_Packet;
	     HC:OUT HC_type;
	     port_wants_to:OUT port_vector);
   end component; 
---------------------------------
   component NoC_Mesh_3D_Nostrum_TDN_Switch_xmitter is
      port(clk,reset:IN std_logic;
	     load_enable:std_logic;
           D:IN NoC_packet;
	     Q:OUT NoC_Packet);
   end component;

------------------------------------------------------------------------
-- returns 1 if any of the members of 'present' is 0, which means that there s something for RNI 
-- used to insert the Read_R signal

  function R_in_matrix(present:port_vector) return std_logic is
      variable ret:std_logic;
   begin
	ret:='0';
	for i in 0 to Resource loop
         if (present(i)=Resource) then
		ret:='1';
	   end if;
	end loop;
	return ret;
   end R_in_matrix;
--------------------------------------------------------------------------
-- Determines next_switch_matrix

   --  Input: A,B,C,D,R _wants_to, next_switch_matrix, ID number (to make it generic for all ports    
   --  return: next_switch_matrix
   --  Function: goes through the targets, if desired target is empty (i.e. har not been previously assigned) - allocate target to source_id
		
 function prio_order(present_matrix,source_wants_to:port_vector;source_id:port_ptr) return port_vector is
                             -- name : type
   variable ret_matrix:port_vector;
   variable target:port_ptr;
   begin
      ret_matrix:=present_matrix;
	L:for i in 0 to R loop     -- find the ports wished destination
	   target:=source_wants_to(i);
	   if (target<Empty) then  -- A desired direction can be empty for boundary nodes to prevent routing off-chip.
	      if (ret_matrix(target)=Empty) then
		   ret_matrix(target):=source_id; -- Associate target outport with the source inport
		   exit L;
		end if;
	   end if;
	end loop;
      return ret_matrix;
   end prio_order;
----------------------------------------------------------------------------
   signal HC:HC_vector:=(others=>(others=>'0'));
   signal port_wants_to:port_array;
   -- signal Valid:type_vector:=(others=>(others=>'0'));
   -- signal NS:NS_vector:=(others=>(others=>'0'));
   -- signal EW:EW_vector:=(others=>(others=>'0'));
   -- signal UD:UD_vector:=(others=>(others=>'0'));
   signal Q:NoC_port:=(others=>(others=>'0'));
   signal next_outport:NoC_port:=(others=>(others=>'0'));
   signal outport_internal:NoC_port;
   signal pres_switch_matrix:port_vector;

   signal ctrl_cycle:fsm_type;
   signal recv_load_enable,xmit_load_enable,next_write_R:std_logic;

-----------------------------------------------------------------------
begin

   recv_load_enable<='1' when ctrl_cycle=3 else '0';
   xmit_load_enable<='1' when ctrl_cycle=3 else '0';
---------------------------------------------------------------------------------------
  recv:for i in 0 to R generate 
       dir:NoC_Mesh_3D_Nostrum_TDN_Switch_recv
		generic map(inbuffer=>inbuffer,Row=>Row,Col=>Col,Layer=>Layer)
		port map(clk=>clk,
			   reset=>reset,
			   load_enable=>recv_load_enable,
			   D=>inport(i),
			   Q=>Q(i),
			   HC=>HC(i),
			   port_wants_to=>port_wants_to(i));
       end generate;
----------------------------------------------------------			
   xmit:for i in 0 to R generate
        dir:NoC_Mesh_3D_Nostrum_TDN_Switch_xmitter
		port map(clk=>clk,
			   reset=>reset,
			   load_enable=>xmit_load_enable,
			   D=>next_outport(i),
			   Q=>outport_internal(i));
   end generate;
---------------------------------------------------------
Ctrl:process(clk)
   begin
      if (clk'event and (clk='1')) then
         if (reset='1') then
	      ctrl_cycle<=0;
	   elsif (ctrl_cycle=3) then
		ctrl_cycle<=0;
	   else
	      ctrl_cycle<=ctrl_cycle+1;
	   end if;
	end if;
   end process;
   switch_cycle<=ieee.std_logic_arith.conv_std_logic_vector(ctrl_cycle,2);
--------------------------------------------------------------------
FSM:process(clk)
	variable next_switch_matrix:port_vector; -- destination matrix
	
	begin
	if (clk'event and clk='1') then
	   if reset='1' then
		  
		  read_R<='0';
		  next_switch_matrix:=(others=>Empty); -- Reset desired direction vector
		  pres_switch_matrix<=(others=>Empty);
		  -- Routing Details:
		  --    the wants_to indexing is an ordered list of preferred directions for deflection. index 0=first choice, 1=second choice, etc.
              --    The value is the direction
   
	  else
		read_R<='0';
		case ctrl_cycle is
		   when 0 => -- Find out Next Switch Matrix based upon desires of each port
		     
			-- Drawback to be fixed later: Priority re-ordering based on HC
			next_switch_matrix:=(others=>Empty); --  by default no connection
			for i in 0 to Up-1 loop -- assign a target port based on fixed priority
			   next_switch_matrix:=prio_order(next_switch_matrix,port_wants_to(i),i);
			end loop;
		  when 1 => 
			for i in Up to Resource loop -- assign a target port based on fixed priority
			   next_switch_matrix:=prio_order(next_switch_matrix,port_wants_to(i),i);
			end loop;
		       pres_switch_matrix<=next_switch_matrix;
		       read_R<=R_in_matrix(next_switch_matrix); -- If R got a connection, then read_R will be inserted
		      
		  when 2 => null; -- Output write_R
		  
		  when 3 => null; -- Latch Recv and Xmit registers
		  when others => null;
		end case;
	   end if;
      end if;
   end process;
----------------------------------------------------------			
  outport<=outport_internal;
----------------------------------------------------------
  next_write_R <= outport_internal(Resource)(Header_high); -- valid bit
----------------------------------------------------------
   process(clk)
   begin
	if (clk'event and (clk='1')) then
	   if (ctrl_cycle=1) then -- or (ctrl_cycle=2) then
	      write_R <= next_write_R;
	   else
		write_R <= '0';
	   end if;
	end if;
   end process;

----------------------------------------------------------------
 -- index of pres_switch_matrix gives the destination, and the value 
 -- on that index suggests which source that is to be picked

   process(pres_switch_matrix,Q)
   begin
      for i in 0 to Resource loop
	   case pres_switch_matrix(i) is
		when North    => next_outport(i)<=Q(North);
		when South    => next_outport(i)<=Q(South);
		when East     => next_outport(i)<=Q(East);
		when West     => next_outport(i)<=Q(West);
		when Up       => next_outport(i)<=Q(Up);
		when Down     => next_outport(i)<=Q(Down);
		when Resource => next_outport(i)<=Q(Resource);
		when others   => next_outport(i)<=(others=>'0');
	   end case;
	end loop;
   end process;
end absolute_addressing;
