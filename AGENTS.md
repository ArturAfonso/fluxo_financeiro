# Orientações de contribuição

Este arquivo define como interpretar requisitos, documentação e código do
Fluxo Financeiro.

## Ordem de autoridade

Em caso de contradição, use esta ordem:

1. instrução atual e explícita do responsável pelo projeto;
2. `Teste Flutter (Banco).docx`, especificação original do desafio;
3. documentos oficiais listados em `docs/index.md`;
4. ADRs aceitos;
5. comportamento existente no código e nos testes.

Uma preferência técnica nunca pode substituir um requisito do desafio.

## Ordem de leitura

1. Leia este arquivo.
2. Leia `docs/index.md`.
3. Consulte `docs/requisitos.md` para rastreabilidade.
4. Consulte `docs/ARCHITECTURE.md` antes de alterar estrutura ou dependências.
5. Consulte o ADR relacionado antes de mudar uma decisão aceita.
6. Para interface, consulte `docs/design/`.

## Estado das decisões

- **Obrigatório:** exigido pelo desafio e não pode ser removido.
- **Aceito:** decisão registrada e vigente.
- **Provisório:** permite avançar, mas ainda pode ser revisto.
- **Em avaliação:** alternativas ainda estão sendo comparadas.
- **Futuro:** fora do escopo atual.
- **Referência:** informação sem autoridade normativa.

Não transforme uma escolha provisória ou em avaliação em regra definitiva
sem registrar a decisão.

## Limites do projeto

- O produto é um aplicativo mobile para Android e iOS.
- Não adicionar Web ou plataformas desktop.
- O entregável obrigatório de instalação é um APK Android de release.
- Não usar dados financeiros, credenciais ou chaves reais em fixtures, testes,
  logs ou screenshots.
- Não usar a marca BrasilCard como se este fosse um produto oficial.
- Diferenciais não obrigatórios só entram depois dos requisitos essenciais.

## Arquitetura obrigatória

- Usar MVVM com separação verificável entre apresentação, domínio e dados.
- Views não contêm regras financeiras, acesso a banco ou chamadas HTTP.
- ViewModels expõem estados imutáveis e dependem de casos de uso.
- Casos de uso e entidades de domínio não dependem do Flutter.
- Contratos de repositório pertencem ao domínio; implementações pertencem a
  dados.
- DTOs nunca chegam à interface; mappers convertem DTOs em entidades.
- Exceções de infraestrutura não chegam cruas à View.
- Saldo, totais, extrato e detalhes usam uma única fonte de verdade.
- Valores monetários não usam `double` no domínio.
- Datas são armazenadas e trafegadas em UTC.

A biblioteca de estado, o contêiner de DI, a persistência e o cliente HTTP só
se tornam definitivos por ADR. Não escolher uma ferramenta apenas por hábito.

## Qualidade e entrega

Toda alteração de código deve preservar:

- `dart format --output=none --set-exit-if-changed .`;
- `flutter analyze` sem warnings;
- `flutter test` passando;
- testes de domínio e ViewModel determinísticos;
- links e estados da documentação atualizados quando uma decisão mudar.

Não iniciar outro incremento sem concluir os critérios de aceite do incremento
atual em `docs/plano-implementacao.md`.
