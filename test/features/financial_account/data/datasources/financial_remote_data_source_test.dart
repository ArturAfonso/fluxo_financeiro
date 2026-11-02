import 'dart:collection';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:fluxo_financeiro/core/network/retry_policy.dart';
import 'package:fluxo_financeiro/features/financial_account/data/datasources/financial_remote_data_source.dart';
import 'package:fluxo_financeiro/features/financial_account/data/datasources/mock_financial_api_adapter.dart';
import 'package:flutter_test/flutter_test.dart';

import '../data_test_fixtures.dart';

void main() {
  test('mock local percorre Dio e retorna o ledger fictício', () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://mock.invalid'))
      ..httpClientAdapter = MockFinancialApiAdapter();
    final dataSource = DioFinancialRemoteDataSource(dio: dio);

    final ledger = await dataSource.fetchLedger();

    expect(ledger.transactions, hasLength(6));
    expect(ledger.openingBalanceCents, 250000);
    dio.close(force: true);
  });

  test('propaga cancelamento de requisição obsoleta', () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://mock.invalid'))
      ..httpClientAdapter = MockFinancialApiAdapter();
    final dataSource = DioFinancialRemoteDataSource(dio: dio);
    final cancelToken = CancelToken();

    final request = dataSource.fetchLedger(cancelToken: cancelToken);
    cancelToken.cancel('request replaced');

    await expectLater(
      request,
      throwsA(
        isA<DioException>().having(
          CancelToken.isCancel,
          'is cancelled',
          isTrue,
        ),
      ),
    );
    dio.close(force: true);
  });

  test('respeita Retry-After no HTTP 429 antes de repetir', () async {
    final adapter = SequenceAdapter([
      () => ResponseBody.fromString(
        jsonEncode({'error': 'rate_limit'}),
        429,
        headers: {
          Headers.contentTypeHeader: ['application/json'],
          'retry-after': ['2'],
        },
      ),
      () => _successResponse(),
    ]);
    final delays = <Duration>[];
    final dio = Dio(BaseOptions(baseUrl: 'https://mock.invalid'))
      ..httpClientAdapter = adapter;
    final dataSource = DioFinancialRemoteDataSource(
      dio: dio,
      retryPolicy: RetryPolicy(
        delay: (duration) async => delays.add(duration),
        jitter: (_) => Duration.zero,
      ),
    );

    final ledger = await dataSource.fetchLedger();

    expect(ledger.transactions, hasLength(1));
    expect(adapter.requests, 2);
    expect(delays, [const Duration(seconds: 2)]);
  });

  test('aplica backoff exponencial e limita tentativas em erro 500', () async {
    final adapter = SequenceAdapter([
      () => ResponseBody.fromString('{}', 500),
      () => ResponseBody.fromString('{}', 500),
      () => ResponseBody.fromString('{}', 500),
    ]);
    final delays = <Duration>[];
    final dio = Dio(BaseOptions(baseUrl: 'https://mock.invalid'))
      ..httpClientAdapter = adapter;
    final dataSource = DioFinancialRemoteDataSource(
      dio: dio,
      retryPolicy: RetryPolicy(
        delay: (duration) async => delays.add(duration),
        jitter: (_) => Duration.zero,
      ),
    );

    await expectLater(dataSource.fetchLedger(), throwsA(isA<DioException>()));

    expect(adapter.requests, 3);
    expect(delays, [
      const Duration(milliseconds: 500),
      const Duration(seconds: 1),
    ]);
  });

  test('não repete erro 400 não transitório', () async {
    final adapter = SequenceAdapter([() => ResponseBody.fromString('{}', 400)]);
    final dio = Dio(BaseOptions(baseUrl: 'https://mock.invalid'))
      ..httpClientAdapter = adapter;
    final dataSource = DioFinancialRemoteDataSource(
      dio: dio,
      retryPolicy: RetryPolicy(delay: (_) async {}),
    );

    await expectLater(dataSource.fetchLedger(), throwsA(isA<DioException>()));

    expect(adapter.requests, 1);
  });
}

ResponseBody _successResponse() {
  return ResponseBody.fromString(
    jsonEncode(ledgerJsonFixture()),
    200,
    headers: {
      Headers.contentTypeHeader: ['application/json'],
    },
  );
}

final class SequenceAdapter implements HttpClientAdapter {
  SequenceAdapter(Iterable<ResponseBody Function()> responses)
    : _responses = Queue.of(responses);

  final Queue<ResponseBody Function()> _responses;
  int requests = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests++;
    if (_responses.isEmpty) {
      throw StateError('No scripted response.');
    }
    return _responses.removeFirst()();
  }

  @override
  void close({bool force = false}) {}
}
