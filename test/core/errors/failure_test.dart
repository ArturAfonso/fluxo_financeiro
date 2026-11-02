import 'package:fluxo_financeiro/core/errors/failure.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('falhas possuem códigos estáveis e igualdade por seus dados', () {
    expect(const NetworkFailure().code, 'network');
    expect(const OfflineFailure().code, 'offline');
    expect(const CacheFailure().code, 'cache');
    expect(const ParsingFailure().code, 'parsing');
    expect(const UnexpectedFailure().code, 'unexpected');
    expect(
      const RateLimitFailure(retryAfter: Duration(seconds: 30)),
      const RateLimitFailure(retryAfter: Duration(seconds: 30)),
    );
    expect(
      const NotFoundFailure(resource: 'transaction', identifier: 'tx-1'),
      const NotFoundFailure(resource: 'transaction', identifier: 'tx-1'),
    );
    expect(
      const ValidationFailure(field: 'transactionId'),
      const ValidationFailure(field: 'transactionId'),
    );
  });
}
