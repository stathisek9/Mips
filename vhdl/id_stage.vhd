-------------------------------------------------------------------------------
-- Title: Instruction decode
-- Developers: Henrik Ljunger
--             Stathis Makridis
-- Purpose: Selecting the the proper registers for read and writing and
-- determining if a branch is taken, and calculate the next pc
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.types.all;

entity id_stage is
  port (
    clk         : in  bit_t;
    rst         : in  bit_t;
    pc          : in  word_t;
    iData       : in  word_t;
    pcSel       : in  PcSel_t;
    writeEn     : in  bit_t;
    writeData   : in  word_t;
    writeAddr   : in  RegAddr_t;
    forwardSelA : in  forwardSel_t;
    forwardSelB : in  forwardSel_t;
    srcIDEX     : in  word_t;
    srcEXMEM    : in  word_t;
    srcMEMWB    : in  word_t;
    srcBSel     : in  srcBSel_t;
    srcASel     : in  bit_t;
    regSel      : in  RegSel_t;
    regDest     : out RegAddr_t;
    srcAAddr    : out RegAddr_t;
    srcBAddr    : out RegAddr_t;
    compEq      : out bit_t;
    compZ       : out bit_t;
    gtz         : out bit_t;
    srcA        : out word_t;
    srcB        : out word_t;
    rt          : out word_t;
    branchPc    : out word_t);
end id_stage;

architecture behavioral of id_stage is

  ---Register file containing the registers
  component regbank is
    port (
      clk       : in  bit_t;
      rst       : in  bit_t;
      writeData : in  word_t;
      writeAddr : in  RegAddr_t;
      writeEn   : in  bit_t;
      srcAAddr  : in  RegAddr_t;
      srcBAddr  : in  RegAddr_t;
      srcA      : out word_t;
      srcB      : out word_t);
  end component regbank;

  --Signals
  signal srcAAddr_i : RegAddr_t;
  signal srcBAddr_i : RegAddr_t;
  signal srcA_i     : word_t;
  signal srcB_i     : word_t;
  signal jPc_i      : word_t;
  signal branchOp_i : word_t;
  signal imm_i      : word_t;
  signal sImm_i     : word_t;
  signal pc_i       : word_t;
  signal srcAComp_i : word_t;
  signal srcBComp_i : word_t;
  signal iData_i    : word_t;
  signal shamt_i    : word_t;
  signal usImm_i    : word_t;


begin

  ---Reg file init
  REG_FILE : regbank
    port map (
      clk       => clk,
      rst       => rst,
      writeData => writeData,
      writeEn   => writeEn,
      writeAddr => writeAddr,
      srcAAddr  => srcAAddr_i,
      srcBAddr  => srcBAddr_i,
      srcA      => srcA_i,
      srcB      => srcB_i
      );

  --- Combinational
  pc_i <= pc;

  iData_i <= iData;

  imm_i <= iData_i(15 downto 0) & x"0000";

  sImm_i <= std_logic_vector(SHIFT_RIGHT(signed(imm_i), 16));

  srcAAddr_i <= iData_i(25 downto 21);

  srcBAddr_i <= iData_i(20 downto 16);

  usImm_i <= HALFWORD_ZERO & iData_i(15 downto 0);

  shamt_i(31 downto 5) <= (others => '0');
  shamt_i(4 downto 0)  <= iData_i(10 downto 6);

  jPc_i <= pc_i(31 downto 28) & iData_i(25 downto 0) & "00";

  branchOp_i <= sImm_i(DATA_WIDTH - 3 downto 0) & "00";

  srcAComp_i <= srcEXMEM when forwardSelA = "01" else
                srcMEMWB when forwardSelA = "10" else
                srcIDEX  when forwardSelA = "11" else
                srcA_i;

  srcBComp_i <= srcEXMEM when forwardSelB = "01" else
                srcMEMWB when forwardSelB = "10" else
                srcIDEX  when forwardSelB = "11" else
                srcB_i;


  --- Output
  Rt <= srcB_i;

  srcA <= srcAComp_i when srcASel = '0' else
          shamt_i;

  srcB <= srcBComp_i when srcBSel = "00" else
          sImm_i when srcBSel = "01" else
          pc_i   when srcBSel = "10" else
          usImm_i;

  regDest <= iData_i(15 downto 11) when regSel = "01" else
             iData_i(20 downto 16) when regSel = "10" else
             (others => '1')       when regSel = "11" else
             (others => '0');

  srcAAddr <= srcAAddr_i when srcASel = '0' else
              (others => '0');

  srcBAddr <= srcBAddr_i when srcBSel = "00" else
              (others => '0');


  -----------------------------------------------------------------------------
  -- Process that selects the next value of the pc
  -----------------------------------------------------------------------------
  BRANCH_PC_PROC : process(branchOp_i, forwardSelA, jPc_i, pcSel, pc_i, srcA_i,
                           srcEXMEM, srcIDEX, srcMEMWB)
  begin
    if pcSel = "01" then
      branchPc <= std_logic_vector(unsigned(pc_i) + unsigned(branchOp_i));
    elsif pcSel = "10" then
      branchPc <= jPc_i;
    elsif pcSel = "11" then
      branchPc <= srcA_i;
      if forwardSelA = "01" then
        branchPc <= srcEXMEM;
      elsif forwardSelA = "10" then
        branchPc <= srcMEMWB;
      elsif forwardSelA = "11" then
        branchPc <= srcIDEX;
      end if;
    else
      branchPc <= pc_i;
    end if;
  end process BRANCH_PC_PROC;

  -----------------------------------------------------------------------------
  -- Process to set control signals for branch prediction
  -----------------------------------------------------------------------------
  BRANC_PROC : process(srcAComp_i, srcBComp_i)
  begin
    compEq <= '0';
    gtz    <= '0';
    compZ  <= '0';
    if srcBComp_i = srcAComp_i then
      compEq <= '1';
    end if;
    if signed(srcAComp_i) > x"00000000" then
      gtz <= '1';
    end if;
    if srcAComp_i = x"00000000" then
      compZ <= '1';
    end if;
  end process BRANC_PROC;

end behavioral;

