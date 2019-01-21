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
package NoC_Mesh_3D_Nostrum_package is
   -- Side types
   subtype side_type is integer range 0 to 7;
   subtype port_ptr is integer range 0 to 7;
   constant North:side_type:=0;
   constant South:side_type:=1;
   constant East:side_type:=2;
   constant West:side_type:=3;
   -- The up and down direction should be chosen last in case of deflection since the Z-direction
   -- has a larger latency
   constant Up:side_type:=4;
   constant Down:side_type:=5;
   constant Resource:side_type:=6;
   constant Empty:side_type:=7;

   constant N:side_type:=North;
   constant S:side_type:=South;
   constant E:side_type:=East;
   constant W:side_type:=West;
   constant U:side_type:=Up;
   constant D:side_type:=Down;
   constant R:side_type:=Resource;

   type port_vector_type is array (natural range <>) of port_ptr;
   subtype port_vector is port_vector_type(0 to R);
   type port_array is array (0 to R) of port_vector;
   -- subtype port_ptr is integer range 0 to Empty; -- In priority order: N=0, S=1, E=2, W=3, U=4, D=5, R=6, Empty (or no connect)=7

   -- 2D planar types used to deflect packets within a layer
   -- Are these useful if we have a buffer on the borders????
   subtype corner_type is integer range 0 to 5;
   constant NWC:corner_type:=0; -- North West Corner
   constant NEC:corner_type:=1; -- North East Corner
   constant SEC:corner_type:=2; -- South East Corner
   constant SWC:corner_type:=3; -- South West Corner
   constant SS:corner_type:=4; -- Side Switch, location given by side_type
   constant CS:corner_type:=5; -- Center switch

   -- Buffer types
   subtype buffer_type is integer range 0 to 1;
   constant noinbuffer:buffer_type:=0;
   constant withinbuffer:buffer_type:=1;
   
   -- Size, type and bit locations of all fields in the packet format are defined here
   constant Type_size:integer:=2; -- Empty=0-, Switch Packet=01, Normal Packet Valid=1-, Setup=11, Data=10
   constant Flit_id_size:integer:=log2(NrOfFlitsperFrame); -- flit number (0-127), needed for reordering of packets on the receiver side
                                     -- The flit id size and the number of channels is always 10 bits (to make the Device Driver simpler).
						 -- Thus, reducing the flit size allows for more channels on the sender side (minimum two). Receiver side
						 -- is dimensioned locally based on the communication needs of the processes (see below).
						 -- This is a preparation for multi-cast transmissions (not supported yet)
   -- constant channel_size:integer:=2;  -- 4 receiver channels per resource
   -- channels are dynamically allocated on the receiver side, i.e., no channel id is needed...
   -- On the other hand, a process ID is needed to identify the receiving channel and receive data properly...
   constant PID_size:integer:=8; -- Max 256 PIDs in a system. The size cannot be larger due to the limited size of the control register which 
                                 -- cannot exceed the word length of the controlling computer. Otherwise, more control registers are needed...
   -- Hop Counter (used to prioritize older packets), the upper two bits (set in the decryption of the control word in the RNI) can be used to 
   -- set a higher base priority to emitted packets
   constant HC_size:integer:=6;
   -- Node Addresses Max 8x8x4 NoC (Absolute addressing)
   constant NS_size:integer:=log2(nr_of_rows);   -- North/South Max 8 Nodes
   constant EW_size:integer:=log2(nr_of_cols);   -- Left/Right Max 8 Nodes
   constant UD_size:integer:=log2(nr_of_layers); -- Up/Down Max 4 Nodes
   constant Header_size:integer:=Type_size+Flit_id_size+2*PID_size+HC_Size+NS_Size+EW_size+UD_size; -- 2+7+7+8+3+3+2= 32
   constant Data_size:integer:=FlitWidth; -- Data field

   subtype NoC_packet is std_logic_vector(Header_size+Data_size-1 downto 0); -- 63:0
   subtype bit_ptr is natural range 0 to NoC_packet'high;

   constant VOID_PACKET:NoC_packet:=(others=>'0');

   ------------------------------------------------------------------------------------------------
   -- constant Nr_of_Cols:integer:=2; -- Must fit in EW_size above
   -- constant Nr_of_Rows:integer:=2; -- Must fit in NS_size above
   -- constant Nr_of_Layers:integer:=1; -- Must fit in UD_size above

   subtype ColumnAddressType is integer range 0 to Nr_Of_Cols-1; -- x
   subtype RowAddressType is integer range 0 to Nr_of_Rows-1; -- y
   subtype LayerAddressType is integer range 0 to Nr_of_Layers-1; -- z
   type NoC_Packet_vector is array (Nr_of_Cols-1 downto 0) of NoC_Packet; -- 3 NoC_Packets in this array
   -- type NoC_Packet_layer is array  (Nr_of_Rows-1 downto 0) of NoC_packet_vector;
   -- type NoC_Packet_cube is array   (Nr_of_Layers-1 downto 0) of NoC_Packet_layer;
   -- Workaround to fix synthesis bug
   type NoC_Packet_layer is array  (Nr_of_Cols*Nr_of_Rows-1 downto 0) of NoC_Packet;
   type NoC_Packet_cube is array   (Nr_of_Cols*Nr_of_Rows*Nr_of_Layers-1 downto 0) of NoC_Packet;

   -- from North to Resource
   type NoC_port is array (0 to Resource) of NoC_Packet;
   type NoC_port_vector is array (Nr_of_Cols-1 downto 0) of NoC_port;
   -- type NoC_port_layer is array  (Nr_of_Rows-1 downto 0) of NoC_port_vector;
   -- type NoC_port_cube is array   (Nr_of_Layers-1 downto 0) of NoC_port_layer;
   -- Workaround to fix synthesis bug
   type NoC_port_layer is array  (Nr_of_Cols*Nr_of_Rows-1 downto 0) of NoC_port;
   type NoC_port_cube is array   (Nr_of_Cols*Nr_of_Rows*Nr_of_Layers-1 downto 0) of NoC_port;

   -- The std_logic equivalent to the NoC ports are used for the Resource R & W signals
   -- type std_logic_matrix is array (Nr_of_Rows-1 downto 0) of std_logic_vector(Nr_of_Cols-1 downto 0);
   -- type std_logic_cube is array (Nr_of_Layers-1 downto 0) of std_logic_matrix;
   -- Workaround to fix synthesis bug
   type std_logic_matrix is array (Nr_of_Cols*Nr_of_Rows-1 downto 0) of std_logic;
   type std_logic_cube is array (Nr_of_Cols*Nr_of_Rows*Nr_of_Layers-1 downto 0) of std_logic;

   -- For this case its 2 member array of 2 members : each member is a std_logic
   -- [(1,0)(1,0)]
   --    1    0


   ------------------------------------------------------------------------------------------------

   subtype Type_type is std_logic_vector(Type_Size-1 downto 0);
   subtype Flit_id_type is std_logic_vector(Flit_id_size-1 downto 0);
   subtype PID_type is std_logic_vector(PID_size-1 downto 0);
   -- subtype channel_type is std_logic_vector(channel_Size-1 downto 0);
   subtype HC_type is std_logic_vector(HC_Size-1 downto 0);
   subtype NS_type is std_logic_vector(NS_Size-1 downto 0);
   subtype EW_type is std_logic_vector(EW_Size-1 downto 0);
   subtype UD_type is std_logic_vector(UD_Size-1 downto 0);
   subtype Data_type is std_logic_vector(Data_Size-1 downto 0);
   type Type_vector is array (0 to R) of Type_type;
   type Flit_id_vector is array (0 to R) of Flit_id_type;
   -- type channel_vector is array (0 to R) of channel_type;
   type HC_vector_type is array(integer range <>) of HC_Type;
   subtype HC_vector is HC_vector_type(0 to R);
   type NS_vector is array (0 to R) of NS_type;
   type EW_vector is array (0 to R) of EW_type;
   type UD_vector is array (0 to R) of UD_type;

   -- Type types
   constant TYPE_SETUP:Type_type:="11"; -- TYPE_SETUP is a const of type 'Type_type' and has value '11'
   constant TYPE_DATA:Type_type:="10";
   constant TYPE_SWITCH:Type_type:="01";
   constant TYPE_EMPTY:Type_type:="00";
   -- Header types
   constant HC_CLR:HC_type:=(others=>'0');
   constant HC_PRIO0:HC_TYPE:=HC_CLR;
   constant HC_PRIO1:HC_type:=(HC_size-1=>'0', HC_size-2=>'1', others => '0');
   constant HC_PRIO2:HC_type:=(HC_size-1=>'1', HC_size-2=>'0', others => '0');
   constant HC_PRIO3:HC_type:=(HC_size-1=>'1', HC_size-2=>'1', others => '0');

   -- Bit locations of every field s high and low bit
   constant Valid_pos:integer:=NoC_packet'high;
   constant Type_high:integer:=NoC_packet'high; -- Setting location of type_high within packet to MSB (Valid is MSB of Type)
   constant Type_low:integer:=Type_high-Type_size+1;
   constant Flit_id_high:integer:=Type_low-1;
   constant Flit_id_low:integer:=Flit_id_high-Flit_id_size+1;
   constant Src_PID_high:integer:=Flit_id_low-1;
   constant Src_PID_low:integer:=Src_PID_high-PID_size+1;
   constant Dest_PID_high:integer:=Src_PID_low-1;
   constant Dest_PID_low:integer:=Dest_PID_high-PID_size+1;
   constant HC_high:integer:=Dest_PID_low-1;
   constant HC_low:integer:=HC_high-HC_size+1;
   constant NS_high:integer:=HC_low-1;
   constant NS_low:integer:=NS_high-NS_size+1;
   constant EW_high:integer:=NS_low-1;
   constant EW_low:integer:=EW_high-EW_size+1;
   constant UD_high:integer:=EW_low-1;
   constant UD_low:integer:=UD_high-UD_size+1;

   constant Header_high:integer:=Type_high;
   constant Header_low:integer:=UD_low;

   constant Data_high:integer:=Header_low-1;
   constant Data_low:integer:=Data_high-Data_size+1;

   subtype fsm_type is integer range 0 to 3;

   -- Use two extra bits for handshaking with Switch
   subtype outpacket is std_logic_vector(NoC_packet'high+2 downto 0);
   subtype inpacket is NoC_packet;

end NoC_Mesh_3D_Nostrum_package;
