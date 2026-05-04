library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.mem_pkg.all;

entity DE0_TOP is
    port(
        CLOCK_50 : in  STD_LOGIC;
        BUTTON   : in  STD_LOGIC_VECTOR(2 downto 0);
        SW       : in  STD_LOGIC_VECTOR(9 downto 0);

        LEDG     : out STD_LOGIC_VECTOR(9 downto 0);

        HEX0     : out STD_LOGIC_VECTOR(6 downto 0);
        HEX1     : out STD_LOGIC_VECTOR(6 downto 0);
        HEX2     : out STD_LOGIC_VECTOR(6 downto 0);
        HEX3     : out STD_LOGIC_VECTOR(6 downto 0)
    );
end DE0_TOP;

architecture Structural of DE0_TOP is

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

    signal rst_s       : STD_LOGIC;
    signal start_s     : STD_LOGIC;

    signal addr_s      : addr_t;
    signal data_in_s   : data_t;
    signal data_out_s  : data_t;

    signal we_s        : STD_LOGIC;
    signal re_s        : STD_LOGIC;

    signal done_s      : STD_LOGIC;
    signal state_s     : STD_LOGIC_VECTOR(2 downto 0);

begin

    -- En la DE0 los botones son activos en bajo.
    -- Por eso se invierten.
    rst_s   <= not BUTTON(0);
    start_s <= not BUTTON(1);

    -- SW[3:0] selecciona dirección de memoria
    addr_s <= SW(3 downto 0);

    -- SW[7:4] permite escribir manualmente datos de 4 bits en la RAM.
    -- Se completa a 8 bits con ceros en la parte alta.
    data_in_s <= "0000" & SW(7 downto 4);

    -- SW[8] = escritura manual en RAM
    -- SW[9] = lectura manual de RAM
    we_s <= SW(8);
    re_s <= SW(9);

    U_SISTEMA: sistema_memorias_top
        port map(
            clk       => CLOCK_50,
            rst       => rst_s,
            start     => start_s,

            addr      => addr_s,
            data_in   => data_in_s,
            we        => we_s,
            re        => re_s,

            data_out  => data_out_s,
            copy_done => done_s,
            state_led => state_s
        );

    -- LEDs
    LEDG(7 downto 0) <= data_out_s;
    LEDG(8)          <= done_s;
    LEDG(9)          <= '0' when state_s = "000" else '1';

    -- HEX0 y HEX1 muestran data_out en hexadecimal
    HEX0 <= hex_to_7seg(data_out_s(3 downto 0));
    HEX1 <= hex_to_7seg(data_out_s(7 downto 4));

    -- HEX2 muestra la dirección seleccionada
    HEX2 <= hex_to_7seg(addr_s);

    -- HEX3 muestra el estado de la FSM
    HEX3 <= hex_to_7seg("0" & state_s);

end Structural;
