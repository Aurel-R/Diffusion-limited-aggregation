LIBRARY ieee;
LIBRARY std;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.paq;


ENTITY grid IS
	generic(DATA: integer := 1024);
	port(lineAr, lineBr: in std_logic_vector(DATA-1 downto 0);
	     lineAw, lineBw: out std_logic_vector(DATA-1 downto 0);
	     co: out std_logic := 'Z');
END grid;



ARCHITECTURE Behavioral OF grid IS
BEGIN
  gen_reg: FOR I IN 0 TO DATA-1 GENERATE
	  FIRST_CELL: IF I = 0 GENERATE
		cell0: paq.cell port map (lineAr(I), lineAr(I+1), 'X', lineBr(I), lineAw(I), lineBw(I), co);
	  END GENERATE FIRST_CELL;

	  LAST_CELL: IF I = DATA-1 GENERATE
		cellN: paq.cell port map (lineAr(I), 'X', lineAr(I-1), lineBr(I), lineAw(I), lineBw(I), co);
	  END GENERATE LAST_CELL;

	  X_CELL: IF I > 0 AND I < DATA-1 GENERATE
		cellX: paq.cell port map (lineAr(I), lineAr(I+1), lineAr(I-1), lineBr(I), lineAw(I), lineBw(I), co);
	 END GENERATE X_CELL;
  END GENERATE gen_reg;

END Behavioral;


  
