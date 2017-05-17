library IEEE;

use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
ENTITY WP IS
    PORT (
        WPadd,WPreset : IN std_logic;
        input: IN std_logic_vector (15 DOWNTO 0);
        clk : IN std_logic;
        output: OUT std_logic_vector (5 DOWNTO 0)
    );
END WP;

ARCHITECTURE WP_ARCH OF WP IS 
signal value: std_logic_vector(5 downto 0);
BEGIN
  output <= value;
    PROCESS (clk) BEGIN
        IF (clk = '1') THEN
            IF (WPreset = '1') THEN
                value <= "000000";
            END IF;
            IF (WPadd = '1') THEN
                value <= std_logic_vector(unsigned(value) + unsigned(input(5 downto 0)));
            END IF;
        END IF;
    END PROCESS;
END WP_ARCH;