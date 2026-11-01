# Catálogo de telas

Esta pasta armazenará uma imagem por tela ou estado, acompanhada de uma
especificação Markdown.

## Organização planejada

```text
screens/
├── dashboard/
├── statement/
└── transaction-details/
```

## Nomenclatura

```text
<id>-<nome>-<estado>-<tema>-v<versao>.png
```

Exemplos:

```text
dash-01-dashboard-success-light-v1.png
ext-01-statement-offline-dark-v1.png
det-01-transaction-details-error-light-v1.png
```

## Status

- **Exploratória:** proposta não revisada.
- **Em revisão:** selecionada para ajustes.
- **Aprovada:** referência vigente para implementação.
- **Substituída:** mantida somente como histórico.

Imagens devem usar dados fictícios e respeitar [tokens.md](../tokens.md) e
[navigation.md](../navigation.md). A existência de uma imagem não a torna
automaticamente aprovada.
