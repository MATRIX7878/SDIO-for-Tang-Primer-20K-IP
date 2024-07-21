LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY CRC7 IS
    PORT (clk, CLR : IN STD_LOGIC;
          DATA : IN STD_LOGIC;
          CRC7 : OUT STD_LOGIC_VECTOR (6 DOWNTO 0)
         );
END ENTITY;

ARCHITECTURE behavior OF CRC7 IS

SIGNAL remainder : STD_LOGIC := DATA XOR CRC7(6);

BEGIN
    PROCESS(ALL)
    BEGIN
        IF RISING_EDGE(clk) THEN
            IF CLR THEN
                CRC7 <= (OTHERS => '0');
            ELSE
                CRC7(6) <= CRC7(5);
                CRC7(5) <= CRC7(4);
                CRC7(4) <= CRC7(3);
                CRC7(3) <= CRC7(2) XOR remainder;
                CRC7(2) <= CRC7(1);
                CRC7(1) <= CRC7(0);
                CRC7(0) <= remainder;
            END IF;
        END IF;
    END PROCESS;
END ARCHITECTURE;
