library IEEE;
use IEEE.std_logic_1164.all;

ENTITY Shadow IS
    PORT (
        Shad : IN std_logic;
        input: IN std_logic_vector (15 DOWNTO 0);
        output: OUT std_logic_vector (3 DOWNTO 0)
    );
END Shadow;

ARCHITECTURE Shadow_ARCH OF Shadow IS BEGIN
  output <= 
            input(11 downto 8) when shad = '0' else
            input(3 downto 0) when shad = '1';
END Shadow_ARCH;
