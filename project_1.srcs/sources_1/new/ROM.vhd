----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/13/2020 11:18:39 AM
-- Design Name: 
-- Module Name: ROM - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ROM is
  Port ( 
    AddrH : in  integer range 0 to 1279;
    AddrV : in integer range 0 to 1023;
    Colors : out std_logic_vector(11 downto 0));
end ROM;

architecture Behavioral of ROM is
type H_mem is array (0 to 1279) of std_logic_vector(11 downto 0);
type rom_mem is array(0 to 1023) of H_mem; 
signal ROM : rom_mem :=(
0 to 255=>(others=>x"f00"),
256 to 511=>(others=>x"0f0"),
512 to 767=>(others=>x"00f"),
others=>(others=>x"fff"));
begin
Colors<=ROM(AddrV)(AddrH);
end Behavioral;
