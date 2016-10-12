library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.types.all;

entity stallunit is

  port (
   -- clk            : in  bit_t;
   -- rst            : in  bit_t;
    memHold        : in  bit_t;
    IDEXsrcA       : in  RegAddr_t;
    IDEXsrcB       : in  RegAddr_t;
    EXMEMmemRegSel : in  bit_t;
    EXMEMdest      : in  RegAddr_t;
    stall          : out bit_t);

end stallunit;

architecture behavioral of stallunit is

 -- signal stallCnt, nextStallCnt : bit_t;

begin  -- behavioral

  --cnt_proc : process(clk)
  --begin
  --  if clk = '1' and clk'event then
  --    stallCnt <= nextStallCnt;
  --    if rst = '1' then
  --      stallCnt <= '0';
  --    end if;
  --  end if;
  --end process cnt_proc;

  -----------------------------------------------------------------------------
  -- Genereates the stall signals.
  -- stallID is high if a branch is in the ID stage but needs operands from the
  -- instruction in Ex stage. stallMem is high if memory needs more time or if
  -- a instruction needs the data from a lw currently in memstage
  -----------------------------------------------------------------------------
  STALL_PROC : process(EXMEMdest, EXMEMmemRegSel, IDEXsrcA, IDEXsrcB, memHold)
  begin
    stall     <= '0';
   -- nextStallCnt <= '0';
    if memHold = '1' then
      stall <= '1';
    elsif EXMEMmemRegSel = '1' then
      if IDEXsrcA = EXMEMdest then
        stall     <= '1';
       -- nextStallCnt <= '1';
      elsif IDEXsrcB = EXMEMdest then
        stall     <= '1';
       -- nextStallCnt <= '1';
      end if;
    end if;
  end process STALL_PROC;

end behavioral;
