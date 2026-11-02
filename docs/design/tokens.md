# Tokens de design

## Estado

**Aceito.** A implementação usa os tokens semânticos do Material 3 e mantém os
dois temas derivados da mesma cor-base.

## Princípios obrigatórios

- suportar tema claro e escuro;
- não comunicar entrada, saída ou status apenas por cor;
- respeitar escala de fonte sem cortar conteúdo essencial;
- usar áreas de toque adequadas e semântica nos controles;
- usar tokens, sem cores e dimensões espalhadas pelos widgets;
- manter contraste verificável nos dois temas.

## Implementação

- `ColorScheme.fromSeed` com base `#175CD3` para claro e escuro;
- superfícies e cores de conteúdo obtidas do `ColorScheme` ativo;
- cards sem elevação e com raio de 20 px;
- campos preenchidos, sem borda visível e com raio de 16 px;
- tipografia responsiva fornecida pelo `TextTheme` do Material 3;
- estados negativos usam `error` e `errorContainer`, acompanhados de sinal,
  ícone e texto;
- estados positivos usam `primary` e `primaryContainer`, acompanhados de sinal,
  ícone e texto.

## Regras financeiras

Entradas e saídas usam combinação de sinal, rótulo, ícone e cor. Status têm
texto visível, evitando depender de interpretação cromática.

## Validações

- cores de conteúdo usam os pares `on*` produzidos pelo Material 3;
- escala de texto de 200% possui teste de widget sem overflow;
- controles possuem tooltip ou rótulo e áreas de toque do Material;
- saldo e transações têm descrições semânticas próprias;
- loading, vazio, erro, offline e retry possuem mensagens textuais.
