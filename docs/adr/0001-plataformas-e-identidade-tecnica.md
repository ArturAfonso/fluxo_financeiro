# ADR 0001 Plataformas e identidade técnica

**Estado:** aceita  
**Data:** 2026-11-01

## Contexto

O desafio solicita um aplicativo mobile e exige um APK Android. Web e desktop
não fazem parte da avaliação. O responsável autorizou Android e iOS e informou o
domínio `arturafonso.com.br`.

## Decisão

- Nome do produto: Fluxo Financeiro.
- Projeto Dart: `fluxo_financeiro`.
- Organização em notação reversa: `br.com.arturafonso`.
- Plataformas geradas: Android e iOS.
- Não gerar Web, Windows, Linux ou macOS desktop.

## Consequências

O repositório permanece focado no escopo mobile. O APK Android é o artefato
obrigatório; a existência do scaffold iOS não cria obrigação de entrega de IPA.
