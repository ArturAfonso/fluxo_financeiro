# ADR 0007 Bibliotecas de apoio e testes

**Estado:** aceita
**Data:** 2026-11-01

## Contexto

O aplicativo requer formatação pt-BR, gráfico de evolução e uma pirâmide de
testes que cubra domínio, ViewModels, repositórios, widgets e fluxo principal.

## Decisão

- Usar `intl` para moeda e datas em pt-BR.
- Usar a versão de `intl` fixada pelo SDK Flutter para manter compatibilidade
  com `flutter_localizations`.
- Usar `fl_chart` para o gráfico simples.
- Usar `flutter_test`, `bloc_test` e `mocktail` nos testes unitários e de widget.
- Usar `integration_test`, fornecido pelo SDK Flutter, para o fluxo principal.
- Usar `drift_dev` e `build_runner` para gerar e testar a persistência.
- Não adotar inicialmente Freezed, Retrofit, biblioteca funcional ou gerador de
  mocks.

## Consequências

A stack mantém pouco código gerado além do banco. O domínio usará unidade
monetária inteira e um `Result` selado próprio, que ainda serão especificados em
ADRs dedicados.
