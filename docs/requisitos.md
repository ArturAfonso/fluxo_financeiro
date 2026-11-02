# Requisitos e rastreabilidade

Este catálogo traduz o enunciado original em itens verificáveis. O DOCX continua
sendo a autoridade superior. Cada requisito deverá apontar, antes da entrega,
para sua implementação, seus testes e sua documentação.

## Funcionais

| ID | Requisito | Estado |
|---|---|---|
| RF-DASH-01 | Exibir saldo disponível | Concluído |
| RF-DASH-02 | Ocultar e exibir saldo, mantendo a preferência entre sessões | Concluído |
| RF-DASH-03 | Exibir entradas e saídas do período selecionado | Concluído |
| RF-DASH-04 | Exibir gráfico simples de evolução | Concluído com pontos diários e agrupamento visual semanal em meses completos |
| RF-DASH-05 | Exibir transações recentes e acesso ao extrato completo | Concluído |
| RF-EXT-01 | Listar descrição, data, valor e status | Concluído |
| RF-EXT-02 | Diferenciar entradas e saídas sem depender apenas de cor | Concluído |
| RF-EXT-03 | Combinar filtros por tipo, status e período | Concluído |
| RF-EXT-04 | Permitir intervalo de datas personalizado | Concluído |
| RF-EXT-05 | Buscar por descrição com debounce | Concluído |
| RF-EXT-06 | Paginar por scroll, página ou cursor | Concluído |
| RF-EXT-07 | Agrupar transações por data | Concluído |
| RF-EXT-08 | Preservar filtros e posição após abrir detalhes e voltar | Concluído |
| RF-EXT-09 | Abrir detalhes por rota nomeada | Concluído |
| RF-DET-01 | Exibir identificador, descrição, valor, data/hora, tipo, status e metadados | Concluído |
| RF-DET-02 | Copiar o identificador da transação | Concluído |
| RF-DET-03 | Manter apresentação consistente com o extrato | Concluído |

## Dados e resiliência

| ID | Requisito | Estado |
|---|---|---|
| RD-01 | Consumir a API indicada e/ou backend simulado | Concluído com mock local |
| RD-02 | Documentar o mapeamento entre resposta externa e domínio | Concluído |
| RD-03 | Estados de carregamento, atualização, vazio, erro e offline | Concluído |
| RD-04 | Pull-to-refresh | Concluído |
| RD-05 | Cache dos últimos dados conhecidos | Concluído na camada de dados |
| RD-06 | Sinalizar dados possivelmente desatualizados | Concluído com banner, instante da sincronização e nova tentativa |
| RD-07 | Deduplicar chamadas equivalentes | Concluído para sincronização |
| RD-08 | Cancelar requisições obsoletas | Concluído com `CancelToken` propagado pelo repositório e substituição de refresh manual |
| RD-09 | Tratar HTTP 429 com retentativa e backoff exponencial | Concluído |
| RD-10 | Garantir fonte única de verdade entre todas as telas | Concluído |
| RD-11 | Fazer parsing defensivo das respostas | Concluído |

## Arquitetura e código

| ID | Requisito | Estado |
|---|---|---|
| RT-ARQ-01 | Usar Flutter stable e Dart com null safety | Concluído |
| RT-ARQ-02 | Documentar versões no README | Concluído |
| RT-ARQ-03 | Aplicar MVVM com View e ViewModel reconhecíveis | Concluído |
| RT-ARQ-04 | Separar apresentação, domínio e dados | Concluído |
| RT-ARQ-05 | Manter entidades, casos de uso e contratos no domínio | Concluído |
| RT-ARQ-06 | Manter datasources, DTOs e mappers em dados | Concluído |
| RT-ARQ-07 | Aplicar injeção e inversão de dependência | Concluído |
| RT-ARQ-08 | Usar estados imutáveis e justificar a biblioteca escolhida | Concluído |
| RT-ARQ-09 | Modelar erros com Result/Either ou hierarquia equivalente | Concluído |
| RT-ARQ-10 | Manter lint rigoroso e zero warnings | Concluído com `flutter_lints`, modos estritos do analyzer e regras adicionais |

## Integridade financeira e temporal

| ID | Requisito | Estado |
|---|---|---|
| RT-FIN-01 | Não usar `double` para dinheiro no domínio | Concluído |
| RT-FIN-02 | Usar centavos inteiros ou tipo decimal | Concluído |
| RT-FIN-03 | Formatar moeda e datas em pt-BR | Concluído |
| RT-FIN-04 | Manter cálculos de saldo e totais no domínio | Concluído |
| RT-FIN-05 | Cobrir zero, grandes valores, arredondamento e virada de dia | Concluído |
| RT-FIN-06 | Armazenar e trafegar datas em UTC | Concluído no domínio |
| RT-FIN-07 | Exibir datas no fuso local | Concluído |

## Segurança

| ID | Requisito | Estado |
|---|---|---|
| RT-SEG-01 | Não versionar credenciais, chaves ou dados financeiros reais | Concluído; fixtures fictícias e revisão por busca |
| RT-SEG-02 | Configurar segredos por `--dart-define` ou arquivo ignorado | Concluído; não há segredo obrigatório |
| RT-SEG-03 | Versionar exemplo de configuração sem segredo | Concluído em `config/example.json` |
| RT-SEG-04 | Usar somente HTTPS | Concluído; validação no bootstrap e cleartext bloqueado |
| RT-SEG-05 | Usar armazenamento seguro somente se houver dado sensível | Concluído; preferências não armazenam dados sensíveis |
| RT-SEG-06 | Não registrar informações sensíveis em logs | Concluído; aplicação não possui logs de dados financeiros |
| RT-SEG-07 | Validar entradas do usuário | Concluído em filtros, datas, cursores, IDs e configuração |
| RT-SEG-08 | Gerar release com obfuscação e split debug info | Concluído |

## Qualidade, performance e acessibilidade

| ID | Requisito | Estado |
|---|---|---|
| RQ-01 | Testar domínio, ViewModels e repositórios com mocks | Concluído |
| RQ-02 | Testar widgets principais em loading, vazio e erro | Concluído |
| RQ-03 | Ter ao menos um teste de integração do fluxo principal | Concluído |
| RQ-04 | Atingir 70% de cobertura em domínio e ViewModels | Concluído; 76,60% e 82,05% |
| RQ-05 | Gerar e entregar relatório de cobertura | Concluído em `docs/coverage.md` |
| RQ-06 | Usar listas lazy, `const` e rebuilds controlados | Concluído |
| RQ-07 | Oferecer semântica, contraste e escala de fonte adequados | Concluído |
| RQ-08 | Suportar tema claro e escuro | Concluído |
| RQ-09 | Executar analyze, testes e build em CI | Concluído em `.github/workflows/quality.yml` |

## Entregáveis

| ID | Entregável | Estado |
|---|---|---|
| RE-01 | Repositório Git público com histórico coeso | Concluído |
| RE-02 | APK Android de release | Concluído na GitHub Release e no pacote compactado de entrega |
| RE-03 | README com ambiente, execução, testes e build | Concluído |
| RE-04 | Diagrama de camadas e fluxo de dados | Concluído em `docs/ARCHITECTURE.md` |
| RE-05 | ADRs de estado, cache, erros, trade-offs e limitações | Concluído |
| RE-06 | Testes automatizados e relatório de cobertura | Concluído |
| RE-07 | Configuração de CI versionada | Concluído |

## Diferenciais fora do escopo inicial

Flavors, internacionalização, biometria, certificate pinning,
observabilidade e golden tests só serão avaliados depois de todos os itens
obrigatórios.
