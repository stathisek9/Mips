library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.types.all;

-------------------------------------------------------------------------------

entity mips_topp_tb is

end entity mips_topp_tb;

-------------------------------------------------------------------------------

architecture top_tb of mips_topp_tb is

  -- component ports
  signal clk       : bit_t;
  signal rst       : bit_t;
  signal extHold   : bit_t;
  signal flushData : bit_t;
  signal extDataR  : byte_t;
  signal extAddr   : byte_t;
  signal extReq    : bit_t;
  signal extRw     : bit_t;
  signal extDataW  : byte_t;
  signal extAck    : bit_t;

  signal iaddr : word_t;
  signal idata : word_t;
  signal irw   : bit_t;
  signal ireq  : bit_t;
  signal ihold : bit_t;

  signal daddr : word_t;
  signal ddata : word_t;
  signal drw   : bit_t;
  signal dreq  : bit_t;
  signal dhold : bit_t;

  signal regAddr, nextAddr                    : word_t;
  signal tmpCnt, nextcnt                      : integer;
  signal regIsel, nextIsel, regdSel, nextdSel : bit_t;
  signal regData, nextData                    : word_t;
  signal regRw, nextRw                    : bit_t;

  component mips_topp
    
    port (
      clk       : inout bit_t;
      rst       : inout bit_t;
      dataFlush : inout bit_t;
      RAMhold   : inout bit_t;
      RAMreq    : inout bit_t;
      RAMrw_n   : inout bit_t;
      RAMack    : inout bit_t;
      RAMaddr   : inout byte_t;
      RAMdataw  : inout byte_t;
      RAMdatar  : inout byte_t
      );

  end component;

  component mem2 is
    generic (
      filename   : string;
      memsize    : natural;
      n          : natural;
      Tclock     : time;
      read_delay : time;
      mem_load   : string;
      base_addr  : word_t);
    port (
      clk   : in    bit_t;
      reset : in    bit_t;
      addr  : in    word_t;
      data  : inout word_t;
      rw    : in    bit_t;
      req   : in    bit_t;
      hold  : out   bit_t);
  end component mem2;

  constant filename   : string  := "fib1.log";
  constant memsize    : natural := 2048;
  constant n          : natural := 0;
  constant Tclock     : time    := 50 ns;
  constant read_delay : time    := 0 ns;
  constant mem_loadI  : string  := "inst";
  constant base_addrI : word_t  := X"00400000";
  constant mem_loadD  : string  := "data";
  constant base_addrD : word_t  := X"10010000";

  -- clock
  constant clk_period : time := 10 ns;

begin  -- architecture top_tb

  -- component instantiation
  DUT : mips_topp
    port map (
      clk       => clk,
      rst       => rst,
      ramHold   => extHold,
      dataFlush => flushData,
      ramDataR  => extDataR,
      ramAck    => extAck,
      ramAddr   => extAddr,
      ramReq    => extReq,
      ramRw_n   => extRw,
      ramDataW  => extDataW);

  mem2_I : mem2
    generic map (
      filename   => filename,
      memsize    => memsize,
      n          => n,
      Tclock     => Tclock,
      read_delay => read_delay,
      mem_load   => mem_loadI,
      base_addr  => base_addrI)
    port map (
      clk   => clk,
      reset => rst,
      addr  => iaddr,
      data  => idata,
      rw    => irw,
      req   => ireq,
      hold  => ihold);

  mem2_D : mem2
    generic map (
      filename   => filename,
      memsize    => memsize,
      n          => n,
      Tclock     => Tclock,
      read_delay => read_delay,
      mem_load   => mem_loadD,
      base_addr  => base_addrD)
    port map (
      clk   => clk,
      reset => rst,
      addr  => daddr,
      data  => ddata,
      rw    => drw,
      req   => dreq,
      hold  => dhold);

  -- clock generation
  CLK_proc : process
  begin
    clk <= '0';
    wait for clk_period/2;
    clk <= '1';
    wait for clk_period/2;
  end process CLK_proc;

  -- waveform generation
  WaveGen_Proc : process
  begin
    -- insert signal assignments here
    rst       <= '1';
    exthold   <= '0';
    flushData <= '0';
    wait for clk_period;
    wait until Clk = '1';
    rst       <= '0';
    --extAddr <= BYTE_ZERO;
    --extReq <= '1';
    --extRw <= '1';
    --extAck <= '0';
    wait for 12 us;
    flushData         <= '1';
    wait until extreq <= '0';
    flushData         <= '0';


    wait;
  end process WaveGen_Proc;

  reg_proc : process(clk)
  begin
    if clk = '1' and clk'event then
      regAddr <= nextAddr;
      tmpCnt  <= nextCnt;
      regData <= nextData;
      regIsel <= nextIsel;
      regDsel <= nextdsel;
      regRw <= nextRw;

      if rst = '1' then
        regAddr <= WORD_ZERO;
        tmpCnt  <= 0;
        regData <= WORD_ZERO;
        regIsel <= '0';
        regDSel <= '0';
        regRw <= '1';
      end if;
    end if;
  end process;

  tmp : process(ddata, extAddr, extDataW, extReq, extrw, idata, regAddr,
                regData, regDsel, regIsel, regRw, tmpCnt)

  begin
    nextAddr <= WORD_ZERO;
    nextCnt  <= 0;
    iaddr    <= WORD_ZERO;
    daddr    <= WORD_ZERO;
    ireq     <= '1';
    irw      <= '1';
    dreq     <= '0';
    drw      <= '1';
    ddata    <= (others => 'Z');
    idata    <= (others => 'Z');
    nextData <= regData;
    nextisel <= regIsel;
    nextdSel <= regDsel;
    extDataR <= BYTE_ZERO;
    nextRw <= regRw;

    if regIsel = '1' then
      iaddr <= regAddr;
    end if;
    if regdSel = '1' then
      daddr <= regAddr;
      dreq  <= '1';
    end if;


    if extReq = '1' then
      nextCnt  <= tmpCnt + 1;
      nextAddr <= regAddr;
      if tmpCnt = 0 then
        nextAddr(31 downto 24) <= extAddr;
      elsif tmpCnt = 1 then
        nextAddr(23 downto 16) <= extAddr;
      elsif tmpCnt = 2 then
        nextAddr(15 downto 8) <= extAddr;
      elsif tmpCnt = 3 then
        nextAddr(7 downto 0) <= extAddr;
        if (regAddr(31 downto 8) & extAddr) < base_addrD then
          iaddr    <= regAddr(31 downto 8) & extAddr;
          nextData <= idata;
          nextIsel <= '1';
          nextRw <= '1';
        else
          daddr    <= regAddr(31 downto 8) & extAddr;
          nextDsel <= '1';
          dreq     <= '1';
          if extrw = '0' then
            nextData(31 downto 24) <= extDataW;
            nextRw <= '0';
          else
            nextData <= ddata;
            nextRw <= '1';
          end if;
        end if;
      elsif tmpCnt = 4 then
        if regIsel = '1' then
          extDataR <= regData(31 downto 24);
        elsif regdsel = '1' then
          if regrw = '1' then
            extDataR <= regData(31 downto 24);
          elsif regrw = '0' then
            nextData(23 downto 16) <= extDataW;
          end if;
        end if;
      elsif tmpCnt = 5 then
        if regIsel = '1' then
          extDataR <= regData(23 downto 16);
        elsif regdsel = '1' then
          if regrw = '1' then
            extDataR <= regData(23 downto 16);
          elsif regrw = '0' then
            nextData(15 downto 8) <= extDataW;
          end if;
        end if;
      elsif tmpCnt = 6 then
        if regIsel = '1' then
          extDataR <= regData(15 downto 8);
        elsif regdsel = '1' then
          if regrw = '1' then
            extDataR <= regData(15 downto 8);
          elsif regrw = '0' then
            nextData(7 downto 0) <= extDataW;
            nextDsel             <= '0';
            nextCnt              <= 0;
            nextRw <= '1';
          end if;
        end if;
      elsif tmpCnt = 7 then
        if regIsel = '1' then
          extDataR <= regData(7 downto 0);
          -- irw      <= '0';
          nextIsel <= '0';
          nextCnt  <= 0;
        elsif regdsel = '1' then
          if regrw = '1' then
            extDataR <= regData(7 downto 0);
            -- drw      <= '0';
            nextDsel <= '0';
            nextCnt  <= 0;
          elsif regrw = '0' then
            nextCnt <= 0;
            nextRw <= '1';
          end if;
        end if;
      end if;
    end if;
  end process tmp;

end architecture top_tb;

-------------------------------------------------------------------------------

configuration mips_top_tb_top_tb_cfg of mips_topp_tb is
  for top_tb
  end for;
end mips_top_tb_top_tb_cfg;

-------------------------------------------------------------------------------
