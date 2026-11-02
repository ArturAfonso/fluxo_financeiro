# ADR 0006 Rede cancelamento e retentativas

**Estado:** aceita
**Data:** 2026-11-01

## Contexto

O desafio exige HTTPS, timeouts, cancelamento de requisições obsoletas,
deduplicação e tratamento de HTTP 429 com backoff exponencial.

## Decisão

- Usar `dio` como cliente HTTP.
- Configurar timeouts e interceptadores em um único ponto.
- Propagar `CancelToken` do repositório até o datasource remoto. Atualizações
  equivalentes compartilham a mesma operação em andamento; uma atualização
  manual mais recente cancela e substitui a anterior.
- Implementar internamente uma política testável de retry para operações
  idempotentes, respeitando `Retry-After`, limite de tentativas, backoff
  exponencial, jitter e cancelamento.
- Traduzir `DioException` para falhas tipadas antes de sair da camada de dados.

## Consequências

Não será adicionada uma biblioteca automática de retry. A deduplicação será
definida no repositório ou coordenador de requisições, onde a chave semântica da
consulta é conhecida. Cancelamentos são traduzidos para uma falha tipada e não
são apresentados ao usuário como erro de conectividade.
