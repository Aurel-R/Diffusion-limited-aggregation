LIBRARY ieee;
LIBRARY std;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

ENTITY hw_img IS
 	generic (ROW_BITS_LEN: integer := 11;
		 COL_BITS_LEN: integer := 11;
		 DATA: integer := 1024);
	port(disp_ena: in std_logic;
	     row: in std_logic_vector(ROW_BITS_LEN-1 downto 0);
	     col: in std_logic_vector(COL_BITS_LEN-1 downto 0);
	     b_dout: in std_logic_vector(DATA-1 downto 0) := (others => '0');
	     b_addr: out std_logic_vector(ROW_BITS_LEN-1 downto 0);
	     R,G,B : out std_logic_vector(7 downto 0) := (others => '0'));
END hw_img;


ARCHITECTURE Behavioral OF hw_img IS
BEGIN

	b_addr <= row;

	R <= (others => '1') when disp_ena = '1' AND b_dout(to_integer(unsigned(col))) = '1' else
	     (others => '0');
	G <= (others => '1') when disp_ena = '1' AND b_dout(to_integer(unsigned(col))) = '1' else
	     (others => '0');
	B <= (others => '1') when disp_ena = '1' AND b_dout(to_integer(unsigned(col))) = '1' else
	     (others => '0');

END Behavioral;
