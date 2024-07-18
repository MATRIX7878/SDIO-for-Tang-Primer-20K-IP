LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY toplevel IS
    PORT(clk, RST, det, RX : IN STD_LOGIC;
         led, TX : OUT STD_LOGIC;
         CMD : INOUT STD_LOGIC;
         DAT : INOUT STD_LOGIC_VECTOR (3 DOWNTO 0)
    );
END ENTITY;

ARCHITECTURE behavior OF toplevel IS
SIGNAL rx_data : STD_LOGIC_VECTOR (7 DOWNTO 0);
SIGNAL rx_ready : STD_LOGIC;

SIGNAL tx_data : STD_LOGIC_VECTOR (7 DOWNTO 0);
SIGNAL tx_ready : STD_LOGIC;

COMPONENT SDDET IS
    PORT(DET : IN STD_LOGIC;
         LED : OUT STD_LOGIC
        );
END COMPONENT;

COMPONENT UART_RX IS
    PORT(clk : IN  STD_LOGIC;
         reset : IN  STD_LOGIC;
         rx_IN : IN  STD_LOGIC;
         rx_data : OUT STD_LOGIC_VECTOR (7 downto 0);
         rx_ready : OUT STD_LOGIC
         );
END COMPONENT;

COMPONENT UART_TX IS
    PORT(clk : IN  STD_LOGIC;
         reset : IN  STD_LOGIC;
         tx_data : IN  STD_LOGIC_VECTOR (7 downto 0);
         tx_ready : OUT STD_LOGIC;
         tx_OUT : OUT STD_LOGIC
         );
END COMPONENT;

BEGIN
    tx_data <= rx_data;

    CARD : SDDET PORT MAP (DET => det, LED => led);
    uartrx : UART_RX PORT MAP (clk => clk, reset => RST, rx_in => RX, rx_data => rx_data, rx_ready => rx_ready);
    uarttx : UART_TX PORT MAP (clk => clk, reset => RST, tx_data => tx_data, tx_ready => tx_ready, tx_OUT => TX);
END ARCHITECTURE;
