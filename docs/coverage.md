# Cobertura de testes

Medição realizada em 2026-11-02 com Flutter 3.41.7 e Dart 3.11.5.

| Grupo | Linhas cobertas | Linhas válidas | Cobertura | Mínimo |
|---|---:|---:|---:|---:|
| Domínio financeiro | 180 | 235 | 76,60% | 70% |
| ViewModels (`Cubit`) | 160 | 195 | 82,05% | 70% |

## Reprodução

```bash
flutter test --coverage
dart run tool/check_coverage.dart coverage/lcov.info
```

O verificador considera todos os arquivos em
`lib/features/financial_account/domain/` e todos os arquivos terminados em
`_cubit.dart`. A execução falha separadamente se qualquer grupo ficar abaixo de
70%, impedindo que uma média global esconda uma camada sem testes suficientes.

Os testes cobrem domínio financeiro, ViewModels, repositório, parsing, retry,
cache Drift, widgets, acessibilidade e o fluxo principal de navegação.
