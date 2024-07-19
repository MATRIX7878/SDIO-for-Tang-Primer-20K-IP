LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;

ENTITY clockFast IS
    PORT(iclk, clr : IN STD_LOGIC;
         ofast : OUT STD_LOGIC);
END clockFast;

ARCHITECTURE behavior OF clockFast IS
    SIGNAL Count : INTEGER RANGE 0 TO 24999999;
    SIGNAL clkstate : STD_LOGIC;

BEGIN
    PROCESS (iclk, clr)
    BEGIN
        IF clr = '1' THEN
            Count <= 0;
            clkstate <= '0';
        ELSIF (RISING_EDGE(iclk)) THEN
            IF Count = 24999999 THEN
                Count <= 0;
                clkstate <= NOT clkstate;
            ELSE
                Count <= Count + 1;
            END IF;
        END IF;
    END PROCESS;
    ofast <= clkstate;
END behavior;