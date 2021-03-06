library IEEE;

use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
ENTITY AddressUnit IS
    PORT (
        resetPC,PCPlusone,PCPlusI,RPlusI,RPluszero,EnablePC : IN std_logic;
        ISide: IN std_logic_vector (15 DOWNTO 0);
        RSide: IN std_logic_vector (15 DOWNTO 0);
        clk : IN std_logic;
        Address: OUT std_logic_vector (15 DOWNTO 0)
    );
END AddressUnit;

ARCHITECTURE ADDRESS_UNIT_ARCH OF ADDRESSUNIT IS
	COMPONENT PC is
		PORT (
	        EnablePC : IN std_logic;
	        input: IN std_logic_vector (15 DOWNTO 0);
	        clk : IN std_logic;
	        output: OUT std_logic_vector (15 DOWNTO 0)
	    );
    END COMPONENT;
    COMPONENT ADDRESSLOGIC is
    	PORT (
        resetPC,PCPlus1,PCPlusI,RPlusI,RPlus0 : IN std_logic;
        ISide: IN std_logic_vector (15 DOWNTO 0);
        RSide: IN std_logic_vector (15 DOWNTO 0);
        PCSide: IN std_logic_vector (15 DOWNTO 0);
        Alout: OUT std_logic_vector (15 DOWNTO 0)
    );
    END COMPONENT;
    SIGNAL pcout : std_logic_vector (15 DOWNTO 0);
    SIGNAL AddressSignal : std_logic_vector (15 DOWNTO 0);
BEGIN
    Address <= AddressSignal;
    l1 : PC PORT MAP (EnablePC, AddressSignal, clk, pcout);
    l2 : ADDRESSLOGIC PORT MAP
        (ResetPC, PCplusone, PCplusI, RplusI, Rpluszero, Iside,Rside,pcout,AddressSignal
        );
END ADDRESS_UNIT_ARCH;