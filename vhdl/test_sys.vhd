library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.types.all;

entity test_sys is
  port (
    clk       : in  bit_t;
    rst       : in  bit_t;
    branchSel : in  bit_t;
    stall     : in  bit_t;
    branchPc  : in  word_t;
    pcInc     : out word_t;
    pc        : out word_t);
end test_sys;

architecture behavioral of test_sys is

  component if_stage
    port (
      clk       : in  bit_t;
      rst       : in  bit_t;
      branchSel : in  bit_t;
      stall     : in  bit_t;
      branchPc  : in  word_t;
      pcInc     : out word_t;
      pc        : out word_t);
  end component;

  component id_stage
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
      sImm        : out word_t;
      branchPc    : out word_t);
  end component;

  signal branchSeli : bit_t;
  signal stalli     : bit_t;
  signal branchPci  : word_t;
  signal pcInci     : word_t;
  signal pci        : word_t;
  
begin  -- behavioral

  branchPci <= branchPc;

  stalli <= stall;

  branchSeli <= branchSel;

  pcInc <= pcInci;

  pc <= pci;
  
  if_stage_1 : if_stage
    port map (
      clk       => clk,
      rst       => rst,
      branchSel => branchSeli,
      stall     => stalli,
      branchPc  => branchPci,
      pcInc     => pcInci,
      pc        => pci);

  id_stage_1: id_stage
    port map (
      clk         => clk,
      rst         => rst,
      pc          => pc,
      iData       => iData,
      pcSel       => pcSel,
      writeEn     => writeEn,
      writeData   => writeData,
      writeAddr   => writeAddr,
      forwardSelA => forwardSelA,
      forwardSelB => forwardSelB,
      srcIDEX     => srcIDEX,
      srcEXMEM    => srcEXMEM,
      srcMEMWB    => srcMEMWB,
      srcBSel     => srcBSel,
      srcASel     => srcASel,
      regSel      => regSel,
      regDest     => regDest,
      srcAAddr    => srcAAddr,
      srcBAddr    => srcBAddr,
      compEq      => compEq,
      compZ       => compZ,
      gtz         => gtz,
      srcA        => srcA,
      srcB        => srcB,
      sImm        => sImm,
      branchPc    => branchPc);

end behavioral;

