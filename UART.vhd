LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD_UNSIGNED.ALL;

ENTITY UART_TX IS
    PORT (clk : IN  STD_LOGIC;
          reset : IN  STD_LOGIC;
          tx_data : IN  STD_LOGIC_VECTOR (7 downto 0);
          tx_ready : OUT STD_LOGIC;
          tx_OUT : OUT STD_LOGIC);
END UART_TX;

ARCHITECTURE Behavior OF UART_TX IS
TYPE state IS (IDLE, START, SEND, STOP);
SIGNAL currentState, nextState : state;

CONSTANT BAUD : STD_LOGIC_VECTOR (7 DOWNTO 0) := d"234";

SIGNAL bits : INTEGER RANGE 0 TO 7 := 0;
SIGNAL counter : STD_LOGIC_VECTOR (7 DOWNTO 0) := (OTHERS => '0');

BEGIN
    PROCESS(ALL)
    BEGIN
        IF RISING_EDGE(clk) THEN
            IF NOT reset THEN
                nextState <= IDLE;
            ELSE
                nextState <= nextState;
            END IF;

            CASE currentState IS
            WHEN IDLE => tx_ready <= '0';
                nextState <= START;
            WHEN START => IF counter = BAUD THEN
                tx_OUT <= '0';
                counter <= (OTHERS => '0');
                nextState <= SEND;
            ELSE
                counter <= counter + '1';
            END IF;
            WHEN SEND => IF counter = BAUD AND bits = 8 THEN
                counter <= (OTHERS => '0');
                bits <= 0;
                nextState <= STOP;
            ELSIF counter = BAUD AND bits < 8 THEN
                tx_OUT <= tx_data(bits);
                counter <= (OTHERS => '0');
                bits <= bits + 1;
            ELSE
                counter <= counter + '1';
            END IF;
            WHEN STOP => IF counter = BAUD THEN
                tx_ready <= '1';
                counter <= (OTHERS => '0');
                nextState <= IDLE;
            ELSE
                counter <= counter + '1';
            END IF;
            END CASE;
        END IF;
    END PROCESS;
END ARCHITECTURE;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD_UNSIGNED.ALL;

ENTITY UART_RX IS
    PORT(clk : IN  STD_LOGIC;
         reset : IN  STD_LOGIC;
         rx_IN : IN  STD_LOGIC;
         rx_data : OUT STD_LOGIC_VECTOR (7 downto 0);
         rx_ready : OUT STD_LOGIC);
END UART_RX;

ARCHITECTURE Behavior OF UART_RX IS
TYPE state IS (IDLE, START, RECEIVE, STOP);
SIGNAL currentState, nextState : state;

CONSTANT BAUD : STD_LOGIC_VECTOR (7 DOWNTO 0) := d"234";

SIGNAL bits : INTEGER RANGE 0 TO 7 := 0;
SIGNAL counter : STD_LOGIC_VECTOR (7 DOWNTO 0) := (OTHERS => '0');

BEGIN
    PROCESS(ALL)
    BEGIN
        IF RISING_EDGE(clk) THEN
            IF NOT reset THEN
                nextState <= IDLE;
            ELSE
                nextState <= nextState;
            END IF;

            CASE currentState IS
            WHEN IDLE => rx_ready <= '0';
                nextState <= START;
            WHEN START => IF counter = BAUD THEN
                counter <= (OTHERS => '0');
                nextState <= RECEIVE;
            ELSE
                counter <= counter + '1';
            END IF;
            WHEN RECEIVE => IF counter = BAUD AND bits = 8 THEN
                counter <= (OTHERS => '0');
                bits <= 0;
                nextState <= STOP;
            ELSIF counter = BAUD AND bits < 8 THEN
                rx_data(bits) <= rx_IN;
                counter <= (OTHERS => '0');
                bits <= bits + 1;
            ELSE
                counter <= counter + '1';
            END IF;
            WHEN STOP => IF counter = BAUD / 2 THEN
                rx_ready <= '1';
                counter <= (OTHERS => '0');
                nextState <= IDLE;
            ELSE
                counter <= counter + '1';
            END IF;
            END CASE;
        END IF;
    END PROCESS;
END ARCHITECTURE;
