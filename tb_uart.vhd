library ieee;
   use ieee.std_logic_1164.all;
   use ieee.numeric_std.all;

entity tb_uart is
end entity tb_uart;

architecture simulation of tb_uart is

   signal clk     : std_logic       := '1';
   signal rst     : std_logic       := '1';
   signal running : std_logic       := '1';

   signal rx_data_ready : std_logic;
   signal rx_data_valid : std_logic;
   signal rx_data       : std_logic_vector(7 downto 0);
   signal rx_pin        : std_logic := '1';

   signal tx_data_ready : std_logic;
   signal tx_data_valid : std_logic;
   signal tx_data       : std_logic_vector(7 downto 0);
   signal tx_pin        : std_logic := '1';

   component uartrx is
      port (
         clk           : in    std_logic;
         rst           : in    std_logic;
         rx_data_ready : in    std_logic;
         rx_data_valid : out   std_logic;
         rx_data       : out   std_logic_vector(7 downto 0);
         rx_pin        : in    std_logic
      );
   end component uartrx;

   component uarttx is
      port (
         clk           : in    std_logic;
         rst           : in    std_logic;
         tx_data_ready : out   std_logic;
         tx_data_valid : in    std_logic;
         tx_data       : in    std_logic_vector(7 downto 0);
         tx_pin        : out   std_logic
      );
   end component uarttx;

begin

   clk    <= running and not clk after 5 ns;
   rst    <= '0', '1' after 100 ns;

   rx_pin <= tx_pin;

   uartrx_inst : component uartrx
      port map (
         clk           => clk,
         rst           => rst,
         rx_data_ready => rx_data_ready,
         rx_data_valid => rx_data_valid,
         rx_data       => rx_data,
         rx_pin        => rx_pin
      );

   uarttx_inst : component uarttx
      port map (
         clk           => clk,
         rst           => rst,
         tx_data_ready => tx_data_ready,
         tx_data_valid => tx_data_valid,
         tx_data       => tx_data,
         tx_pin        => tx_pin
      );

   test_proc : process
      procedure send(arg : std_logic_vector) is
      begin
         tx_data       <= arg;
         tx_data_valid <= '1';
         wait until rising_edge(clk);

         while tx_data_ready = '0' loop
            wait until rising_edge(clk);
         end loop;

         tx_data_valid <= '0';
         wait until rising_edge(clk);
      end procedure send;
   begin
      rx_data_ready <= '1';
      tx_data_valid <= '0';
      wait until rst = '1';
      wait until rising_edge(clk);
      wait until rising_edge(clk);

      send(X"53");

      wait until rx_data_valid = '1';
      assert rx_data = X"53";

      wait for 10 us;
      wait until rising_edge(clk);

      send(X"54");

      wait until rx_data_valid = '1';
      assert rx_data = X"54";

      wait until rising_edge(clk);
      report "Test finished";
      running       <= '0';
      wait;
   end process test_proc;

end architecture simulation;

