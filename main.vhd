library IEEE;

use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
ENTITY main IS
    PORT (
        External_reset: IN STD_LOGIC;
        clk : IN std_logic
    );
END main;

architecture main_arch of main is
  component  Sayeh IS
    PORT (
        External_reset: IN STD_LOGIC;
        portDataReady : IN std_logic;
        memDataReady : IN std_logic;
        dataBusForMem: inout std_logic_vector(15 downto 0);
        addressout: out std_logic_vector(15 downto 0);
        clk : IN std_logic;
        readMem, writeMem: OUT std_logic;
        readport, writeport: OUT std_logic
    );
END component;
component memory is
  port (clk, readmem, writemem : in std_logic;
    addressbus: in std_logic_vector (15 downto 0);
    databus : inout std_logic_vector (15 downto 0);
    memdataready : out std_logic);
end component;

component portmanager is
  port (clk, readport, writeport : in std_logic;
    addressbus: in std_logic_vector (15 downto 0);
    databus : inout std_logic_vector (15 downto 0);
    portdataready : out std_logic);
end component;



signal address, data: std_logic_vector (15 downto 0);
signal readmem, writemem,memdataready,readport, writeport,portdataready: std_logic;
begin
  mySayeh: Sayeh port map (
        External_reset,
        portDataReady ,
        memDataReady ,
        data,
        address,
        clk,
        readMem, writeMem,readPort,writePort
    );
  mymem: memory port map (clk, readmem, writemem,
    address,
    data,
    memdataready);
 myPortManager: portmanager port map (clk, readPort, writePort,
    address,
    data,
    portDataReady);
end main_arch;