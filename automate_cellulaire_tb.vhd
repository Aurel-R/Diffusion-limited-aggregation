LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE work.paq;

ENTITY automate_cellulaire_tb IS
END automate_cellulaire_tb;

ARCHITECTURE Behavioral OF automate_cellulaire_tb IS
	COMPONENT automate_cellulaire IS
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
	END COMPONENT;

	constant sw_number: integer := 8;

	-- /!\ IMPORTANT NOTE /!\	
	--	apparently, clk_period and pixel_clk_perdio should be synchronized:
	--		for correct print, try clk_period = h_pixels * pixel_clk_period
	--
	-- (it's difficult to check this without tests on real screen, I based only on gtkwave so...)
	constant h_pixels: integer := 16;
	constant v_pixels: integer := 8;
	constant pixel_clk_period: time := 1 ns;
	constant clk_period: time := 16 ns;  -- pixel_clk_period * h_pixels
	
	signal clk: std_logic;
	signal pixel_clk: std_logic;
	signal rst: std_logic := '0';
	signal btnc, btnu, btnd, btnl, btnr: std_logic := '0';
	signal sw: std_logic_vector(SW_NUMBER-1 downto 0) := (others => '0');
	signal led: std_logic_vector(7 downto 0);
	signal R,G,B: std_logic_vector(7 downto 0);
	signal h_sync: std_logic;
	signal v_sync: std_logic;


BEGIN
	
	uut: automate_cellulaire generic map (h_pixels=>h_pixels, v_pixels=>v_pixels) 
		port map (clk, pixel_clk, rst, btnc,btnu,btnd,btnl,btnr,sw,led,R,G,B,h_sync,v_sync);

	clock: process
	begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
	end process;

	pixel_clock: process
	begin
		pixel_clk <= '1';
		wait for pixel_clk_period/2;
		pixel_clk <= '0';
		wait for pixel_clk_period/2;
	end process;


	sig_proc: process
	begin
		report "START OF TEST";
		wait for 10 ns;
		btnu <= '1';
		wait for 20 ns;
		btnu <= '0';
		wait for 100000 ns;

		-- uncomment for various tests

	--	btnd <= '1';
	--	wait for 10 ns;
	--	btnd <= '0';
	--	wait for 100 ns;

	--	btnu <= '1';
	--	wait for 10 ns;
	--	btnu <= '0';
	--	wait for 10000 ns;
		
	--	rst <= '1';
	--	wait for 10 ns;
	--	rst <= '0';
	--	wait for 20 ns;

		report "END OF TEST";
		wait;
	end process;

END Behavioral;






