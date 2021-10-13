-----------------------------------------------------------------------------------------------
-- This entity generates a number 'TAIL' of PWM linearly decreasing signals. 
-- 'TAIL' = number of leds ON in the tail. (TAIL = 1 means only 1 led ON). 
-----------------------------------------------------------------------------------------------  
-- The design aims to minimize the components utilization, that's why we decided to implement a 
-- shift register instead of a counter. This choice is the best if TAIL isn't too large, like
-- the value that can presumably assume in our Basys 3 board.
-- Indeed, with a shift reg the number of flipflops increase linearly with TAIL, 
-- with a counter instead the growth is logarithmic but there are more support luts.  
-- The shift register has a '0' at the input.
-- The '0' is shifted until the last FFD has a '0', then the whole register is resetted to '1'
-- So that the output has a N° of TAIL of outputs square waves with different duty cycle.
-----------------------------------------------------------------------------------------------


---------- DEFAULT LIBRARY ---------
library IEEE;
	use IEEE.STD_LOGIC_1164.all;
	use IEEE.NUMERIC_STD.ALL;
------------------------------------


entity pwm_multiout is
    Generic(
            -- Tail length, (TAIL = 1 means only 1 led ON) 
            TAIL : INTEGER 
        );
        Port(
            ---------Global---------
            clk : IN STD_LOGIC;
            res : IN STD_LOGIC;
            ---------I/O------------
            pwm : OUT STD_LOGIC_VECTOR(TAIL-1 downto 0)
        );
end pwm_multiout;


architecture Behavioral of pwm_multiout is

    ---------------------------- Signals ----------------------------    
    signal	MEM : STD_LOGIC_VECTOR(0 to TAIL-2) := (Others => '1');
    -----------------------------------------------------------------
    
begin

    ----------------------------- Data flow ---------------------------
    pwm(TAIL-1) <= '1';             -- the first output is always '1', the brightest led has maximum intensity = always on
    pwm(TAIL-2 downto 0) <= MEM;    -- others outputs are out of mem_reg
	-------------------------------------------------------------------
	 
	 
    ----------------------------- Process ------------------------------
    shift_reg: process(clk, res)
    begin 
        ----- Async Reset --------
        if res = '1' then
            MEM <= (Others => '1');
        ----------------------------
        
        ------ Sync Process --------
        elsif rising_edge(clk) then  
            MEM <= MEM(1 to TAIL-2) & '0';
            if MEM(0) = '0' then
                MEM <= (Others => '1');
            end if;
        end if;
        ----------------------------	
    end process;
	-------------------------------------------------------------------   
	
end Behavioral;