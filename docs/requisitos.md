# Requisitos e rastreabilidade

Este catálogo traduz o enunciado original em itens verificáveis. O DOCX continua
sendo a autoridade superior. Cada requisito deverá apontar, antes da entrega,
para sua implementação, seus testes e sua documentação.

## Funcionais

| ID | Requisito | Estado |
|---|---|---|
| RF-DASH-01 | Exibir saldo disponível | Pendente |
| RF-DASH-02 | Ocultar e exibir saldo, mantendo a preferência entre sessões | Pendente |
| RF-DASH-03 | Exibir entradas e saídas do período selecionado | Pendente |
| RF-DASH-04 | Exibir gráfico simples de evolução | Pendente |
| RF-DASH-05 | Exibir transações recentes e acesso ao extrato completo | Pendente |
| RF-EXT-01 | Listar descrição, data, valor e status | Pendente |
| RF-EXT-02 | Diferenciar entradas e saídas sem depender apenas de cor | Pendente |
| RF-EXT-03 | Combinar filtros por tipo, status e período | Pendente |
| RF-EXT-04 | Permitir intervalo de datas personalizado | Pendente |
| RF-EXT-05 | Buscar por descrição com debounce | Pendente |
| RF-EXT-06 | Paginar por scroll, página ou cursor | Pendente |
| RF-EXT-07 | Agrupar transações por data | Pendente |
| RF-EXT-08 | Preservar filtros e posição após abrir detalhes e voltar | Pendente |
| RF-EXT-09 | Abrir detalhes por rota nomeada | Pendente |
| RF-DET-01 | Exibir identificador, descrição, valor, data/hora, tipo, status e metadados | Pendente |
| RF-DET-02 | Copiar o identificador da transação | Pendente |
| RF-DET-03 | Manter apresentação consistente com o extrato | Pendente |

## Dados e resiliência

| ID | Requisito | Estado |
|---|---|---|
| RD-01 | Consumir a API indicada e/ou backend simulado | Pendente |
| RD-02 | Documentar o mapeamento entre resposta externa e domínio | Pendente |
| RD-03 | Estados de carregamento, atualização, vazio, erro e offline | Pendente |
| RD-04 | Pull-to-refresh | Pendente |
| RD-05 | Cache dos últimos dados conhecidos | Pendente |
| RD-06 | Sinalizar dados possivelmente desatualizados | Pendente |
| RD-07 | Deduplicar chamadas equivalentes | Pendente |
| RD-08 | Cancelar requisições obsoletas | Pendente |
| RD-09 | Tratar HTTP 429 com retentativa e backoff exponencial | Pendente |
| RD-10 | Garantir fonte única de verdade entre todas as telas | Pendente |
| RD-11 | Fazer parsing defensivo das respostas | Pendente |

## Arquitetura e código

| ID | Requisito | Estado |
|---|---|---|
| RT-ARQ-01 | Usar Flutter stable e Dart com null safety | Scaffold |
| RT-ARQ-02 | Documentar versões no README | Concluído |
| RT-ARQ-03 | Aplicar MVVM com View e ViewModel reconhecíveis | Pendente |
| RT-ARQ-04 | Separar apresentação, domínio e dados | Pendente |
| RT-ARQ-05 | Manter entidades, casos de uso e contratos no domínio | Pendente |
| RT-ARQ-06 | Manter datasources, DTOs e mappers em dados | Pendente |
| RT-ARQ-07 | Aplicar injeção e inversão de dependência | Pendente |
| RT-ARQ-08 | Usar estados imutáveis e justificar a biblioteca escolhida | Pendente |
| RT-ARQ-09 | Modelar erros com Result/Either ou hierarquia equivalente | Pendente |
| RT-ARQ-10 | Manter lint rigoroso e zero warnings | Scaffold |

## Integridade financeira e temporal

| ID | Requisito | Estado |
|---|---|---|
| RT-FIN-01 | Não usar `double` para dinheiro no domínio | Pendente |
| RT-FIN-02 | Usar centavos inteiros ou tipo decimal | Pendente |
| RT-FIN-03 | Formatar moeda e datas em pt-BR | Pendente |
| RT-FIN-04 | Manter cálculos de saldo e totais no domínio | Pendente |
| RT-FIN-05 | Cobrir zero, grandes valores, arredondamento e virada de dia | Pendente |
| RT-FIN-06 | Armazenar e trafegar datas em UTC | Pendente |
| RT-FIN-07 | Exibir datas no fuso local | Pendente |

## Segurança

| ID | Requisito | Estado |
|---|---|---|
| RT-SEG-01 | Não versionar credenciais, chaves ou dados financeiros reais | Pendente |
| RT-SEG-02 | Configurar segredos por `--dart-define` ou arquivo ignorado | Pendente |
| RT-SEG-03 | Versionar exemplo de configuração sem segredo | Pendente |
| RT-SEG-04 | Usar somente HTTPS | Pendente |
| RT-SEG-05 | Usar armazenamento seguro somente se houver dado sensível | Pendente |
| RT-SEG-06 | Não registrar informações sensíveis em logs | Pendente |
| RT-SEG-07 | Validar entradas do usuário | Pendente |
| RT-SEG-08 | Gerar release com obfuscação e split debug info | Pendente |

## Qualidade, performance e acessibilidade

| ID | Requisito | Estado |
|---|---|---|
| RQ-01 | Testar domínio, ViewModels e repositórios com mocks | Pendente |
| RQ-02 | Testar widgets principais em loading, vazio e erro | Pendente |
| RQ-03 | Ter ao menos um teste de integração do fluxo principal | Pendente |
| RQ-04 | Atingir 70% de cobertura em domínio e ViewModels | Pendente |
| RQ-05 | Gerar e entregar relatório de cobertura | Pendente |
| RQ-06 | Usar listas lazy, `const` e rebuilds controlados | Pendente |
| RQ-07 | Oferecer semântica, contraste e escala de fonte adequados | Pendente |
| RQ-08 | Suportar tema claro e escuro | Scaffold inicial |
| RQ-09 | Executar analyze, testes e build em CI | Pendente |

## Entregáveis

| ID | Entregável | Estado |
|---|---|---|
| RE-01 | Repositório Git público com histórico coeso | Pendente |
| RE-02 | APK Android de release | Pendente |
| RE-03 | README com ambiente, execução, testes e build | Inicial |
| RE-04 | Diagrama de camadas e fluxo de dados | Pendente |
| RE-05 | ADRs de estado, cache, erros, trade-offs e limitações | Inicial |
| RE-06 | Testes automatizados e relatório de cobertura | Pendente |
| RE-07 | Configuração de CI versionada | Pendente |

## Diferenciais fora do escopo inicial

Flavors, internacionalização, biometria, certificate pinning,
observabilidade e golden tests só serão avaliados depois de todos os itens
obrigatórios.
