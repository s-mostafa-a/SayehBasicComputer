library IEEE;

use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
ENTITY Sayeh IS
    PORT (
        External_reset: IN STD_LOGIC;
        portDataready:IN std_logic;
        memDataReady : IN std_logic;
        dataBusForMem: inout std_logic_vector(15 downto 0);
        addressout: out std_logic_vector(15 downto 0);
        clk : IN std_logic;
        readMem, writeMem: OUT std_logic;
        readport, writeport: OUT std_logic
    );
END Sayeh;

ARCHITECTURE Sayeh_ARCH OF Sayeh IS 
component controller is
PORT (
        portdataready: in std_logic;
        Readport: out std_logic;
        Writeport: out std_logic;
        --for memory
        memDataReady: in std_logic;
        Readmem: out std_logic;
        Writemem: out std_logic;
        --for controller
        External_reset: in std_logic;
        IRout: in std_logic_vector (15 DOWNTO 0);
        Cout: in std_logic;
        Zout: in std_logic;
        --for alu
        B15to0: out std_logic;
        AandB: out std_logic;
        AorB: out std_logic;
        NotB: out std_logic;
        AaddB: out std_logic;
        AsubB: out std_logic;
        AcmpB: out std_logic;
        BShr: out std_logic;
        BShl: out std_logic;
        Btws : out std_logic;
        AmulB : out std_logic;
	      AdivB : out std_logic;
	      Bsquar : out std_logic;
        sinB : out std_logic;
	      cosB : out std_logic;
	      tanB : out std_logic;
	      cotB : out std_logic;
	      RND : out std_logic;
        ALU_On_DataBus: out std_logic;
        --flags
        Cset,Creset,Zset,Zreset,SRload: out std_logic;
        --register file
        rflwrite,rfhwrite,Rd_On_Addressbus,Rs_On_Addressbus: out std_logic;
        --address unit
        resetPC,PCPlusOne,PCPlusI,RPlusI,RPlusZero,PCEnable : out std_logic;
        Address_On_Bus: out std_logic;
        --wp
        wpadd,wpreset: out std_logic;
        --IR
        IRload: out std_logic;
        --shadow
        shad: out std_logic;
        --clock
        clk : IN std_logic
    );
  end component;
  

  component DataPath IS
    PORT (
        DataBus : inout  std_logic_vector(15 downto 0);
        --for controller
        IRout: out std_logic_vector (15 DOWNTO 0);
        Cout: out std_logic;
        Zout: out std_logic;
        --for alu
        B15to0: in std_logic;
        AandB: in std_logic;
        AorB: in std_logic;
        NotB: in std_logic;
        AaddB: in std_logic;
        AsubB: in std_logic;
        AcmpB: in std_logic;
        BShr: in std_logic;
        BShl: in std_logic;
        Btws : in std_logic;
        AmulB : in std_logic;
	      AdivB : in std_logic;
	      Bsquar : in std_logic;
	      sinB : in std_logic;
	      cosB : in std_logic;
	      tanB : in std_logic;
	      cotB : in std_logic;
	      RND : in std_logic;
        ALU_On_DataBus: in std_logic;
        --flags
        Cset,Creset,Zset,Zreset,SRload: in std_logic;
        --register file
        rflwrite,rfhwrite,Rd_On_Addressbus,Rs_On_Addressbus: in std_logic;
        --address unit
        resetPC,PCPlusOne,PCPlusI,RPlusI,RPlusZero,EnablePC : in std_logic;
        auoutput: OUT std_logic_vector (15 DOWNTO 0);
        Address_On_Bus: in std_logic;
        --wp
        wpadd,wpreset: in std_logic;
        --IR
        IRload: in std_logic;
        --shadow
        shad: in std_logic;
        --clock
        clk : IN std_logic
    );
END component;



signal IRout: std_logic_vector (15 DOWNTO 0);
signal Cout: std_logic;
signal Zout: std_logic;
signal B15to0: std_logic;
signal AandB: std_logic;
signal AorB: std_logic;
signal NotB: std_logic;
signal AaddB: std_logic;
signal AsubB: std_logic;
signal AcmpB: std_logic;
signal BShr: std_logic;
signal BShl: std_logic;
signal Btws : std_logic;
signal AmulB,AdivB,Bsquar,sinB,cosB,tanB,cotB,RND: std_logic;
signal ALU_On_DataBus: std_logic;
signal Cset,Creset,Zset,Zreset,SRload: std_logic;
signal rflwrite,rfhwrite,Rd_On_Addressbus,Rs_On_Addressbus: std_logic;
signal resetPC,PCPlusOne,PCPlusI,RPlusI,RPlusZero,EnablePC : std_logic;
signal auoutput: std_logic_vector (15 DOWNTO 0);
signal Address_On_Bus: std_logic;
signal wpadd,wpreset: std_logic;
signal IRload: std_logic;
signal shad: std_logic;



BEGIN
  
  myDataPath: DataPath port map (
        dataBusForMem,
        --for controller
        IRout,
        Cout,
        Zout,
        --for alu
        B15to0,
        AandB,
        AorB,
        NotB,
        AaddB,
        AsubB,
        AcmpB,
        BShr,
        BShl,
        Btws ,
        AmulB,-- ozi
        AdivB ,-- ozi
        Bsquar ,-- ozi
	      sinB ,-- ozi
	      cosB ,-- ozi
	      tanB ,-- ozi
	      cotB ,-- ozi
	      RND, -- ozi
        ALU_On_DataBus,
        --flags
        Cset,Creset,Zset,Zreset,SRload,
        --register file
        rflwrite,rfhwrite,Rd_On_Addressbus,Rs_On_Addressbus,
        --address unit
        resetPC,PCPlusOne,PCPlusI,RPlusI,RPlusZero,EnablePC,
        auoutput,
        Address_On_Bus,
        --wp
        wpadd,wpreset,
        --IR
        IRload,
        --shadow
        shad,
        --clock
        clk
  );
  
  mycontroller: Controller PORT MAP (
        portDataReady,
        Readport,
        Writeport,
        --for memory
        memDataReady,
        Readmem,
        Writemem,
        --for controller
        External_reset,
        IRout,
        Cout,
        Zout,
        --for alu
        B15to0,
        AandB,
        AorB,
        NotB,
        AaddB,
        AsubB,
        AcmpB,
        BShr,
        BShl,
        Btws ,
        AmulB,-- ozi
	      AdivB ,-- ozi
       	Bsquar ,-- ozi
	      sinB ,-- ozi
       	cosB ,-- ozi
	      tanB ,-- ozi
	      cotB ,-- ozi
	      RND, -- ozi
        ALU_On_DataBus,
        --flags
        Cset,Creset,Zset,Zreset,SRload,
        --register file
        rflwrite,rfhwrite,Rd_On_Addressbus,Rs_On_Addressbus,
        --address unit
        resetPC,PCPlusOne,PCPlusI,RPlusI,RPlusZero,EnablePC ,
        Address_On_Bus,
        --wp
        wpadd,wpreset,
        --IR
        IRload,
        --shadow
        shad,
        --clock
        clk 
    );
    addressout <= auoutput;
End Sayeh_Arch;