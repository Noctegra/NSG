--Legal Notice: (C)2006 Altera Corporation. All rights reserved.  Your
--use of Altera Corporation's design tools, logic functions and other
--software and tools, and its AMPP partner logic functions, and any
--output files any of the foregoing (including device programming or
--simulation files), and any associated documentation or information are
--expressly subject to the terms and conditions of the Altera Program
--License Subscription Agreement or other applicable license agreement,
--including, without limitation, that your use is for the sole purpose
--of programming logic devices manufactured by Altera and sold by Altera
--or its authorized distributors.  Please refer to the applicable
--agreement for further details.


-- turn off superfluous VHDL processor warnings 
-- altera message_level Level1 
-- altera message_off 10034 10035 10036 10037 10230 10240 10030 

library altera;
--use altera.altera_europa_support_lib.all;

library altera_mf;
use altera_mf.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library lpm;
use lpm.all;

entity memory is 
	  generic (width:integer);
        port (
              -- inputs:
                 signal address1 : IN STD_LOGIC_VECTOR (width-1 DOWNTO 0);
                 signal address2 : IN STD_LOGIC_VECTOR (width-1 DOWNTO 0);
                 signal byteenable1 : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal byteenable2 : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal chipselect1 : IN STD_LOGIC;
                 signal chipselect2 : IN STD_LOGIC;
                 signal clk : IN STD_LOGIC;
                 signal clken1 : IN STD_LOGIC;
                 signal clken2 : IN STD_LOGIC;
                 signal write1 : IN STD_LOGIC;
                 signal write2 : IN STD_LOGIC;
                 signal writedata1 : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal writedata2 : IN STD_LOGIC_VECTOR (31 DOWNTO 0);

              -- outputs:
                 signal readdata1 : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal readdata2 : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
              );
end entity memory;


architecture europa of memory is

-----------------------------------------------
  component altsyncram is
GENERIC (
      address_reg_b : STRING;
        byte_size : NATURAL;
        byteena_reg_b : STRING;
        indata_reg_b : STRING;
        init_file : STRING;
        lpm_type : STRING;
        numwords_a : NATURAL;
        numwords_b : NATURAL;
        operation_mode : STRING;
        outdata_reg_a : STRING;
        outdata_reg_b : STRING;
        ram_block_type : STRING;
        read_during_write_mode_mixed_ports : STRING;
        width_a : NATURAL;
        width_b : NATURAL;
        width_byteena_a : NATURAL;
        width_byteena_b : NATURAL;
        widthad_a : NATURAL;
        widthad_b : NATURAL;
        wrcontrol_wraddress_reg_b : STRING
      );
    PORT (
    signal q_a : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
        signal q_b : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
        signal data_a : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
        signal data_b : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
        signal clocken0 : IN STD_LOGIC;
        signal wren_a : IN STD_LOGIC;
        signal byteena_a : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
        signal clocken1 : IN STD_LOGIC;
        signal wren_b : IN STD_LOGIC;
        signal byteena_b : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
        signal clock0 : IN STD_LOGIC;
        signal clock1 : IN STD_LOGIC;
        signal address_a : IN STD_LOGIC_VECTOR (width-1 DOWNTO 0);
        signal address_b : IN STD_LOGIC_VECTOR (width-1 DOWNTO 0)
      );
  end component altsyncram;
--------------------------------------------------------------------------
                signal internal_readdata1 :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal internal_readdata2 :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal wren1 :  STD_LOGIC;
                signal wren2 :  STD_LOGIC;
--------------------------------------------------
begin

  wren1 <= chipselect1 AND write1;
  wren2 <= chipselect2 AND write2;
  --s1, which is an e_avalon_slave
  --s2, which is an e_avalon_slave
  --vhdl renameroo for output signals
  readdata1 <= internal_readdata1;
  --vhdl renameroo for output signals
  readdata2 <= internal_readdata2;
--------------------------------------------
    the_altsyncram : altsyncram
      generic map(
        address_reg_b => "CLOCK1",
        byte_size => 8,
        byteena_reg_b => "CLOCK1",
        indata_reg_b => "CLOCK1",
        init_file => "UNUSED", -- "../onchip_memory_2.hex",
        lpm_type => "altsyncram",
        numwords_a => 2**width, -- 1024
        numwords_b => 2**width, -- 1024
        operation_mode => "BIDIR_DUAL_PORT",
        outdata_reg_a => "UNREGISTERED",
        outdata_reg_b => "UNREGISTERED",
        ram_block_type => "M9K",
        read_during_write_mode_mixed_ports => "DONT_CARE",
        width_a => 32,
        width_b => 32,
        width_byteena_a => 4,
        width_byteena_b => 4,
        widthad_a => width,
        widthad_b => width,
        wrcontrol_wraddress_reg_b => "CLOCK1"
      )
      port map(
                address_a => address1,
                address_b => address2,
                byteena_a => byteenable1,
                byteena_b => byteenable2,
                clock0 => clk,
                clock1 => clk,
                clocken0 => clken1,
                clocken1 => clken2,
                data_a => writedata1,
                data_b => writedata2,
                q_a => internal_readdata1,
                q_b => internal_readdata2,
                wren_a => wren1,
                wren_b => wren2
      );
 ------------------------------------------------------
end europa;

