LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;

------------------------
--vga_controller
--modified from https://eewiki.net/pages/viewpage.action?pageId=15925278
--Benoit Chappet de Vangel
--05/04/2016
--version 1.0
-----------------------
ENTITY vga_ctl IS
  GENERIC(
    h_pulse  :  INTEGER   := 1;   --horizontal sync pulse width in pixels
    h_bp     :  INTEGER   := 3;   --horizontal back porch width in pixels
    h_pixels :  INTEGER   := 6;  --horizontal display width in pixels
    h_fp     :  INTEGER   := 2;   --horizontal front porch width in pixels
    h_pol    :  STD_LOGIC := '1';   --horizontal sync pulse polarity (1 = positive, 0 = negative)
    v_pulse  :  INTEGER   := 2;     --vertical sync pulse width in rows
    v_bp     :  INTEGER   := 1;    --vertical back porch width in rows
    v_pixels :  INTEGER   := 8;  --vertical display width in rows
    v_fp     :  INTEGER   := 3;     --vertical front porch width in rows
    v_pol    :  STD_LOGIC := '1';   --vertical sync pulse polarity (1 = positive, 0 = negative)
--    WIDTH_COORD : NATURAL := 15);   --width of column and row vector 
    col_bits_len: integer := 11;
    row_bits_len : integer := 11);
  PORT(
    pixel_clk :  IN   STD_LOGIC;  --pixel clock at frequency of VGA mode being used
    rst   :  IN   STD_LOGIC;  
    h_sync    :  OUT  STD_LOGIC;  --horizontal sync pulse
    v_sync    :  OUT  STD_LOGIC;  --vertical sync pulse
    disp_ena  :  OUT  STD_LOGIC;  --display enable ('1' = display time, '0' = blanking time)
    column    :  OUT  STD_LOGIC_VECTOR(col_bits_len-1 downto 0);    --horizontal pixel coordinate
    row       :  OUT  STD_LOGIC_VECTOR(row_bits_len-1 downto 0));    --vertical pixel coordinate
END vga_ctl;

ARCHITECTURE behavior OF vga_ctl IS
  CONSTANT  h_period  :  INTEGER := h_pulse + h_bp + h_pixels + h_fp;  --total number of pixel clocks in a row
  CONSTANT  v_period  :  INTEGER := v_pulse + v_bp + v_pixels + v_fp;  --total number of rows in column
BEGIN

  PROCESS(pixel_clk, rst)
    VARIABLE h_count  :  INTEGER RANGE 0 TO h_period - 1 := 0;  --horizontal counter (counts the columns)
    VARIABLE v_count  :  INTEGER RANGE 0 TO v_period - 1 := 0;  --vertical counter (counts the rows)
  BEGIN
  
    IF(rst = '1') THEN  --reset asserted
      h_count := 0;         --reset horizontal counter
      v_count := 0;         --reset vertical counter
      h_sync <= NOT h_pol;  --deassert horizontal sync
      v_sync <= NOT v_pol;  --deassert vertical sync
      disp_ena <= '0';      --disable display
      column <= (others => '0');          --reset column pixel coordinate
      row <= (others => '0');             --reset row pixel coordinate
      
    ELSIF(rising_edge(pixel_clk)) THEN

      --counters
      IF(h_count < h_period - 1) THEN    --horizontal counter (pixels)
        h_count := h_count + 1;
      ELSE
        h_count := 0;
        IF(v_count < v_period - 1) THEN  --veritcal counter (rows)
          v_count := v_count + 1;
        ELSE
          v_count := 0;
        END IF;
      END IF;

      --horizontal sync signal
      IF(h_count < h_pixels + h_fp OR h_count >= h_pixels + h_fp + h_pulse) THEN
        h_sync <= NOT h_pol;    --deassert horizontal sync pulse
      ELSE
        h_sync <= h_pol;        --assert horizontal sync pulse
      END IF;
      
      --vertical sync signal
      IF(v_count < v_pixels + v_fp OR v_count >= v_pixels + v_fp + v_pulse) THEN
        v_sync <= NOT v_pol;    --deassert vertical sync pulse
      ELSE
        v_sync <= v_pol;        --assert vertical sync pulse
      END IF;
      
      --set pixel coordinates
      IF(h_count < h_pixels) THEN  --horizontal display time
        column <= std_logic_vector(to_unsigned(h_count,column'LENGTH));         --set horizontal pixel coordinate
      END IF;
      IF(v_count < v_pixels) THEN  --vertical display time
        row <= std_logic_vector(to_unsigned(v_count,row'LENGTH));            --set vertical pixel coordinate
      END IF;

      --set display enable output
      IF(h_count < h_pixels AND v_count < v_pixels) THEN  --display time
        disp_ena <= '1';                                  --enable display
      ELSE                                                --blanking time
        disp_ena <= '0';                                  --disable display
      END IF;

    END IF;
  END PROCESS;

END behavior;
