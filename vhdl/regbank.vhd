-------------------------------------------------------------------------------
-- Title: Register bank containing the register for the mips architecture
-- Developers:  Henrik Ljunger
--              Stathis Makridos
-- Purpose: Handles write and reads from the registers
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.types.all;

entity regbank is
  port (
    clk       : in  bit_t;
    rst       : in  bit_t;
    writeData : in  word_t;
    writeAddr : in  RegAddr_t;
    writeEn   : in  bit_t;
    srcAAddr  : in  RegAddr_t;
    srcBAddr  : in  RegAddr_t;
    srcA      : out word_t;
    srcB      : out word_t
    );
end regbank;

architecture rtl of regbank is
  type REG_t is array (NBR_OF_REG - 1 downto 0) of word_t;
  signal r, rNext : REG_t;

begin
  -----------------------------------------------------------------------------
  -- Process that updates the registers
  -----------------------------------------------------------------------------
  REG_UPDATE_PROC : process(clk)
  begin
    if clk = '1' and clk'event then
      if rst = '1' then
        RST_REG : for i in NBR_OF_REG - 1 downto 0 loop
          r(i) <= (others => '0');
        end loop RST_REG;
      else
        UPDATE_REG : for i in NBR_OF_REG - 1 downto 0 loop
          r(i) <= rNext(i);
        end loop UPDATE_REG;
      end if;
    end if;
  end process REG_UPDATE_PROC;

  -----------------------------------------------------------------------------
  -- Writes to a register
  -----------------------------------------------------------------------------
  WRITE_PROC : process(r, writeAddr, writeData, writeEn)
  begin
    ---Default
    default_write : for i in 1 to NBR_OF_REG - 1 loop
      rNext(i) <= r(i);
    end loop default_write;
    if writeEn = '1' then
      rNext(to_integer(unsigned(writeAddr))) <= writeData;
    end if;
    ---r(0) should always be zero
    rNext(0) <= (others => '0');
  end process WRITE_PROC;

  -----------------------------------------------------------------------------
  -- Read a register
  -----------------------------------------------------------------------------
  READ_A_PROC : process(r, srcAAddr)
  begin
    srcA <= r(to_integer(unsigned(srcAAddr)));
  end process READ_A_PROC;

  READ_B_PROC : process(r, srcBAddr)
  begin
    srcB <= r(to_integer(unsigned(srcBAddr)));
  end process READ_B_PROC;

end rtl;






