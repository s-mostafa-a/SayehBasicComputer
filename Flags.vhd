library IEEE;

use IEEE.std_logic_1164.all;
ENTITY Flags IS
    PORT (
        Cset,Creset,Zset,Zreset,SRload,ZinfromALU,CinfromALU : IN std_logic;
        clk : IN std_logic;
        CouttoALU,ZouttoALU: OUT std_logic
    );
END Flags;

ARCHITECTURE Flags_ARCH OF Flags IS 
signal C,Z: std_logic;
BEGIN
  CouttoALU <= C;
  ZouttoALU <= Z;
    PROCESS (clk) BEGIN
        IF (clk = '1') THEN
            if(Cset = '1') then
              C <= '1';
            elsif(Creset = '1') then
              C <= '0';
            elsif(Zset = '1') then
              Z <= '1';
            elsif(Zreset = '1') then
              Z <= '0';
            elsif(SRload = '1') then
            C<=CinfromALU;
            Z<=ZinfromALU;
          end if;
        END IF;
    END PROCESS;
END Flags_ARCH;