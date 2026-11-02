# Navegação e rotas

## Estado

Mapa aceito. GoRouter e rotas nomeadas foram confirmados no ADR 0004.
Preservação de estado é obrigatória.

## Telas principais

| ID | Tela | Responsabilidade |
|---|---|---|
| DASH-01 | Dashboard | Saldo, totais, evolução e transações recentes |
| EXT-01 | Extrato | Busca, filtros, agrupamento e paginação |
| DET-01 | Detalhes | Dados completos e cópia do identificador |

## Rotas conceituais

```text
dashboard              /
statement              /statement
transactionDetails     /transactions/:transactionId
```

O detalhe recebe apenas `transactionId` e consulta a fonte de verdade. A
entidade completa não deve ser serializada como argumento de navegação.

## Preservação

Ao retornar dos detalhes, o extrato deve preservar:

- filtros selecionados;
- texto de busca;
- páginas ou cursor já carregados;
- agrupamentos exibidos;
- posição de rolagem.

## Estados de interface a projetar

Cada tela aplicável precisa considerar loading inicial, atualização, sucesso,
vazio, erro com retry, offline com cache e cache possivelmente desatualizado.
