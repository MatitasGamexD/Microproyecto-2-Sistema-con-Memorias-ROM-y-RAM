library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.mem_pkg.all;

entity ram_sync is
    port(
        clk      : in  STD_LOGIC;
        rst      : in  STD_LOGIC;
        we       : in  STD_LOGIC;
        re       : in  STD_LOGIC;
        addr     : in  addr_t;
        data_in  : in  data_t;
        data_out : out data_t
    );
end ram_sync;

architecture Behavioral of ram_sync is

    signal RAM : mem_t := (others => (others => '0'));

begin

    process(clk)
    begin
        if rising_edge(clk) then

            if rst = '1' then
                RAM      <= (others => (others => '0'));
                data_out <= (others => '0');

            else

                if we = '1' then
                    RAM(to_integer(unsigned(addr))) <= data_in;
                end if;

                if re = '1' then
                    data_out <= RAM(to_integer(unsigned(addr)));
                end if;

            end if;

        end if;
    end process;

end Behavioral;
