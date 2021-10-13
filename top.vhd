
-- Davide Brescia, Lorenzo Giancristofaro, Simone Polge

------- Default library --------
library IEEE;
	use IEEE.STD_LOGIC_1164.all;
	use IEEE.NUMERIC_STD.ALL;
--------------------------------


entity top is
    Generic(
        -- N° of LEDs 
        N_LEDS      : INTEGER := 16;   
        -- N° of switches 
        N_SWITCHES  : INTEGER := 16;
        -- N° of clock cycles for each 'time' unit. 
        -- What is T0, exactly? T = T0 * (sw + 1), where T is the N° of clock cycles to wait for leds movement. 
        -- T0 is the desired T when sw = 0.
        T0          : INTEGER := 1000;  
        -- Tail length, number of leds ON. (TAIL = 1 means only 1 led ON) 
        TAIL        : INTEGER := 4
    );
    Port(
        --------Global-------
        clk : IN STD_LOGIC;
        res : IN STD_LOGIC;
		
        ---------I/O---------
        sw  : IN    UNSIGNED(N_SWITCHES-1 downto 0);
        led : OUT   STD_LOGIC_VECTOR(N_LEDS-1 downto 0)
    );
end top;

architecture Behavioral of top is
		
    -- Please open RTL elaborated design to have a clear view of links between entities 
    
	--------------------- Components declarations -------------------- 
	 
    component kittcar is
        Generic(
            -- N° of LEDs
            N_LEDS      : INTEGER;       
            -- Initial position of the brightest LED
            INIT_POS    : INTEGER        
        );
        Port( 
            ---------Global---------
            clk         : IN STD_LOGIC;
            res         : IN STD_LOGIC;
            clk_enable  : IN STD_LOGIC;
            ---------I/O------------
            kittcar_out : OUT STD_LOGIC_VECTOR(N_LEDS-1 downto 0)
        );
    end component;
    
    
    component pwm_multiout is
        Generic(
            -- Tail length 
            TAIL : INTEGER
        );
        Port(
            ---------Global---------
            clk : IN STD_LOGIC;
            res : IN STD_LOGIC;
            ---------I/O---------
            pwm : OUT STD_LOGIC_VECTOR(TAIL-1 downto 0)
        );
    end component;
    
    
    component controller is
        Generic(
            -- N° of LEDs
            N_LEDS  : INTEGER;
            -- Tail length 
            TAIL    : INTEGER
        );
        Port(
            ---------Global---------
            clk             : IN STD_LOGIC;
            res             : IN STD_LOGIC;
            clk_enable      : IN std_logic;
            ---------I/O---------
            kittcar_in      : IN  STD_LOGIC_VECTOR (N_LEDS-1 downto 0);
            pwm             : IN  STD_LOGIC_VECTOR (TAIL-1 downto 0);
            led             : OUT STD_LOGIC_VECTOR (N_LEDS-1 downto 0)
        );
    end component;
        
    component enable_generator is
    Generic(      
            -- N° of switches
            N_SWITCHES  : INTEGER;       
            -- N° of clock cycles for each 'time' unit
            T0          : INTEGER       
        );
    Port ( 
           ---------Global---------
           clk : IN STD_LOGIC;
           res : IN STD_LOGIC;
           ---------I/O---------
           clk_enable   : OUT STD_LOGIC;
           sw           : IN  UNSIGNED    (N_SWITCHES-1 downto 0)
           );
    end component;
    -----------------------------------------------------------------
    
	
	---------------------------- SIGNALS ----------------------------
    signal clk_enable     : STD_LOGIC;
    signal kittcar_signal : STD_LOGIC_VECTOR (N_LEDS-1 downto 0);
    signal pwm            : STD_LOGIC_VECTOR (TAIL-1   downto 0);
    -----------------------------------------------------------------
begin

	--------------------- Components instantiations -------------------
    
	enable_generator0 :  enable_generator
	   Generic Map(
            N_SWITCHES => N_SWITCHES,
            T0         => T0
       )
       Port Map(
            clk        => clk,
            res        => res,
            clk_enable => clk_enable,
            sw         => sw
       );    	
    
    kittcar0: kittcar
        Generic Map(
            N_LEDS      => N_LEDS,
            INIT_POS    => 0
        )
        Port Map( 
            clk         => clk,
            res         => res,
            clk_enable  => clk_enable, 
            kittcar_out => kittcar_signal        
        );
   
    -- If TAIL > 1: user wants the shaded tail. The components inside this label would generate problems if instantiated with TAIL = 1
    tailed_kittcar_pwm:  
        if TAIL > 1 generate 
                
            pwm0: pwm_multiout
                Generic Map(
                    TAIL => TAIL
                )
                Port Map(
                    clk => clk,
                    res => res,
                    pwm => pwm
                );
                
            controller0: controller
                Generic Map(
                    N_LEDS => N_LEDS,
                    TAIL   => TAIL
                )
                Port Map(
                    clk         => clk,
                    res         => res,
                    clk_enable  => clk_enable,
                    kittcar_in  => kittcar_signal,
                    pwm         => pwm,
                    led         => led
                );
            
        end generate;        
        
    -------------------------------------------------------------
    
    ------------------------- Data flow -------------------------
    
    simple_kittcar:  -- If TAIL = 1: user wants the simple KittCar effect. It is not necessary to generate a pwm signal and match it to leds through the controller block
    
        if TAIL = 1 generate 
        
            led <= kittcar_signal;
            
        end generate;  
        
    -------------------------------------------------------------
    
end Behavioral;
