----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/12/2020 06:54:35 PM
-- Design Name: 
-- Module Name: vga - Behavioral
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

entity vga is
    Port ( 
           ps2_clk : in std_logic_vector(0 downto 0);
           ps2_dat : in std_logic_vector(0 downto 0);
           clk : in STD_LOGIC;
           sw : in std_logic_vector(2 downto 0);
           rst : in std_logic;
           vgaRed : out STD_LOGIC_VECTOR (3 downto 0);
           vgaBlue : out STD_LOGIC_VECTOR (3 downto 0);
           vgaGreen : out STD_LOGIC_VECTOR (3 downto 0);
           Hsync : out STD_LOGIC;
           Vsync : out STD_LOGIC);
end vga;

architecture Behavioral of vga is
component clk_wiz_0 is
    Port(
       clk_out1 : out std_logic;
       reset : in std_logic;
       locked : out std_logic;
       clk_in1 : in std_logic);
end component;
component ROM is
  Port ( 
    AddrH : in  integer range 0 to 1279;
    AddrV : in integer range 0 to 1023;
    Colors : out std_logic_vector(11 downto 0));
end component;
signal AddrH : integer range 0 to 1279;
signal AddrV : integer range 0 to 1023;
signal Color: std_logic_vector(11 downto 0);
signal charac: std_logic_vector(7 downto 0);
signal locked : std_logic;
signal ck25MHz : std_logic;
signal TCH : std_logic;
signal Hcount : integer range 0 to 1687;
signal Vcount : integer range 0 to 1065;
begin

a: clk_wiz_0 port map(clk_out1=>ck25MHz,clk_in1=>clk,locked=>locked,reset=>rst);
--b: ROM port map (AddrH=>AddrH, AddrV=>AddrV,Colors => Color);
process(ck25MHz,rst)
begin
if rising_edge(ck25MHz) then
    if(rst = '1') then
        Hcount <= 0;
        TCH <= '0';
    end if;
    if(Hcount = 1679) then
        Hcount <= 0;
        TCH <= '1';
    else
        Hcount <= Hcount + 1;
        TCH <= '0';
    end if;   
end if;
end process;

process(ck25MHz,rst,TCH)
begin
if rising_edge(ck25MHz) then
    if(rst = '1') then
        Vcount <= 0;
    end if;
    if (TCH = '1') then
    if(Vcount = 1065) then
        Vcount <= 0;
    else
        Vcount <= Vcount + 1;
    end if;  
    end if; 
end if;
end process;

process(Vcount)
begin
    if(Vcount < 3) then
        Vsync <= '1';
    else
        Vsync <= '0';
    end if;
end process;

process(Hcount)
begin
    if(Hcount < 112) then
        Hsync <= '1';
    else
        Hsync <= '0';
    end if;
end process;

process(Hcount,Vcount,charac)
variable R,G,B : std_logic_vector(3 downto 0);
begin
if(Hcount < 1640 and Hcount > 360) then
    if(Vcount >41 and Vcount <1065) then
        if(charac = x"2d") then
            R:= "1111";
            B:= "0000";
            G:= "0000";
         elsif(charac = x"32") then
            R:= "0000";
            B:= "1111";
            G:= "0000";
         elsif(charac = x"34") then
            R:= "0000";
            G:= "1111";
            B:= "0000";
         else
            R:= "0000"; 
            G:= "0000";
            B:= "0000";
         end if;
     else
        AddrH <= 0;
        AddrV <= 0;
        R:= "0000";
        G:= "0000";
        B:= "0000";
     end if;
else
     AddrH <= 0;
     AddrV <= 0;
     R:= "0000";
     B:= "0000";
     G:= "0000";
end if;
vgaRed <= R;
vgaBlue <= B;
vgaGreen <= G;
end process;


--PS/2 Controller
process(ps2_clk)
variable char : std_logic_vector(8 downto 0);
variable start: std_logic := '0';
variable count: integer range 0 to 8;
begin
if(falling_edge(ps2_clk(0))) then
if(start = '0') and (ps2_dat(0)='0') then
    start := '1';
    count := 0;
else
    if(start = '1') then
        if(count = 8) then
            if(char(7 downto 0) /= x"f0") then
                charac <= char(7 downto 0);
            end if;
            start := '0';
        else
            char(count) := ps2_dat(0);
            count := count + 1;
        end if;
     end if;
end if;
end if;
end process;
end Behavioral;
