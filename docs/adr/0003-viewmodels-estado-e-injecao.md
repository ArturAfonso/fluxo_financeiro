# ADR 0003 ViewModels estado e injeção

**Estado:** aceita
**Data:** 2026-11-01

## Contexto

O desafio exige MVVM, estados imutáveis, injeção de dependências e testes de
ViewModel. Foram considerados Cubit, Riverpod Notifier e ChangeNotifier.

## Decisão

- Implementar cada ViewModel como uma classe nomeada de acordo com seu papel e
  baseada em `Cubit<State>` do `flutter_bloc`.
- Representar estados imutáveis com igualdade por valor usando `equatable`.
- Usar `get_it` no composition root.
- Manter injeção por construtor em ViewModels, casos de uso, repositórios e
  datasources.
- Resolver o ViewModel no ponto de composição da rota e entregá-lo à View por
  `BlocProvider`.

## Consequências

As transições ficam explícitas e podem ser verificadas com `bloc_test`. GetIt
não pode ser usado como estado global da interface nem acessado de forma
indiscriminada dentro dos widgets.
