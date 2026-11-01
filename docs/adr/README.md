# Decisões arquiteturais

ADRs registram contexto, alternativas, decisão, consequências e estado. Eles
devem ser curtos e alterados por substituição, não por reescrita silenciosa do
histórico.

## Convenção

```text
NNNN-titulo-curto.md
```

Estados permitidos: proposta, aceita, substituída e rejeitada.

## Índice

| ADR | Decisão | Estado |
|---|---|---|
| [0001](0001-plataformas-e-identidade-tecnica.md) | Plataformas e identidade técnica | Aceita |
| [0002](0002-mvvm-com-camadas.md) | MVVM com separação em camadas | Aceita |

## ADRs planejados

- implementação de ViewModel e gerenciamento de estado;
- injeção de dependências;
- roteamento e preservação de estado;
- persistência e cache;
- backend simulado e integração externa;
- erros tipados, retry e deduplicação;
- modelagem monetária e temporal.
