# Contrato do backend simulado

## Estado

Contrato aceito para implementação. O backend simulado será a fonte dos dados
financeiros fictícios. A CoinGecko pode ser usada apenas como dado complementar
de mercado e nunca como origem do saldo ou das transações da conta, pois sua
API não oferece um extrato bancário.

## Convenções

- transporte exclusivamente HTTPS quando houver servidor remoto;
- JSON em `snake_case`;
- dinheiro como inteiro em centavos, nunca `double`;
- instantes ISO 8601 em UTC, terminados em `Z`;
- valores de `type`: `credit` e `debit`;
- valores de `status`: `completed`, `pending`, `failed` e `reversed`;
- dados estritamente fictícios e identificadores opacos;
- ordenação de transações da mais recente para a mais antiga.

## Snapshot do livro financeiro

`GET /v1/ledger`

```json
{
  "data": {
    "opening_balance_cents": 125000,
    "opening_balance_at": "2026-10-01T00:00:00Z",
    "as_of": "2026-11-01T12:00:00Z",
    "transactions": []
  }
}
```

O snapshot é lido atomicamente. O saldo disponível é calculado no domínio a
partir do saldo de abertura e das transações concluídas até `as_of`.

## Extrato paginado

`GET /v1/transactions`

Parâmetros opcionais:

| Parâmetro | Regra |
|---|---|
| `cursor` | Cursor opaco retornado pela página anterior |
| `limit` | Inteiro entre 1 e 100; padrão 20 |
| `types` | Lista separada por vírgula |
| `statuses` | Lista separada por vírgula |
| `start_at` | Início inclusivo em UTC |
| `end_before` | Fim exclusivo em UTC |
| `query` | Busca normalizada pela descrição |

```json
{
  "data": {
    "items": [
      {
        "id": "tx_01",
        "description": "Compra fictícia",
        "amount_cents": 4590,
        "occurred_at": "2026-10-31T18:30:00Z",
        "type": "debit",
        "status": "completed",
        "metadata": {
          "merchant": "Loja Exemplo"
        }
      }
    ],
    "next_cursor": null
  }
}
```

## Detalhe

`GET /v1/transactions/{transaction_id}` retorna a mesma representação usada
em `items`. Isso impede divergência de valor, status ou descrição entre extrato
e detalhes.

## Falhas

```json
{
  "error": {
    "code": "rate_limit",
    "message": "Limite temporariamente excedido",
    "retry_after_seconds": 30
  }
}
```

O mapper converte respostas em entidades ou falhas tipadas. HTTP 404 vira
`NotFoundFailure`, ausência de conexão vira `OfflineFailure`, HTTP 429 vira
`RateLimitFailure` e payload inválido vira `ParsingFailure`. A mensagem externa
não é exibida diretamente na interface.

## Mapeamento para o domínio

| JSON | Domínio |
|---|---|
| `opening_balance_cents` | `Money.fromCents` |
| `amount_cents` | `Money.fromCents` |
| `occurred_at` | `FinancialTransaction.occurredAt` em UTC |
| `type` | `TransactionType` |
| `status` | `TransactionStatus` |
| `metadata` | Mapa imutável de texto |
| `next_cursor` | `TransactionPage.nextCursor` |

Campos obrigatórios ausentes, enum desconhecido, dinheiro negativo ou data sem
UTC tornam o payload inválido. Campos adicionais podem ser ignorados de forma
compatível ou preservados em `metadata` quando forem úteis ao detalhe.
