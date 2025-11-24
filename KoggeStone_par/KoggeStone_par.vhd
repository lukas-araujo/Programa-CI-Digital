--------------------------------------------------------------------------------
--! @file KoggeStone_par.vhd
--! @brief Somador de Arquitetura Kogge-Stone.
--! @details Este módulo implementa um somador parametrizável usando a topologia
--! Kogge-Stone. A implementação segue a estrutura de generate fornecida no modelo Verilog da aula.
--!
--! @author Lukas
--! @version 1.0
--! @date 2025-11-03
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--! @brief Entidade do somador Kogge-Stone parametrizável.
entity KoggeStone_par is
    generic (
        --! Largura dos operandos em bits.
        N : natural := 4
    );
    port (
        --! Operando A
        A    : in  std_logic_vector(N-1 downto 0);
        --! Operando B
        B    : in  std_logic_vector(N-1 downto 0);
        --! Carry In de entrada
        Cin  : in  std_logic;
        --! Resultado da soma
        Sum  : out std_logic_vector(N-1 downto 0);
        --! Carry Out de saída
        Cout : out std_logic
    );
end entity KoggeStone_par;

architecture behavioural of KoggeStone_par is

    --! Função auxiliar para calcular Log2 arredondado para cima (ceil_log2)
    function ceil_log2 (val : natural) return natural is
        variable temp : natural := val;
        variable res  : natural := 0;
    begin
        if val <= 1 then return 0; end if;
        temp := temp - 1;
        while temp > 0 loop
            temp := temp / 2;
            res := res + 1;
        end loop;
        return res;
    end function;

    --! Constante que define o número de níveis da árvore de prefixo
    constant NUM_STAGES : natural := ceil_log2(N);

    --! Sinais de Propagate (P) e Generate (G) iniciais
    signal P, G : std_logic_vector(N-1 downto 0);
    
    --! Vetor de Carries (incluindo o C[N] final)
    signal C : std_logic_vector(N downto 0);

    --! Definição de tipos para matrizes 2D (Estágios x Bits)
    type stage_array_t is array (0 to NUM_STAGES) of std_logic_vector(N-1 downto 0);
    
    --! Sinal de Generate para cada estágio da árvore
    signal G_stage : stage_array_t;
    
    --! Sinal de Propagate para cada estágio da árvore
    signal P_stage : stage_array_t;

begin


    --! Propagate inicial
    P <= A xor B;
    --! Generate inicial
    G <= A and B;

    --! Inicializa o estágio 0 da árvore com os valores brutos
    G_stage(0) <= G;
    P_stage(0) <= P;

    --! Loop externo (j): Itera sobre os estágios da árvore (de 1 até log2(N))
    gen_stages : for j in 1 to NUM_STAGES generate
        --! Constante auxiliar para o deslocamento (offset) da conexão: 2^(j-1)
        constant OFFSET : natural := 2**(j-1);
    begin
        --! Loop interno (i): Itera sobre cada bit
        gen_bits : for i in 0 to N-1 generate
        begin
            --! Lógica de conexão do Kogge-Stone:
            --! Se o índice 'i' for maior ou igual ao offset, aplicamos o "Dot Operator".
            --! Caso contrário, apenas passamos o valor do estágio anterior (buffer).
            
            if_compute : if i >= OFFSET generate
                --! Operador de Prefixo (Grey Cell / Black Cell logic)
                --! G_new = G_current OR (P_current AND G_previous_offset)
                G_stage(j)(i) <= G_stage(j-1)(i) or (P_stage(j-1)(i) and G_stage(j-1)(i - OFFSET));
                --! P_new = P_current AND P_previous_offset
                P_stage(j)(i) <= P_stage(j-1)(i) and P_stage(j-1)(i - OFFSET);
            end generate if_compute;

            if_buffer : if i < OFFSET generate
                --! Buffer (passa o valor adiante)
                G_stage(j)(i) <= G_stage(j-1)(i);
                P_stage(j)(i) <= P_stage(j-1)(i);
            end generate if_buffer;
            
        end generate gen_bits;
    end generate gen_stages;

    --! O carry de entrada é o C[0]
    C(0) <= Cin;

    --! O Verilog fornecido usa uma estrutura de ripple carry no final,
    --! usando os Ps e Gs do último estágio da árvore e o carry anterior.
    gen_carries : for i in 0 to N-1 generate
        C(i+1) <= G_stage(NUM_STAGES)(i) or (P_stage(NUM_STAGES)(i) and C(i));
    end generate gen_carries;

    --! Soma = P inicial XOR Carries calculados
    Sum  <= P xor C(N-1 downto 0);
    --! Cout é o último bit do vetor de carries
    Cout <= C(N);

end architecture behavioural;

