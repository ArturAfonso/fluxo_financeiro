# Tokens de design

## Estado

**Provisório.** A estrutura semântica está aceita; valores finais dependem dos
primeiros mockups e da validação de contraste.

## Princípios obrigatórios

- suportar tema claro e escuro;
- não comunicar entrada, saída ou status apenas por cor;
- respeitar escala de fonte sem cortar conteúdo essencial;
- usar áreas de toque adequadas e semântica nos controles;
- usar tokens, sem cores e dimensões espalhadas pelos widgets;
- manter contraste verificável nos dois temas.

## Grupos de tokens planejados

- `background`, `surface` e `surfaceContainer`;
- `foreground` e `mutedForeground`;
- `primary`, `secondary` e respectivos contrastes;
- `positive`, `negative`, `warning`, `info` e `disabled`;
- `border`, `divider`, `focus` e `shadow`;
- escala tipográfica;
- espaçamento, raios, elevação e movimento.

## Regras financeiras

Entradas e saídas usarão combinação de sinal, rótulo, ícone e cor. Status
terão texto visível, evitando depender de interpretação cromática.

## Validações pendentes

- paleta e tipografia finais;
- contraste WCAG dos pares principais;
- comportamento com escala de texto ampliada;
- gráfico legível nos dois temas;
- estados de foco, erro, offline e dados desatualizados.
