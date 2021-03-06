
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

ENTITY ALU IS PORT (
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
	Bsquar : in std_logic; --done
	sinB : in std_logic; --done
	cosB : in std_logic; --done
	tanB : in std_logic; --done
	cotB : in std_logic; --done
	RND : in std_logic
	);
END ALU;


ARCHITECTURE dataflow OF ALU IS 
component array_multiplier is
	port(
		x, y : in  std_logic_vector(7 downto 0);
		z    : out std_logic_vector(15 downto 0)
	);
end component;
component array_divider is
	generic(
		N : INTEGER := 16;
		M : INTEGER := 8
	);
	port(
		A : in  std_logic_vector(N - 1 downto 0);
		B : in  std_logic_vector(M - 1 downto 0);
		Q : out std_logic_vector(N - 1 downto 0);
		R : out std_logic_vector(M - 1 downto 0)
	);
end component;
  signal sub : std_logic_vector(16 downto 0);
  signal rnd3,rnd4,rnd5 : std_logic_vector(15 downto 0);
  signal rnd1,rnd2 : std_logic_vector(15 downto 0);
  signal sum : std_logic_vector(16 downto 0);
  signal sc : std_logic_vector(1 downto 0);
	signal Asigned : signed(15 downto 0);
	signal Bsigned : signed(15 downto 0);
	signal output_tmp : std_logic_vector(15 downto 0);
	signal divide : std_logic_vector(15 downto 0);
	signal multiply : std_logic_vector(15 downto 0);
	signal q : std_logic_vector(15 downto 0);
BEGIN
   mymult: array_multiplier port map(A(7 downto 0), B(7 downto 0),multiply);
	 mydiv: array_divider generic map(N => 16, M => 16) port map(A ,B ,divide ,Q );
   sc <= "0"&ALU_cin;
   sum <= std_logic_vector(unsigned("0"&a) + unsigned(b) + unsigned(sc));
   sub <= std_logic_vector(unsigned("0"&a) - unsigned(b) - unsigned(sc));
   rnd1 <= ((A xor B)xor "1000010001001000");
	 rnd2 <= std_logic_vector(unsigned(A) + unsigned(B) + 5216);
	 rnd3 <= rnd1 and rnd2;
	 rnd4 <= rnd2 or rnd1;
	 rnd5 <= rnd3(0) & rnd4(0) & rnd3(15) & rnd4(1) & rnd3(14) & rnd4(2) & rnd3(13) & rnd4(3) & rnd3(12) & rnd4(4) & rnd3(11) & rnd4(5) & rnd3(10) & rnd4(6) & rnd3(9) & rnd4(7) ;
   
   output <= output_tmp;
   Bsigned <= signed(B);
   Asigned <= signed(A); 
  process (clk)
 begin
 if(clk = '1') then
    alu_zout <= '0';
    alu_cout <= '0';
	  if clk'event and clk = '1' then

		-- A and B (tested)                                                            
		if (AandB = '1') then                                                          
		   output_tmp <= (A and B);                                                        
		--------------------

	  	-- shift B to right(tested)
		elsif (Bshr = '1') then
			output_tmp <= '0' &  B(15 downto 1);
		--------------------
	
		-- A not B(tested)
		elsif (AnotB = '1') then
			output_tmp <= not B;
		--------------------

		-- B 15 to 0(tested)
		elsif (B15to0 = '1') then
			output_tmp <= B;
		--------------------

		-- B two's complement (tested)
		elsif (Btws = '1') then
			output_tmp <= std_logic_vector(unsigned(not B) + 1);
		--------------------

		-- A or B (tested)                                                             
		elsif (AorB = '1') then
		  output_tmp <= A or B;
		--------------------
		
		-- shift B to left (tested)
		elsif (Bshl = '1') then 
		  output_tmp <= B(14 downto 0) & '0';
		--------------------
		
		-- compare B and A (tested)
		elsif (AcmpB = '1') then
		  if (A = B) then
		    ALU_Zout <= '1';
		  elsif (Asigned < Bsigned) then
		    ALU_Cout <= '1';
		  end if; 
		---------------------
		
		-- A + B + ALU_Cin with carry out (tested)
		elsif (AaddB = '1') then
		  output_tmp <= sum(15 downto 0);
		  ALU_Cout <= sum(16);
		---------------------
		
		-- A + B two's complement + 1 - cin
		elsif (AsubB = '1') then
		  output_tmp <= sub(15 downto 0);
		  ALU_Cout <= sub(16);
		---------------------/////////////////////////////////////Emtiazi
		
		-- A * B
		elsif (AmulB = '1') then                                           --TODO
		  output_tmp <= multiply;
		---------------------
		
		-- A / B
		elsif (AdivB = '1') then                                           --TODO
		  output_tmp <= divide;
		---------------------
		-- radical B
		elsif (Bsquar = '1') then
		  if B >= "0000000000000000" and B < "0000000000000001" then 

 output_tmp <= "0000000000000000";

elsif B >= "0000000000000001" and B < "0000000000000100" then 

 output_tmp <= "0000000000000001";

elsif B >= "0000000000000100" and B < "0000000000001001" then 

 output_tmp <= "0000000000000010";

elsif B >= "0000000000001001" and B < "0000000000010000" then 

 output_tmp <= "0000000000000011";

elsif B >= "0000000000010000" and B < "0000000000011001" then 

 output_tmp <= "0000000000000100";

elsif B >= "0000000000011001" and B < "0000000000100100" then 

 output_tmp <= "0000000000000101";

elsif B >= "0000000000100100" and B < "0000000000110001" then 

 output_tmp <= "0000000000000110";

elsif B >= "0000000000110001" and B < "0000000001000000" then 

 output_tmp <= "0000000000000111";

elsif B >= "0000000001000000" and B < "0000000001010001" then 

 output_tmp <= "0000000000001000";

elsif B >= "0000000001010001" and B < "0000000001100100" then 

 output_tmp <= "0000000000001001";

elsif B >= "0000000001100100" and B < "0000000001111001" then 

 output_tmp <= "0000000000001010";

elsif B >= "0000000001111001" and B < "0000000010010000" then 

 output_tmp <= "0000000000001011";

elsif B >= "0000000010010000" and B < "0000000010101001" then 

 output_tmp <= "0000000000001100";

elsif B >= "0000000010101001" and B < "0000000011000100" then 

 output_tmp <= "0000000000001101";

elsif B >= "0000000011000100" and B < "0000000011100001" then 

 output_tmp <= "0000000000001110";

elsif B >= "0000000011100001" and B < "0000000100000000" then 

 output_tmp <= "0000000000001111";

elsif B >= "0000000100000000" and B < "0000000100100001" then 

 output_tmp <= "0000000000010000";

elsif B >= "0000000100100001" and B < "0000000101000100" then 

 output_tmp <= "0000000000010001";

elsif B >= "0000000101000100" and B < "0000000101101001" then 

 output_tmp <= "0000000000010010";

elsif B >= "0000000101101001" and B < "0000000110010000" then 

 output_tmp <= "0000000000010011";

elsif B >= "0000000110010000" and B < "0000000110111001" then 

 output_tmp <= "0000000000010100";

elsif B >= "0000000110111001" and B < "0000000111100100" then 

 output_tmp <= "0000000000010101";

elsif B >= "0000000111100100" and B < "0000001000010001" then 

 output_tmp <= "0000000000010110";

elsif B >= "0000001000010001" and B < "0000001001000000" then 

 output_tmp <= "0000000000010111";

elsif B >= "0000001001000000" and B < "0000001001110001" then 

 output_tmp <= "0000000000011000";

elsif B >= "0000001001110001" and B < "0000001010100100" then 

 output_tmp <= "0000000000011001";

elsif B >= "0000001010100100" and B < "0000001011011001" then 

 output_tmp <= "0000000000011010";

elsif B >= "0000001011011001" and B < "0000001100010000" then 

 output_tmp <= "0000000000011011";

elsif B >= "0000001100010000" and B < "0000001101001001" then 

 output_tmp <= "0000000000011100";

elsif B >= "0000001101001001" and B < "0000001110000100" then 

 output_tmp <= "0000000000011101";

elsif B >= "0000001110000100" and B < "0000001111000001" then 

 output_tmp <= "0000000000011110";

elsif B >= "0000001111000001" and B < "0000010000000000" then 

 output_tmp <= "0000000000011111";

elsif B >= "0000010000000000" and B < "0000010001000001" then 

 output_tmp <= "0000000000100000";

elsif B >= "0000010001000001" and B < "0000010010000100" then 

 output_tmp <= "0000000000100001";

elsif B >= "0000010010000100" and B < "0000010011001001" then 

 output_tmp <= "0000000000100010";

elsif B >= "0000010011001001" and B < "0000010100010000" then 

 output_tmp <= "0000000000100011";

elsif B >= "0000010100010000" and B < "0000010101011001" then 

 output_tmp <= "0000000000100100";

elsif B >= "0000010101011001" and B < "0000010110100100" then 

 output_tmp <= "0000000000100101";

elsif B >= "0000010110100100" and B < "0000010111110001" then 

 output_tmp <= "0000000000100110";

elsif B >= "0000010111110001" and B < "0000011001000000" then 

 output_tmp <= "0000000000100111";

elsif B >= "0000011001000000" and B < "0000011010010001" then 

 output_tmp <= "0000000000101000";

elsif B >= "0000011010010001" and B < "0000011011100100" then 

 output_tmp <= "0000000000101001";

elsif B >= "0000011011100100" and B < "0000011100111001" then 

 output_tmp <= "0000000000101010";

elsif B >= "0000011100111001" and B < "0000011110010000" then 

 output_tmp <= "0000000000101011";

elsif B >= "0000011110010000" and B < "0000011111101001" then 

 output_tmp <= "0000000000101100";

elsif B >= "0000011111101001" and B < "0000100001000100" then 

 output_tmp <= "0000000000101101";

elsif B >= "0000100001000100" and B < "0000100010100001" then 

 output_tmp <= "0000000000101110";

elsif B >= "0000100010100001" and B < "0000100100000000" then 

 output_tmp <= "0000000000101111";

elsif B >= "0000100100000000" and B < "0000100101100001" then 

 output_tmp <= "0000000000110000";

elsif B >= "0000100101100001" and B < "0000100111000100" then 

 output_tmp <= "0000000000110001";

elsif B >= "0000100111000100" and B < "0000101000101001" then 

 output_tmp <= "0000000000110010";

elsif B >= "0000101000101001" and B < "0000101010010000" then 

 output_tmp <= "0000000000110011";

elsif B >= "0000101010010000" and B < "0000101011111001" then 

 output_tmp <= "0000000000110100";

elsif B >= "0000101011111001" and B < "0000101101100100" then 

 output_tmp <= "0000000000110101";

elsif B >= "0000101101100100" and B < "0000101111010001" then 

 output_tmp <= "0000000000110110";

elsif B >= "0000101111010001" and B < "0000110001000000" then 

 output_tmp <= "0000000000110111";

elsif B >= "0000110001000000" and B < "0000110010110001" then 

 output_tmp <= "0000000000111000";

elsif B >= "0000110010110001" and B < "0000110100100100" then 

 output_tmp <= "0000000000111001";

elsif B >= "0000110100100100" and B < "0000110110011001" then 

 output_tmp <= "0000000000111010";

elsif B >= "0000110110011001" and B < "0000111000010000" then 

 output_tmp <= "0000000000111011";

elsif B >= "0000111000010000" and B < "0000111010001001" then 

 output_tmp <= "0000000000111100";

elsif B >= "0000111010001001" and B < "0000111100000100" then 

 output_tmp <= "0000000000111101";

elsif B >= "0000111100000100" and B < "0000111110000001" then 

 output_tmp <= "0000000000111110";

elsif B >= "0000111110000001" and B < "0001000000000000" then 

 output_tmp <= "0000000000111111";

elsif B >= "0001000000000000" and B < "0001000010000001" then 

 output_tmp <= "0000000001000000";

elsif B >= "0001000010000001" and B < "0001000100000100" then 

 output_tmp <= "0000000001000001";

elsif B >= "0001000100000100" and B < "0001000110001001" then 

 output_tmp <= "0000000001000010";

elsif B >= "0001000110001001" and B < "0001001000010000" then 

 output_tmp <= "0000000001000011";

elsif B >= "0001001000010000" and B < "0001001010011001" then 

 output_tmp <= "0000000001000100";

elsif B >= "0001001010011001" and B < "0001001100100100" then 

 output_tmp <= "0000000001000101";

elsif B >= "0001001100100100" and B < "0001001110110001" then 

 output_tmp <= "0000000001000110";

elsif B >= "0001001110110001" and B < "0001010001000000" then 

 output_tmp <= "0000000001000111";

elsif B >= "0001010001000000" and B < "0001010011010001" then 

 output_tmp <= "0000000001001000";

elsif B >= "0001010011010001" and B < "0001010101100100" then 

 output_tmp <= "0000000001001001";

elsif B >= "0001010101100100" and B < "0001010111111001" then 

 output_tmp <= "0000000001001010";

elsif B >= "0001010111111001" and B < "0001011010010000" then 

 output_tmp <= "0000000001001011";

elsif B >= "0001011010010000" and B < "0001011100101001" then 

 output_tmp <= "0000000001001100";

elsif B >= "0001011100101001" and B < "0001011111000100" then 

 output_tmp <= "0000000001001101";

elsif B >= "0001011111000100" and B < "0001100001100001" then 

 output_tmp <= "0000000001001110";

elsif B >= "0001100001100001" and B < "0001100100000000" then 

 output_tmp <= "0000000001001111";

elsif B >= "0001100100000000" and B < "0001100110100001" then 

 output_tmp <= "0000000001010000";

elsif B >= "0001100110100001" and B < "0001101001000100" then 

 output_tmp <= "0000000001010001";

elsif B >= "0001101001000100" and B < "0001101011101001" then 

 output_tmp <= "0000000001010010";

elsif B >= "0001101011101001" and B < "0001101110010000" then 

 output_tmp <= "0000000001010011";

elsif B >= "0001101110010000" and B < "0001110000111001" then 

 output_tmp <= "0000000001010100";

elsif B >= "0001110000111001" and B < "0001110011100100" then 

 output_tmp <= "0000000001010101";

elsif B >= "0001110011100100" and B < "0001110110010001" then 

 output_tmp <= "0000000001010110";

elsif B >= "0001110110010001" and B < "0001111001000000" then 

 output_tmp <= "0000000001010111";

elsif B >= "0001111001000000" and B < "0001111011110001" then 

 output_tmp <= "0000000001011000";

elsif B >= "0001111011110001" and B < "0001111110100100" then 

 output_tmp <= "0000000001011001";

elsif B >= "0001111110100100" and B < "0010000001011001" then 

 output_tmp <= "0000000001011010";

elsif B >= "0010000001011001" and B < "0010000100010000" then 

 output_tmp <= "0000000001011011";

elsif B >= "0010000100010000" and B < "0010000111001001" then 

 output_tmp <= "0000000001011100";

elsif B >= "0010000111001001" and B < "0010001010000100" then 

 output_tmp <= "0000000001011101";

elsif B >= "0010001010000100" and B < "0010001101000001" then 

 output_tmp <= "0000000001011110";

elsif B >= "0010001101000001" and B < "0010010000000000" then 

 output_tmp <= "0000000001011111";

elsif B >= "0010010000000000" and B < "0010010011000001" then 

 output_tmp <= "0000000001100000";

elsif B >= "0010010011000001" and B < "0010010110000100" then 

 output_tmp <= "0000000001100001";

elsif B >= "0010010110000100" and B < "0010011001001001" then 

 output_tmp <= "0000000001100010";

elsif B >= "0010011001001001" and B < "0010011100010000" then 

 output_tmp <= "0000000001100011";

elsif B >= "0010011100010000" and B < "0010011111011001" then 

 output_tmp <= "0000000001100100";

elsif B >= "0010011111011001" and B < "0010100010100100" then 

 output_tmp <= "0000000001100101";

elsif B >= "0010100010100100" and B < "0010100101110001" then 

 output_tmp <= "0000000001100110";

elsif B >= "0010100101110001" and B < "0010101001000000" then 

 output_tmp <= "0000000001100111";

elsif B >= "0010101001000000" and B < "0010101100010001" then 

 output_tmp <= "0000000001101000";

elsif B >= "0010101100010001" and B < "0010101111100100" then 

 output_tmp <= "0000000001101001";

elsif B >= "0010101111100100" and B < "0010110010111001" then 

 output_tmp <= "0000000001101010";

elsif B >= "0010110010111001" and B < "0010110110010000" then 

 output_tmp <= "0000000001101011";

elsif B >= "0010110110010000" and B < "0010111001101001" then 

 output_tmp <= "0000000001101100";

elsif B >= "0010111001101001" and B < "0010111101000100" then 

 output_tmp <= "0000000001101101";

elsif B >= "0010111101000100" and B < "0011000000100001" then 

 output_tmp <= "0000000001101110";

elsif B >= "0011000000100001" and B < "0011000100000000" then 

 output_tmp <= "0000000001101111";

elsif B >= "0011000100000000" and B < "0011000111100001" then 

 output_tmp <= "0000000001110000";

elsif B >= "0011000111100001" and B < "0011001011000100" then 

 output_tmp <= "0000000001110001";

elsif B >= "0011001011000100" and B < "0011001110101001" then 

 output_tmp <= "0000000001110010";

elsif B >= "0011001110101001" and B < "0011010010010000" then 

 output_tmp <= "0000000001110011";

elsif B >= "0011010010010000" and B < "0011010101111001" then 

 output_tmp <= "0000000001110100";

elsif B >= "0011010101111001" and B < "0011011001100100" then 

 output_tmp <= "0000000001110101";

elsif B >= "0011011001100100" and B < "0011011101010001" then 

 output_tmp <= "0000000001110110";

elsif B >= "0011011101010001" and B < "0011100001000000" then 

 output_tmp <= "0000000001110111";

elsif B >= "0011100001000000" and B < "0011100100110001" then 

 output_tmp <= "0000000001111000";

elsif B >= "0011100100110001" and B < "0011101000100100" then 

 output_tmp <= "0000000001111001";

elsif B >= "0011101000100100" and B < "0011101100011001" then 

 output_tmp <= "0000000001111010";

elsif B >= "0011101100011001" and B < "0011110000010000" then 

 output_tmp <= "0000000001111011";

elsif B >= "0011110000010000" and B < "0011110100001001" then 

 output_tmp <= "0000000001111100";

elsif B >= "0011110100001001" and B < "0011111000000100" then 

 output_tmp <= "0000000001111101";

elsif B >= "0011111000000100" and B < "0011111100000001" then 

 output_tmp <= "0000000001111110";

elsif B >= "0011111100000001" and B < "0100000000000000" then 

 output_tmp <= "0000000001111111";

elsif B >= "0100000000000000" and B < "0100000100000001" then 

 output_tmp <= "0000000010000000";

elsif B >= "0100000100000001" and B < "0100001000000100" then 

 output_tmp <= "0000000010000001";

elsif B >= "0100001000000100" and B < "0100001100001001" then 

 output_tmp <= "0000000010000010";

elsif B >= "0100001100001001" and B < "0100010000010000" then 

 output_tmp <= "0000000010000011";

elsif B >= "0100010000010000" and B < "0100010100011001" then 

 output_tmp <= "0000000010000100";

elsif B >= "0100010100011001" and B < "0100011000100100" then 

 output_tmp <= "0000000010000101";

elsif B >= "0100011000100100" and B < "0100011100110001" then 

 output_tmp <= "0000000010000110";

elsif B >= "0100011100110001" and B < "0100100001000000" then 

 output_tmp <= "0000000010000111";

elsif B >= "0100100001000000" and B < "0100100101010001" then 

 output_tmp <= "0000000010001000";

elsif B >= "0100100101010001" and B < "0100101001100100" then 

 output_tmp <= "0000000010001001";

elsif B >= "0100101001100100" and B < "0100101101111001" then 

 output_tmp <= "0000000010001010";

elsif B >= "0100101101111001" and B < "0100110010010000" then 

 output_tmp <= "0000000010001011";

elsif B >= "0100110010010000" and B < "0100110110101001" then 

 output_tmp <= "0000000010001100";

elsif B >= "0100110110101001" and B < "0100111011000100" then 

 output_tmp <= "0000000010001101";

elsif B >= "0100111011000100" and B < "0100111111100001" then 

 output_tmp <= "0000000010001110";

elsif B >= "0100111111100001" and B < "0101000100000000" then 

 output_tmp <= "0000000010001111";

elsif B >= "0101000100000000" and B < "0101001000100001" then 

 output_tmp <= "0000000010010000";

elsif B >= "0101001000100001" and B < "0101001101000100" then 

 output_tmp <= "0000000010010001";

elsif B >= "0101001101000100" and B < "0101010001101001" then 

 output_tmp <= "0000000010010010";

elsif B >= "0101010001101001" and B < "0101010110010000" then 

 output_tmp <= "0000000010010011";

elsif B >= "0101010110010000" and B < "0101011010111001" then 

 output_tmp <= "0000000010010100";

elsif B >= "0101011010111001" and B < "0101011111100100" then 

 output_tmp <= "0000000010010101";

elsif B >= "0101011111100100" and B < "0101100100010001" then 

 output_tmp <= "0000000010010110";

elsif B >= "0101100100010001" and B < "0101101001000000" then 

 output_tmp <= "0000000010010111";

elsif B >= "0101101001000000" and B < "0101101101110001" then 

 output_tmp <= "0000000010011000";

elsif B >= "0101101101110001" and B < "0101110010100100" then 

 output_tmp <= "0000000010011001";

elsif B >= "0101110010100100" and B < "0101110111011001" then 

 output_tmp <= "0000000010011010";

elsif B >= "0101110111011001" and B < "0101111100010000" then 

 output_tmp <= "0000000010011011";

elsif B >= "0101111100010000" and B < "0110000001001001" then 

 output_tmp <= "0000000010011100";

elsif B >= "0110000001001001" and B < "0110000110000100" then 

 output_tmp <= "0000000010011101";

elsif B >= "0110000110000100" and B < "0110001011000001" then 

 output_tmp <= "0000000010011110";

elsif B >= "0110001011000001" and B < "0110010000000000" then 

 output_tmp <= "0000000010011111";

elsif B >= "0110010000000000" and B < "0110010101000001" then 

 output_tmp <= "0000000010100000";

elsif B >= "0110010101000001" and B < "0110011010000100" then 

 output_tmp <= "0000000010100001";

elsif B >= "0110011010000100" and B < "0110011111001001" then 

 output_tmp <= "0000000010100010";

elsif B >= "0110011111001001" and B < "0110100100010000" then 

 output_tmp <= "0000000010100011";

elsif B >= "0110100100010000" and B < "0110101001011001" then 

 output_tmp <= "0000000010100100";

elsif B >= "0110101001011001" and B < "0110101110100100" then 

 output_tmp <= "0000000010100101";

elsif B >= "0110101110100100" and B < "0110110011110001" then 

 output_tmp <= "0000000010100110";

elsif B >= "0110110011110001" and B < "0110111001000000" then 

 output_tmp <= "0000000010100111";

elsif B >= "0110111001000000" and B < "0110111110010001" then 

 output_tmp <= "0000000010101000";

elsif B >= "0110111110010001" and B < "0111000011100100" then 

 output_tmp <= "0000000010101001";

elsif B >= "0111000011100100" and B < "0111001000111001" then 

 output_tmp <= "0000000010101010";

elsif B >= "0111001000111001" and B < "0111001110010000" then 

 output_tmp <= "0000000010101011";

elsif B >= "0111001110010000" and B < "0111010011101001" then 

 output_tmp <= "0000000010101100";

elsif B >= "0111010011101001" and B < "0111011001000100" then 

 output_tmp <= "0000000010101101";

elsif B >= "0111011001000100" and B < "0111011110100001" then 

 output_tmp <= "0000000010101110";

elsif B >= "0111011110100001" and B < "0111100100000000" then 

 output_tmp <= "0000000010101111";

elsif B >= "0111100100000000" and B < "0111101001100001" then 

 output_tmp <= "0000000010110000";

elsif B >= "0111101001100001" and B < "0111101111000100" then 

 output_tmp <= "0000000010110001";

elsif B >= "0111101111000100" and B < "0111110100101001" then 

 output_tmp <= "0000000010110010";

elsif B >= "0111110100101001" and B < "0111111010010000" then 

 output_tmp <= "0000000010110011";

elsif B >= "0111111010010000" and B < "0111111111111001" then 

 output_tmp <= "0000000010110100";

elsif B >= "0111111111111001" and B < "1000000000000000" then 

 output_tmp <= "0000000010110101";

else


output_tmp <= "ZZZZZZZZZZZZZZZZ";

end if;
		---------------------
		-- sinus(b)
		elsif (sinB = '1') then
		  if B = "0000000000000000" then 


 output_tmp <= "0000000000000000";

elsif B = "0000000000000001" then 

 output_tmp <= "0000000000000001";

elsif B = "0000000000000010" then 

 output_tmp <= "0000000000000011";

elsif B = "0000000000000011" then 

 output_tmp <= "0000000000000101";

elsif B = "0000000000000100" then 

 output_tmp <= "0000000000000110";

elsif B = "0000000000000101" then 

 output_tmp <= "0000000000001000";

elsif B = "0000000000000110" then 

 output_tmp <= "0000000000001010";

elsif B = "0000000000000111" then 

 output_tmp <= "0000000000001100";

elsif B = "0000000000001000" then 

 output_tmp <= "0000000000001101";

elsif B = "0000000000001001" then 

 output_tmp <= "0000000000001111";

elsif B = "0000000000001010" then 

 output_tmp <= "0000000000010001";

elsif B = "0000000000001011" then 

 output_tmp <= "0000000000010011";

elsif B = "0000000000001100" then 

 output_tmp <= "0000000000010100";

elsif B = "0000000000001101" then 

 output_tmp <= "0000000000010110";

elsif B = "0000000000001110" then 

 output_tmp <= "0000000000011000";

elsif B = "0000000000001111" then 

 output_tmp <= "0000000000011001";

elsif B = "0000000000010000" then 

 output_tmp <= "0000000000011011";

elsif B = "0000000000010001" then 

 output_tmp <= "0000000000011101";

elsif B = "0000000000010010" then 

 output_tmp <= "0000000000011110";

elsif B = "0000000000010011" then 

 output_tmp <= "0000000000100000";

elsif B = "0000000000010100" then 

 output_tmp <= "0000000000100010";

elsif B = "0000000000010101" then 

 output_tmp <= "0000000000100011";

elsif B = "0000000000010110" then 

 output_tmp <= "0000000000100101";

elsif B = "0000000000010111" then 

 output_tmp <= "0000000000100111";

elsif B = "0000000000011000" then 

 output_tmp <= "0000000000101000";

elsif B = "0000000000011001" then 

 output_tmp <= "0000000000101010";

elsif B = "0000000000011010" then 

 output_tmp <= "0000000000101011";

elsif B = "0000000000011011" then 

 output_tmp <= "0000000000101101";

elsif B = "0000000000011100" then 

 output_tmp <= "0000000000101110";

elsif B = "0000000000011101" then 

 output_tmp <= "0000000000110000";

elsif B = "0000000000011110" then 

 output_tmp <= "0000000000110001";

elsif B = "0000000000011111" then 

 output_tmp <= "0000000000110011";

elsif B = "0000000000100000" then 

 output_tmp <= "0000000000110100";

elsif B = "0000000000100001" then 

 output_tmp <= "0000000000110110";

elsif B = "0000000000100010" then 

 output_tmp <= "0000000000110111";

elsif B = "0000000000100011" then 

 output_tmp <= "0000000000111001";

elsif B = "0000000000100100" then 

 output_tmp <= "0000000000111010";

elsif B = "0000000000100101" then 

 output_tmp <= "0000000000111100";

elsif B = "0000000000100110" then 

 output_tmp <= "0000000000111101";

elsif B = "0000000000100111" then 

 output_tmp <= "0000000000111110";

elsif B = "0000000000101000" then 

 output_tmp <= "0000000001000000";

elsif B = "0000000000101001" then 

 output_tmp <= "0000000001000001";

elsif B = "0000000000101010" then 

 output_tmp <= "0000000001000010";

elsif B = "0000000000101011" then 

 output_tmp <= "0000000001000100";

elsif B = "0000000000101100" then 

 output_tmp <= "0000000001000101";

elsif B = "0000000000101101" then 

 output_tmp <= "0000000001000110";

elsif B = "0000000000101110" then 

 output_tmp <= "0000000001000111";

elsif B = "0000000000101111" then 

 output_tmp <= "0000000001001001";

elsif B = "0000000000110000" then 

 output_tmp <= "0000000001001010";

elsif B = "0000000000110001" then 

 output_tmp <= "0000000001001011";

elsif B = "0000000000110010" then 

 output_tmp <= "0000000001001100";

elsif B = "0000000000110011" then 

 output_tmp <= "0000000001001101";

elsif B = "0000000000110100" then 

 output_tmp <= "0000000001001110";

elsif B = "0000000000110101" then 

 output_tmp <= "0000000001001111";

elsif B = "0000000000110110" then 

 output_tmp <= "0000000001010000";

elsif B = "0000000000110111" then 

 output_tmp <= "0000000001010001";

elsif B = "0000000000111000" then 

 output_tmp <= "0000000001010010";

elsif B = "0000000000111001" then 

 output_tmp <= "0000000001010011";

elsif B = "0000000000111010" then 

 output_tmp <= "0000000001010100";

elsif B = "0000000000111011" then 

 output_tmp <= "0000000001010101";

elsif B = "0000000000111100" then 

 output_tmp <= "0000000001010110";

elsif B = "0000000000111101" then 

 output_tmp <= "0000000001010111";

elsif B = "0000000000111110" then 

 output_tmp <= "0000000001011000";

elsif B = "0000000000111111" then 

 output_tmp <= "0000000001011001";

elsif B = "0000000001000000" then 

 output_tmp <= "0000000001011001";

elsif B = "0000000001000001" then 

 output_tmp <= "0000000001011010";

elsif B = "0000000001000010" then 

 output_tmp <= "0000000001011011";

elsif B = "0000000001000011" then 

 output_tmp <= "0000000001011100";

elsif B = "0000000001000100" then 

 output_tmp <= "0000000001011100";

elsif B = "0000000001000101" then 

 output_tmp <= "0000000001011101";

elsif B = "0000000001000110" then 

 output_tmp <= "0000000001011101";

elsif B = "0000000001000111" then 

 output_tmp <= "0000000001011110";

elsif B = "0000000001001000" then 

 output_tmp <= "0000000001011111";

elsif B = "0000000001001001" then 

 output_tmp <= "0000000001011111";

elsif B = "0000000001001010" then 

 output_tmp <= "0000000001100000";

elsif B = "0000000001001011" then 

 output_tmp <= "0000000001100000";

elsif B = "0000000001001100" then 

 output_tmp <= "0000000001100001";

elsif B = "0000000001001101" then 

 output_tmp <= "0000000001100001";

elsif B = "0000000001001110" then 

 output_tmp <= "0000000001100001";

elsif B = "0000000001001111" then 

 output_tmp <= "0000000001100010";

elsif B = "0000000001010000" then 

 output_tmp <= "0000000001100010";

elsif B = "0000000001010001" then 

 output_tmp <= "0000000001100010";

elsif B = "0000000001010010" then 

 output_tmp <= "0000000001100011";

elsif B = "0000000001010011" then 

 output_tmp <= "0000000001100011";

elsif B = "0000000001010100" then 

 output_tmp <= "0000000001100011";

elsif B = "0000000001010101" then 

 output_tmp <= "0000000001100011";

elsif B = "0000000001010110" then 

 output_tmp <= "0000000001100011";

elsif B = "0000000001010111" then 

 output_tmp <= "0000000001100011";

elsif B = "0000000001011000" then 

 output_tmp <= "0000000001100011";

elsif B = "0000000001011001" then 

 output_tmp <= "0000000001100011";

elsif B = "0000000001011010" then 

 output_tmp <= "0000000001100100";

elsif B = "0000000001011011" then 

 output_tmp <= "0000000001100011";

elsif B = "0000000001011100" then 

 output_tmp <= "0000000001100011";

elsif B = "0000000001011101" then 

 output_tmp <= "0000000001100011";

elsif B = "0000000001011110" then 

 output_tmp <= "0000000001100011";

elsif B = "0000000001011111" then 

 output_tmp <= "0000000001100011";

elsif B = "0000000001100000" then 

 output_tmp <= "0000000001100011";

elsif B = "0000000001100001" then 

 output_tmp <= "0000000001100011";

elsif B = "0000000001100010" then 

 output_tmp <= "0000000001100011";

elsif B = "0000000001100011" then 

 output_tmp <= "0000000001100010";

elsif B = "0000000001100100" then 

 output_tmp <= "0000000001100010";

elsif B = "0000000001100101" then 

 output_tmp <= "0000000001100010";

elsif B = "0000000001100110" then 

 output_tmp <= "0000000001100001";

elsif B = "0000000001100111" then 

 output_tmp <= "0000000001100001";

elsif B = "0000000001101000" then 

 output_tmp <= "0000000001100001";

elsif B = "0000000001101001" then 

 output_tmp <= "0000000001100000";

elsif B = "0000000001101010" then 

 output_tmp <= "0000000001100000";

elsif B = "0000000001101011" then 

 output_tmp <= "0000000001011111";

elsif B = "0000000001101100" then 

 output_tmp <= "0000000001011111";

elsif B = "0000000001101101" then 

 output_tmp <= "0000000001011110";

elsif B = "0000000001101110" then 

 output_tmp <= "0000000001011101";

elsif B = "0000000001101111" then 

 output_tmp <= "0000000001011101";

elsif B = "0000000001110000" then 

 output_tmp <= "0000000001011100";

elsif B = "0000000001110001" then 

 output_tmp <= "0000000001011100";

elsif B = "0000000001110010" then 

 output_tmp <= "0000000001011011";

elsif B = "0000000001110011" then 

 output_tmp <= "0000000001011010";

elsif B = "0000000001110100" then 

 output_tmp <= "0000000001011001";

elsif B = "0000000001110101" then 

 output_tmp <= "0000000001011001";

elsif B = "0000000001110110" then 

 output_tmp <= "0000000001011000";

elsif B = "0000000001110111" then 

 output_tmp <= "0000000001010111";

elsif B = "0000000001111000" then 

 output_tmp <= "0000000001010110";

elsif B = "0000000001111001" then 

 output_tmp <= "0000000001010101";

elsif B = "0000000001111010" then 

 output_tmp <= "0000000001010100";

elsif B = "0000000001111011" then 

 output_tmp <= "0000000001010011";

elsif B = "0000000001111100" then 

 output_tmp <= "0000000001010010";

elsif B = "0000000001111101" then 

 output_tmp <= "0000000001010001";

elsif B = "0000000001111110" then 

 output_tmp <= "0000000001010000";

elsif B = "0000000001111111" then 

 output_tmp <= "0000000001001111";

elsif B = "0000000010000000" then 

 output_tmp <= "0000000001001110";

elsif B = "0000000010000001" then 

 output_tmp <= "0000000001001101";

elsif B = "0000000010000010" then 

 output_tmp <= "0000000001001100";

elsif B = "0000000010000011" then 

 output_tmp <= "0000000001001011";

elsif B = "0000000010000100" then 

 output_tmp <= "0000000001001010";

elsif B = "0000000010000101" then 

 output_tmp <= "0000000001001001";

elsif B = "0000000010000110" then 

 output_tmp <= "0000000001000111";

elsif B = "0000000010000111" then 

 output_tmp <= "0000000001000110";

elsif B = "0000000010001000" then 

 output_tmp <= "0000000001000101";

elsif B = "0000000010001001" then 

 output_tmp <= "0000000001000100";

elsif B = "0000000010001010" then 

 output_tmp <= "0000000001000010";

elsif B = "0000000010001011" then 

 output_tmp <= "0000000001000001";

elsif B = "0000000010001100" then 

 output_tmp <= "0000000001000000";

elsif B = "0000000010001101" then 

 output_tmp <= "0000000000111110";

elsif B = "0000000010001110" then 

 output_tmp <= "0000000000111101";

elsif B = "0000000010001111" then 

 output_tmp <= "0000000000111100";

elsif B = "0000000010010000" then 

 output_tmp <= "0000000000111010";

elsif B = "0000000010010001" then 

 output_tmp <= "0000000000111001";

elsif B = "0000000010010010" then 

 output_tmp <= "0000000000110111";

elsif B = "0000000010010011" then 

 output_tmp <= "0000000000110110";

elsif B = "0000000010010100" then 

 output_tmp <= "0000000000110100";

elsif B = "0000000010010101" then 

 output_tmp <= "0000000000110011";

elsif B = "0000000010010110" then 

 output_tmp <= "0000000000110001";

elsif B = "0000000010010111" then 

 output_tmp <= "0000000000110000";

elsif B = "0000000010011000" then 

 output_tmp <= "0000000000101110";

elsif B = "0000000010011001" then 

 output_tmp <= "0000000000101101";

elsif B = "0000000010011010" then 

 output_tmp <= "0000000000101011";

elsif B = "0000000010011011" then 

 output_tmp <= "0000000000101010";

elsif B = "0000000010011100" then 

 output_tmp <= "0000000000101000";

elsif B = "0000000010011101" then 

 output_tmp <= "0000000000100111";

elsif B = "0000000010011110" then 

 output_tmp <= "0000000000100101";

elsif B = "0000000010011111" then 

 output_tmp <= "0000000000100011";

elsif B = "0000000010100000" then 

 output_tmp <= "0000000000100010";

elsif B = "0000000010100001" then 

 output_tmp <= "0000000000100000";

elsif B = "0000000010100010" then 

 output_tmp <= "0000000000011110";

elsif B = "0000000010100011" then 

 output_tmp <= "0000000000011101";

elsif B = "0000000010100100" then 

 output_tmp <= "0000000000011011";

elsif B = "0000000010100101" then 

 output_tmp <= "0000000000011001";

elsif B = "0000000010100110" then 

 output_tmp <= "0000000000011000";

elsif B = "0000000010100111" then 

 output_tmp <= "0000000000010110";

elsif B = "0000000010101000" then 

 output_tmp <= "0000000000010100";

elsif B = "0000000010101001" then 

 output_tmp <= "0000000000010011";

elsif B = "0000000010101010" then 

 output_tmp <= "0000000000010001";

elsif B = "0000000010101011" then 

 output_tmp <= "0000000000001111";

elsif B = "0000000010101100" then 

 output_tmp <= "0000000000001101";

elsif B = "0000000010101101" then 

 output_tmp <= "0000000000001100";

elsif B = "0000000010101110" then 

 output_tmp <= "0000000000001010";

elsif B = "0000000010101111" then 

 output_tmp <= "0000000000001000";

elsif B = "0000000010110000" then 

 output_tmp <= "0000000000000110";

elsif B = "0000000010110001" then 

 output_tmp <= "0000000000000101";

elsif B = "0000000010110010" then 

 output_tmp <= "0000000000000011";

elsif B = "0000000010110011" then 

 output_tmp <= "0000000000000001";

elsif B = "0000000010110100" then 

 output_tmp <= "0000000000000000";

elsif B = "0000000010110101" then 

 output_tmp <= "1111111111111111";

elsif B = "0000000010110110" then 

 output_tmp <= "1111111111111110";

elsif B = "0000000010110111" then 

 output_tmp <= "1111111111111101";

elsif B = "0000000010111000" then 

 output_tmp <= "1111111111111101";

elsif B = "0000000010111001" then 

 output_tmp <= "1111111111111100";

elsif B = "0000000010111010" then 

 output_tmp <= "1111111111111011";

elsif B = "0000000010111011" then 

 output_tmp <= "1111111111111010";

elsif B = "0000000010111100" then 

 output_tmp <= "1111111111111001";

elsif B = "0000000010111101" then 

 output_tmp <= "1111111111111000";

elsif B = "0000000010111110" then 

 output_tmp <= "1111111111110111";

elsif B = "0000000010111111" then 

 output_tmp <= "1111111111110110";

elsif B = "0000000011000000" then 

 output_tmp <= "1111111111110110";

elsif B = "0000000011000001" then 

 output_tmp <= "1111111111110101";

elsif B = "0000000011000010" then 

 output_tmp <= "1111111111110100";

elsif B = "0000000011000011" then 

 output_tmp <= "1111111111110011";

elsif B = "0000000011000100" then 

 output_tmp <= "1111111111110010";

elsif B = "0000000011000101" then 

 output_tmp <= "1111111111110001";

elsif B = "0000000011000110" then 

 output_tmp <= "1111111111110001";

elsif B = "0000000011000111" then 

 output_tmp <= "1111111111110000";

elsif B = "0000000011001000" then 

 output_tmp <= "1111111111101111";

elsif B = "0000000011001001" then 

 output_tmp <= "1111111111101110";

elsif B = "0000000011001010" then 

 output_tmp <= "1111111111101101";

elsif B = "0000000011001011" then 

 output_tmp <= "1111111111101100";

elsif B = "0000000011001100" then 

 output_tmp <= "1111111111101100";

elsif B = "0000000011001101" then 

 output_tmp <= "1111111111101011";

elsif B = "0000000011001110" then 

 output_tmp <= "1111111111101010";

elsif B = "0000000011001111" then 

 output_tmp <= "1111111111101001";

elsif B = "0000000011010000" then 

 output_tmp <= "1111111111101001";

elsif B = "0000000011010001" then 

 output_tmp <= "1111111111101000";

elsif B = "0000000011010010" then 

 output_tmp <= "1111111111100111";

elsif B = "0000000011010011" then 

 output_tmp <= "1111111111100110";

elsif B = "0000000011010100" then 

 output_tmp <= "1111111111100110";

elsif B = "0000000011010101" then 

 output_tmp <= "1111111111100101";

elsif B = "0000000011010110" then 

 output_tmp <= "1111111111100100";

elsif B = "0000000011010111" then 

 output_tmp <= "1111111111100011";

elsif B = "0000000011011000" then 

 output_tmp <= "1111111111100011";

elsif B = "0000000011011001" then 

 output_tmp <= "1111111111100010";

elsif B = "0000000011011010" then 

 output_tmp <= "1111111111100001";

elsif B = "0000000011011011" then 

 output_tmp <= "1111111111100001";

elsif B = "0000000011011100" then 

 output_tmp <= "1111111111100000";

elsif B = "0000000011011101" then 

 output_tmp <= "1111111111011111";

elsif B = "0000000011011110" then 

 output_tmp <= "1111111111011111";

elsif B = "0000000011011111" then 

 output_tmp <= "1111111111011110";

elsif B = "0000000011100000" then 

 output_tmp <= "1111111111011101";

elsif B = "0000000011100001" then 

 output_tmp <= "1111111111011101";

elsif B = "0000000011100010" then 

 output_tmp <= "1111111111011100";

elsif B = "0000000011100011" then 

 output_tmp <= "1111111111011011";

elsif B = "0000000011100100" then 

 output_tmp <= "1111111111011011";

elsif B = "0000000011100101" then 

 output_tmp <= "1111111111011010";

elsif B = "0000000011100110" then 

 output_tmp <= "1111111111011010";

elsif B = "0000000011100111" then 

 output_tmp <= "1111111111011001";

elsif B = "0000000011101000" then 

 output_tmp <= "1111111111011001";

elsif B = "0000000011101001" then 

 output_tmp <= "1111111111011000";

elsif B = "0000000011101010" then 

 output_tmp <= "1111111111011000";

elsif B = "0000000011101011" then 

 output_tmp <= "1111111111010111";

elsif B = "0000000011101100" then 

 output_tmp <= "1111111111010111";

elsif B = "0000000011101101" then 

 output_tmp <= "1111111111010110";

elsif B = "0000000011101110" then 

 output_tmp <= "1111111111010110";

elsif B = "0000000011101111" then 

 output_tmp <= "1111111111010101";

elsif B = "0000000011110000" then 

 output_tmp <= "1111111111010101";

elsif B = "0000000011110001" then 

 output_tmp <= "1111111111010100";

elsif B = "0000000011110010" then 

 output_tmp <= "1111111111010100";

elsif B = "0000000011110011" then 

 output_tmp <= "1111111111010011";

elsif B = "0000000011110100" then 

 output_tmp <= "1111111111010011";

elsif B = "0000000011110101" then 

 output_tmp <= "1111111111010011";

elsif B = "0000000011110110" then 

 output_tmp <= "1111111111010010";

elsif B = "0000000011110111" then 

 output_tmp <= "1111111111010010";

elsif B = "0000000011111000" then 

 output_tmp <= "1111111111010010";

elsif B = "0000000011111001" then 

 output_tmp <= "1111111111010001";

elsif B = "0000000011111010" then 

 output_tmp <= "1111111111010001";

elsif B = "0000000011111011" then 

 output_tmp <= "1111111111010001";

elsif B = "0000000011111100" then 

 output_tmp <= "1111111111010000";

elsif B = "0000000011111101" then 

 output_tmp <= "1111111111010000";

elsif B = "0000000011111110" then 

 output_tmp <= "1111111111010000";

elsif B = "0000000011111111" then 

 output_tmp <= "1111111111010000";

elsif B = "0000000100000000" then 

 output_tmp <= "1111111111001111";

elsif B = "0000000100000001" then 

 output_tmp <= "1111111111001111";

elsif B = "0000000100000010" then 

 output_tmp <= "1111111111001111";

elsif B = "0000000100000011" then 

 output_tmp <= "1111111111001111";

elsif B = "0000000100000100" then 

 output_tmp <= "1111111111001111";

elsif B = "0000000100000101" then 

 output_tmp <= "1111111111001111";

elsif B = "0000000100000110" then 

 output_tmp <= "1111111111001110";

elsif B = "0000000100000111" then 

 output_tmp <= "1111111111001110";

elsif B = "0000000100001000" then 

 output_tmp <= "1111111111001110";

elsif B = "0000000100001001" then 

 output_tmp <= "1111111111001110";

elsif B = "0000000100001010" then 

 output_tmp <= "1111111111001110";

elsif B = "0000000100001011" then 

 output_tmp <= "1111111111001110";

elsif B = "0000000100001100" then 

 output_tmp <= "1111111111001110";

elsif B = "0000000100001101" then 

 output_tmp <= "1111111111001110";

elsif B = "0000000100001110" then 

 output_tmp <= "1111111111001110";

elsif B = "0000000100001111" then 

 output_tmp <= "1111111111001110";

elsif B = "0000000100010000" then 

 output_tmp <= "1111111111001110";

elsif B = "0000000100010001" then 

 output_tmp <= "1111111111001110";

elsif B = "0000000100010010" then 

 output_tmp <= "1111111111001110";

elsif B = "0000000100010011" then 

 output_tmp <= "1111111111001110";

elsif B = "0000000100010100" then 

 output_tmp <= "1111111111001110";

elsif B = "0000000100010101" then 

 output_tmp <= "1111111111001110";

elsif B = "0000000100010110" then 

 output_tmp <= "1111111111001110";

elsif B = "0000000100010111" then 

 output_tmp <= "1111111111001111";

elsif B = "0000000100011000" then 

 output_tmp <= "1111111111001111";

elsif B = "0000000100011001" then 

 output_tmp <= "1111111111001111";

elsif B = "0000000100011010" then 

 output_tmp <= "1111111111001111";

elsif B = "0000000100011011" then 

 output_tmp <= "1111111111001111";

elsif B = "0000000100011100" then 

 output_tmp <= "1111111111001111";

elsif B = "0000000100011101" then 

 output_tmp <= "1111111111010000";

elsif B = "0000000100011110" then 

 output_tmp <= "1111111111010000";

elsif B = "0000000100011111" then 

 output_tmp <= "1111111111010000";

elsif B = "0000000100100000" then 

 output_tmp <= "1111111111010000";

elsif B = "0000000100100001" then 

 output_tmp <= "1111111111010001";

elsif B = "0000000100100010" then 

 output_tmp <= "1111111111010001";

elsif B = "0000000100100011" then 

 output_tmp <= "1111111111010001";

elsif B = "0000000100100100" then 

 output_tmp <= "1111111111010010";

elsif B = "0000000100100101" then 

 output_tmp <= "1111111111010010";

elsif B = "0000000100100110" then 

 output_tmp <= "1111111111010010";

elsif B = "0000000100100111" then 

 output_tmp <= "1111111111010011";

elsif B = "0000000100101000" then 

 output_tmp <= "1111111111010011";

elsif B = "0000000100101001" then 

 output_tmp <= "1111111111010011";

elsif B = "0000000100101010" then 

 output_tmp <= "1111111111010100";

elsif B = "0000000100101011" then 

 output_tmp <= "1111111111010100";

elsif B = "0000000100101100" then 

 output_tmp <= "1111111111010101";

elsif B = "0000000100101101" then 

 output_tmp <= "1111111111010101";

elsif B = "0000000100101110" then 

 output_tmp <= "1111111111010110";

elsif B = "0000000100101111" then 

 output_tmp <= "1111111111010110";

elsif B = "0000000100110000" then 

 output_tmp <= "1111111111010111";

elsif B = "0000000100110001" then 

 output_tmp <= "1111111111010111";

elsif B = "0000000100110010" then 

 output_tmp <= "1111111111011000";

elsif B = "0000000100110011" then 

 output_tmp <= "1111111111011000";

elsif B = "0000000100110100" then 

 output_tmp <= "1111111111011001";

elsif B = "0000000100110101" then 

 output_tmp <= "1111111111011001";

elsif B = "0000000100110110" then 

 output_tmp <= "1111111111011010";

elsif B = "0000000100110111" then 

 output_tmp <= "1111111111011010";

elsif B = "0000000100111000" then 

 output_tmp <= "1111111111011011";

elsif B = "0000000100111001" then 

 output_tmp <= "1111111111011011";

elsif B = "0000000100111010" then 

 output_tmp <= "1111111111011100";

elsif B = "0000000100111011" then 

 output_tmp <= "1111111111011101";

elsif B = "0000000100111100" then 

 output_tmp <= "1111111111011101";

elsif B = "0000000100111101" then 

 output_tmp <= "1111111111011110";

elsif B = "0000000100111110" then 

 output_tmp <= "1111111111011111";

elsif B = "0000000100111111" then 

 output_tmp <= "1111111111011111";

elsif B = "0000000101000000" then 

 output_tmp <= "1111111111100000";

elsif B = "0000000101000001" then 

 output_tmp <= "1111111111100001";

elsif B = "0000000101000010" then 

 output_tmp <= "1111111111100001";

elsif B = "0000000101000011" then 

 output_tmp <= "1111111111100010";

elsif B = "0000000101000100" then 

 output_tmp <= "1111111111100011";

elsif B = "0000000101000101" then 

 output_tmp <= "1111111111100011";

elsif B = "0000000101000110" then 

 output_tmp <= "1111111111100100";

elsif B = "0000000101000111" then 

 output_tmp <= "1111111111100101";

elsif B = "0000000101001000" then 

 output_tmp <= "1111111111100110";

elsif B = "0000000101001001" then 

 output_tmp <= "1111111111100110";

elsif B = "0000000101001010" then 

 output_tmp <= "1111111111100111";

elsif B = "0000000101001011" then 

 output_tmp <= "1111111111101000";

elsif B = "0000000101001100" then 

 output_tmp <= "1111111111101001";

elsif B = "0000000101001101" then 

 output_tmp <= "1111111111101001";

elsif B = "0000000101001110" then 

 output_tmp <= "1111111111101010";

elsif B = "0000000101001111" then 

 output_tmp <= "1111111111101011";

elsif B = "0000000101010000" then 

 output_tmp <= "1111111111101100";

elsif B = "0000000101010001" then 

 output_tmp <= "1111111111101100";

elsif B = "0000000101010010" then 

 output_tmp <= "1111111111101101";

elsif B = "0000000101010011" then 

 output_tmp <= "1111111111101110";

elsif B = "0000000101010100" then 

 output_tmp <= "1111111111101111";

elsif B = "0000000101010101" then 

 output_tmp <= "1111111111110000";

elsif B = "0000000101010110" then 

 output_tmp <= "1111111111110001";

elsif B = "0000000101010111" then 

 output_tmp <= "1111111111110001";

elsif B = "0000000101011000" then 

 output_tmp <= "1111111111110010";

elsif B = "0000000101011001" then 

 output_tmp <= "1111111111110011";

elsif B = "0000000101011010" then 

 output_tmp <= "1111111111110100";

elsif B = "0000000101011011" then 

 output_tmp <= "1111111111110101";

elsif B = "0000000101011100" then 

 output_tmp <= "1111111111110110";

elsif B = "0000000101011101" then 

 output_tmp <= "1111111111110110";

elsif B = "0000000101011110" then 

 output_tmp <= "1111111111110111";

elsif B = "0000000101011111" then 

 output_tmp <= "1111111111111000";

elsif B = "0000000101100000" then 

 output_tmp <= "1111111111111001";

elsif B = "0000000101100001" then 

 output_tmp <= "1111111111111010";

elsif B = "0000000101100010" then 

 output_tmp <= "1111111111111011";

elsif B = "0000000101100011" then 

 output_tmp <= "1111111111111100";

elsif B = "0000000101100100" then 

 output_tmp <= "1111111111111101";

elsif B = "0000000101100101" then 

 output_tmp <= "1111111111111101";

elsif B = "0000000101100110" then 

 output_tmp <= "1111111111111110";

elsif B = "0000000101100111" then 

 output_tmp <= "1111111111111111";

elsif B = "0000000101101000" then 

 output_tmp <= "0000000000000000";

else 

output_tmp <= "ZZZZZZZZZZZZZZZZ";


end if;
		---------------------
		-- cosinus(b)
		elsif (cosB = '1') then
		  if B = "0000000000000000" then 


 output_tmp <= "0000000001100100";

elsif B = "0000000000000001" then 

 output_tmp <= "0000000001100011";

elsif B = "0000000000000010" then 

 output_tmp <= "0000000001100011";

elsif B = "0000000000000011" then 

 output_tmp <= "0000000001100011";

elsif B = "0000000000000100" then 

 output_tmp <= "0000000001100011";

elsif B = "0000000000000101" then 

 output_tmp <= "0000000001100011";

elsif B = "0000000000000110" then 

 output_tmp <= "0000000001100011";

elsif B = "0000000000000111" then 

 output_tmp <= "0000000001100011";

elsif B = "0000000000001000" then 

 output_tmp <= "0000000001100011";

elsif B = "0000000000001001" then 

 output_tmp <= "0000000001100010";

elsif B = "0000000000001010" then 

 output_tmp <= "0000000001100010";

elsif B = "0000000000001011" then 

 output_tmp <= "0000000001100010";

elsif B = "0000000000001100" then 

 output_tmp <= "0000000001100001";

elsif B = "0000000000001101" then 

 output_tmp <= "0000000001100001";

elsif B = "0000000000001110" then 

 output_tmp <= "0000000001100001";

elsif B = "0000000000001111" then 

 output_tmp <= "0000000001100000";

elsif B = "0000000000010000" then 

 output_tmp <= "0000000001100000";

elsif B = "0000000000010001" then 

 output_tmp <= "0000000001011111";

elsif B = "0000000000010010" then 

 output_tmp <= "0000000001011111";

elsif B = "0000000000010011" then 

 output_tmp <= "0000000001011110";

elsif B = "0000000000010100" then 

 output_tmp <= "0000000001011101";

elsif B = "0000000000010101" then 

 output_tmp <= "0000000001011101";

elsif B = "0000000000010110" then 

 output_tmp <= "0000000001011100";

elsif B = "0000000000010111" then 

 output_tmp <= "0000000001011100";

elsif B = "0000000000011000" then 

 output_tmp <= "0000000001011011";

elsif B = "0000000000011001" then 

 output_tmp <= "0000000001011010";

elsif B = "0000000000011010" then 

 output_tmp <= "0000000001011001";

elsif B = "0000000000011011" then 

 output_tmp <= "0000000001011001";

elsif B = "0000000000011100" then 

 output_tmp <= "0000000001011000";

elsif B = "0000000000011101" then 

 output_tmp <= "0000000001010111";

elsif B = "0000000000011110" then 

 output_tmp <= "0000000001010110";

elsif B = "0000000000011111" then 

 output_tmp <= "0000000001010101";

elsif B = "0000000000100000" then 

 output_tmp <= "0000000001010100";

elsif B = "0000000000100001" then 

 output_tmp <= "0000000001010011";

elsif B = "0000000000100010" then 

 output_tmp <= "0000000001010010";

elsif B = "0000000000100011" then 

 output_tmp <= "0000000001010001";

elsif B = "0000000000100100" then 

 output_tmp <= "0000000001010000";

elsif B = "0000000000100101" then 

 output_tmp <= "0000000001001111";

elsif B = "0000000000100110" then 

 output_tmp <= "0000000001001110";

elsif B = "0000000000100111" then 

 output_tmp <= "0000000001001101";

elsif B = "0000000000101000" then 

 output_tmp <= "0000000001001100";

elsif B = "0000000000101001" then 

 output_tmp <= "0000000001001011";

elsif B = "0000000000101010" then 

 output_tmp <= "0000000001001010";

elsif B = "0000000000101011" then 

 output_tmp <= "0000000001001001";

elsif B = "0000000000101100" then 

 output_tmp <= "0000000001000111";

elsif B = "0000000000101101" then 

 output_tmp <= "0000000001000110";

elsif B = "0000000000101110" then 

 output_tmp <= "0000000001000101";

elsif B = "0000000000101111" then 

 output_tmp <= "0000000001000100";

elsif B = "0000000000110000" then 

 output_tmp <= "0000000001000010";

elsif B = "0000000000110001" then 

 output_tmp <= "0000000001000001";

elsif B = "0000000000110010" then 

 output_tmp <= "0000000001000000";

elsif B = "0000000000110011" then 

 output_tmp <= "0000000000111110";

elsif B = "0000000000110100" then 

 output_tmp <= "0000000000111101";

elsif B = "0000000000110101" then 

 output_tmp <= "0000000000111100";

elsif B = "0000000000110110" then 

 output_tmp <= "0000000000111010";

elsif B = "0000000000110111" then 

 output_tmp <= "0000000000111001";

elsif B = "0000000000111000" then 

 output_tmp <= "0000000000110111";

elsif B = "0000000000111001" then 

 output_tmp <= "0000000000110110";

elsif B = "0000000000111010" then 

 output_tmp <= "0000000000110100";

elsif B = "0000000000111011" then 

 output_tmp <= "0000000000110011";

elsif B = "0000000000111100" then 

 output_tmp <= "0000000000110010";

elsif B = "0000000000111101" then 

 output_tmp <= "0000000000110000";

elsif B = "0000000000111110" then 

 output_tmp <= "0000000000101110";

elsif B = "0000000000111111" then 

 output_tmp <= "0000000000101101";

elsif B = "0000000001000000" then 

 output_tmp <= "0000000000101011";

elsif B = "0000000001000001" then 

 output_tmp <= "0000000000101010";

elsif B = "0000000001000010" then 

 output_tmp <= "0000000000101000";

elsif B = "0000000001000011" then 

 output_tmp <= "0000000000100111";

elsif B = "0000000001000100" then 

 output_tmp <= "0000000000100101";

elsif B = "0000000001000101" then 

 output_tmp <= "0000000000100011";

elsif B = "0000000001000110" then 

 output_tmp <= "0000000000100010";

elsif B = "0000000001000111" then 

 output_tmp <= "0000000000100000";

elsif B = "0000000001001000" then 

 output_tmp <= "0000000000011110";

elsif B = "0000000001001001" then 

 output_tmp <= "0000000000011101";

elsif B = "0000000001001010" then 

 output_tmp <= "0000000000011011";

elsif B = "0000000001001011" then 

 output_tmp <= "0000000000011001";

elsif B = "0000000001001100" then 

 output_tmp <= "0000000000011000";

elsif B = "0000000001001101" then 

 output_tmp <= "0000000000010110";

elsif B = "0000000001001110" then 

 output_tmp <= "0000000000010100";

elsif B = "0000000001001111" then 

 output_tmp <= "0000000000010011";

elsif B = "0000000001010000" then 

 output_tmp <= "0000000000010001";

elsif B = "0000000001010001" then 

 output_tmp <= "0000000000001111";

elsif B = "0000000001010010" then 

 output_tmp <= "0000000000001101";

elsif B = "0000000001010011" then 

 output_tmp <= "0000000000001100";

elsif B = "0000000001010100" then 

 output_tmp <= "0000000000001010";

elsif B = "0000000001010101" then 

 output_tmp <= "0000000000001000";

elsif B = "0000000001010110" then 

 output_tmp <= "0000000000000110";

elsif B = "0000000001010111" then 

 output_tmp <= "0000000000000101";

elsif B = "0000000001011000" then 

 output_tmp <= "0000000000000011";

elsif B = "0000000001011001" then 

 output_tmp <= "0000000000000001";

elsif B = "0000000001011010" then 

 output_tmp <= "0000000000000000";

elsif B = "0000000001011011" then 

 output_tmp <= "1111111111111111";

elsif B = "0000000001011100" then 

 output_tmp <= "1111111111111110";

elsif B = "0000000001011101" then 

 output_tmp <= "1111111111111101";

elsif B = "0000000001011110" then 

 output_tmp <= "1111111111111101";

elsif B = "0000000001011111" then 

 output_tmp <= "1111111111111100";

elsif B = "0000000001100000" then 

 output_tmp <= "1111111111111011";

elsif B = "0000000001100001" then 

 output_tmp <= "1111111111111010";

elsif B = "0000000001100010" then 

 output_tmp <= "1111111111111001";

elsif B = "0000000001100011" then 

 output_tmp <= "1111111111111000";

elsif B = "0000000001100100" then 

 output_tmp <= "1111111111110111";

elsif B = "0000000001100101" then 

 output_tmp <= "1111111111110110";

elsif B = "0000000001100110" then 

 output_tmp <= "1111111111110110";

elsif B = "0000000001100111" then 

 output_tmp <= "1111111111110101";

elsif B = "0000000001101000" then 

 output_tmp <= "1111111111110100";

elsif B = "0000000001101001" then 

 output_tmp <= "1111111111110011";

elsif B = "0000000001101010" then 

 output_tmp <= "1111111111110010";

elsif B = "0000000001101011" then 

 output_tmp <= "1111111111110001";

elsif B = "0000000001101100" then 

 output_tmp <= "1111111111110001";

elsif B = "0000000001101101" then 

 output_tmp <= "1111111111110000";

elsif B = "0000000001101110" then 

 output_tmp <= "1111111111101111";

elsif B = "0000000001101111" then 

 output_tmp <= "1111111111101110";

elsif B = "0000000001110000" then 

 output_tmp <= "1111111111101101";

elsif B = "0000000001110001" then 

 output_tmp <= "1111111111101100";

elsif B = "0000000001110010" then 

 output_tmp <= "1111111111101100";

elsif B = "0000000001110011" then 

 output_tmp <= "1111111111101011";

elsif B = "0000000001110100" then 

 output_tmp <= "1111111111101010";

elsif B = "0000000001110101" then 

 output_tmp <= "1111111111101001";

elsif B = "0000000001110110" then 

 output_tmp <= "1111111111101001";

elsif B = "0000000001110111" then 

 output_tmp <= "1111111111101000";

elsif B = "0000000001111000" then 

 output_tmp <= "1111111111100111";

elsif B = "0000000001111001" then 

 output_tmp <= "1111111111100110";

elsif B = "0000000001111010" then 

 output_tmp <= "1111111111100110";

elsif B = "0000000001111011" then 

 output_tmp <= "1111111111100101";

elsif B = "0000000001111100" then 

 output_tmp <= "1111111111100100";

elsif B = "0000000001111101" then 

 output_tmp <= "1111111111100011";

elsif B = "0000000001111110" then 

 output_tmp <= "1111111111100011";

elsif B = "0000000001111111" then 

 output_tmp <= "1111111111100010";

elsif B = "0000000010000000" then 

 output_tmp <= "1111111111100001";

elsif B = "0000000010000001" then 

 output_tmp <= "1111111111100001";

elsif B = "0000000010000010" then 

 output_tmp <= "1111111111100000";

elsif B = "0000000010000011" then 

 output_tmp <= "1111111111011111";

elsif B = "0000000010000100" then 

 output_tmp <= "1111111111011111";

elsif B = "0000000010000101" then 

 output_tmp <= "1111111111011110";

elsif B = "0000000010000110" then 

 output_tmp <= "1111111111011101";

elsif B = "0000000010000111" then 

 output_tmp <= "1111111111011101";

elsif B = "0000000010001000" then 

 output_tmp <= "1111111111011100";

elsif B = "0000000010001001" then 

 output_tmp <= "1111111111011011";

elsif B = "0000000010001010" then 

 output_tmp <= "1111111111011011";

elsif B = "0000000010001011" then 

 output_tmp <= "1111111111011010";

elsif B = "0000000010001100" then 

 output_tmp <= "1111111111011010";

elsif B = "0000000010001101" then 

 output_tmp <= "1111111111011001";

elsif B = "0000000010001110" then 

 output_tmp <= "1111111111011001";

elsif B = "0000000010001111" then 

 output_tmp <= "1111111111011000";

elsif B = "0000000010010000" then 

 output_tmp <= "1111111111011000";

elsif B = "0000000010010001" then 

 output_tmp <= "1111111111010111";

elsif B = "0000000010010010" then 

 output_tmp <= "1111111111010111";

elsif B = "0000000010010011" then 

 output_tmp <= "1111111111010110";

elsif B = "0000000010010100" then 

 output_tmp <= "1111111111010110";

elsif B = "0000000010010101" then 

 output_tmp <= "1111111111010101";

elsif B = "0000000010010110" then 

 output_tmp <= "1111111111010101";

elsif B = "0000000010010111" then 

 output_tmp <= "1111111111010100";

elsif B = "0000000010011000" then 

 output_tmp <= "1111111111010100";

elsif B = "0000000010011001" then 

 output_tmp <= "1111111111010011";

elsif B = "0000000010011010" then 

 output_tmp <= "1111111111010011";

elsif B = "0000000010011011" then 

 output_tmp <= "1111111111010011";

elsif B = "0000000010011100" then 

 output_tmp <= "1111111111010010";

elsif B = "0000000010011101" then 

 output_tmp <= "1111111111010010";

elsif B = "0000000010011110" then 

 output_tmp <= "1111111111010010";

elsif B = "0000000010011111" then 

 output_tmp <= "1111111111010001";

elsif B = "0000000010100000" then 

 output_tmp <= "1111111111010001";

elsif B = "0000000010100001" then 

 output_tmp <= "1111111111010001";

elsif B = "0000000010100010" then 

 output_tmp <= "1111111111010000";

elsif B = "0000000010100011" then 

 output_tmp <= "1111111111010000";

elsif B = "0000000010100100" then 

 output_tmp <= "1111111111010000";

elsif B = "0000000010100101" then 

 output_tmp <= "1111111111010000";

elsif B = "0000000010100110" then 

 output_tmp <= "1111111111001111";

elsif B = "0000000010100111" then 

 output_tmp <= "1111111111001111";

elsif B = "0000000010101000" then 

 output_tmp <= "1111111111001111";

elsif B = "0000000010101001" then 

 output_tmp <= "1111111111001111";

elsif B = "0000000010101010" then 

 output_tmp <= "1111111111001111";

elsif B = "0000000010101011" then 

 output_tmp <= "1111111111001111";

elsif B = "0000000010101100" then 

 output_tmp <= "1111111111001110";

elsif B = "0000000010101101" then 

 output_tmp <= "1111111111001110";

elsif B = "0000000010101110" then 

 output_tmp <= "1111111111001110";

elsif B = "0000000010101111" then 

 output_tmp <= "1111111111001110";

elsif B = "0000000010110000" then 

 output_tmp <= "1111111111001110";

elsif B = "0000000010110001" then 

 output_tmp <= "1111111111001110";

elsif B = "0000000010110010" then 

 output_tmp <= "1111111111001110";

elsif B = "0000000010110011" then 

 output_tmp <= "1111111111001110";

elsif B = "0000000010110100" then 

 output_tmp <= "1111111111001110";

elsif B = "0000000010110101" then 

 output_tmp <= "1111111111001110";

elsif B = "0000000010110110" then 

 output_tmp <= "1111111111001110";

elsif B = "0000000010110111" then 

 output_tmp <= "1111111111001110";

elsif B = "0000000010111000" then 

 output_tmp <= "1111111111001110";

elsif B = "0000000010111001" then 

 output_tmp <= "1111111111001110";

elsif B = "0000000010111010" then 

 output_tmp <= "1111111111001110";

elsif B = "0000000010111011" then 

 output_tmp <= "1111111111001110";

elsif B = "0000000010111100" then 

 output_tmp <= "1111111111001110";

elsif B = "0000000010111101" then 

 output_tmp <= "1111111111001111";

elsif B = "0000000010111110" then 

 output_tmp <= "1111111111001111";

elsif B = "0000000010111111" then 

 output_tmp <= "1111111111001111";

elsif B = "0000000011000000" then 

 output_tmp <= "1111111111001111";

elsif B = "0000000011000001" then 

 output_tmp <= "1111111111001111";

elsif B = "0000000011000010" then 

 output_tmp <= "1111111111001111";

elsif B = "0000000011000011" then 

 output_tmp <= "1111111111010000";

elsif B = "0000000011000100" then 

 output_tmp <= "1111111111010000";

elsif B = "0000000011000101" then 

 output_tmp <= "1111111111010000";

elsif B = "0000000011000110" then 

 output_tmp <= "1111111111010000";

elsif B = "0000000011000111" then 

 output_tmp <= "1111111111010001";

elsif B = "0000000011001000" then 

 output_tmp <= "1111111111010001";

elsif B = "0000000011001001" then 

 output_tmp <= "1111111111010001";

elsif B = "0000000011001010" then 

 output_tmp <= "1111111111010010";

elsif B = "0000000011001011" then 

 output_tmp <= "1111111111010010";

elsif B = "0000000011001100" then 

 output_tmp <= "1111111111010010";

elsif B = "0000000011001101" then 

 output_tmp <= "1111111111010011";

elsif B = "0000000011001110" then 

 output_tmp <= "1111111111010011";

elsif B = "0000000011001111" then 

 output_tmp <= "1111111111010011";

elsif B = "0000000011010000" then 

 output_tmp <= "1111111111010100";

elsif B = "0000000011010001" then 

 output_tmp <= "1111111111010100";

elsif B = "0000000011010010" then 

 output_tmp <= "1111111111010101";

elsif B = "0000000011010011" then 

 output_tmp <= "1111111111010101";

elsif B = "0000000011010100" then 

 output_tmp <= "1111111111010110";

elsif B = "0000000011010101" then 

 output_tmp <= "1111111111010110";

elsif B = "0000000011010110" then 

 output_tmp <= "1111111111010111";

elsif B = "0000000011010111" then 

 output_tmp <= "1111111111010111";

elsif B = "0000000011011000" then 

 output_tmp <= "1111111111011000";

elsif B = "0000000011011001" then 

 output_tmp <= "1111111111011000";

elsif B = "0000000011011010" then 

 output_tmp <= "1111111111011001";

elsif B = "0000000011011011" then 

 output_tmp <= "1111111111011001";

elsif B = "0000000011011100" then 

 output_tmp <= "1111111111011010";

elsif B = "0000000011011101" then 

 output_tmp <= "1111111111011010";

elsif B = "0000000011011110" then 

 output_tmp <= "1111111111011011";

elsif B = "0000000011011111" then 

 output_tmp <= "1111111111011011";

elsif B = "0000000011100000" then 

 output_tmp <= "1111111111011100";

elsif B = "0000000011100001" then 

 output_tmp <= "1111111111011101";

elsif B = "0000000011100010" then 

 output_tmp <= "1111111111011101";

elsif B = "0000000011100011" then 

 output_tmp <= "1111111111011110";

elsif B = "0000000011100100" then 

 output_tmp <= "1111111111011111";

elsif B = "0000000011100101" then 

 output_tmp <= "1111111111011111";

elsif B = "0000000011100110" then 

 output_tmp <= "1111111111100000";

elsif B = "0000000011100111" then 

 output_tmp <= "1111111111100001";

elsif B = "0000000011101000" then 

 output_tmp <= "1111111111100001";

elsif B = "0000000011101001" then 

 output_tmp <= "1111111111100010";

elsif B = "0000000011101010" then 

 output_tmp <= "1111111111100011";

elsif B = "0000000011101011" then 

 output_tmp <= "1111111111100011";

elsif B = "0000000011101100" then 

 output_tmp <= "1111111111100100";

elsif B = "0000000011101101" then 

 output_tmp <= "1111111111100101";

elsif B = "0000000011101110" then 

 output_tmp <= "1111111111100110";

elsif B = "0000000011101111" then 

 output_tmp <= "1111111111100110";

elsif B = "0000000011110000" then 

 output_tmp <= "1111111111100111";

elsif B = "0000000011110001" then 

 output_tmp <= "1111111111101000";

elsif B = "0000000011110010" then 

 output_tmp <= "1111111111101001";

elsif B = "0000000011110011" then 

 output_tmp <= "1111111111101001";

elsif B = "0000000011110100" then 

 output_tmp <= "1111111111101010";

elsif B = "0000000011110101" then 

 output_tmp <= "1111111111101011";

elsif B = "0000000011110110" then 

 output_tmp <= "1111111111101100";

elsif B = "0000000011110111" then 

 output_tmp <= "1111111111101100";

elsif B = "0000000011111000" then 

 output_tmp <= "1111111111101101";

elsif B = "0000000011111001" then 

 output_tmp <= "1111111111101110";

elsif B = "0000000011111010" then 

 output_tmp <= "1111111111101111";

elsif B = "0000000011111011" then 

 output_tmp <= "1111111111110000";

elsif B = "0000000011111100" then 

 output_tmp <= "1111111111110001";

elsif B = "0000000011111101" then 

 output_tmp <= "1111111111110001";

elsif B = "0000000011111110" then 

 output_tmp <= "1111111111110010";

elsif B = "0000000011111111" then 

 output_tmp <= "1111111111110011";

elsif B = "0000000100000000" then 

 output_tmp <= "1111111111110100";

elsif B = "0000000100000001" then 

 output_tmp <= "1111111111110101";

elsif B = "0000000100000010" then 

 output_tmp <= "1111111111110110";

elsif B = "0000000100000011" then 

 output_tmp <= "1111111111110110";

elsif B = "0000000100000100" then 

 output_tmp <= "1111111111110111";

elsif B = "0000000100000101" then 

 output_tmp <= "1111111111111000";

elsif B = "0000000100000110" then 

 output_tmp <= "1111111111111001";

elsif B = "0000000100000111" then 

 output_tmp <= "1111111111111010";

elsif B = "0000000100001000" then 

 output_tmp <= "1111111111111011";

elsif B = "0000000100001001" then 

 output_tmp <= "1111111111111100";

elsif B = "0000000100001010" then 

 output_tmp <= "1111111111111101";

elsif B = "0000000100001011" then 

 output_tmp <= "1111111111111101";

elsif B = "0000000100001100" then 

 output_tmp <= "1111111111111110";

elsif B = "0000000100001101" then 

 output_tmp <= "1111111111111111";

elsif B = "0000000100001110" then 

 output_tmp <= "0000000000000000";

elsif B = "0000000100001111" then 

 output_tmp <= "0000000000000001";

elsif B = "0000000100010000" then 

 output_tmp <= "0000000000000011";

elsif B = "0000000100010001" then 

 output_tmp <= "0000000000000101";

elsif B = "0000000100010010" then 

 output_tmp <= "0000000000000110";

elsif B = "0000000100010011" then 

 output_tmp <= "0000000000001000";

elsif B = "0000000100010100" then 

 output_tmp <= "0000000000001010";

elsif B = "0000000100010101" then 

 output_tmp <= "0000000000001100";

elsif B = "0000000100010110" then 

 output_tmp <= "0000000000001101";

elsif B = "0000000100010111" then 

 output_tmp <= "0000000000001111";

elsif B = "0000000100011000" then 

 output_tmp <= "0000000000010001";

elsif B = "0000000100011001" then 

 output_tmp <= "0000000000010011";

elsif B = "0000000100011010" then 

 output_tmp <= "0000000000010100";

elsif B = "0000000100011011" then 

 output_tmp <= "0000000000010110";

elsif B = "0000000100011100" then 

 output_tmp <= "0000000000011000";

elsif B = "0000000100011101" then 

 output_tmp <= "0000000000011001";

elsif B = "0000000100011110" then 

 output_tmp <= "0000000000011011";

elsif B = "0000000100011111" then 

 output_tmp <= "0000000000011101";

elsif B = "0000000100100000" then 

 output_tmp <= "0000000000011110";

elsif B = "0000000100100001" then 

 output_tmp <= "0000000000100000";

elsif B = "0000000100100010" then 

 output_tmp <= "0000000000100010";

elsif B = "0000000100100011" then 

 output_tmp <= "0000000000100011";

elsif B = "0000000100100100" then 

 output_tmp <= "0000000000100101";

elsif B = "0000000100100101" then 

 output_tmp <= "0000000000100111";

elsif B = "0000000100100110" then 

 output_tmp <= "0000000000101000";

elsif B = "0000000100100111" then 

 output_tmp <= "0000000000101010";

elsif B = "0000000100101000" then 

 output_tmp <= "0000000000101011";

elsif B = "0000000100101001" then 

 output_tmp <= "0000000000101101";

elsif B = "0000000100101010" then 

 output_tmp <= "0000000000101110";

elsif B = "0000000100101011" then 

 output_tmp <= "0000000000110000";

elsif B = "0000000100101100" then 

 output_tmp <= "0000000000110010";

elsif B = "0000000100101101" then 

 output_tmp <= "0000000000110011";

elsif B = "0000000100101110" then 

 output_tmp <= "0000000000110100";

elsif B = "0000000100101111" then 

 output_tmp <= "0000000000110110";

elsif B = "0000000100110000" then 

 output_tmp <= "0000000000110111";

elsif B = "0000000100110001" then 

 output_tmp <= "0000000000111001";

elsif B = "0000000100110010" then 

 output_tmp <= "0000000000111010";

elsif B = "0000000100110011" then 

 output_tmp <= "0000000000111100";

elsif B = "0000000100110100" then 

 output_tmp <= "0000000000111101";

elsif B = "0000000100110101" then 

 output_tmp <= "0000000000111110";

elsif B = "0000000100110110" then 

 output_tmp <= "0000000001000000";

elsif B = "0000000100110111" then 

 output_tmp <= "0000000001000001";

elsif B = "0000000100111000" then 

 output_tmp <= "0000000001000010";

elsif B = "0000000100111001" then 

 output_tmp <= "0000000001000100";

elsif B = "0000000100111010" then 

 output_tmp <= "0000000001000101";

elsif B = "0000000100111011" then 

 output_tmp <= "0000000001000110";

elsif B = "0000000100111100" then 

 output_tmp <= "0000000001000111";

elsif B = "0000000100111101" then 

 output_tmp <= "0000000001001001";

elsif B = "0000000100111110" then 

 output_tmp <= "0000000001001010";

elsif B = "0000000100111111" then 

 output_tmp <= "0000000001001011";

elsif B = "0000000101000000" then 

 output_tmp <= "0000000001001100";

elsif B = "0000000101000001" then 

 output_tmp <= "0000000001001101";

elsif B = "0000000101000010" then 

 output_tmp <= "0000000001001110";

elsif B = "0000000101000011" then 

 output_tmp <= "0000000001001111";

elsif B = "0000000101000100" then 

 output_tmp <= "0000000001010000";

elsif B = "0000000101000101" then 

 output_tmp <= "0000000001010001";

elsif B = "0000000101000110" then 

 output_tmp <= "0000000001010010";

elsif B = "0000000101000111" then 

 output_tmp <= "0000000001010011";

elsif B = "0000000101001000" then 

 output_tmp <= "0000000001010100";

elsif B = "0000000101001001" then 

 output_tmp <= "0000000001010101";

elsif B = "0000000101001010" then 

 output_tmp <= "0000000001010110";

elsif B = "0000000101001011" then 

 output_tmp <= "0000000001010111";

elsif B = "0000000101001100" then 

 output_tmp <= "0000000001011000";

elsif B = "0000000101001101" then 

 output_tmp <= "0000000001011001";

elsif B = "0000000101001110" then 

 output_tmp <= "0000000001011001";

elsif B = "0000000101001111" then 

 output_tmp <= "0000000001011010";

elsif B = "0000000101010000" then 

 output_tmp <= "0000000001011011";

elsif B = "0000000101010001" then 

 output_tmp <= "0000000001011100";

elsif B = "0000000101010010" then 

 output_tmp <= "0000000001011100";

elsif B = "0000000101010011" then 

 output_tmp <= "0000000001011101";

elsif B = "0000000101010100" then 

 output_tmp <= "0000000001011101";

elsif B = "0000000101010101" then 

 output_tmp <= "0000000001011110";

elsif B = "0000000101010110" then 

 output_tmp <= "0000000001011111";

elsif B = "0000000101010111" then 

 output_tmp <= "0000000001011111";

elsif B = "0000000101011000" then 

 output_tmp <= "0000000001100000";

elsif B = "0000000101011001" then 

 output_tmp <= "0000000001100000";

elsif B = "0000000101011010" then 

 output_tmp <= "0000000001100001";

elsif B = "0000000101011011" then 

 output_tmp <= "0000000001100001";

elsif B = "0000000101011100" then 

 output_tmp <= "0000000001100001";

elsif B = "0000000101011101" then 

 output_tmp <= "0000000001100010";

elsif B = "0000000101011110" then 

 output_tmp <= "0000000001100010";

elsif B = "0000000101011111" then 

 output_tmp <= "0000000001100010";

elsif B = "0000000101100000" then 

 output_tmp <= "0000000001100011";

elsif B = "0000000101100001" then 

 output_tmp <= "0000000001100011";

elsif B = "0000000101100010" then 

 output_tmp <= "0000000001100011";

elsif B = "0000000101100011" then 

 output_tmp <= "0000000001100011";

elsif B = "0000000101100100" then 

 output_tmp <= "0000000001100011";

elsif B = "0000000101100101" then 

 output_tmp <= "0000000001100011";

elsif B = "0000000101100110" then 

 output_tmp <= "0000000001100011";

elsif B = "0000000101100111" then 

 output_tmp <= "0000000001100011";

elsif B = "0000000101101000" then 

 output_tmp <= "0000000001100100";

else

 output_tmp <= "ZZZZZZZZZZZZZZZZ";
 end if;
		---------------------
		-- tangent(b)
		elsif (tanB = '1') then
		  if B = "0000000000000000" then 


 output_tmp <= "0000000000000000";

elsif B = "0000000000000001" then 

 output_tmp <= "0000000000000001";

elsif B = "0000000000000010" then 

 output_tmp <= "0000000000000011";

elsif B = "0000000000000011" then 

 output_tmp <= "0000000000000101";

elsif B = "0000000000000100" then 

 output_tmp <= "0000000000000110";

elsif B = "0000000000000101" then 

 output_tmp <= "0000000000001000";

elsif B = "0000000000000110" then 

 output_tmp <= "0000000000001010";

elsif B = "0000000000000111" then 

 output_tmp <= "0000000000001100";

elsif B = "0000000000001000" then 

 output_tmp <= "0000000000001110";

elsif B = "0000000000001001" then 

 output_tmp <= "0000000000001111";

elsif B = "0000000000001010" then 

 output_tmp <= "0000000000010001";

elsif B = "0000000000001011" then 

 output_tmp <= "0000000000010011";

elsif B = "0000000000001100" then 

 output_tmp <= "0000000000010101";

elsif B = "0000000000001101" then 

 output_tmp <= "0000000000010111";

elsif B = "0000000000001110" then 

 output_tmp <= "0000000000011000";

elsif B = "0000000000001111" then 

 output_tmp <= "0000000000011010";

elsif B = "0000000000010000" then 

 output_tmp <= "0000000000011100";

elsif B = "0000000000010001" then 

 output_tmp <= "0000000000011110";

elsif B = "0000000000010010" then 

 output_tmp <= "0000000000100000";

elsif B = "0000000000010011" then 

 output_tmp <= "0000000000100010";

elsif B = "0000000000010100" then 

 output_tmp <= "0000000000100100";

elsif B = "0000000000010101" then 

 output_tmp <= "0000000000100110";

elsif B = "0000000000010110" then 

 output_tmp <= "0000000000101000";

elsif B = "0000000000010111" then 

 output_tmp <= "0000000000101010";

elsif B = "0000000000011000" then 

 output_tmp <= "0000000000101100";

elsif B = "0000000000011001" then 

 output_tmp <= "0000000000101110";

elsif B = "0000000000011010" then 

 output_tmp <= "0000000000110000";

elsif B = "0000000000011011" then 

 output_tmp <= "0000000000110010";

elsif B = "0000000000011100" then 

 output_tmp <= "0000000000110101";

elsif B = "0000000000011101" then 

 output_tmp <= "0000000000110111";

elsif B = "0000000000011110" then 

 output_tmp <= "0000000000111001";

elsif B = "0000000000011111" then 

 output_tmp <= "0000000000111100";

elsif B = "0000000000100000" then 

 output_tmp <= "0000000000111110";

elsif B = "0000000000100001" then 

 output_tmp <= "0000000001000000";

elsif B = "0000000000100010" then 

 output_tmp <= "0000000001000011";

elsif B = "0000000000100011" then 

 output_tmp <= "0000000001000110";

elsif B = "0000000000100100" then 

 output_tmp <= "0000000001001000";

elsif B = "0000000000100101" then 

 output_tmp <= "0000000001001011";

elsif B = "0000000000100110" then 

 output_tmp <= "0000000001001110";

elsif B = "0000000000100111" then 

 output_tmp <= "0000000001010000";

elsif B = "0000000000101000" then 

 output_tmp <= "0000000001010011";

elsif B = "0000000000101001" then 

 output_tmp <= "0000000001010110";

elsif B = "0000000000101010" then 

 output_tmp <= "0000000001011010";

elsif B = "0000000000101011" then 

 output_tmp <= "0000000001011101";

elsif B = "0000000000101100" then 

 output_tmp <= "0000000001100000";

elsif B = "0000000000101101" then 

 output_tmp <= "0000000001100011";

elsif B = "0000000000101110" then 

 output_tmp <= "0000000001100111";

elsif B = "0000000000101111" then 

 output_tmp <= "0000000001101011";

elsif B = "0000000000110000" then 

 output_tmp <= "0000000001101111";

elsif B = "0000000000110001" then 

 output_tmp <= "0000000001110011";

elsif B = "0000000000110010" then 

 output_tmp <= "0000000001110111";

elsif B = "0000000000110011" then 

 output_tmp <= "0000000001111011";

elsif B = "0000000000110100" then 

 output_tmp <= "0000000001111111";

elsif B = "0000000000110101" then 

 output_tmp <= "0000000010000100";

elsif B = "0000000000110110" then 

 output_tmp <= "0000000010001001";

elsif B = "0000000000110111" then 

 output_tmp <= "0000000010001110";

elsif B = "0000000000111000" then 

 output_tmp <= "0000000010010100";

elsif B = "0000000000111001" then 

 output_tmp <= "0000000010011001";

elsif B = "0000000000111010" then 

 output_tmp <= "0000000010100000";

elsif B = "0000000000111011" then 

 output_tmp <= "0000000010100110";

elsif B = "0000000000111100" then 

 output_tmp <= "0000000010101101";

elsif B = "0000000000111101" then 

 output_tmp <= "0000000010110100";

elsif B = "0000000000111110" then 

 output_tmp <= "0000000010111100";

elsif B = "0000000000111111" then 

 output_tmp <= "0000000011000100";

elsif B = "0000000001000000" then 

 output_tmp <= "0000000011001101";

elsif B = "0000000001000001" then 

 output_tmp <= "0000000011010110";

elsif B = "0000000001000010" then 

 output_tmp <= "0000000011100000";

elsif B = "0000000001000011" then 

 output_tmp <= "0000000011101011";

elsif B = "0000000001000100" then 

 output_tmp <= "0000000011110111";

elsif B = "0000000001000101" then 

 output_tmp <= "0000000100000100";

elsif B = "0000000001000110" then 

 output_tmp <= "0000000100010010";

elsif B = "0000000001000111" then 

 output_tmp <= "0000000100100010";

elsif B = "0000000001001000" then 

 output_tmp <= "0000000100110011";

elsif B = "0000000001001001" then 

 output_tmp <= "0000000101000111";

elsif B = "0000000001001010" then 

 output_tmp <= "0000000101011100";

elsif B = "0000000001001011" then 

 output_tmp <= "0000000101110101";

elsif B = "0000000001001100" then 

 output_tmp <= "0000000110010001";

elsif B = "0000000001001101" then 

 output_tmp <= "0000000110110001";

elsif B = "0000000001001110" then 

 output_tmp <= "0000000111010110";

elsif B = "0000000001001111" then 

 output_tmp <= "0000001000000010";

elsif B = "0000000001010000" then 

 output_tmp <= "0000001000110111";

elsif B = "0000000001010001" then 

 output_tmp <= "0000001001110111";

elsif B = "0000000001010010" then 

 output_tmp <= "0000001011000111";

elsif B = "0000000001010011" then 

 output_tmp <= "0000001100101110";

elsif B = "0000000001010100" then 

 output_tmp <= "0000001110110111";

elsif B = "0000000001010101" then 

 output_tmp <= "0000010001110111";

elsif B = "0000000001010110" then 

 output_tmp <= "0000010110010110";

elsif B = "0000000001010111" then 

 output_tmp <= "0000011101110100";

elsif B = "0000000001011000" then 

 output_tmp <= "0000101100101111";

elsif B = "0000000001011001" then 

 output_tmp <= "0001011001100000";

elsif B = "0000000001011010" then 

 output_tmp <= "1111111111111111";

elsif B = "0000000001011011" then 

 output_tmp <= "1111010011010000";

elsif B = "0000000001011100" then 

 output_tmp <= "1111101001101000";

elsif B = "0000000001011101" then 

 output_tmp <= "1111110001000110";

elsif B = "0000000001011110" then 

 output_tmp <= "1111110100110101";

elsif B = "0000000001011111" then 

 output_tmp <= "1111110111000100";

elsif B = "0000000001100000" then 

 output_tmp <= "1111111000100100";

elsif B = "0000000001100001" then 

 output_tmp <= "1111111001101001";

elsif B = "0000000001100010" then 

 output_tmp <= "1111111010011100";

elsif B = "0000000001100011" then 

 output_tmp <= "1111111011000100";

elsif B = "0000000001100100" then 

 output_tmp <= "1111111011100100";

elsif B = "0000000001100101" then 

 output_tmp <= "1111111011111111";

elsif B = "0000000001100110" then 

 output_tmp <= "1111111100010101";

elsif B = "0000000001100111" then 

 output_tmp <= "1111111100100111";

elsif B = "0000000001101000" then 

 output_tmp <= "1111111100110111";

elsif B = "0000000001101001" then 

 output_tmp <= "1111111101000101";

elsif B = "0000000001101010" then 

 output_tmp <= "1111111101010010";

elsif B = "0000000001101011" then 

 output_tmp <= "1111111101011100";

elsif B = "0000000001101100" then 

 output_tmp <= "1111111101100110";

elsif B = "0000000001101101" then 

 output_tmp <= "1111111101101111";

elsif B = "0000000001101110" then 

 output_tmp <= "1111111101110111";

elsif B = "0000000001101111" then 

 output_tmp <= "1111111101111110";

elsif B = "0000000001110000" then 

 output_tmp <= "1111111110000100";

elsif B = "0000000001110001" then 

 output_tmp <= "1111111110001010";

elsif B = "0000000001110010" then 

 output_tmp <= "1111111110010000";

elsif B = "0000000001110011" then 

 output_tmp <= "1111111110010101";

elsif B = "0000000001110100" then 

 output_tmp <= "1111111110011001";

elsif B = "0000000001110101" then 

 output_tmp <= "1111111110011110";

elsif B = "0000000001110110" then 

 output_tmp <= "1111111110100010";

elsif B = "0000000001110111" then 

 output_tmp <= "1111111110100110";

elsif B = "0000000001111000" then 

 output_tmp <= "1111111110101001";

elsif B = "0000000001111001" then 

 output_tmp <= "1111111110101101";

elsif B = "0000000001111010" then 

 output_tmp <= "1111111110110000";

elsif B = "0000000001111011" then 

 output_tmp <= "1111111110110011";

elsif B = "0000000001111100" then 

 output_tmp <= "1111111110110110";

elsif B = "0000000001111101" then 

 output_tmp <= "1111111110111001";

elsif B = "0000000001111110" then 

 output_tmp <= "1111111110111011";

elsif B = "0000000001111111" then 

 output_tmp <= "1111111110111110";

elsif B = "0000000010000000" then 

 output_tmp <= "1111111111000000";

elsif B = "0000000010000001" then 

 output_tmp <= "1111111111000010";

elsif B = "0000000010000010" then 

 output_tmp <= "1111111111000100";

elsif B = "0000000010000011" then 

 output_tmp <= "1111111111000110";

elsif B = "0000000010000100" then 

 output_tmp <= "1111111111001000";

elsif B = "0000000010000101" then 

 output_tmp <= "1111111111001010";

elsif B = "0000000010000110" then 

 output_tmp <= "1111111111001100";

elsif B = "0000000010000111" then 

 output_tmp <= "1111111111001110";

elsif B = "0000000010001000" then 

 output_tmp <= "1111111111010000";

elsif B = "0000000010001001" then 

 output_tmp <= "1111111111010001";

elsif B = "0000000010001010" then 

 output_tmp <= "1111111111010011";

elsif B = "0000000010001011" then 

 output_tmp <= "1111111111010101";

elsif B = "0000000010001100" then 

 output_tmp <= "1111111111010110";

elsif B = "0000000010001101" then 

 output_tmp <= "1111111111011000";

elsif B = "0000000010001110" then 

 output_tmp <= "1111111111011001";

elsif B = "0000000010001111" then 

 output_tmp <= "1111111111011010";

elsif B = "0000000010010000" then 

 output_tmp <= "1111111111011100";

elsif B = "0000000010010001" then 

 output_tmp <= "1111111111011101";

elsif B = "0000000010010010" then 

 output_tmp <= "1111111111011110";

elsif B = "0000000010010011" then 

 output_tmp <= "1111111111100000";

elsif B = "0000000010010100" then 

 output_tmp <= "1111111111100001";

elsif B = "0000000010010101" then 

 output_tmp <= "1111111111100010";

elsif B = "0000000010010110" then 

 output_tmp <= "1111111111100011";

elsif B = "0000000010010111" then 

 output_tmp <= "1111111111100100";

elsif B = "0000000010011000" then 

 output_tmp <= "1111111111100101";

elsif B = "0000000010011001" then 

 output_tmp <= "1111111111100111";

elsif B = "0000000010011010" then 

 output_tmp <= "1111111111101000";

elsif B = "0000000010011011" then 

 output_tmp <= "1111111111101001";

elsif B = "0000000010011100" then 

 output_tmp <= "1111111111101010";

elsif B = "0000000010011101" then 

 output_tmp <= "1111111111101011";

elsif B = "0000000010011110" then 

 output_tmp <= "1111111111101100";

elsif B = "0000000010011111" then 

 output_tmp <= "1111111111101101";

elsif B = "0000000010100000" then 

 output_tmp <= "1111111111101110";

elsif B = "0000000010100001" then 

 output_tmp <= "1111111111101111";

elsif B = "0000000010100010" then 

 output_tmp <= "1111111111110000";

elsif B = "0000000010100011" then 

 output_tmp <= "1111111111110001";

elsif B = "0000000010100100" then 

 output_tmp <= "1111111111110010";

elsif B = "0000000010100101" then 

 output_tmp <= "1111111111110011";

elsif B = "0000000010100110" then 

 output_tmp <= "1111111111110100";

elsif B = "0000000010100111" then 

 output_tmp <= "1111111111110100";

elsif B = "0000000010101000" then 

 output_tmp <= "1111111111110101";

elsif B = "0000000010101001" then 

 output_tmp <= "1111111111110110";

elsif B = "0000000010101010" then 

 output_tmp <= "1111111111110111";

elsif B = "0000000010101011" then 

 output_tmp <= "1111111111111000";

elsif B = "0000000010101100" then 

 output_tmp <= "1111111111111001";

elsif B = "0000000010101101" then 

 output_tmp <= "1111111111111010";

elsif B = "0000000010101110" then 

 output_tmp <= "1111111111111011";

elsif B = "0000000010101111" then 

 output_tmp <= "1111111111111100";

elsif B = "0000000010110000" then 

 output_tmp <= "1111111111111101";

elsif B = "0000000010110001" then 

 output_tmp <= "1111111111111101";

elsif B = "0000000010110010" then 

 output_tmp <= "1111111111111110";

elsif B = "0000000010110011" then 

 output_tmp <= "1111111111111111";

elsif B = "0000000010110100" then 

 output_tmp <= "0000000000000000";

elsif B = "0000000010110101" then 

 output_tmp <= "0000000000000001";

elsif B = "0000000010110110" then 

 output_tmp <= "0000000000000011";

elsif B = "0000000010110111" then 

 output_tmp <= "0000000000000101";

elsif B = "0000000010111000" then 

 output_tmp <= "0000000000000110";

elsif B = "0000000010111001" then 

 output_tmp <= "0000000000001000";

elsif B = "0000000010111010" then 

 output_tmp <= "0000000000001010";

elsif B = "0000000010111011" then 

 output_tmp <= "0000000000001100";

elsif B = "0000000010111100" then 

 output_tmp <= "0000000000001110";

elsif B = "0000000010111101" then 

 output_tmp <= "0000000000001111";

elsif B = "0000000010111110" then 

 output_tmp <= "0000000000010001";

elsif B = "0000000010111111" then 

 output_tmp <= "0000000000010011";

elsif B = "0000000011000000" then 

 output_tmp <= "0000000000010101";

elsif B = "0000000011000001" then 

 output_tmp <= "0000000000010111";

elsif B = "0000000011000010" then 

 output_tmp <= "0000000000011000";

elsif B = "0000000011000011" then 

 output_tmp <= "0000000000011010";

elsif B = "0000000011000100" then 

 output_tmp <= "0000000000011100";

elsif B = "0000000011000101" then 

 output_tmp <= "0000000000011110";

elsif B = "0000000011000110" then 

 output_tmp <= "0000000000100000";

elsif B = "0000000011000111" then 

 output_tmp <= "0000000000100010";

elsif B = "0000000011001000" then 

 output_tmp <= "0000000000100100";

elsif B = "0000000011001001" then 

 output_tmp <= "0000000000100110";

elsif B = "0000000011001010" then 

 output_tmp <= "0000000000101000";

elsif B = "0000000011001011" then 

 output_tmp <= "0000000000101010";

elsif B = "0000000011001100" then 

 output_tmp <= "0000000000101100";

elsif B = "0000000011001101" then 

 output_tmp <= "0000000000101110";

elsif B = "0000000011001110" then 

 output_tmp <= "0000000000110000";

elsif B = "0000000011001111" then 

 output_tmp <= "0000000000110010";

elsif B = "0000000011010000" then 

 output_tmp <= "0000000000110101";

elsif B = "0000000011010001" then 

 output_tmp <= "0000000000110111";

elsif B = "0000000011010010" then 

 output_tmp <= "0000000000111001";

elsif B = "0000000011010011" then 

 output_tmp <= "0000000000111100";

elsif B = "0000000011010100" then 

 output_tmp <= "0000000000111110";

elsif B = "0000000011010101" then 

 output_tmp <= "0000000001000000";

elsif B = "0000000011010110" then 

 output_tmp <= "0000000001000011";

elsif B = "0000000011010111" then 

 output_tmp <= "0000000001000110";

elsif B = "0000000011011000" then 

 output_tmp <= "0000000001001000";

elsif B = "0000000011011001" then 

 output_tmp <= "0000000001001011";

elsif B = "0000000011011010" then 

 output_tmp <= "0000000001001110";

elsif B = "0000000011011011" then 

 output_tmp <= "0000000001010000";

elsif B = "0000000011011100" then 

 output_tmp <= "0000000001010011";

elsif B = "0000000011011101" then 

 output_tmp <= "0000000001010110";

elsif B = "0000000011011110" then 

 output_tmp <= "0000000001011010";

elsif B = "0000000011011111" then 

 output_tmp <= "0000000001011101";

elsif B = "0000000011100000" then 

 output_tmp <= "0000000001100000";

elsif B = "0000000011100001" then 

 output_tmp <= "0000000001100011";

elsif B = "0000000011100010" then 

 output_tmp <= "0000000001100111";

elsif B = "0000000011100011" then 

 output_tmp <= "0000000001101011";

elsif B = "0000000011100100" then 

 output_tmp <= "0000000001101111";

elsif B = "0000000011100101" then 

 output_tmp <= "0000000001110011";

elsif B = "0000000011100110" then 

 output_tmp <= "0000000001110111";

elsif B = "0000000011100111" then 

 output_tmp <= "0000000001111011";

elsif B = "0000000011101000" then 

 output_tmp <= "0000000001111111";

elsif B = "0000000011101001" then 

 output_tmp <= "0000000010000100";

elsif B = "0000000011101010" then 

 output_tmp <= "0000000010001001";

elsif B = "0000000011101011" then 

 output_tmp <= "0000000010001110";

elsif B = "0000000011101100" then 

 output_tmp <= "0000000010010100";

elsif B = "0000000011101101" then 

 output_tmp <= "0000000010011001";

elsif B = "0000000011101110" then 

 output_tmp <= "0000000010100000";

elsif B = "0000000011101111" then 

 output_tmp <= "0000000010100110";

elsif B = "0000000011110000" then 

 output_tmp <= "0000000010101101";

elsif B = "0000000011110001" then 

 output_tmp <= "0000000010110100";

elsif B = "0000000011110010" then 

 output_tmp <= "0000000010111100";

elsif B = "0000000011110011" then 

 output_tmp <= "0000000011000100";

elsif B = "0000000011110100" then 

 output_tmp <= "0000000011001101";

elsif B = "0000000011110101" then 

 output_tmp <= "0000000011010110";

elsif B = "0000000011110110" then 

 output_tmp <= "0000000011100000";

elsif B = "0000000011110111" then 

 output_tmp <= "0000000011101011";

elsif B = "0000000011111000" then 

 output_tmp <= "0000000011110111";

elsif B = "0000000011111001" then 

 output_tmp <= "0000000100000100";

elsif B = "0000000011111010" then 

 output_tmp <= "0000000100010010";

elsif B = "0000000011111011" then 

 output_tmp <= "0000000100100010";

elsif B = "0000000011111100" then 

 output_tmp <= "0000000100110011";

elsif B = "0000000011111101" then 

 output_tmp <= "0000000101000111";

elsif B = "0000000011111110" then 

 output_tmp <= "0000000101011100";

elsif B = "0000000011111111" then 

 output_tmp <= "0000000101110101";

elsif B = "0000000100000000" then 

 output_tmp <= "0000000110010001";

elsif B = "0000000100000001" then 

 output_tmp <= "0000000110110001";

elsif B = "0000000100000010" then 

 output_tmp <= "0000000111010110";

elsif B = "0000000100000011" then 

 output_tmp <= "0000001000000010";

elsif B = "0000000100000100" then 

 output_tmp <= "0000001000110111";

elsif B = "0000000100000101" then 

 output_tmp <= "0000001001110111";

elsif B = "0000000100000110" then 

 output_tmp <= "0000001011000111";

elsif B = "0000000100000111" then 

 output_tmp <= "0000001100101110";

elsif B = "0000000100001000" then 

 output_tmp <= "0000001110110111";

elsif B = "0000000100001001" then 

 output_tmp <= "0000010001110111";

elsif B = "0000000100001010" then 

 output_tmp <= "0000010110010110";

elsif B = "0000000100001011" then 

 output_tmp <= "0000011101110100";

elsif B = "0000000100001100" then 

 output_tmp <= "0000101100101111";

elsif B = "0000000100001101" then 

 output_tmp <= "0001011001100000";

elsif B = "0000000100001110" then 

 output_tmp <= "1111111111111111";

elsif B = "0000000100001111" then 

 output_tmp <= "1111010011010000";

elsif B = "0000000100010000" then 

 output_tmp <= "1111101001101000";

elsif B = "0000000100010001" then 

 output_tmp <= "1111110001000110";

elsif B = "0000000100010010" then 

 output_tmp <= "1111110100110101";

elsif B = "0000000100010011" then 

 output_tmp <= "1111110111000100";

elsif B = "0000000100010100" then 

 output_tmp <= "1111111000100100";

elsif B = "0000000100010101" then 

 output_tmp <= "1111111001101001";

elsif B = "0000000100010110" then 

 output_tmp <= "1111111010011100";

elsif B = "0000000100010111" then 

 output_tmp <= "1111111011000100";

elsif B = "0000000100011000" then 

 output_tmp <= "1111111011100100";

elsif B = "0000000100011001" then 

 output_tmp <= "1111111011111111";

elsif B = "0000000100011010" then 

 output_tmp <= "1111111100010101";

elsif B = "0000000100011011" then 

 output_tmp <= "1111111100100111";

elsif B = "0000000100011100" then 

 output_tmp <= "1111111100110111";

elsif B = "0000000100011101" then 

 output_tmp <= "1111111101000101";

elsif B = "0000000100011110" then 

 output_tmp <= "1111111101010010";

elsif B = "0000000100011111" then 

 output_tmp <= "1111111101011100";

elsif B = "0000000100100000" then 

 output_tmp <= "1111111101100110";

elsif B = "0000000100100001" then 

 output_tmp <= "1111111101101111";

elsif B = "0000000100100010" then 

 output_tmp <= "1111111101110111";

elsif B = "0000000100100011" then 

 output_tmp <= "1111111101111110";

elsif B = "0000000100100100" then 

 output_tmp <= "1111111110000100";

elsif B = "0000000100100101" then 

 output_tmp <= "1111111110001010";

elsif B = "0000000100100110" then 

 output_tmp <= "1111111110010000";

elsif B = "0000000100100111" then 

 output_tmp <= "1111111110010101";

elsif B = "0000000100101000" then 

 output_tmp <= "1111111110011001";

elsif B = "0000000100101001" then 

 output_tmp <= "1111111110011110";

elsif B = "0000000100101010" then 

 output_tmp <= "1111111110100010";

elsif B = "0000000100101011" then 

 output_tmp <= "1111111110100110";

elsif B = "0000000100101100" then 

 output_tmp <= "1111111110101001";

elsif B = "0000000100101101" then 

 output_tmp <= "1111111110101101";

elsif B = "0000000100101110" then 

 output_tmp <= "1111111110110000";

elsif B = "0000000100101111" then 

 output_tmp <= "1111111110110011";

elsif B = "0000000100110000" then 

 output_tmp <= "1111111110110110";

elsif B = "0000000100110001" then 

 output_tmp <= "1111111110111001";

elsif B = "0000000100110010" then 

 output_tmp <= "1111111110111011";

elsif B = "0000000100110011" then 

 output_tmp <= "1111111110111110";

elsif B = "0000000100110100" then 

 output_tmp <= "1111111111000000";

elsif B = "0000000100110101" then 

 output_tmp <= "1111111111000010";

elsif B = "0000000100110110" then 

 output_tmp <= "1111111111000100";

elsif B = "0000000100110111" then 

 output_tmp <= "1111111111000110";

elsif B = "0000000100111000" then 

 output_tmp <= "1111111111001000";

elsif B = "0000000100111001" then 

 output_tmp <= "1111111111001010";

elsif B = "0000000100111010" then 

 output_tmp <= "1111111111001100";

elsif B = "0000000100111011" then 

 output_tmp <= "1111111111001110";

elsif B = "0000000100111100" then 

 output_tmp <= "1111111111010000";

elsif B = "0000000100111101" then 

 output_tmp <= "1111111111010001";

elsif B = "0000000100111110" then 

 output_tmp <= "1111111111010011";

elsif B = "0000000100111111" then 

 output_tmp <= "1111111111010101";

elsif B = "0000000101000000" then 

 output_tmp <= "1111111111010110";

elsif B = "0000000101000001" then 

 output_tmp <= "1111111111011000";

elsif B = "0000000101000010" then 

 output_tmp <= "1111111111011001";

elsif B = "0000000101000011" then 

 output_tmp <= "1111111111011010";

elsif B = "0000000101000100" then 

 output_tmp <= "1111111111011100";

elsif B = "0000000101000101" then 

 output_tmp <= "1111111111011101";

elsif B = "0000000101000110" then 

 output_tmp <= "1111111111011110";

elsif B = "0000000101000111" then 

 output_tmp <= "1111111111100000";

elsif B = "0000000101001000" then 

 output_tmp <= "1111111111100001";

elsif B = "0000000101001001" then 

 output_tmp <= "1111111111100010";

elsif B = "0000000101001010" then 

 output_tmp <= "1111111111100011";

elsif B = "0000000101001011" then 

 output_tmp <= "1111111111100100";

elsif B = "0000000101001100" then 

 output_tmp <= "1111111111100101";

elsif B = "0000000101001101" then 

 output_tmp <= "1111111111100111";

elsif B = "0000000101001110" then 

 output_tmp <= "1111111111101000";

elsif B = "0000000101001111" then 

 output_tmp <= "1111111111101001";

elsif B = "0000000101010000" then 

 output_tmp <= "1111111111101010";

elsif B = "0000000101010001" then 

 output_tmp <= "1111111111101011";

elsif B = "0000000101010010" then 

 output_tmp <= "1111111111101100";

elsif B = "0000000101010011" then 

 output_tmp <= "1111111111101101";

elsif B = "0000000101010100" then 

 output_tmp <= "1111111111101110";

elsif B = "0000000101010101" then 

 output_tmp <= "1111111111101111";

elsif B = "0000000101010110" then 

 output_tmp <= "1111111111110000";

elsif B = "0000000101010111" then 

 output_tmp <= "1111111111110001";

elsif B = "0000000101011000" then 

 output_tmp <= "1111111111110010";

elsif B = "0000000101011001" then 

 output_tmp <= "1111111111110011";

elsif B = "0000000101011010" then 

 output_tmp <= "1111111111110100";

elsif B = "0000000101011011" then 

 output_tmp <= "1111111111110100";

elsif B = "0000000101011100" then 

 output_tmp <= "1111111111110101";

elsif B = "0000000101011101" then 

 output_tmp <= "1111111111110110";

elsif B = "0000000101011110" then 

 output_tmp <= "1111111111110111";

elsif B = "0000000101011111" then 

 output_tmp <= "1111111111111000";

elsif B = "0000000101100000" then 

 output_tmp <= "1111111111111001";

elsif B = "0000000101100001" then 

 output_tmp <= "1111111111111010";

elsif B = "0000000101100010" then 

 output_tmp <= "1111111111111011";

elsif B = "0000000101100011" then 

 output_tmp <= "1111111111111100";

elsif B = "0000000101100100" then 

 output_tmp <= "1111111111111101";

elsif B = "0000000101100101" then 

 output_tmp <= "1111111111111101";

elsif B = "0000000101100110" then 

 output_tmp <= "1111111111111110";

elsif B = "0000000101100111" then 

 output_tmp <= "1111111111111111";

elsif B = "0000000101101000" then 

 output_tmp <= "0000000000000000";

else

output_tmp <= "ZZZZZZZZZZZZZZZZ";


end if;
		---------------------
		-- cotangent(b)
		elsif (cotB = '1') then
		  if B = "0000000000000000" then 


 output_tmp <= "1111111111111111";

elsif B = "0000000000000001" then 

 output_tmp <= "0001011001100000";

elsif B = "0000000000000010" then 

 output_tmp <= "0000101100101111";

elsif B = "0000000000000011" then 

 output_tmp <= "0000011101110100";

elsif B = "0000000000000100" then 

 output_tmp <= "0000010110010110";

elsif B = "0000000000000101" then 

 output_tmp <= "0000010001110111";

elsif B = "0000000000000110" then 

 output_tmp <= "0000001110110111";

elsif B = "0000000000000111" then 

 output_tmp <= "0000001100101110";

elsif B = "0000000000001000" then 

 output_tmp <= "0000001011000111";

elsif B = "0000000000001001" then 

 output_tmp <= "0000001001110111";

elsif B = "0000000000001010" then 

 output_tmp <= "0000001000110111";

elsif B = "0000000000001011" then 

 output_tmp <= "0000001000000010";

elsif B = "0000000000001100" then 

 output_tmp <= "0000000111010110";

elsif B = "0000000000001101" then 

 output_tmp <= "0000000110110001";

elsif B = "0000000000001110" then 

 output_tmp <= "0000000110010001";

elsif B = "0000000000001111" then 

 output_tmp <= "0000000101110101";

elsif B = "0000000000010000" then 

 output_tmp <= "0000000101011100";

elsif B = "0000000000010001" then 

 output_tmp <= "0000000101000111";

elsif B = "0000000000010010" then 

 output_tmp <= "0000000100110011";

elsif B = "0000000000010011" then 

 output_tmp <= "0000000100100010";

elsif B = "0000000000010100" then 

 output_tmp <= "0000000100010010";

elsif B = "0000000000010101" then 

 output_tmp <= "0000000100000100";

elsif B = "0000000000010110" then 

 output_tmp <= "0000000011110111";

elsif B = "0000000000010111" then 

 output_tmp <= "0000000011101011";

elsif B = "0000000000011000" then 

 output_tmp <= "0000000011100000";

elsif B = "0000000000011001" then 

 output_tmp <= "0000000011010110";

elsif B = "0000000000011010" then 

 output_tmp <= "0000000011001101";

elsif B = "0000000000011011" then 

 output_tmp <= "0000000011000100";

elsif B = "0000000000011100" then 

 output_tmp <= "0000000010111100";

elsif B = "0000000000011101" then 

 output_tmp <= "0000000010110100";

elsif B = "0000000000011110" then 

 output_tmp <= "0000000010101101";

elsif B = "0000000000011111" then 

 output_tmp <= "0000000010100110";

elsif B = "0000000000100000" then 

 output_tmp <= "0000000010100000";

elsif B = "0000000000100001" then 

 output_tmp <= "0000000010011001";

elsif B = "0000000000100010" then 

 output_tmp <= "0000000010010100";

elsif B = "0000000000100011" then 

 output_tmp <= "0000000010001110";

elsif B = "0000000000100100" then 

 output_tmp <= "0000000010001001";

elsif B = "0000000000100101" then 

 output_tmp <= "0000000010000100";

elsif B = "0000000000100110" then 

 output_tmp <= "0000000001111111";

elsif B = "0000000000100111" then 

 output_tmp <= "0000000001111011";

elsif B = "0000000000101000" then 

 output_tmp <= "0000000001110111";

elsif B = "0000000000101001" then 

 output_tmp <= "0000000001110011";

elsif B = "0000000000101010" then 

 output_tmp <= "0000000001101111";

elsif B = "0000000000101011" then 

 output_tmp <= "0000000001101011";

elsif B = "0000000000101100" then 

 output_tmp <= "0000000001100111";

elsif B = "0000000000101101" then 

 output_tmp <= "0000000001100100";

elsif B = "0000000000101110" then 

 output_tmp <= "0000000001100000";

elsif B = "0000000000101111" then 

 output_tmp <= "0000000001011101";

elsif B = "0000000000110000" then 

 output_tmp <= "0000000001011010";

elsif B = "0000000000110001" then 

 output_tmp <= "0000000001010110";

elsif B = "0000000000110010" then 

 output_tmp <= "0000000001010011";

elsif B = "0000000000110011" then 

 output_tmp <= "0000000001010000";

elsif B = "0000000000110100" then 

 output_tmp <= "0000000001001110";

elsif B = "0000000000110101" then 

 output_tmp <= "0000000001001011";

elsif B = "0000000000110110" then 

 output_tmp <= "0000000001001000";

elsif B = "0000000000110111" then 

 output_tmp <= "0000000001000110";

elsif B = "0000000000111000" then 

 output_tmp <= "0000000001000011";

elsif B = "0000000000111001" then 

 output_tmp <= "0000000001000000";

elsif B = "0000000000111010" then 

 output_tmp <= "0000000000111110";

elsif B = "0000000000111011" then 

 output_tmp <= "0000000000111100";

elsif B = "0000000000111100" then 

 output_tmp <= "0000000000111001";

elsif B = "0000000000111101" then 

 output_tmp <= "0000000000110111";

elsif B = "0000000000111110" then 

 output_tmp <= "0000000000110101";

elsif B = "0000000000111111" then 

 output_tmp <= "0000000000110010";

elsif B = "0000000001000000" then 

 output_tmp <= "0000000000110000";

elsif B = "0000000001000001" then 

 output_tmp <= "0000000000101110";

elsif B = "0000000001000010" then 

 output_tmp <= "0000000000101100";

elsif B = "0000000001000011" then 

 output_tmp <= "0000000000101010";

elsif B = "0000000001000100" then 

 output_tmp <= "0000000000101000";

elsif B = "0000000001000101" then 

 output_tmp <= "0000000000100110";

elsif B = "0000000001000110" then 

 output_tmp <= "0000000000100100";

elsif B = "0000000001000111" then 

 output_tmp <= "0000000000100010";

elsif B = "0000000001001000" then 

 output_tmp <= "0000000000100000";

elsif B = "0000000001001001" then 

 output_tmp <= "0000000000011110";

elsif B = "0000000001001010" then 

 output_tmp <= "0000000000011100";

elsif B = "0000000001001011" then 

 output_tmp <= "0000000000011010";

elsif B = "0000000001001100" then 

 output_tmp <= "0000000000011000";

elsif B = "0000000001001101" then 

 output_tmp <= "0000000000010111";

elsif B = "0000000001001110" then 

 output_tmp <= "0000000000010101";

elsif B = "0000000001001111" then 

 output_tmp <= "0000000000010011";

elsif B = "0000000001010000" then 

 output_tmp <= "0000000000010001";

elsif B = "0000000001010001" then 

 output_tmp <= "0000000000001111";

elsif B = "0000000001010010" then 

 output_tmp <= "0000000000001110";

elsif B = "0000000001010011" then 

 output_tmp <= "0000000000001100";

elsif B = "0000000001010100" then 

 output_tmp <= "0000000000001010";

elsif B = "0000000001010101" then 

 output_tmp <= "0000000000001000";

elsif B = "0000000001010110" then 

 output_tmp <= "0000000000000110";

elsif B = "0000000001010111" then 

 output_tmp <= "0000000000000101";

elsif B = "0000000001011000" then 

 output_tmp <= "0000000000000011";

elsif B = "0000000001011001" then 

 output_tmp <= "0000000000000001";

elsif B = "0000000001011010" then 

 output_tmp <= "0000000000000000";

elsif B = "0000000001011011" then 

 output_tmp <= "1111111111111111";

elsif B = "0000000001011100" then 

 output_tmp <= "1111111111111110";

elsif B = "0000000001011101" then 

 output_tmp <= "1111111111111101";

elsif B = "0000000001011110" then 

 output_tmp <= "1111111111111101";

elsif B = "0000000001011111" then 

 output_tmp <= "1111111111111100";

elsif B = "0000000001100000" then 

 output_tmp <= "1111111111111011";

elsif B = "0000000001100001" then 

 output_tmp <= "1111111111111010";

elsif B = "0000000001100010" then 

 output_tmp <= "1111111111111001";

elsif B = "0000000001100011" then 

 output_tmp <= "1111111111111000";

elsif B = "0000000001100100" then 

 output_tmp <= "1111111111110111";

elsif B = "0000000001100101" then 

 output_tmp <= "1111111111110110";

elsif B = "0000000001100110" then 

 output_tmp <= "1111111111110101";

elsif B = "0000000001100111" then 

 output_tmp <= "1111111111110100";

elsif B = "0000000001101000" then 

 output_tmp <= "1111111111110100";

elsif B = "0000000001101001" then 

 output_tmp <= "1111111111110011";

elsif B = "0000000001101010" then 

 output_tmp <= "1111111111110010";

elsif B = "0000000001101011" then 

 output_tmp <= "1111111111110001";

elsif B = "0000000001101100" then 

 output_tmp <= "1111111111110000";

elsif B = "0000000001101101" then 

 output_tmp <= "1111111111101111";

elsif B = "0000000001101110" then 

 output_tmp <= "1111111111101110";

elsif B = "0000000001101111" then 

 output_tmp <= "1111111111101101";

elsif B = "0000000001110000" then 

 output_tmp <= "1111111111101100";

elsif B = "0000000001110001" then 

 output_tmp <= "1111111111101011";

elsif B = "0000000001110010" then 

 output_tmp <= "1111111111101010";

elsif B = "0000000001110011" then 

 output_tmp <= "1111111111101001";

elsif B = "0000000001110100" then 

 output_tmp <= "1111111111101000";

elsif B = "0000000001110101" then 

 output_tmp <= "1111111111100111";

elsif B = "0000000001110110" then 

 output_tmp <= "1111111111100101";

elsif B = "0000000001110111" then 

 output_tmp <= "1111111111100100";

elsif B = "0000000001111000" then 

 output_tmp <= "1111111111100011";

elsif B = "0000000001111001" then 

 output_tmp <= "1111111111100010";

elsif B = "0000000001111010" then 

 output_tmp <= "1111111111100001";

elsif B = "0000000001111011" then 

 output_tmp <= "1111111111100000";

elsif B = "0000000001111100" then 

 output_tmp <= "1111111111011110";

elsif B = "0000000001111101" then 

 output_tmp <= "1111111111011101";

elsif B = "0000000001111110" then 

 output_tmp <= "1111111111011100";

elsif B = "0000000001111111" then 

 output_tmp <= "1111111111011010";

elsif B = "0000000010000000" then 

 output_tmp <= "1111111111011001";

elsif B = "0000000010000001" then 

 output_tmp <= "1111111111011000";

elsif B = "0000000010000010" then 

 output_tmp <= "1111111111010110";

elsif B = "0000000010000011" then 

 output_tmp <= "1111111111010101";

elsif B = "0000000010000100" then 

 output_tmp <= "1111111111010011";

elsif B = "0000000010000101" then 

 output_tmp <= "1111111111010001";

elsif B = "0000000010000110" then 

 output_tmp <= "1111111111010000";

elsif B = "0000000010000111" then 

 output_tmp <= "1111111111001110";

elsif B = "0000000010001000" then 

 output_tmp <= "1111111111001100";

elsif B = "0000000010001001" then 

 output_tmp <= "1111111111001010";

elsif B = "0000000010001010" then 

 output_tmp <= "1111111111001000";

elsif B = "0000000010001011" then 

 output_tmp <= "1111111111000110";

elsif B = "0000000010001100" then 

 output_tmp <= "1111111111000100";

elsif B = "0000000010001101" then 

 output_tmp <= "1111111111000010";

elsif B = "0000000010001110" then 

 output_tmp <= "1111111111000000";

elsif B = "0000000010001111" then 

 output_tmp <= "1111111110111110";

elsif B = "0000000010010000" then 

 output_tmp <= "1111111110111011";

elsif B = "0000000010010001" then 

 output_tmp <= "1111111110111001";

elsif B = "0000000010010010" then 

 output_tmp <= "1111111110110110";

elsif B = "0000000010010011" then 

 output_tmp <= "1111111110110011";

elsif B = "0000000010010100" then 

 output_tmp <= "1111111110110000";

elsif B = "0000000010010101" then 

 output_tmp <= "1111111110101101";

elsif B = "0000000010010110" then 

 output_tmp <= "1111111110101001";

elsif B = "0000000010010111" then 

 output_tmp <= "1111111110100110";

elsif B = "0000000010011000" then 

 output_tmp <= "1111111110100010";

elsif B = "0000000010011001" then 

 output_tmp <= "1111111110011110";

elsif B = "0000000010011010" then 

 output_tmp <= "1111111110011001";

elsif B = "0000000010011011" then 

 output_tmp <= "1111111110010101";

elsif B = "0000000010011100" then 

 output_tmp <= "1111111110010000";

elsif B = "0000000010011101" then 

 output_tmp <= "1111111110001010";

elsif B = "0000000010011110" then 

 output_tmp <= "1111111110000100";

elsif B = "0000000010011111" then 

 output_tmp <= "1111111101111110";

elsif B = "0000000010100000" then 

 output_tmp <= "1111111101110111";

elsif B = "0000000010100001" then 

 output_tmp <= "1111111101101111";

elsif B = "0000000010100010" then 

 output_tmp <= "1111111101100110";

elsif B = "0000000010100011" then 

 output_tmp <= "1111111101011100";

elsif B = "0000000010100100" then 

 output_tmp <= "1111111101010010";

elsif B = "0000000010100101" then 

 output_tmp <= "1111111101000101";

elsif B = "0000000010100110" then 

 output_tmp <= "1111111100110111";

elsif B = "0000000010100111" then 

 output_tmp <= "1111111100100111";

elsif B = "0000000010101000" then 

 output_tmp <= "1111111100010101";

elsif B = "0000000010101001" then 

 output_tmp <= "1111111011111111";

elsif B = "0000000010101010" then 

 output_tmp <= "1111111011100100";

elsif B = "0000000010101011" then 

 output_tmp <= "1111111011000100";

elsif B = "0000000010101100" then 

 output_tmp <= "1111111010011100";

elsif B = "0000000010101101" then 

 output_tmp <= "1111111001101001";

elsif B = "0000000010101110" then 

 output_tmp <= "1111111000100100";

elsif B = "0000000010101111" then 

 output_tmp <= "1111110111000100";

elsif B = "0000000010110000" then 

 output_tmp <= "1111110100110101";

elsif B = "0000000010110001" then 

 output_tmp <= "1111110001000110";

elsif B = "0000000010110010" then 

 output_tmp <= "1111101001101000";

elsif B = "0000000010110011" then 

 output_tmp <= "1111010011010000";

elsif B = "0000000010110100" then 

 output_tmp <= "1000000000000000";

elsif B = "0000000010110101" then 

 output_tmp <= "0001011001100000";

elsif B = "0000000010110110" then 

 output_tmp <= "0000101100101111";

elsif B = "0000000010110111" then 

 output_tmp <= "0000011101110100";

elsif B = "0000000010111000" then 

 output_tmp <= "0000010110010110";

elsif B = "0000000010111001" then 

 output_tmp <= "0000010001110111";

elsif B = "0000000010111010" then 

 output_tmp <= "0000001110110111";

elsif B = "0000000010111011" then 

 output_tmp <= "0000001100101110";

elsif B = "0000000010111100" then 

 output_tmp <= "0000001011000111";

elsif B = "0000000010111101" then 

 output_tmp <= "0000001001110111";

elsif B = "0000000010111110" then 

 output_tmp <= "0000001000110111";

elsif B = "0000000010111111" then 

 output_tmp <= "0000001000000010";

elsif B = "0000000011000000" then 

 output_tmp <= "0000000111010110";

elsif B = "0000000011000001" then 

 output_tmp <= "0000000110110001";

elsif B = "0000000011000010" then 

 output_tmp <= "0000000110010001";

elsif B = "0000000011000011" then 

 output_tmp <= "0000000101110101";

elsif B = "0000000011000100" then 

 output_tmp <= "0000000101011100";

elsif B = "0000000011000101" then 

 output_tmp <= "0000000101000111";

elsif B = "0000000011000110" then 

 output_tmp <= "0000000100110011";

elsif B = "0000000011000111" then 

 output_tmp <= "0000000100100010";

elsif B = "0000000011001000" then 

 output_tmp <= "0000000100010010";

elsif B = "0000000011001001" then 

 output_tmp <= "0000000100000100";

elsif B = "0000000011001010" then 

 output_tmp <= "0000000011110111";

elsif B = "0000000011001011" then 

 output_tmp <= "0000000011101011";

elsif B = "0000000011001100" then 

 output_tmp <= "0000000011100000";

elsif B = "0000000011001101" then 

 output_tmp <= "0000000011010110";

elsif B = "0000000011001110" then 

 output_tmp <= "0000000011001101";

elsif B = "0000000011001111" then 

 output_tmp <= "0000000011000100";

elsif B = "0000000011010000" then 

 output_tmp <= "0000000010111100";

elsif B = "0000000011010001" then 

 output_tmp <= "0000000010110100";

elsif B = "0000000011010010" then 

 output_tmp <= "0000000010101101";

elsif B = "0000000011010011" then 

 output_tmp <= "0000000010100110";

elsif B = "0000000011010100" then 

 output_tmp <= "0000000010100000";

elsif B = "0000000011010101" then 

 output_tmp <= "0000000010011001";

elsif B = "0000000011010110" then 

 output_tmp <= "0000000010010100";

elsif B = "0000000011010111" then 

 output_tmp <= "0000000010001110";

elsif B = "0000000011011000" then 

 output_tmp <= "0000000010001001";

elsif B = "0000000011011001" then 

 output_tmp <= "0000000010000100";

elsif B = "0000000011011010" then 

 output_tmp <= "0000000001111111";

elsif B = "0000000011011011" then 

 output_tmp <= "0000000001111011";

elsif B = "0000000011011100" then 

 output_tmp <= "0000000001110111";

elsif B = "0000000011011101" then 

 output_tmp <= "0000000001110011";

elsif B = "0000000011011110" then 

 output_tmp <= "0000000001101111";

elsif B = "0000000011011111" then 

 output_tmp <= "0000000001101011";

elsif B = "0000000011100000" then 

 output_tmp <= "0000000001100111";

elsif B = "0000000011100001" then 

 output_tmp <= "0000000001100100";

elsif B = "0000000011100010" then 

 output_tmp <= "0000000001100000";

elsif B = "0000000011100011" then 

 output_tmp <= "0000000001011101";

elsif B = "0000000011100100" then 

 output_tmp <= "0000000001011010";

elsif B = "0000000011100101" then 

 output_tmp <= "0000000001010110";

elsif B = "0000000011100110" then 

 output_tmp <= "0000000001010011";

elsif B = "0000000011100111" then 

 output_tmp <= "0000000001010000";

elsif B = "0000000011101000" then 

 output_tmp <= "0000000001001110";

elsif B = "0000000011101001" then 

 output_tmp <= "0000000001001011";

elsif B = "0000000011101010" then 

 output_tmp <= "0000000001001000";

elsif B = "0000000011101011" then 

 output_tmp <= "0000000001000110";

elsif B = "0000000011101100" then 

 output_tmp <= "0000000001000011";

elsif B = "0000000011101101" then 

 output_tmp <= "0000000001000000";

elsif B = "0000000011101110" then 

 output_tmp <= "0000000000111110";

elsif B = "0000000011101111" then 

 output_tmp <= "0000000000111100";

elsif B = "0000000011110000" then 

 output_tmp <= "0000000000111001";

elsif B = "0000000011110001" then 

 output_tmp <= "0000000000110111";

elsif B = "0000000011110010" then 

 output_tmp <= "0000000000110101";

elsif B = "0000000011110011" then 

 output_tmp <= "0000000000110010";

elsif B = "0000000011110100" then 

 output_tmp <= "0000000000110000";

elsif B = "0000000011110101" then 

 output_tmp <= "0000000000101110";

elsif B = "0000000011110110" then 

 output_tmp <= "0000000000101100";

elsif B = "0000000011110111" then 

 output_tmp <= "0000000000101010";

elsif B = "0000000011111000" then 

 output_tmp <= "0000000000101000";

elsif B = "0000000011111001" then 

 output_tmp <= "0000000000100110";

elsif B = "0000000011111010" then 

 output_tmp <= "0000000000100100";

elsif B = "0000000011111011" then 

 output_tmp <= "0000000000100010";

elsif B = "0000000011111100" then 

 output_tmp <= "0000000000100000";

elsif B = "0000000011111101" then 

 output_tmp <= "0000000000011110";

elsif B = "0000000011111110" then 

 output_tmp <= "0000000000011100";

elsif B = "0000000011111111" then 

 output_tmp <= "0000000000011010";

elsif B = "0000000100000000" then 

 output_tmp <= "0000000000011000";

elsif B = "0000000100000001" then 

 output_tmp <= "0000000000010111";

elsif B = "0000000100000010" then 

 output_tmp <= "0000000000010101";

elsif B = "0000000100000011" then 

 output_tmp <= "0000000000010011";

elsif B = "0000000100000100" then 

 output_tmp <= "0000000000010001";

elsif B = "0000000100000101" then 

 output_tmp <= "0000000000001111";

elsif B = "0000000100000110" then 

 output_tmp <= "0000000000001110";

elsif B = "0000000100000111" then 

 output_tmp <= "0000000000001100";

elsif B = "0000000100001000" then 

 output_tmp <= "0000000000001010";

elsif B = "0000000100001001" then 

 output_tmp <= "0000000000001000";

elsif B = "0000000100001010" then 

 output_tmp <= "0000000000000110";

elsif B = "0000000100001011" then 

 output_tmp <= "0000000000000101";

elsif B = "0000000100001100" then 

 output_tmp <= "0000000000000011";

elsif B = "0000000100001101" then 

 output_tmp <= "0000000000000001";

elsif B = "0000000100001110" then 

 output_tmp <= "0000000000000000";

elsif B = "0000000100001111" then 

 output_tmp <= "1111111111111111";

elsif B = "0000000100010000" then 

 output_tmp <= "1111111111111110";

elsif B = "0000000100010001" then 

 output_tmp <= "1111111111111101";

elsif B = "0000000100010010" then 

 output_tmp <= "1111111111111101";

elsif B = "0000000100010011" then 

 output_tmp <= "1111111111111100";

elsif B = "0000000100010100" then 

 output_tmp <= "1111111111111011";

elsif B = "0000000100010101" then 

 output_tmp <= "1111111111111010";

elsif B = "0000000100010110" then 

 output_tmp <= "1111111111111001";

elsif B = "0000000100010111" then 

 output_tmp <= "1111111111111000";

elsif B = "0000000100011000" then 

 output_tmp <= "1111111111110111";

elsif B = "0000000100011001" then 

 output_tmp <= "1111111111110110";

elsif B = "0000000100011010" then 

 output_tmp <= "1111111111110101";

elsif B = "0000000100011011" then 

 output_tmp <= "1111111111110100";

elsif B = "0000000100011100" then 

 output_tmp <= "1111111111110100";

elsif B = "0000000100011101" then 

 output_tmp <= "1111111111110011";

elsif B = "0000000100011110" then 

 output_tmp <= "1111111111110010";

elsif B = "0000000100011111" then 

 output_tmp <= "1111111111110001";

elsif B = "0000000100100000" then 

 output_tmp <= "1111111111110000";

elsif B = "0000000100100001" then 

 output_tmp <= "1111111111101111";

elsif B = "0000000100100010" then 

 output_tmp <= "1111111111101110";

elsif B = "0000000100100011" then 

 output_tmp <= "1111111111101101";

elsif B = "0000000100100100" then 

 output_tmp <= "1111111111101100";

elsif B = "0000000100100101" then 

 output_tmp <= "1111111111101011";

elsif B = "0000000100100110" then 

 output_tmp <= "1111111111101010";

elsif B = "0000000100100111" then 

 output_tmp <= "1111111111101001";

elsif B = "0000000100101000" then 

 output_tmp <= "1111111111101000";

elsif B = "0000000100101001" then 

 output_tmp <= "1111111111100111";

elsif B = "0000000100101010" then 

 output_tmp <= "1111111111100101";

elsif B = "0000000100101011" then 

 output_tmp <= "1111111111100100";

elsif B = "0000000100101100" then 

 output_tmp <= "1111111111100011";

elsif B = "0000000100101101" then 

 output_tmp <= "1111111111100010";

elsif B = "0000000100101110" then 

 output_tmp <= "1111111111100001";

elsif B = "0000000100101111" then 

 output_tmp <= "1111111111100000";

elsif B = "0000000100110000" then 

 output_tmp <= "1111111111011110";

elsif B = "0000000100110001" then 

 output_tmp <= "1111111111011101";

elsif B = "0000000100110010" then 

 output_tmp <= "1111111111011100";

elsif B = "0000000100110011" then 

 output_tmp <= "1111111111011010";

elsif B = "0000000100110100" then 

 output_tmp <= "1111111111011001";

elsif B = "0000000100110101" then 

 output_tmp <= "1111111111011000";

elsif B = "0000000100110110" then 

 output_tmp <= "1111111111010110";

elsif B = "0000000100110111" then 

 output_tmp <= "1111111111010101";

elsif B = "0000000100111000" then 

 output_tmp <= "1111111111010011";

elsif B = "0000000100111001" then 

 output_tmp <= "1111111111010001";

elsif B = "0000000100111010" then 

 output_tmp <= "1111111111010000";

elsif B = "0000000100111011" then 

 output_tmp <= "1111111111001110";

elsif B = "0000000100111100" then 

 output_tmp <= "1111111111001100";

elsif B = "0000000100111101" then 

 output_tmp <= "1111111111001010";

elsif B = "0000000100111110" then 

 output_tmp <= "1111111111001000";

elsif B = "0000000100111111" then 

 output_tmp <= "1111111111000110";

elsif B = "0000000101000000" then 

 output_tmp <= "1111111111000100";

elsif B = "0000000101000001" then 

 output_tmp <= "1111111111000010";

elsif B = "0000000101000010" then 

 output_tmp <= "1111111111000000";

elsif B = "0000000101000011" then 

 output_tmp <= "1111111110111110";

elsif B = "0000000101000100" then 

 output_tmp <= "1111111110111011";

elsif B = "0000000101000101" then 

 output_tmp <= "1111111110111001";

elsif B = "0000000101000110" then 

 output_tmp <= "1111111110110110";

elsif B = "0000000101000111" then 

 output_tmp <= "1111111110110011";

elsif B = "0000000101001000" then 

 output_tmp <= "1111111110110000";

elsif B = "0000000101001001" then 

 output_tmp <= "1111111110101101";

elsif B = "0000000101001010" then 

 output_tmp <= "1111111110101001";

elsif B = "0000000101001011" then 

 output_tmp <= "1111111110100110";

elsif B = "0000000101001100" then 

 output_tmp <= "1111111110100010";

elsif B = "0000000101001101" then 

 output_tmp <= "1111111110011110";

elsif B = "0000000101001110" then 

 output_tmp <= "1111111110011001";

elsif B = "0000000101001111" then 

 output_tmp <= "1111111110010101";

elsif B = "0000000101010000" then 

 output_tmp <= "1111111110010000";

elsif B = "0000000101010001" then 

 output_tmp <= "1111111110001010";

elsif B = "0000000101010010" then 

 output_tmp <= "1111111110000100";

elsif B = "0000000101010011" then 

 output_tmp <= "1111111101111110";

elsif B = "0000000101010100" then 

 output_tmp <= "1111111101110111";

elsif B = "0000000101010101" then 

 output_tmp <= "1111111101101111";

elsif B = "0000000101010110" then 

 output_tmp <= "1111111101100110";

elsif B = "0000000101010111" then 

 output_tmp <= "1111111101011100";

elsif B = "0000000101011000" then 

 output_tmp <= "1111111101010010";

elsif B = "0000000101011001" then 

 output_tmp <= "1111111101000101";

elsif B = "0000000101011010" then 

 output_tmp <= "1111111100110111";

elsif B = "0000000101011011" then 

 output_tmp <= "1111111100100111";

elsif B = "0000000101011100" then 

 output_tmp <= "1111111100010101";

elsif B = "0000000101011101" then 

 output_tmp <= "1111111011111111";

elsif B = "0000000101011110" then 

 output_tmp <= "1111111011100100";

elsif B = "0000000101011111" then 

 output_tmp <= "1111111011000100";

elsif B = "0000000101100000" then 

 output_tmp <= "1111111010011100";

elsif B = "0000000101100001" then 

 output_tmp <= "1111111001101001";

elsif B = "0000000101100010" then 

 output_tmp <= "1111111000100100";

elsif B = "0000000101100011" then 

 output_tmp <= "1111110111000100";

elsif B = "0000000101100100" then 

 output_tmp <= "1111110100110101";

elsif B = "0000000101100101" then 

 output_tmp <= "1111110001000110";

elsif B = "0000000101100110" then 

 output_tmp <= "1111101001101000";

elsif B = "0000000101100111" then 

 output_tmp <= "1111010011010000";

elsif B = "0000000101101000" then 

 output_tmp <= "1000000000000000";

else

output_tmp <= "ZZZZZZZZZZZZZZZZ";


end if;
		---------------------
		-- Random
		elsif (RND = '1') then                                              
		  output_tmp <= ('0' & rnd5(15 downto 1));
		---------------------
		---------------------
			end if;
		if (AcmpB = '0') then
		   ALU_Zout <= not(output_tmp(0) or output_tmp(1) or output_tmp(2) or output_tmp(3) 
				  or output_tmp(7) or output_tmp(6) or output_tmp(5) or output_tmp(4) or 
				  output_tmp(8) or output_tmp(9) or output_tmp(10) or output_tmp(11) or 
				  output_tmp(15) or output_tmp(14) or output_tmp(13) or output_tmp(12));
   		end if;
	end if;
	end if;
  end process;
END dataflow;





