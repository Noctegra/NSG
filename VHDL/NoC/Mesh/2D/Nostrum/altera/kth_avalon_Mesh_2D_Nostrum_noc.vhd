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
use ieee.std_logic_signed.all;
use work.NoC_Mesh_2D_Nostrum_package.all;
use work.NoC_configuration_package.all;
use work.NoC_Mesh_2D_Nostrum_avalon_wrapper_package.all;

ENTITY kth_avalon_Mesh_2D_Nostrum_noc IS
   PORT(
	-- Avalon Slave Memory port
	avalon_slave_reset:IN avalon_signal_vector; -- (0 to NoC_Size-1); 
	avalon_slave_address:IN avalon_address_vector; -- (0 to NoC_Size-1); 
	avalon_slave_byteenable:IN avalon_byteenable_vector; -- (0 to NoC_Size-1); 
	avalon_slave_chipselect:IN avalon_signal_vector; -- (0 to NoC_Size-1);
	avalon_slave_clk:IN avalon_signal_vector; -- (0 to NoC_Size-1);
	-- avalon_slave_clken:IN avalon_signal_vector; -- (0 to NoC_Size-1);
	avalon_slave_read:IN avalon_signal_vector; -- (0 to NoC_Size-1);
	avalon_slave_write:IN avalon_signal_vector; -- (0 to NoC_Size-1);
	avalon_slave_writedata:IN avalon_bus_vector; -- (0 to NoC_Size-1);
	avalon_slave_readdata:OUT avalon_bus_vector; -- (0 to NoC_Size-1);
	avalon_slave_irq:OUT avalon_signal_vector; -- (0 to NoC_Size-1);
	-- Direct Access Port
	dap_address:IN dap_address_vector;
	dap_read:IN dap_signal_vector;
	dap_write:IN dap_signal_vector;
	dap_byteenable:IN dap_byteenable_vector;
	dap_writedata:IN dap_bus_vector;
	dap_readdata:OUT dap_bus_vector
   );
END kth_avalon_Mesh_2D_Nostrum_noc;

architecture absolute_addressing of kth_avalon_Mesh_2D_Nostrum_noc is
   component NoC_Mesh_2D_Nostrum
   port(clk,reset:IN std_logic;
	  To_NoC:IN NoC_Packet_cube;
	  To_Res:OUT NoC_Packet_cube;
	  read_R:OUT std_logic_cube;
	  write_R:OUT std_logic_cube);
   end component;
   component kth_Nostrum_rni
      generic(rni_pos:integer);
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
		slave_irq:OUT STD_LOGIC;
		-- NoC Switch Ports
		TO_NOC:out NoC_packet; -- In for switch is out for rni
		FROM_NOC:in NoC_packet; -- Out for switch is in for rni
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
      );
   END component;

	-- NoC Switch Ports
--   signal inport:outpacket_vector(0 to NoC_Size-1); -- Out for switch is in for rni
--   signal outport:inpacket_vector(0 to NoC_Size-1); -- In for switch is out for rni
   signal clk,reset:std_logic;
   signal To_NoC:NoC_Packet_cube;
   signal To_Res:NoC_Packet_cube;
   signal read_R:std_logic_cube;
   signal write_R:std_logic_cube;

   -- GlobalSync port, used to implement Synchronous MoC in SW
   signal HeartBeat:std_logic;

begin
   -- test_avalon_slave_address<=avalon_slave_address;
   clk<=avalon_slave_clk(0);
   reset<=avalon_slave_reset(0);
   UNoC: NoC_Mesh_2D_Nostrum
      port map(clk=>clk,
	         reset=>reset,
	         To_NoC=>To_NoC,
	         To_Res=>To_Res,
	         read_R=>read_R,
	         write_R=>write_R);
    
   UZ:for z in 0 to 0 generate
     UY:for y in 0 to Nr_of_Rows-1 generate
       UX:for x in 0 to Nr_of_Cols-1 generate
		URNI: kth_Nostrum_rni
			generic map(rni_pos=>z*Nr_of_Rows*Nr_of_Cols+y*Nr_of_Cols+x)
			port map(
			   -- Avalon Slave Memory port
			   slave_reset => avalon_slave_reset(z*Nr_of_Rows*Nr_of_Cols+y*Nr_of_Cols+x),
			   slave_address => avalon_slave_address(z*Nr_of_Rows*Nr_of_Cols+y*Nr_of_Cols+x), -- (address_width_map(z*Nr_of_Rows*Nr_of_Cols+y*Nr_of_Cols+x)-1 downto 0),
			   slave_byteenable => avalon_slave_byteenable(z*Nr_of_Rows*Nr_of_Cols+y*Nr_of_Cols+x),
			   slave_chipselect => avalon_slave_chipselect(z*Nr_of_Rows*Nr_of_Cols+y*Nr_of_Cols+x),
			   slave_clk => avalon_slave_clk(z*Nr_of_Rows*Nr_of_Cols+y*Nr_of_Cols+x),
			   -- slave_clken => avalon_slave_clken(z*Nr_of_Rows*Nr_of_Cols+y*Nr_of_Cols+x),
			   slave_read => avalon_slave_read(z*Nr_of_Rows*Nr_of_Cols+y*Nr_of_Cols+x),
			   slave_write => avalon_slave_write(z*Nr_of_Rows*Nr_of_Cols+y*Nr_of_Cols+x),
			   slave_writedata => avalon_slave_writedata(z*Nr_of_Rows*Nr_of_Cols+y*Nr_of_Cols+x),
			   slave_readdata => avalon_slave_readdata(z*Nr_of_Rows*Nr_of_Cols+y*Nr_of_Cols+x),
			   slave_irq => avalon_slave_irq(z*Nr_of_Rows*Nr_of_Cols+y*Nr_of_Cols+x),
			   -- NoC Switch Ports
			   To_NoC   => To_NoC(z*Nr_of_Rows*Nr_of_Cols+y*Nr_of_Cols+x), -- Out for switch is in for rni
			   From_NoC => To_Res(z*Nr_of_Rows*Nr_of_Cols+y*Nr_of_Cols+x), -- In for switch is out for rni
			   read_R   => read_R(z*Nr_of_Rows*Nr_of_Cols+y*Nr_of_Cols+x),
			   write_R  => write_R(z*Nr_of_Rows*Nr_of_Cols+y*Nr_of_Cols+x),
			   -- Direct Access Port
			   dap_address => dap_address(z*Nr_of_Rows*Nr_of_Cols+y*Nr_of_Cols+x),
			   dap_writedata => dap_writedata(z*Nr_of_Rows*Nr_of_Cols+y*Nr_of_Cols+x),
			   dap_readdata => dap_readdata(z*Nr_of_Rows*Nr_of_Cols+y*Nr_of_Cols+x),
			   dap_read => dap_read(z*Nr_of_Rows*Nr_of_Cols+y*Nr_of_Cols+x),
			   dap_write => dap_write(z*Nr_of_Rows*Nr_of_Cols+y*Nr_of_Cols+x),
			   dap_byteenable => dap_byteenable(z*Nr_of_Rows*Nr_of_Cols+y*Nr_of_Cols+x),
			   -- GlobalSync port, used to implement Synchronous MoC in SW
			   HeartBeat => HeartBeat
			);
		-- R_in:inport(z*Nr_of_Rows*Nr_of_Cols+y*Nr_of_Cols+x)<=Write_R(z*Nr_of_Rows*Nr_of_Cols+y*Nr_of_Cols+x) & Read_R(z*Nr_of_Rows*Nr_of_Cols+y*Nr_of_Cols+x) & To_Res(z*Nr_of_Rows*Nr_of_Cols+y*Nr_of_Cols+x);
		-- R_out:To_NoC(z*Nr_of_Rows*Nr_of_Cols+y*Nr_of_Cols+x)<=outport(z*Nr_of_Rows*Nr_of_Cols+y*Nr_of_Cols+x);
	   end generate; -- UX
      end generate; -- UY
   end generate; -- UZ

end absolute_addressing;
