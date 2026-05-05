library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.mem_pkg.all;

entity tb_sistema_memorias_auto is
end entity;


architecture sim of tb_sistema_memorias_auto is

    component sistema_memorias_auto_top is
        generic(
            TICK_MAX : positive := 25000000
        );
        port(
            clk          : in  STD_LOGIC;
            rst          : in  STD_LOGIC;

            current_addr : out addr_t;
            data_out     : out data_t;
            copy_done    : out STD_LOGIC;
            state_led    : out STD_LOGIC_VECTOR(2 downto 0)
        );
    end component;

    constant CLK_PERIOD : time := 20 ns;

    signal clk          : STD_LOGIC := '0';
    signal rst          : STD_LOGIC := '0';
    signal current_addr : addr_t;
    signal data_out     : data_t;
    signal copy_done    : STD_LOGIC;
    signal state_led    : STD_LOGIC_VECTOR(2 downto 0);

    type expected_t is array (0 to MEM_DEPTH_C-1) of data_t;

    constant EXPECTED_ROM : expected_t := (
        0  => x"AA",
        1  => x"55",
        2  => x"F0",
        3  => x"0F",
        4  => x"FF",
        5  => x"00",
        6  => x"00",
        7  => x"00",
        8  => x"00",
        9  => x"00",
        10 => x"00",
        11 => x"00",
        12 => x"00",
        13 => x"00",
        14 => x"00",
        15 => x"00"
    );

begin

    clk <= not clk after CLK_PERIOD/2;

    UUT: sistema_memorias_auto_top
        generic map(
            TICK_MAX => 4
        )
        port map(
            clk          => clk,
            rst          => rst,
            current_addr => current_addr,
            data_out     => data_out,
            copy_done    => copy_done,
            state_led    => state_led
        );

    process
    begin

        -- Reset inicial
        rst <= '1';
        wait for 60 ns;
        rst <= '0';

        -- Esperar a que termine la copia automática ROM -> RAM
        wait until copy_done = '1';

        -- Verificar lectura automática de la RAM
        for i in 0 to MEM_DEPTH_C-1 loop

            wait until current_addr = STD_LOGIC_VECTOR(to_unsigned(i, ADDR_WIDTH_C))
                       and state_led = "110";

            wait for 1 ns;

            assert data_out = EXPECTED_ROM(i)
            report "ERROR: El dato leido automaticamente desde RAM no coincide con la ROM"
            severity error;

        end loop;

        report "SIMULACION AUTOMATICA TERMINADA SIN ERRORES" severity note;

        wait;

    end process;

end architecture;
