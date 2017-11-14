--
-- Copyright (C) Telecom ParisTech
-- Copyright (C) Renaud Pacalet (renaud.pacalet@telecom-paristech.fr)
-- 
-- This file must be used under the terms of the CeCILL. This source
-- file is licensed as described in the file COPYING, which you should
-- have received as part of this distribution. The terms are also
-- available at:
-- http://www.cecill.info/licences/Licence_CeCILL_V1.1-US.txt
--

-- See the README.md file for a detailed description of SAB4Z

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sab4z is
  port(
    aclk:       in  std_ulogic;  -- Clock
    aresetn:    in  std_ulogic;  -- Synchronous, active low, reset
    btn:        in  std_ulogic;  -- Command button
    sw:         in  std_ulogic_vector(3 downto 0); -- Slide switches
    led:        out std_ulogic_vector(3 downto 0); -- LEDs

    --------------------------------
    -- AXI lite slave port s0_axi --
    --------------------------------
    -- Inputs (master to slave) --
    ------------------------------
    -- Read address channel
    s0_axi_araddr:  in  std_ulogic_vector(29 downto 0);
    s0_axi_arprot:  in  std_ulogic_vector(2 downto 0);
    s0_axi_arvalid: in  std_ulogic;
    -- Read data channel
    s0_axi_rready:  in  std_ulogic;
    -- Write address channel
    s0_axi_awaddr:  in  std_ulogic_vector(29 downto 0);
    s0_axi_awprot:  in  std_ulogic_vector(2 downto 0);
    s0_axi_awvalid: in  std_ulogic;
    -- Write data channel
    s0_axi_wdata:   in  std_ulogic_vector(31 downto 0);
    s0_axi_wstrb:   in  std_ulogic_vector(3 downto 0);
    s0_axi_wvalid:  in  std_ulogic;
    -- Write response channel
    s0_axi_bready:  in  std_ulogic;
    -------------------------------
    -- Outputs (slave to master) --
    -------------------------------
    -- Read address channel
    s0_axi_arready: out std_ulogic;
    -- Read data channel
    s0_axi_rdata:   out std_ulogic_vector(31 downto 0);
    s0_axi_rresp:   out std_ulogic_vector(1 downto 0);
    s0_axi_rvalid:  out std_ulogic;
    -- Write address channel
    s0_axi_awready: out std_ulogic;
    -- Write data channel
    s0_axi_wready:  out std_ulogic;
    -- Write response channel
    s0_axi_bresp:   out std_ulogic_vector(1 downto 0);
    s0_axi_bvalid:  out std_ulogic;

    ---------------------------
    -- AXI slave port s1_axi --
    ------------------------------
    -- Inputs (master to slave) --
    ------------------------------
    -- Read address channel
    s1_axi_arid:    in  std_ulogic_vector(5 downto 0);
    s1_axi_araddr:  in  std_ulogic_vector(29 downto 0);
    s1_axi_arlen:   in  std_ulogic_vector(3 downto 0);
    s1_axi_arsize:  in  std_ulogic_vector(2 downto 0);
    s1_axi_arburst: in  std_ulogic_vector(1 downto 0);
    s1_axi_arlock:  in  std_ulogic_vector(1 downto 0);
    s1_axi_arcache: in  std_ulogic_vector(3 downto 0);
    s1_axi_arprot:  in  std_ulogic_vector(2 downto 0);
    s1_axi_arqos:   in  std_ulogic_vector(3 downto 0);
    s1_axi_arvalid: in  std_ulogic;
    -- Read data channel
    s1_axi_rready:  in  std_ulogic;
    -- Write address channel
    s1_axi_awid:    in  std_ulogic_vector(5 downto 0);
    s1_axi_awaddr:  in  std_ulogic_vector(29 downto 0);
    s1_axi_awlen:   in  std_ulogic_vector(3 downto 0);
    s1_axi_awsize:  in  std_ulogic_vector(2 downto 0);
    s1_axi_awburst: in  std_ulogic_vector(1 downto 0);
    s1_axi_awlock:  in  std_ulogic_vector(1 downto 0);
    s1_axi_awcache: in  std_ulogic_vector(3 downto 0);
    s1_axi_awprot:  in  std_ulogic_vector(2 downto 0);
    s1_axi_awqos:   in  std_ulogic_vector(3 downto 0);
    s1_axi_awvalid: in  std_ulogic;
    -- Write data channel
    s1_axi_wid:     in  std_ulogic_vector(5 downto 0);
    s1_axi_wdata:   in  std_ulogic_vector(31 downto 0);
    s1_axi_wstrb:   in  std_ulogic_vector(3 downto 0);
    s1_axi_wlast:   in  std_ulogic;
    s1_axi_wvalid:  in  std_ulogic;
    -- Write response channel
    s1_axi_bready:  in  std_ulogic;
    -------------------------------
    -- Outputs (slave to master) --
    -------------------------------
    -- Read address channel
    s1_axi_arready: out std_ulogic;
    -- Read data channel
    s1_axi_rid:     out std_ulogic_vector(5 downto 0);
    s1_axi_rdata:   out std_ulogic_vector(31 downto 0);
    s1_axi_rresp:   out std_ulogic_vector(1 downto 0);
    s1_axi_rlast:   out std_ulogic;
    s1_axi_rvalid:  out std_ulogic;
    -- Write address channel
    s1_axi_awready: out std_ulogic;
    -- Write data channel
    s1_axi_wready:  out std_ulogic;
    -- Write response channel
    s1_axi_bid:     out std_ulogic_vector(5 downto 0);
    s1_axi_bresp:   out std_ulogic_vector(1 downto 0);
    s1_axi_bvalid:  out std_ulogic;

    ---------------------------
    -- AXI master port m_axi --
    ---------------------------
    -------------------------------
    -- Outputs (slave to master) --
    -------------------------------
    -- Read address channel
    m_axi_arid:    out std_ulogic_vector(5 downto 0);
    m_axi_araddr:  out std_ulogic_vector(31 downto 0);
    m_axi_arlen:   out std_ulogic_vector(3 downto 0);
    m_axi_arsize:  out std_ulogic_vector(2 downto 0);
    m_axi_arburst: out std_ulogic_vector(1 downto 0);
    m_axi_arlock:  out std_ulogic_vector(1 downto 0);
    m_axi_arcache: out std_ulogic_vector(3 downto 0);
    m_axi_arprot:  out std_ulogic_vector(2 downto 0);
    m_axi_arqos:   out std_ulogic_vector(3 downto 0);
    m_axi_arvalid: out std_ulogic;
    -- Read data channel
    m_axi_rready:  out std_ulogic;
    -- Write address channel
    m_axi_awid:    out std_ulogic_vector(5 downto 0);
    m_axi_awaddr:  out std_ulogic_vector(31 downto 0);
    m_axi_awlen:   out std_ulogic_vector(3 downto 0);
    m_axi_awsize:  out std_ulogic_vector(2 downto 0);
    m_axi_awburst: out std_ulogic_vector(1 downto 0);
    m_axi_awlock:  out std_ulogic_vector(1 downto 0);
    m_axi_awcache: out std_ulogic_vector(3 downto 0);
    m_axi_awprot:  out std_ulogic_vector(2 downto 0);
    m_axi_awqos:   out std_ulogic_vector(3 downto 0);
    m_axi_awvalid: out std_ulogic;
    -- Write data channel
    m_axi_wid:     out std_ulogic_vector(5 downto 0);
    m_axi_wdata:   out std_ulogic_vector(31 downto 0);
    m_axi_wstrb:   out std_ulogic_vector(3 downto 0);
    m_axi_wlast:   out std_ulogic;
    m_axi_wvalid:  out std_ulogic;
    -- Write response channel
    m_axi_bready:  out std_ulogic;
    ------------------------------
    -- Inputs (slave to master) --
    ------------------------------
    -- Read address channel
    m_axi_arready: in  std_ulogic;
    -- Read data channel
    m_axi_rid:     in  std_ulogic_vector(5 downto 0);
    m_axi_rdata:   in  std_ulogic_vector(31 downto 0);
    m_axi_rresp:   in  std_ulogic_vector(1 downto 0);
    m_axi_rlast:   in  std_ulogic;
    m_axi_rvalid:  in  std_ulogic;
    -- Write address channel
    m_axi_awready: in  std_ulogic;
    -- Write data channel
    m_axi_wready:  in  std_ulogic;
    -- Write response channel
    m_axi_bid:     in  std_ulogic_vector(5 downto 0);
    m_axi_bresp:   in  std_ulogic_vector(1 downto 0);
    m_axi_bvalid:  in  std_ulogic
  );
end entity sab4z;

architecture rtl of sab4z is

  constant axi_resp_okay:   std_ulogic_vector(1 downto 0) := "00";
  constant axi_resp_exokay: std_ulogic_vector(1 downto 0) := "01";
  constant axi_resp_slverr: std_ulogic_vector(1 downto 0) := "10";
  constant axi_resp_decerr: std_ulogic_vector(1 downto 0) := "11";

  -- STATUS register
  signal status: std_ulogic_vector(31 downto 0);

  alias life:    std_ulogic_vector(3 downto 0) is status(3 downto 0);
  alias cnt:     std_ulogic_vector(3 downto 0) is status(7 downto 4);
  alias arcnt:   std_ulogic_vector(3 downto 0) is status(11 downto 8);
  alias rcnt:    std_ulogic_vector(3 downto 0) is status(15 downto 12);
  alias awcnt:   std_ulogic_vector(3 downto 0) is status(19 downto 16);
  alias wcnt:    std_ulogic_vector(3 downto 0) is status(23 downto 20);
  alias bcnt:    std_ulogic_vector(3 downto 0) is status(27 downto 24);
  alias slsw:    std_ulogic_vector(3 downto 0) is status(31 downto 28);

  -- R register
  signal r: std_ulogic_vector(31 downto 0);

  -- Or reduction of std_ulogic_vector
  function or_reduce(v: std_ulogic_vector) return std_ulogic is
    variable tmp: std_ulogic_vector(v'length - 1 downto 0) := v;
  begin
    if tmp'length = 0 then
      return '0';
    elsif tmp'length = 1 then
      return tmp(0);
    else
      return or_reduce(tmp(tmp'length - 1 downto tmp'length / 2)) or
             or_reduce(tmp(tmp'length / 2 - 1 downto 0));
    end if;
  end function or_reduce;

  signal btn_sd: std_ulogic;  -- Synchronized and debounced command button
  signal btn_re: std_ulogic;  -- Rising edge of command button

  -- local copies of outputs
  signal s1_axi_arready_l: std_ulogic;
  signal s1_axi_rvalid_l: std_ulogic;
  signal s1_axi_awready_l: std_ulogic;
  signal s1_axi_wready_l: std_ulogic;
  signal s1_axi_bvalid_l: std_ulogic;

  -- debouncer
  constant  n0: positive := 50000; -- sampling counter wrapping value
  constant  n1: positive := 10;    -- debouncing counter maximum value

  signal cnt0: natural range 0 to n0;    -- sampling counter
  signal cnt1: natural range 0 to n1;    -- debouncing counter
  signal sync: std_ulogic_vector(0 to 1); -- re-synchronizer
  signal btn_sd_p: std_ulogic;            -- previous value of btn_sd

begin

  -- Synchronizer - debouncer
  btn_sd <= '1' when cnt1 = n1 else '0';

  process(aclk)
  begin
    if rising_edge(aclk) then
      if aresetn = '0' then
        cnt0     <= 0;
        cnt1     <= 0;
        sync     <= (others => '0');
        btn_re   <= '0';
        btn_sd_p <= '0';
      else
        if sync(1) = '0' then
          cnt1 <= 0;
        elsif cnt0 = n0 and sync(1) = '1' and cnt1 < n1 then
          cnt1 <= cnt1 + 1;
        end if;
        if cnt0 = n0 then
          cnt0 <= 0;
        else
          cnt0 <= cnt0 + 1;
        end if;
        sync <= btn & sync(0);
        btn_re    <= (not btn_sd_p) and btn_sd;
        btn_sd_p   <= btn_sd;
      end if;
    end if;
  end process;

  -- LED outputs
  process(r, status, cnt, btn_sd)
    variable m0: std_ulogic_vector(63 downto 0);
    variable m1: std_ulogic_vector(31 downto 0);
    variable m2: std_ulogic_vector(15 downto 0);
    variable m3: std_ulogic_vector(7 downto 0);
    variable m4: std_ulogic_vector(3 downto 0);
  begin
    m0 := r & status;
    if cnt(3) = '1' then
      m1 := m0(63 downto 32);
    else
      m1 := m0(31 downto 0);
    end if;
    if cnt(2) = '1' then
      m2 := m1(31 downto 16);
    else
      m2 := m1(15 downto 0);
    end if;
    if cnt(1) = '1' then
      m3 := m2(15 downto 8);
    else
      m3 := m2(7 downto 0);
    end if;
    if cnt(0) = '1' then
      m4 := m3(7 downto 4);
    else
      m4 := m3(3 downto 0);
    end if;
    if btn_sd = '1' then
      m4 := cnt;
    end if;
    led <= std_ulogic_vector(m4);
  end process;

  -- Status register
  process(aclk)
    constant lifecntwidth: positive := 25;
    variable lifecnt: unsigned(lifecntwidth - 1 downto 0); -- Life monitor counter
    variable lifeleft2right: boolean;
  begin
    if rising_edge(aclk) then
      if aresetn = '0' then
        life  <= X"1";
        cnt   <= X"0";
        arcnt <= X"0";
        rcnt  <= X"0";
        awcnt <= X"0";
        wcnt  <= X"0";
        bcnt  <= X"0";
        lifecnt := (others => '0');
        lifeleft2right := true;
      else
        -- Life monitor
        lifecnt := lifecnt + 1;
        if lifecnt(lifecntwidth - 1) = '1' then
          lifecnt(lifecntwidth - 1) := '0';
          if lifeleft2right then
            life <= life(0) & life(3 downto 1);
            if life(1) = '1' then
              lifeleft2right := not lifeleft2right;
            end if;
          else
            life <= life(2 downto 0) & life(3);
            if life(2) = '1' then
              lifeleft2right := not lifeleft2right;
            end if;
          end if;
        end if;
        -- BTN event counter
        if btn_re = '1' then
          cnt <= std_ulogic_vector(unsigned(cnt) + 1);
        end if;
        -- S1_AXI address read transactions counter
        if s1_axi_arvalid = '1' and s1_axi_arready_l = '1' then
          arcnt <= std_ulogic_vector(unsigned(arcnt) + 1);
        end if;
        -- S1_AXI data read transactions counter
        if s1_axi_rvalid_l = '1' and s1_axi_rready = '1' then
          rcnt <= std_ulogic_vector(unsigned(rcnt) + 1);
        end if;
        -- S1_AXI address write transactions counter
        if s1_axi_awvalid = '1' and s1_axi_awready_l = '1' then
          awcnt <= std_ulogic_vector(unsigned(awcnt) + 1);
        end if;
        -- S1_AXI data write transactions counter
        if s1_axi_wvalid = '1' and s1_axi_wready_l = '1' then
          wcnt <= std_ulogic_vector(unsigned(wcnt) + 1);
        end if;
        -- S1_AXI write response transactions counter
        if s1_axi_bvalid_l = '1' and s1_axi_bready = '1' then
          bcnt <= std_ulogic_vector(unsigned(bcnt) + 1);
        end if;
        -- Slide switches
        slsw <= std_ulogic_vector(sw);
      end if;
    end if;
  end process;

  -- Forwarding of S1_AXI read-write requests to M_AXI and of M_AXI responses to S1_AXI
  m_axi_arid    <= s1_axi_arid;
  m_axi_araddr  <= "00" & s1_axi_araddr;
  m_axi_arlen   <= s1_axi_arlen;
  m_axi_arsize  <= s1_axi_arsize;
  m_axi_arburst <= s1_axi_arburst;
  m_axi_arlock  <= s1_axi_arlock;
  m_axi_arcache <= s1_axi_arcache;
  m_axi_arprot  <= s1_axi_arprot;
  m_axi_arqos   <= s1_axi_arqos;
  m_axi_arvalid <= s1_axi_arvalid;
  m_axi_rready  <= s1_axi_rready;
  m_axi_awid    <= s1_axi_awid;
  m_axi_awaddr  <= "00" & s1_axi_awaddr;
  m_axi_awlen   <= s1_axi_awlen;
  m_axi_awsize  <= s1_axi_awsize;
  m_axi_awburst <= s1_axi_awburst;
  m_axi_awlock  <= s1_axi_awlock;
  m_axi_awcache <= s1_axi_awcache;
  m_axi_awprot  <= s1_axi_awprot;
  m_axi_awqos   <= s1_axi_awqos;
  m_axi_awvalid <= s1_axi_awvalid;
  m_axi_wid     <= s1_axi_wid;
  m_axi_wdata   <= s1_axi_wdata;
  m_axi_wstrb   <= s1_axi_wstrb;
  m_axi_wlast   <= s1_axi_wlast;
  m_axi_wvalid  <= s1_axi_wvalid;
  m_axi_bready  <= s1_axi_bready;

  s1_axi_arready_l <= m_axi_arready;
  s1_axi_arready   <= s1_axi_arready_l;
  s1_axi_rid       <= m_axi_rid;
  s1_axi_rdata     <= m_axi_rdata;
  s1_axi_rresp     <= m_axi_rresp;
  s1_axi_rlast     <= m_axi_rlast;
  s1_axi_rvalid_l  <= m_axi_rvalid;
  s1_axi_rvalid    <= s1_axi_rvalid_l;
  s1_axi_awready_l <= m_axi_awready;
  s1_axi_awready   <= s1_axi_awready_l;
  s1_axi_wready_l  <= m_axi_wready;
  s1_axi_wready    <= s1_axi_wready_l;
  s1_axi_bid       <= m_axi_bid;
  s1_axi_bresp     <= m_axi_bresp;
  s1_axi_bvalid_l  <= m_axi_bvalid;
  s1_axi_bvalid    <= s1_axi_bvalid_l;

  -- S0_AXI read-write requests
  s0_axi_pr: process(aclk)
    -- idle: waiting for AXI master requests: when receiving write address and data valid (higher priority than read), perform the write, assert write address
    --       ready, write data ready and bvalid, go to w1, else, when receiving address read valid, perform the read, assert read address ready, read data valid
    --       and go to r1
    -- w1:   deassert write address ready and write data ready, wait for write response ready: when receiving it, deassert write response valid, go to idle
    -- r1:   deassert read address ready, wait for read response ready: when receiving it, deassert read data valid, go to idle
    type state_type is (idle, w1, r1);
    variable state: state_type;
  begin
    if rising_edge(aclk) then
      if aresetn = '0' then
        s0_axi_arready <= '0';
        s0_axi_rdata   <= (others => '0');
        s0_axi_rresp   <= (others => '0');
        s0_axi_rvalid  <= '0';
        s0_axi_awready <= '0';
        s0_axi_wready  <= '0';
        s0_axi_bresp   <= (others => '0');
        s0_axi_bvalid  <= '0';
        state := idle;
      else
        -- s0_axi write and read
        case state is
          when idle =>
            if s0_axi_awvalid = '1' and s0_axi_wvalid = '1' then -- Write address and data
              if or_reduce(s0_axi_awaddr(29 downto 3)) /= '0' then -- If unmapped address
                s0_axi_bresp <= axi_resp_decerr;
              elsif s0_axi_awaddr(2) = '0' then -- If read-only status register
                s0_axi_bresp <= axi_resp_slverr;
              else
                s0_axi_bresp <= axi_resp_okay;
                for i in 0 to 3 loop
                  if s0_axi_wstrb(i) = '1' then
                    r(8 * i + 7 downto 8 * i) <= s0_axi_wdata(8 * i + 7 downto 8 * i);
                  end if;
                end loop;
              end if;
              s0_axi_awready <= '1';
              s0_axi_wready <= '1';
              s0_axi_bvalid <= '1';
              state := w1;
            elsif s0_axi_arvalid = '1' then
              if or_reduce(s0_axi_araddr(29 downto 3)) /= '0' then -- If unmapped address
                s0_axi_rdata <= (others => '0');
                s0_axi_rresp <= axi_resp_decerr;
              else
                s0_axi_rresp <= axi_resp_okay;
                if s0_axi_araddr(2) = '0' then -- If status register
                  s0_axi_rdata <= status;
                else
                  s0_axi_rdata <= r;
                end if;
              end if;
              s0_axi_arready <= '1';
              s0_axi_rvalid <= '1';
              state := r1;
            end if;
          when w1 =>
            s0_axi_awready <= '0';
            s0_axi_wready <= '0';
            if s0_axi_bready = '1' then
              s0_axi_bvalid <= '0';
              state := idle;
            end if;
          when r1 =>
            s0_axi_arready <= '0';
            if s0_axi_rready = '1' then
              s0_axi_rvalid <= '0';
              state := idle;
            end if;
        end case;
      end if;
    end if;
  end process s0_axi_pr;

end architecture rtl;
