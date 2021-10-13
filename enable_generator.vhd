---------------------------------------------------------------------------------------------------
-- This entity generates clk_enable
-- clk_enable gives the possibility to change the execution rate of kitt_car and unifier
------------IMPORTANT--------------
-- clk_enable isn't supposed to be used a clock signal, the actual clock signal has a dedicated bus
---------------------------------------------------------------------------------------------------

---------- DEFAULT LIBRARY ---------
    library IEEE;
	use IEEE.STD_LOGIC_1164.all;
	use IEEE.NUMERIC_STD.ALL;
------------------------------------

entity enable_generator is
    Generic(      
            -- N° of switches
            N_SWITCHES : INTEGER;       
            -- N° of clock cycles for each 'time' unit. What is T0, exactly? T = T0 * (sw + 1), where T is the N° of clock cycles to wait for leds movement. T0 is the desired T when sw = 0. 
            T0         : INTEGER   
        );
    Port ( 
           ---------Global---------
           clk : IN STD_LOGIC;
           res : IN STD_LOGIC;
           ---------I/O---------
           clk_enable   : OUT STD_LOGIC;
           sw           : IN  UNSIGNED    (N_SWITCHES-1 downto 0)
           );
end enable_generator;

architecture Behavioral of enable_generator is

   	---------------------------- SIGNALS --------------------------------
    signal count_sw    : UNSIGNED(N_SWITCHES-1 downto 0) := (Others => '0');
    signal count_t0    : INTEGER range 0 to T0 := 0;
    signal enable      : STD_LOGIC := '0';          -- Initialized to '0'
	---------------------------------------------------------------------
    
begin
    ---------------------------- DATA FLOW ------------------------------
    clk_enable <= enable;
    ---------------------------------------------------------------------
    
    ---------------------------- PROCESS --------------------------------
    Counter: process(clk, res)
    begin
        ----- Async Reset --------
        if res = '1' then
            count_sw <= (Others => '0'); 
            count_t0 <= 0;
                
        ----- Sync Process --------
            
        -- The external 'if' is true just one time every T0 clock rising edges
        -- The internal 'if' is true just one time every SW*T0 clock rising edges
        
        elsif rising_edge(clk)  then
            count_t0 <= count_t0 +1;
            if ( count_t0 = T0-1 ) then             
                count_t0 <= 0;
                if ( count_sw >= sw ) then
                     enable <= '1';
                     count_sw  <= ( others => '0');
                else 
                     count_sw <= count_sw + 1;
                     enable <='0';
                end if;
            else
                enable <= '0';
            end if;
        end if;

    end process;	    
    ---------------------------------------------------------------------

end Behavioral;
