LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD_UNSIGNED.ALL;

ENTITY UARTRX IS
    PORT(baud, dataRX : IN STD_LOGIC;
         triggerRX : OUT STD_LOGIC
         );
END ENTITY;

ARCHITECTURE behavior OF UARTRX IS
TYPE state IS (IDLE, START, RX, STOP);
SIGNAL currentState, nextState : state;

SIGNAL counter : INTEGER;

SIGNAL receive : STD_LOGIC_VECTOR (7 DOWNTO 0);

BEGIN
    PROCESS(ALL)
    BEGIN
        IF RISING_EDGE(baud) THEN
            CASE currentState IS
            WHEN IDLE => IF dataRX = '0' THEN
                triggerRX <= '0';
                nextState <= START;
            ELSE
                nextState <= IDLE;
            END IF;
            WHEN START => nextState <= RX;
            WHEN RX => IF counter = 8 THEN
                counter <= 0;
                nextState <= STOP;
            ELSE
                receive(counter) <= dataRX;
                counter <= counter + 1;
            END IF;
            WHEN STOP => triggerRX <= '1';
                nextState <= IDLE;
            END CASE;
        END IF;
    END PROCESS;
END ARCHITECTURE;

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD_UNSIGNED.ALL;

ENTITY UARTTX IS
    PORT(baud, triggerTX : IN STD_LOGIC;
         dataTX : OUT STD_LOGIC
         );
END ENTITY;

ARCHITECTURE Behavior OF UARTTX IS
TYPE state IS (IDLE, START, TX, STOP);
SIGNAL currentState, nextState : state;

SIGNAL counter : STD_LOGIC_VECTOR (2 DOWNTO 0) := (OTHERS => '0');

BEGIN
    PROCESS(ALL)
    BEGIN
        IF RISING_EDGE(baud) THEN
            CASE currentState IS
            WHEN IDLE => IF triggerTX THEN
                nextState <= START;
            ELSE
                nextState <= IDLE;
            END IF;
            WHEN START => dataTX <= '0';
                nextState <= TX;
            WHEN TX => IF counter = 8 THEN
                counter <= (OTHERS => '0');
                nextState <= STOP;
            ELSE
                dataTX <= dataTX;
                counter <= counter + '1';
            END IF;
            WHEN STOP => dataTX <= '1';
                nextState <= IDLE;
            END CASE;
        END IF;
    END PROCESS;
END ARCHITECTURE;
