library IEEE;
use IEEE.std_logic_1164.all;

ENTITY DataPath IS
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
END DataPath;

ARCHITECTURE dp_arch OF DataPath IS 
  component ALU IS PORT (
  clk : in std_logic;	
	A : in std_logic_vector(15 downto 0);
	B : in std_logic_vector(15 downto 0);
	output : out std_logic_vector (15 downto 0);
	ALU_Cin : in std_logic;
	ALU_Zin : in std_logic;
	ALU_Cout : out std_logic;
	ALU_Zout : out std_logic;
	B15to0 : in std_logic;
	AandB : in std_logic;
	AorB : in std_logic;
	Bshl : in std_logic;
 	Bshr : in std_logic;
	AcmpB : in std_logic;
	AaddB : in std_logic;
	AsubB : in std_logic;
	Btws : in std_logic;
	AnotB : in std_logic;
	AmulB : in std_logic;
	AdivB : in std_logic;
	Bsquar : in std_logic;
	sinB : in std_logic;
	cosB : in std_logic;
	tanB : in std_logic;
	cotB : in std_logic;
	RND : in std_logic);
END component;
component Flags IS
    PORT (
        Cset,Creset,Zset,Zreset,SRload,ZinfromALU,CinfromALU : IN std_logic;
        clk : IN std_logic;
        CouttoALU,ZouttoALU: OUT std_logic
    );
END component;
component RegisterFile IS
    PORT (
        rflwrite, rfhwrite: IN std_logic;
        wpin: IN std_logic_vector (5 DOWNTO 0);
        shadowin: IN std_logic_vector (3 DOWNTO 0);
        input: IN std_logic_vector (15 DOWNTO 0);
        clk : IN std_logic;
        RD,RS: OUT std_logic_vector (15 DOWNTO 0)
    );
end component;
component AddressUnit IS
    PORT (
        resetPC,PCPlusone,PCPlusI,RPlusI,RPlusZero,EnablePC : IN std_logic;
        ISide: IN std_logic_vector (15 DOWNTO 0);
        RSide: IN std_logic_vector (15 DOWNTO 0);
        clk : IN std_logic;
        Address: OUT std_logic_vector (15 DOWNTO 0)
    );
END component;
component IR IS
    PORT (
        IRLoad : IN std_logic;
        input: IN std_logic_vector (15 DOWNTO 0);
        clk : IN std_logic;
        output: OUT std_logic_vector (15 DOWNTO 0)
    );
end component;
component WP IS
    PORT (
        WPadd,WPreset : IN std_logic;
        input: IN std_logic_vector (15 DOWNTO 0);
        clk : IN std_logic;
        output: OUT std_logic_vector (5 DOWNTO 0)
    );
end component;
component Shadow IS
    PORT (
        Shad : IN std_logic;
        input: IN std_logic_vector (15 DOWNTO 0);
        output: OUT std_logic_vector (3 DOWNTO 0)
    );
end component;
signal SRS,SRD,ALUOut,RSide,ISide,outputofAddressunit: std_logic_vector(15 downto 0);
signal ALU_Cin, ALU_Cout, ALU_Zin, ALU_Zout: std_logic;
signal wpintoregf: std_logic_vector(5 downto 0);
signal shadowintoregf: std_logic_vector(3 downto 0);
begin
  myalu: ALU port map(clk,	
	SRD, --in 15 to 0
	SRS, --in 15 to 0
  ALUOut, -- out 15 to 0
	ALU_Cin, -- signal ozi
	ALU_Zin, -- signal ozi
	ALU_Cout, -- signal ozi
	ALU_Zout, -- signal ozi
	B15to0, -- ozi
	AandB, -- ozi
	AorB,-- ozi
	Bshl,-- ozi
 	Bshr,-- ozi
	AcmpB,-- ozi
	AaddB,-- ozi
	AsubB,-- ozi
	Btws,-- ozi
	notB,-- ozi
	AmulB,-- ozi
	AdivB ,-- ozi
	Bsquar ,-- ozi
	sinB ,-- ozi
	cosB ,-- ozi
	tanB ,-- ozi
	cotB ,-- ozi
	RND -- ozi
	);
	flg: Flags port map(
        Cset,Creset,Zset,Zreset,SRload,ALU_Zout,ALU_Cout,--ozi
        clk,
        ALU_Cin,ALU_Zin --ozi
    );
	regfile: RegisterFile PORT MAP (
        rflwrite, rfhwrite, -- ozi
        wpintoregf, -- signal ozi
        shadowintoregf, --signal ozi
        DataBus, --ozi
        clk, 
        SRD,SRS --signal ozlari
    );
  AU: AddressUnit PORT MAP (
        resetPC,PCPlusOne,PCPlusI,RPlusI,RPlusZero,EnablePC, -- ozlari
        ISide, --signal ozi with IR
        RSide, --signal ozi
        clk,
        outputofAddressunit --signal ozi
    );
    --------------------------------
    auoutput <= outputofAddressunit;
    --------------------------------
  myIR: IR PORT MAP (
        IRLoad, --ozi
        DataBus, --ozi
        clk,
        ISide --signal ozi with AU
    );
  mywp: WP PORT MAP (
        WPadd,WPreset, --ozi
        ISide, --signal ozi with IR
        clk,
        wpintoregf -- signal ozi with register file
    );
  myshadow: Shadow PORT MAP (
        Shad, --ozi
        ISide, --signal ozi with IR
        shadowintoregf --signal ozi with register file
    );
  DataBus <= outputofAddressunit when Address_On_Bus = '1' else
             "ZZZZZZZZZZZZZZZZ";
  DataBus <= ALUout when ALU_On_DataBus = '1' else
             "ZZZZZZZZZZZZZZZZ";
  RSide <= SRD when Rd_On_Addressbus = '1' else             
             "ZZZZZZZZZZZZZZZZ";
  RSide <= SRS when Rs_On_Addressbus = '1' else             
             "ZZZZZZZZZZZZZZZZ";  
  IRout<=ISide;
  Zout <= ALU_Zin;
  Cout <= ALU_Cin;
end dp_arch;