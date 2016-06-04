LIBRARY ieee;
LIBRARY std;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


PACKAGE paq IS

component fsm is
	generic (SW_NUMBER: integer := 8;
		 DATA: integer := 1024;
		 ADDR: integer := 11; --(768)
		 MAX_COUNTER: integer := 767;
		 RANDOM_BITS_LEN: integer := 11);
	port(clk: in std_logic;
	     rst: in std_logic := '0';
	     btnu: in std_logic := '0';
	     btnd: in std_logic := '0';
	     sw: in std_logic_vector(SW_NUMBER-1 downto 0) := (others => '0');
	     a_addr: out std_logic_vector(ADDR-1 downto 0) := (others => '0');
	     a_dout: in std_logic_vector(DATA-1 downto 0) := (others => '0');
	     a_wr: out std_logic := '0';
             a_din: out std_logic_vector(DATA-1 downto 0) := (others => '0');
	     random: in std_logic_vector(RANDOM_BITS_LEN-1 downto 0) := (others => '0'));	
end component;

component bram is
	generic (DATA : integer := 1024;
	         ADDR : integer := 11); 
	port(rst : in std_logic;
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
	     b_dout  : out std_logic_vector(DATA-1 downto 0));  
end component;

component hw_img is
	generic (ROW_BITS_LEN: integer := 11;
		 COL_BITS_LEN: integer := 11;
		 DATA: integer := 1024);
	port(disp_ena: in std_logic;
	     row: in std_logic_vector(ROW_BITS_LEN-1 downto 0);
	     col: in std_logic_vector(COL_BITS_LEN-1 downto 0);
	     b_dout: in std_logic_vector(DATA-1 downto 0) := (others => '0');
	     b_addr: out std_logic_vector(ROW_BITS_LEN-1 downto 0);
	     R,G,B : out std_logic_vector(7 downto 0) := (others => '0'));
end component;

component vga_ctl is
	generic(h_pulse: INTEGER   := 1;
		h_bp:  INTEGER   := 3;   
		h_pixels :  INTEGER   := 6;
		h_fp     :  INTEGER   := 2;
		h_pol    :  STD_LOGIC := '1';
		v_pulse  :  INTEGER   := 2; 
		v_bp     :  INTEGER   := 1;
		v_pixels :  INTEGER   := 8;
		v_fp     :  INTEGER   := 3;
		v_pol    :  STD_LOGIC := '1';
		col_bits_len: INTEGER := 11;
		row_bits_len: INTEGER := 11);
	port(pixel_clk: in std_logic;
	     rst: in std_logic;
	     h_sync: out std_logic;
	     v_sync: out std_logic;
	     disp_ena: out std_logic;
	     column: out std_logic_vector(col_bits_len-1 downto 0);
	     row: out std_logic_vector(row_bits_len-1 downto 0));	
end component;

component grid is
	generic(DATA: integer := 1024);
	port(lineAr, lineBr: in std_logic_vector(DATA-1 downto 0);
	     lineAw, lineBw: out std_logic_vector(DATA-1 downto 0);
	     co: out std_logic := 'Z');
end component;

component cell is
	port(cell_initial_value: in std_logic;
	     Rcell: in std_logic;
	     Lcell: in std_logic;
	     Dcell: in std_logic;
	     cell_out_value: out std_logic;
	     cell_topdown: out std_logic;
	     co: out std_logic);
end component;	

component rand is
	generic (WIDTH: integer := 11;
		 MAX: integer := 1023);
	port(clk: in STD_LOGIC;
	     random: out STD_LOGIC_VECTOR(WIDTH-1 downto 0));
end component;

END PACKAGE paq;


