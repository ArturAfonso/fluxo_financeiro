import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

final class MockFinancialApiAdapter implements HttpClientAdapter {
  bool _closed = false;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (_closed) {
      throw StateError('Adapter is closed.');
    }
    if (cancelFuture != null) {
      var cancelled = false;
      cancelFuture.then((_) => cancelled = true);
      await Future<void>.delayed(const Duration(milliseconds: 80));
      if (cancelled) {
        throw DioException.requestCancelled(
          requestOptions: options,
          reason: 'Mock request cancelled.',
        );
      }
    }
    if (options.method == 'GET' && options.path == '/v1/ledger') {
      return ResponseBody.fromString(
        jsonEncode(_ledgerFixture),
        200,
        headers: {
          Headers.contentTypeHeader: ['application/json; charset=utf-8'],
        },
      );
    }
    return ResponseBody.fromString(
      jsonEncode({
        'error': {'code': 'not_found', 'message': 'Endpoint inexistente'},
      }),
      404,
      headers: {
        Headers.contentTypeHeader: ['application/json; charset=utf-8'],
      },
    );
  }

  @override
  void close({bool force = false}) {
    _closed = true;
  }
}

const _ledgerFixture = {
  'data': {
    'opening_balance_cents': 250000,
    'opening_balance_at': '2026-10-01T00:00:00Z',
    'as_of': '2026-11-02T12:00:00Z',
    'transactions': [
      {
        'id': 'tx_006',
        'description': 'Transferência recebida',
        'amount_cents': 180000,
        'occurred_at': '2026-11-01T10:30:00Z',
        'type': 'credit',
        'status': 'completed',
        'metadata': {'sender': 'Cliente Exemplo'},
      },
      {
        'id': 'tx_005',
        'description': 'Compra no mercado',
        'amount_cents': 24890,
        'occurred_at': '2026-11-02T10:15:00Z',
        'type': 'debit',
        'status': 'completed',
        'metadata': {'merchant': 'Mercado Fictício'},
      },
      {
        'id': 'tx_004',
        'description': 'Pagamento de serviço',
        'amount_cents': 7990,
        'occurred_at': '2026-10-30T14:00:00Z',
        'type': 'debit',
        'status': 'pending',
        'metadata': {'category': 'Serviços'},
      },
      {
        'id': 'tx_003',
        'description': 'Compra estornada',
        'amount_cents': 12500,
        'occurred_at': '2026-10-29T09:15:00Z',
        'type': 'debit',
        'status': 'reversed',
        'metadata': {'reason': 'Cancelamento fictício'},
      },
      {
        'id': 'tx_002',
        'description': 'Pagamento recusado',
        'amount_cents': 4590,
        'occurred_at': '2026-10-28T21:20:00Z',
        'type': 'debit',
        'status': 'failed',
        'metadata': {'reason': 'Saldo temporariamente indisponível'},
      },
      {
        'id': 'tx_001',
        'description': 'Depósito fictício',
        'amount_cents': 50000,
        'occurred_at': '2026-10-15T12:00:00Z',
        'type': 'credit',
        'status': 'completed',
        'metadata': {'channel': 'Mock local'},
      },
    ],
  },
};
