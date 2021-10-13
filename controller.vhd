-----------------------------------------------------------------------------------------------
-- This module generates the final desired leds behavior.
-- It 'unifies' the outputs of one kittcar module and one pwm_multiout module.
-----------------------------------------------------------------------------------------------
-- The modeling style is mixed. 
-- The design has been developped at logic gates level in order to minimize the number of
-- components in synthesis.
-- 
-- Please look at "controller_schematic.jpg" to see our idea.
--
-- Consideration:
-- As in pwm_multiout, using a shift register is the best choice if TAIL isn't too large, like 
-- the value that can presumably assume in our Basys 3 board. With a large TAIL, it would have
-- been better using counters, one for each led.
-- Indeed, with a shift reg the number of flipflops increase linearly with TAIL, 
-- with a counter instead the growth is logarithmic but there are much more support LUTS.
-- We benchmarked these two designs (with 'Report Utilization') and we saw that:
-- for TAIL = 4 
-- 'shift reg' solution: 69 LUTS and 102 FFs  | 'counters' solution: 117 LUTS, 124 FFs
-- for TAIL = 16
-- 'shift reg' solution: 154 LUTS and 283 FFs | 'counters' solution: 191 LUTS, 158 FFs
-- These datas refer to the synthesis of the WHOLE project, not the synth of just this module;
-- they refer also to N_LEDS = N_SWITCHES = 16, T0 = 1000.
-----------------------------------------------------------------------------------------------


------- Default library --------
library IEEE;
	use IEEE.STD_LOGIC_1164.all;
	use IEEE.NUMERIC_STD.ALL;
--------------------------------


entity controller is   
    Generic(
            -- Number of LEDs
            N_LEDS  : INTEGER;
            -- Tail length. (TAIL = 1 means only 1 led ON, simple KittCar effect)
            TAIL    : INTEGER
        );
        Port(
            ---------Global---------
            clk : IN STD_LOGIC;
            res : IN STD_LOGIC;
            clk_enable : IN std_logic;
            ---------I/O---------
            kittcar_in : IN  STD_LOGIC_VECTOR (N_LEDS-1 downto 0);
            pwm        : IN  STD_LOGIC_VECTOR (TAIL-1 downto 0);
            led        : OUT STD_LOGIC_VECTOR (N_LEDS-1 downto 0)
        );
end controller;


architecture Mixed of controller is
    
	------------------------ Types declaration ----------------------
    type TYPE_MATRIX    is array( natural RANGE <> ) of STD_LOGIC_VECTOR(N_LEDS-1 downto 0);
    -----------------------------------------------------------------
    
	---------------------------- Signals ----------------------------
    signal NET : TYPE_MATRIX(0 to TAIL-1)   := (Others => (Others => '0'));
    signal MEM : TYPE_MATRIX(0 to TAIL-2)   := (Others => (Others => '0'));
    -----------------------------------------------------------------
 
begin     

    -- Please see 'controller schematic.jpg'
    
    ---------------------------- Data flow --------------------------
    
    -- NET is the logic AND between PWM_MULTIOUT output and data (MEM), stored inside the shift register of this entity 
    and_gates_1:
        for J in N_LEDS-1 downto 0 generate
            rows: 
            for I in 0 to TAIL-2 generate
                NET(I)(J) <= MEM(I)(J) and pwm(I);
            end generate;
    end generate;
    
    -- First 'column' of NET is assigned separately to reduce the flip flops by a number = N_LEDS
    and_gates_2:   
        for J in N_LEDS-1 downto 0 generate
            NET(TAIL-1)(J) <= kittcar_in(J) and pwm(TAIL-1);    
    end generate;
    
    -- LED is the logic OR between all NETs of the same line 
	or_gates:
    for J in N_LEDS-1 downto 0 generate 
        combinational_process:  -- behavioral of an OR with N_TAIL inputs
        process(NET)
            variable temp : std_logic;
        begin
            temp := '0';
            for I in 0 to TAIL-1 loop
                temp := temp or NET(I)(J);
            end loop;
            led(J) <= temp; 
        end process;
    end generate;	
    
	--------------------------------------------------------------------
	
	
    ----------------------------- Process ------------------------------
    
    shift_register: process( clk, res, clk_enable )   -- N_LED shift registers with N_TAIL-1 depth 
    begin
        ------- Async reset --------
        if res = '1' then
            MEM <= (Others => (Others => '0'));   
        ------ Sync process --------
        elsif rising_edge(clk) and clk_enable = '1' then    
            MEM <= MEM(1 to TAIL-2) & kittcar_in;     -- Push in 
        end if;
    end process;	
    
	--------------------------------------------------------------------
    
end Mixed;
