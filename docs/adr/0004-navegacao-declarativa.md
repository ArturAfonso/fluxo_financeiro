# ADR 0004 Navegação declarativa

**Estado:** aceita
**Data:** 2026-11-01

## Contexto

O desafio exige rotas nomeadas e preservação de filtros e posição ao abrir um
detalhe e voltar.

## Decisão

Usar `go_router` como mecanismo de navegação, com:

- nomes de rota centralizados;
- parâmetros de caminho para identificadores;
- detalhe recebendo apenas o identificador da transação;
- shell declarativa caso a navegação principal use destinos persistentes;
- ciclo de vida do ViewModel posicionado para preservar o estado do extrato.

## Consequências

Não haverá um sistema paralelo baseado em `MaterialPageRoute`. A variante
exata da shell será escolhida junto ao fluxo visual, sem alterar a decisão de
usar GoRouter e rotas nomeadas.
