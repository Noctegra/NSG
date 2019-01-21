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
use ieee.std_logic_unsigned.all;
use work.noc_configuration_package.all;
use work.NoC_Mesh_1D_Nostrum_TDN_package.all;

entity kth_axi_Nostrum_TDN_rni is
  generic
  (
    -- Users to add parameters here
    rni_number : integer := 0
    -- use_64bit : integer := 0
  );
  port
  (
     -- Users to add ports here
     -- NoC Switch Ports
	TO_NOC:out NoC_packet; -- In for switch is out for rni
	FROM_NOC:in NoC_packet; -- Out for switch is in for rni
	Switch_cycle:in std_logic_vector(1 downto 0);
	read_R:IN std_logic;
	write_R:IN std_logic;
	HeartBeat:INOUT std_logic;
	NoC_Irq:OUT std_logic;
	dap_address:IN std_logic_Vector(13 downto 0);
	dap_writedata:IN std_logic_vector(63 downto 0);
	dap_readdata:OUT std_logic_vector(63 downto 0);
	dap_read:IN std_logic;
	dap_write:IN std_logic;
	dap_byteenable:IN std_logic_vector(7 downto 0);

	-- User ports ends
	-- Do not modify the ports beyond this line

	-- Global Clock Signal
	S_AXI_ACLK	: in std_logic;
	-- Global Reset Signal. This Signal is Active LOW
	S_AXI_ARESETN	: in std_logic;
	-- Write address (issued by master, acceped by Slave)
	S_AXI_AWADDR	: in std_logic_vector(16 downto 0); -- (C_S_AXI_ADDR_WIDTH-1 downto 0);
	-- Write channel Protection type. This signal indicates the
	-- privilege and security level of the transaction, and whether
   	-- the transaction is a data access or an instruction access.
	S_AXI_AWPROT	: in std_logic_vector(2 downto 0);
	-- Write address valid. This signal indicates that the master signaling
   	-- valid write address and control information.
	S_AXI_AWVALID	: in std_logic;
	-- Write address ready. This signal indicates that the slave is ready
   	-- to accept an address and associated control signals.
	S_AXI_AWREADY	: out std_logic;
	-- Write data (issued by master, acceped by Slave) 
	S_AXI_WDATA	: in std_logic_vector(31 downto 0); -- (C_S_AXI_DATA_WIDTH-1 downto 0);
	-- Write strobes. This signal indicates which byte lanes hold
   	-- valid data. There is one write strobe bit for each eight
   	-- bits of the write data bus.    
	S_AXI_WSTRB	: in std_logic_vector(3 downto 0); -- ((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
	-- Write valid. This signal indicates that valid write
   	-- data and strobes are available.
	S_AXI_WVALID	: in std_logic;
	-- Write ready. This signal indicates that the slave
   	-- can accept the write data.
	S_AXI_WREADY	: out std_logic;
	-- Write response. This signal indicates the status
   	-- of the write transaction.
	S_AXI_BRESP	: out std_logic_vector(1 downto 0);
	-- Write response valid. This signal indicates that the channel
   	-- is signaling a valid write response.
	S_AXI_BVALID	: out std_logic;
	-- Response ready. This signal indicates that the master
   		-- can accept a write response.
	S_AXI_BREADY	: in std_logic;
	-- Read address (issued by master, acceped by Slave)
	S_AXI_ARADDR	: in std_logic_vector(16 downto 0); -- (C_S_AXI_ADDR_WIDTH-1 downto 0);
	-- Protection type. This signal indicates the privilege
   	-- and security level of the transaction, and whether the
   	-- transaction is a data access or an instruction access.
	S_AXI_ARPROT	: in std_logic_vector(2 downto 0);
	-- Read address valid. This signal indicates that the channel
   	-- is signaling valid read address and control information.
	S_AXI_ARVALID	: in std_logic;
	-- Read address ready. This signal indicates that the slave is
   	-- ready to accept an address and associated control signals.
	S_AXI_ARREADY	: out std_logic;
	-- Read data (issued by slave)
	S_AXI_RDATA	: out std_logic_vector(31 downto 0); -- (C_S_AXI_DATA_WIDTH-1 downto 0);
	-- Read response. This signal indicates the status of the
   	-- read transfer.
	S_AXI_RRESP	: out std_logic_vector(1 downto 0);
	-- Read valid. This signal indicates that the channel is
    	-- signaling the required read data.
	S_AXI_RVALID	: out std_logic;
	-- Read ready. This signal indicates that the master can
   	-- accept the read data and response information.
	S_AXI_RREADY	: in std_logic
 );
end entity kth_axi_Nostrum_TDN_rni;

------------------------------------------------------------------------------
-- Architecture section
------------------------------------------------------------------------------

architecture arch_imp of kth_axi_Nostrum_TDN_rni is

   component kth_Nostrum_TDN_rni
      generic
	(
	    rni_pos : integer := 0
        --    use_64bit : integer := 0
	);
      port(
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
   END COMPONENT;

   -- constant C_S_AXI_DATA_WIDTH:integer:=32;

   -- AXI4LITE signals
   signal axi_awaddr	: std_logic_vector(16 downto 0);
   signal axi_awready	: std_logic;
   signal axi_wready	: std_logic;
   signal axi_bresp	: std_logic_vector(1 downto 0);
   signal axi_bvalid	: std_logic;
   signal axi_araddr	: std_logic_vector(16 downto 0);
   signal axi_arready	: std_logic;
   signal axi_rdata	: std_logic_vector(31 downto 0); -- (C_S_AXI_DATA_WIDTH-1 downto 0);
   signal axi_wdata	: std_logic_vector(31 downto 0); -- (C_S_AXI_DATA_WIDTH-1 downto 0);
   signal axi_rresp	: std_logic_vector(1 downto 0);
   signal axi_rvalid	: std_logic;

   -- Example-specific design signals
   -- local parameter for addressing 32 bit / 64 bit C_S_AXI_DATA_WIDTH
   -- ADDR_LSB is used for addressing 32/64 bit registers/memories
   -- ADDR_LSB = 2 for 32 bits (n downto 2)
   -- ADDR_LSB = 3 for 64 bits (n downto 3)
   -- constant ADDR_LSB  : integer := (C_S_AXI_DATA_WIDTH/32)+ 1;
   -- constant OPT_MEM_ADDR_BITS : integer := 15;
   ------------------------------------------------
   ---- Signals for user logic register space example
   --------------------------------------------------
   signal slv_reg_rden  :std_logic;
   signal slv_reg_wren  :std_logic;
   signal slave_chipselect:std_logic;
   signal slave_address   :std_logic_vector(14 downto 0); -- (C_S_AXI_ADDR_WIDTH-1 downto 0);
   signal slave_byteenable:std_logic_vector(3 downto 0); -- ((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
   signal slave_clk	  :std_logic;
   signal slave_reset	  :std_logic;
   signal slave_readdata  :std_logic_vector(31 downto 0);

--   signal inport : outpacket;
--   signal outport : inpacket;

begin

   -- Mapping AXI to slave primitives
   slave_address    <= S_AXI_AWADDR(16 downto 2) when slv_reg_wren='1' else S_AXI_ARADDR(16 downto 2);
   slave_byteenable <= S_AXI_WSTRB;
   slave_chipselect <= slv_reg_rden OR slv_reg_wren;
   slave_clk        <= S_AXI_ACLK;
   slave_reset      <= not(S_AXI_ARESETN);
 
   -- I/O Connections assignments

   S_AXI_AWREADY<= axi_awready;
   S_AXI_WREADY	<= axi_wready;
   S_AXI_BRESP	<= axi_bresp;  -- this signal is always 00 after reset... why bother to reset it???
   S_AXI_BVALID	<= axi_bvalid;
   S_AXI_ARREADY<= axi_arready;
   S_AXI_RDATA	<= axi_rdata;
   axi_wdata	<= S_AXI_WDATA;
   S_AXI_RRESP	<= axi_rresp;  -- this signal is always 00 after reset... why bother to reset it???
   S_AXI_RVALID	<= axi_rvalid;

   -- Implement axi_awready generation
   -- axi_awready is asserted for one S_AXI_ACLK clock cycle when both
   -- S_AXI_AWVALID and S_AXI_WVALID are asserted. axi_awready is
   -- de-asserted when reset is low.

   process (S_AXI_ACLK)
   begin
      if rising_edge(S_AXI_ACLK) then 
         if S_AXI_ARESETN = '0' then
            axi_awready <= '0';
         else
            if (axi_awready = '0' and S_AXI_AWVALID = '1' and S_AXI_WVALID = '1') then
               -- slave is ready to accept write address when
               -- there is a valid write address and write data
               -- on the write address and data bus. This design 
               -- expects no outstanding transactions. 
               axi_awready <= '1';
            else
               axi_awready <= '0';
            end if;
         end if;
      end if;
   end process;

   -- Implement axi_awaddr latching
   -- This process is used to latch the address when both 
   -- S_AXI_AWVALID and S_AXI_WVALID are valid. 

   process (S_AXI_ACLK)
   begin
      if rising_edge(S_AXI_ACLK) then 
         if S_AXI_ARESETN = '0' then
            axi_awaddr <= (others => '0');
         else
            if (axi_awready = '0' and S_AXI_AWVALID = '1' and S_AXI_WVALID = '1') then
               -- Write Address latching
               axi_awaddr <= S_AXI_AWADDR;
            end if;
         end if;
      end if;                   
   end process; 

   -- Implement axi_wready generation
   -- axi_wready is asserted for one S_AXI_ACLK clock cycle when both
   -- S_AXI_AWVALID and S_AXI_WVALID are asserted. axi_wready is 
   -- de-asserted when reset is low. 

   process (S_AXI_ACLK)
   begin
      if rising_edge(S_AXI_ACLK) then 
         if S_AXI_ARESETN = '0' then
            axi_wready <= '0';
         else
            if (axi_wready = '0' and S_AXI_WVALID = '1' and S_AXI_AWVALID = '1') then
               -- slave is ready to accept write data when 
               -- there is a valid write address and write data
               -- on the write address and data bus. This design 
               -- expects no outstanding transactions.           
               axi_wready <= '1';
            else
              axi_wready <= '0';
            end if;
         end if;
      end if;
   end process; 

   -- Implement memory mapped register select and write logic generation
   -- The write data is accepted and written to memory mapped registers when
   -- axi_awready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted. Write strobes are used to
   -- select byte enables of slave registers while writing.
   -- These registers are cleared when reset (active low) is applied.
   -- Slave register write enable is asserted when valid address and data are available
   -- and the slave is ready to accept the write address and write data.

   slv_reg_wren <= axi_wready and S_AXI_WVALID and axi_awready and S_AXI_AWVALID ;


   -- Implement write response logic generation
   -- The write response and response valid signals are asserted by the slave 
   -- when axi_wready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted.  
   -- This marks the acceptance of address and indicates the status of 
   -- write transaction.

   process (S_AXI_ACLK)
   begin
      if rising_edge(S_AXI_ACLK) then 
         if S_AXI_ARESETN = '0' then
       	    axi_bvalid  <= '0';
            axi_bresp   <= "00"; --need to work more on the responses
	 else
            if (axi_awready = '1' and S_AXI_AWVALID = '1' and axi_wready = '1' and S_AXI_WVALID = '1' and axi_bvalid = '0'  ) then
               axi_bvalid <= '1';
               axi_bresp  <= "00"; 
            elsif (S_AXI_BREADY = '1' and axi_bvalid = '1') then   --check if bready is asserted while bvalid is high)
               axi_bvalid <= '0';                                 -- (there is a possibility that bready is always asserted high)
            end if;
         end if;
      end if;                   
   end process; 

   -- Implement axi_arready generation
   -- axi_arready is asserted for one S_AXI_ACLK clock cycle when
   -- S_AXI_ARVALID is asserted. axi_awready is 
   -- de-asserted when reset (active low) is asserted. 
   -- The read address is also latched when S_AXI_ARVALID is 
   -- asserted. axi_araddr is reset to zero on reset assertion.

   process (S_AXI_ACLK)
   begin
      if rising_edge(S_AXI_ACLK) then 
         if S_AXI_ARESETN = '0' then
            axi_arready <= '0';
            axi_araddr  <= (others => '1');
         else
            if (axi_arready = '0' and S_AXI_ARVALID = '1') then
               -- indicates that the slave has acceped the valid read address
               axi_arready <= '1';
               -- Read Address latching 
               axi_araddr  <= S_AXI_ARADDR;           
            else
               axi_arready <= '0';
            end if;
         end if;
      end if;           
   end process; 

   -- Implement axi_arvalid generation
   -- axi_rvalid is asserted for one S_AXI_ACLK clock cycle when both 
   -- S_AXI_ARVALID and axi_arready are asserted. The slave registers 
   -- data are available on the axi_rdata bus at this instance. The 
   -- assertion of axi_rvalid marks the validity of read data on the 
   -- bus and axi_rresp indicates the status of read transaction.axi_rvalid 
   -- is deasserted on reset (active low). axi_rresp and axi_rdata are 
   -- cleared to zero on reset (active low).  
   process (S_AXI_ACLK)
   begin
      if rising_edge(S_AXI_ACLK) then
         if S_AXI_ARESETN = '0' then
            axi_rvalid <= '0';
            axi_rresp  <= "00";
	    -- axi_rdata <= (others=>'0');
         else
            if (axi_arready = '1' and S_AXI_ARVALID = '1' and axi_rvalid = '0') then
               -- Valid read data is available at the read data bus
               axi_rvalid <= '1';
               axi_rresp  <= "00"; -- 'OKAY' response
            elsif (axi_rvalid = '1' and S_AXI_RREADY = '1') then
               -- Read data is accepted by the master
               axi_rvalid <= '0';
            end if;            
         end if;
      end if;
   end process;
   axi_rdata<=slave_readdata; -- forward data immediately to match rvalid...

   -- Implement memory mapped register select and read logic generation
   -- Slave register read enable is asserted when valid address is available
   -- and the slave is ready to accept the read address.

   slv_reg_rden <= axi_arready and S_AXI_ARVALID and (not axi_rvalid) ;


  -- Add user logic here
  USER_LOGIC : kth_Nostrum_TDN_rni
    generic map
    (
      -- MAP USER GENERICS BELOW THIS LINE ---------------
      --USER generics mapped here
	rni_pos	=> rni_number
	-- use_64bit => use_64bit
      -- MAP USER GENERICS ABOVE THIS LINE ---------------

    )
    port map
    (
      -- MAP USER PORTS BELOW THIS LINE ------------------
      --USER ports mapped here
      -- NoC Switch Ports
      TO_NOC => TO_NOC,
      FROM_NOC => FROM_NOC,
      Switch_cycle => Switch_cycle,
      Read_R => Read_R,
      Write_R => Write_R,
      HeartBeat		=> HeartBeat,
      slave_irq		=> NoC_Irq,
      -- Direct Access Port
      dap_address 	=> dap_address,
      dap_readdata 	=> dap_readdata,
      dap_writedata 	=> dap_writedata,
      dap_read 		=> dap_read,
      dap_write 	=> dap_write,
      dap_byteenable 	=> dap_byteenable,
      -- MAP USER PORTS ABOVE THIS LINE ------------------

      slave_clk           => slave_clk,
      slave_reset         => slave_reset,
      slave_address       => slave_address,
      slave_chipselect    => slave_chipselect,
      slave_writedata     => axi_wdata,
      slave_byteenable    => slave_byteenable,
      slave_read          => slv_reg_rden,
      slave_write         => slv_reg_wren,
      slave_readdata      => slave_readdata
    );

	-- User logic ends


end arch_imp;
