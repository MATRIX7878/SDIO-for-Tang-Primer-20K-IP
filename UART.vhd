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

SIGNAL oclk : STD_LOGIC;
SIGNAL triggerRX : STD_LOGIC;

COMPONENT SDDET IS
    PORT(DET : IN STD_LOGIC;
         LED : OUT STD_LOGIC
        );
END COMPONENT;

COMPONENT clockdiv IS
    PORT(iclk, clr : IN STD_LOGIC;
         oclk : OUT STD_LOGIC);
END COMPONENT;

COMPONENT UARTRX IS
    PORT(baud, dataRX : IN STD_LOGIC;
         triggerRX : OUT STD_LOGIC
         );
END COMPONENT;

COMPONENT UARTTX IS
    PORT(baud, triggerTX : IN STD_LOGIC;
         dataTX : OUT STD_LOGIC
         );
END COMPONENT;

BEGIN
    CARD : SDDET PORT MAP (DET => det, LED => led);
    div : clockdiv PORT MAP (iclk => clk, clr => RST, oclk => oclk);
    uart_rx : UARTRX PORT MAP (baud => oclk, dataRX => RX, triggerRX => triggerRX);
    uart_tx : UARTTX PORT MAP (baud => oclk, triggerTX => triggerRX, dataTX => TX);
END ARCHITECTURE;
