library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
ENTITY RegisterFile IS
    PORT (
        rflwrite, rfhwrite: IN std_logic;
        wpin: IN std_logic_vector (5 DOWNTO 0);
        shadowin: IN std_logic_vector (3 DOWNTO 0);
        input: IN std_logic_vector (15 DOWNTO 0);
        clk : IN std_logic;
        RD,RS: OUT std_logic_vector (15 DOWNTO 0)
    );
END RegisterFile;
architecture rf of RegisterFile is
type registers is array(0 to 63) of std_logic_vector(15 downto 0);
signal mem : registers := ((others => (others => '0')));
signal srd,srs: std_logic_vector(15 downto 0);
signal ir0,ir1,ir2,ir3,irs,ird: integer := 0;
begin
  rd <= srd;
  rs <= srs;
  ir0 <= to_integer(unsigned(wpin));
  ir1 <= (to_integer(unsigned(wpin) + 1));
  ir2 <= (to_integer(unsigned(wpin) + 2));
  ir3 <= (to_integer(unsigned(wpin) + 3));
        --selecting registers
        --2 raghame chap -> rd, 2 raghame rast -> rs
      ird <= ir0 when shadowin(3 downto 2) = "00" else
             ir1 when shadowin(3 downto 2) = "01" else
             ir2 when shadowin(3 downto 2) = "10" else
             ir3 when shadowin(3 downto 2) = "11" ;
      irs <= ir0 when shadowin(1 downto 0) = "00" else
             ir1 when shadowin(1 downto 0) = "01" else
             ir2 when shadowin(1 downto 0) = "10" else
             ir3 when shadowin(1 downto 0) = "11" ;
  process(clk)
    begin
    if(clk = '1') then
      -- write
    if (rflwrite = '1') and (rfhwrite='1') then
        mem(ird) <= input;
    elsif (rflwrite = '1') then
        mem(ird) <= mem(ird)(15 downto 8)&input(7 downto 0);
    elsif (rfhwrite = '1') then
        mem(ird) <= input(7 downto 0)&mem(ird)(7 downto 0);
    end if;
    srd <= mem(ird);
    srs <= mem(irs);
    end if;
    end process;
end rf;