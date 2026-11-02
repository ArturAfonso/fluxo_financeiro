import 'dart:async';

import 'package:dio/dio.dart';
import 'package:fluxo_financeiro/core/errors/failure.dart';
import 'package:fluxo_financeiro/core/result/result.dart';
import 'package:fluxo_financeiro/features/financial_account/data/datasources/financial_local_data_source.dart';
import 'package:fluxo_financeiro/features/financial_account/data/datasources/financial_remote_data_source.dart';
import 'package:fluxo_financeiro/features/financial_account/data/dtos/ledger_dto.dart';
import 'package:fluxo_financeiro/features/financial_account/data/repositories/financial_repository_impl.dart';
import 'package:fluxo_financeiro/features/financial_account/domain/entities/transaction_page.dart';
import 'package:fluxo_financeiro/features/financial_account/domain/filters/transaction_filter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../data_test_fixtures.dart';

final class MockLocalDataSource extends Mock
    implements FinancialLocalDataSource {}

final class MockRemoteDataSource extends Mock
    implements FinancialRemoteDataSource {}

void main() {
  late MockLocalDataSource local;
  late MockRemoteDataSource remote;
  late DateTime now;
  late FinancialRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(ledgerFixture());
    registerFallbackValue(DateTime.utc(2026));
    registerFallbackValue(
      TransactionQuery(
        filter: TransactionFilter(),
        page: TransactionPageRequest(),
      ),
    );
  });

  setUp(() {
    local = MockLocalDataSource();
    remote = MockRemoteDataSource();
    now = DateTime.utc(2026, 11, 1, 12);
    repository = FinancialRepositoryImpl(
      localDataSource: local,
      remoteDataSource: remote,
      clock: () => now,
    );
  });

  test('usa cache fresco sem acessar a rede', () async {
    final snapshot = ledgerFixture();
    when(local.getLedger).thenAnswer(
      (_) async => CachedLedger(
        snapshot: snapshot,
        cachedAt: now.subtract(const Duration(minutes: 2)),
      ),
    );

    final result = await repository.getLedgerSnapshot();

    final ledger = result.fold(
      onSuccess: (value) => value,
      onFailure: (failure) => throw TestFailure('$failure'),
    );
    expect(ledger.openingBalance, snapshot.openingBalance);
    expect(ledger.lastSynchronizedAt, now.subtract(const Duration(minutes: 2)));
    expect(ledger.isStale, isFalse);
    verify(local.getLedger).called(1);
    verifyNever(
      () => remote.fetchLedger(cancelToken: any(named: 'cancelToken')),
    );
  });

  test('entrega cache antigo quando atualização falha offline', () async {
    final snapshot = ledgerFixture();
    when(local.getLedger).thenAnswer(
      (_) async => CachedLedger(
        snapshot: snapshot,
        cachedAt: now.subtract(const Duration(hours: 1)),
      ),
    );
    when(
      () => remote.fetchLedger(cancelToken: any(named: 'cancelToken')),
    ).thenThrow(
      DioException(
        requestOptions: RequestOptions(),
        type: DioExceptionType.connectionError,
      ),
    );

    final result = await repository.getLedgerSnapshot();

    final ledger = result.fold(
      onSuccess: (value) => value,
      onFailure: (failure) => throw TestFailure('$failure'),
    );
    expect(ledger.openingBalance, snapshot.openingBalance);
    expect(ledger.lastSynchronizedAt, now.subtract(const Duration(hours: 1)));
    expect(ledger.isStale, isTrue);
    verify(
      () => remote.fetchLedger(cancelToken: any(named: 'cancelToken')),
    ).called(1);
  });

  test('preenche cache vazio antes de devolver o snapshot', () async {
    final snapshot = ledgerFixture();
    var reads = 0;
    when(local.getLedger).thenAnswer((_) async {
      reads++;
      return reads == 1
          ? null
          : CachedLedger(snapshot: snapshot, cachedAt: now);
    });
    when(
      () => remote.fetchLedger(cancelToken: any(named: 'cancelToken')),
    ).thenAnswer((_) async => ledgerDtoFixture());
    when(() => local.replaceLedger(any(), any())).thenAnswer((_) async {});

    final result = await repository.getLedgerSnapshot();

    final ledger = result.fold(
      onSuccess: (value) => value,
      onFailure: (failure) => throw TestFailure('$failure'),
    );
    expect(ledger.openingBalance, snapshot.openingBalance);
    expect(ledger.lastSynchronizedAt, now);
    expect(ledger.isStale, isFalse);
    verify(
      () => remote.fetchLedger(cancelToken: any(named: 'cancelToken')),
    ).called(1);
    verify(() => local.replaceLedger(any(), now)).called(1);
  });

  test('consolida refreshes simultâneos na mesma chamada remota', () async {
    final completer = Completer<LedgerDto>();
    when(
      () => remote.fetchLedger(cancelToken: any(named: 'cancelToken')),
    ).thenAnswer((_) => completer.future);
    when(() => local.replaceLedger(any(), any())).thenAnswer((_) async {});

    final first = repository.refresh();
    final second = repository.refresh();
    completer.complete(ledgerDtoFixture());

    expect(identical(first, second), isTrue);
    expect(await first, const Success<void>(null));
    expect(await second, const Success<void>(null));
    verify(
      () => remote.fetchLedger(cancelToken: any(named: 'cancelToken')),
    ).called(1);
  });

  test('cancela refresh obsoleto quando uma atualização o substitui', () async {
    late CancelToken firstToken;
    var calls = 0;
    when(
      () => remote.fetchLedger(cancelToken: any(named: 'cancelToken')),
    ).thenAnswer((invocation) {
      final token = invocation.namedArguments[#cancelToken] as CancelToken;
      calls++;
      if (calls == 1) {
        firstToken = token;
        return token.whenCancel.then<LedgerDto>((error) => throw error);
      }
      return Future.value(ledgerDtoFixture());
    });
    when(() => local.replaceLedger(any(), any())).thenAnswer((_) async {});

    final obsolete = repository.refresh();
    final latest = repository.refresh(replaceInFlight: true);

    expect(firstToken.isCancelled, isTrue);
    expect(
      await obsolete,
      const FailureResult<void>(RequestCancelledFailure()),
    );
    expect(await latest, const Success<void>(null));
    verify(
      () => remote.fetchLedger(cancelToken: any(named: 'cancelToken')),
    ).called(2);
    verify(() => local.replaceLedger(any(), now)).called(1);
  });

  test(
    'converte payload inválido em ParsingFailure sem gravar cache',
    () async {
      when(
        () => remote.fetchLedger(cancelToken: any(named: 'cancelToken')),
      ).thenAnswer((_) async => ledgerDtoFixture(type: 'unknown'));

      final result = await repository.refresh();

      expect(result, const FailureResult<void>(ParsingFailure()));
      verifyNever(() => local.replaceLedger(any(), any()));
    },
  );

  test('converte HTTP 429 esgotado em RateLimitFailure', () async {
    final headers = Headers()..set('retry-after', '30');
    when(
      () => remote.fetchLedger(cancelToken: any(named: 'cancelToken')),
    ).thenThrow(
      DioException.badResponse(
        statusCode: 429,
        requestOptions: RequestOptions(),
        response: Response(
          requestOptions: RequestOptions(),
          statusCode: 429,
          headers: headers,
        ),
      ),
    );

    final result = await repository.refresh();

    expect(
      result,
      const FailureResult<void>(
        RateLimitFailure(retryAfter: Duration(seconds: 30)),
      ),
    );
  });

  test('traduz cursor inválido do cache em ValidationFailure', () async {
    when(local.getLedger).thenAnswer(
      (_) async => CachedLedger(snapshot: ledgerFixture(), cachedAt: now),
    );
    when(
      () => local.getTransactions(any()),
    ).thenThrow(const FormatException('invalid cursor'));
    final query = TransactionQuery(
      filter: TransactionFilter(),
      page: TransactionPageRequest(),
    );

    final result = await repository.getTransactions(query);

    expect(
      result.fold(onSuccess: (_) => null, onFailure: (failure) => failure),
      const ValidationFailure(field: 'cursor'),
    );
  });

  test('propaga cache desatualizado para a página de transações', () async {
    final cachedAt = now.subtract(const Duration(hours: 1));
    when(local.getLedger).thenAnswer(
      (_) async => CachedLedger(snapshot: ledgerFixture(), cachedAt: cachedAt),
    );
    when(
      () => remote.fetchLedger(cancelToken: any(named: 'cancelToken')),
    ).thenThrow(
      DioException(
        requestOptions: RequestOptions(),
        type: DioExceptionType.connectionError,
      ),
    );
    when(
      () => local.getTransactions(any()),
    ).thenAnswer((_) async => TransactionPage(items: const []));

    final result = await repository.getTransactions(
      TransactionQuery(
        filter: TransactionFilter(),
        page: TransactionPageRequest(),
      ),
    );

    final page = result.fold(
      onSuccess: (value) => value,
      onFailure: (failure) => throw TestFailure('$failure'),
    );
    expect(page.isStale, isTrue);
    expect(page.lastSynchronizedAt, cachedAt);
  });

  test('retorna NotFoundFailure para detalhe inexistente', () async {
    when(local.getLedger).thenAnswer(
      (_) async => CachedLedger(snapshot: ledgerFixture(), cachedAt: now),
    );
    when(
      () => local.getTransactionById('missing'),
    ).thenAnswer((_) async => null);

    final result = await repository.getTransactionById('missing');

    expect(
      result.fold(onSuccess: (_) => null, onFailure: (failure) => failure),
      const NotFoundFailure(resource: 'transaction', identifier: 'missing'),
    );
  });
}
