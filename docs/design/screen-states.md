# Estados das telas

## Princípio

Cada tela preserva o último conteúdo válido quando uma atualização falha. Os
estados comunicam situação e ação possível sem depender apenas de cor.

## Estados compartilhados

| Estado | Conteúdo | Ação |
|---|---|---|
| Carregamento inicial | Estrutura estável com indicadores sem valores falsos | Aguardar |
| Sucesso | Dados da fonte local canônica | Navegar, buscar ou filtrar |
| Atualização | Conteúdo anterior visível e progresso não bloqueante | Aguardar ou continuar |
| Vazio | Explicação contextual | Limpar filtros ou atualizar |
| Erro inicial | Mensagem segura e objetiva | Tentar novamente |
| Offline sem cache | Ausência de conexão, sem inventar valores | Tentar novamente |
| Offline com cache | Últimos dados e indicador textual de offline | Atualizar quando possível |
| Cache desatualizado | Conteúdo com instante da última atualização | Atualizar |

## Dashboard

- Oculta o saldo com conteúdo semântico equivalente quando a preferência
  estiver ativa.
- Atualização não remove saldo, gráfico ou transações já conhecidos.
- Falha parcial do gráfico não bloqueia saldo e extrato recente.

## Extrato

- Vazio sem filtros significa que ainda não existem movimentações.
- Vazio com filtros oferece limpar busca e filtros.
- Paginação exibe progresso apenas ao final da lista e preserva itens atuais.
- Falha de próxima página mantém os itens e oferece tentar novamente no rodapé.
- Tipo e status usam texto e ícone, além de cor.

## Detalhes

- Carregamento apresenta indicador central sem valores fictícios.
- Identificador inexistente possui estado próprio e ação de voltar.
- Com cache disponível, o detalhe pode abrir offline com indicação textual.
- A ação de copiar só fica disponível quando o identificador foi carregado.

## Referência de implementação

As referências visuais futuras devem cobrir pelo menos sucesso claro e escuro,
carregamento inicial, vazio, erro e offline com cache. Os arquivos seguem a
convenção do [catálogo de telas](screens/README.md) e os
[tokens semânticos](tokens.md).
