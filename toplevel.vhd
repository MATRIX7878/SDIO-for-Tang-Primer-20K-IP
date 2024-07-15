LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY toplevel IS
    PORT(clk, RST, det : IN STD_LOGIC;
         RX : IN STD_LOGIC_VECTOR (8 DOWNTO 0);
         led : OUT STD_LOGIC;
         TX : OUT STD_LOGIC_VECTOR (9 DOWNTO 0);
         CMD : INOUT STD_LOGIC;
         DAT : INOUT STD_LOGIC_VECTOR (3 DOWNTO 0)
    );
END ENTITY;

ARCHITECTURE behavior OF toplevel IS

SIGNAL oclk : STD_LOGIC;
SIGNAL busy : STD_LOGIC;

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
    PORT(baud : IN STD_LOGIC;
         busy : OUT STD_LOGIC;
         data : IN STD_LOGIC_VECTOR (8 DOWNTO 0)
         );
END COMPONENT;

COMPONENT UARTTX IS
    PORT(baud : IN STD_LOGIC;
         busy : OUT STD_LOGIC;
         data : OUT STD_LOGIC_VECTOR (9 DOWNTO 0)
         );
END COMPONENT;

BEGIN
    CARD : SDDET PORT MAP (det => DET, led => LED);
    div : clockdiv PORT MAP (clk => iclk, RST => clr, oclk => oclk);
    uart_rx : UARTRX PORT MAP (oclk => baud, busy => busy, RX => data);
    uart_tx : UARTTX PORT MAP (oclk => baud, busy => busy, TX => data);
END ARCHITECTURE;
