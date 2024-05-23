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
SIGNAL tx_str : STD_LOGIC_VECTOR (23 DOWNTO 0) := (OTHERS => '0');

SIGNAL tx_cnt : UNSIGNED (7 DOWNTO 0) := (OTHERS => '0');

SIGNAL send_data : STD_LOGIC_VECTOR (63 DOWNTO 0):= (OTHERS => '0');

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

SIGNAL status : state;

BEGIN
    PROCESS(clk, RST, status) IS
    BEGIN
       IF RISING_EDGE(clk) THEN
        IF RST = '0' THEN
            tx_data <= (OTHERS => '0');
            status <= IDLE;
            tx_cnt <= (OTHERS => '0');
            tx_data_valid <= '0';
        ELSE
            CASE status IS
                WHEN IDLE => status <= SEND;
                WHEN SEND => tx_data <= tx_str(7 DOWNTO 0) SLL 8;
                             IF (tx_data_valid = '1' AND tx_data_ready = '1' AND tx_cnt < 8) THEN
                                 tx_cnt <= tx_cnt + '1';
                             ELSIF tx_data_valid AND tx_data_ready THEN
                                 tx_cnt <= (OTHERS => '0');
                                 tx_data_valid <= '0';
                                 status <= RECIEVE;
                             ELSIF NOT tx_data_valid THEN
                                 tx_data_valid <= '1';
                             END IF;
                WHEN RECIEVE => IF rx_data_valid = '1' THEN
                                    tx_data_valid <= '1';
                                    tx_data <= rx_data;
                                ELSIF tx_data_valid AND tx_data_ready THEN
                                    tx_data_valid <= '0';
                                ELSE
                                    status <= SEND;
                                END IF;
                WHEN OTHERS => status <= IDLE;
            END CASE;
        END IF;
       END IF;
    END PROCESS;

    PROCESS(ALL) IS
    VARIABLE data : INTEGER;
    BEGIN
        data := 8 * (8 - TO_INTEGER(tx_cnt));
        tx_str(7 DOWNTO 0) <= send_data(data+7 DOWNTO data);
        tx_str(15 DOWNTO 8) <= X"0D";
        tx_str(23 DOWNTO 16) <= X"0A";
    END PROCESS; 

    UART_RX : UARTRX PORT MAP (clk, RST, rx_data_ready, RX, rx_data_valid, rx_data);
    UART_TX : UARTTX PORT MAP (clk, RST, tx_data_valid, tx_data, tx_data_ready, TX);
END ARCHITECTURE;
