# Tokens de design

## Estado

**Aceito.** A implementação usa tokens semânticos do Material 3 e mantém uma
identidade consistente em verde-petróleo e lima nos temas claro e escuro.

## Princípios obrigatórios

- suportar tema claro e escuro;
- não comunicar entrada, saída ou status apenas por cor;
- respeitar escala de fonte sem cortar conteúdo essencial;
- usar áreas de toque adequadas e semântica nos controles;
- concentrar a paleta principal no tema e reservar cores locais para semânticas
  financeiras específicas;
- manter contraste verificável nos dois temas.

## Implementação

- verde-petróleo `#003B32` nas superfícies de destaque e ações do tema claro;
- lima `#C6F36A` em seleção, foco e entradas no tema escuro;
- fundos `#F4F8F5` no tema claro e `#001E1A` no escuro;
- superfícies e cores de conteúdo obtidas do `ColorScheme` ativo;
- cards sem elevação e com raio de 22 px;
- campos preenchidos, borda de estado e raio de 16 px;
- tipografia responsiva fornecida pelo `TextTheme` do Material 3;
- estados negativos ou desatualizados usam pares de container e conteúdo com
  sinal, ícone e texto;
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
