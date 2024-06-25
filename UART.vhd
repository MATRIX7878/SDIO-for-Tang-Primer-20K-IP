LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY UARTRX IS
    PORT(clk, RST : IN STD_LOGIC;
         rx_data_ready, rx_pin: IN STD_LOGIC;
         rx_data_valid : OUT STD_LOGIC;
         rx_data : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
    );
END ENTITY;

ARCHITECTURE behavior OF UARTRX IS

CONSTANT CYCLE : INTEGER := 235;

SIGNAL rx0 : STD_LOGIC;
SIGNAL rx1 : STD_LOGIC;
SIGNAL rxNeg : STD_LOGIC;
SIGNAL rxBit : STD_LOGIC_VECTOR (7 DOWNTO 0);

SIGNAL rxCycle : UNSIGNED (15 DOWNTO 0) := (OTHERS => '0');
SIGNAL rxCnt : UNSIGNED (2 DOWNTO 0) := (OTHERS => '0');

TYPE stateRx IS (RIDLE, RSTART, REC, RSTOP, RDATA);

SIGNAL status, nextStateRx : stateRx;

BEGIN
    PROCESS(clk, RST)
    BEGIN
        IF (RISING_EDGE(clk)) THEN
            IF RST = '0' THEN
                rx0 <= '0';
                rx1 <= '0';
                status <= RIDLE;
            ELSE
                rx0 <= rx_pin;
                rx1 <= rx0;
                status <= nextStateRx;
            END IF;
        END IF;
    END PROCESS;

    PROCESS(ALL) IS
    BEGIN
        rxNeg <= rx1 AND NOT rx0;
        CASE status IS
            WHEN RIDLE => IF rxNeg THEN
                            nextStateRx <= RSTART;
                        ELSE
                            nextStateRx <= RIDLE;
                        END IF;
            WHEN RSTART => IF rxCycle = CYCLE - 1 THEN
                                nextStateRx <= REC;
                            ELSE
                                nextStateRx <= RSTART;
                            END IF;
            WHEN REC => IF (rxCycle = CYCLE - 1 AND rxCnt = 7) THEN
                            nextStateRx <= RSTOP;
                        ELSE
                            nextStateRx <= REC;
                        END IF;
            WHEN RSTOP => IF rxCycle = CYCLE / 2 - 1 THEN
                                nextStateRx <= RDATA;
                            ELSE
                                nextStateRx <= RSTOP;
                            END IF;
            WHEN RDATA => IF rx_data_ready THEN
                                nextStateRx <= RIDLE;
                            ELSE
                                nextStateRx <= RDATA;
                            END IF;
            WHEN OTHERS => nextStateRx <= RIDLE;
        END CASE;
    END PROCESS;

    PROCESS(ALL) IS
    BEGIN
        IF RISING_EDGE(clk) THEN
            IF RST ='0' THEN
                rx_data_valid <= '0';
            ELSIF (status = RSTOP AND nextStateRx /= status) THEN
                rx_data_valid <= '1';
            ELSIF (status = RDATA AND rx_data_ready = '1') THEN
                rx_data_valid <= '0';
            END IF;
        END IF;

        IF RISING_EDGE(clk) THEN
            IF RST = '0' THEN
                rx_data <= (OTHERS => '0');
            ELSIF (status = RSTOP AND nextStateRx /= status) THEN
                rx_data <= rxBit;
            END IF;
        END IF;

        IF RISING_EDGE(clk) THEN
            IF RST = '0' THEN
                rxCnt <= (OTHERS => '0');
            ELSIF (status = REC) THEN
                IF rxCycle = CYCLE - 1 THEN
                    rxCnt <= rxCnt + 1;
                ELSE
                    rxCnt <= rxCnt;
                END IF;
            ELSE
                rxCnt <= (OTHERS => '0');
            END IF;
        END IF;

        IF RISING_EDGE(clk) THEN
            IF RST = '0' THEN
                rxCycle <= (OTHERS => '0');
            ELSIF ((status = REC AND rxCycle = CYCLE - 1) OR nextStateRx /= status) THEN
                rxCycle <= (OTHERS => '0');
            ELSE
                rxCycle <= rxCycle + 1;
            END IF;
        END IF;

        IF RISING_EDGE(clk) THEN
            IF RST = '0' THEN
                rxBit <= (OTHERS => '0');
            ELSIF (status = REC AND rxCycle = CYCLE / 2 - 1) THEN
                rxBit(TO_INTEGER(rxCnt)) <= rx_pin;
            ELSE
                rxBit <= rxBit;
            END IF;
        END IF;
    END PROCESS;
END behavior;

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY UARTTX IS
    PORT(clk, RST : IN STD_LOGIC;
         tx_data_valid : IN STD_LOGIC;
         tx_data : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
         tx_data_ready, tx_pin : OUT STD_LOGIC
    );
END ENTITY;

ARCHITECTURE Behavior OF UARTTX IS

SIGNAL txReg : STD_LOGIC;
SIGNAL txLatch : STD_LOGIC_VECTOR (7 DOWNTO 0);

SIGNAL txCycle : UNSIGNED (15 DOWNTO 0);
SIGNAL txBit : UNSIGNED (2 DOWNTO 0);

TYPE stateTx IS (TIDLE, TSTART, SEND, TSTOP);

SIGNAL trans, nextStateTx : stateTx;

CONSTANT CYCLE : INTEGER := 235;

BEGIN
    tx_pin <= txReg;

    PROCESS(clk, RST)
    BEGIN
        IF (RISING_EDGE(clk)) THEN
            IF RST = '0' THEN
                trans <= TIDLE;
            ELSE
                trans <= nextStateTx;
            END IF;
        END IF;
    END PROCESS;

    PROCESS(ALL) IS
    BEGIN
        CASE trans IS
            WHEN TIDLE => IF tx_data_valid = '1' THEN
                            nextStateTx <= TSTART;
                        ELSE
                            nextStateTx <= TIDLE;
                        END IF;
            WHEN TSTART => IF txCycle = CYCLE - 1 THEN
                                nextStateTx <= SEND;
                            ELSE
                                nextStateTx <= TSTART;
                            END IF;
            WHEN SEND => IF (txCycle = CYCLE - 1 AND txBit = 7) THEN
                            nextStateTx <= TSTOP;
                        ELSE
                            nextStateTx <= SEND;
                        END IF;
            WHEN TSTOP => IF txCycle = CYCLE - 1 THEN
                                nextStateTx <= TIDLE;
                            ELSE
                                nextStateTx <= TSTOP;
                            END IF;
            WHEN OTHERS => nextStateTx <= TIDLE;
        END CASE;
    END PROCESS;

    PROCESS(ALL) IS
    BEGIN
        IF RISING_EDGE(clk) THEN
            IF RST = '0' THEN
                tx_data_ready <= '0';
            ELSIF (trans = TIDLE) THEN
                IF tx_data_valid = '1' THEN
                    tx_data_ready <= '0';
                ELSE
                    tx_data_ready <= '1';
                END IF;
            ELSIF (trans = TSTOP AND txCycle = CYCLE - 1) THEN
                tx_data_ready <= '1';
            END IF;
        END IF;

        IF RISING_EDGE(clk) THEN
            IF RST = '0' THEN
                txLatch <= (OTHERS => '0');
            ELSIF (trans = TIDLE AND tx_data_valid = '1') THEN
                txLatch <= tx_data;
            END IF;
        END IF;

        IF RISING_EDGE(clk) THEN
            IF RST = '0' THEN
                txBit <= (OTHERS => '0');
            ELSIF (trans = SEND) THEN
                IF txCycle = CYCLE - 1 THEN
                    txBit <= txBit + 1;
                ELSE
                    txBit <= txBit;
                END IF;
            ELSE
                txBit <= (OTHERS => '0');
            END IF;
        END IF;

        IF RISING_EDGE(clk) THEN
            IF RST = '0' THEN
                txCycle <= (OTHERS => '0');
            ELSIF ((trans = SEND AND txCycle = CYCLE - 1) OR nextStateTx /= trans) THEN
                txCycle <= (OTHERS => '0');
            ELSE
                txCycle <= txCycle + 1;
            END IF;
        END IF;

        IF RISING_EDGE(clk) THEN
            IF RST = '0' THEN
                txReg <= '1';
            ELSE
                CASE trans IS
                    WHEN TIDLE => txReg <= '1';
                    WHEN TSTOP => txReg <= '1';
                    WHEN TSTART => txReg <= '0';
                    WHEN SEND => txReg <= txLatch(TO_INTEGER(txBit));
                    WHEN OTHERS => txReg <= '1';
                END CASE;
            END IF;
        END IF;
    END PROCESS;
END Behavior;
