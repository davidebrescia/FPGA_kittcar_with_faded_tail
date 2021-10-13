--------------------------------------------------------------------------------------------
-- At the output it generates the simple kittcar effect
--------------------------------------------------------------------------------------------
-- It consists of a shift register of 2*N_LEDS-2 stages of 1 bit 
-- The shift register has a feedback, meaning that the last one is connected to the first one
--------------------------------------------------------------------------------------------


-------- DEFAULT LIBRARY -------
library IEEE;
	use IEEE.STD_LOGIC_1164.all;
	use IEEE.NUMERIC_STD.ALL;
--------------------------------


entity kittcar is
    Generic(
            -- N° of LEDs
            N_LEDS      : INTEGER;       
            -- Initial position of the brightest LED
            INIT_POS    : INTEGER        
        );
        Port( 
            ---------Global---------
            clk : IN STD_LOGIC;
            res : IN STD_LOGIC;
            
            ---------I/O------------
            clk_enable : IN STD_LOGIC;
            kittcar_out : OUT   STD_LOGIC_VECTOR(N_LEDS-1 downto 0)
        );
end kittcar;

architecture Behavioral of kittcar is

    -------------------- Constant declaration -----------------------
    constant N_CELLS : INTEGER := 2*N_LEDS-2;
    constant INIT_VALUE : STD_LOGIC_VECTOR(0 to N_CELLS-1)  := ( INIT_POS => '1', Others => '0' );   
	--------------------------------------------------------------------
	
    -------------------------- Signals ------------------------------
    signal MEM      : STD_LOGIC_VECTOR(0 to N_CELLS-1)  := INIT_VALUE;  
	--------------------------------------------------------------------

begin

    ----------------------------- Data flow ---------------------------
	kittcar_out(0) <= MEM(0);
    kittcar_out(N_LEDS-1) <= MEM(N_LEDS-1);
    
    -- The output is the logic OR between MEM ( 1 TO N_LEDS-2 ) with ( 2*N_LEDS-3 DOWNTO N_LEDS) 
    -- E.G. kittcar_out(1) = MEM(1) or MEM(29) ...
    -- E.G. kittcar_out(14) = MEM(14) or MEM(16), in case of N_LEDS = 16 
    gen: for I in 1 to N_LEDS-2 generate
        kittcar_out(I) <= MEM(I) or MEM(N_CELLS - I); 
    end generate;    
	--------------------------------------------------------------------
    
    
    ----------------------------- Process ------------------------------
    Shift_Reg: process(clk, res, clk_enable) 
    begin
	----- Async reset --------
        if (res = '1') then
            MEM <= INIT_VALUE;  -- resetted to INIT_VALUE 
	 
	------ Sync process --------
        elsif (rising_edge(clk) AND clk_enable = '1') then 
            MEM <= '0' & MEM(0 to N_CELLS - 2);         -- Shift register 
            MEM(0) <= MEM(N_CELLS - 1);                 -- feedback
        end if;
		
    end process;
	--------------------------------------------------------------------
	
end Behavioral;