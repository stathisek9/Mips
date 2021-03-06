library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.types.all;

entity forwardingunit is
  port (
    IFIDsrcA      : in  RegAddr_t;
    IFIDsrcB      : in  RegAddr_t;
    IDEXdest      : in  RegAddr_t;
    EXMEMdest     : in  RegAddr_t;
    MEMWBdest     : in  RegAddr_t;
    IDEXregWrite  : in  bit_t;
    EXMEMregWrite : in  bit_t;
    MEMWBregWrite : in  bit_t;
    MEMWBmemSel   : in  bit_t;
    IDEXsrcA      : in  RegAddr_t;
    IDEXsrcB      : in  RegAddr_t;
    aluFSelA      : out bit_t;
    aluFSelB      : out bit_t;
    forwardSelA   : out forwardSel_t;
    forwardSelB   : out forwardSel_t);
end forwardingunit;

architecture behavioral of forwardingunit is


begin  -- behavioral

  forwardSelA <= "11" when IFIDsrcA = IDEXdest and IDEXregWrite = '1' else
                 "01" when IFIDsrcA = EXMEMdest and EXMEMregWrite = '1' else
                 "10" when IFIDsrcA = MEMWBdest and MEMWBregWrite = '1' else
                 "00";

  forwardSelB <= "11" when IFIDsrcB = IDEXdest and IDEXregWrite = '1' else
                 "01" when IFIDsrcB = EXMEMdest and EXMEMregWrite = '1' else
                 "10" when IFIDsrcB = MEMWBdest and MEMWBregWrite = '1' else
                 "00";

  aluFSelA <= '1' when IDEXsrcA = MEMWBdest and MEMWBmemSel = '1' else
              '0';

  aluFSelB <= '1' when IDEXsrcB = MEMWBdest and MEMWBmemSel = '1' else
              '0';

end behavioral;
