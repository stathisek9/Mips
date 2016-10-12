-------------------------------------------------------------------------------
-- Title: Instruction fetch stage of a MIPS cpu
-- Developers: Henrik Ljunger
--             Stathis Makridis
-- Purpose: Keeping the program counter and updates it
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.types.all;

entity if_stage is
  port (
    clk       : in  bit_t;
    rst       : in  bit_t;
    branchSel : in  bit_t;
    stall     : in  bit_t;
    branchPc  : in  word_t;
    pcInc     : out word_t;
    pc        : out word_t
    );
end if_stage;

architecture behavioral of if_stage is
  signal pc_i, pcNext_i : word_t;
  signal pcInc_i        : word_t;

begin
  -----------------------------------------------------------------------------
  -- Updates the program counter
  -----------------------------------------------------------------------------
  PROGRAM_COUNTER : process(clk)
  begin
    if clk'event and clk = '1' then
      if rst = '1' then
        pc_i <= (others => '0');
      else
        pc_i <= pcNext_i;
      end if;
    end if;
  end process PROGRAM_COUNTER;

  -----------------------------------------------------------------------------
  -- Sets the next pc value
  -----------------------------------------------------------------------------
  PROGRAM_COUNTER_NEXT : process(branchPc, branchSel, pcInc_i, stall)
  begin
    pcNext_i <= pcInc_i;
    if branchSel = '1' then
      pcNext_i <= branchPc;
    end if;

    if stall = '1' then
      pcNext_i <= pc_i;
    end if;
  end process PROGRAM_COUNTER_NEXT;

  pcInc_i <= std_logic_vector(unsigned(pc_i) + 4);
  pc      <= pc_i;

  pcInc <= pcInc_i;
end behavioral;
