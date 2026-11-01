# Documentação do Fluxo Financeiro

Este é o ponto de entrada da documentação AI-ready do projeto.

> **Estado:** scaffold mobile concluído; requisitos catalogados; arquitetura de
> referência registrada; implementação funcional ainda não iniciada.
>
> **Baseline:** Flutter 3.41.7 stable e Dart 3.11.5.
>
> **Plataformas:** Android e iOS.

## Objetivo

Construir um aplicativo de extrato e gestão financeira que apresente saldo,
entradas, saídas e transações com consistência, funcione de maneira útil com
conectividade degradada e permita defender cada decisão durante a apresentação
técnica.

## Fontes de verdade

- O documento `Teste Flutter (Banco).docx` é a especificação superior.
- [requisitos.md](requisitos.md) é o catálogo rastreável de requisitos.
- [ARCHITECTURE.md](ARCHITECTURE.md) define limites e dependências das camadas.
- ADRs aceitos em [adr/](adr/) registram decisões e consequências.
- [design/](design/) concentra navegação, tokens e referências visuais.

## Decisões atuais

### Obrigatórias

- MVVM com apresentação, domínio e dados claramente separados.
- Injeção e inversão de dependência.
- Estados imutáveis e erros tipados.
- Fonte única de verdade para os dados financeiros.
- Cache local, paginação, deduplicação e tratamento de HTTP 429.
- Tema claro e escuro, acessibilidade básica e listas performáticas.
- Testes unitários, de widget e de integração, com cobertura exigida.
- CI e APK Android de release protegido.

### Aceitas

- Nome do produto: Fluxo Financeiro.
- Projeto Dart: `fluxo_financeiro`.
- Organização: `br.com.arturafonso`.
- Plataformas geradas: Android e iOS.

### Em avaliação

- implementação de ViewModel e gerenciamento de estado;
- contêiner de injeção de dependências;
- cliente HTTP e mecanismo de cancelamento/deduplicação;
- banco local e estratégia exata de sincronização;
- backend simulado e eventual uso complementar da CoinGecko;
- identidade visual e tipografia finais.

## Mapa da documentação

| Documento | Finalidade | Estado |
|---|---|---|
| [AGENTS.md](../AGENTS.md) | Regras para assistentes e colaboradores | Aceito |
| [README.md](../README.md) | Entrada pública e comandos do projeto | Aceito; evolutivo |
| [requisitos.md](requisitos.md) | Requisitos e rastreabilidade | Obrigatório; inicial |
| [ARCHITECTURE.md](ARCHITECTURE.md) | Arquitetura MVVM e limites das camadas | Obrigatório; inicial |
| [plano-implementacao.md](plano-implementacao.md) | Incrementos e critérios de aceite | Provisório |
| [adr/README.md](adr/README.md) | Índice das decisões arquiteturais | Aceito |
| [design/README.md](design/README.md) | Entrada da documentação visual | Aceito |
| [design/navigation.md](design/navigation.md) | Rotas, telas e preservação de estado | Inicial |
| [design/tokens.md](design/tokens.md) | Tokens semânticos e acessibilidade | Provisório |
| [design/screens/README.md](design/screens/README.md) | Convenções para referências de telas | Aceito |

## Regra de atualização

Ao criar, renomear ou tornar oficial um documento, atualize este mapa. Evite
duplicar regras: registre a definição em uma fonte canônica e use links nos
demais arquivos.
