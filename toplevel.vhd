LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY toplevel IS
    PORT(clk, RST : IN STD_LOGIC;
         RX : IN STD_LOGIC;
         TX : OUT STD_LOGIC
    );
END ENTITY;

ARCHITECTURE behavior OF toplevel IS

SIGNAL rx_data_ready : STD_LOGIC := '1';
SIGNAL rx_data_valid : STD_LOGIC;

SIGNAL rx_data : STD_LOGIC_VECTOR (7 DOWNTO 0) := (OTHERS => '0');

SIGNAL tx_data_ready : STD_LOGIC;
SIGNAL tx_data_valid : STD_LOGIC;

SIGNAL tx_data : STD_LOGIC_VECTOR (7 DOWNTO 0) := (OTHERS => '0');

SIGNAL tx_cnt : UNSIGNED (7 DOWNTO 0) := (OTHERS => '0');

TYPE state IS (IDLE, SEND, RECIEVE);

COMPONENT UARTRX IS
    PORT(clk, RST : IN STD_LOGIC;
         rx_data_ready, rx_pin: IN STD_LOGIC;
         rx_data_valid : OUT STD_LOGIC;
         rx_data : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
    );
END COMPONENT;

COMPONENT UARTTX IS
    PORT(clk, RST : IN STD_LOGIC;
         tx_data_valid : IN STD_LOGIC;
         tx_data : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
         tx_data_ready, tx_pin : OUT STD_LOGIC
    );
END COMPONENT;

SIGNAL status, nextStatus : state;

BEGIN
    tx_data <= rx_data;
    tx_data_valid <= rx_data_valid;
    rx_data_ready <= tx_data_ready;

    UART_RX : UARTRX PORT MAP (clk, RST, rx_data_ready, RX, rx_data_valid, rx_data);
    UART_TX : UARTTX PORT MAP (clk, RST, tx_data_valid, tx_data, tx_data_ready, TX);
END ARCHITECTURE;
