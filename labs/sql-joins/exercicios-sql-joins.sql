------------------------------------------------------------
-- EXERCICIOS - SQL JOINS
-- TEMA: EDITORAS E LIVROS
--
-- Contexto dos exercicios:
--   EDITORAS
--   LIVROS
--
-- Estes exercicios seguem a mesma ideia do script de exemplos,
-- mas em outro contexto. Considere uma base em que uma editora
-- pode publicar varios livros, e um livro pertence a uma editora.
--
-- Para fazer os exercicios, primeiro prepare o banco executando
-- os comandos de DROP, CREATE TABLE e INSERT abaixo.
--
-- Escreva cada consulta abaixo do respectivo enunciado.
------------------------------------------------------------


------------------------------------------------------------
-- 0. PREPARACAO DO BANCO DE DADOS
------------------------------------------------------------

-- Execute esta secao antes de resolver os exercicios.
--
-- A ordem dos comandos de DROP e importante:
--   1. primeiro removemos LIVROS, pois ela possui chave
--      estrangeira para EDITORAS;
--   2. depois removemos EDITORAS.
--
-- Os blocos abaixo BEGIN/END ignoram o erro ORA-00942, que
-- ocorre quando a tabela ainda nao existe.
--
-- EXECUTE IMMEDIATE e uma instrucao do Oracle usada para
-- executar um comando SQL escrito como texto dentro de um bloco
-- PL/SQL. Aqui ela permite executar DROP TABLE dentro do bloco
-- BEGIN/END e tratar possiveis erros na secao EXCEPTION.

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE LIVROS';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN
            RAISE;
        END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE EDITORAS';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN
            RAISE;
        END IF;
END;
/


------------------------------------------------------------
-- 0.1. CRIACAO DA TABELA EDITORAS
------------------------------------------------------------

CREATE TABLE EDITORAS (
    CODIGO          NUMBER(10)      NOT NULL,
    NOME            VARCHAR2(100)   NOT NULL,
    PAIS_ORIGEM     VARCHAR2(80)    NOT NULL,

    CONSTRAINT PK_EDITORAS
        PRIMARY KEY (CODIGO),

    CONSTRAINT UK_EDITORAS_NOME
        UNIQUE (NOME)
);


------------------------------------------------------------
-- 0.2. CRIACAO DA TABELA LIVROS
------------------------------------------------------------

CREATE TABLE LIVROS (
    CODIGO              NUMBER(10)      NOT NULL,
    TITULO              VARCHAR2(150)   NOT NULL,
    EDICAO              VARCHAR2(80),
    EDITORA_CODIGO      NUMBER(10)      NOT NULL,
    ANO_PUBLICACAO      NUMBER(4)       NOT NULL,
    ANO_FIM_CATALOGO    NUMBER(4),
    PRECO_LANCAMENTO    NUMBER(15,2),
    MOEDA               VARCHAR2(10),

    CONSTRAINT PK_LIVROS
        PRIMARY KEY (CODIGO),

    CONSTRAINT FK_LIVROS_EDITORAS
        FOREIGN KEY (EDITORA_CODIGO)
        REFERENCES EDITORAS(CODIGO),

    CONSTRAINT CK_LIVROS_ANO_CATALOGO
        CHECK (
            ANO_FIM_CATALOGO IS NULL
            OR ANO_FIM_CATALOGO >= ANO_PUBLICACAO
        ),

    CONSTRAINT CK_LIVROS_PRECO
        CHECK (
            PRECO_LANCAMENTO IS NULL
            OR PRECO_LANCAMENTO >= 0
        )
);


------------------------------------------------------------
-- 0.3. SEED - EDITORAS
------------------------------------------------------------

INSERT INTO EDITORAS (CODIGO, NOME, PAIS_ORIGEM)
VALUES (1, 'Companhia das Letras', 'Brasil');

INSERT INTO EDITORAS (CODIGO, NOME, PAIS_ORIGEM)
VALUES (2, 'Record', 'Brasil');

INSERT INTO EDITORAS (CODIGO, NOME, PAIS_ORIGEM)
VALUES (3, 'Penguin Books', 'Reino Unido');

INSERT INTO EDITORAS (CODIGO, NOME, PAIS_ORIGEM)
VALUES (4, 'HarperCollins', 'Estados Unidos');

INSERT INTO EDITORAS (CODIGO, NOME, PAIS_ORIGEM)
VALUES (5, 'Gallimard', 'Franca');

INSERT INTO EDITORAS (CODIGO, NOME, PAIS_ORIGEM)
VALUES (6, 'Planeta', 'Espanha');

INSERT INTO EDITORAS (CODIGO, NOME, PAIS_ORIGEM)
VALUES (7, 'Kodansha', 'Japao');

-- Esta editora foi inserida sem livros para permitir exercicios
-- com LEFT JOIN e registros sem correspondencia.

INSERT INTO EDITORAS (CODIGO, NOME, PAIS_ORIGEM)
VALUES (8, 'Editora Horizonte', 'Brasil');


------------------------------------------------------------
-- 0.4. SEED - LIVROS
------------------------------------------------------------

INSERT INTO LIVROS (
    CODIGO,
    TITULO,
    EDICAO,
    EDITORA_CODIGO,
    ANO_PUBLICACAO,
    ANO_FIM_CATALOGO,
    PRECO_LANCAMENTO,
    MOEDA
)
VALUES (
    101,
    'Algoritmos na Pratica',
    '1a edicao',
    1,
    2018,
    NULL,
    89.90,
    'BRL'
);

INSERT INTO LIVROS (
    CODIGO,
    TITULO,
    EDICAO,
    EDITORA_CODIGO,
    ANO_PUBLICACAO,
    ANO_FIM_CATALOGO,
    PRECO_LANCAMENTO,
    MOEDA
)
VALUES (
    102,
    'Banco de Dados Essencial',
    '2a edicao',
    1,
    2009,
    NULL,
    74.50,
    'BRL'
);

INSERT INTO LIVROS (
    CODIGO,
    TITULO,
    EDICAO,
    EDITORA_CODIGO,
    ANO_PUBLICACAO,
    ANO_FIM_CATALOGO,
    PRECO_LANCAMENTO,
    MOEDA
)
VALUES (
    201,
    'Redes para Sistemas',
    '1a edicao',
    2,
    2001,
    2014,
    62.00,
    'BRL'
);

INSERT INTO LIVROS (
    CODIGO,
    TITULO,
    EDICAO,
    EDITORA_CODIGO,
    ANO_PUBLICACAO,
    ANO_FIM_CATALOGO,
    PRECO_LANCAMENTO,
    MOEDA
)
VALUES (
    202,
    'Engenharia de Software Aplicada',
    '3a edicao',
    2,
    2016,
    NULL,
    98.00,
    'BRL'
);

INSERT INTO LIVROS (
    CODIGO,
    TITULO,
    EDICAO,
    EDITORA_CODIGO,
    ANO_PUBLICACAO,
    ANO_FIM_CATALOGO,
    PRECO_LANCAMENTO,
    MOEDA
)
VALUES (
    301,
    'Introduction to SQL',
    'International edition',
    3,
    1998,
    2008,
    39.90,
    'GBP'
);

INSERT INTO LIVROS (
    CODIGO,
    TITULO,
    EDICAO,
    EDITORA_CODIGO,
    ANO_PUBLICACAO,
    ANO_FIM_CATALOGO,
    PRECO_LANCAMENTO,
    MOEDA
)
VALUES (
    302,
    'Data Modeling Guide',
    'Revised edition',
    3,
    2012,
    NULL,
    44.90,
    'GBP'
);

INSERT INTO LIVROS (
    CODIGO,
    TITULO,
    EDICAO,
    EDITORA_CODIGO,
    ANO_PUBLICACAO,
    ANO_FIM_CATALOGO,
    PRECO_LANCAMENTO,
    MOEDA
)
VALUES (
    401,
    'Cloud Systems Handbook',
    '1st edition',
    4,
    2020,
    NULL,
    59.99,
    'USD'
);

INSERT INTO LIVROS (
    CODIGO,
    TITULO,
    EDICAO,
    EDITORA_CODIGO,
    ANO_PUBLICACAO,
    ANO_FIM_CATALOGO,
    PRECO_LANCAMENTO,
    MOEDA
)
VALUES (
    402,
    'Operating Systems Review',
    'Classic edition',
    4,
    1995,
    2005,
    49.99,
    'USD'
);

INSERT INTO LIVROS (
    CODIGO,
    TITULO,
    EDICAO,
    EDITORA_CODIGO,
    ANO_PUBLICACAO,
    ANO_FIM_CATALOGO,
    PRECO_LANCAMENTO,
    MOEDA
)
VALUES (
    501,
    'Bases de Donnees',
    'Edition universitaire',
    5,
    2007,
    2019,
    35.00,
    'EUR'
);

INSERT INTO LIVROS (
    CODIGO,
    TITULO,
    EDICAO,
    EDITORA_CODIGO,
    ANO_PUBLICACAO,
    ANO_FIM_CATALOGO,
    PRECO_LANCAMENTO,
    MOEDA
)
VALUES (
    601,
    'Arquitectura de Datos',
    '2a edicion',
    6,
    2015,
    NULL,
    42.00,
    'EUR'
);

INSERT INTO LIVROS (
    CODIGO,
    TITULO,
    EDICAO,
    EDITORA_CODIGO,
    ANO_PUBLICACAO,
    ANO_FIM_CATALOGO,
    PRECO_LANCAMENTO,
    MOEDA
)
VALUES (
    701,
    'Sistemas Distribuidos Modernos',
    '1a edicao',
    7,
    2019,
    NULL,
    5200.00,
    'JPY'
);

INSERT INTO LIVROS (
    CODIGO,
    TITULO,
    EDICAO,
    EDITORA_CODIGO,
    ANO_PUBLICACAO,
    ANO_FIM_CATALOGO,
    PRECO_LANCAMENTO,
    MOEDA
)
VALUES (
    702,
    'Fundamentos de Programacao',
    'Edicao compacta',
    7,
    2003,
    2011,
    3900.00,
    'JPY'
);

COMMIT;


------------------------------------------------------------
-- EXERCICIOS
------------------------------------------------------------


------------------------------------------------------------
-- 1. LISTAGEM BASICA DE LIVROS E EDITORAS
------------------------------------------------------------

-- Liste o nome da editora, o pais de origem, o titulo do livro
-- e a edicao do livro.
--
-- Ordene o resultado pelo nome da editora e depois pelo titulo
-- do livro.



------------------------------------------------------------
-- 2. LIVROS DE EDITORAS BRASILEIRAS
------------------------------------------------------------

-- Liste todos os livros publicados por editoras do Brasil.
--
-- A consulta deve exibir:
--   - editora
--   - livro
--   - edicao
--   - ano de publicacao



------------------------------------------------------------
-- 3. LIVROS AINDA EM CATALOGO
------------------------------------------------------------

-- Liste os livros que ainda estao em catalogo.
--
-- Considere que um livro ainda esta em catalogo quando
-- ANO_FIM_CATALOGO for NULL.
--
-- A consulta deve exibir a editora, o livro e o ano de
-- publicacao.



------------------------------------------------------------
-- 4. LIVROS FORA DE CATALOGO
------------------------------------------------------------

-- Liste os livros que ja sairam de catalogo.
--
-- A consulta deve exibir:
--   - editora
--   - livro
--   - ano de publicacao
--   - ano de fim de catalogo



------------------------------------------------------------
-- 5. EDITORAS SEM LIVROS CADASTRADOS
------------------------------------------------------------

-- Liste as editoras que nao possuem nenhum livro cadastrado.
--
-- Use LEFT JOIN para resolver o exercicio.



------------------------------------------------------------
-- 6. TODAS AS EDITORAS E SEUS LIVROS
------------------------------------------------------------

-- Liste todas as editoras, mesmo aquelas que nao possuem livros
-- cadastrados.
--
-- Para editoras sem livros, as colunas referentes ao livro
-- devem aparecer como NULL.



------------------------------------------------------------
-- 7. QUANTIDADE DE LIVROS POR EDITORA
------------------------------------------------------------

-- Conte quantos livros cada editora possui.
--
-- A consulta deve mostrar tambem editoras com zero livros.
--
-- Ordene da editora com mais livros para a editora com menos
-- livros.



------------------------------------------------------------
-- 8. EDITORAS COM MAIS DE UM LIVRO
------------------------------------------------------------

-- Liste somente as editoras que possuem mais de um livro
-- cadastrado.
--
-- A consulta deve exibir:
--   - editora
--   - quantidade de livros
--
-- Dica:
--   depois de agrupar com GROUP BY, use HAVING para filtrar
--   grupos pela quantidade calculada.



------------------------------------------------------------
-- 9. QUANTIDADE DE LIVROS POR PAIS
------------------------------------------------------------

-- Conte quantos livros existem para cada pais de origem das
-- editoras.
--
-- Ordene o resultado da maior quantidade para a menor.



------------------------------------------------------------
-- 10. LIVROS PUBLICADOS ENTRE 1990 E 2010
------------------------------------------------------------

-- Liste os livros cujo ano de publicacao esteja entre 1990 e
-- 2010.
--
-- A consulta deve exibir:
--   - editora
--   - livro
--   - ano de publicacao



------------------------------------------------------------
-- 11. TEMPO EM CATALOGO DOS LIVROS ENCERRADOS
------------------------------------------------------------

-- Para os livros que possuem ano de fim de catalogo, calcule
-- por quantos anos eles permaneceram em catalogo.
--
-- A consulta deve exibir:
--   - editora
--   - livro
--   - ano de publicacao
--   - ano de fim de catalogo
--   - anos em catalogo
--
-- Ordene pelos livros com maior tempo em catalogo.



------------------------------------------------------------
-- 12. LIVROS COM PRECO EM REAL
------------------------------------------------------------

-- Liste todos os livros cujo preco de lancamento esteja
-- registrado em BRL.
--
-- A consulta deve exibir a editora, o livro, o preco de
-- lancamento e a moeda.



------------------------------------------------------------
-- 13. PRECO MEDIO DOS LIVROS POR EDITORA E MOEDA
------------------------------------------------------------

-- Calcule o preco medio de lancamento dos livros agrupando por
-- editora e moeda.
--
-- Importante: nao misture moedas diferentes na mesma media.



------------------------------------------------------------
-- 14. MAIOR PRECO DE LANCAMENTO EM BRL
------------------------------------------------------------

-- Liste o livro ou os livros que possuem o maior preco de
-- lancamento registrado em BRL.
--
-- A consulta deve exibir:
--   - editora
--   - livro
--   - preco de lancamento
--   - moeda



------------------------------------------------------------
-- 15. EDITORAS COM LIVROS EM BRL
------------------------------------------------------------

-- Liste as editoras que possuem pelo menos um livro com preco
-- de lancamento registrado em BRL.
--
-- Cada editora deve aparecer apenas uma vez.
--
-- Dica:
--   use DISTINCT para evitar que a mesma editora apareca mais
--   de uma vez no resultado.



------------------------------------------------------------
-- 16. QUANTIDADE DE MOEDAS POR EDITORA
------------------------------------------------------------

-- Conte quantas moedas diferentes aparecem nos livros de cada
-- editora.
--
-- A consulta deve exibir todas as editoras, inclusive as que
-- nao possuem livros cadastrados.
--
-- Dica:
--   use DISTINCT dentro do COUNT para contar apenas moedas
--   diferentes.



------------------------------------------------------------
-- 17. LIVRO MAIS ANTIGO POR EDITORA
------------------------------------------------------------

-- Para cada editora que possui livros, descubra o menor ano de
-- publicacao cadastrado.
--
-- A consulta deve exibir:
--   - editora
--   - primeiro ano de publicacao encontrado



------------------------------------------------------------
-- 18. LIVRO MAIS RECENTE POR EDITORA
------------------------------------------------------------

-- Para cada editora que possui livros, descubra o maior ano de
-- publicacao cadastrado.
--
-- A consulta deve exibir:
--   - editora
--   - ano do livro mais recente



------------------------------------------------------------
-- 19. FILTRO NO ON X FILTRO NO WHERE
------------------------------------------------------------

-- Escreva duas consultas para comparar o comportamento do
-- filtro no ON e no WHERE.
--
-- Objetivo:
--   listar todas as editoras, mas considerar apenas livros
--   publicados a partir do ano 2015.
--
-- Consulta A:
--   use LEFT JOIN e coloque o filtro de ano no ON.
--
-- Consulta B:
--   use LEFT JOIN e coloque o filtro de ano no WHERE.
--
-- Compare os resultados obtidos.



------------------------------------------------------------
-- 20. RELATORIO GERAL DO CATALOGO EDITORIAL
------------------------------------------------------------

-- Monte um relatorio geral com todas as editoras e seus
-- respectivos livros.
--
-- A consulta deve exibir:
--   - codigo da editora
--   - nome da editora
--   - pais de origem
--   - codigo do livro
--   - titulo do livro
--   - edicao
--   - ano de publicacao
--   - ano de fim de catalogo
--   - status do livro
--
-- Regras para o status:
--   - se a editora nao possuir livro, mostrar 'SEM LIVRO'
--   - se o livro nao possuir ano de fim de catalogo, mostrar 'EM CATALOGO'
--   - caso contrario, mostrar 'FORA DE CATALOGO'
--
-- Ordene por editora e livro.
