# ADR 0002 MVVM com camadas

**Estado:** aceita  
**Data:** 2026-11-01

## Contexto

O enunciado exige MVVM e separação clara entre apresentação, domínio e dados.
A avaliação atribui o maior peso individual a arquitetura e design.

## Decisão

Usar MVVM organizado por feature, com:

- View e ViewModel na apresentação;
- entidades, value objects, casos de uso e contratos no domínio;
- datasources, DTOs, mappers e implementações de repositório em dados;
- dependências invertidas por contratos do domínio.

## Consequências

- Views permanecem simples e testáveis.
- Regras financeiras podem ser testadas sem Flutter.
- Bibliotecas de estado e DI continuam substituíveis.
- A estrutura possui mais arquivos que um aplicativo simples, mas cada camada é
  exigida pelo desafio e deve conter responsabilidade concreta.
