LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY CRC7 IS
    PORT (clk : IN STD_LOGIC;
          CMD : IN STD_LOGIC_VECTOR (39 DOWNTO 0);
          CRC7 : OUT STD_LOGIC_VECTOR (6 DOWNTO 0) := (OTHERS => '0')
         );
END ENTITY;

ARCHITECTURE behavior OF CRC7 IS

SIGNAL remainder : STD_LOGIC := '0';

SIGNAL counter : INTEGER := 39;

BEGIN
    PROCESS(ALL)
    BEGIN
        IF RISING_EDGE(clk) THEN
            IF counter > -1 THEN
                remainder <= CMD(counter) XOR CRC7(6);

                CRC7(6) <= CRC7(5);
                CRC7(5) <= CRC7(4);
                CRC7(4) <= CRC7(3);
                CRC7(3) <= CRC7(2) XOR remainder;
                CRC7(2) <= CRC7(1);
                CRC7(1) <= CRC7(0);
                CRC7(0) <= remainder;

                counter <= counter - 1;
            END IF;
        END IF;
    END PROCESS;
END ARCHITECTURE;