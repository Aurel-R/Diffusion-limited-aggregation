LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE work.paq;

ENTITY automate_cellulaire IS
  GENERIC(
    
    --WIDTH_GRID : natural := 3; --width of the cellular automata grid   -- UNUSED !
    --HEIGHT_GRID: natural := 3; --height of the cellular automata grid  -- UNUSED !
    

	-- /!\ INFO /!\
	--	- h_pixels & v_pixels is used to create the Grid
	--	- You have to give only the display resolution
	--		for 1024x768 screen:
	--					h_pixels := 1024
	--					v_pixels := 768
	-- 
	--	That create a memory of 768 address, each containing 1024 bits

    SW_NUMBER: INTEGER := 8; --switch number 
    h_pulse  :  INTEGER   := 1;   --horiztonal sync pulse width in pixels
    h_bp     :  INTEGER   := 3;   --horiztonal back porch width in pixels
    h_pixels :  INTEGER   := 6;  --horiztonal display width in pixels
    h_fp     :  INTEGER   := 2;   --horiztonal front porch width in pixels
    h_pol    :  STD_LOGIC := '1';   --horizontal sync pulse polarity (1 = positive, 0 = negative)
    v_pulse  :  INTEGER   := 2;     --vertical sync pulse width in rows
    v_bp     :  INTEGER   := 1;    --vertical back porch width in rows
    v_pixels :  INTEGER   := 8;  --vertical display width in rows
    v_fp     :  INTEGER   := 3;     --vertical front porch width in rows
    v_pol    :  STD_LOGIC := '1'   --vertical sync pulse polarity (1 = positive, 0 = negative)
  );PORT(
    clk       :  IN   STD_LOGIC;  --state update clock
    pixel_clk :  IN   STD_LOGIC;  --pixel clock at frequency of VGA mode being used
    rst       :  IN   STD_LOGIC;  
    btnc,btnu,btnd,btnl,btnr : IN STD_LOGIC; --buttons
    sw        :  IN   STD_LOGIC_VECTOR(SW_NUMBER-1 downto 0); --switches
    led       :  OUT  STD_LOGIC_VECTOR(7 downto 0); --led
    R,G,B     :  OUT  STD_LOGIC_VECTOR(7 downto 0); --color of pixel
    h_sync    :  OUT  STD_LOGIC;  --horiztonal sync pulse
    v_sync    :  OUT  STD_LOGIC  --vertical sync pulse
  );
END automate_cellulaire;


ARCHITECTURE Behavioral OF automate_cellulaire IS


	function bits_req(nb: integer) return integer is
		variable ret, x: integer;
	begin
		ret := 1;
		x := nb;
		while x > 0 loop
			ret := ret + 1;
			x := x / 2;
		end loop;
		return ret;
	end function;

	constant row_bits_len: integer := bits_req(v_pixels);
	constant col_bits_len: integer := bits_req(h_pixels);
	constant random_bits_len: integer := bits_req(h_pixels) - 1;
	constant max_random_value: integer := h_pixels - 1;

	-- interconnection signals: [rand] <==> [fsm]
	signal random: std_logic_vector(random_bits_len-1 downto 0) := (others => '0');

	-- interconnection signals: [fsm] <==> [bram]
	signal a_addr: std_logic_vector(row_bits_len-1 downto 0) := (others => '0');
	signal a_dout: std_logic_vector(h_pixels-1 downto 0) := (others => '0');
	signal a_wr  : std_logic := '0';
	signal a_din : std_logic_vector(h_pixels-1 downto 0) := (others => '0'); 
	
	-- interconnection signals: [bram] <==> [hw_img] 
	signal b_dout: std_logic_vector(h_pixels-1 downto 0) := (others => '0');
	signal b_addr: std_logic_vector(row_bits_len-1 downto 0) := (others => '0');
	signal b_wr: std_logic := '0'; -- UNUSED
	signal b_din: std_logic_vector(h_pixels-1 downto 0) := (others => '0'); -- UNUSED

	-- interconnection signals: [hw_img] <==> [vga_ctl]
	signal disp_ena: std_logic := '0';
	signal row: std_logic_vector(row_bits_len-1 downto 0) := (others => '0');
	signal col: std_logic_vector(col_bits_len-1 downto 0) := (others => '0');


BEGIN
	rand: paq.rand generic map (random_bits_len, max_random_value)
			  port map (clk, random);

	-- port map for Grid is generate inside the fsm (and port map for cell inside the Grid)
	fsm: paq.fsm generic map (SW_NUMBER, h_pixels, row_bits_len, v_pixels-1, random_bits_len)
		        port map (clk, rst, btnu, btnd, sw, a_addr, a_dout, a_wr, a_din, random);

	bram: paq.bram generic map (h_pixels, row_bits_len)
			  port map (rst, clk, a_wr, a_addr, a_din, a_dout, pixel_clk, b_wr, 
				    b_addr, b_din, b_dout);	
	
	hw_img: paq.hw_img generic map (row_bits_len, col_bits_len, h_pixels)
			      port map (disp_ena, row, col, b_dout, b_addr, R, G, B);

	vga_ctl: paq.vga_ctl generic map (h_pulse, h_bp, h_pixels, h_fp, h_pol,
				          v_pulse, v_bp, v_pixels, v_fp, v_pol,
					  col_bits_len, row_bits_len)
				port map (pixel_clk, rst, h_sync, v_sync, disp_ena, col, row);	  

END Behavioral;


