LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY SDDET IS
    PORT(DET : IN STD_LOGIC;
         LED : OUT STD_LOGIC
        );
END ENTITY;

ARCHITECTURE behavior OF SDDET IS

BEGIN
    PROCESS(DET)
    BEGIN
        WHILE DET LOOP
        END LOOP;
        LED <= '0';
    END PROCESS;
END ARCHITECTURE;

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD_UNSIGNED.ALL;

ENTITY SDCTRL IS
    PORT (clk, clkSlow, clkFast : IN STD_LOGIC;
          led : OUT STD_LOGIC;
          CMD : INOUT STD_LOGIC_VECTOR (47 DOWNTO 0);
          C2RESP : INOUT STD_LOGIC_VECTOR (135 DOWNTO 0)
         );
END ENTITY;

ARCHITECTURE Behavior OF SDCTRL IS
COMPONENT SDDET IS
    PORT(DET : IN STD_LOGIC;
         LED : OUT STD_LOGIC
        );
END COMPONENT;

COMPONENT CRC7 IS
    PORT (clk, CLR : IN STD_LOGIC;
          DATA : IN STD_LOGIC;
          CRC7 : OUT STD_LOGIC_VECTOR (6 DOWNTO 0)
         );
END COMPONENT;
TYPE state IS (DUMMY, CMD0, CMD55, CMD55RESP, ACMD41, ACMD41RESP, CMD2, CMD2RESP, CMD3, CMD3RESP);
SIGNAL nextState, currentState : state;

SIGNAL card, CLR, args : STD_LOGIC;
SIGNAL redun7 : STD_LOGIC_VECTOR (6 DOWNTO 0);

SIGNAL start, trans, stop : STD_LOGIC;
SIGNAL cmdind : STD_LOGIC_VECTOR (5 DOWNTO 0);
SIGNAL RCA, STAT : STD_LOGIC_VECTOR (15 DOWNTO 0);
SIGNAL cardstat : STD_LOGIC_VECTOR (31 DOWNTO 0);
SIGNAL cycle7 : STD_LOGIC_VECTOR (6 DOWNTO 0);
SIGNAL CID : STD_LOGIC_VECTOR (119 DOWNTO 0);
SIGNAL CSD : STD_LOGIC_VECTOR (126 DOWNTO 0);

SIGNAL counter : INTEGER := 0;

BEGIN
    det : SDDET PORT MAP(DET => card);
    check7 : CRC7 PORT MAP(clk => clk, CLR => CLR, DATA => args, CRC7 => redun7);

    PROCESS(ALL)
    BEGIN
        IF NOT card THEN
            IF RISING_EDGE(clkSlow) THEN
                CASE currentState IS
                WHEN DUMMY => IF counter = 74 THEN
                        nextState <= CMD0;
                        counter <= 47;
                    ELSE
                        counter <= counter + 1;
                    END IF;
                WHEN CMD0 => CMD(47) <= '0';
                    CMD(46) <= '1';
                    CMD(45 DOWNTO 8) <= (OTHERS => '0'); 
                    IF counter = 47 THEN
                        CLR <= '1';
                        args <= CMD(counter);
                        counter <= counter - 1;
                        nextState <= CMD0;
                    ELSIF counter > -1 THEN
                        CLR <= '0';
                        args <= CMD(counter);
                        counter <= counter - 1;
                        nextState <= CMD0;
                    ELSE
                        CMD(7 DOWNTO 1) <= redun7(6 DOWNTO 0);
                        CMD(0) <= '1';
                        counter <= 47;
                        nextState <= CMD55;
                    END IF;
                WHEN CMD55 => CMD(47) <= '0';
                    CMD(46) <= '1';
                    CMD(45 DOWNTO 40) <= d"55";
                    CMD(39 DOWNTO 8) <= (OTHERS => '0'); 
                    IF counter = 47 THEN
                        CLR <= '1';
                        args <= CMD(counter);
                        counter <= counter - 1;
                        nextState <= CMD55;
                    ELSIF counter > -1 THEN
                        CLR <= '0';
                        args <= CMD(counter);
                        counter <= counter - 1;
                        nextState <= CMD55;
                    ELSE
                        CMD(7 DOWNTO 1) <= redun7(6 DOWNTO 0);
                        CMD(0) <= '1';
                        counter <= 47;
                        nextState <= CMD55RESP;
                    END IF;
                WHEN CMD55RESP => start <= CMD(47);
                    trans <= CMD(46);
                    cmdind <= CMD(45 DOWNTO 40);
                    cardstat <= CMD(39 DOWNTO 8);
                    cycle7 <= CMD(7 DOWNTO 1);
                    IF counter = 47 THEN
                        CLR <= '1';
                        args <= CMD(counter);
                        counter <= counter - 1;
                        nextState <= CMD55RESP;
                    ELSIF counter > -1 THEN
                        CLR <= '0';
                        args <= CMD(counter);
                        counter <= counter - 1;
                        nextState <= CMD55RESP;
                    ELSE
                        counter <= 47;
                        IF redun7 = cycle7 THEN
                            stop <= CMD(0);
                            nextState <= ACMD41;
                        ELSE
                            led <= '0';
                            LOOP
                            END LOOP;
                        END IF;
                    END IF;
                WHEN ACMD41 => CMD(47) <= '0';
                    CMD(46) <= '1';
                    CMD(45 DOWNTO 40) <= d"41";
                    CMD(39 DOWNTO 8) <= (OTHERS => '0');
                    IF counter = 47 THEN
                        CLR <= '1';
                        args <= CMD(counter);
                        counter <= counter - 1;
                        nextState <= ACMD41;
                    ELSIF counter > -1 THEN
                        CLR <= '0';
                        args <= CMD(counter);
                        counter <= counter - 1;
                        nextState <= ACMD41;
                    ELSE
                        CMD(7 DOWNTO 1) <= redun7(6 DOWNTO 0);
                        CMD(0) <= '1';
                        counter <= 47;
                        nextState <= ACMD41RESP;
                    END IF;
                WHEN ACMD41RESP => start <= CMD(47);
                    trans <= CMD(46);
                    cmdind <= CMD(45 DOWNTO 40);
                    cardstat <= CMD(39 DOWNTO 8);
                    cycle7 <= CMD(7 DOWNTO 1);
                    stop <= CMD(0);
                    IF CMD(31) = '1' THEN
                        nextState <= CMD55;
                    ELSE
                        nextState <= CMD2;
                    END IF;
                END CASE;
            END IF;
            IF RISING_EDGE(clkFast) THEN
                CASE currentState IS
                WHEN CMD2 => CMD(47) <= '0';
                    CMD(46) <= '1';
                    CMD(45 DOWNTO 40) <= TO_STDLOGICVECTOR(2, 6);
                    CMD(39 DOWNTO 8) <= (OTHERS => '0'); 
                    IF counter = 47 THEN
                        CLR <= '1';
                        args <= CMD(counter);
                        counter <= counter - 1;
                        nextState <= CMD2;
                    ELSIF counter > -1 THEN
                        CLR <= '0';
                        args <= CMD(counter);
                        counter <= counter - 1;
                        nextState <= CMD2;
                    ELSE
                        CMD(7 DOWNTO 1) <= redun7(6 DOWNTO 0);
                        CMD(0) <= '1';
                        counter <= 135;
                        nextState <= CMD2RESP;
                    END IF;
                WHEN CMD2RESP => start <= C2RESP(135);
                    trans <= C2RESP(134);
                    cmdind <= C2RESP(133 DOWNTO 128);
                    CSD <= C2RESP(127 DOWNTO 1);
                    CID <= C2RESP(127 DOWNTO 8);
                    cycle7 <= C2RESP(7 DOWNTO 1);
                    IF counter = 135 THEN
                        CLR <= '1';
                        args <= CID(counter);
                        counter <= counter - 1;
                        nextState <= CMD2RESP;
                    ELSIF counter > -1 THEN
                        CLR <= '0';
                        args <= CID(counter);
                        counter <= counter - 1;
                        nextState <= CMD2RESP;
                    ELSE
                        counter <= 47;
                        IF redun7 = cycle7 THEN
                            stop <= C2RESP(0);
                            nextState <= CMD3;
                        ELSE
                            led <= '0';
                            LOOP
                            END LOOP;
                        END IF;
                        stop <= C2RESP(0);
                    END IF;
                WHEN CMD3 => CMD(47) <= '0';
                    CMD(46) <= '1';
                    CMD(45 DOWNTO 40) <= TO_STDLOGICVECTOR(3, 6);
                    CMD(39 DOWNTO 8) <= (OTHERS => '0'); 
                    IF counter = 47 THEN
                        CLR <= '1';
                        args <= CMD(counter);
                        counter <= counter - 1;
                        nextState <= CMD3;
                    ELSIF counter > -1 THEN
                        CLR <= '0';
                        args <= CMD(counter);
                        counter <= counter - 1;
                        nextState <= CMD3;
                    ELSE
                        CMD(7 DOWNTO 1) <= redun7(6 DOWNTO 0);
                        CMD(0) <= '1';
                        counter <= 39;
                        nextState <= CMD3RESP;
                    END IF;
                WHEN CMD3RESP => start <= CMD(47);
                    trans <= CMD(46);
                    cmdind <= CMD(45 DOWNTO 40);
                    RCA <= CMD(39 DOWNTO 24);
                    STAT <= CMD(23 DOWNTO 8);
                    cycle7 <= CMD(7 DOWNTO 1);
                    IF counter = 47 THEN
                        CLR <= '1';
                        args <= CMD(counter);
                        counter <= counter - 1;
                        nextState <= CMD3RESP;
                    ELSIF counter > -1 THEN
                        CLR <= '0';
                        args <= CMD(counter);
                        counter <= counter - 1;
                        nextState <= CMD3RESP;
                    ELSE
                        counter <= 47;
                        IF redun7 = cycle7 THEN
                            stop <= CMD(0);
                            nextState <= CMD3;
                        ELSE
                            led <= '0';
                            LOOP
                            END LOOP;
                        END IF;
                    END IF;
                END CASE;
            END IF;
        END IF;
    END PROCESS;
END ARCHITECTURE;

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY SDRW IS
    PORT (clk, clkFast: IN STD_LOGIC;
          CMD : INOUT STD_LOGIC_VECTOR (47 DOWNTO 0);
          DATA : INOUT STD_LOGIC_VECTOR (4095 DOWNTO 0)
         );
END ENTITY;

ARCHITECTURE BEHAVIOR OF SDRW IS
COMPONENT SDDET IS
    PORT(DET : IN STD_LOGIC;
         LED : OUT STD_LOGIC
        );
END COMPONENT;

SIGNAL card : STD_LOGIC;

BEGIN
    det : SDDET PORT MAP(DET => card);

    PROCESS(ALL)
    BEGIN
        IF NOT card THEN
            IF RISING_EDGE(clk) THEN
                
            END IF;
        END IF;
    END PROCESS;
END ARCHITECTURE;
