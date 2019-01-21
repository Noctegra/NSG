-------------------------------------------------------------------------------------------------------------------------
-- Copyright (c) 2006-present Johnny �berg, KTH Royal Institute of Technology, Sweden. 
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
-- THIS SOFTWARE IS PROVIDED BY THE AUTHOR �AS IS� AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
-- THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
-- AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
-- LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
-- HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
-- OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
-------------------------------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use work.NoC_Mesh_3D_Nostrum_package.all;
entity NoC_Mesh_3D_Nostrum_Switch_xmitter is
   port(clk,reset:IN std_logic;
	  load_enable:std_logic;
	  D:IN NoC_Packet;
	  Q:OUT NoC_Packet);
end NoC_Mesh_3D_Nostrum_Switch_xmitter;

architecture behave of Noc_Mesh_3D_Nostrum_Switch_xmitter is
   signal mem:NoC_Packet;
begin
   process(clk)
   begin
      if (clk'event and (clk='1')) then
	   if (reset='1') then
		mem<=(others=>'0');
	   else
		if (load_enable='1') then
		   mem<=D;
		end if;
	   end if;
      end if;
   end process;

   Q<=mem;
   
end behave;