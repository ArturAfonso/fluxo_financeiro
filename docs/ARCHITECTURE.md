# Arquitetura do aplicativo

## 1. Objetivo

Definir uma arquitetura MVVM verificável, simples de explicar e capaz de manter
saldo, totais, extrato e detalhes coerentes sob cache, paginação e falhas de
rede.

## 2. Estilo arquitetural

O projeto usará organização por feature com camadas internas obrigatórias:

```text
View
  -> ViewModel
      -> Use case
          -> Repository contract
              -> Repository implementation
                  -> remote datasource
                  -> local datasource
```

Dependências apontam para dentro. O domínio não conhece Flutter, banco, HTTP ou
classes de apresentação.

## 3. Estrutura planejada de `lib`

```text
lib/
├── app/
│   ├── app.dart
│   ├── bootstrap.dart
│   ├── di/
│   ├── router/
│   └── theme/
├── core/
│   ├── errors/
│   ├── result/
│   ├── network/
│   ├── persistence/
│   └── utils/
└── features/
    └── financial_account/
        ├── domain/
        │   ├── entities/
        │   ├── repositories/
        │   ├── use_cases/
        │   └── value_objects/
        ├── data/
        │   ├── datasources/
        │   ├── dtos/
        │   ├── mappers/
        │   └── repositories/
        └── presentation/
            ├── dashboard/
            ├── statement/
            └── transaction_details/
```

Pastas só serão criadas quando contiverem uma responsabilidade real.

## 4. Responsabilidades

### View

- renderiza estados;
- encaminha intenções do usuário ao ViewModel;
- possui apenas estado efêmero estritamente visual;
- não calcula saldo, não consulta banco e não faz HTTP.

### ViewModel

- coordena casos de uso;
- publica estado imutável;
- controla loading, vazio, sucesso, erro e offline;
- preserva filtros, busca, paginação e posição necessária;
- converte resultados do domínio em informação pronta para a View.

### Domínio

- contém entidades e value objects financeiros;
- contém casos de uso e regras de cálculo;
- define contratos de repositório;
- representa falhas sem depender de exceções de infraestrutura.

### Dados

- implementa repositórios;
- integra fontes remotas e locais;
- valida e converte DTOs por mappers;
- aplica cache, paginação, deduplicação, cancelamento e retry;
- traduz falhas técnicas para o modelo de erros do domínio.

## 5. Fonte única de verdade

A estratégia pretendida é observar a fonte local e fazer a sincronização
remota atualizar essa fonte atomicamente. Dashboard, extrato e detalhes devem
ler o mesmo conjunto canônico de entidades. A decisão final de persistência e a
política de expiração serão registradas por ADR.

## 6. Dinheiro e datas

- Valores monetários serão representados por value object baseado em unidade
  mínima inteira ou decimal seguro.
- Conversão e arredondamento pertencem ao domínio ou ao mapper, nunca ao widget.
- Datas externas e persistidas serão UTC.
- Conversão para fuso local e formatação pt-BR ocorrerão na fronteira de
  apresentação.

## 7. Navegação

Dashboard, extrato e detalhe usarão rotas nomeadas. A rota de detalhe receberá
um identificador, não uma entidade completa. Isso evita estado duplicado e faz
o detalhe consultar a mesma fonte de verdade.

## 8. Decisões pendentes

- biblioteca de ViewModel/estado;
- ferramenta de DI;
- banco local;
- cliente HTTP;
- formato do mock remoto;
- estratégia de paginação;
- política de expiração e sincronização;
- modelagem final de `Result` e falhas.

Essas escolhas devem maximizar clareza, testabilidade e capacidade de defesa,
sem adicionar camadas ou padrões sem responsabilidade concreta.
