# Exercício de SQL e PL/SQL — Fábrica de móveis

## Contexto

Uma fábrica de móveis precisa controlar as matérias-primas utilizadas na produção de seus produtos. Cada produto possui uma composição que informa a quantidade de cada material necessária para fabricar uma unidade.

Por exemplo, uma mesa utiliza madeira, parafusos e verniz. Ao concluir uma ordem de produção de dez mesas, o sistema deve verificar a disponibilidade dos materiais e registrar o consumo correspondente.

Seu desafio é construir esse banco de dados em **Oracle SQL e PL/SQL**, em três etapas:

1. Criar as tabelas, as restrições e os dados de teste.
2. Implementar triggers para validar operações e automatizar o controle do estoque.
3. Criar views e procedures para consultar e operar o sistema.

Os enunciados apresentam os requisitos. Cabe ao aluno escrever e testar os comandos SQL e os blocos PL/SQL necessários.

## Regras gerais do exercício

- Cada ordem de produção está associada a um único produto e informa quantas unidades serão fabricadas.
- As situações possíveis de uma ordem são `ABERTA`, `CONCLUIDA` e `CANCELADA`.
- Uma ordem nasce aberta e pode ser concluída ou cancelada. Depois disso, não pode ser reaberta, alterada ou excluída.
- A abertura de uma ordem não reserva nem consome materiais. O consumo ocorre somente na conclusão.
- Uma ordem só pode ser concluída se houver saldo suficiente de **todos** os materiais necessários.
- Se a conclusão falhar, nenhuma baixa, movimentação ou alteração de situação dessa operação deve permanecer no banco.
- Cada material possui uma unidade de medida. As quantidades em estoque e na composição devem utilizar essa mesma unidade.
- Para este exercício, cadastre as composições antes de abrir as ordens e não as altere durante os testes de produção.
- O exercício controla matérias-primas; o estoque de produtos acabados não faz parte desta versão.

## Etapa 1 — Criação das tabelas

### 1.1. Estruture o banco de dados

Crie as tabelas abaixo. Escolha tipos de dados adequados e defina as restrições necessárias (constraints).

| Tabela | Informações necessárias |
| --- | --- |
| `produtos` | Identificador, nome e descrição do produto. |
| `materias_primas` | Identificador, nome, unidade de medida, quantidade em estoque e estoque mínimo. |
| `composicoes` | Produto, matéria-prima e quantidade necessária para fabricar uma unidade do produto. |
| `ordens_producao` | Identificador, produto, quantidade a produzir, situação, data de abertura e data de conclusão. |
| `movimentacoes_estoque` | Identificador, matéria-prima, tipo de movimentação (`ENTRADA` ou `CONSUMO`), quantidade, data e ordem de produção relacionada, quando houver. |
| `auditoria_estoque` | Identificador, matéria-prima, saldo anterior, saldo novo, usuário do banco e data da alteração. |

### 1.2. Garanta a integridade dos dados

Implemente as seguintes restrições:

1. Todas as tabelas devem possuir chave primária. Na composição, você pode utilizar uma chave composta.
2. Os relacionamentos devem ser representados por chaves estrangeiras, sem exclusão em cascata do histórico.
3. Os nomes dos produtos devem ser únicos. A mesma regra vale para os nomes das matérias-primas.
4. Uma matéria-prima não pode aparecer duas vezes na composição de um mesmo produto.
5. O estoque atual e o estoque mínimo não podem ser negativos.
6. As quantidades da composição, das ordens e das movimentações devem ser maiores que zero.
7. A quantidade a produzir deve ser inteira. Quantidades de matérias-primas podem possuir até três casas decimais.
8. A situação inicial de uma ordem deve ser `ABERTA`. A data de abertura deve ser preenchida automaticamente quando não for informada.
9. Uma ordem concluída deve possuir data de conclusão. Ordens abertas ou canceladas não devem possuir essa data.
10. Uma movimentação de consumo deve estar vinculada a uma ordem de produção. Uma entrada não deve estar vinculada a uma ordem.
11. Os campos essenciais ao funcionamento do modelo não devem aceitar valores nulos.

**Atenção:** diferencie as regras que podem ser garantidas por constraints do tipo `PRIMARY KEY`, `FOREIGN KEY`, `UNIQUE`, `CHECK`, `NOT NULL` e `DEFAULT` daquelas que exigirão os triggers da próxima etapa.

### 1.3. Cadastre dados para os testes

Prepare uma carga inicial contendo:

- Pelo menos três produtos, como mesa, cadeira e estante.
- Pelo menos cinco matérias-primas, com suas unidades e estoques mínimos.
- Pelo menos dois materiais na composição de cada produto.
- Pelo menos uma matéria-prima compartilhada por dois produtos.
- Pelo menos quatro ordens abertas, incluindo uma que possa ser concluída e outra cuja produção exija mais material do que o disponível.
- Pelo menos uma matéria-prima com estoque abaixo do mínimo.

Cadastre o saldo inicial de cada matéria-prima e uma movimentação de entrada correspondente. A soma das entradas menos os consumos deve coincidir com o saldo armazenado. As movimentações representam o histórico; inseri-las, por si só, não deve atualizar o estoque.

Tente inserir registros que violem as restrições e registre quais erros foram apresentados pelo Oracle.

## Etapa 2 — Implementação de triggers

### 2.1. Controle o ciclo de vida das ordens

Crie um trigger para garantir que:

- Uma ordem seja inserida somente na situação `ABERTA`.
- Uma ordem aberta possa permanecer aberta, ser concluída ou ser cancelada.
- O produto e a quantidade de uma ordem aberta possam ser corrigidos antes de sua conclusão ou cancelamento.
- Uma ordem concluída ou cancelada não possa ser alterada nem excluída.
- A data de conclusão seja preenchida automaticamente quando a ordem passar de aberta para concluída.

Apresente mensagens claras quando uma operação não for permitida.

### 2.2. Efetue a baixa dos materiais na conclusão

Crie um trigger acionado pela passagem de uma ordem de `ABERTA` para `CONCLUIDA`.

Para cada matéria-prima da composição do produto, calcule:

`quantidade necessária = quantidade por unidade × quantidade da ordem`

O trigger deve:

1. Impedir a conclusão de produtos sem composição cadastrada.
2. Verificar e baixar a quantidade necessária de cada matéria-prima.
3. Impedir a conclusão quando algum material tiver saldo insuficiente, informando qual material impediu a operação.
4. Registrar uma movimentação de consumo para cada material utilizado, vinculada à ordem.
5. Garantir que uma falha desfaça todos os efeitos daquela conclusão, inclusive eventuais baixas já realizadas.
6. Não consumir materiais quando uma ordem for apenas aberta, corrigida ou cancelada.

Utilize um cursor ou um laço de consulta para percorrer a composição. Não utilize `COMMIT` nos triggers e não ignore exceções que devam impedir a conclusão.

### 2.3. Audite as alterações de estoque

Crie um trigger que registre em `auditoria_estoque` cada alteração efetiva da quantidade em estoque de uma matéria-prima.

O registro deve conter o saldo anterior, o novo saldo, o usuário conectado e a data da alteração. Utilize `:OLD`, `:NEW` e `SYS_CONTEXT`.

Uma atualização que mantenha o mesmo saldo não deve gerar auditoria. Os registros de auditoria devem participar da mesma transação da alteração de estoque.

### 2.4. Proteja o histórico

Crie um trigger que impeça a alteração e a exclusão de movimentações de estoque. Novas entradas e novos consumos devem continuar permitidos.

### 2.5. Teste os triggers

Execute e documente, no mínimo, os seguintes cenários:

1. Conclusão de uma ordem com materiais suficientes: confira a situação, a data, os saldos, as movimentações e a auditoria.
2. Conclusão de uma ordem com falta de um dos materiais: compare os dados antes e depois e comprove que nenhum efeito da tentativa permaneceu.
3. Conclusão de uma ordem de produto sem composição.
4. Cancelamento de uma ordem aberta: confirme que não houve consumo.
5. Tentativa de alterar ou excluir uma ordem concluída.
6. Tentativa de inserir uma ordem já concluída.
7. Tentativa de alterar ou excluir uma movimentação.
8. Atualização de estoque sem mudança de saldo: confirme que não houve nova auditoria.

## Etapa 3 — Views e procedures

### 3.1. View de situação do estoque

Crie a view `vw_situacao_estoque` com o nome da matéria-prima, a unidade de medida, o saldo, o estoque mínimo e uma classificação:

- `SEM ESTOQUE`: saldo igual a zero.
- `ABAIXO DO MINIMO`: saldo maior que zero e menor que o estoque mínimo.
- `REGULAR`: saldo maior ou igual ao estoque mínimo, desde que maior que zero.

### 3.2. View de necessidades das ordens abertas

Crie a view `vw_necessidades_producao`, apresentando, para cada material de cada ordem aberta:

- Identificador da ordem e nome do produto.
- Nome da matéria-prima e unidade de medida.
- Quantidade necessária para a ordem.
- Saldo disponível no momento da consulta.
- Quantidade faltante, considerando zero quando o estoque for suficiente.

Como não há reserva de estoque, cada linha deve comparar a necessidade daquela ordem com o saldo atual. A view não deve considerar que outras ordens abertas já consumiram esse saldo.

### 3.3. View de consumo por produto

Crie a view `vw_consumo_por_produto`, agrupando os consumos registrados por produto e matéria-prima.

Apresente o nome do produto, o nome da matéria-prima, a unidade e a quantidade total consumida. Produtos sem consumo não precisam aparecer nessa view.

### 3.4. Procedure para receber matéria-prima

Crie a procedure `pr_receber_materia_prima`, recebendo o identificador da matéria-prima e a quantidade recebida.

A procedure deve validar a existência do material e exigir uma quantidade positiva com até três casas decimais. Em seguida, deve aumentar o estoque e registrar a movimentação de entrada. A auditoria deve ser gerada pelo trigger da etapa 2.

O aumento do saldo e o registro da entrada devem formar uma única operação: se um deles falhar, desfaça os efeitos dessa chamada e preserve as alterações anteriores realizadas por quem a chamou.

### 3.5. Procedure para abrir ordem de produção

Crie a procedure `pr_abrir_ordem`, recebendo o identificador do produto e a quantidade a produzir.

Valide a existência do produto e exija quantidade inteira positiva. Cadastre a ordem aberta e devolva seu identificador por meio de um parâmetro `OUT`.

A abertura deve ser permitida mesmo sem estoque suficiente. Nenhuma baixa deve ocorrer nesse momento.

### 3.6. Procedure para concluir ordem de produção

Crie a procedure `pr_concluir_ordem`, recebendo o identificador da ordem.

Verifique se a ordem existe e está aberta. Solicite a mudança para `CONCLUIDA`, deixando o trigger realizar a baixa e registrar os consumos. Evite duplicar na procedure a lógica de consumo implementada na etapa 2.

Caso a conclusão não seja possível, o chamador deve receber o erro correspondente.

### 3.7. Controle as transações e demonstre o fluxo completo

As procedures não devem executar `COMMIT`. A confirmação ou o desfazimento da transação cabe ao bloco que as chama. Utilize `SAVEPOINT` e tratamento de exceções quando necessário para preservar alterações anteriores do chamador.

Escreva um roteiro que:

1. Consulte as views para identificar uma ordem com falta de material.
2. Tente concluir essa ordem e trate a falha esperada.
3. Receba a quantidade de material necessária para viabilizar a produção.
4. Conclua a ordem e confira o histórico e os saldos.
5. Execute `ROLLBACK` e demonstre que o recebimento e a conclusão foram desfeitos, incluindo os registros de auditoria.
6. Repita o fluxo com sucesso e finalize com `COMMIT`.

## Conceitos adicionais

### O que é uma chave composta?

Uma **chave composta** é uma chave formada por duas ou mais colunas que, em conjunto, identificam um registro de maneira única. Nesse caso, a identificação depende da combinação dos valores dessas colunas.

Na tabela `composicoes`, por exemplo, cada registro relaciona um produto a uma matéria-prima utilizada em sua fabricação. Considere os seguintes dados:

| produto_id | materia_prima_id | quantidade_por_unidade |
| --- | --- | --- |
| 1 | 10 | 2,000 |
| 1 | 20 | 8,000 |
| 2 | 10 | 1,500 |

O produto `1` aparece em duas linhas porque utiliza materiais diferentes. A matéria-prima `10` também aparece em duas linhas porque é utilizada em produtos diferentes. Portanto, nenhuma dessas colunas, isoladamente, identifica uma linha de forma única.

Entretanto, cada combinação de `produto_id` e `materia_prima_id` deve aparecer uma única vez. Se essas duas colunas formarem a chave primária composta, o banco permitirá os pares `(1, 10)`, `(1, 20)` e `(2, 10)`, mas rejeitará a inserção de outro registro com o par `(1, 10)`, mesmo que a quantidade informada seja diferente.

Como fazem parte da chave primária, ambas as colunas também serão obrigatórias: nenhuma poderá conter `NULL`. Além disso, cada coluna pode ser uma chave estrangeira para sua respectiva tabela: `produto_id` referencia `produtos` e `materia_prima_id` referencia `materias_primas`.

Uma alternativa é criar um identificador próprio para cada composição e utilizá-lo como chave primária. Nesse caso, ainda será necessário definir uma restrição `UNIQUE` sobre o par de colunas do produto e da matéria-prima para impedir combinações repetidas, mantendo ambas com `NOT NULL`.

### O que é `SYS_CONTEXT`?

`SYS_CONTEXT` é uma função do Oracle que consulta informações de um contexto. O contexto predefinido `USERENV` fornece informações sobre a sessão atual.

Por exemplo:

```sql
SELECT SYS_CONTEXT('USERENV', 'SESSION_USER') AS usuario_conectado
FROM dual;
```

Nesse exemplo, `USERENV` indica o contexto consultado e `SESSION_USER` identifica a informação desejada: o nome do usuário que iniciou a sessão no banco.

No exercício, essa função permite identificar o usuário do banco responsável pela alteração do estoque. Se várias pessoas utilizarem a mesma conta de conexão, o valor retornado será essa conta compartilhada, sem distinguir as pessoas.

`SYS_CONTEXT` pode ser utilizado em SQL, procedures, funções e triggers. Seu uso não depende de `FOR EACH ROW`: tanto um trigger por comando quanto um trigger por linha pode consultá-lo. Consulte a [documentação de SYS_CONTEXT no Oracle](https://docs.oracle.com/en/database/oracle/oracle-database/19/sqlrf/SYS_CONTEXT.html).

### O que são `:OLD` e `:NEW`?

`:OLD` e `:NEW` são pseudorregistros que permitem acessar os valores das colunas da linha processada por um trigger DML.

| Operação | `:OLD.coluna` | `:NEW.coluna` |
| --- | --- | --- |
| `INSERT` | `NULL`, pois não existe linha anterior. | Valor da coluna na linha que está sendo inserida. |
| `UPDATE` | Valor anterior à atualização. | Novo valor da coluna. |
| `DELETE` | Valor da coluna na linha que está sendo excluída. | `NULL`, pois não existe linha posterior. |

Em uma atualização de estoque de 20 para 15 unidades, `:OLD.quantidade_estoque` representa `20` e `:NEW.quantidade_estoque` representa `15`. Utilize o nome de coluna adotado em sua tabela.

Os campos de `:OLD` são somente para leitura. Em um trigger `BEFORE` por linha de `INSERT` ou `UPDATE`, é possível atribuir valores a campos de `:NEW`. Em triggers `AFTER` e `INSTEAD OF`, esses campos são somente para leitura.

No corpo PL/SQL, utilize os dois-pontos: `:OLD.coluna` e `:NEW.coluna`. Na cláusula `WHEN` do trigger, omita-os: `OLD.coluna` e `NEW.coluna`. Consulte a [documentação de pseudorregistros do Oracle](https://docs.oracle.com/en/database/oracle/oracle-database/19/lnpls/correlation-names-and-pseudorecords.html).

### Em quais tipos de triggers `:OLD` e `:NEW` funcionam?

Triggers DML respondem a operações como `INSERT`, `UPDATE` e `DELETE`. É necessário distinguir o momento de execução (`BEFORE` ou `AFTER`) do nível de execução (por comando ou por linha).

Um trigger simples **por comando**, sem `FOR EACH ROW`, executa uma vez por comando SQL. Um trigger simples **por linha**, com `FOR EACH ROW`, executa para cada linha afetada. Se um `UPDATE` alterar dez linhas, o primeiro executará uma vez e o segundo, dez vezes.

| Tipo de trigger | Acessa `:OLD` e `:NEW`? | Finalidade comum |
| --- | --- | --- |
| `BEFORE ... FOR EACH ROW` | Sim. | Validar a linha e ajustar campos de `:NEW` antes de um `INSERT` ou `UPDATE`. |
| `AFTER ... FOR EACH ROW` | Sim, somente para leitura. | Auditar os valores anteriores e novos. |
| `BEFORE` ou `AFTER` por comando | Não. | Executar ações relativas ao comando como um todo. |
| `INSTEAD OF` por linha, em views | Sim, somente para leitura. | Executar operações em substituição ao DML solicitado sobre a view. |
| Composto (`COMPOUND TRIGGER`) | Somente nas seções por linha. | Combinar ações por comando e por linha no mesmo trigger. |

No trigger composto, os pseudorregistros não ficam disponíveis nas seções por comando nem na parte declarativa comum. Consulte a [documentação de triggers DML do Oracle](https://docs.oracle.com/en/database/oracle/oracle-database/19/lnpls/dml-triggers.html).

### O que é uma procedure e o que ela pode fazer?

Uma **procedure** é um subprograma PL/SQL que reúne instruções para executar uma tarefa. Quando criada com `CREATE OR REPLACE PROCEDURE`, fica armazenada no banco e pode ser chamada novamente pelo seu nome.

Uma procedure pode consultar, inserir, atualizar e excluir dados, realizar cálculos, validar regras, tratar exceções e chamar outros subprogramas. Ela também pode devolver informações por parâmetros de saída. Ao contrário de um trigger, uma procedure precisa ser chamada; não é disparada automaticamente por uma alteração na tabela.

Consulte a [documentação de subprogramas PL/SQL do Oracle](https://docs.oracle.com/en/database/oracle/oracle-database/19/lnpls/plsql-subprograms.html).

### Parâmetros `IN` e `OUT`

Os parâmetros permitem trocar informações entre a procedure e quem a chama.

| Modo | Finalidade | Exemplo de uso |
| --- | --- | --- |
| `IN` | Recebe um valor de entrada, que não pode ser alterado por atribuição ao parâmetro dentro da procedure. É o modo padrão quando nenhum modo é informado. | Receber a quantidade a produzir. |
| `OUT` | Devolve um valor ao chamador. A procedure deve atribuir o resultado ao parâmetro. | Devolver uma quantidade calculada ou o identificador de um registro criado. |
| `IN OUT` | Recebe um valor inicial e devolve um valor atualizado no mesmo parâmetro. | Receber um acumulador e devolver seu novo total. |

Para receber um resultado de `OUT` ou `IN OUT`, o chamador deve passar uma variável compatível. Para `IN`, pode passar uma variável, um valor literal ou uma expressão. Consulte a [documentação de parâmetros do Oracle](https://docs.oracle.com/en/database/oracle/oracle-database/19/lnpls/subprogram-parameters.html).

### Exemplo 1 — Procedure com parâmetro `IN`

A procedure abaixo recebe o nome de um produto e exibe uma mensagem, sem alterar tabelas.

```sql
CREATE OR REPLACE PROCEDURE pr_exibir_produto (
    p_nome IN VARCHAR2
) AS
BEGIN
    DBMS_OUTPUT.PUT_LINE('Produto informado: ' || p_nome);
END;
/
```

Depois de criá-la, execute a chamada:

```sql
SET SERVEROUTPUT ON;

BEGIN
    pr_exibir_produto('Mesa');
END;
/
```

O parâmetro `p_nome` recebe o texto `Mesa`. `DBMS_OUTPUT.PUT_LINE` exibe a mensagem, mas não devolve esse texto como parâmetro de saída.

### Exemplo 2 — Procedure com parâmetros `IN` e `OUT`

A próxima procedure calcula quantas unidades de um material são necessárias para uma produção. O exemplo é independente das tabelas: os valores são informados na chamada.

```sql
CREATE OR REPLACE PROCEDURE pr_calcular_material (
    p_quantidade_produtos IN NUMBER,
    p_material_por_unidade IN NUMBER,
    p_total OUT NUMBER
) AS
BEGIN
    IF p_quantidade_produtos IS NULL OR p_quantidade_produtos <= 0
       OR p_material_por_unidade IS NULL OR p_material_por_unidade <= 0 THEN
        RAISE_APPLICATION_ERROR(-20020, 'As quantidades devem ser positivas.');
    END IF;

    p_total := p_quantidade_produtos * p_material_por_unidade;
END;
/
```

Para utilizar o resultado:

```sql
SET SERVEROUTPUT ON;

DECLARE
    v_total NUMBER;
BEGIN
    pr_calcular_material(10, 4, v_total);
    DBMS_OUTPUT.PUT_LINE('Quantidade necessária: ' || v_total);
END;
/
```

Os parâmetros `IN` recebem `10` e `4`. O parâmetro `OUT` devolve `40` para a variável `v_total`, que pode ser utilizada nas próximas instruções do bloco. Passar um número literal no lugar de `v_total` não é permitido, pois o resultado precisa ser armazenado em uma variável.

Nos exemplos, `CREATE OR REPLACE` cria ou substitui a definição da procedure; o bloco `BEGIN ... END` posterior faz a chamada. No SQL Developer em modo script, a barra `/` envia o bloco PL/SQL para execução.

**No exercício:** mantenha o controle da transação no bloco chamador. As procedures que alteram dados devem permitir que ele decida entre `COMMIT` e `ROLLBACK`.
