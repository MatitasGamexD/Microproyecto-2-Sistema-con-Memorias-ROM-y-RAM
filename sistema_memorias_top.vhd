library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.mem_pkg.all;

entity sistema_memorias_top is
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
end sistema_memorias_top;

architecture Behavioral of sistema_memorias_top is

    component rom_sync is
        port(
            clk      : in  STD_LOGIC;
            re       : in  STD_LOGIC;
            addr     : in  addr_t;
            data_out : out data_t
        );
    end component;

    component ram_sync is
        port(
            clk      : in  STD_LOGIC;
            rst      : in  STD_LOGIC;
            we       : in  STD_LOGIC;
            re       : in  STD_LOGIC;
            addr     : in  addr_t;
            data_in  : in  data_t;
            data_out : out data_t
        );
    end component;

    type state_t is (
        S_IDLE,
        S_ROM_READ,
        S_RAM_WRITE,
        S_NEXT_ADDR
    );

    signal state_reg, state_next : state_t;

    signal idx_reg, idx_next : unsigned(ADDR_WIDTH-1 downto 0);

    signal rom_data : data_t;
    signal ram_data : data_t;

    signal rom_re_s     : STD_LOGIC;
    signal ram_we_s     : STD_LOGIC;
    signal ram_re_s     : STD_LOGIC;
    signal mem_addr_s   : addr_t;
    signal ram_data_in_s: data_t;

    signal done_reg, done_next : STD_LOGIC;

    signal start_d     : STD_LOGIC;
    signal start_pulse : STD_LOGIC;

begin

    -- Detector de flanco para start
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                start_d <= '0';
            else
                start_d <= start;
            end if;
        end if;
    end process;

    start_pulse <= start and not start_d;

    -- Instancia de ROM
    U_ROM: rom_sync
        port map(
            clk      => clk,
            re       => rom_re_s,
            addr     => mem_addr_s,
            data_out => rom_data
        );

    -- Instancia de RAM
    U_RAM: ram_sync
        port map(
            clk      => clk,
            rst      => rst,
            we       => ram_we_s,
            re       => ram_re_s,
            addr     => mem_addr_s,
            data_in  => ram_data_in_s,
            data_out => ram_data
        );

    -- Registro de estados
    process(clk)
    begin
        if rising_edge(clk) then

            if rst = '1' then
                state_reg <= S_IDLE;
                idx_reg   <= (others => '0');
                done_reg  <= '0';

            else
                state_reg <= state_next;
                idx_reg   <= idx_next;
                done_reg  <= done_next;

            end if;

        end if;
    end process;

    -- Lógica combinacional de control
    process(
        state_reg,
        start_pulse,
        addr,
        data_in,
        we,
        re,
        idx_reg,
        rom_data,
        done_reg
    )
    begin

        state_next <= state_reg;
        idx_next   <= idx_reg;
        done_next  <= done_reg;

        rom_re_s      <= '0';
        ram_we_s      <= '0';
        ram_re_s      <= '0';
        mem_addr_s    <= addr;
        ram_data_in_s <= data_in;

        case state_reg is

            when S_IDLE =>

                -- Modo manual:
                -- addr, data_in, we y re vienen de los switches
                mem_addr_s    <= addr;
                ram_data_in_s <= data_in;
                ram_we_s      <= we;
                ram_re_s      <= re;

                if start_pulse = '1' then
                    idx_next  <= (others => '0');
                    done_next <= '0';
                    state_next <= S_ROM_READ;
                end if;

            when S_ROM_READ =>

                -- Leer una posición de la ROM
                mem_addr_s <= STD_LOGIC_VECTOR(idx_reg);
                rom_re_s   <= '1';

                state_next <= S_RAM_WRITE;

            when S_RAM_WRITE =>

                -- Escribir en RAM el dato leído desde ROM
                mem_addr_s    <= STD_LOGIC_VECTOR(idx_reg);
                ram_data_in_s <= rom_data;
                ram_we_s      <= '1';

                state_next <= S_NEXT_ADDR;

            when S_NEXT_ADDR =>

                if idx_reg = to_unsigned(MEM_DEPTH-1, ADDR_WIDTH) then
                    idx_next   <= (others => '0');
                    done_next  <= '1';
                    state_next <= S_IDLE;
                else
                    idx_next   <= idx_reg + 1;
                    state_next <= S_ROM_READ;
                end if;

        end case;

    end process;

    -- Salidas
    data_out <= ram_data when state_reg = S_IDLE else rom_data;

    copy_done <= done_reg;

    with state_reg select
        state_led <= "000" when S_IDLE,
                     "001" when S_ROM_READ,
                     "010" when S_RAM_WRITE,
                     "011" when S_NEXT_ADDR,
                     "111" when others;

end Behavioral;
