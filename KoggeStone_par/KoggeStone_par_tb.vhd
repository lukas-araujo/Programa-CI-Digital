--------------------------------------------------------------------------------
--! @file KoggeStone_par_tb.vhd
--! @brief Testbench para o Somador Kogge-Stone.
--! @details Este ambiente de verificação realiza uma cobertura de todos os casos
--! possíveis para uma largura de 8 bits.
--!
--! @author Lukas Araujo
--! @version 1.1
--! @date 2023-10-27
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--! Entidade de teste para o Somador Kogge-Stone.
entity KoggeStone_par_tb is
end entity KoggeStone_par_tb;

--! Arquitetura.
architecture behavioural of KoggeStone_par_tb is

    --! Configuração da largura de bits para o teste.
    constant C_N : natural := 8;
    
    --! Componente sob teste
    component KoggeStone_par is
        generic (
            N : natural := 4
        );
        port (
            A    : in  std_logic_vector(N-1 downto 0);
            B    : in  std_logic_vector(N-1 downto 0);
            Cin  : in  std_logic;
            Sum  : out std_logic_vector(N-1 downto 0);
            Cout : out std_logic
        );
    end component;
    
    --! Estímulo para Operando A
    signal s_A   : std_logic_vector(C_N-1 downto 0) := (others => '0');
    --! Estímulo para Operando B
    signal s_B   : std_logic_vector(C_N-1 downto 0) := (others => '0');
    --! Estímulo para Carry In
    signal s_Cin : std_logic := '0';
    
    
    --! Resultado da soma obtido do DUT
    signal s_Sum  : std_logic_vector(C_N-1 downto 0);
    --! Carry Out obtido do DUT
    signal s_Cout : std_logic;

begin

    --! Instanciação do DUT (Design Under Test)
    uut : KoggeStone_par
        generic map (
            N => C_N
        )
        port map (
            A    => s_A,
            B    => s_B,
            Cin  => s_Cin,
            Sum  => s_Sum,
            Cout => s_Cout
        );

    --! Processo principal de estímulo e verificação.
    stim_proc : process
        -- variable i, j, k : integer;
        
        variable v_expected : unsigned(C_N downto 0);
        variable v_actual   : unsigned(C_N downto 0);
        
        variable v_errors : integer := 0;

    begin
        report "Iniciando Verificacao";

        -- Loop do Cin (0 e 1)
        for k in 0 to 1 loop
            
            -- Loop do A (0 até 255)
            for i in 0 to (2**C_N - 1) loop
                
                -- Loop do B (0 até 255)
                for j in 0 to (2**C_N - 1) loop
                    
                    s_Cin <= std_logic(to_unsigned(k, 1)(0)); 
                    s_A   <= std_logic_vector(to_unsigned(i, C_N));
                    s_B   <= std_logic_vector(to_unsigned(j, C_N));
                    
                    wait for 10 ns;

                    v_expected := to_unsigned(i, C_N+1) + to_unsigned(j, C_N+1) + to_unsigned(k, C_N+1);
                    
                    v_actual := unsigned(s_Cout & s_Sum);

                    if v_actual /= v_expected then
                        report "ERRO" &
                               " Tempo=" & time'image(now) &
                               " | A=" & integer'image(i) &
                               " | B=" & integer'image(j) &
                               " | Cin=" & integer'image(k) &
                               " | Esperado=" & integer'image(to_integer(v_expected)) &
                               " | Obtido=" & integer'image(to_integer(v_actual))
                               severity error;
                        v_errors := v_errors + 1;
                    end if;
                    

                end loop;
            end loop; 
        end loop;

        if v_errors = 0 then
            report "DEU BOM" severity note;
        else
            report "DEU RUIM: Foram encontrados " & integer'image(v_errors) & " erros no design." severity failure;
        end if;

        wait; 
    end process;

end architecture behavioural;