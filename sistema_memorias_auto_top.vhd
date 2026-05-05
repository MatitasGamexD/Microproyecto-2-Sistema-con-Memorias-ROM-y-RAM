library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.mem_pkg.all;

entity sistema_memorias_auto_top is
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
end entity;


architecture rtl of sistema_memorias_auto_top is

    component rom_sync is
        generic(
            DATA_WIDTH : positive := 8;
            ADDR_WIDTH : positive := 4
        );
        port(
            clk      : in  STD_LOGIC;
            addr     : in  STD_LOGIC_VECTOR(ADDR_WIDTH-1 downto 0);
            data_out : out STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0)
        );
    end component;

    component ram_sincrona is
        generic(
            DATA_WIDTH : positive := 8;
            ADDR_WIDTH : positive := 4;
            RDW_MODE   : string   := "READ_FIRST"
        );
        port(
            clk      : in  STD_LOGIC;
            rd_en    : in  STD_LOGIC := '1';
            wr_en    : in  STD_LOGIC;
            addr     : in  STD_LOGIC_VECTOR(ADDR_WIDTH-1 downto 0);
            data_in  : in  STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
            data_out : out STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0)
        );
    end component;

    type state_t is (
        S_ROM_ADDR,
        S_ROM_WAIT,
        S_RAM_WRITE,
        S_NEXT_COPY,
        S_RAM_READ,
        S_LATCH_READ,
        S_WAIT_TICK
    );

    signal state_reg, state_next : state_t;

    signal copy_addr_reg, copy_addr_next : unsigned(ADDR_WIDTH_C-1 downto 0);
    signal read_addr_reg, read_addr_next : unsigned(ADDR_WIDTH_C-1 downto 0);

    signal rom_addr_s : addr_t;
    signal ram_addr_s : addr_t;

    signal rom_data_s : data_t;
    signal ram_data_s : data_t;

    signal ram_rd_s : STD_LOGIC;
    signal ram_wr_s : STD_LOGIC;

    signal display_data_reg, display_data_next : data_t;

    signal done_reg, done_next : STD_LOGIC;

    signal tick_count : integer range 0 to TICK_MAX-1 := 0;
    signal tick_s     : STD_LOGIC := '0';

begin

    U_ROM: rom_sync
        generic map(
            DATA_WIDTH => DATA_WIDTH_C,
            ADDR_WIDTH => ADDR_WIDTH_C
        )
        port map(
            clk      => clk,
            addr     => rom_addr_s,
            data_out => rom_data_s
        );

    U_RAM: ram_sincrona
        generic map(
            DATA_WIDTH => DATA_WIDTH_C,
            ADDR_WIDTH => ADDR_WIDTH_C,
            RDW_MODE   => "READ_FIRST"
        )
        port map(
            clk      => clk,
            rd_en    => ram_rd_s,
            wr_en    => ram_wr_s,
            addr     => ram_addr_s,
            data_in  => rom_data_s,
            data_out => ram_data_s
        );

    -- Generador de tiempo para que la lectura automática se vea lenta
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                tick_count <= 0;
                tick_s <= '0';
            else
                if tick_count = TICK_MAX-1 then
                    tick_count <= 0;
                    tick_s <= '1';
                else
                    tick_count <= tick_count + 1;
                    tick_s <= '0';
                end if;
            end if;
        end if;
    end process;

    -- Registro principal
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                state_reg        <= S_ROM_ADDR;
                copy_addr_reg    <= (others => '0');
                read_addr_reg    <= (others => '0');
                display_data_reg <= (others => '0');
                done_reg         <= '0';
            else
                state_reg        <= state_next;
                copy_addr_reg    <= copy_addr_next;
                read_addr_reg    <= read_addr_next;
                display_data_reg <= display_data_next;
                done_reg         <= done_next;
            end if;
        end if;
    end process;

    -- Lógica de control automática
    process(
        state_reg,
        copy_addr_reg,
        read_addr_reg,
        display_data_reg,
        done_reg,
        tick_s,
        ram_data_s
    )
    begin

        state_next        <= state_reg;
        copy_addr_next    <= copy_addr_reg;
        read_addr_next    <= read_addr_reg;
        display_data_next <= display_data_reg;
        done_next         <= done_reg;

        rom_addr_s <= STD_LOGIC_VECTOR(copy_addr_reg);
        ram_addr_s <= STD_LOGIC_VECTOR(copy_addr_reg);

        ram_rd_s <= '0';
        ram_wr_s <= '0';

        case state_reg is

            when S_ROM_ADDR =>

                -- Se coloca la dirección de la ROM
                rom_addr_s <= STD_LOGIC_VECTOR(copy_addr_reg);
                state_next <= S_ROM_WAIT;

            when S_ROM_WAIT =>

                -- Se espera un ciclo porque la ROM es síncrona
                rom_addr_s <= STD_LOGIC_VECTOR(copy_addr_reg);
                state_next <= S_RAM_WRITE;

            when S_RAM_WRITE =>

                -- Se escribe en RAM el dato que sale de la ROM
                ram_addr_s <= STD_LOGIC_VECTOR(copy_addr_reg);
                ram_wr_s   <= '1';
                state_next <= S_NEXT_COPY;

            when S_NEXT_COPY =>

                -- Se pasa a la siguiente dirección
                if copy_addr_reg = to_unsigned(MEM_DEPTH_C-1, ADDR_WIDTH_C) then
                    done_next      <= '1';
                    read_addr_next <= (others => '0');
                    state_next     <= S_RAM_READ;
                else
                    copy_addr_next <= copy_addr_reg + 1;
                    state_next     <= S_ROM_ADDR;
                end if;

            when S_RAM_READ =>

                -- Se lee automáticamente la RAM
                ram_addr_s <= STD_LOGIC_VECTOR(read_addr_reg);
                ram_rd_s   <= '1';
                state_next <= S_LATCH_READ;

            when S_LATCH_READ =>

                -- Se guarda el dato leído para mostrarlo estable
                ram_addr_s         <= STD_LOGIC_VECTOR(read_addr_reg);
                display_data_next  <= ram_data_s;
                state_next         <= S_WAIT_TICK;

            when S_WAIT_TICK =>

                -- Se mantiene el dato visible en los displays
                ram_addr_s <= STD_LOGIC_VECTOR(read_addr_reg);

                if tick_s = '1' then
                    if read_addr_reg = to_unsigned(MEM_DEPTH_C-1, ADDR_WIDTH_C) then
                        read_addr_next <= (others => '0');
                    else
                        read_addr_next <= read_addr_reg + 1;
                    end if;

                    state_next <= S_RAM_READ;
                end if;

        end case;

    end process;

    current_addr <= STD_LOGIC_VECTOR(read_addr_reg);
    data_out     <= display_data_reg;
    copy_done    <= done_reg;

    with state_reg select
        state_led <= "000" when S_ROM_ADDR,
                     "001" when S_ROM_WAIT,
                     "010" when S_RAM_WRITE,
                     "011" when S_NEXT_COPY,
                     "100" when S_RAM_READ,
                     "101" when S_LATCH_READ,
                     "110" when S_WAIT_TICK,
                     "111" when others;

end architecture;
