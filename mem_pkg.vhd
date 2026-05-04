library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

package mem_pkg is

    constant ADDR_WIDTH : integer := 4;
    constant DATA_WIDTH : integer := 8;
    constant MEM_DEPTH  : integer := 16;

    subtype addr_t is STD_LOGIC_VECTOR(ADDR_WIDTH-1 downto 0);
    subtype data_t is STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
    subtype seg7_t is STD_LOGIC_VECTOR(6 downto 0);

    type mem_t is array (0 to MEM_DEPTH-1) of data_t;

    function hex_to_7seg(hex : STD_LOGIC_VECTOR(3 downto 0)) return seg7_t;

end package;


package body mem_pkg is

    function hex_to_7seg(hex : STD_LOGIC_VECTOR(3 downto 0)) return seg7_t is
        variable seg : seg7_t;
    begin
        -- Display de 7 segmentos activo en bajo
        -- Formato: seg(6 downto 0) = g f e d c b a

        case hex is
            when "0000" => seg := "1000000"; -- 0
            when "0001" => seg := "1111001"; -- 1
            when "0010" => seg := "0100100"; -- 2
            when "0011" => seg := "0110000"; -- 3
            when "0100" => seg := "0011001"; -- 4
            when "0101" => seg := "0010010"; -- 5
            when "0110" => seg := "0000010"; -- 6
            when "0111" => seg := "1111000"; -- 7
            when "1000" => seg := "0000000"; -- 8
            when "1001" => seg := "0010000"; -- 9
            when "1010" => seg := "0001000"; -- A
            when "1011" => seg := "0000011"; -- b
            when "1100" => seg := "1000110"; -- C
            when "1101" => seg := "0100001"; -- d
            when "1110" => seg := "0000110"; -- E
            when "1111" => seg := "0001110"; -- F
            when others => seg := "1111111"; -- apagado
        end case;

        return seg;
    end function;

end package body;
