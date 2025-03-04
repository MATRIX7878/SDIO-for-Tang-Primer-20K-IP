LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE WORK.instructions.ALL;
USE WORK.SDIOStates.ALL;

ENTITY toplevel IS
    PORT(clk, RST, det : IN STD_LOGIC;
         led, TX, SDclk, mirrorSDclk, mirrorCMD : OUT STD_LOGIC;
         mirrorDAT : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
         CMD : INOUT STD_LOGIC;
         DAT : INOUT STD_LOGIC_VECTOR (3 DOWNTO 0)
        );
END ENTITY;

ARCHITECTURE behavior OF toplevel IS
TYPE sequence IS (RESET, INIT);
SIGNAL currentSequence : sequence := RESET;

SIGNAL oslow : STD_LOGIC;

SIGNAL clockChoice : STD_LOGIC := oslow;

SIGNAL tx_ready : STD_LOGIC;
SIGNAL tx_valid : STD_LOGIC := '0';
SIGNAL tx_data, tx_str : STD_LOGIC_VECTOR (7 DOWNTO 0) := (OTHERS => '0');

SIGNAL SDCMD : SDCMDS := CMD0;
SIGNAL currentState : state := DONE;

SIGNAL counter : INTEGER RANGE 0 TO 148 := 0;

COMPONENT SDDET IS
    PORT(DET : IN STD_LOGIC;
         LED : OUT STD_LOGIC := '1');
END COMPONENT;

COMPONENT UART_TX IS
    GENERIC (DIVISOR : NATURAL := 234);
    PORT (clk : IN  STD_LOGIC;
          reset : IN  STD_LOGIC;
          tx_valid : IN STD_LOGIC;
          tx_data : IN  STD_LOGIC_VECTOR (7 DOWNTO 0);
          tx_ready : OUT STD_LOGIC;
          tx_OUT : OUT STD_LOGIC := '1');
END COMPONENT;

COMPONENT clockSlow IS
    PORT(iclk, clr : IN STD_LOGIC;
         oslow : OUT STD_LOGIC);
END COMPONENT;

COMPONENT SDprotocol IS
    PORT (clk, clkSlow : IN STD_LOGIC;
          SDCMD : IN SDCMDS;
          SDclock : OUT STD_LOGIC
         );
END COMPONENT;

COMPONENT SDIO IS
    PORT(clk : IN STD_LOGIC;
         CMD : IN STD_LOGIC_VECTOR (47 DOWNTO 0) := (OTHERS => '0');
         dataIn : IN STD_LOGIC_VECTOR (4095 DOWNTO 0);
         flashCLK : OUT STD_LOGIC := '0';
         RSP : OUT STD_LOGIC_VECTOR (135 DOWNTO 0) := (OTHERS => '0');
         dataOut : OUT STD_LOGIC_VECTOR (5019 DOWNTO 0) := (OTHERS => '0');
         currentState : OUT state;
         D0, D1, D2, D3, CMDRSP : INOUT STD_LOGIC
        );
END COMPONENT;

BEGIN
    PROCESS(ALL)
    BEGIN
        IF RISING_EDGE(clockChoice) THEN
            mirrorSDclk <= SDclk;
            mirrorCMD <= CMD;
            mirrorDAT <= DAT;

            IF led THEN
                CMD <= '1';
                DAT <= (OTHERS => '1');
            END IF;

            IF NOT led THEN
                CASE currentSequence IS
                WHEN RESET => IF counter = 147 THEN
                    SDCMD <= CMD0;
                    SDCLK <= '1';
                    currentSequence <= INIT;
                ELSE
                    SDCLK <= '0';
                    counter <= counter + 1;
                END IF;
                WHEN INIT => SDCMD <= CMD0;
                END CASE;
            END IF;
        END IF;
    END PROCESS;

    CARD : SDDET PORT MAP (DET => det, LED => led);
    UARTTX : UART_TX PORT MAP (clk => clk, reset => RST, tx_valid => tx_valid, tx_data => tx_data, tx_ready => tx_ready, tx_OUT => TX);
    TURTLE : clockSlow PORT MAP(iclk => clk, clr => RST, oslow => oslow);
    SDCTRL : SDprotocol PORT MAP(clk => clk, clkSlow => oslow, SDCMD => SDCMD);
--    COMM : SDIO PORT MAP(clk => clockChoice, 
END ARCHITECTURE;
