LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY toplevel IS
    PORT(clk, RST, det, RX : IN STD_LOGIC;
         led, TX : OUT STD_LOGIC;
         I2C : INOUT STD_LOGIC;
         DAT : INOUT STD_LOGIC_VECTOR (3 DOWNTO 0)
    );
END ENTITY;

ARCHITECTURE behavior OF toplevel IS
SIGNAL rx_data : STD_LOGIC_VECTOR (7 DOWNTO 0);
SIGNAL rx_ready : STD_LOGIC;

SIGNAL oslow : STD_LOGIC;
SIGNAL ofast : STD_LOGIC;

SIGNAL ARGRESP : STD_LOGIC_VECTOR (47 DOWNTO 0);
SIGNAL C2RESP : STD_LOGIC_VECTOR (135 DOWNTO 0);
SIGNAL DATA : STD_LOGIC_VECTOR (4095 DOWNTO 0);

COMPONENT SDDET IS
    PORT(DET : IN STD_LOGIC;
         LED : OUT STD_LOGIC
        );
END COMPONENT;

COMPONENT UART_RX IS
    PORT(clk : IN  STD_LOGIC;
         reset : IN  STD_LOGIC;
         rx_IN : IN  STD_LOGIC;
         rx_ready : OUT STD_LOGIC;
         rx_data : OUT STD_LOGIC_VECTOR (7 downto 0)
         );
END COMPONENT;

COMPONENT UART_TX IS
    PORT(clk : IN  STD_LOGIC;
         reset : IN  STD_LOGIC;
         tx_ready : IN STD_LOGIC;
         tx_data : IN  STD_LOGIC_VECTOR (7 downto 0);
         tx_OUT : OUT STD_LOGIC
         );
END COMPONENT;

COMPONENT clockSlow IS
    PORT(iclk, clr : IN STD_LOGIC;
         oslow : OUT STD_LOGIC);
END COMPONENT;

COMPONENT clockFast IS
    PORT(iclk, clr : IN STD_LOGIC;
         ofast : OUT STD_LOGIC);
END COMPONENT;

COMPONENT SDCTRL IS
    PORT (clk, clkSlow, clkFast : IN STD_LOGIC;
          led : OUT STD_LOGIC;
          CMD : INOUT STD_LOGIC_VECTOR (47 DOWNTO 0);
          C2RESP : INOUT STD_LOGIC_VECTOR (135 DOWNTO 0)
         );
END COMPONENT;

BEGIN
    --CARD : SDDET PORT MAP (DET => det, LED => led);
    uartrx : UART_RX PORT MAP (clk => clk, reset => RST, rx_IN   => RX, rx_ready => rx_ready, rx_data => rx_data);
    uarttx : UART_TX PORT MAP (clk => clk, reset => RST, tx_data => rx_data, tx_ready => rx_ready, tx_OUT => TX);
    TURTLE : clockSlow PORT MAP(iclk => clk, clr => RST, oslow => oslow);
    RABBIT : clockFast PORT MAP(iclk => clk, clr => RST, ofast => ofast);
   -- SDINIT : SDCTRL PORT MAP (clk => clk, clkSlow => oslow, clkFast => ofast, led => led, CMD => ARGRESP, C2RESP => C2RESP);
END ARCHITECTURE;
