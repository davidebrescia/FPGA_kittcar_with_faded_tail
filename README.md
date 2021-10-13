# A very low-utilization Faded KittCar


## What is the "Faded KittCar"?  
It's a particular effect on the LEDs, shown in the gif:

![ezgif-1-b595d79fd17a](https://user-images.githubusercontent.com/92381157/137212284-da792547-5158-4a64-a4ed-4018f0796a4b.gif)  


(The white color means LED off).   
There is a 'leader' light (the one 100% red) that slides along a number equal to 'N_LEDS' of LEDs (= 6 in the gif). There's also a tail, with 'TAIL' length (= 3 in the gif). The sliding speed is set real-time by the user through 'N_SWITCHES' mechanical switches.


The user may want to modify these parameters through the Generics:  
- NUMBER_OF_LEDS
- N_SWITCHES
- TAIL
- T0  
  
What's T0?  
First, we define T as the N° of clock cycles to wait for leds movement.  
T = T0 * (sw + 1)    
T0 is the desired T when sw = 0.

## Challenge
Synthesizing a FPGA firmware that performs the Faded KittCar task, obtaining the lowest utilization in terms of LUTs and FFs.

## Solution
4 modules, designed with a 'Dataflow Modeling' style.  
To see the details, please look at each VHDL module (of course, they are commented).  
Just to make the life easier, here's the schematic of 'controller.vhd':  

![controller_schematic](https://user-images.githubusercontent.com/92381157/137215879-ea764a5d-5e8c-4b94-87a9-695001fdda48.jpg)


## Utilization
On a Digilent Basys 3, with N_LEDS = N_SWITCHES = 16, TAIL = 4, T0 = 1000.   
LUTs: 69  
FFs: 102  


 
