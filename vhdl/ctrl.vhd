-------------------------------------------------------------------------------
-- Title: Control unit for a mips cpu
-- Developers: Henrik Ljunger
--             Stathis Makridis
-- Purpose: Generate all the control signals for the cpu to
-- decide which operation to be performed
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.types.all;

entity ctrl is
  port (
    clk         : in  bit_t;
    rst         : in  bit_t;
    -- From ID
    opCode      : in  OpCode_t;
    funcCode    : in  FuncCode_t;
    compEq      : in  bit_t;
    compZ       : in  bit_t;
    gtz         : in  bit_t;
    branchField : in  BranchField_t;
    -- To IF
    branchSel   : out bit_t;
    -- To ID
    regWriteEn  : out bit_t;
    pcSel       : out PcSel_t;
    -- To EX
    srcASel     : out bit_t;
    srcBSel     : out SrcBSel_t;
    aluSel      : out AluSel_t;
    -- To Mem
    memRw_n     : out bit_t;
    memReq      : out bit_t;
    -- To WB
    regSel      : out RegSel_t;
    memRegSel   : out bit_t
    );
end ctrl;

architecture behavioral of ctrl is
begin  -- behavioral
  -----------------------------------------------------------------------------
  -- The control process
  -----------------------------------------------------------------------------
  CTRL_PROC : process(branchField, compEq, compZ, funcCode, gtz, opCode)
  begin
    branchSel  <= '0';
    regWriteEn <= '0';
    srcASel    <= '0';
    srcBSel    <= "00";
    aluSel     <= (others => '0');
    memRw_n    <= '1';
    memReq     <= '0';
    memRegSel  <= '0';
    pcSel      <= "00";
    regSel     <= "10";                 -- Rd = 01 Rt = 10 R31 = 11 R0 = 00

    case opCode is
      when OP_RFORMAT =>
        regWriteEn <= '1';
        regSel     <= "01";
        case funcCode is
          when FUNCT_ADDU =>
            aluSel <= ALU_ADDU;
          when FUNCT_SUBU =>
            aluSel <= ALU_SUBU;
          when FUNCT_MULTU =>
            aluSel <= ALU_MULTU;
          when FUNCT_MFHI =>
            aluSel <= ALU_MFHI;
          when FUNCT_MFLO =>
            aluSel <= ALU_MFLO;
          when FUNCT_AND =>
            aluSel <= ALU_AND;
          when FUNCT_OR =>
            aluSel <= ALU_OR;
          when FUNCT_XOR =>
            aluSel <= ALU_XOR;
          when FUNCT_NOR =>
            aluSel <= ALU_NOR;
          when FUNCT_SLL =>
            srcASel <= '1';
            aluSel  <= ALU_SLL;
          when FUNCT_SRL =>
            srcASel <= '1';
            aluSel  <= ALU_SRL;
          when FUNCT_SRA =>
            srcASel <= '1';
            aluSel  <= ALU_SRA;
          when FUNCT_SLT =>
            aluSel <= ALU_SLT;
          when FUNCT_SLTU =>
            aluSel <= ALU_SLTU;
          when FUNCT_SLLV =>
            aluSel <= ALU_SLL;
          when FUNCT_SRLV =>
            aluSel <= ALU_SRL;
          when FUNCT_SRAV =>
            aluSel <= ALU_SRA;
          when FUNCT_JALR =>
            pcSel     <= "11";
            branchSel <= '1';
            srcBSel   <= "10";
            srcASel   <= '1';
          when FUNCT_JR =>
            pcSel     <= "11";
            branchSel <= '1';

          when FUNCT_NOP =>
            regWriteEn <= '0';
          when others => null;
        end case;
      when OP_BLTZ_BGEZ =>
        if (branchField = "00000") and (compEq = '0' and gtz = '0') then
          branchSel <= '1';
          pcSel     <= "01";
        elsif (branchField = "00001") and (gtz = '1' or compZ = '1') then
          branchSel <= '1';
          pcSel     <= "01";
        end if;
      when OP_J =>
        pcSel     <= "10";
        branchSel <= '1';
      when OP_JAL =>
        pcSel      <= "10";
        branchSel  <= '1';
        regSel     <= "11";
        regWriteEn <= '1';
        srcBSel    <= "10";
      when OP_BEQ =>
        if compEq = '1' then
          pcSel     <= "01";
          branchSel <= '1';
        end if;
      when OP_BNE =>
        if compEq = '0' then
          pcSel     <= "01";
          branchSel <= '1';
        end if;
      when OP_BLEZ =>
        if compZ = '1' or gtz = '0' then
          pcSel     <= "01";
          branchSel <= '1';
        end if;
      when OP_BGTZ =>
        if gtz = '1' then
          pcSel     <= "01";
          branchSel <= '1';
        end if;
      when OP_ADDIU =>
        regWriteEn <= '1';
        aluSel     <= ALU_ADDU;
        srcBSel    <= "01";
      when OP_SLTI =>
        regWriteEn <= '1';
        aluSel     <= ALU_SLT;
        srcBSel    <= "01";
      when OP_SLTIU =>
        regWriteEn <= '1';
        aluSel     <= ALU_SLTU;
        srcBSel    <= "01";
      when OP_ANDI =>
        regWriteEn <= '1';
        aluSel     <= ALU_AND;
        srcBSel    <= "11";
      when OP_ORI =>
        regWriteEn <= '1';
        aluSel     <= ALU_OR;
        srcBSel    <= "11";
      when OP_XORI =>
        regWriteEn <= '1';
        aluSel     <= ALU_XOR;
        srcBSel    <= "11";
      when OP_LUI =>
        regWriteEn <= '1';
        aluSel     <= ALU_LUI;
        srcBSel    <= "01";

      when OP_LW =>
        memReq     <= '1';
        regWriteEn <= '1';
        srcBSel    <= "01";
        memRegSel  <= '1';
        aluSel     <= ALU_ADDU;
      when OP_SW =>
        srcBSel <= "01";
        memRw_n <= '0';
        memReq  <= '1';
        aluSel  <= ALU_ADDU;

      when others => null;

    end case;

  end process CTRL_PROC;

end behavioral;
