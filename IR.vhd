library IEEE;

use IEEE.std_logic_1164.all;

ENTITY IR IS
    PORT (
        IRLoad : IN std_logic;
        input: IN std_logic_vector (15 DOWNTO 0);
        clk : IN std_logic;
        output: OUT std_logic_vector (15 DOWNTO 0)
    );
END IR;

ARCHITECTURE IR_ARCH OF IR IS BEGIN
    PROCESS (clk) BEGIN
        IF (clk = '1') THEN
            IF (IRLoad = '1') THEN
                output <= input;
            END IF;
        END IF;
    END PROCESS;
END IR_ARCH;