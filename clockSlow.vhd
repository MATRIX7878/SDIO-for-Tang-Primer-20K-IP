LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;

ENTITY clockSlow IS
    PORT(iclk, clr : IN STD_LOGIC;
         oslow : OUT STD_LOGIC);
END clockSlow;

ARCHITECTURE behavior OF clockSlow IS
    SIGNAL Count : INTEGER RANGE 0 TO 399999;
    SIGNAL clkstate : STD_LOGIC;

BEGIN
    PROCESS (iclk, clr)
    BEGIN
        IF clr = '1' THEN
            Count <= 0;
            clkstate <= '0';
        ELSIF (RISING_EDGE(iclk)) THEN
            IF Count = 399999 THEN
                Count <= 0;
                clkstate <= NOT clkstate;
            ELSE
                Count <= Count + 1;
            END IF;
        END IF;
    END PROCESS;
    oslow <= clkstate;
END behavior;