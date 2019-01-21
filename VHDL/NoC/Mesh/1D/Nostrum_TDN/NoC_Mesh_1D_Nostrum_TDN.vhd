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
use work.noc_configuration_package.all;
use work.NoC_Mesh_1D_Nostrum_TDN_package.all;
entity NoC_Mesh_1D_Nostrum_TDN is
   port(clk,reset:IN std_logic;
	  To_NoC:IN NoC_Packet_cube;
	  To_Res:OUT NoC_Packet_cube;
	  Switch_cycle:OUT Switch_cycle_cube;
	  read_R:OUT std_logic_cube;
	  write_R:OUT std_logic_cube);
end NoC_Mesh_1D_Nostrum_TDN;

architecture absolute_addressing of NoC_Mesh_1D_Nostrum_TDN is

   component NoC_Mesh_3D_Nostrum_TDN_Switch is
      generic(Col:ColumnAddressType;   -- x position
              Row:RowAddressType;	-- y position
	        Layer:LayerAddressType;  -- z position
	        inbuffer:buffer_type);
      port(clk,reset:IN std_logic;
	     Inport:IN Noc_port; 			-- Array of NoC packets, port 0=N, 1=S, 2=E, 3=W, 4=U, 5=D, 6=R, 7=Empty
	     Outport:OUT NoC_port;			-- Z-direction has lowest priority since it has the slowest links on DE3 boards
             Switch_cycle:OUT std_logic_vector(1 downto 0);
	     read_R:OUT std_logic;
	     write_R:OUT std_logic);
   end component;

   signal interconnect_in,interconnect_out:NoC_port_cube;

begin

   -- (x,y,z)=(0,0,0) is the lowest southwest corner, i.e, (x,y,z) is counted as (West->East)(South->North)(Down->Up)
   UZ:for z in 0 to 0 generate
     UY:for y in 0 to 0 generate
       UX:for x in 0 to Nr_of_Cols-1 generate
		UD:NoC_Mesh_3D_Nostrum_TDN_Switch
			generic map(Col=>x,
					Row=>y,
					Layer=>z,
					inbuffer=>withinbuffer)
			port map(clk=>clk,
				   reset=>reset,
				   Inport=>interconnect_in(z*Nr_of_Rows*Nr_of_Cols+y*Nr_of_Cols+x),
				   Outport=>interconnect_out(z*Nr_of_Rows*Nr_of_Cols+y*Nr_of_Cols+x),
				   Switch_cycle=>Switch_cycle(z*Nr_of_Rows*Nr_of_Cols+y*Nr_of_Cols+x),
				   read_R=>read_R(z*Nr_of_Rows*Nr_of_Cols+y*Nr_of_Cols+x),
				   write_R=>write_R(z*Nr_of_Rows*Nr_of_Cols+y*Nr_of_Cols+x));
		ZU:interconnect_in(z*Nr_of_Rows*Nr_of_Cols+y*Nr_of_Cols+x)(Up)<=Void_packet;  -- No packets can come from z-direction
		ZD:interconnect_in(z*Nr_of_Rows*Nr_of_Cols+y*Nr_of_Cols+x)(Down)<=Void_packet;
		YS:interconnect_in(z*Nr_of_Rows*Nr_of_Cols+y*Nr_of_Cols+x)(South)<=Void_packet; -- No packets can come from South
		YN:interconnect_in(z*Nr_of_Rows*Nr_of_Cols+y*Nr_of_Cols+x)(North)<=Void_packet; -- No packets can come from North
		X0:if (x=0) generate
		      interconnect_in(z*Nr_of_Rows*Nr_of_Cols+y*Nr_of_Cols+x)(West)<=Void_packet; -- No packets can come from West
           end generate; -- X0
		XX:if (x>0) generate
		      interconnect_in(z*Nr_of_Rows*Nr_of_Cols+y*Nr_of_Cols+(x-1))(East)<=interconnect_out(z*Nr_of_Rows*Nr_of_Cols+y*Nr_of_Cols+x)(West);
		      interconnect_in(z*Nr_of_Rows*Nr_of_Cols+y*Nr_of_Cols+x)(West)<=interconnect_out(z*Nr_of_Rows*Nr_of_Cols+y*Nr_of_Cols+(x-1))(East);
           end generate; -- XX
		XN:if (x=Nr_of_Cols-1) generate
		      interconnect_in(z*Nr_of_Rows*Nr_of_Cols+y*Nr_of_Cols+x)(East)<=Void_packet; -- No packets can come from East
            end generate; -- XN
		R_in:interconnect_in(z*Nr_of_Rows*Nr_of_Cols+y*Nr_of_Cols+x)(Resource)<=To_NoC(z*Nr_of_Rows*Nr_of_Cols+y*Nr_of_Cols+x);
		R_out:To_Res(z*Nr_of_Rows*Nr_of_Cols+y*Nr_of_Cols+x)<=interconnect_out(z*Nr_of_Rows*Nr_of_Cols+y*Nr_of_Cols+x)(Resource);
       end generate; -- UX
     end generate; -- UY
   end generate; -- UZ

end absolute_addressing;
