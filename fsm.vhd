LIBRARY ieee;
LIBRARY std;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.paq;

ENTITY fsm IS
  GENERIC(
    SW_NUMBER:	INTEGER := 8;
    DATA: INTEGER := 1024;
    ADDR: INTEGER := 11; -- (768) each line corresponds to one address
    MAX_COUNTER: INTEGER := 767;
    RANDOM_BITS_LEN: INTEGER := 11
  );PORT(
    clk : IN	STD_LOGIC; --system clock
    rst	: IN	STD_LOGIC := '0'; --used to reset bram
    btnu: IN	STD_LOGIC := '0'; --running the cellular automaton
    btnd: IN	STD_LOGIC := '0'; --stay the cellular automaton
    sw  : IN	STD_LOGIC_VECTOR(SW_NUMBER-1 downto 0) := (others => '0'); --mod switch
    a_addr: OUT STD_LOGIC_VECTOR(ADDR-1 downto 0) := (others => '0');
    a_dout: IN STD_LOGIC_VECTOR(DATA-1 downto 0) := (others => '0');
    a_wr : OUT std_logic := '0';
    a_din: OUT STD_LOGIC_VECTOR(DATA-1 downto 0) := (others => '0');
    random: IN STD_LOGIC_VECTOR(RANDOM_BITS_LEN-1 downto 0) := (others => '0')
  );
END fsm;


ARCHITECTURE Behavioral OF fsm IS

  type state is (waiting, running, reload, writeT, writeA, writeB, readA, readB);
  signal current_s: state := waiting;
  signal next_s: state;
  signal counter: UNSIGNED(ADDR-1 downto 0) := (others => '0');
  signal sw_save_state: STD_LOGIC_VECTOR(SW_NUMBER-1 downto 0); --to detect speed change (unused yet)
  signal wr: STD_LOGIC := '0';
  signal lineAr: STD_LOGIC_VECTOR(DATA-1 downto 0) := (others => '0');
  signal lineBr: STD_LOGIC_VECTOR(DATA-1 downto 0) := (others => '0');
  signal lineAw: STD_LOGIC_VECTOR(DATA-1 downto 0) := (others => '0');
  signal lineBw: STD_LOGIC_VECTOR(DATA-1 downto 0) := (others => '0');
  signal co : STD_LOGIC := 'Z';
  signal top_line: STD_LOGIC_VECTOR(DATA-1 downto 0) := (others => '0');

BEGIN

  PROCESS (clk, rst, btnd) IS
  BEGIN
    if rst = '1' then
	current_s <= reload;
    elsif btnd = '1' then
	current_s <= waiting;	    
    elsif rising_edge(clk) then
	current_s <= next_s;
    end if;
  END PROCESS;

  a_wr <= '1' when current_s = writeT else
	  '1' when current_s = writeA else
	  '1' when current_s = writeB else '0';

  a_addr <= STD_LOGIC_VECTOR(counter-1) when current_s = writeA AND counter > 0 else 
	    STD_LOGIC_VECTOR(counter);
  
  with current_s select
    a_din <= top_line when writeT, lineAw when writeA, lineBw when writeB, (others => 'X') when others;

  lineAr <= a_dout when current_s = readA;
  lineBr <= a_dout when current_s = readB;

  grid: paq.grid generic map (DATA) port map (lineAr, lineBr, lineAw, lineBw, co);

  PROCESS (current_s,btnu) IS
  BEGIN
        case current_s is
	when waiting =>
		if btnu = '1' then
		  next_s <= running;
		else
		  next_s <= waiting;
		end if;
	when running =>
		if co = '1' then
		   counter <= (others => '0');
		   next_s <= running;
		end if;
	
		if counter = 0 then
		  top_line(to_integer(unsigned(random))) <= '1';
		  next_s <= writeT;
		elsif counter < MAX_COUNTER and wr = '1' then
		  next_s <= writeA;
		elsif counter < MAX_COUNTER and wr = '0' then
		  next_s <= readA;
		else
		  next_s <= waiting;
		end if;
	when reload =>
		counter <= (others => '0');
		next_s <= waiting;
	when writeT =>
		next_s <= readA;
	when writeA =>
		top_line <= (others => '0');
		next_s <= writeB;
	when writeB =>
		wr <= '0';
		next_s <= running;
	when readA =>
		counter <= counter + 1;
		next_s <= readB;
	when readB =>
		wr <= '1';
		next_s <= running;
	end case;			
  END PROCESS;

  PROCESS (sw) IS
  BEGIN
    if sw /= sw_save_state then
	sw_save_state <= sw;
    end if;
  END PROCESS;

END Behavioral;


