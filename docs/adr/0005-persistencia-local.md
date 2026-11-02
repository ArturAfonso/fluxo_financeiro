# ADR 0005 Persistência local

**Estado:** aceita
**Data:** 2026-11-01

## Contexto

O aplicativo precisa filtrar, ordenar, agrupar e paginar transações, manter
cache offline e atualizar diferentes telas a partir da mesma fonte de verdade.

## Decisão

- Usar `drift` e `drift_flutter` para dados financeiros estruturados.
- Usar transações atômicas, consultas tipadas, streams reativos e migrações
  testadas.
- Usar `SharedPreferencesAsync` somente para preferências pequenas e não
  sensíveis, inicialmente tema e visibilidade do saldo.
- Manter o banco Drift sem criptografia neste desafio porque ele contém somente
  fixtures financeiras fictícias e nenhuma credencial. Em produção, dados
  financeiros reais exigiriam modelagem de ameaças e armazenamento cifrado,
  com a chave protegida pelo Android Keystore ou iOS Keychain.
- Fixar temporariamente `drift` e `drift_dev` em `2.31.0` e `drift_flutter` em
  `0.2.8`. Esse é o conjunto mais recente resolvido sem sobrescrever versões
  fixadas pelo Flutter 3.41.7; a atualização será reavaliada junto com o SDK.

## Consequências

Drift introduz geração de código com `drift_dev` e `build_runner`, compensada
por segurança de tipos e suporte a consultas. Preferências nunca armazenarão o
extrato, saldo, credenciais ou dados críticos. A decisão de não cifrar o cache é
específica para os dados simulados do desafio e não deve ser transportada sem
reavaliação para um produto bancário real.
