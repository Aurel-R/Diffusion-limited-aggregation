LIBRARY ieee;
LIBRARY std;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

ENTITY rand IS
  GENERIC( WIDTH: INTEGER := 11;
	   MAX: INTEGER := 1023);
  PORT(clk: in STD_LOGIC;
       random: out STD_LOGIC_VECTOR(WIDTH-1 downto 0));
END rand;

ARCHITECTURE Behavioral OF rand IS
BEGIN
	process(clk) is
	variable rand_temp : std_logic_vector(width-1 downto 0):= ('1', others => '0');
	variable temp : std_logic := '0';
	begin
		if(rising_edge(clk)) then
		  temp := rand_temp(width-1) xor rand_temp(width-2);
		  rand_temp(width-1 downto 1) := rand_temp(width-2 downto 0);
		  rand_temp(0) := temp;
		end if;
		if (unsigned(rand_temp) <= MAX) then
		  random <= rand_temp;
		end if;
	end process;
END Behavioral;

