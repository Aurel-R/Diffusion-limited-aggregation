library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;
library std;
use std.textio.all;

entity bram is
generic (
    DATA    : integer := 1024; --width of the words
    ADDR    : integer := 11 --width of the address
);
port ( 
    rst     : in std_logic;
    -- Port A
    a_clk   : in  std_logic;
    a_wr    : in  std_logic; --write when high
    a_addr  : in  std_logic_vector(ADDR-1 downto 0); --address of the word
    a_din   : in  std_logic_vector(DATA-1 downto 0); --word to write
    a_dout  : out std_logic_vector(DATA-1 downto 0); --output word
     
    -- Port B
    b_clk   : in  std_logic;
    b_wr    : in  std_logic;
    b_addr  : in  std_logic_vector(ADDR-1 downto 0);
    b_din   : in  std_logic_vector(DATA-1 downto 0);
    b_dout  : out std_logic_vector(DATA-1 downto 0)
);
end bram;
 
architecture behavioral of bram is
    subtype word_t  is std_logic_vector(DATA - 1 downto 0);
    constant DEPTH : natural := (2**ADDR);
    type ram_type is array ( DEPTH-1 downto 0 ) of word_t;
    
    function InitRam return Ram_Type is
          variable RamFileLine : line;
          variable RAM :ram_type;
          variable word : bit_vector(DATA-1 downto 0) := (others => '1'); --to read binary number 
    begin
	  RAM(5) := to_stdlogicvector(word);
	  word := (others => '0'); 
          for i in ram_type'range loop
	     if i /= 5 then
               RAM(i) := to_stdLogicVector(word); --for binary numbers
             end if;
          end loop;
          return RAM;
    end function;

    --shared variable can be accessed by more than one process
    shared variable mem : ram_type := InitRam;
    
    
begin
    --for test purposes
    --process(a_clk)
    --    variable i : integer := 0;
    --begin
    --    if rising_edge(a_clk) then
    --        report "MEM(" & integer'image(i) & ") = " & integer'image(to_integer(unsigned(mem(i))));
    --        i := (i +1) mod DEPTH;
    --    end if;
    --end process;

    process(rst)
    begin
	mem := InitRam;
    end process;

    -- Port A
    portA_proc:process(a_clk)
    begin
        if rising_edge(a_clk) then
            if(a_wr='1') then
                mem(to_integer(unsigned(a_addr))) := a_din;
            end if;
            a_dout <= mem(to_integer(unsigned(a_addr)));
        end if;
    end process;
    
    -- Port B
    portB_proc:process(b_clk)
    begin
        if rising_edge(b_clk) then
            if(b_wr='1') then
                mem(to_integer(unsigned(b_addr))) := b_din;
            end if;
            b_dout <= mem(to_integer(unsigned(b_addr)));
        end if;
    end process;
 
end behavioral;
