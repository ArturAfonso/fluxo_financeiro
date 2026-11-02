# Roteiro de apresentação técnica

## Demonstração sugerida — 7 minutos

1. Abra o dashboard e mostre saldo, ocultação persistida, troca de mês, totais
   e evolução diária no gráfico. Em um mês completo, destaque que a View agrupa
   os pontos por semana para manter a leitura sem alterar os dados do domínio.
2. Atualize por gesto e explique que o conteúdo conhecido permanece disponível
   diante de falha, acompanhado do aviso de possível desatualização.
3. Abra o extrato, combine tipo, status e período e faça uma busca por
   descrição.
4. Role a lista para demonstrar paginação e abra uma transação.
5. Copie o identificador e volte, destacando a preservação da busca, filtros e
   posição.
6. Alterne entre tema claro e escuro.
7. Encerre mostrando testes, cobertura e CI.

## Arquitetura em uma frase

A View envia intenções ao Cubit, o Cubit coordena casos de uso, o domínio define
regras e contratos, e o repositório sincroniza o mock remoto com o Drift, que é
a fonte local canônica para todas as telas.

## Decisões para defender

- **Cubit:** estados explícitos, pouca cerimônia e testes determinísticos.
- **GetIt:** composição centralizada sem esconder dependências dos construtores.
- **GoRouter:** rotas nomeadas e `StatefulShellRoute` para preservar as abas.
- **Drift:** consultas tipadas, transações atômicas, migrações e paginação.
- **Dio:** cancelamento, timeout e tratamento controlado de HTTP 429.
- **Money em centavos:** evita perda de precisão de `double`.
- **UTC no domínio:** fronteiras temporais previsíveis e conversão local apenas
  na apresentação.
- **Result e Failure:** falhas técnicas não escapam como exceções para a View.

## Trade-offs assumidos

- O backend padrão é simulado porque o desafio não fornece um ledger bancário
  real compatível.
- A sincronização troca o snapshot completo; para grande volume seria indicado
  delta sync ou paginação remota incremental.
- `SharedPreferences` guarda somente tema e visibilidade, nunca dados
  financeiros ou credenciais.
- O APK do repositório usa assinatura de desenvolvimento; uma chave privada de
  distribuição não deve ser versionada.

## Evidências rápidas

- `flutter analyze` sem issues;
- 76 testes automatizados previstos na CI; no host atual, 70 passam e 6 testes
  Drift são ignorados pela ausência da biblioteca nativa SQLite;
- fluxo instrumentado passando no emulador Android;
- domínio com 76,50% e ViewModels com 83,25% de cobertura;
- APK release ofuscado com símbolos separados;
- CI com formatação, análise, testes, cobertura mínima e build Android.
