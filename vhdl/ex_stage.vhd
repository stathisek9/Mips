library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.types.all;

entity ex_stage is
  port (
    clk        : in  bit_t;
    rst        : in  bit_t;
    aluSel     : in  AluSel_t;
    srcA       : in  word_t;
    srcB       : in  word_t;
    aluFSelA   : in  bit_t;
    aluFSelB   : in  bit_t;
    forwardSrc : in  word_t;
    aluRes     : out word_t
    );
end ex_stage;

architecture behavioral of ex_stage is
  component alu is
    port (
      clk    : in  bit_t;
      rst    : in  bit_t;
      opA    : in  word_t;
      opB    : in  word_t;
      aluSel : in  AluSel_t;
      aluRes : out word_t);
  end component alu;

  signal opA_i, opB_i : word_t;
  signal aluSel_i     : AluSel_t;
  signal aluRes_i     : word_t;
begin

  ALU_UNIT : ALU
    port map (
      clk    => clk,
      rst    => rst,
      opA    => opA_i,
      opB    => opB_i,
      aluSel => aluSel_i,
      aluRes => aluRes_i
      );

  opA_i <= srcA when aluFSelA = '0' else
           forwardSrc;

  opB_i <= srcB when aluFSelB = '0' else
           forwardSrc;

  aluRes <= aluRes_i;

  aluSel_i <= aluSel;

end behavioral;


