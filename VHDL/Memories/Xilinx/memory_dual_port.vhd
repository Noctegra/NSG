------------------------------------------------------------------------------
--
-- Dual Port Memory for NSG - Xilinx Flavor
--
-- Author:      Kalle Ngo (Original Author Johnny Oberg)
-- Date:        July 21st, 2017
-- Changes:     Modified by Kalle to use XPM template to create ram_32b
--              for Vivado 2017.1+ compatability
--
------------------------------------------------------------------------------

library IEEE;
Library xpm;

use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use xpm.vcomponents.all;

entity rams_32b is
   generic(width:integer);
   port(clka : in std_logic;
        clkb : in std_logic;
        -- ena : in std_logic; 
        -- enb : in std_logic;
        wea : in std_logic_vector(3 downto 0);
        web : in std_logic_vector(3 downto 0);
        addra : in std_logic_vector(width-1 downto 0);
        addrb : in std_logic_vector(width-1 downto 0);
        dia : in std_logic_vector(31 downto 0);
        dib : in std_logic_vector(31 downto 0);
        doa : out std_logic_vector(31 downto 0);
        dob : out std_logic_vector(31 downto 0));
end rams_32b;

architecture syn of rams_32b is

begin
xpm_memory_tdpram_inst : xpm_memory_tdpram
  generic map (

    -- Common module generics
    MEMORY_SIZE        => 32*(2**width),        --positive integer
    MEMORY_PRIMITIVE   => "auto",      --string; "auto", "distributed", "block" or "ultra" ;
    CLOCKING_MODE      => "common_clock",--string; "common_clock", "independent_clock" 
    MEMORY_INIT_FILE   => "none",      --string; "none" or "<filename>.mem" 
    MEMORY_INIT_PARAM  => "",          --string;
    USE_MEM_INIT       => 0,           --integer; 0,1
    WAKEUP_TIME        => "disable_sleep",--string; "disable_sleep" or "use_sleep_pin" 
    MESSAGE_CONTROL    => 0,           --integer;
    ECC_MODE           => "no_ecc",    --string; "no_ecc", "encode_only", "decode_only" or "both_encode_and_decode" 
    AUTO_SLEEP_TIME    => 0,           --Do not Change

    -- Port A module generics
    WRITE_DATA_WIDTH_A => 32,          --positive integer
    READ_DATA_WIDTH_A  => 32,          --positive integer
    BYTE_WRITE_WIDTH_A => 8,           --integer; 8, 9, or WRITE_DATA_WIDTH_A value
    ADDR_WIDTH_A       => width,           --positive integer
    READ_RESET_VALUE_A => "0",         --string
    READ_LATENCY_A     => 2,           --non-negative integer
    WRITE_MODE_A       => "no_change", --string; "write_first", "read_first", "no_change" 

    -- Port B module generics
    WRITE_DATA_WIDTH_B => 32,          --positive integer
    READ_DATA_WIDTH_B  => 32,          --positive integer
    BYTE_WRITE_WIDTH_B => 8,           --integer; 8, 9, or WRITE_DATA_WIDTH_B value
    ADDR_WIDTH_B       => width,       --positive integer
    READ_RESET_VALUE_B => "0",         --string
    READ_LATENCY_B     => 2,           --non-negative integer
    WRITE_MODE_B       => "no_change"  --string; "write_first", "read_first", "no_change" 
  )
  port map (

    -- Common module ports
    sleep          => '0',

    -- Port A module ports
    clka           => clka,
    rsta           => '0',
    ena            => '1',
    regcea         => '1',
    wea            => wea,
    addra          => addra,
    dina           => dia,
    injectsbiterra => '0',
    injectdbiterra => '0',
    douta          => doa,
    sbiterra       => open,
    dbiterra       => open,

    -- Port B module ports
    clkb           => clkb,
    rstb           => '0',
    enb            => '1',
    regceb         => '1',
    web            => web,
    addrb          => addrb,
    dinb           => dib,
    injectsbiterrb => '0',
    injectdbiterrb => '0',
    doutb          => dob,
    sbiterrb       => open,
    dbiterrb       => open
  );
-- End of xpm_memory_tdpram_inst instance declaration


end architecture;


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
entity memory_dual_port is 
        generic (
		   width_data_a : NATURAL :=64;
        	   width_data_b : NATURAL:=32;
        	   width_byteena_a : NATURAL:=8;
        	   width_byteena_b : NATURAL:=4;
        	   width_address_a : NATURAL:=13;
        	   width_address_b : NATURAL:=14
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
begin
   assert ((width_data_a*(2**width_address_a))=(width_data_b*(2**width_address_b)))
      report "Dual port memory must have exactly the same number of bits seen from port A and port B"
      severity failure;
end memory_dual_port;

architecture structure of memory_dual_port is
   component rams_32b
      generic(width:integer);
      port(clka : in std_logic;
           clkb : in std_logic;
           --ena : in std_logic_vector(3 downto 0);
           --enb : in std_logic_vector(3 downto 0);
           --wea : in std_logic;
           --web : in std_logic;
           wea : in std_logic_vector(3 downto 0);
           web : in std_logic_vector(3 downto 0);
           addra : in std_logic_vector(width-1 downto 0);
           addrb : in std_logic_vector(width-1 downto 0);
           dia : in std_logic_vector(31 downto 0);
           dib : in std_logic_vector(31 downto 0);
           doa : out std_logic_vector(31 downto 0);
           dob : out std_logic_vector(31 downto 0));
   end component;


   type c_type is record
     wa:integer;
     wd:integer;
   end record;

   function min(L,R:integer) return integer is
   begin
      if (L<R) then return L; end if;
      return R;
   end min;

   function max(L,R:integer) return integer is
   begin
      if (L>R) then return L; end if;
      return R;
   end max;

   function max(L,R:c_type) return c_type is
   begin
      if (L.wa>R.wa) then return L; end if;
      return R;
   end max;

   function min(L,R:c_type) return c_type is
   begin
      if (L.wa<R.wa) then return L; end if;
      return R;
   end min;

   function log2(a:integer) return integer is
   begin
      for i in 0 to 30 loop
	if (a<=2**i) then return i; end if;
      end loop;
      return 31;
   end log2;

   subtype diff_type is integer range 0 to 15;
   constant lsw_a:integer:=log2(width_data_a); -- 6 = log2(64) = 2^6
   constant lsw_b:integer:=log2(width_data_b); -- 5 = log2(32) = 2^6

   constant c_a:c_type:=(width_address_a,width_data_a);
   constant c_b:c_type:=(width_address_b,width_data_b);
   constant c_max:c_type:=max(c_a,c_b); -- max address, min data
   constant c_min:c_type:=min(c_a,c_b); -- min address, max data
   constant min_addr_width:integer:=min(c_a.wa,c_b.wa);
   constant max_addr_width:integer:=c_max.wa;
   constant max_data_width:integer:=max(c_a.wd,c_b.wd);
   constant lsw_max:diff_type:=log2(c_max.wd);
   constant diff_max:diff_type:=7-lsw_max;
   -- port A
   signal internal_address_a:std_logic_vector(min_addr_width-1 downto 0);
   signal internal_writedata_a:std_logic_vector(max_data_width-1 downto 0);
   signal internal_readdata_a:std_logic_vector(max_data_width-1 downto 0);
   signal internal_byteenable_a:std_logic_vector(max_data_width/8-1 downto 0);
   signal wren_a,internal_read_a,delayed_read_a:std_logic;
   signal internal_addra_a,delayed_addra_a:diff_type;
   -- port B
   signal internal_address_b:std_logic_vector(min_addr_width-1 downto 0);
   signal internal_writedata_b:std_logic_vector(max_data_width-1 downto 0);
   signal internal_readdata_b:std_logic_vector(max_data_width-1 downto 0);
   signal internal_byteenable_b:std_logic_vector(max_data_width/8-1 downto 0);
   signal wren_b,internal_read_b,delayed_read_b:std_logic;
   signal internal_addra_b,delayed_addra_b:diff_type;

   constant diff_port_a:diff_type:=log2(max_data_width)-lsw_a; -- 6-6 = 0
   constant diff_port_b:diff_type:=log2(max_data_width)-lsw_b; -- 6-5 = 1
   constant ram_size:integer:=width_data_a*(2**width_address_a);

begin
  -- Make a max_data_width bit wide memory...
  --G0:if (ram_size>1024) generate
  RAM:for i in 0 to (max_data_width/32)-1 generate
     U:rams_32b
         generic map (
            WIDTH => (min_addr_width)
         )
         port map (
            clkA => clk,
            clkB => clk,
            -- enA => internal_byteenable_a((i+1)*4-1 downto i*4),
            -- enB => internal_byteenable_b((i+1)*4-1 downto i*4),
            -- weA => wren_a((i+1)*4-1 downto i*4),
            -- weB => wren_b((i+1)*4-1 downto i*4),
            weA => internal_byteenable_a((i+1)*4-1 downto i*4),
            weB => internal_byteenable_b((i+1)*4-1 downto i*4),
            addrA => internal_address_a,
            addrB => internal_address_b,
            diA => internal_writedata_a((i+1)*32-1 downto i*32),
            diB => internal_writedata_b((i+1)*32-1 downto i*32),
            doA => internal_readdata_a((i+1)*32-1 downto i*32),
            doB => internal_readdata_b((i+1)*32-1 downto i*32)
         );
   end generate;

   -- portA
   process(address_a,byteenable_a,writedata_a,wren_a)
      variable addr:diff_type;
      constant en_size:integer:=byteenable_a'length;
   begin
      -- pick out the high bits...
      internal_address_a<=address_a(width_address_a-1 downto diff_port_a);
      internal_byteenable_a<=(others=>'0');
      case diff_port_a is
         when 0 => -- width_data_a equals width_data_b
	    if (wren_a='1') then
               internal_byteenable_a<=byteenable_a;
	    end if;
            internal_writedata_a<=writedata_a;
	    internal_addra_a<=0;
	 when others => -- width_data_a is smaller than max_data_width
	    addr:=conv_integer(address_a(diff_port_a-1 downto 0));
	    for i in 0 to 2**diff_port_a-1 loop
	       if (i=addr) then
		  if (wren_a='1') then
		     internal_byteenable_a((i+1)*en_size-1 downto i*en_size)<=byteenable_a;
		  end if;
	       end if;
               internal_writedata_a((i+1)*width_data_a-1 downto i*width_data_a)<=writedata_a;
	    end loop;
	    internal_addra_a<=addr;
      end case;
   end process;
   wren_a<=write_a AND chipselect_a;
   internal_read_a<=not(write_a) AND chipselect_a;
   process(clk)
   begin
      if rising_edge(clk) then
         delayed_read_a<=internal_read_a;
         delayed_addra_a<=internal_addra_a;
      end if;
   end process;

   -- ok, let's ignore byteneable on reads for simplicity's sake...
   process(internal_readdata_a,delayed_read_a,delayed_addra_a)
   begin
      readdata_a<=(others=>'Z');
      if (delayed_read_a='1') then
	 case diff_port_a is
	    when 0 =>
	       readdata_a<=internal_readdata_a;
	    when others =>
	       for i in 0 to 2**diff_port_a-1 loop
		  if (i=delayed_addra_a) then
		     readdata_a<=internal_readdata_a((i+1)*width_data_a-1 downto i*width_data_a);
		  end if;
	       end loop;
	 end case;
      end if;
   end process;

   -- portB
   process(address_b,byteenable_b,writedata_b,wren_b)
      variable addr:diff_type;
      constant en_size:integer:=byteenable_b'length;
   begin
      -- pick out the high bits...
      internal_address_b<=address_b(width_address_b-1 downto diff_port_b);
      internal_byteenable_b<=(others=>'0');
      case diff_port_b is
         when 0 => -- width_data_b is equal to max_data_width
	    if (wren_b='1') then
               internal_byteenable_b<=byteenable_b;
	    end if;
            internal_writedata_b<=writedata_b;
	    internal_addra_b<=0;
	 when others => -- width_data_b is less than max_data_width
	    addr:=conv_integer(address_b(diff_port_b-1 downto 0));
	    for i in 0 to 2**diff_port_b-1 loop
	       if (i=addr) then
			  if (wren_b='1') then
				 internal_byteenable_b((i+1)*en_size-1 downto i*en_size)<=byteenable_b;
			  end if;
	       end if;
               internal_writedata_b((i+1)*width_data_b-1 downto i*width_data_b)<=writedata_b;
	    end loop;
	    internal_addra_b<=addr;
      end case;
   end process;
   wren_b<=write_b AND chipselect_b;
   internal_read_b<=not(write_b) AND chipselect_b;
   process(clk)
   begin
      if rising_edge(clk) then
         delayed_addra_b<=internal_addra_b;
	 delayed_read_b<=internal_read_b;
      end if;
   end process;

   -- ok, let's ignore byteneable on reads for simplicity's sake...
   process(internal_readdata_b,delayed_read_b,delayed_addra_b)
   begin
      readdata_b<=(others=>'Z');
      if (delayed_read_b='1') then
	 case diff_port_b is
	    when 0 =>
	       readdata_b<=internal_readdata_b;
	    when others =>
	       for i in 0 to 2**diff_port_b-1 loop
		  if (i=delayed_addra_b) then
		     readdata_b<=internal_readdata_b((i+1)*width_data_b-1 downto i*width_data_b);
		  end if;
	       end loop;
	 end case;
      end if;
   end process;
end structure;

