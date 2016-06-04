LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY cell IS
PORT(cell_initial_value: in std_logic;
     Rcell: in std_logic;
     Lcell: in std_logic;
     Dcell: in std_logic;
     cell_out_value: out std_logic;
     cell_topdown: out std_logic;
     co: out std_logic);
END cell;



ARCHITECTURE Behavioral OF cell IS

BEGIN

      cell_out_value <= '1' when cell_initial_value = '1' AND (
				 (Rcell = 'X' AND (Lcell = '1' OR Dcell = '1')) OR
				 (Lcell = 'X' AND (Rcell = '1' OR Dcell = '1')) OR
				 (Lcell = '1' OR Rcell = '1' OR Dcell = '1')) else '0';

      cell_topdown <= '1' when cell_initial_value = '1' AND (
		               (Rcell = 'X' AND Lcell = '0' AND Dcell = '0') OR
			       (Lcell = 'X' AND Rcell = '0' AND Dcell = '0') OR
			       (Lcell = '0' AND Rcell = '0' AND Dcell = '0')) else Dcell;
      
      co <= '1' when cell_initial_value = '1' AND (
				 (Rcell = 'X' AND (Lcell = '1' OR Dcell = '1')) OR
				 (Lcell = 'X' AND (Rcell = '1' OR Dcell = '1')) OR
				 (Lcell = '1' OR Rcell = '1' OR Dcell = '1')) else 'Z';

END Behavioral;



