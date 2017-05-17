library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity portManager is
  generic (blocksize : integer := 16);

  port (clk, readport, writeport : in std_logic;
    addressbus: in std_logic_vector (15 downto 0);
    databus : inout std_logic_vector (15 downto 0);
    portdataready : out std_logic := '0');
end entity portmanager;

architecture behavioral of portmanager is
  type mem is array (0 to blocksize - 1) of std_logic_vector (15 downto 0);
begin
  process (clk)
    variable buffermem : mem := (others => (others => '0'));
    variable ad : integer;
    variable init : boolean := true;
    
    
    
  begin
--    buffermem(0) := "ZZZZZZZZ00000000";
--    buffermem(0) := "0000001000000011";
  --  buffermem(0) := "0110000101110001";
  --  buffermem(1) := "1000000110010001";
  --  buffermem(2) := "1010000110110001";
  --  buffermem(3) := "1100000101101001";
  --  buffermem(4) := "1110000100000001";
    buffermem(0) := "0000111101010001";
    buffermem(1) := "0000000100111000";
    buffermem(2) := "1111000100111000";
    buffermem(3) := "1111010100101010";
    buffermem(4) := "1111010100101010";
    buffermem(5) := "1100000100000001";
--    if init = true then
--      ? some initiation
--      buffermem(0) := "0000000000000000";
--      init := false;
--    end if;


--   memdataready <= '0';

    if  clk'event and clk = '1' then
      ad := to_integer(unsigned(addressbus));

      if readport = '1' then -- Readiing :)
        portdataready <= '1';
        if ad >= blocksize then
          databus <= (others => 'Z');
        else
          databus <= buffermem(ad);
        end if;
      else
        databus <= (others => 'Z');
      end if;
      if writeport = '1' then -- Writing :)
        portdataready <= '1';
        if ad < blocksize then
          buffermem(ad) := databus;
        end if;      
      end if;
    end if;
  end process;
end architecture behavioral;
