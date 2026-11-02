# ADR 0008 Modelagem financeira temporal e erros

**Estado:** aceita
**Data:** 2026-11-01

## Contexto

Saldo, totais, filtros e detalhes precisam permanecer coerentes entre telas.
O enunciado proíbe `double`, exige datas UTC, erros tipados e casos de borda
para arredondamento, estorno, valores grandes e virada de dia.

## Decisão

- Representar dinheiro com `Money`, armazenando centavos em `int`.
- Aceitar conversão decimal apenas a partir de texto e arredondar a terceira
  casa para longe de zero. Formatação localizada não pertence ao domínio.
- Manter o valor da transação não negativo e representar o sentido por
  `TransactionType.credit` ou `TransactionType.debit`.
- Modelar os status exemplificados pelo enunciado: concluída, pendente, falha e
  estornada. Somente transações concluídas afetam saldo e totais.
- Exigir `DateTime` UTC nas entidades e usar períodos semiabertos: início
  incluído e fim excluído. A apresentação converte o calendário local para UTC.
- Calcular o saldo a partir de um snapshot atômico com saldo de abertura,
  instante de referência e transações do intervalo.
- Paginar o extrato por cursor, com limite entre 1 e 100 itens.
- Retornar `Result<T>` com uma hierarquia fechada de `Failure`, sem propagar
  exceções de infraestrutura para a apresentação.

## Consequências

A separação entre valor e tipo evita sinais ambíguos nos DTOs. Períodos
semiabertos eliminam dupla contagem entre dias adjacentes. O snapshot é
adequado ao conjunto pequeno do desafio; numa evolução com histórico extenso,
o saldo de abertura deve avançar como marco consolidado para limitar o volume
calculado.
