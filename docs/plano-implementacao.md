# Plano de implementação

O trabalho será dividido em incrementos pequenos, demonstráveis e verificáveis.

## Incremento 0 - Scaffold mobile

**Estado:** concluído.

- criar projeto Flutter apenas para Android e iOS;
- registrar organização e nome do aplicativo;
- documentar baseline do Flutter e Dart;
- criar a estrutura inicial da documentação do projeto;
- validar analyze e teste inicial.

## Incremento 1 - Contratos e decisões

- concluir matriz de rastreabilidade;
- registrar ADRs de estado, DI, navegação, persistência e dados remotos;
- definir modelo de dinheiro, transação, status, filtros e paginação;
- definir estados e referências visuais das telas;
- definir contrato do backend simulado.

**Aceite:** nenhuma decisão obrigatória permanece implícita e os contratos
podem ser testados sem widgets.

## Incremento 2 - Domínio financeiro

- implementar value object monetário;
- implementar entidades e filtros;
- implementar casos de uso de saldo, totais, extrato e detalhes;
- cobrir zero, grandes valores, estornos, arredondamento e fuso horário.

**Aceite:** testes de domínio passam, sem imports do Flutter ou infraestrutura.

## Incremento 3 - Dados, cache e resiliência

- implementar DTOs, mappers e parsing defensivo;
- implementar datasource remoto ou mock;
- implementar cache local e repositório;
- implementar paginação, deduplicação, cancelamento e backoff;
- testar fallback offline, expiração e HTTP 429.

**Aceite:** saldo, totais, lista e detalhe derivam da mesma fonte de verdade.

## Incremento 4 - Apresentação MVVM

- implementar tema claro e escuro;
- implementar navegação nomeada;
- implementar dashboard, extrato e detalhes;
- implementar loading, vazio, erro, retry, offline e dados desatualizados;
- preservar filtros e posição ao voltar;
- validar acessibilidade e escala de fonte.

**Aceite:** widgets não contêm regras financeiras ou acesso direto a dados.

## Incremento 5 - Qualidade e entrega

- completar testes unitários, de widget e integração;
- medir e impor cobertura mínima de domínio e ViewModels;
- configurar CI;
- revisar segurança e logs;
- concluir README e ADRs;
- gerar APK ofuscado e símbolos separados;
- ensaiar a apresentação técnica.

**Aceite:** todos os itens de `requisitos.md` possuem evidência e nenhum warning
permanece.
