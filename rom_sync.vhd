library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.mem_pkg.all;

entity rom_sync is
    port(
        clk      : in  STD_LOGIC;
        re       : in  STD_LOGIC;
        addr     : in  addr_t;
        data_out : out data_t
    );
end rom_sync;

architecture Behavioral of rom_sync is

    constant ROM_CONTENT : mem_t := (
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

    process(clk)
    begin
        if rising_edge(clk) then
            if re = '1' then
                data_out <= ROM_CONTENT(to_integer(unsigned(addr)));
            end if;
        end if;
    end process;

end Behavioral;
