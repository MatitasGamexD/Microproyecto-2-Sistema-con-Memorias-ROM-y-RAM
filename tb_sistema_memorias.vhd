library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.mem_pkg.all;

entity tb_sistema_memorias is
end tb_sistema_memorias;

architecture sim of tb_sistema_memorias is

    component sistema_memorias_top is
        port(
            clk       : in  STD_LOGIC;
            rst       : in  STD_LOGIC;
            start     : in  STD_LOGIC;

            addr      : in  addr_t;
            data_in   : in  data_t;
            we        : in  STD_LOGIC;
            re        : in  STD_LOGIC;

            data_out  : out data_t;
            copy_done : out STD_LOGIC;
            state_led : out STD_LOGIC_VECTOR(2 downto 0)
        );
    end component;

    constant CLK_PERIOD : time := 20 ns;

    signal clk       : STD_LOGIC := '0';
    signal rst       : STD_LOGIC := '0';
    signal start     : STD_LOGIC := '0';

    signal addr      : addr_t := (others => '0');
    signal data_in   : data_t := (others => '0');
    signal we        : STD_LOGIC := '0';
    signal re        : STD_LOGIC := '0';

    signal data_out  : data_t;
    signal copy_done : STD_LOGIC;
    signal state_led : STD_LOGIC_VECTOR(2 downto 0);

    type expected_t is array (0 to MEM_DEPTH-1) of data_t;

    constant EXPECTED_ROM : expected_t := (
        0  => x"12",
        1  => x"34",
        2  => x"56",
        3  => x"78",
        4  => x"9A",
        5  => x"BC",
        6  => x"DE",
        7  => x"F0",
        8  => x"0F",
        9  => x"1E",
        10 => x"2D",
        11 => x"3C",
        12 => x"4B",
        13 => x"5A",
        14 => x"69",
        15 => x"FF"
    );

begin

    clk <= not clk after CLK_PERIOD/2;

    UUT: sistema_memorias_top
        port map(
            clk       => clk,
            rst       => rst,
            start     => start,

            addr      => addr,
            data_in   => data_in,
            we        => we,
            re        => re,

            data_out  => data_out,
            copy_done => copy_done,
            state_led => state_led
        );

    process
    begin

        -- RESET INICIAL
        rst <= '1';
        wait for 60 ns;
        rst <= '0';
        wait until rising_edge(clk);

        -- VALIDACIÓN 1: Reset del sistema
        addr <= x"0";
        re   <= '1';
        wait until rising_edge(clk);
        wait for 1 ns;

        assert data_out = x"00"
        report "ERROR: La RAM no quedó limpia después del reset"
        severity error;

        re <= '0';

        -- VALIDACIÓN 2: Lectura ROM + Escritura en RAM
        -- Se activa start para copiar toda la ROM hacia la RAM
        start <= '1';
        wait until rising_edge(clk);
        start <= '0';

        wait until copy_done = '1';
        wait until rising_edge(clk);

        -- VALIDACIÓN 3: Lectura desde RAM
        for i in 0 to MEM_DEPTH-1 loop

            addr <= STD_LOGIC_VECTOR(to_unsigned(i, ADDR_WIDTH));
            re   <= '1';
            we   <= '0';

            wait until rising_edge(clk);
            wait for 1 ns;

            assert data_out = EXPECTED_ROM(i)
            report "ERROR: Dato incorrecto leído desde RAM"
            severity error;

        end loop;

        re <= '0';

        -- VALIDACIÓN 4: Escritura manual en RAM
        addr    <= x"5";
        data_in <= x"AA";
        we      <= '1';
        re      <= '0';

        wait until rising_edge(clk);
        wait for 1 ns;

        we <= '0';
        re <= '1';

        wait until rising_edge(clk);
        wait for 1 ns;

        assert data_out = x"AA"
        report "ERROR: Falló la escritura manual en RAM"
        severity error;

        re <= '0';

        -- VALIDACIÓN 5: Reset nuevamente
        rst <= '1';
        wait until rising_edge(clk);
        wait for 1 ns;
        rst <= '0';

        wait until rising_edge(clk);

        addr <= x"5";
        re   <= '1';

        wait until rising_edge(clk);
        wait for 1 ns;

        assert data_out = x"00"
        report "ERROR: La RAM no se limpió después del segundo reset"
        severity error;

        assert false
        report "SIMULACION TERMINADA SIN ERRORES"
        severity failure;

    end process;

end sim;
