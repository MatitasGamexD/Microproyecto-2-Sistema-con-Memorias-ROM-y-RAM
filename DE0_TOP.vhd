library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library work;
use work.mem_pkg.all;

entity DE0_TOP is
    port(
        CLOCK_50 : in  STD_LOGIC;
        KEY      : in  STD_LOGIC_VECTOR(2 downto 0);
        SW       : in  STD_LOGIC_VECTOR(9 downto 0);

        LEDR     : out STD_LOGIC_VECTOR(9 downto 0);

        HEX0     : out STD_LOGIC_VECTOR(6 downto 0);
        HEX1     : out STD_LOGIC_VECTOR(6 downto 0);
        HEX2     : out STD_LOGIC_VECTOR(6 downto 0);
        HEX3     : out STD_LOGIC_VECTOR(6 downto 0)
    );
end entity;


architecture Structural of DE0_TOP is

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

    signal rst_s   : STD_LOGIC;
    signal addr_s  : addr_t;
    signal data_s  : data_t;
    signal done_s  : STD_LOGIC;
    signal state_s : STD_LOGIC_VECTOR(2 downto 0);

begin

    -- KEY(0) es activo en bajo, por eso se invierte
    rst_s <= not KEY(0);

    U_AUTO: sistema_memorias_auto_top
        generic map(
            TICK_MAX => 25000000
        )
        port map(
            clk          => CLOCK_50,
            rst          => rst_s,
            current_addr => addr_s,
            data_out     => data_s,
            copy_done    => done_s,
            state_led    => state_s
        );

    -- Los switches ya no controlan nada.
    -- Todo el proceso es automático.

    LEDR(7 downto 0) <= data_s;
    LEDR(8)          <= done_s;
    LEDR(9)          <= '1' when done_s = '0' else '0';

    -- HEX1 y HEX0 muestran el dato leído de RAM
    HEX0 <= hex_to_7seg(data_s(3 downto 0));
    HEX1 <= hex_to_7seg(data_s(7 downto 4));

    -- HEX2 muestra la dirección actual
    HEX2 <= hex_to_7seg(addr_s);

    -- HEX3 muestra el estado de la FSM
    HEX3 <= hex_to_7seg("0" & state_s);

end architecture;
