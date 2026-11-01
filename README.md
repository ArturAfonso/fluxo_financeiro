# Fluxo Financeiro

Aplicativo mobile em Flutter para consulta de saldo, acompanhamento de entradas
e saídas e exploração de um extrato financeiro. O projeto é desenvolvido como
parte de um desafio técnico e prioriza arquitetura justificável, consistência de
dados, resiliência, testes e acessibilidade.

> **Estado atual:** Incremento 0 concluído. O scaffold Flutter existe para
> Android e iOS, mas as funcionalidades financeiras ainda não foram
> implementadas.

## Baseline

- Flutter 3.41.7 stable.
- Dart 3.11.5.
- Plataformas: Android e iOS.
- Projeto Dart: `fluxo_financeiro`.
- Identificador Android: `br.com.arturafonso.fluxo_financeiro`.
- Bundle identifier iOS: `br.com.arturafonso.fluxoFinanceiro`.
- Arquitetura obrigatória: MVVM com apresentação, domínio e dados.

Web, Windows, Linux e macOS desktop estão deliberadamente fora do escopo.

## Executar o scaffold

```bash
flutter pub get
flutter run
```

## Verificações

```bash
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
```

Quando a implementação estiver pronta, o APK protegido será gerado com:

```bash
flutter build apk --release \
  --obfuscate \
  --split-debug-info=build/symbols/android
```

## Documentação

O ponto de entrada da documentação é [docs/index.md](docs/index.md). Antes de
alterar o projeto, assistentes de IA devem ler [AGENTS.md](AGENTS.md).

- [Requisitos e rastreabilidade](docs/requisitos.md)
- [Arquitetura](docs/ARCHITECTURE.md)
- [Plano de implementação](docs/plano-implementacao.md)
- [Decisões arquiteturais](docs/adr/README.md)
- [Design](docs/design/README.md)

O enunciado original fornecido para o desafio permanece em
[`Teste Flutter (Banco).docx`](Teste%20Flutter%20%28Banco%29.docx).
