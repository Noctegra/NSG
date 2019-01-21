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
use work.NoC_configuration_package.all;
use work.NoC_Mesh_2D_Nostrum_package.all;
use work.NoC_Mesh_2D_Nostrum_axi_wrapper_package.all;

ENTITY kth_axi_Mesh_2D_Nostrum_noc IS
   PORT(
	-- Axi Slave Memory port
	s_axi_aclk	: in axi_onebit_vector;  -- std_logic
	s_axi_aresetn	: in axi_onebit_vector;  -- std_logic
	s_axi_awaddr	: in axi_address_vector; -- std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
	s_axi_awprot	: in axi_threebit_vector;  -- std_logic_vector(2 downto 0);
	s_axi_awvalid	: in axi_onebit_vector;  -- std_logic
	s_axi_awready	: out axi_onebit_vector; -- std_logic
	s_axi_wdata	: in axi_bus_vector;     -- std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
	s_axi_wstrb	: in axi_byteenable_vector; -- std_logic_vector((C_S00_AXI_DATA_WIDTH/8)-1 downto 0);
	s_axi_wvalid	: in axi_onebit_vector;  -- std_logic
	s_axi_wready	: out axi_onebit_vector; -- std_logic;
	s_axi_bresp	: out axi_twobit_vector;   -- std_logic_vector(1 downto 0);
	s_axi_bvalid	: out axi_onebit_vector; -- std_logic;
	s_axi_bready	: in axi_onebit_vector;  -- std_logic;
	s_axi_araddr	: in axi_address_vector;     -- std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
	s_axi_arprot	: in axi_threebit_vector;  -- std_logic_vector(2 downto 0);
	s_axi_arvalid	: in axi_onebit_vector;  -- std_logic;
	s_axi_arready	: out axi_onebit_vector; -- std_logic;
	s_axi_rdata	: out axi_bus_vector;    -- std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
	s_axi_rresp	: out axi_twobit_vector;   -- std_logic_vector(1 downto 0);
	s_axi_rvalid	: out axi_onebit_vector; -- std_logic;
	s_axi_rready	: in axi_onebit_vector;  -- std_logic;

	-- Direct Access Port
	dap_address      : IN dap_address_vector;
	dap_read         : IN dap_signal_vector;
	dap_write        : IN dap_signal_vector;
	dap_byteenable   : IN dap_byteenable_vector;
	dap_writedata    : IN dap_bus_vector;
	dap_readdata     : OUT dap_bus_vector;
	-- GlobalSync port, used to implement Synchronous MoC in SW
	NoC_Irq		 : OUT axi_onebit_vector
   );
END kth_axi_Mesh_2D_Nostrum_noc;

architecture absolute_addressing of kth_axi_Mesh_2D_Nostrum_noc is
   component NoC_Mesh_2D_Nostrum
      port(clk,reset:IN std_logic;
	     To_NoC:IN NoC_Packet_cube;
	     To_Res:OUT NoC_Packet_cube;
	     read_R:OUT std_logic_cube;
	     write_R:OUT std_logic_cube);
   end component;
   component kth_axi_Nostrum_rni
      generic
	(
	    -- Users to add parameters here
	    rni_number : integer := 0
	    -- use_64bit : integer := 0
	);
      PORT(
	   -- Users to add ports here
	   -- NoC Switch Ports
	   TO_NOC:out NoC_packet; -- In for switch is out for rni
	   FROM_NOC:in NoC_packet; -- Out for switch is in for rni
	   read_R:IN std_logic;
	   write_R:IN std_logic;
	   -- GlobalSync port, used to implement Synchronous MoC in SW
	   HeartBeat:INOUT std_logic;
	   NoC_Irq:OUT std_logic;
	   -- Direct Access Port
	   -- dap_address:IN std_logic_vector(14-use_64bit downto 0);
	   -- dap_writedata:IN std_logic_vector(32*use_64bit+31 downto 0);
	   -- dap_readdata:OUT std_logic_vector(32*use_64bit+31 downto 0);
	   dap_address:IN std_logic_vector(13 downto 0);
	   dap_writedata:IN std_logic_vector(63 downto 0);
	   dap_readdata:OUT std_logic_vector(63 downto 0);
	   dap_read:IN std_logic;
	   dap_write:IN std_logic;
	   -- dap_byteenable:IN std_logic_vector(8/(2-use_64bit)-1 downto 0);
	   dap_byteenable:IN std_logic_vector(7 downto 0);
	   -- User ports ends
	   -- Do not modify the ports beyond this line
	   -- Ports of Axi Slave Bus Interface S_AXI
	   s_axi_aclk	: in std_logic;
	   s_axi_aresetn: in std_logic;
	   s_axi_awaddr	: in std_logic_vector(16 downto 0);
	   s_axi_awprot	: in std_logic_vector(2 downto 0);
	   s_axi_awvalid: in std_logic;
	   s_axi_awready: out std_logic;
	   s_axi_wdata	: in std_logic_vector(31 downto 0);
	   s_axi_wstrb	: in std_logic_vector(3 downto 0);
	   s_axi_wvalid	: in std_logic;
	   s_axi_wready	: out std_logic;
	   s_axi_bresp	: out std_logic_vector(1 downto 0);
	   s_axi_bvalid	: out std_logic;
	   s_axi_bready	: in std_logic;
	   s_axi_araddr	: in std_logic_vector(16 downto 0);
	   s_axi_arprot	: in std_logic_vector(2 downto 0);
	   s_axi_arvalid: in std_logic;
	   s_axi_arready: out std_logic;
	   s_axi_rdata	: out std_logic_vector(31 downto 0);
	   s_axi_rresp	: out std_logic_vector(1 downto 0);
	   s_axi_rvalid	: out std_logic;
	   s_axi_rready	: in std_logic
      );
   END component;

	-- NoC Switch Ports
   signal clk,reset:std_logic;
   signal Heartbeat:std_logic;
   signal To_NoC:NoC_Packet_cube;
   signal To_Res:NoC_Packet_cube;
   signal read_R:std_logic_cube;
   signal write_R:std_logic_cube;

begin
   clk<=s_axi_aclk(0);
   reset<=not(s_axi_aresetn(0));
   UNoC:NoC_Mesh_2D_Nostrum
      port map(clk=>clk,
	         reset=>reset,
	         To_NoC=>To_NoC,
	         To_Res=>To_Res,
	         read_R=>read_R,
	         write_R=>write_R);
    
   UZ:for z in 0 to 0 generate
     UY:for y in 0 to Nr_of_Rows-1 generate
       UX:for x in 0 to Nr_of_Cols-1 generate
		URNI: kth_axi_Nostrum_rni
			generic map(rni_number=>z*Nr_of_Rows*Nr_of_Cols+y*Nr_of_Cols+x)
			port map(
			   -- Axi Slave Bus Interface
			   s_axi_aclk	=> s_axi_aclk(z*Nr_of_Rows*Nr_of_Cols+y*Nr_of_Cols+x), 
			   s_axi_aresetn=> s_axi_aresetn(z*Nr_of_Rows*Nr_of_Cols+y*Nr_of_Cols+x),
			   s_axi_awaddr	=> s_axi_awaddr(z*Nr_of_Rows*Nr_of_Cols+y*Nr_of_Cols+x),
			   s_axi_awprot	=> s_axi_awprot(z*Nr_of_Rows*Nr_of_Cols+y*Nr_of_Cols+x),
			   s_axi_awvalid=> s_axi_awvalid(z*Nr_of_Rows*Nr_of_Cols+y*Nr_of_Cols+x),
			   s_axi_awready=> s_axi_awready(z*Nr_of_Rows*Nr_of_Cols+y*Nr_of_Cols+x),
			   s_axi_wdata	=> s_axi_wdata(z*Nr_of_Rows*Nr_of_Cols+y*Nr_of_Cols+x),
			   s_axi_wstrb	=> s_axi_wstrb(z*Nr_of_Rows*Nr_of_Cols+y*Nr_of_Cols+x),
			   s_axi_wvalid	=> s_axi_wvalid(z*Nr_of_Rows*Nr_of_Cols+y*Nr_of_Cols+x),
			   s_axi_wready	=> s_axi_wready(z*Nr_of_Rows*Nr_of_Cols+y*Nr_of_Cols+x),
			   s_axi_bresp	=> s_axi_bresp(z*Nr_of_Rows*Nr_of_Cols+y*Nr_of_Cols+x),
			   s_axi_bvalid	=> s_axi_bvalid(z*Nr_of_Rows*Nr_of_Cols+y*Nr_of_Cols+x),
			   s_axi_bready	=> s_axi_bready(z*Nr_of_Rows*Nr_of_Cols+y*Nr_of_Cols+x),
			   s_axi_araddr	=> s_axi_araddr(z*Nr_of_Rows*Nr_of_Cols+y*Nr_of_Cols+x),
			   s_axi_arprot	=> s_axi_arprot(z*Nr_of_Rows*Nr_of_Cols+y*Nr_of_Cols+x),
			   s_axi_arvalid=> s_axi_arvalid(z*Nr_of_Rows*Nr_of_Cols+y*Nr_of_Cols+x),
			   s_axi_arready=> s_axi_arready(z*Nr_of_Rows*Nr_of_Cols+y*Nr_of_Cols+x),
			   s_axi_rdata	=> s_axi_rdata(z*Nr_of_Rows*Nr_of_Cols+y*Nr_of_Cols+x),
			   s_axi_rresp	=> s_axi_rresp(z*Nr_of_Rows*Nr_of_Cols+y*Nr_of_Cols+x),
			   s_axi_rvalid	=> s_axi_rvalid(z*Nr_of_Rows*Nr_of_Cols+y*Nr_of_Cols+x),
			   s_axi_rready	=> s_axi_rready(z*Nr_of_Rows*Nr_of_Cols+y*Nr_of_Cols+x),
			   -- NoC Switch Ports
			   To_NoC   => To_NoC(z*Nr_of_Rows*Nr_of_Cols+y*Nr_of_Cols+x), -- Out for switch is in for rni
			   From_NoC => To_Res(z*Nr_of_Rows*Nr_of_Cols+y*Nr_of_Cols+x), -- In for switch is out for rni
			   read_R   => read_R(z*Nr_of_Rows*Nr_of_Cols+y*Nr_of_Cols+x),
			   write_R  => write_R(z*Nr_of_Rows*Nr_of_Cols+y*Nr_of_Cols+x),
			   -- Direct Access Port
			   dap_address    => dap_address(z*Nr_of_Rows*Nr_of_Cols+y*Nr_of_Cols+x),
			   dap_writedata  => dap_writedata(z*Nr_of_Rows*Nr_of_Cols+y*Nr_of_Cols+x),
			   dap_readdata   => dap_readdata(z*Nr_of_Rows*Nr_of_Cols+y*Nr_of_Cols+x),
			   dap_read       => dap_read(z*Nr_of_Rows*Nr_of_Cols+y*Nr_of_Cols+x),
			   dap_write      => dap_write(z*Nr_of_Rows*Nr_of_Cols+y*Nr_of_Cols+x),
			   dap_byteenable => dap_byteenable(z*Nr_of_Rows*Nr_of_Cols+y*Nr_of_Cols+x),
			   -- GlobalSync port, used to implement Synchronous MoC in SW
			   HeartBeat => HeartBeat,
			   NoC_Irq => NoC_Irq(z*Nr_of_Rows*Nr_of_Cols+y*Nr_of_Cols+x)
			);
	    end generate; -- UX
      end generate; -- UY
    end generate; -- UZ

end absolute_addressing;
