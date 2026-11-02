# ADR 0009 Cache sincronização e paginação

**Estado:** aceita
**Data:** 2026-11-01

## Contexto

Dashboard, extrato e detalhe devem compartilhar uma fonte de verdade, funcionar
offline, sinalizar dados antigos e evitar chamadas repetidas. O backend
simulado também precisa permitir exercitar HTTP 429 e parsing defensivo.

## Decisão

- Usar o Drift como fonte canônica lida pelas telas e gravar um snapshot remoto
  em uma única transação de banco.
- Considerar o cache fresco por cinco minutos. Após esse período, tentar
  atualizar; se a rede falhar, entregar o snapshot local com seu `asOf` antigo.
- Consolidar chamadas simultâneas de atualização em uma única `Future`.
- Manter busca e filtros no banco local. Assim, digitação não gera chamadas de
  rede; debounce permanece responsabilidade do ViewModel.
- Paginar com cursor opaco baseado no par `occurredAt` e `id`, em ordem
  decrescente, evitando deslocamento quando novos registros chegam.
- Retentar somente operações GET idempotentes para HTTP 429, erros transitórios
  de conexão e HTTP 5xx. Usar no máximo três tentativas, backoff exponencial,
  jitter limitado e respeitar `Retry-After` quando válido.
- Nunca substituir o cache válido por resposta inválida ou atualização parcial.

## Consequências

Leituras permanecem consistentes e rápidas, e o aplicativo continua útil sem
rede. O snapshot completo simplifica a demonstração e a atomicidade do desafio;
em produção, sincronização incremental e remoções explícitas seriam necessárias
para históricos extensos. A busca local evita a necessidade de cancelar uma
requisição por caractere, enquanto `CancelToken` continua disponível para
operações remotas abandonadas.
