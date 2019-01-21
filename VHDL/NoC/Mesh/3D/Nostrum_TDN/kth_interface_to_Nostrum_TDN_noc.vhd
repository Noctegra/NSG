-------------------------------------------------------------------------------------------------------------------------
-- Copyright (c) 2006-2018 Johnny Öberg, KTH Royal Institute of Technology, Sweden. 
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
use ieee.std_logic_arith.conv_std_logic_vector;
use ieee.std_logic_arith.conv_integer;
use ieee.std_logic_unsigned.conv_integer;
use ieee.std_logic_signed.all;
use ieee.numeric_std.all;
use work.noc_configuration_package.all;
Use work.noc_Mesh_3D_Nostrum_TDN_package.all;
entity kth_interface_to_Nostrum_TDN_noc is
    generic
	(
		-- row_pos : integer :=0 ;
		-- col_pos : integer :=0 ;
		-- layer_pos : integer := 0;
		rni_pos : integer := 0;
		channel_size : integer := flit_id_size; -- size of one msg channel in nr of flit data words (must be a power of two)
		flit_width : integer := 32; -- size of flit data read/writes to/from buffer memory
		-- The following two parameters are set in the NoC_3D_SW_configuration_package, 
		nr_of_recv_channels_size: integer :=1; -- size of the receive channel buffer  (nr_of_recv_channels = 2**nr_of_recv_channels_size)
		nr_of_send_channels_size: integer :=1;  -- size of the transmit channel buffer (nr_of_send_channels = 2**nr_of_send_channels_size)
		-- 
		send_buffer_size:integer:=4; -- nr_of_send_channels_size+channel_size-(log2(flit_width)-5);
		recv_buffer_size:integer:=5-- nr_of_recv_channels_size+channel_size-(log2(flit_width)-5);
	);
	port 
	(
		Clk:IN STD_LOGIC; -- Global Clock
		Reset:IN STD_LOGIC; -- Global Reset
		
		-- DO NOT EDIT BELOW THIS LINE ---------------------
		-- Bus protocol ports, do not add or delete. 
		-- memory interface ports
		send_buffer_read:OUT STD_LOGIC;
		send_buffer_write:OUT STD_LOGIC; 
		send_buffer_address:OUT STD_LOGIC_VECTOR(send_buffer_size-1 DOWNTO 0); -- generic number of channels used on the send side...
		send_buffer_readdata:IN STD_LOGIC_VECTOR(flit_width-1 DOWNTO 0);
		send_buffer_writedata:OUT STD_LOGIC_VECTOR(flit_width-1 DOWNTO 0);

		recv_buffer_read:OUT STD_LOGIC;
		recv_buffer_write:OUT STD_LOGIC;
		recv_buffer_address:OUT STD_LOGIC_VECTOR(recv_buffer_size-1 DOWNTO 0); -- generic number of channels used on the recv side
		recv_buffer_readdata:IN STD_LOGIC_VECTOR(flit_width-1 DOWNTO 0);
		recv_buffer_writedata:OUT STD_LOGIC_VECTOR(flit_width-1 DOWNTO 0);

		-- Slave ports
		slave_clk:IN STD_LOGIC;                           -- Bus Clock
		slave_reset:IN STD_LOGIC;                         -- Bus Reset
		slave_irq:OUT STD_LOGIC;                          -- Interrupt Request
		slave_readdata:OUT STD_LOGIC_VECTOR(31 DOWNTO 0); -- Data to bus Master
		slave_address:IN STD_LOGIC_VECTOR(7 DOWNTO 0);    -- Address
		slave_read:IN STD_LOGIC;                          -- Read assert
		slave_chipselect:IN STD_LOGIC;                    -- Chip select in case of multiple units
		slave_write:IN STD_LOGIC;                         -- Write assert
		slave_writedata:IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- Data from bus Master

		-- DO NOT EDIT ABOVE THIS LINE ---------------------
		-- what is in for the NoC is out for the nios_to_3D_NoC...
	     	-- GlobalSync port, used to implement Synchronous MoC in SW
	      	GlobalSync:INOUT std_logic;
		Toggle_address_cpu_side:OUT std_logic_vector(0 to 2**nr_of_recv_channels_size-1);
		Toggle_address_noc_side:OUT std_logic_vector(0 to 2**nr_of_recv_channels_size-1);
		-- Test_debug:OUT std_logic_vector(31 downto 0);
		-- what is in for the NoC is out for the NI...
		inport:in NoC_packet;
		outport:out NoC_packet;
		switch_cycle:in std_logic_vector(1 downto 0);
		read_R:in std_logic;
		write_R:in std_logic
	);

end kth_interface_to_Nostrum_TDN_noc;

------------------------------------------------------------------------------
-- Architecture Section
------------------------------------------------------------------------------

architecture Implementation of kth_interface_to_Nostrum_TDN_noc is
   function print_std_logic(A:std_logic) return character is
   begin
      case A is
	 when 'U' => return 'U';
	 when 'X' => return 'X';
	 when '0' => return '0';
	 when '1' => return '1';
	 when 'Z' => return 'Z';
	 when 'L' => return 'L';
	 when 'H' => return 'H';
	 when 'W' => return 'W';
	 when others => return '-';
      end case;
      return ' ';
   end print_std_logic;
   function print_std_logic_vector(a:std_logic_vector) return string is
      variable ret:string(1 to a'length);
      variable index:positive;
   begin
      index:=1;
      for i in a'range loop
	ret(index):=print_std_logic(a(i));
	index:=index+1;
      end loop;
      return ret;
   end print_std_logic_vector;
------------------------------------------------------------------------
   function reverse(A:std_logic_vector) return std_logic_vector is
      variable ret:std_logic_vector(A'reverse_range);
   begin
      for i in A'range loop
	   ret(i):=A(i);
	end loop;
	return ret;
   end reverse;
----------------------------------------------------------------------
   constant nr_of_recv_channels: integer := 2**nr_of_recv_channels_size;
   constant nr_of_send_channels: integer := 2**nr_of_send_channels_size;
   constant node_nr: natural := rni_pos; -- layer_pos*Nr_of_Cols*Nr_of_Rows+row_pos*Nr_of_Cols+col_pos;
   constant programmable_send_channels:std_logic:=use_programmable_send_channels(node_nr);
   constant programmable_recv_channels:std_logic:=use_programmable_recv_channels(node_nr);

   function send_channel_function(rom:send_process_map_vector_type) return send_channel_info_vector_type is
      variable ret:send_channel_info_vector_type(0 to nr_of_send_channels-1);
      variable tmp:integer;
   begin
      -- Enable, TDN, EW, NS, UD, Source, Target
      ret:=(others=>('0',0,0,0,0,(others=>'0'),(others=>'0')));
      tmp:=0;
      for i in rom'range loop
	 if (rom(i).NodeNr=node_nr) then
	    --if (tmp<nr_of_send_channels) then
	       ret(tmp).enable:='1';
	       ret(tmp).tdn:=rom(i).tdn;
	       ret(tmp).ew:=rom(i).ew;
	       ret(tmp).ns:=rom(i).ns;
	       ret(tmp).ud:=rom(i).ud;
	       ret(tmp).source:=conv_std_logic_vector(rom(i).source,8);
	       ret(tmp).target:=conv_std_logic_vector(rom(i).target,8);
	       tmp:=tmp+1;
	    --end if;
	 end if;
      end loop;
      return ret;
   end send_channel_function;

   function recv_channel_function(rom:recv_process_map_vector_type) return recv_channel_info_vector_type is
      variable ret:recv_channel_info_vector_type(0 to nr_of_recv_channels-1);
      variable tmp:integer;
   begin
      ret:=(others=>recv_channel_info_type'('0',SMOC,'0',(others=>'0'),(others=>'0')));
      tmp:=0;
      for i in rom'range loop
	 if (rom(i).NodeNr=node_nr) then
	    --if (tmp<nr_of_recv_channels) then
	       ret(tmp).enable:='1';
	       ret(tmp).channel_type:=rom(i).channel_type;
		   ret(tmp).irq:=rom(i).irq;
	       ret(tmp).source:=conv_std_logic_vector(rom(i).source,8);
	       ret(tmp).target:=conv_std_logic_vector(rom(i).target,8);
	       tmp:=tmp+1;
	    --end if;
	 end if;
      end loop;
      return ret;
   end recv_channel_function;

-- Programmable Send and Receive channel info
   constant send_channel_rom:send_channel_info_vector_type(0 to nr_of_send_channels-1):=send_channel_function(send_process_map);
   signal send_channel_info:send_channel_info_vector_type(0 to nr_of_send_channels-1);
   signal send_channel_data:send_channel_info_type;
   -- signal send_channel_hit:std_logic;
   -- signal send_channel_source:std_logic_vector(7 downto 0); -- maximum 256 processes...
   -- signal send_channel_target:std_logic_vector(7 downto 0); -- maximum 256 processes...

   constant recv_channel_rom:recv_channel_info_vector_type(0 to nr_of_recv_channels-1):=recv_channel_function(recv_process_map);
   signal recv_channel_info:recv_channel_info_vector_type(0 to nr_of_recv_channels-1);
   signal recv_channel_data:recv_channel_info_type;

   -- signal recv_channel_hit:std_logic;
   signal recv_channel_source:std_logic_vector(7 downto 0); -- maximum 256 processes...
   signal recv_channel_target:std_logic_vector(7 downto 0); -- maximum 256 processes...
   signal toggle_bits_cpu_side,toggle_bits_noc_side:std_logic_vector(0 to 2**nr_of_recv_channels_size-1);
   -- Recv queue handling will be needed for SDF MOCs...
   -- type recv_queue_address_type is array(integer range <>) of std_logic_vector(1 downto 0);
   -- signal write_queue_address,read_queue_address:recv_queue_address_type(0 to 2**nr_of_recv_channels_size-1);
---------------------------------------------------------------------- 
   alias D_from_NoC:NoC_packet is inport(NoC_packet'high downto 0);
   -- Define header layout used by the receiver process
   alias recv_type is inport(type_high downto type_low);
   alias recv_flit_id is inport(flit_id_high downto flit_id_low);
   alias recv_src_pid is inport(Src_PID_high downto Src_PID_low);
   alias recv_dest_pid is inport(Dest_PID_high downto Dest_PID_low);
   alias Heartbeat:std_logic is GlobalSync;

   -- Setup flit layout
   constant global_clock_low:natural:=0;
   constant global_clock_high:natural:=7;
   constant frame_length_low:natural:=global_clock_high+1;
   constant frame_length_high:natural:=frame_length_low+flit_id_size-1;
   -- Global clock is 40 bits wide...
   constant global_clock_64_low:natural:=0;
   constant global_clock_64_high:natural:=39;
   constant frame_length_64_low:natural:=global_clock_high+1;
   constant frame_length_64_high:natural:=frame_length_low+flit_id_size-1;
   -- constant dest_pid_low:natural:=frame_length_high+1;
   -- constant dest_pid_high:natural:=dest_pid_low+PID_size-1;

   -- alias D_to_NoC:NoC_packet is outport;
   signal D_to_NoC:NoC_packet; -- alias D_to_NoC:NoC_packet is outport;

   constant recv_address_size:integer:=nr_of_recv_channels_size+channel_size;
   constant send_address_size:integer:=nr_of_send_channels_size+channel_size;
----------------------------------------------------------------------------
   type XMIT_STATE_TYPE is (Idle, Transmit_SETUP, Transmit_From_Memory, Wait_for_Queue);

   signal xmit_state        : XMIT_STATE_TYPE;

   type RECV_STATE_TYPE is (Idle, Write_Data, Setup_Data, Wait_for_Write_R);
   signal recv_state        : RECV_STATE_TYPE;

   signal data_reg : std_logic_vector(FlitWidth-1 downto 0);
   -- signal send_counter : std_logic_vector(flit_id_size-1 downto 0); -- max nr_of_flits to send=2**Flit_id_size
   signal send_counter : std_logic_vector(channel_size-1 downto 0); -- max nr_of_flits to send=2**Flit_id_size
   -- 
   -- 32 send buffers to read from
   -- This should be a generic number set by the noc generator, but then the device driver file needs to be
   -- put directly in the project directory (as the software configuration is)
   -- or it should use a generic parameter set by the software configuration file.
   --
   -- In principle, no more than two buffers will ever be needed, but which one to use depends on the
   -- schedule of the processes, and the order in which channels are used in the c-code.
   -- Since this cannot be known beforehand, it is set to the maximum number of used send channels in the node.
   -- 
   signal src_buffer   : std_logic_vector(nr_of_send_channels_size-1 downto 0);
   signal recv_address : std_logic_vector(recv_address_size-1 downto 0); -- Generic nr of write buffers + channel_width (# data words) = nr_of_address bits
   -- signal send_address : std_logic_vector(send_address_size-1 downto 0); -- Generic nr of read buffers + channel_width = nr_of_address bits
   -- Allowed flit widths are 128, 64, and 32 bits, remaining bits sometimes needs to be padded with ones or zeros...
   constant zeros : std_logic_vector(127 downto 0):=(others=>'0');
   constant ones  : std_logic_vector(127 downto 0):=(others=>'1');
   --constant write_base_address : std_logic_vector(31 downto 0):=X"0000A000";
   --constant read_base_address : std_logic_vector(31 downto 0):=X"00008000";
-----------------------------------------------------------------------------------

   -- Bit fields in Starting Frame from uBlaze
   constant counter_size:integer:=send_counter'length;
   constant src_buffer_size:integer:=src_buffer'length; -- shd be one since signal src_buffer   : std_logic_vector( 0 downto 0);

   --signal active_send_channel:integer range 0 to max_nr_of_send_channels-1;
   signal active_send_channel:std_logic_vector(src_buffer_size-1 downto 0);
   signal active_recv_channel:integer range 0 to max_nr_of_recv_channels-1;
   signal active_toggle_bit:std_logic;

   -- where Src_type is std_logic_vector(3 downto 0); -- so shd be able to get IDs till 15
   -- subtype src_int is integer range 0 to Nr_of_Cols*Nr_of_Rows-1;

   subtype recv_counter_type is std_logic_vector(counter_size-1 downto 0);
   type recv_counter_array_type is array(integer range<>) of recv_counter_type;

   signal recv_counter:recv_counter_array_type(0 to nr_of_recv_channels-1);
   signal setup_reg:recv_counter_array_type(0 to nr_of_recv_channels-1);

   -- The global clock is currently only used for debugging purposes, to record the time when a msg transfer was initiated
   -- v2.0 is counting heartbeats instead of clock ticks
   -- signal clock_tick:std_logic_vector(7 downto 0); -- 1 us = 1 clock tick
   signal clock_tick:std_logic_vector(31 downto 0); -- Count clock ticks, used for WCET measurements
   signal global_clock:std_logic_vector(20+19 downto 0); -- Counts clock_ticks since reset (max 12.725829025185185185185185185185 days)
   alias clock_low is global_clock(31 downto 0);
   alias clock_high is global_clock(39 downto 32);

   subtype lword is std_logic_vector(31 downto 0);
   signal command_reg,write_status_reg:lword;
   signal command_type:std_logic;
   signal read_status_reg:std_logic_vector(2*nr_of_recv_channels-1 downto 0); -- max 256 channels...

   type PID_array_type is array(integer range<>) of PID_type;
   signal msg_length_reg:recv_counter_array_type(2*nr_of_recv_channels-1 downto 0);
   signal s_pid,d_pid: PID_array_type(2*nr_of_recv_channels-1 downto 0);
   signal interrupt_reg,old_interrupt_reg:std_logic_vector(nr_of_recv_channels-1 downto 0);

   signal interrupt:std_logic_vector(2**nr_of_recv_channels_size-1 downto 0); -- nr_of_recv_channels_size, index of the channel that is finished receiving
   signal interrupt_request:std_logic;
  
   subtype channel_status_type is std_logic_vector(1 downto 0); -- 00 = Empty, 01=Open, 10=Closed, 11=not used
   constant ChannelEmpty:channel_status_type:="00";
   constant ChannelOpen:channel_status_type:="01";
   constant ChannelClosed:channel_status_type:="10";

   type channel_status_array is array(integer range<>) of channel_status_type;
   signal channel_status:channel_status_array(2*nr_of_recv_channels-1 downto 0);

   -- Synrchronization signals to implement Synchronous MoC in SW
   signal synchronize_flag,old_GlobalSync:std_logic;
   signal toggle_bit,old_toggle_bit:integer range 0 to 1;
-----------------------------------------------------------------------------------
   -- command reg layout
   --    2     7        7      1     9 	(Sum must be less than 32, i.e., the word size of processor)
   -- <Prio><SrcPid><DestPID><Src><Size>
   -- Src - send source buffer (must match nr_of_send_buffers)
   -- Size - Size of send buffer (must match flit_id_size)
   -- <Src>+<Size> can be set dynamically, but must then always be equal to read_address_size
   --              They are currently set statically
   -- The actual numbers below will differ from configuration to configuration, based on information in the generator .xml file
   -- Example numbers provided in comments below are based on a default configuration with the numbers
   --   64 processors, 128 processes, hop_count 6 bits, frame_size 64 flits
   -- Every processor has exactly two processes associated with it.
   -- Size - size of message

   --  2016-12-02
   --  LSB Bit positions of each field fixed to make life easier for VP manufacturers...
   --  <channel_nr> <Priority> <Msg_length>
   --  <16..12>    <11..10>    <9..0>
   ---------------------------------------------------------
   constant size_counter_lsb:integer:= 0; -- 0
   constant size_counter_msb:integer:=size_counter_lsb+counter_size-1; -- 0 + 9 - 1 = 8
   constant priority_lsb:integer:=10; -- size_counter_msb+1; -- 1 + 8 = 9
   constant priority_msb:integer:=priority_lsb+2-1;  -- 9 + 2 - 1 = 10 -- NB! The priority bits currently sets the two MSB bits in the Hop Counter
   constant channel_nr_lsb:integer:=12; -- priority_msb+1; -- 10 + 1 = 11
   constant channel_nr_msb:integer:=channel_nr_lsb+nr_of_send_channels_size-1; -- 11 + ... - 1 = ...

   -- Coordinates are inferred from the process map and are no longer needed in the command_reg
   -- In a fault-tolerant solution, with dynamic re-allocation of processes, the NS,EW,and UD fields are not needed by the switches either.
   -- The destination will be found based on DestPID only
   -- UD - target coord in UD direction
   -- constant ud_lsb:integer:=size_counter_msb+1; -- 10
   -- constant ud_msb:integer:=ud_lsb+UD_Size-1; -- 10 + 2 -1 = 11
   -- EW - target coord in EW direction
   -- constant ew_lsb:integer:=ud_msb+1; -- 12
   -- constant ew_msb:integer:=ew_lsb+EW_Size-1; -- 12 + 2 -1 = 13
   -- NS - target coord in NS direction
   -- constant ns_lsb:integer:=ew_msb+1; -- 14
   -- constant ns_msb:integer:=ns_lsb+EW_Size-1; -- 12 + 2 -1 = 15
   -- DestPid - process id of destination (could replace target coord if we add a process map translation)
   -- constant d_pid_lsb: integer:=ud_msb+1; -- 16

--
--   different message types can be used to implement QoS, do maintenance and support different communication methods, etc.
--   Eg., RequestChannel, Acknowledge, Reset, Resend, etc...
--
--   constant type_lsb:integer:=priority_msb+1; -- 17
--   constant type_msb:integer:=type_lsb+Type_Size-1; -- 17+2-1 = 18

--   alias command_header is command_reg(type_msb downto src_buffer_lsb);
--   alias command_src_buffer is command_reg(src_buffer_msb downto src_buffer_lsb);
--   alias command_size_counter is command_reg(size_counter_msb downto size_counter_lsb);
  -- alias command_ns is command_reg(ns_msb downto ns_lsb);
  -- alias command_ew is command_reg(ew_msb downto ew_lsb);
  -- alias command_ud is command_reg(ud_msb downto ud_lsb);
--   alias command_src_pid is command_reg(s_pid_msb downto s_pid_lsb);
--   alias command_dest_pid is command_reg(d_pid_msb downto d_pid_lsb);
--   alias command_priority is command_reg(priority_msb downto priority_lsb);

   alias command_size_counter is command_reg(size_counter_msb downto size_counter_lsb);
   alias command_priority is command_reg(priority_msb downto priority_lsb);
   alias command_channel_nr is command_reg(channel_nr_msb downto channel_nr_lsb);

--   signal debug_command_buff:std_logic_vector(src_buffer_msb downto src_buffer_lsb);
--   signal debug_command_size:std_logic_vector(size_counter_msb downto size_counter_lsb);
--   signal debug_command_src :std_logic_vector(s_pid_msb downto s_pid_lsb);
--   signal debug_command_dest:std_logic_vector(d_pid_msb downto d_pid_lsb);
--   signal debug_command_priority:std_logic_vector(priority_msb downto priority_lsb);

   -- alias command_type is command_reg(type_msb downto type_lsb);
   -- Write status signals
   alias xmit_busy is write_status_reg(0);
   alias xmit_rest is write_status_reg(31 downto 1);
   signal xmit_start:STD_LOGIC;

   -- Read status signals
   alias recv_status is read_status_reg(2*nr_of_recv_channels-1 downto 0);
   --alias recv_rest is read_status_reg(31 downto 1);
-----------------------------------------------------------------------------------
   constant command_queue_length:integer:=nr_of_send_channels;
   constant command_queue_address_size:integer:=nr_of_send_channels_size;
   -- one bit extra to differ between Switch Maintenance and Normal packets
   type command_queue_type is array(0 to command_queue_length-1) of std_logic_vector(32 downto 0);
   signal command_queue_mem:command_queue_type;
   constant SWITCH_PACKET:std_logic:='0';
   constant NORMAL_PACKET:std_logic:='1';
   -- one extra bit is needed to detect queue empty and queue full
   signal command_queue_write_address,command_queue_read_address:std_logic_vector(command_queue_address_size downto 0);
   signal command_queue_write,command_queue_read,command_queue_empty,command_queue_full:std_logic;
   signal command_queue_in:std_logic_vector(32 downto 0);

-----------------------------------------------------------------------------------
   constant xmit_queue_length:integer:=2;
   constant xmit_queue_address_size:integer:=1;
   type xmit_queue_type is array(0 to xmit_queue_length-1) of NoC_Packet;
   signal xmit_queue_mem:xmit_queue_type;
   -- one extra bit is needed to detect queue empty and queue full
   signal xmit_queue_write_address,xmit_queue_read_address:std_logic_vector(xmit_queue_address_size downto 0);
   signal xmit_queue_write,xmit_queue_read,xmit_queue_empty,xmit_queue_full:std_logic;
   signal xmit_queue_in,xmit_queue_out:NoC_Packet;

-----------------------------------------------------------------------------------

   -- signal GlobalSync:std_logic;
   -- constant node_nr:natural:=col_pos+row_pos*Nr_of_Cols+layer_pos*Nr_of_Cols*Nr_of_Rows;
   signal old_heartbeat:std_logic;

   -- Programmable heartbeat, only available in node 0
   -- Enable signal is set in noc_configuration_package
   signal heartbeat_timer_value:natural;
   signal reset_timer_value:natural;
   signal timer:natural;
   -- constant default_heartbeat_value:natural:=50000000; -- 1s  @ 50 MHz (=1 Hz)
   -- constant default_reset_value:natural:=50000;        -- 1ms @ 50 MHz

   --signal clock_cycle_counter:std_logic_vector(3 downto 0);
   --alias TDN is clock_cycle_counter(3 downto 2);
   --signal debug_TDN:std_logic_vector(1 downto 0);
   signal tdn_counter:std_logic_vector(1 downto 0);
   alias TDN is tdn_counter;

   --type TDN_type is array (natural range <>) of std_logic_vector(0 to 3);
   --constant TDN_slot:TDN_type(0 to 3):=(('1','0','0','0'), -- node 0 injects packets in TDN slot 0
   --                                     ('0','1','0','0'), -- node 1 injects packets in TDN slot 1
   --                                     ('0','0','0','1'), -- node 2 injects packets in TDN slot 3
   --                                    ('0','0','1','0')); -- node 3 injects packets in TDN slot 2
   signal TDN_slot:std_logic_vector(3 downto 0);

-----------------------------------------------------------------------------------
--   alias debug_outport_type:type_type is outport(type_high downto type_low);
--   alias debug_outport_spid:pid_type is outport(Src_PID_high downto Src_PID_low);
--   alias debug_outport_dpid:pid_type is outport(Dest_PID_high downto Dest_PID_low);
--   alias debug_outport_ew:ew_type is outport(ew_high downto ew_low);
--   alias debug_outport_ns:ns_type is outport(ns_high downto ns_low);
--   alias debug_outport_ud:ud_type is outport(ud_high downto ud_low);
--   alias debug_outport_data:data_type is outport(data_high downto data_low);
--   alias debug_inport_type:type_type is inport(type_high downto type_low);
--   alias debug_inport_spid:pid_type is inport(Src_PID_high downto Src_PID_low);
--   alias debug_inport_dpid:pid_type is inport(Dest_PID_high downto Dest_PID_low);
--   alias debug_inport_ew:ew_type is inport(ew_high downto ew_low);
--   alias debug_inport_ns:ns_type is inport(ns_high downto ns_low);
--   alias debug_inport_ud:ud_type is inport(ud_high downto ud_low);
--   alias debug_inport_data:data_type is inport(data_high downto data_low);

begin

   -- debug_command_buff<=command_src_buffer;
   -- debug_command_size<=command_size_counter;
   -- debug_command_src <=command_src_pid;
   -- debug_command_dest<=command_dest_pid;
   -- debug_command_priority<=command_priority;

   -- test_debug(7 downto 0)<=slave_writedata(7 downto 0);
   -- test_debug(8)<=slave_chipselect;
   -- test_debug(9)<=slave_write;
   -- test_debug(10)<=slave_read;
   -- test_debug(31 downto 11) <= (others=>'1');

--   assert (s_pid_msb<32) report "control register larger than word size of processor" severity failure;

------------------------------------------
   global_clock_process:
      process(Clk,reset)
      begin
         if (reset='1') then
		   global_clock<=(others=>'0');
		   clock_tick<=(others=>'0');
		   -- The switch_cycle is run on another reset than the rni, so we have to compensate for the difference.
		   -- The TDN should start in the switch ctrl cycle 3 (11). Then we output the flit just in time to be latched into the Switch's Resource receive buffer
		   -- clock_cycle_counter<="0000"; -- (others=>'0');
		   tdn_counter<=(others=>'0');
	     elsif rising_edge(clk) then
                  --clock_cycle_counter<=clock_cycle_counter+1;
		  -- tdn_counter should be updated so that it presents a new value to the Switch in Switch_cycle 3
		  if (Switch_cycle=2) then
		     tdn_counter<=tdn_counter+1;
		  end if;
		  -- clock tick = 1us
		  -- clock_tick=99 assumes a 100 MHz clock
		  -- if (clock_tick=99) then
		  --    clock_tick<=(others=>'0');
		  --    global_clock<=global_clock+1;
		  -- else
		  clock_tick<=clock_tick+1;
		  -- end if;
		  -- v2.0 is counting heartbeats instead of clock ticks
		  if (GlobalSync/=old_GlobalSync) and (GlobalSync='1') then
		     global_clock<=global_clock+1;
		  end if;
	     end if;
	end process;
-----------------------------------------------------------------------------------------------------------------
   TDN_mask_process:
      process(TDN,xmit_queue_out,TDN_slot)
         variable TDN_enable:std_logic;
      begin
         TDN_enable:=TDN_slot(ieee.std_logic_unsigned.conv_integer(TDN));
	 if (TDN_enable='1') then
            outport<=xmit_queue_out;
	 else
            outport<=Void_Packet;
	 end if;
      end process;

xmit_queue:
   process(clk,reset)
   begin
      if (reset='1') then
	 xmit_queue_mem<=(others=>(others=>'0'));
	 xmit_queue_write_address<=(others=>'0');
	 xmit_queue_read_address<=(others=>'0');
      elsif rising_edge(clk) then
	 for i in 0 to xmit_queue_length-1 loop
	    if (i=xmit_queue_write_address(xmit_queue_address_size-1 downto 0)) then
	       if (xmit_queue_write='1') then
	          xmit_queue_mem(i)<=xmit_queue_in;
	       end if;
            end if;
            if (i=xmit_queue_read_address(xmit_queue_address_size-1 downto 0)) then
	       if (xmit_queue_read='1') then
		  xmit_queue_mem(i)<=Void_Packet;
	       end if;
	    end if;
	 end loop;
	 if (xmit_queue_read='1') then
	    xmit_queue_read_address<=xmit_queue_read_address+1;
         end if;
	 if (xmit_queue_write='1') then
	    xmit_queue_write_address<=xmit_queue_write_address+1;
	 end if;
      end if;
   end process;
   process(xmit_queue_read_address,xmit_queue_mem)
   begin
      for i in 0 to xmit_queue_length-1 loop
         if (i=xmit_queue_read_address(xmit_queue_address_size-1 downto 0)) then
            xmit_queue_out<=xmit_queue_mem(i);
         end if;
      end loop;
   end process;
   xmit_queue_read<=read_R;
   xmit_queue_in<=D_to_NoC;
   xmit_queue_empty<='1' when (xmit_queue_read_address=xmit_queue_write_address) else '0';
   xmit_queue_full <='1' when ((xmit_queue_read_address(xmit_queue_address_size-1 downto 0)=xmit_queue_write_address(xmit_queue_address_size-1 downto 0)) AND
                               (xmit_queue_read_address(xmit_queue_address_size) /= xmit_queue_write_address(xmit_queue_address_size))) else '0';

-----------------------------------------------------------------------------------------------------------------

   heartbeat_generator:if (node_nr=0) generate
      heartbeat_process:
         process(clk,reset)
	    variable setup:std_logic:='0';
         begin
	    if (reset='1') then
	       setup:='0';
               GlobalSync<='0';
	       timer<=0;
            elsif rising_edge(clk) then
               timer<=timer+1;
	       if (setup='0') then
		  if (timer>=reset_timer_value) then
		     timer<=0;
		     setup:='1';
		  end if;
	       else
                  if (timer<=heartbeat_timer_value/2) then
                      GlobalSync<='1';
                  else
                     GlobalSync<='0';
                     if (timer>=heartbeat_timer_value) then
                        timer<=0;
                     end if;
                  end if;
               end if;
            end if;
         end process;
      end generate; -- heartbeat_generator
      GlobalSync<='Z'; -- Default for all other nodes...

-----------------------------------------------------			
-- Reading from avalon(Nios) i.e. avalon wants to write so we pick the command here

-- Picks data from avalon and writes to 'command_reg' which is a std_logic_vector(31 downto 0)

 -- This is the command which tells what to send and where to send and how much to send
 -- The actual data to be sent is written to the RAM

command_queue:
   process(clk,reset)
   begin
      if (reset='1') then
	 command_queue_mem<=(others=>(others=>'0'));
	 command_queue_write_address<=(others=>'0');
	 command_queue_read_address<=(others=>'0');
      elsif rising_edge(clk) then
	 for i in 0 to command_queue_length-1 loop
	    if (i=command_queue_write_address(command_queue_address_size-1 downto 0)) then
	       if (command_queue_write='1') then
	          command_queue_mem(i)<=command_queue_in;
	       end if;
            end if;
            if (i=command_queue_read_address(command_queue_address_size-1 downto 0)) then
	       if (command_queue_read='1') then
		  command_queue_mem(i)<=(others=>'0');
	       end if;
	    end if;
	 end loop;
	 if (command_queue_read='1') then
	    command_queue_read_address<=command_queue_read_address+1;
         end if;
	 if (command_queue_write='1') then
	    command_queue_write_address<=command_queue_write_address+1;
	 end if;
      end if;
   end process;
   process(command_queue_read_address,command_queue_mem)
   begin
      for i in 0 to command_queue_length-1 loop
         if (i=command_queue_read_address(command_queue_address_size-1 downto 0)) then
            command_reg<=command_queue_mem(i)(31 downto 0);
            command_type<=command_queue_mem(i)(32);
         end if;
      end loop;
   end process;
   -- command_reg<=command_queue_mem(ieee.std_logic_unsigned.conv_integer(command_queue_read_address));
   command_queue_empty<='1' when (command_queue_read_address=command_queue_write_address) else '0';
   command_queue_full <='1' when ((command_queue_read_address(command_queue_address_size-1 downto 0)=command_queue_write_address(command_queue_address_size-1 downto 0)) AND
                                  (command_queue_read_address(command_queue_address_size)/= command_queue_write_address(command_queue_address_size))) else '0';

-----------------------------------------------
 -- writing to bus  (i.e. cpu wants to read)
 -- CPu reads the data sent by NoC for it
 --
 -- Steps:
 -- 1. First it reads the interrupt register and finds out which source has sent the data
 --    (The interrupt register is set in -- Interrupt reg (H'001) handler --   process(clk,reset)
 --      after the data has been fully received in the recv_FSM)
 -- 2. Then it reads the exact message length received from that source
 -- 3. Finally it reads the data (data reading is done directly from the memory)


   process(channel_status)
   begin
	read_status_reg<=(others=>'0');
	-- update status bits of read register to allow for polling
      for i in 0 to 2*nr_of_recv_channels-1 loop
	   if (channel_status(i)=ChannelClosed) then
		read_status_reg(i)<='1';
	   else
		read_status_reg(i)<='0';
	   end if;
	end loop;
   end process;

  read_ctrl_interface:
    process(slave_address,slave_read,slave_chipselect,
		write_status_reg,read_status_reg,
		msg_length_reg,
		s_pid,
		d_pid,		
		interrupt_reg) is
       constant zero_size:integer:=s_pid(0)'length+d_pid(0)'length+msg_length_reg(0)'length;
	 variable index:natural range 0 to 2*nr_of_recv_channels-1;
    begin
	slave_readdata<=(others=>'Z');
	-- slave_readdata<=(others=>'0'); -- Avalon bus seems to be wire_or... (its output from nios_2_noc)
	
	if slave_chipselect='1' then
	   if slave_read='1' then
	    
		  case slave_address is
		
		   when "00000000" => -- write data status register
			slave_readdata<=write_status_reg;
			-- if (row_pos=0) and (col_pos=0) and (layer_pos=0) then
			--   assert false report "reading write data status" severity note;
		      --   -- assert false report "------------------------------" severity note;
			-- end if;
		   when "00000001" => -- read status register
			-- The reading of the status bits could be made more intelligent, by using the dest pid as address and return status of only that pid...
			-- slave_readdata<=read_status_reg; 
			-- Version 2.0 is not using this register. It is using the channel as part of the address. See below
			-- if (row_pos=0) and (col_pos=0) and (layer_pos=0) then
			--    assert false report "reading read status register, v1.0 style - Should not happen in v2.0" severity note;
		      --   -- assert false report "------------------------------" severity note;
			-- end if;
			NULL; 
		   when "00000010" =>
			slave_readdata<=zeros(31 downto interrupt_reg'length) & interrupt_reg; -- sending interrupt register value to NioS
			-- This register should also be adopted to v2.0
			-- if (row_pos=0) and (col_pos=0) and (layer_pos=0) then
			--    assert false report "reading interrupt_reg, v1.0 style - Should not happen in v2.0" severity note;
		      --    -- assert false report "------------------------------" severity note;
			-- end if;
		   when "00000011" =>  -- global synchronize_flag register
			slave_readdata<=zeros(31 downto 1) & synchronize_flag;
			-- if (row_pos=0) and (col_pos=0) and (layer_pos=0) then
			--   assert false report "reading GlobalSync Flag" severity note;
		      --   -- assert false report "------------------------------" severity note;
			-- end if;
		   when "00000100" =>
                  -- 20120509 Added Hardware Node Nr for this register
                  --slave_readdata<=conv_std_logic_vector(layer_pos*Nr_of_Rows*Nr_of_Cols+row_pos*Nr_of_Cols+col_pos,32);
			slave_readdata<=conv_std_logic_vector(node_nr,32);
		   when "00000101" =>
			-- 20150512 Added a clock tick register for WCET measurements
			slave_readdata<=clock_tick;
		   when "00000110" | "00000111" =>
			-- reserved for future use
			NULL;
			-- if (row_pos=0) and (col_pos=0) and (layer_pos=0) then
			--    assert false report "reading Reserved flags - Should never happen" severity note;
		      --   -- assert false report "------------------------------" severity note;
			-- end if;
		   when "00001000" | "00001001" | "00001010" | "00001011" | "00001100" | "00001101" | "00001110" | "00001111" =>
			-- reserved for future use
			NULL;
		   when "00010000" | "00010001" | "00010010" | "00010011" | "00010100" | "00010101" | "00010110" | "00010111" =>
			-- reserved for future use
			NULL;
		   when "00011000" | "00011001" | "00011010" | "00011011" | "00011100" | "00011101" | "00011110" | "00011111" =>
			-- reserved for future use
			NULL;
		   when others =>
			case slave_address(7 downto 5) is
			   -- when "000" covered above...
			   when "001" => -- Message Length Registers
				--index:=(1-toggle_bit)*nr_of_recv_channels+(ieee.std_logic_unsigned.conv_integer(slave_address(4 downto 0)));
				--slave_readdata<=zeros(31 downto zero_size) & s_pid(index) & d_pid(index) & msg_length_reg(index); -- Sends msg_len (no of flits) of data received from Source index
				index:=(ieee.std_logic_unsigned.conv_integer(slave_address(4 downto 0)));
                                if (toggle_bits_cpu_side(index)='1') then
				   index:=index+nr_of_recv_channels;
                                end if;
				slave_readdata<=zeros(31 downto counter_size) & msg_length_reg(index);
			   when "010" => -- Read Status Registers
				index:=(ieee.std_logic_unsigned.conv_integer(slave_address(4 downto 0)));
                                if (toggle_bits_cpu_side(index)='1') then
				   index:=index+nr_of_recv_channels;
                                end if;
				slave_readdata<=zeros(31 downto 1) & read_status_reg(index);
				-- if (read_status_reg(index)='0') then
				--	assert (read_status_reg(index)='1') report "Panic mode - Message not received in time!" severity warning;
				--	assert (read_status_reg(index)='1') report "Channel " & debug_number(index) severity warning;
				-- end if;
			   when "011" => -- reserved for used together with the interrupt_register
			   when others => 
				-- reserved for future use 
				-- index range "11" should be used together with the interrupt_register
				-- not implemented yet
				NULL;
			end case;
		end case;
	   end if;
	end if;
    end process;

-----------------------------------------------------			
-- Reading from avalon(Nios) i.e. avalon wants to write so we pick the command here

-- Picks data from avalon and writes to 'command_reg' which is a std_logic_vector(31 downto 0)

 -- This is the command which tells what to send and where to send and how much to send
 -- The actual data to be sent is written to the RAM

 write_ctrl_interface:
   process(clk,reset)
      variable recv_channel_nr:natural range 0 to recv_channel_info'high; -- nr_of_recv_channels-1;
      variable send_channel_nr:natural range 0 to send_channel_info'high; -- nr_of_send_channels-1;
   begin
	if (reset='1') then
	   command_queue_in<=(others=>'0');
	   command_queue_write<='0';
	   old_GlobalSync<='0';
	   synchronize_flag<='0';
	   toggle_bit<=0;
	   old_toggle_bit<=0;
	   toggle_bits_cpu_side<=(others=>'0');
	   if (node_nr=0) then
              heartbeat_timer_value<=default_heartbeat_timer_value;
              reset_timer_value<=default_reset_timer_value;
	   end if;
	elsif rising_edge(clk) then
	   old_GlobalSync<=GlobalSync;
	   old_toggle_bit<=toggle_bit;
	   command_queue_write<='0';
	   -- detect positive flank
	   if (old_GlobalSync/=GlobalSync) and (GlobalSync='1') then
	      synchronize_flag<='1';
	      toggle_bit<=1-toggle_bit;
	      -- Multiple toggle_bits are needed for multi-heartbeat rates...
	      for i in 0 to recv_channel_info'high loop
		    if (recv_channel_info(i).channel_type=SMOC) then
		       toggle_bits_cpu_side(i)<=not(toggle_bits_cpu_side(i));
                    end if;
	      end loop;
	   end if;
	   if ((slave_chipselect='1') and (slave_write='1')) then
	      case slave_address is
		   when "00000000" =>
			-- Normal packet start - write to command queue
			command_queue_write<='1';
			command_queue_in<=NORMAL_PACKET & slave_writedata;
			-- if (row_pos=0) and (col_pos=0) and (layer_pos=0) then
			--   assert false report "Start RNI Send cycle" severity note;
			-- end if;
		   when "00000001" =>
		        -- A write to this register clears the interrupt flag for the requested channel
		        -- This is handled by the interrupt service routine
			--
                        NULL;
		   when "00000010" =>
			-- SWITCH MAINTENANCE packet start - write to command queue
			command_queue_write<='1';
			command_queue_in<=SWITCH_PACKET & slave_writedata;
			-- if (row_pos=0) and (col_pos=0) and (layer_pos=0) then
			--   assert false report "Start Switch Send cycle" severity note;
			-- end if;
		   when "00000011" => -- Clear synchronizer
			-- if (row_pos=0) and (col_pos=0) and (layer_pos=0) then
			--   assert false report "Clear Synchronize Flag" severity note;
			-- end if;
                        -- Clearing of channel_status register is handled in the recv_FSM
			if (slave_writedata=ONES) then
			   -- Clear syncronize_flag (used as a poll bit by SMOC functions...)
			   synchronize_flag<='0';
			   --for i in 0 to nr_of_recv_channels-1 loop
			   --   if (recv_channel_info(i).channel_type=SMOC) then
			   --      toggle_bits_cpu_side(i)<=not(toggle_bits_cpu_side(i));
	           	   --   end if;
                           --end loop;
			else
			   -- Toggle the receive buffer bit for COMB/SDF channels...
			   recv_channel_nr:=ieee.std_logic_unsigned.conv_integer(slave_writedata(nr_of_recv_channels_size-1 downto 0));
			   --if (recv_channel_nr<nr_of_recv_channels) then
			      if (recv_channel_info(recv_channel_nr).channel_type=COMB) then
			         toggle_bits_cpu_side(recv_channel_nr)<=not(toggle_bits_cpu_side(recv_channel_nr));
	           	      end if;
			   --end if;
			end if;
		   when "00000100" =>
                        -- Programmable HeartBeat Timer Value, only accessible from node 0
			if (node_nr=0) then
			   if (use_programmable_heartbeat='1') then
			      heartbeat_timer_value<=ieee.std_logic_unsigned.conv_integer(slave_writedata);
			   end if;
			end if;
		   when "00000101" =>
                        -- Programmable HeartBeat Reset Timer Value, only accessible from node 0
			if (node_nr=0) then
			   if (use_programmable_heartbeat='1') then
			      reset_timer_value<=ieee.std_logic_unsigned.conv_integer(slave_writedata);
			   end if;
			end if;
		   when others => -- "00000101" - "11111111"
			case slave_address(7 downto 6) is
			   -- when "00" covered above...
			   when "01" => -- reserved for future use
				NULL;
			   when "10" => -- Send channel map decoded outside this process
				NULL;
			   when "11" => -- Recv channel map decoded outside this process
				NULL;
			   when others =>
				NULL;
			end case;
		end case;
	
	   end if;
	end if;
   end process;
   -- When receiver is writing to a channel, the cpu should read from its previous received value
   -- This ensures that the cpu sees the channel map as 
   --    low address=last received values
   --    high address=current receive values
   toggle_address_cpu_side<=toggle_bits_cpu_side;
   toggle_address_noc_side<=toggle_bits_noc_side;

-----------------------------------------------------------------------
   G_send_channels_1:if (programmable_send_channels='1') generate
      send_channels_write:process(clk,reset)
	 variable address:natural range 0 to max_nr_of_send_channels-1;
      begin
         if (reset='1') then
	    send_channel_info<=(others=>('0',0,0,0,0,(others=>'0'),(others=>'0')));
	 elsif rising_edge(clk) then
	    if ((slave_write='1') and (slave_address(7 downto 5)="100")) then
	       -- Max 32 addressable channel registers...
	       address:=ieee.std_logic_unsigned.conv_integer(slave_address(4 downto 0));
	       send_channel_info(address).enable<='1';
	       send_channel_info(address).source<=slave_writedata(7 downto 0);
	       send_channel_info(address).target<=slave_writedata(15 downto 8);
               -- v2016 changed to fixed addresses...
               send_channel_info(address).tdn<=ieee.std_logic_unsigned.conv_integer(slave_writedata(31 downto 28)); -- TDNs are not used by this RNI...
	       -- z,y,x
	       --send_channel_info(address).ud<=ieee.std_logic_unsigned.conv_integer(slave_writedata(16+ud_size-1 downto 16));
	       --send_channel_info(address).ns<=ieee.std_logic_unsigned.conv_integer(slave_writedata(16+ud_size+ns_size-1 downto 16+ud_size));
	       --send_channel_info(address).ew<=ieee.std_logic_unsigned.conv_integer(slave_writedata(16+ud_size+ns_size+ew_size-1 downto 16+ud_size+ns_size));
	       send_channel_info(address).ud<=ieee.std_logic_unsigned.conv_integer(slave_writedata(27 downto 24));
	       send_channel_info(address).ns<=ieee.std_logic_unsigned.conv_integer(slave_writedata(23 downto 20));
	       send_channel_info(address).ew<=ieee.std_logic_unsigned.conv_integer(slave_writedata(19 downto 16));
	    end if;
	 end if;
      end process;
   end generate;
   G_send_channels_0:if (programmable_send_channels='0') generate
      send_channel_info<=send_channel_rom;
   end generate;
   G_recv_channels_1:if (programmable_recv_channels='1') generate
      recv_channels_write:process(clk,reset)
	 variable address:natural range 0 to max_nr_of_recv_channels-1;
      begin
         if (reset='1') then
	    recv_channel_info<=(others=>('0',SMOC,'0',(others=>'0'),(others=>'0')));
	 elsif rising_edge(clk) then
	    if ((slave_write='1') and (slave_address(7 downto 5)="110")) then
	       -- Max 32 addressable registers...
	       address:=ieee.std_logic_unsigned.conv_integer(slave_address(4 downto 0));
	       recv_channel_info(address).enable<='1';
           recv_channel_info(address).channel_type<=slave_writedata(17);
           recv_channel_info(address).irq         <=slave_writedata(16);
	       recv_channel_info(address).target      <=slave_writedata(15 downto 8);
	       recv_channel_info(address).source      <=slave_writedata(7 downto 0);
	    end if;
	 end if;
      end process;
   end generate;
   G_recv_channels_0:if (programmable_recv_channels='0') generate
      recv_channel_info<=recv_channel_rom;
   end generate;

   send_channels_read:process(command_reg,send_channel_info)
   begin
      -- active_send_channel<=0;
      active_send_channel<=(others=>'0');
      send_channel_data<=('0',0,0,0,0,(others=>'0'),(others=>'0'));
      L:for i in 0 to send_channel_info'high loop
         if (send_channel_info(i).enable='1') then
            if (command_channel_nr=i) then
	       send_channel_data<=send_channel_info(i);
               -- active_send_channel<=i;
	       active_send_channel<=conv_std_logic_vector(i,active_send_channel'length);
            end if;
         end if;
      end loop;
   end process;

   recv_channels_read:process(recv_channel_source,recv_channel_target,recv_channel_info)
   begin
      active_recv_channel<=0;
      -- recv_channel_hit<='0';
      recv_channel_data<=('0',SMOC,'0',(others=>('0')),(others=>('0')));
      L:for i in 0 to recv_channel_info'high loop
         if (recv_channel_info(i).enable='1') then
	    if ((recv_channel_source=recv_channel_info(i).source) AND (recv_channel_target=recv_channel_info(i).target)) then
	       active_recv_channel<=i;
	       recv_channel_data<=recv_channel_info(i);
	       -- recv_channel_hit<='1';
	       exit L;
	    end if;
         end if;
      end loop;
   end process;

--------------------------------------------------------------
--   reset_process:process(FSL_Rst)
--		 begin
--		    if C_RESET_IS_HIGH = 1 THEN
--			 reset<=FSL_Rst;
--		    else
--			 reset<=not(FSL_Rst);
--		    end if;
--		end process;

   send_buffer_write <= '0';
   send_buffer_read <= '1'; -- Always read from send_buffer port
   send_buffer_writedata <= (others=>'0'); -- Set to zero to avoid unknown Quartus optimizations...

   -- send counter is one bit less than recv_counter (2 read buffers instead of 4 write)
   send_buffer_address <= Src_buffer & send_counter; -- Read on an even word (4 byte) boundary
   
   -- send_address<=Src_buffer & send_counter;

   -- Set xmit status signals
   -- xmit_rest and xmit_busy are alias for one bigger signal 'write_status_reg' which avalon reads
   xmit_busy<='0' when xmit_state=Idle else '1';
   xmit_rest<=(others=>'0');

   -- Only one xmit_start should be given within a frame. Otherwise the transmitter bugs out...
   -- xmit_start<='1' when ((slave_address="0000000") and
   --				 (slave_chipselect='1') and
   --				 (slave_write='1'))
   --		   else '0';
   xmit_start<='1' when ((xmit_state=idle) and (command_queue_empty='0')) else '0';

--------------------------------------------------------------------------------------
-- This FSM controls transmission of data received from Nios (avalon) to NoC
-- It updates D_to_NoC which is an alias for outport ( the actual port)

-- 1. First it sends out a setup packet in xmit_state = Read_Input
-- 2. Then it jumps to xmit_state = Wait_for_Read_R, and waits till data is sent
-- 3. Then it jumps to xmit_state = Transmit_From_Memory
--    a. First sends out global_clock inplace of data (31:0)
--    b. Jumps to xmit_state = Wait_for_Read_R, and waits till data is sent
--    c. Then it starts sending data and jumping between Read_Memory and Wait_for_read_R till all data is send
--    d. Once all data is sent the Delay_state pushes the FSM back to idle

-- Q. What is in the first 2 packets that are sent ??
-- A. First one has (16 downto 9) First byte of global clock and (8 downto 0) msg_len
--    Second flit has the (31 downto 0) of the global clock
--    Remaining flits contain pure data
-- Q. What if flit_width > 32???

   --active_send_channel<=ieee.std_logic_unsigned.conv_integer(command_channel_nr);

 xmit_FSM : process (Clk) is
	--variable header:std_logic_vector(header_size-1 downto 0);
        variable Flit_id: Flit_id_type;
	variable src_pid: PID_type;
	variable dest_pid: PID_type;
	variable priority: HC_type;
	variable dest_row: NS_type;
	variable dest_col: EW_type;
	variable dest_layer: UD_type;

	variable mem_address:std_logic_vector(channel_size-1 downto 0);
	variable mem_address_int:integer range 0 to 2**channel_size-1;
	variable send_clock:std_logic;
	variable delay:integer range 0 to 128*4-1; -- delay for reducing injection rate in order to avoid congestion (max 128 switch cycles) 
        constant injection_delay:integer:=4*FlitInjectionRate-1;
        variable command_ns:ns_type; -- ns_range_type;
	variable command_ew:ew_type; -- ew_range_type;
	variable command_ud:ud_type; -- ud_range_type;
        variable MSG_type:std_logic;
	--variable tmp:std_logic_vector(nr_of_send_channels_size-1 downto 0);
    begin  -- process xmit_FSM
     if rising_edge(clk) then     -- Rising clock edge
      if (reset = '1') then               -- Synchronous reset (active high)
         -- CAUTION: make sure your reset polarity is consistent with the
         -- system reset polarity
         xmit_state      <= Idle;
         D_to_NoC        <= (others=> '0');
	 send_counter	 <= (others => '0');
	 src_buffer	 <= (others => '0');
	 -- BRAM_R_Addr     <= (others => '0' );
	 send_clock:='0';
	 command_queue_read<='0';
	 TDN_slot<=(others=>'0');
         xmit_queue_write<='0';
      else
        command_queue_read<='0';
        xmit_queue_write<='0';
        case xmit_state is
           -------------------------------------------	
           when Idle =>
	      D_to_NoC<=(others=>'0');
              if (xmit_start= '1') then
                 command_queue_read<='1';
		 -- Have to check if the channel is enabled_also...
		 if (send_channel_data.enable='1') then
	            MSG_type:=command_type;

                    -- 1. Save Header Info
		
                    --src_buffer <=command_src_buffer;
                    --src_buffer <= conv_std_logic_vector(active_send_channel,max_nr_of_send_channels_size);
		    src_buffer <= active_send_channel;
                    TDN_slot <= conv_std_logic_vector(send_channel_data.tdn,4);

                    -- 2. Select packet behaviour...	
                    if (command_type=NORMAL_PACKET) then
                       --(command_ew,command_ns,command_ud):=process_map(ieee.std_logic_unsigned.conv_integer(command_dest_pid));
	   	       -- (command_ud,command_ns,command_ew):=target_map(active_send_channel); -- z, y, x
	 	       command_ud:=ud_type(conv_std_logic_vector(send_channel_data.ud,UD_Size));
		       command_ns:=ns_type(conv_std_logic_vector(send_channel_data.ns,NS_Size));
		       command_ew:=ew_type(conv_std_logic_vector(send_channel_data.ew,EW_Size));
                       dest_col   := command_ew; -- conv_std_logic_vector(command_ew,EW_type'length);
                       dest_row   := command_ns; -- conv_std_logic_vector(command_ns,NS_type'length);
                       dest_layer := command_ud; -- conv_std_logic_vector(command_ud,UD_type'length);
		       --if (rni_pos=1) then
			--   assert false report "EW" & print_std_logic_vector(command_ew) severity note;
			--   assert false report "NS" & print_std_logic_vector(command_ns) severity note;
		       --end if;			  
		       -- We could pick src and dest from send_channel_info(active_send_channel) instead...
	               -- src_pid    :=command_src_pid;
        	       -- dest_pid   :=command_dest_pid;
		       src_pid := send_channel_data.source; -- active_send_channel_info(  PID_Size-1 downto 0);
		       dest_pid:= send_channel_data.target; -- active_send_channel_info(2*PID_Size-1 downto PID_Size);
                       priority   :=command_priority & HC_CLR(HC_CLR'high-command_priority'length downto 0);
	               -- Increment size to include global clock info
		       if (FlitWidth=32) then
                          Flit_id      :=command_size_counter+1;
			  -- set send_counter to address of first data word
                          send_counter <=command_size_counter-1;
		       else
                          Flit_id      :=command_size_counter;
			  -- set send_counter to address of first data word
                          send_counter <=command_size_counter-1;
		       end if;
                       xmit_state   <= Transmit_SETUP;
                    else -- SWITCH RECONFIGURATION PACKET
                       dest_col   := command_reg(28+EW_type'length-1 downto 28);
                       dest_row   := command_reg(24+NS_type'length-1 downto 24);
                       dest_layer := command_reg(20+UD_type'length-1 downto 20);
                       src_pid    := (others=>'0'); -- Not used
                       dest_pid   := (others=>'0'); -- Not used
                       priority   := HC_PRIO3;
                       Flit_id      :=command_size_counter-1;
		       -- set send_counter to address of first data word
                       send_counter <=command_size_counter-1;
                       xmit_state   <= Transmit_From_Memory;
                    end if; -- Packet_Type
                 end if;  -- send_channel enable bit...
	      end if; -- xmit_start
        -------------------------------------------------------------------
           when Transmit_SETUP =>
              -- Clear unused fields
              D_to_NoC <= (others => '0');

              -- header:=TYPE_SETUP & Flit_id & src_pid & dest_pid & priority & dest_col & dest_row & dest_layer; 
	      --if (rni_pos=1) then
		--   assert false report "dest_col" & print_std_logic_vector(command_ew) severity note;
		--   assert false report "dest_row" & print_std_logic_vector(command_ns) severity note;
	      -- end if;			  
              -- D_to_NoC(Header_High downto Header_low)<=header;
	      D_to_NoC<=(others=>'0');
	      D_to_NoC(Type_High downto Type_low)<=TYPE_SETUP;
	      D_to_NoC(Flit_id_High downto Flit_id_low)<=Flit_id;
	      D_to_NoC(Src_pid_High downto Src_pid_low)<=src_pid;
	      D_to_NoC(Dest_pid_High downto Dest_pid_low)<=dest_pid;
	      D_to_NoC(NS_High downto NS_low)<=dest_row;
	      D_to_NoC(EW_High downto EW_low)<=dest_col;
	      D_to_NoC(UD_High downto UD_low)<=dest_layer;
	      D_to_NoC(HC_High downto HC_low)<=priority;
              -- Sending out msg_len, source_pid, dest_pid, and the first byte of the global clock

	      -- global_clock is (39 downto 0)
	      if (FlitWidth=32) then
                 D_to_NoC(global_clock_high downto global_clock_low)<=global_clock(39 downto 32);
		 -- command_size_counter contains the message length, we add 2 to accomodate for the 2 Setup flits, 
		 -- i.e., the 40-bit global heartbeat counter
                 D_to_NoC(frame_length_high downto frame_length_low)<=(command_size_counter+2);
                 --D_to_NoC(dest_pid_high downto dest_pid_low)<= dest_pid; -- save dest_pid in the data part of the first setup flit
	         send_clock:='1';
              else
                 D_to_NoC(global_clock_64_high downto global_clock_64_low)<=global_clock(39 downto 0);
		 -- command_size_counter contains the message length, we add 1 since the global heartbeat counter
		 -- fits in the first flit
                 D_to_NoC(frame_length_64_high downto frame_length_64_low)<=(command_size_counter+1);
	         send_clock:='0';
	      end if;
	      xmit_state <= Wait_for_Queue;
        -------------------------------------------------------------------
           when Transmit_From_Memory =>
               -- Clear Data field
               D_to_NoC<=(others=>'0');	
               -- Select behaviour
               if (MSG_Type=NORMAL_PACKET) then
	          --    header:=TYPE_DATA & Flit_id  & src_pid & dest_pid & priority & dest_col & dest_row & dest_layer; 
                  -- D_to_NoC(Header_High downto Header_low)<=header;
	          D_to_NoC<=(others=>'0');
	          D_to_NoC(Type_High downto Type_low)<=TYPE_DATA;
	          D_to_NoC(Flit_id_High downto Flit_id_low)<=Flit_id;
	          D_to_NoC(Src_pid_High downto Src_pid_low)<=src_pid;
	          D_to_NoC(Dest_pid_High downto Dest_pid_low)<=dest_pid;
	          D_to_NoC(NS_High downto NS_low)<=dest_row;
	          D_to_NoC(EW_High downto EW_low)<=dest_col;
	          D_to_NoC(UD_High downto UD_low)<=dest_layer;
	          D_to_NoC(HC_High downto HC_low)<=priority;
	          if (FlitWidth=32) then
                     -- The second Flit should contain the global clock
                     if (send_clock='1') then
                        send_clock:='0';
                        D_to_NoC(Data_high downto Data_low) <= global_clock(31 downto 0); -- Global clock is used for debugging purposes...
                     else
                        D_to_NoC(Data_high downto Data_low) <= send_buffer_readdata;
		        D_to_NoC(Type_High downto Type_low)<=TYPE_DATA;
	                -- set send_counter to address of next data word (0 being the last)
		        send_counter <= send_counter - 1;
                     end if;
	          else
                     D_to_NoC(Data_high downto Data_low) <= send_buffer_readdata;
	             -- set send_counter to address of next data word (0 being the last)
		     send_counter <= send_counter - 1;
                  end if;
               else -- SWITCH_PACKET
                  -- header:=TYPE_SWITCH & Flit_id  & src_pid & dest_pid & priority & dest_row & dest_col & dest_layer; 
                  -- D_to_NoC(Header_High downto Header_low)<=header;
	          D_to_NoC<=(others=>'0');
	          D_to_NoC(Type_High downto Type_low)<=TYPE_SWITCH;
	          D_to_NoC(Flit_id_High downto Flit_id_low)<=Flit_id;
	          D_to_NoC(Src_pid_High downto Src_pid_low)<=src_pid;
	          D_to_NoC(Dest_pid_High downto Dest_pid_low)<=dest_pid;
	          D_to_NoC(NS_High downto NS_low)<=dest_row;
	          D_to_NoC(EW_High downto EW_low)<=dest_col;
	          D_to_NoC(UD_High downto UD_low)<=dest_layer;
		  D_to_NoC(HC_High downto HC_low)<=priority;
                  D_to_NoC(Data_high downto Data_low) <= send_buffer_readdata;
	          -- set send_counter to address of next data word (0 being the last)
	          send_counter <= send_counter - 1;
               end if;
	       xmit_state <= Wait_for_Queue;
          -----------------------------------------------------------------------
	    when Wait_for_Queue =>
		if (xmit_queue_full ='0') then
		   xmit_queue_write<='1';
		   Flit_id := Flit_id -1;
		   if (send_counter=-1) then   -- i.e. all the data has been sent
		      xmit_state <= Idle;
		   else
		      xmit_state <= Transmit_From_Memory;
		   end if;
		end if;
	   end case;
	end if;
     end if;
  end process xmit_FSM;
---------------------------------------------------------------------------------
   -- CAUTION:
   -- The sequence in which data are read in and written out should be
   -- consistant with the sequence they are written and read in the
   -- driver's FSL2NoC_parallel.c file

   -- FSL_S_Read  <= FSL_S_Exists   when (xmit_state=Read_Input) else '0';
   -- FSL_M_Write <= not FSL_M_Full when interrupt='1' else '0';

--   process(FSL_M_Full,interrupt)
--   begin
--	if (interrupt_request='1') then
--         FSL_M_Write <= not FSL_M_Full;
--	else
--	   FSL_M_Write <='0';
--	end if;
--   end process;

--   with interrupt(2 downto 1) select
--      msg_src_reg <= zeros(31 downto counter_size+2) & "00" & setup_reg0 when "00",
--			  zeros(31 downto counter_size+2) & "01" & setup_reg1 when "01",
--			  zeros(31 downto counter_size+2) & "10" & setup_reg2 when "10",
--			  zeros(31 downto counter_size+2) & "11" & setup_reg3 when others;
--
---------------------------------------------------------
   -- Interrupt reg (H'001) handler
   -- slave_irq <= interrupt_request;
   -- SMOCs should only interrupt on Heartbeat
   -- COMBs should interrupt when they receive data
   process(clk,reset)
   begin
      if (reset='1') then
         old_heartbeat<='0';
		 old_interrupt_reg<=(others=>'0');
      elsif rising_edge(clk) then
         old_heartbeat<=heartbeat;
		 old_interrupt_reg<=interrupt_reg;
         slave_irq<='0';
	     for i in 0 to recv_channel_info'high loop
			if (recv_channel_info(i).irq='1') then
		       if (recv_channel_info(i).channel_type=SMOC) then
                  if ((old_heartbeat='0') and (heartbeat='1')) then
                     slave_irq<='1';
			      end if;
               else -- COMB
                  if ((interrupt_reg(i)='1') and (old_interrupt_reg(i)='0')) then
                     slave_irq<='1';
                  end if;
               end if;
            end if;
         end loop;
      end if;
   end process;
   -- But the IRQ registers should still be set, to make sure the message_to_me flag is functioning properly...
   process(clk,reset)
	variable index:natural range 0 to nr_of_recv_channels-1;
   begin
      if (reset='1') then
	   interrupt_reg<= (others=>'0');
      elsif rising_edge(clk) then
	   if (slave_chipselect='1') then
		if (slave_write='1') then
		   if (slave_address="0000001") then
			-- reset the interrupt pointed to by the writedata
			-- Interrupts do not use the toggle bit to determine the right register.
			index:=ieee.std_logic_unsigned.conv_integer(slave_writedata(nr_of_recv_channels_size-1 downto 0));
			interrupt_reg(index)<='0';
		   end if;
		end if;
	   end if;
	
	 -- interrupt is modified when the data is received from the NoC in recv_FSM
       -- This is triggered only when a data flit arrives

       -- It just pulls the interrupt line of Nios
	 -- depending upon the source of the data, value of msg_src_regx and interrupt_regx is set
	
       -- Avalon picks the interrupt register on request in the "read_ctrl_interface" at start 
       -- of the file

       -- Modify later: 
       -- 1. Currently the interrupt is decided from (2 downto 1) so only two bits are decoded
       --    But it has all the four bits of the source field in order to select proper channel
       -- 2. Must correct later otherwise for all others channel 3 wld be triggered

	   -- Update interrupt_reg according to interrupt from recv process	
	   if (interrupt_request='1') then
		index:=ieee.std_logic_unsigned.conv_integer(interrupt);
		interrupt_reg(index)<='1';
	   end if;
	end if;
   end process;
-----------------------------------------------------------------------
  recv_buffer_read <= '0';
  -- recv_buffer_address <= write_base_address(31 downto counter_size+4) & recv_address & "00";
  recv_buffer_address <= active_toggle_bit & recv_address;
  recv_buffer_writedata <= data_reg;

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- We receive from the NoC(switch) here 
   recv_channel_source<=recv_src_pid;
   recv_channel_target<=recv_dest_pid;

 recv_FSM : process (clk,reset) is
	variable msg_size:std_logic_vector(counter_size-1 downto 0);
	variable mem_address:std_logic_vector(recv_address'length-1 downto 0);
        variable tmp_counter:recv_counter_type;
	-- variable recv_src:src_type;
	-- new change
	-- variable source_pid, dest_pid: std_logic_vector(7 downto 0);
	-- variable busy_flag0, busy_flag1, busy_flag2, busy_flag3, RNI_busy: std_logic;
	-- variable ch0_sourceNo, ch1_sourceNo, ch2_sourceNo, ch3_sourceNo: src_type;
	-- variable interrupt0, interrupt1, interrupt2, interrupt3: std_logic;
	-- variable ch_selected: std_logic_vector(channel_size-1 downto 0);
		 -- used to store which source is using which channel as channels 
		 -- are not dedicated anymore
        -- variable channel_selected:natural range 0 to 2*nr_of_recv_channels-1;
        variable channel_selected:natural range 0 to nr_of_recv_channels-1;
	variable channel_nr:natural range 0 to 2*nr_of_recv_channels-1;
	variable index:natural range 0 to nr_of_recv_channels-1;
	variable tmp_index:natural range 0 to 2*nr_of_recv_channels-1;
	variable found:std_logic;
	-- variable mem_address_int:integer range 0 to 2047;
	
   begin -- process recv_FSM
     if (reset='1') then
	  recv_state   <= Idle; -- asynchronous reset of FSM
	  recv_address <= (others=>'0');
	  -- clear channel status information
	  channel_status <= (others=>ChannelEmpty);
	  msg_length_reg <= (others=>(others=>'0'));
          s_pid          <= (others=>(others=>'0'));
          d_pid          <= (others=>(others=>'0'));
	  data_reg       <= (others=>'0');
	  -- clear interrupt flags
	  interrupt_request<='0';
      interrupt<=(others => '0');
	  -- interrupt_reg_fifo<=(others => '0');
	  recv_buffer_write<='0';
	  active_toggle_bit<='0';
	  toggle_bits_noc_side<=(others=>'0');
     elsif rising_edge(clk) then
	  recv_buffer_write<='0';
	  -- clear interrupt register (data is only valid for one clock cycle)
      interrupt<=(others => '0');
	  -- interrupt based on input arrival is for COMB processes only. It should also set the Message_for_me flag...
	  -- clear channel_status on falling edge of corresponding interrupt_reg position
	  interrupt_request<='0';
	  -- interrupt_reg_fifo<=interrupt_reg;
	  --
	  -- v2016 details
  	  -- interrupt for COMBS should happen whenever data has arrived, and then the channel status should be cleared by SW by clearing the channels interrupt_flag_reg...
	  -- clear channel_status on falling edge of corresponding interrupt_reg position'
	  --
  	  -- interrupt for SMOCS should happen once every heartbeat, and then the channel status
          -- should be cleared automatically...
	  -- Add always clear in case of unread channel status on GlobalSync
	  -- In the clock cycle right after global sync, reset the channel status to unread
	  -- No messages should have had time to come before that time...
          --
	  if (old_GlobalSync/=GlobalSync) and (GlobalSync='1') then
	     -- Multiple toggle_bits are needed for multi-heartbeat rates...
	     for i in 0 to recv_channel_info'high loop
		    if (recv_channel_info(i).channel_type=SMOC) then
		       -- Clear the channel status that will be visible to the noc in the next clock cycle
		       -- CPU side toggles. NoC side takes old CPU side value...
		       if (toggle_bits_cpu_side(i)='0') then
		          tmp_index:=nr_of_recv_channels+i;
		       else
		          tmp_index:=i;
		       end if;
		       channel_status(tmp_index)<=ChannelEmpty;
		       toggle_bits_noc_side(i)<=toggle_bits_cpu_side(i);
                    end if;
	     end loop;
	  end if;
	  if ((slave_write='1') and (slave_address(7 downto 0)="00000011")) then -- Clear channel command
	     index:=ieee.std_logic_unsigned.conv_integer(slave_writedata(nr_of_recv_channels_size-1 downto 0));
	     for i in 0 to nr_of_recv_channels-1 loop
		if (i=index) then
		   if (recv_channel_info(i).channel_type=COMB) then
		      -- A write to this address toggles the bits on the cpu side in the next clock cycle.
                      -- This is handled in the write_ctrl_interface handler above...
		      if (toggle_bits_cpu_side(i)='1') then
		         tmp_index:=nr_of_recv_channels+i;
		      else
		         tmp_index:=i;
		      end if;
		      channel_status(tmp_index)<=ChannelEmpty;
		   end if;
		end if;
             end loop;
	  end if;

        case recv_state is
		when Idle =>
       ------------------------------------------------------------------------------
	 -- check for incoming packets
       ------------------------------------------------------------------------------
			if Write_R='1' then -- Check if NoC is sending something to RNI

				-- First Flit ( Setup Flit): Has one byte of global clock, srouce pid id, dest pid is, and the msg_len
				-- Second Flit (Data_type) : Has the 31 downto 0 of the global clock
				-- Remaining flits (Data_type) : Carry the data
				-- So for 15 data flits, we actually receive 17 flits and the code starts running counter from 16 till 0 

				-- Values of recv_counterx are set as per the received counter value in
				-- "if (D_from_NoC(Type_high downto Type_low)=TYPE_SETUP)" block
				-- and these values are decremented after every flit arrival
				-- After the last flit arrives the counter has moved to '0' so the interrupt line is pulled for the CPu
				-- Note that for 15 data flit msg the actual no of flits received is 17 
				-- ( two header flits at start carrying the global clk and the msg_len)
				 
				-- 1. Load proper 'mem_address' depending on src_pid
				--    Currently, a source can only transmit one frame at a time. Therefore, it can only transmit to a single destination at a time.
				--    Since there can only be one source pid, we use that information to determine the target channel.
				--    If multiple channels can be open simultaneously from the same source (i.e., multiple destinations), we have to search for
				--    destination pid as well.
                                --
				--    A single source can only have one send channel open at a time...
				--    ...but there can be many sources sending simultaneously from different nodes.
                                --
				--    A toggle bit to implement alternative reading/writing of recv_channel buffers every other cycle
				--    One buffer is receiving while the other is used in the processes
                                --    This is in practice a two-slot input queue. 
                                --
                                --    a) all SMOCs swap queue slots simultaneously during GlobalSync
				--
				--       Important Note - if flits are arriving too late compared to the GlobalSync, they are stored in the
                        	--       wrong buffer since toggle_bit will have had time to toggle (but then the SW processes should generate 
				--       an exception, since the recv message flag of that channel is not set).
				--
                                --    b) COMBs swap queue slots when the sync register is written to

				channel_selected:=active_recv_channel;
				if (toggle_bits_noc_side(channel_selected)='1') then
				   channel_nr:=nr_of_recv_channels+channel_selected;
				   active_toggle_bit<='1';
				else
				   channel_nr:=channel_selected;
				   active_toggle_bit<='0';
				end if;

				--    Here we set the address (depending on source) to which one should write in the 
				--    recv_buffer: rni_memory 
				--    Depending on source ID: Address is allocated channel followed by the 'msg_len' sent 
				--    from the packet sender

				-- mem_address:=conv_std_logic_vector(channel_selected,nr_of_recv_channels_size) & recv_counter(channel_selected);
				-- rewrite indirect addressing (which infers a memory) to a synthesizable version (which infers an array of registers)

				for i in 0 to nr_of_recv_channels-1 loop
				   if (channel_selected=i) then
				      -- Vivado synthesis cannot handle conv_std_logic_vector with nr_of_channels_size=0. Rewrite
					  if (nr_of_recv_channels_size=0) then
				         mem_address:=recv_counter(i);
					  else
				         mem_address:=conv_std_logic_vector(i,nr_of_recv_channels_size) & recv_counter(i);
					  end if;
				   end if;
				end loop;

                                -- NOTE: Avalon-bus addresses are byte-addressed from the Nios II CPU point of view.
				--       recv_address is connected to "recv_buffer_address" currently 
				--       which is used in "recv_buffer:rni_memory"
                                ---
                                -- Use recv_flit_nr to reorder incoming packages. 
                                -- Potential point for future optimizations:
                                --    If there are no conflicts (i.e., all TDNs have been properly selected), all packets arrive in order...
                                --    which means that recv_counter(i) as above is sufficient, which means that the flit number is not needed anymore =>
				--    recv_address<=mem_address;
                                
				recv_address<= mem_address(mem_address'high downto flit_id_size) & D_from_NoC(Flit_id_high downto Flit_id_low);				
				
                                -- 2. Store data flit into recv buffer

				if (D_from_NoC(Type_high downto Type_low)=TYPE_SETUP) then
				   -- Setup Flit
				   -- Load proper
				   -- 1. recv_state: Setup
				   -- 2. Pick data: 
				   --     i)   data_reg: First byte of global clk
				   --     ii)  recv_counter(x): Set the proper counter (with msg_len) for proper source
				   --     iii) d_pid_reg(x): Store the dest id for SW process
				   --     iv)  s_pid_reg(x): Store the source id SW process
				   --     v)   msg_len(x): Store the frame length for SW process
				   -- 3. recv_address: channel followed by msg_len for the recv_buffer in rni
				

				   --     i) store first byte of global clock
				   --     ii) remaining four bytes are stored in the first TYPE_NORMAL PACKET in a data frame
				   if (FlitWidth=32) then
				      data_reg<=zeros(FlitWidth-1 downto global_clock_high+1) & D_from_NoC(global_clock_high downto global_clock_low); -- 6+counter_size downto (counter_size-1));
				   else
				      data_reg<=zeros(FlitWidth-1 downto global_clock_64_high+1) & D_from_NoC(global_clock_64_high downto global_clock_64_low); -- 6+counter_size downto (counter_size-1));   
				   end if;
						
				   -- ii. load counter value in to the proper counter wrt the recv_src
				   --     Counter is decremented after every flit reception

				   -- recv_counter(channel_selected)<=D_from_NoC(frame_length_high downto frame_length_low);
				   -- rewrite to infer registers
				      for i in 0 to nr_of_recv_channels-1 loop
				         if (i=channel_selected) then
					    if (FlitWidth=32) then
					       recv_counter(i)<=D_from_NoC(frame_length_high downto frame_length_low);
					    else
					       recv_counter(i)<=D_from_NoC(frame_length_64_high downto frame_length_64_low);
					    end if;
				         end if;
				      end loop;

				   -- iii. Set proper dest id
			   	   -- iv. set proper source id
				   -- v. store msg length

				   -- d_pid(channel_nr)<=recv_dest_pid; -- The dest pid is stored in flit header
				   -- s_pid(channel_nr)<=recv_src_pid; -- The source pid is stored in flit header
				   -- msg_length_reg(channel_nr)<=D_from_NoC(frame_length_high downto frame_length_low);

				   -- rewrite to infer registers
				      for i in 0 to 2*nr_of_recv_channels-1 loop
				         if (i=channel_nr) then
					    d_pid(i)<=recv_dest_pid; -- before: D_from_NoC(dest_pid_high downto dest_pid_low); -- now...
					    s_pid(i)<=recv_src_pid; -- The source & Dest pid is stored in flit header
					    msg_length_reg(i)<=D_from_NoC(frame_length_high downto frame_length_low);
				         end if;
				      end loop;
				      recv_state <= Setup_Data;
			        else
				      -- Data flit
				      -- Load proper
				      --1. recv_state: Data
				      --2. Pick data: data_reg: Its data this time 
				      -- ( very first data flit has the global clock, followed by flits with actual data)		

				      data_reg<=D_from_NoC(FlitWidth-1 downto 0);
				      recv_state <= Write_data;
				end if;
			     end if;  -- end if Write_R='1' then

	   when Setup_Data =>
	-------------------------------------------------------------------------
	   -- 1. Activates the recv_buffer_write
	   -- 2. Saves the msg_len value in the setup_regx to send it to the CPU at the time of interrupt   
		-- Storing of specific data has been moved to previous cycle
		recv_buffer_write <= '1'; -- store first byte of global clock
		recv_state <= Wait_for_Write_R;
		-- rewrite to infer registers instead of memory
		-- channel_status(channel_selected)<=ChannelOpen;
		for i in 0 to 2*nr_of_recv_channels-1 loop
		   if (i=channel_nr) then
		      channel_status(i)<=ChannelOpen;
		   end if;
		end loop;
           when Write_Data =>
	---------------------------------------------------------------------------
	   -- 1. Activates the recv_buffer_write
		recv_buffer_write <= '1'; -- store incoming data
		recv_state <= Wait_for_Write_R;
   	   when Wait_for_Write_R =>
	---------------------------------------------------------------------------
	   -- 1. Decrement the msg_len once it has received a flit
	   -- 2. If all flits have been received, pull the interrupt line
	      if (Write_R ='0') then  		
	         recv_buffer_write <= '0';
		 -- rewrite to infer registers instead of memory
		 -- recv_counter(channel_selected)<=recv_counter(channel_selected)-1;
		 -- channel_status(channel_nr)<=ChannelClosed;
		 for i in 0 to nr_of_recv_channels-1 loop
		    if (i=channel_selected) then
		       tmp_counter:=recv_counter(i)-1;
                       recv_counter(i)<=tmp_counter;
		       if (tmp_counter=0) then -- all the flits of the packet have been received
			  if (recv_channel_info(i).channel_type=COMB) then
		             toggle_bits_noc_side(i)<=not(toggle_bits_noc_side(i));
			  end if;
                          -- pull interrupt line
	              interrupt<=conv_std_logic_vector(channel_selected,interrupt'length);
		          interrupt_request<='1';
		       end if;
		    end if;
		 end loop;
		 for i in 0 to 2*nr_of_recv_channels-1 loop
		    if (i=channel_nr) then
                       if (tmp_counter=0) then
		          channel_status(i)<=ChannelClosed;
                       end if;
		    end if;
		 end loop;
		 recv_state <= Idle;
	      end if;
        end case;
      end if;
   end process recv_FSM;

end architecture Implementation;
