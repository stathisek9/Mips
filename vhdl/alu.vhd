library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use work.types.all;

entity alu is
  port(
    clk    : in  bit_t;
    rst    : in  bit_t;
    opA    : in  word_t;
    opB    : in  word_t;
    aluSel : in  AluSel_t;
    aluRes : out word_t);
end alu;

architecture behavioral of alu is

  signal hi, hiNext, lo, loNext : word_t;

  signal MultResult : doubleword_t;
  signal AddResult  : word_t;
  signal AndResult  : word_t;
  signal OrResult   : word_t;
  signal XorResult  : word_t;
  signal NorResult  : word_t;
  signal SllResult  : word_t;
  signal SrlResult  : word_t;
  signal SraResult  : word_t;
  signal SltResult  : word_t;
  signal SltuResult : word_t;
  signal ui         : word_t;


begin
  --- Combinational
  MultResult <= std_logic_vector(unsigned(opA) * unsigned(opB));

  AddResult <= std_logic_vector(unsigned(opA) - unsigned(opB)) when aluSel = ALU_SUBU else
               std_logic_vector(unsigned(opA) + unsigned(opB));

  AndResult <= opA and opB;

  OrResult <= opA or opB;

  XorResult <= opA xor opB;

  NorResult <= opA nor opB;

  SllResult <= std_logic_vector(SHIFT_LEFT(unsigned(opB), to_integer(unsigned(opA))));

  SrlResult <= std_logic_vector(SHIFT_RIGHT(unsigned(opB), to_integer(unsigned(opA))));

  SraResult <= std_logic_vector(SHIFT_RIGHT(signed(opB), to_integer(unsigned(opA))));

  SltResult <= ((0) => '1', others => '0') when signed(opA) < signed(opB) else
               (others => '0');

  SltuResult <= ((0) => '1', others => '0') when unsigned(opA) < unsigned(opB) else
                (others => '0');

  ui <= opB(15 downto 0) & HALFWORD_ZERO;

  -----------------------------------------------------------------------------
  -- Updates the High and Low registers
  -----------------------------------------------------------------------------
  REG_UPDATE_PROC : process(clk)
  begin
    if clk = '1' and clk'event then
      if rst = '1' then
        Hi <= (others => '0');
        Lo <= (others => '0');
      else
        Hi <= HiNext;
        Lo <= LoNext;
      end if;
    end if;
  end process REG_UPDATE_PROC;

  -----------------------------------------------------------------------------
  -- Selects the proper result to the alu output
  -----------------------------------------------------------------------------
  ALU_RESULT_PROC : process(AddResult, AndResult, Hi, Lo,
                            MultResult(31 downto 0), MultResult(63 downto 32),
                            NorResult, OrResult, SllResult, SltResult,
                            SltuResult, SraResult, SrlResult, XorResult,
                            aluSel, opB, ui)
  begin
    HiNext <= Hi;
    LoNext <= Lo;
    aluRes <= opB;
    case aluSel is
      when ALU_SLL =>
        aluRes <= SllResult;
      when ALU_SRL =>
        aluRes <= SrlResult;
      when ALU_SRA =>
        aluRes <= SraResult;
      when ALU_MFHI =>
        aluRes <= HI;
      when ALU_MFLO =>
        aluRes <= LO;
      when ALU_MULTU =>
        HiNext <= MultResult(63 downto 32);
        LoNext <= MultResult(31 downto 0);
      when ALU_ADDU =>
        aluRes <= AddResult;
      when ALU_SUBU =>
        aluRes <= AddResult;
      when ALU_AND =>
        aluRes <= AndResult;
      when ALU_OR =>
        aluRes <= OrResult;
      when ALU_XOR =>
        aluRes <= XorResult;
      when ALU_NOR =>
        aluRes <= NorResult;
      when ALU_SLT =>
        aluRes <= SltResult;
      when ALU_SLTU =>
        aluRes <= SltuResult;
      when ALU_LUI =>
        aluRes <= ui;
      when others => null;
    end case;
  end process ALU_RESULT_PROC;
end behavioral;
