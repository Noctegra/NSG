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
-- OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE,
-------------------------------------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE WORK.NoC_Mesh_3D_Nostrum_TDN_package.all;
USE WORK.noc_configuration_package.all;
use WORK.all;
ENTITY kth_Nostrum_TDN_rni IS
      generic
	(
	    rni_pos : integer := 0
	);
   PORT(
	-- Slave Memory port
	slave_reset:IN STD_LOGIC; 
	slave_address:IN STD_LOGIC_VECTOR(14 DOWNTO 0); 
	slave_byteenable:IN STD_LOGIC_VECTOR(3 DOWNTO 0); 
	slave_chipselect:IN STD_LOGIC;
	slave_clk:IN STD_LOGIC;
	-- slave_clken:IN STD_LOGIC;
	slave_read:IN STD_LOGIC;
	slave_write:IN STD_LOGIC;
	slave_writedata:IN STD_LOGIC_VECTOR(31 DOWNTO 0);
	slave_readdata:OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
	slave_Irq:OUT STD_LOGIC;
	-- NoC Switch Ports
	TO_NOC:out NoC_packet; -- In for switch is out for rni
	FROM_NOC:in NoC_packet; -- Out for switch is in for rni
        Switch_cycle:in std_logic_vector(1 downto 0);
	read_R:IN std_logic;
	write_R:IN std_logic;
	-- Direct Access Port
	dap_address:IN std_logic_vector(13 downto 0);
	dap_writedata:IN std_logic_vector(63 downto 0);
	dap_readdata:OUT std_logic_vector(63 downto 0);
	dap_read:IN std_logic;
	dap_write:IN std_logic;
	dap_byteenable:IN std_logic_vector(7 downto 0);
	-- GlobalSync port, used to implement Synchronous MoC in SW
	HeartBeat:INOUT std_logic
	-- GlobalSync:IN std_logic 
   );
END kth_Nostrum_TDN_rni;

ARCHITECTURE structure OF kth_Nostrum_TDN_rni IS

   component memory_dual_port
	  generic (width_data_a : NATURAL;
        	   width_data_b : NATURAL;
        	   width_byteena_a : NATURAL;
        	   width_byteena_b : NATURAL;
        	   width_address_a : NATURAL;  -- this is the port deciding the number of words...
        	   width_address_b : NATURAL
		);
        port (
              -- inputs:
                 signal address_a : IN STD_LOGIC_VECTOR (width_address_a-1 DOWNTO 0);
                 signal address_b : IN STD_LOGIC_VECTOR (width_address_b-1 DOWNTO 0);
                 signal byteenable_a : IN STD_LOGIC_VECTOR (width_byteena_a-1 DOWNTO 0);
                 signal byteenable_b : IN STD_LOGIC_VECTOR (width_byteena_b-1 DOWNTO 0);
                 signal chipselect_a : IN STD_LOGIC;
                 signal chipselect_b : IN STD_LOGIC;
                 signal clk : IN STD_LOGIC;
                 signal clken_a : IN STD_LOGIC;
                 signal clken_b : IN STD_LOGIC;
                 signal write_a : IN STD_LOGIC;
                 signal write_b : IN STD_LOGIC;
                 signal writedata_a : IN STD_LOGIC_VECTOR (width_data_a-1 DOWNTO 0);
                 signal writedata_b : IN STD_LOGIC_VECTOR (width_data_b-1 DOWNTO 0);

              -- outputs:
                 signal readdata_a : OUT STD_LOGIC_VECTOR (width_data_a-1 DOWNTO 0);
                 signal readdata_b : OUT STD_LOGIC_VECTOR (width_data_b-1 DOWNTO 0)
              );
   end component;
   component kth_interface_to_Nostrum_TDN_noc
    generic
	(
		rni_pos      : integer := 0;
		channel_size : integer := flit_id_size; -- size of one msg channel in nr of data words (must be a power of two)
                flit_width : integer := 32;             -- size of flit data read/writes to/from buffer memory
                --injection_delay : integer  := 3;        -- Nr of switch cycles between flit transmissions inside a packet

		-- The following two parameters are set in the NoC_configuration_package, 
		nr_of_recv_channels_size: integer :=1;  -- size of the receive channel buffer  (nr_of_recv_channels = 2**nr_of_recv_channels_size)
		nr_of_send_channels_size: integer :=1;  -- size of the transmit channel buffer (nr_of_send_channels = 2**nr_of_send_channels_size)
		--
		send_buffer_size:integer:=4; -- nr_of_send_channels_size+channel_size-(log2(flit_width)-5);
		recv_buffer_size:integer:=5  -- nr_of_send_channels_size+channel_size-(log2(flit_width)-5);
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
		slave_clk:IN STD_LOGIC; -- Master Clock
		slave_reset:IN STD_LOGIC;  -- Master Reset
		slave_irq:OUT STD_LOGIC; -- Interrupt Request
		slave_readdata:OUT STD_LOGIC_VECTOR(31 DOWNTO 0); -- Master Data In
		-- slave_address:IN STD_LOGIC_VECTOR(6 DOWNTO 0); -- Master Address
		slave_address:IN STD_LOGIC_VECTOR(7 DOWNTO 0); -- Master Address
		slave_read:IN STD_LOGIC; -- Master Read assert
		slave_chipselect:IN STD_LOGIC; 
		slave_write:IN STD_LOGIC; -- Master Write assert
		slave_writedata:IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- Master Data Out

		-- DO NOT EDIT ABOVE THIS LINE ---------------------
	    	-- GlobalSync port, used to implement Synchronous MoC in SW
		GlobalSync:INOUT std_logic;
		Toggle_address_cpu_side:OUT std_logic_vector(0 to 2**nr_of_recv_channels_size-1);
		Toggle_address_noc_side:OUT std_logic_vector(0 to 2**nr_of_recv_channels_size-1);
		-- what is in for the NoC is out for the nios_to_3D_NoC...
		inport:in NoC_packet;
		outport:out NoC_packet;
		Switch_cycle:in std_logic_vector(1 downto 0);
		read_R:in std_logic;
		write_R:in std_logic
	);

   end component;

   constant use_DAP   : natural_bit := config_use_DAP(rni_pos);
   constant use_64bit : natural_bit := config_use_64bit(rni_pos);


   -- channel_size is always in number of flits, independent of the flit width...
   constant channel_size:integer:=flit_id_size; -- -(log2(FlitWidth)-5);
--   constant rni_pos:integer:=col_pos+row_pos*Nr_of_Cols+layer_pos*Nr_of_Cols*Nr_of_Rows;

   constant nr_of_recv_channels_size:integer:=recv_channel_size_map(rni_pos);
   constant nr_of_send_channels_size:integer:=send_channel_size_map(rni_pos);

   -- One extra bit is needed to be able to toggle addresses
   constant recv_width:integer:=nr_of_recv_channels_size+channel_size+1;
   constant send_width:integer:=nr_of_send_channels_size+channel_size;
   constant bus_width:integer:=32*use_64bit+32;

   -- adapt to axi, avalon, dap, and rni port widths
   -- dap port is 64 bits, cpu bus port is 32 bits. This affect ports <>_a
   -- recv memory is one bit wider than send memory
   constant recv_address_width_a:natural:=recv_width-(log2(bus_width)-log2(FlitWidth));
   constant recv_address_width_b:natural:=recv_width; -- -(log2(FlitWidth)-5);
   constant send_address_width_a:natural:=send_width-(log2(bus_width)-log2(FlitWidth));
   constant send_address_width_b:natural:=send_width; -- -(log2(FlitWidth)-5);
   -- rni port is Flitwidth (128,64, or 32) bits wide, bus port is 32 bits. This affect ports <>_b
   -- constant recv_data_width_b:natural:=FlitWidth;
   -- constant send_data_width_b:natural:=FlitWidth;
   constant recv_address_width_byteena_a:natural:=bus_width/8; -- 64 bits = 8 bytes, 32 bits = 4 bytes
   constant send_address_width_byteena_a:natural:=bus_width/8; -- 64 bits = 8 bytes, 32 bits = 4 bytes
   constant recv_address_width_byteena_b:natural:=FlitWidth/8; -- 1 bit per byte
   constant send_address_width_byteena_b:natural:=FlitWidth/8; -- 1 bit per byte
  
   -- alias internal_address is avalon_slave_address(address_width_map(col_pos+row_pos*Nr_of_Cols+layer_pos*Nr_of_Cols*Nr_of_Rows)-1 DOWNTO 0);
   -- signal internal_address:std_logic_vector(address_width_map(col_pos+row_pos*Nr_of_Cols+layer_pos*Nr_of_Cols*Nr_of_Rows)-1 DOWNTO 0);

   signal Clk,reset:STD_LOGIC;
   signal send_buffer_read1:STD_LOGIC;
   signal send_buffer_read2:STD_LOGIC;
   signal send_buffer_write1:STD_LOGIC;
   signal send_buffer_write2:STD_LOGIC;
   signal send_buffer_address1:STD_LOGIC_VECTOR(send_address_width_a-1 DOWNTO 0) :=(others=>'0') ;
   signal send_buffer_address2:STD_LOGIC_VECTOR(send_address_width_b-1 DOWNTO 0) :=(others=>'0') ;
   signal send_buffer_chipselect1:STD_LOGIC;
   signal send_buffer_chipselect2:STD_LOGIC;
   signal send_buffer_byteenable1:STD_LOGIC_VECTOR(send_address_width_byteena_a-1 downto 0):=(others=>'0') ;
   signal send_buffer_byteenable2:STD_LOGIC_VECTOR(send_address_width_byteena_b-1 downto 0):=(others=>'0') ;
   signal send_buffer_readdata1:STD_LOGIC_VECTOR(bus_width-1 DOWNTO 0):=(others=>'0') ;
   signal send_buffer_readdata2:STD_LOGIC_VECTOR(FlitWidth-1 DOWNTO 0):=(others=>'0') ;
   signal send_buffer_clken:STD_LOGIC;
   signal send_buffer_writedata1:STD_LOGIC_VECTOR(bus_width-1 DOWNTO 0):=(others=>'0') ;
   signal send_buffer_writedata2:STD_LOGIC_VECTOR(FlitWidth-1 DOWNTO 0):=(others=>'0') ;
   signal recv_buffer_read1:STD_LOGIC;
   signal recv_buffer_read2:STD_LOGIC;
   signal recv_buffer_write1:STD_LOGIC;
   signal recv_buffer_write2:STD_LOGIC;
   signal recv_buffer_address1:STD_LOGIC_VECTOR(recv_address_width_a-1 DOWNTO 0):=(others=>'0') ;
   signal recv_buffer_address2:STD_LOGIC_VECTOR(recv_address_width_b-1 DOWNTO 0):=(others=>'0') ;
   -- connection to generic_nios is 1 bit less
   signal internal_recv_buffer_address2:STD_LOGIC_VECTOR(recv_address_width_b-1 DOWNTO 0):=(others=>'0') ;
   signal recv_buffer_chipselect1:STD_LOGIC;
   signal recv_buffer_chipselect2:STD_LOGIC;
   signal recv_buffer_byteenable1:STD_LOGIC_VECTOR(recv_address_width_byteena_a-1 downto 0):=(others=>'0') ;
   signal recv_buffer_byteenable2:STD_LOGIC_VECTOR(recv_address_width_byteena_b-1 downto 0):=(others=>'0') ;
   signal recv_buffer_readdata1:STD_LOGIC_VECTOR(bus_width-1 DOWNTO 0):=(others=>'0') ; 
   signal recv_buffer_readdata2:STD_LOGIC_VECTOR(FlitWidth-1 DOWNTO 0):=(others=>'0') ;
   signal recv_buffer_clken:STD_LOGIC;
   signal recv_buffer_writedata1:STD_LOGIC_VECTOR(bus_width-1 DOWNTO 0):=(others=>'0') ;
   signal recv_buffer_writedata2:STD_LOGIC_VECTOR(FlitWidth-1 DOWNTO 0):=(others=>'0') ;
   signal rni_chipselect:STD_LOGIC;
   signal rni_readdata,rni_readdata_delayed:STD_LOGIC_VECTOR(31 DOWNTO 0):=(others=>'0');
   signal rni_writedata:STD_LOGIC_VECTOR(31 DOWNTO 0):=(others=>'0');
   -- signal rni_address:STD_LOGIC_VECTOR(6 DOWNTO 0):=(others=>'0') ;
   signal rni_address:STD_LOGIC_VECTOR(7 DOWNTO 0):=(others=>'0') ;
   signal rni_write:STD_LOGIC;
   signal rni_read:STD_LOGIC;
   signal slave_clken:STD_LOGIC;
   signal old_slave_read:STD_LOGIC;
   -- signal slave_irq:STD_LOGIC;
   signal toggle_address_cpu_side,toggle_address_noc_side:STD_LOGIC_VECTOR(0 to 2**nr_of_recv_channels_size-1);
   -- signal xor_map:std_logic_vector(recv_address_width_a-1 downto 0);
   signal internal_address:std_logic_vector(14 downto 0);

    -- Mem map
   -- H'000-H'007 Control regs
   -- H'400-H'7FF Read buffer
   -- H'800-H'FFF Write buffer
   -- constant zeroes:std_logic_vector(31 downto 0):=(others=>'0');
   -- work around to fix that Quartus cannot have constant arrays in generic map
   -- signal test_signal:std_logic_vector(internal_address'high downto 3);
   -- signal test_boolean:boolean;

   -- test signals to check messages to/from noc
 --  alias test_send_valid is TO_NOC(valid_pos);
 --  alias test_send_dest_col is TO_NOC(EW_high downto EW_low);
 --  alias test_send_dest_row is TO_NOC(NS_high downto NS_low);
 --  alias test_send_dest_layer is TO_NOC(UD_high downto UD_low);
 --  alias test_send_source_pid is TO_NOC(src_pid_high downto src_pid_low);
 --  alias test_send_flit_id is TO_NOC(flit_id_high downto flit_id_low);
 --  alias test_send_hc_count is TO_NOC(HC_high downto hc_low);
 --  alias test_send_data is TO_NOC(data_high downto 0);
 --  alias test_recv_valid is FROM_NOC(valid_pos);
 --  alias test_recv_dest_col is FROM_NOC(EW_high downto EW_low);
 --  alias test_recv_dest_row is FROM_NOC(NS_high downto NS_low);
 --  alias test_recv_dest_layer is FROM_NOC(UD_high downto UD_low);
 --  alias test_recv_source_pid is FROM_NOC(src_pid_high downto src_pid_low);
 --  alias test_recv_flit_id is FROM_NOC(flit_id_high downto flit_id_low);
 --  alias test_recv_hc_count is FROM_NOC(HC_high downto hc_low);
--   alias test_recv_data is FROM_NOC(data_high downto 0);

   signal internal_writedata:std_logic_vector(bus_width-1 downto 0);
   --signal internal_readdata:std_logic_vector(bus_width-1 downto 0);
   signal internal_be:std_logic_Vector(8/(2-use_64bit)-1 downto 0);
   signal dap_select,dap_rni_select,dap_recv_buffer_select,dap_send_buffer_select:std_logic;
   constant ZEROS:std_logic_vector(31 downto 0):=(others=>'0');
   constant ONES:std_logic_vector(31 downto 0):=(others=>'1');
BEGIN

  -- Delay RdAck one clock cycle due to pipelined memory...
  process(clk,reset)
  begin
     if (reset='1') then
         old_slave_read<='0';
     elsif (rising_edge(clk)) then
        old_slave_read<=slave_read;
     end if;
  end process;
  --IP2Bus_RdAck <= slave_read AND old_slave_read;
  --IP2Bus_Error <= '0';
  ------------------------------------------

   -- internal_address<=slave_address(address_width_map(col_pos+row_pos*Nr_of_Cols+layer_pos*Nr_of_Cols*Nr_of_Rows)-1 DOWNTO 0);
   -- internal address is 32 bit word addressable
   GDAP_1: IF (use_DAP=1) GENERATE
      internal_address<=dap_address & not(dap_byteenable(0)) when (dap_select='1') else slave_address(14 downto 0);
      internal_writedata<=dap_writedata when (dap_select='1') else ZEROS & slave_writedata(31 downto 0) when (internal_address(0)='0') else slave_writedata(31 downto 0) & ZEROS;
      internal_be<=dap_byteenable when (dap_select='1') else "0000" & slave_byteenable when internal_address(0)='0' else
				        slave_byteenable & "0000";

      -- Readdata from memory is streaming, and output is delayed one clock cycle due to output buffer in memory
      dap_readdata<=ZEROS(31 downto 0) & rni_readdata_delayed when (dap_rni_select='1') else
   		         send_buffer_readdata1 when (dap_send_buffer_select='1') else
    		         recv_buffer_readdata1 when (dap_recv_buffer_select='1') else 
   		         (others=>'0');
      -- dap_readdata<=internal_readdata;
      dap_select<=dap_read OR dap_write;
		-- 64 flits, 2 channels => 7 bit addresses
		-- 64 bit => send_address_width_a=6, 32 bit => send_address_width_a=7
        -- 64 bit => range ends with 1, 32 bit => range ends with 0
		-- 64 bit => range starts with 6, 32 bit => range starts with 6
      send_buffer_address1<=internal_address(send_address_width_a-1+use_64bit downto use_64bit); -- memory is word addressable, bus is byte addressable
   END GENERATE; -- use_DAP=1
   GDAP_0: IF (use_DAP=0) GENERATE
      internal_address<=slave_address(14 downto 0);
      internal_writedata<=slave_writedata(31 downto 0);
      internal_be<=slave_byteenable;

      -- Readdata from memory is streaming, and output is delayed one clock cycle due to output buffer in memory
      dap_readdata<=(others=>'0');
      -- dap_readdata<=internal_readdata;
      dap_select<='0';
      send_buffer_address1<=internal_address(send_address_width_a-1 downto 0); -- memory is word addressable, bus is byte addressable
   END GENERATE; -- use_DAP=0
   process(clk,reset)
   begin
      if (reset='1') then
          dap_rni_select<='0';
          dap_recv_buffer_select<='0';
          dap_send_buffer_select<='0';
	  rni_readdata_delayed<=(others=>'0');
	  -- rni_chipselect_delayed<='0';
      elsif (rising_edge(clk)) then
          dap_rni_select<=rni_chipselect;
          dap_recv_buffer_select<=recv_buffer_chipselect1;
          dap_send_buffer_select<=send_buffer_chipselect1;
	  rni_readdata_delayed<=rni_readdata;
	  -- rni_chipselect_delayed<=rni_chipselect;
      end if;
   end process;
  
   recv_buffer_writedata1<=internal_writedata;
   send_buffer_writedata1<=internal_writedata;
   Clk<=slave_clk;
   Reset<=slave_reset;
   slave_clken<='1';
   send_buffer_clken<='1';
   recv_buffer_clken<='1';
   process(internal_address,slave_chipselect,dap_select)
   begin
        recv_buffer_chipselect1<='0';
	send_buffer_chipselect1<='0';
	rni_chipselect<='0';
	if ((slave_chipselect='1') OR (dap_select='1')) then
	   -- if (internal_address(internal_address'high)='1') then
	   if (internal_address(internal_address'high)='1') then
		recv_buffer_chipselect1<='1';
		-- if (row_pos=0) and (col_pos=0) and (layer_pos=0) then
		--   -- assert false report "Reading from Recv Buffer Memory" severity note;
		--   -- assert false report "------------------------------" severity note;
		-- end if;
	   end if;
	   -- if (internal_address(internal_address'high downto internal_address'high-1)="01") then
	   if (internal_address(internal_address'high downto internal_address'high-1)="01") then
		send_buffer_chipselect1<='1';
		-- if (row_pos=0) and (col_pos=0) and (layer_pos=0) then
		--   -- assert false report "Writing to Send Buffer Memory" severity note;
		--   -- assert false report "------------------------------" severity note;
		--end if;
	   end if;
	   -- if (internal_address(internal_address'high downto 7)=ZEROS(internal_address'high downto 7)) then
	   if (internal_address(internal_address'high downto internal_address'high-1)="00") then
		rni_chipselect<='1';
	   end if;
	end if;
   end process;
   -- H'800-H'FFF -- send_buffer
   -- recv_buffer_chipselect1<='1' when (slave_chipselect='1') and (internal_address(internal_address'high)='1') else '0';
   recv_buffer_chipselect2<='1'; -- this buffer is always on seen from the RNI -- recv_buffer_write2 or recv_buffer_read2;
   -- recv_buffer_read1<=slave_read when recv_buffer_chipselect1='1' else '0';
   recv_buffer_read1<=dap_read when ((dap_select='1') and (recv_buffer_chipselect1='1')) else slave_read when (recv_buffer_chipselect1='1') else '0';
   recv_buffer_write1<=dap_write when ((dap_select='1') and (recv_buffer_chipselect1='1')) else slave_write when (recv_buffer_chipselect1='1') else '0';
   -- recv_buffer_read2 is set inside the rni_controller
   -- recv_buffer_write2 is set inside the rni_controller
   recv_buffer_byteenable1<=ZEROS(recv_address_width_byteena_a-1 downto 0) when recv_buffer_chipselect1='0' else internal_be;
   recv_buffer_byteenable2<=ZEROS(recv_address_width_byteena_b-1 downto 0) when recv_buffer_chipselect2='0' else ONES(recv_address_width_byteena_b-1 downto 0);
   -- H'400-H'7FF -- recv_buffer
   -- send_buffer_chipselect1<='1' when (slave_chipselect='1') and 
   --						 (internal_address(internal_address'high downto internal_address'high-1)="01") else '0';
   send_buffer_chipselect2<='1'; -- The send buffer is always on from the RNI point of view...
   send_buffer_read2<='1'; -- rni always reads the send_buffer...
   -- send_buffer_write2<='0'; -- this signal is set inside the rni_controller
   send_buffer_read1<=dap_read when ((dap_select='1') and (send_buffer_chipselect1='1')) else slave_read when (send_buffer_chipselect1='1') else '0';
   send_buffer_write1<=dap_write when ((dap_select='1') and (send_buffer_chipselect1='1')) else slave_write when (send_buffer_chipselect1='1') else '0';
   send_buffer_byteenable1<=ZEROS(send_address_width_byteena_a-1 downto 0) when ((dap_select='0') AND (send_buffer_chipselect1='0')) else internal_be;
   send_buffer_byteenable2<=ZEROS(send_address_width_byteena_b-1 downto 0) when send_buffer_chipselect2='0' else ONES(send_address_width_byteena_b-1 downto 0);

   -- H'000-00F
   -- rni_chipselect<='1' when ((slave_chipselect='1') and 
   --				     (internal_address(internal_address'high downto 5)=ZEROS(internal_address'high downto 5))) else '0';
   -- Xilinx memory response is one clock cycle slower than Altera memories, so we need to compensate rni reads
   -- since they are immediate for both Altera and Xilinx...
   -- Thus, we use the dap select signals since they are one clock cycle delayed compared to the normal select signals
   --internal_readdata<=ZEROS(31 downto 0) & rni_readdata_delayed when (dap_select='1') else
   --		      send_buffer_readdata1 when (dap_send_buffer_select='1') else
   --		      recv_buffer_readdata1 when (dap_recv_buffer_select='1') else 
   -- 		      (others=>'0');

	send_buffer:memory_dual_port
		  generic map (width_data_a => bus_width, -- dap access port width (bus port is 32 bits)
			       width_data_b => FlitWidth, -- rni port width
			       width_byteena_a => send_address_width_byteena_a,
			       width_byteena_b => send_address_width_byteena_b,
			       width_address_a => send_address_width_a,
			       width_address_b => send_address_width_b
			      )
	        port map(
        	      -- inputs:
                	 address_a => send_buffer_address1,
	                 address_b => send_buffer_address2,
        	         byteenable_a => send_buffer_byteenable1,
                	 byteenable_b => send_buffer_byteenable2,
	                 chipselect_a => send_buffer_chipselect1,
        	         chipselect_b => send_buffer_chipselect2,
                	 clk => slave_clk,
	                 clken_a => slave_clken,
        	         clken_b => send_buffer_clken,
                	 write_a => send_buffer_write1,
	                 write_b => send_buffer_write2,
        	         writedata_a => send_buffer_writedata1,
                	 writedata_b => send_buffer_writedata2,
	              -- outputs:
        	         readdata_a => send_buffer_readdata1,
                	 readdata_b => send_buffer_readdata2
		);
	recv_buffer:memory_dual_port
		  generic map (width_data_a => bus_width, -- dap access port width (bus port is 32 bits)
			       width_data_b => FlitWidth, -- rni port width
			       width_byteena_a => recv_address_width_byteena_a,
			       width_byteena_b => recv_address_width_byteena_b,
			       width_address_a => recv_address_width_a,
			       width_address_b => recv_address_width_b
			      )
	        port map(
        	      -- inputs:
        	         address_a => recv_buffer_address1, 
        	         address_b => recv_buffer_address2,
        	         byteenable_a => recv_buffer_byteenable1,
        	         byteenable_b => recv_buffer_byteenable2,
        	         chipselect_a => recv_buffer_chipselect1,
        	         chipselect_b => recv_buffer_chipselect2,
        	         clk => slave_clk,
        	         clken_a => slave_clken,
        	         clken_b => recv_buffer_clken,
        	         write_a => recv_buffer_write1,
        	         write_b => recv_buffer_write2,
        	         writedata_a => recv_buffer_writedata1,
        	         writedata_b => recv_buffer_writedata2,
	              -- outputs:
        	         readdata_a => recv_buffer_readdata1,
        	         readdata_b => recv_buffer_readdata2
              );

   G1:if (use_64bit=1) GENERATE 
	output:slave_readdata<=rni_readdata_delayed when (dap_rni_select='1') else
   		      send_buffer_readdata1(31 downto 0)  when ((dap_send_buffer_select='1') and (internal_address(0)='0')) else
   		      send_buffer_readdata1(63 downto 32) when ((dap_send_buffer_select='1') and (internal_address(0)='1')) else
   		      recv_buffer_readdata1(31 downto 0)  when ((dap_recv_buffer_select='1') and (internal_address(0)='0')) else
   		      recv_buffer_readdata1(63 downto 32) when ((dap_recv_buffer_select='1') and (internal_address(0)='1')) else
   		      (others=>'0');
   END GENERATE; -- G1
   G0:if (use_64bit=0) GENERATE
	output:slave_readdata<=rni_readdata_delayed when (dap_rni_select='1') else
   		      send_buffer_readdata1(31 downto 0)  when (dap_send_buffer_select='1') else
   		      recv_buffer_readdata1(31 downto 0)  when (dap_recv_buffer_select='1') else
   		      (others=>'0');
   END GENERATE; -- G0
   -- when recv_buffer_chipselect1='1' else
   --				  (others=>'0');
   -- slave_readdata<=rni_readdata;
   -- slave_readdata<=recv_buffer_readdata1;
   -- slave_readdata<=send_buffer_readdata1;
   rni_write<=dap_write when (dap_select='1') else slave_write when (rni_chipselect='1') else '0';
   rni_read<=dap_read when (dap_select='1') else slave_read when (rni_chipselect='1') else '0';
   -- control reg is word addressable, bus is byte addressable
   rni_address<=internal_address(7 downto 0) when (dap_select='1') else slave_address(7 downto 0);
   rni_writedata<=dap_writedata(31 downto 0) when (dap_select='1') else slave_writedata;

interface:kth_interface_to_Nostrum_TDN_noc
	generic map(
			rni_pos => rni_pos,
			channel_size => channel_size, -- size of one msg channel in nr of data words (must be a power of two)
                        flit_Width => FlitWidth,

		        -- The following two parameters are set in the noc_configuration_package, 
			nr_of_recv_channels_size => nr_of_recv_channels_size,
		        nr_of_send_channels_size => nr_of_send_channels_size,  -- size of the transmit channel buffer (nr_of_send_channels = 2**nr_of_send_channels_size)
			--
			send_buffer_size => send_address_width_b,
			recv_buffer_size => recv_address_width_b
		    )
	port map(
		Clk => slave_Clk,
		Reset => slave_Reset,

		-- DO NOT EDIT BELOW THIS LINE ---------------------
		-- Bus protocol ports, do not add or delete. 
		-- Memory interface ports
		send_buffer_address =>		send_buffer_address2,
		send_buffer_readdata =>		send_buffer_readdata2, 
		send_buffer_write =>		send_buffer_write2,
		send_buffer_read =>		send_buffer_read2,
		send_buffer_writedata => 	send_buffer_writedata2,
		recv_buffer_address =>		internal_recv_buffer_address2,
		recv_buffer_readdata =>	     	recv_buffer_readdata2, 
		recv_buffer_write =>		recv_buffer_write2,
		recv_buffer_read =>		recv_buffer_read2,
		recv_buffer_writedata => 	recv_buffer_writedata2,

		-- Slave ports
		slave_clk => slave_clk,
		slave_reset => slave_reset,
		slave_irq => slave_irq,
		slave_readdata => rni_readdata,
		slave_address => rni_address,
		slave_chipselect => rni_chipselect,
		slave_read => rni_read,
		slave_write => rni_write,
		slave_writedata => rni_writedata,
		-- DO NOT EDIT ABOVE THIS LINE ---------------------

            	-- GlobalSync port, used to implement Synchronous MoC in SW
		GlobalSync => HeartBeat,
		-- Toggle_address port, used to locally remap addresses so that the nios always sees the last received parameter set
		Toggle_Address_cpu_side => Toggle_address_cpu_side,
		Toggle_Address_noc_side => Toggle_address_noc_side,
		-- Test_debug => Test_debug_rni,
		-- what is in for the NoC is out for the nios_2_NoC...
		inport => FROM_NOC,
		outport => TO_NOC,
		Switch_cycle => Switch_cycle,
		read_r => read_r,
		write_r => write_r
	);

-- When receiver is writing to a channel, the nios should read from its previous received value
-- The bit flip ensures that the nios always sees the channel memory map as (low address=received values, high address=not yet received values)
   --process(toggle_address)
   --begin
   --	xor_map<=(others=>'0');
   --	xor_map(xor_map'high)<=toggle_address;
   --end process;
   --recv_buffer_address1<=internal_address(recv_address_width_a-1 downto 0) xor xor_map; -- memory is word addressable, bus is byte addressable

   -- Recv memory Accesses from cpu
   process(internal_address,toggle_address_cpu_side)
      variable active_buffer:integer range 0 to 2**nr_of_recv_channels_size-1;
   begin
      -- <buffer><channel_size><msg_size> : <1><2><2> => recv_width=5, buffer is at 4, channel 3 downto 2, msg 1 downto 0
	  -- active_buffer:=ieee.std_logic_unsigned.conv_integer(internal_address(recv_address_width_a-1 downto recv_address_width_a-nr_of_recv_channels_size));
	  active_buffer:=ieee.std_logic_unsigned.conv_integer(internal_address(recv_address_width_a-2+use_64bit downto recv_address_width_a-1+use_64bit-nr_of_recv_channels_size));
   	--xor_map<=(others=>'0');
	--xor_map(xor_map'high)<=toggle_address_cpu_side(active_buffer);
        -- memory is Flitwidth sized word addressable on the noc side, cpu side bus is 32-bit word addressable
        -- but DAP_port is 64 bits, so cpu side has 64 bit connection to memory if DAP port is used
        -- (this can be optimized more based on DAP settings)...
		-- 64 flits, 2 channels => 7+1 toggle bit addresses
		-- 64 bit => recv_address_width_a=7, 32 bit => recv_address_width_a=8
        -- 64 bit => range ends with 1, 32 bit => range ends with 0
		-- 64 bit => range starts with 6, 32 bit => range starts with 6
	  recv_buffer_address1<=toggle_address_cpu_side(active_buffer) & internal_address(recv_address_width_a-2+use_64bit downto use_64bit);
	-- recv_buffer_address1<=toggle_address_cpu_side(active_buffer) & internal_address(recv_width-2 downto 1);
	-- -- recv_buffer_address1<=internal_address(recv_width-nr_of_recv_channels_size+1 downto 1);
   end process;

   -- Recv memory Accesses from rni
   process(internal_recv_buffer_address2,toggle_address_noc_side)
      variable active_buffer:integer range 0 to 2**nr_of_recv_channels_size-1;
   begin
	active_buffer:=ieee.std_logic_unsigned.conv_integer(internal_recv_buffer_address2(recv_address_width_b-2 downto recv_address_width_b-1-nr_of_recv_channels_size));
  	-- recv_buffer_address2<=not(toggle_address(active_buffer)) & internal_recv_buffer_address2(recv_address_width_b-2 downto 0); -- memory is word addressable, bus is byte addressable
        -- memory is Flitwidth sized word addressable on the noc side, cpu side is 32-bit word addressable
        -- but DAP_port is 64 bits, so cpu side has 64 bit connection to memory...
  	recv_buffer_address2<=toggle_address_noc_side(active_buffer) & internal_recv_buffer_address2(recv_address_width_b-2 downto 0);
   end process;
      
   --recv_buffer_address2<=not(toggle_address) & internal_recv_buffer_address2; -- memory is word addressable, bus is byte addressable

END structure;
