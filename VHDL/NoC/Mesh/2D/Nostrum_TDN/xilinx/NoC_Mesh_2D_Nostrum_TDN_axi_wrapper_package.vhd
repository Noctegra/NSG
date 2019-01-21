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
use work.noc_configuration_package.all;
use work.NoC_Mesh_2D_Nostrum_TDN_package.all;
package NoC_Mesh_2D_Nostrum_TDN_axi_wrapper_package is

   constant NoC_Size:integer:=Nr_of_Cols*Nr_of_Rows*Nr_of_Layers;
   type inpacket_vector is array(integer range <>) of inpacket;
   type outpacket_vector is array(integer range <>) of outpacket;

   -- The max 32 recv channel solution makes ctrl registers too large compared to send and recv buffer,
   -- which makes the max_address_size calculation incorrect. Workaround, set max_address_size to fixed value (15 bits => 32 kByte address span)
   -- 16 bits (64 kByte) would be prefereable, but that does not comply to NoC rni base address at 0x020000
   constant max_address_size:integer:=15; -- max_size_of_nr_of_recv_channels+flit_id_size; -- workaround, Quartus cannot handle generic vector constants
   subtype axi_address_type is std_logic_vector(16 downto 0); -- 128 kByte address space

   subtype axi_bus_type is std_logic_vector(31 downto 0);
   subtype axi_byteenable_type is std_logic_vector(3 downto 0);

   subtype axi_onebit_vector  is std_logic_vector(NoC_Size-1 downto 0);
   type axi_twobit_vector     is array(NoC_Size-1 downto 0) of std_logic_vector(1 downto 0);
   type axi_threebit_vector   is array(NoC_Size-1 downto 0) of std_logic_vector(2 downto 0);
   type axi_bus_vector        is array(NoC_Size-1 downto 0) of std_logic_vector(31 downto 0);
   type axi_address_vector    is array(NoC_Size-1 downto 0) of axi_address_type;
   type axi_byteenable_vector is array(NoC_Size-1 downto 0) of std_logic_vector(3 downto 0);
   subtype axi_signal_vector  is std_logic_vector(NoC_Size-1 downto 0);

   type dap_bus_vector is array(NoC_Size-1 downto 0) of std_logic_vector(63 downto 0);
   type dap_address_vector is array(NoC_Size-1 downto 0) of std_logic_vector(13 downto 0);
   type dap_byteenable_vector is array(NoC_Size-1 downto 0) of std_logic_vector(7 downto 0);
   subtype dap_signal_vector is std_logic_vector(NoC_Size-1 downto 0);

end NoC_Mesh_2D_Nostrum_TDN_axi_wrapper_package;

