# Fluxo Financeiro

Aplicativo Flutter mobile para consulta de saldo, acompanhamento mensal de
entradas e saídas e exploração de extrato financeiro. A implementação prioriza
consistência dos dados, resiliência offline, testabilidade e acessibilidade.

O projeto está funcional para Android e iOS. Web e plataformas desktop estão
deliberadamente fora do escopo.

## Funcionalidades

- saldo disponível com preferência persistida de visibilidade;
- totais mensais e gráfico de evolução diária, com agrupamento semanal em
  meses completos;
- transações recentes e extrato completo;
- busca com debounce e filtros combináveis por tipo, status e período;
- paginação por cursor e agrupamento por data;
- detalhes e cópia do identificador da transação;
- cache local, pull-to-refresh e fallback sinalizado para o último snapshot;
- temas claro e escuro com escolha persistida;
- estados de loading, vazio, erro, offline e retry.

## Ambiente

- Flutter 3.41.7 stable;
- Dart 3.11.5;
- Android SDK compatível com o Flutter 3.41.7;
- Xcode e CocoaPods para execução no iOS;
- `libsqlite3` no host Linux para os testes do Drift.

Identificadores:

- projeto Dart: `fluxo_financeiro`;
- Android: `br.com.arturafonso.fluxo_financeiro`;
- iOS: `br.com.arturafonso.fluxoFinanceiro`.

## Executar

```bash
flutter pub get
flutter run
```

O aplicativo usa um backend simulado local por padrão, portanto não precisa de
credenciais nem de conexão com um serviço financeiro real.

Para apontar para um endpoint HTTPS compatível com o contrato documentado:

```bash
flutter run \
  --dart-define=USE_MOCK_API=false \
  --dart-define=API_BASE_URL=https://api.example.com
```

Também é possível copiar `config/example.json` para `config/local.json` e usar:

```bash
flutter run --dart-define-from-file=config/local.json
```

`config/local.json` é ignorado pelo Git. A URL é validada no bootstrap e HTTP ou
credenciais embutidas na URL são rejeitados.

## Arquitetura

O projeto aplica MVVM com organização por feature:

```text
View → Cubit/ViewModel → Use case → Repository
                                      ├── Drift local
                                      └── Dio remoto/mock
```

- `presentation`: telas, Cubits e estados imutáveis;
- `domain`: entidades, casos de uso, contratos, dinheiro e datas;
- `data`: DTOs, mappers, datasources e implementação do repositório;
- `app`: roteamento, tema, configuração e composição das dependências.

Valores monetários permanecem em centavos inteiros no domínio. Datas são
armazenadas em UTC e convertidas para o fuso local somente na apresentação.
Dashboard, extrato e detalhes consultam o mesmo snapshot persistido no Drift.

A explicação completa está em [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) e as
decisões estão registradas em [docs/adr/README.md](docs/adr/README.md).

## Qualidade

```bash
dart format --output=none --set-exit-if-changed lib test integration_test tool
flutter analyze
flutter test --coverage
dart run tool/check_coverage.dart coverage/lcov.info
```

Cobertura medida:

- domínio: 76,50%;
- ViewModels: 83,25%;
- mínimo automatizado: 70% para cada grupo.

O fluxo dashboard → extrato → busca → detalhes → retorno é coberto por teste de
widget integrado e por `integration_test`. Com um dispositivo Android ou iOS
conectado:

```bash
flutter test integration_test/app_flow_test.dart -d <device-id>
```

A CI executa formatação, análise estática, testes, cobertura mínima e build
Android. Em Linux, a biblioteca `libsqlite3` permite executar também os testes
reais do cache em memória.

## Build Android

Build debug:

```bash
flutter build apk --debug
```

Build release ofuscado com símbolos separados:

```bash
flutter build apk --release \
  --obfuscate \
  --split-debug-info=build/symbols/android
```

O repositório não contém keystore privado. O APK local de avaliação usa a
assinatura de desenvolvimento configurada pelo template; uma publicação real
deve receber assinatura de produção fora do repositório.

## Documentação

- [Requisitos e rastreabilidade](docs/requisitos.md)
- [Arquitetura e fluxo de dados](docs/ARCHITECTURE.md)
- [Contrato do backend simulado](docs/data-contract.md)
- [Plano de implementação](docs/plano-implementacao.md)
- [Relatório de cobertura](docs/coverage.md)
- [Roteiro de apresentação técnica](docs/apresentacao-tecnica.md)
- [Decisões arquiteturais](docs/adr/README.md)
- [Estados e navegação](docs/design/README.md)

O enunciado original permanece em
[`Teste Flutter (Banco).docx`](Teste%20Flutter%20%28Banco%29.docx).

## Limitações conhecidas

- o backend padrão é uma fixture local e não representa uma instituição real;
- a sincronização substitui um snapshot completo, adequada ao volume do teste;
- o APK de avaliação não inclui uma chave privada de distribuição;
- testes instrumentados dependem de um dispositivo ou emulador.
