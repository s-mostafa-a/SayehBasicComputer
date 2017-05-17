library IEEE;
use IEEE.std_logic_1164.all;

entity controller is
  --port (register_load, register_shift : out std_logic;
    --clk, rst : in std_logic);
--end entity;
PORT (  -- for port manager
        portDataReady: in std_logic;
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
  end entity;

architecture rtl of controller is
  type state is (reset, fetch2,fetch1,exe,shadowexe,halt,pcinc,writeFullToReg1,writeFullToReg2,writeToMem1,writeToMem2,writeHighToReg,writeLowToReg,decide,exe16,cmp1,cmp2,inputFromPort1,inputFromPort2,inputFromMem1,inputFromMem2,writeToPort1,writeToPort2);
  signal current_state : state;
  signal next_state : state;
  signal shadowEn: std_logic;
begin
  shadowEN <= '0' when IRout(15 downto 12) = "1111" else
              '0' when IRout(15 downto 12) = "0000" and IRout(11 downto 8) > "0110" else
              '1' ; ---------------------------------------------------------------------------------------------------------------------------moshkel injast ke gahi uu ham else ast
  -- next to current
  process (clk, External_reset)
  begin
    if External_reset = '1' then
      current_state <= reset;
    elsif clk'event and clk = '1' then
      current_state <= next_state; -------- in momkene moshkel saz beshe--ye state e kazaii ezafe mikonam
    end if;
  end process;

 -- next based on state
  process (current_state,IRout,Cout,Zout,memDataReady)
  begin
    -- reseting
        --Readmem <= '0'; mirine
        --Writemem <= '0'; mirine
        --for controller
        Readport <= '0'; 
        Writeport <= '0';
        --for alu
        B15to0 <= '0';
        AandB <= '0';
        AorB <= '0';
        NotB <= '0';
        AaddB <= '0';
        AsubB <= '0';
        AmulB <= '0';
	      AdivB <= '0';
	      Bsquar <= '0';
	      sinB <= '0';
	      cosB <= '0';
	      tanB <= '0';
	      cotB <= '0';
	      RND <= '0';
        AcmpB <= '0';
        BShr <= '0';
        BShl <= '0';
        Btws  <= '0';
        ALU_On_DataBus <= '0';
        --flags
        Cset <= '0';
        Creset <= '0';
        Zset <= '0';
        Zreset <= '0';
        srload <= '0';
        --register file
        rflwrite <= '0';
        rfhwrite <= '0';
        Rd_On_Addressbus <= '0';
        Rs_On_Addressbus <= '0';
        --address unit
        resetPC <= '0';
        PCPlusOne <= '0';
        PCPlusI <= '0';
        RPlusI <= '0';
        RPlusZero <= '0';
        PCEnable <= '0';
        Address_On_Bus <= '0';
        --wp
        wpadd <= '0';
        wpreset <= '0';
        --IR
        IRload <= '0';
        --shadow
        shad <= '0';

    case current_state is
      when reset =>
        resetPC <= '1';
        wpreset <= '1';
        PCEnable <= '1';
        Creset <= '1';
        Zreset <= '1';
        next_state <= fetch1;
        --register_shift <= '1';
      when fetch1 =>
        readMem <= '1';
        next_state <= fetch2;
        IRload <= '1';
      when fetch2 =>
        ALU_On_DataBus <= '0';
        readMem <= '1';
        writeMem <= '0';
        srload <= '0';
        IRload <= '1';
        next_state <= decide;
      when decide =>
        ALU_On_DataBus <= '0';
        readMem <= '0';
        writeMem <= '0';
        srload <= '0';
        IRload <= '0';
        next_state <= exe;
      when exe =>
        if shadowEn = '1' then -- dastoor 8 biti ast
          shad <='0';
          if IRout(15 downto 8) = "00000000" then
            next_state <= shadowexe;
          elsif IRout(15 downto 8) = "00000001" then
            next_state <= halt;
          elsif IRout(15 downto 8) = "00000010" then -- zero set 
            Zset <= '1';
            next_state <= shadowexe;
          elsif IRout(15 downto 8) = "00000011" then -- zero reset
            Zreset <= '1';
            next_state <= shadowexe;
          elsif IRout(15 downto 8) = "00000100" then -- carry set
            Cset <= '1';
            next_state <= shadowexe;
          elsif IRout(15 downto 8) = "00000101" then -- carry reset
            Creset <= '1';
            next_state <= shadowexe;
          elsif IRout(15 downto 8) = "00000110" then --wp reset
            wpreset <= '1';
            next_state <= shadowexe;
          elsif IRout(15 downto 12) = "0001" then -- rs to rd --all working to here
            readmem <= '0';
            writemem <= '0';
            address_on_bus <= '0';
            B15to0 <= '1';
            -- ehtemalan bayad wait bezanam ta biad berese too clock badi
            -- behtaresh ine ke state ezafe konam bere jolo
            alu_on_databus <= '1';
            rflwrite <= '1';
            rfhwrite <= '1';
            next_state <= writeFullToReg1;
          elsif IRout(15 downto 12) = "0010" then -- data in address of rs to rd --working
            rs_on_addressbus <= '1';
            alu_on_databus <= '0';
            address_on_bus <= '0';
            rpluszero <= '1';
            readmem <='1';
            writemem <= '0';
            rflwrite <= '1';
            rfhwrite <= '1';
            next_state <= inputFromMem1;
          --//////////////////////////////////////////////////////////////////////////////////////////////////////point
          elsif IRout(15 downto 12) = "0100" then -- data in address of rs to rd --working
            rs_on_addressbus <= '1';
            alu_on_databus <= '0';
            address_on_bus <= '0';
            rpluszero <= '1';
            readmem <='0';
            writemem <= '0';
            readport <='1';
            writeport <= '0';
            rflwrite <= '0';
            rfhwrite <= '0';
            next_state <= inputFromPort1;
            elsif IRout(15 downto 12) = "0101" then -- (rd) <- rs
            rd_on_addressbus <= '1';
            address_on_bus <= '0';
            rpluszero <= '1';
            readmem <='0';
            writemem <= '0';
            readPort <='0';
            writePort <= '1';
            b15to0 <= '1';
            alu_on_databus <= '1';
            next_state <= writeToPort1;
          --\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\point
          elsif IRout(15 downto 12) = "0011" then -- rs to address of rd
            rd_on_addressbus <= '1';
            address_on_bus <= '0';
            rpluszero <= '1';
            readmem <='0';
            writemem <= '1';
            b15to0 <= '1';
            alu_on_databus <= '1';
            next_state <= writeToMem1;
          elsif IRout(15 downto 12) = "0110" then -- a and b
            AandB <= '1';
            readmem <='0';
            writemem <= '0';
            address_on_bus <= '0';
            alu_on_databus <= '1';
            rflwrite <= '1';
            rfhwrite <= '1';
            next_state <= writeFullToReg1;
          elsif IRout(15 downto 12) = "0111" then -- a or b
            AorB <= '1';
            readmem <='0';
            writemem <= '0';
            address_on_bus <= '0';
            alu_on_databus <= '1';
            rflwrite <= '1';
            rfhwrite <= '1';
            next_state <= writeFullToReg1;
          elsif IRout(15 downto 12) = "1000" then -- not b
            NotB <= '1';
            readmem <='0';
            writemem <= '0';
            address_on_bus <= '0';
            alu_on_databus <= '1';
            rflwrite <= '1';
            rfhwrite <= '1';
            next_state <= writeFullToReg1;
          elsif IRout(15 downto 12) = "1001" then -- shift b to left
            BShl <= '1';
            readmem <='0';
            writemem <= '0';
            address_on_bus <= '0';
            alu_on_databus <= '1';
            rflwrite <= '1';
            rfhwrite <= '1';
            next_state <= writeFullToReg1;
          elsif IRout(15 downto 12) = "1010" then -- shift b to right
            BShr <= '1';
            readmem <='0';
            writemem <= '0';
            address_on_bus <= '0';
            alu_on_databus <= '1';
            rflwrite <= '1';
            rfhwrite <= '1';
            next_state <= writeFullToReg1;
          elsif IRout(15 downto 12) = "1011" then -- add
            AaddB <= '1';
            readmem <='0';
            writemem <= '0';
            address_on_bus <= '0';
            alu_on_databus <= '1';
            rflwrite <= '1';
            rfhwrite <= '1';
            next_state <= writeFullToReg1;
          elsif IRout(15 downto 12) = "1100" then -- subtract
            AsubB <= '1';
            readmem <='0';
            writemem <= '0';
            address_on_bus <= '0';
            alu_on_databus <= '1';
            rflwrite <= '1';
            rfhwrite <= '1';
            next_state <= writeFullToReg1;
          elsif IRout(15 downto 12) = "1101" then -- muliply 
            AmulB <= '1';
            readmem <='0';
            writemem <= '0';
            address_on_bus <= '0';
            alu_on_databus <= '1';
            rflwrite <= '1';
            rfhwrite <= '1';
            next_state <= writeFullToReg1;
          elsif IRout(15 downto 12) = "1110" then -- compare
            AcmpB <= '1';
            srload <='1';
            readmem <='0';
            writemem <= '0';
            address_on_bus <= '0';
            alu_on_databus <= '0';
            rflwrite <= '0';
            rfhwrite <= '0';
            next_state <= cmp1;
          end if;
        elsif shadowEn = '0' then ---dastoor 16 biti ast
          next_state <= exe16;
        end if;
      when shadowexe =>
        shad <= '1';
        -------------------------------------------------------------------------------
        if IRout(7 downto 0) = "00000000" then
            next_state <= pcinc;
          elsif IRout(7 downto 0) = "00000001" then
            next_state <= halt;
          elsif IRout(7 downto 0) = "00000010" then
            Zset <= '1';
            next_state <= pcinc;
          elsif IRout(7 downto 0) = "00000011" then
            Zreset <= '1';
            next_state <= pcinc;
          elsif IRout(7 downto 0) = "00000100" then
            Cset <= '1';
            next_state <= pcinc;
          elsif IRout(7 downto 0) = "00000101" then
            Creset <= '1';
            next_state <= pcinc;
          elsif IRout(7 downto 0) = "00000110" then
            wpreset <= '1';
            next_state <= pcinc;
          elsif IRout(7 downto 4) = "0001" then --rs to rd reg2
            readmem <= '0';
            writemem <= '0';
            address_on_bus <= '0';
            B15to0 <= '1';
            -- ehtemalan bayad wait bezanam ta biad berese too clock badi
            -- behtaresh ine ke state ezafe konam bere jolo
            alu_on_databus <= '1';
            rflwrite <= '1';
            rfhwrite <= '1';
            next_state <= writeFullToReg2;
          elsif IRout(7 downto 4) = "0010" then  --rd <- (rs)
            rs_on_addressbus <= '1';
            alu_on_databus <= '0';
            address_on_bus <= '0';
            rpluszero <= '1';
            readmem <='1';
            writemem <= '0';
            rflwrite <= '1';
            rfhwrite <= '1';
            next_state <= inputFromMem2;
          --//////////////////////////////////////////////////////////////////////////////////////////////////////point
          elsif IRout(7 downto 4) = "0100" then -- data in address of rs to rd --working
            rs_on_addressbus <= '1';
            alu_on_databus <= '0';
            address_on_bus <= '0';
            rpluszero <= '1';
            readmem <='0';
            writemem <= '0';
            readport <='1';
            writeport <= '0';
            rflwrite <= '0';
            rfhwrite <= '0';
            next_state <= inputfromport2;
         elsif IRout(7 downto 4) = "0101" then -- (rd) <- rs
            rd_on_addressbus <= '1';
            address_on_bus <= '0';
            rpluszero <= '1';
            readmem <='0';
            writemem <= '0';
            readPort <='0';
            writePort <= '1';
            b15to0 <= '1';
            alu_on_databus <= '1';
            next_state <= writeToPort2;
          --\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\point

          elsif IRout(7 downto 4) = "0011" then -- (rd) <- rs
            rd_on_addressbus <= '1';
            address_on_bus <= '0';
            rpluszero <= '1';
            readmem <='0';
            writemem <= '1';
            b15to0 <= '1';
            alu_on_databus <= '1';
            next_state <= writeToMem2;
          elsif IRout(7 downto 4) = "0110" then -- and
            AandB <= '1';
            readmem <='0';
            writemem <= '0';
            address_on_bus <= '0';
            alu_on_databus <= '1';
            rflwrite <= '1';
            rfhwrite <= '1';
            next_state <= writeFullToReg2;
          elsif IRout(7 downto 4) = "0111" then --or
            AorB <= '1';
            readmem <='0';
            writemem <= '0';
            address_on_bus <= '0';
            alu_on_databus <= '1';
            rflwrite <= '1';
            rfhwrite <= '1';
            next_state <= writeFullToReg2;
          elsif IRout(7 downto 4) = "1000" then --not
            NotB <= '1';
            readmem <='0';
            writemem <= '0';
            address_on_bus <= '0';
            alu_on_databus <= '1';
            rflwrite <= '1';
            rfhwrite <= '1';
            next_state <= writeFullToReg2;
          elsif IRout(7 downto 4) = "1001" then -- shift b left
            BShl <= '1';
            readmem <='0';
            writemem <= '0';
            address_on_bus <= '0';
            alu_on_databus <= '1';
            rflwrite <= '1';
            rfhwrite <= '1';
            next_state <= writeFullToReg2;
          elsif IRout(7 downto 4) = "1010" then -- shift b right
            BShr <= '1';
            readmem <='0';
            writemem <= '0';
            address_on_bus <= '0';
            alu_on_databus <= '1';
            rflwrite <= '1';
            rfhwrite <= '1';
            next_state <= writeFullToReg2;
          elsif IRout(7 downto 4) = "1011" then -- add
            AaddB <= '1';
            readmem <='0';
            writemem <= '0';
            address_on_bus <= '0';
            alu_on_databus <= '1';
            rflwrite <= '1';
            rfhwrite <= '1';
            next_state <= writeFullToReg2; 
          elsif IRout(7 downto 4) = "1100" then -- sub
            AsubB <= '1';
            readmem <='0';
            writemem <= '0';
            address_on_bus <= '0';
            alu_on_databus <= '1';
            rflwrite <= '1';
            rfhwrite <= '1';
            next_state <= writeFullToReg2;
          elsif IRout(7 downto 4) = "1101" then -- multiply
            AmulB <= '1';
            readmem <='0';
            writemem <= '0';
            address_on_bus <= '0';
            alu_on_databus <= '1';
            rflwrite <= '1';
            rfhwrite <= '1';
            next_state <= writeFullToReg2;
          elsif IRout(7 downto 4) = "1110" then --compare
            AcmpB <= '1';
            srload <='1';
            readmem <='0';
            writemem <= '0';
            address_on_bus <= '0';
            alu_on_databus <= '0';
            rflwrite <= '0';
            rfhwrite <= '0';
            next_state <= cmp2;
          end if;
        -------------------------------------------------------------------------------
      when exe16 => -- dastor 16 biti ast
          shad <= '0';
          if IRout(15 downto 12) = "1111" then
            if IRout(9 downto 8)="00" then -- immediate to rd low
              readmem <='1';
              writemem <= '0';
              address_on_bus <= '0';
              alu_on_databus <= '0';
              --//////////////////////////////////////////////////////////////////////////////////
              rflwrite <= '0';
              rfhwrite <= '0';
              next_state <= writeLowToReg;
            elsif IRout(9 downto 8)="01" then -- immediate to rd high
              readmem <='1';
              writemem <= '0';
              address_on_bus <= '0';
              alu_on_databus <= '0';
              rflwrite <= '0';
              rfhwrite <= '0';
              next_state <= writeHighToReg;
            elsif IRout(9 downto 8)="10" then -- save pc plus i
              pcplusI <= '1';
              readmem <='0';
              writemem <= '0';
              address_on_bus <= '1';
              alu_on_databus <= '0';
              rflwrite <= '1';
              rfhwrite <= '1';
              next_state <= pcinc;
            elsif IRout(9 downto 8)="11" then -- rd plus i
              readmem <= '0';
              writemem <= '0';
              rd_on_addressbus <= '1';
              rs_on_addressbus <= '0';
              rplusI <= '1';
              resetPC <= '0';
              PCPlusOne <= '0';
              PCPlusI <= '0';
              RPlusZero <= '0';
              pcEnable <= '1';
              next_state <= pcinc;
            end if;
          elsif IRout(15 downto 12) = "0000" then
            if IRout(11 downto 8) = "0111" then -- pc plus i
              pcplusI <= '1';
              pcEnable <= '1';
              next_state <= fetch1;
            elsif IRout(11 downto 8) = "1000" then -- branch if zero
              if zout='1' then
                pcplusI <= '1';
                pcEnable <= '1';
              end if;
              next_state <= fetch1;
            elsif IRout(11 downto 8) = "1001" then --branch if carry
              if cout='1' then
                pcplusI <= '1';
                pcEnable <= '1';
              end if;
              next_state <= fetch1;
            elsif IRout(11 downto 8) = "1010" then -- wp add i
              wpadd <='1';
              next_state <= pcinc;
              --/////////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\points
            elsif IRout(11 downto 4) = "11110000" then --SquareB
              shad <= '1';
              Bsquar <='1';
              next_state <= writeFullToReg2;
            elsif IRout(11 downto 4) = "11110001" then --SinB
              shad <= '1';
              sinB <= '1';
              next_state <= writeFullToReg2;
            elsif IRout(11 downto 4) = "11110010" then --CosB
              shad <= '1';
              cosB <= '1';
              next_state <= writeFullToReg2;
            elsif IRout(11 downto 4) = "11110011" then --TanB
              shad <= '1';
              tanB <= '1';
              next_state <= writeFullToReg2;
            elsif IRout(11 downto 4) = "11110100" then --CotB
              shad <= '1';
              cotB <= '1';
              next_state <= writeFullToReg2;
            elsif IRout(11 downto 4) = "11110101" then --Random Number
              shad <= '1';
              RND <= '1';
              next_state <= writeFullToReg2;
            elsif IRout(11 downto 4) = "11110110" then --A divided by B
              shad <= '1';
              AdivB <= '1';
              readmem <='0';
              writemem <= '0';
              address_on_bus <= '0';
              alu_on_databus <= '1';
              rflwrite <= '1';
              rfhwrite <= '1';
              next_state <= writeFullToReg2;
            end if;
        end if;
      when pcinc =>
        pcplusone <= '1';
        pcEnable <= '1';
        next_state <= fetch1;
      when halt =>
        next_state <= halt;
      when writeFullToReg1 =>
        shad <= '0';
        alu_on_databus <= '1';
        rflwrite <= '1';
        rfhwrite <= '1';
        next_state <= shadowexe;
      when writeFullToReg2 =>
        shad <= '1';
        alu_on_databus <= '1';
        rflwrite <= '1';
        rfhwrite <= '1';
        next_state <= pcinc;
      when writeToMem1 =>
        Address_On_Bus <= '0';
        alu_on_databus <= '1';
        readmem <= '0';
        writemem <= '1';
        next_state <= shadowexe;
      when writeToMem2 =>
        Address_On_Bus <= '0';
        alu_on_databus <= '1';
        readmem <= '0';
        writemem <= '1';
        next_state <= pcinc;
     when writeLowToReg =>
        Address_On_Bus <= '0';
        alu_on_databus <= '0';
        readmem <= '1';
        writemem <= '0';
        rflwrite <= '1';
        rfhwrite <= '0';
        next_state <= pcinc;
      when writeHighToReg =>
        Address_On_Bus <= '0';
        alu_on_databus <= '0';
        readmem <= '1';
        writemem <= '0';
        rflwrite <= '0';
        rfhwrite <= '1';
        next_state <= pcinc;
      when cmp1 => 
        AcmpB <= '1';
        srload <='1';
        next_state <= shadowexe;
      when cmp2 => 
        AcmpB <= '1';
        srload <='1';
        next_state <= pcinc;
      when inputFromPort1 =>
        rs_on_addressbus <= '1';
        alu_on_databus <= '0';
        address_on_bus <= '0';
        rpluszero <= '1';
        readmem <='0';
        writemem <= '0';
        readport <='1';
        writeport <= '0';
        rflwrite <= '1';
        rfhwrite <= '1'; 
        next_state <= shadowexe;
      when inputFromPort2 =>
        rs_on_addressbus <= '1';
        alu_on_databus <= '0';
        address_on_bus <= '0';
        rpluszero <= '1';
        readmem <='0';
        writemem <= '0';
        readport <='1';
        writeport <= '0';
        rflwrite <= '1';
        rfhwrite <= '1'; 
        next_state <= pcinc;
      when inputFromMem1 =>
        rs_on_addressbus <= '1';
        alu_on_databus <= '0';
        address_on_bus <= '0';
        rpluszero <= '1';
        readmem <='1';
        writemem <= '0';
        readport <='0';
        writeport <= '0';
        rflwrite <= '1';
        rfhwrite <= '1'; 
        next_state <= shadowexe;
      when inputFromMem2 =>
        rs_on_addressbus <= '1';
        alu_on_databus <= '0';
        address_on_bus <= '0';
        rpluszero <= '1';
        readmem <='1';
        writemem <= '0';
        readport <='0';
        writeport <= '0';
        rflwrite <= '1';
        rfhwrite <= '1'; 
        next_state <= pcinc;
      when writeToPort1 =>
        Address_On_Bus <= '0';
        alu_on_databus <= '1';
        readmem <= '0';
        writemem <= '0';
        readport <= '0';
        writeport <= '1';
        next_state <= shadowexe;
      when writeToPort2 =>
        Address_On_Bus <= '0';
        alu_on_databus <= '1';
        readmem <= '0';
        writemem <= '0';
        readport <= '0';
        writeport <= '1';
        next_state <= pcinc;
    end case;
  end process;
end architecture;