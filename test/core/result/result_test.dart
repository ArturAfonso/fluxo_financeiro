import 'package:fluxo_financeiro/core/errors/failure.dart';
import 'package:fluxo_financeiro/core/result/result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Result', () {
    test('mapeia sucesso sem perder o tipo', () {
      const result = Success(21);

      expect(result.map((value) => value * 2), const Success(42));
    });

    test('preserva falha ao mapear', () {
      const result = FailureResult<int>(OfflineFailure());

      expect(result.map((value) => value * 2), result);
    });

    test('fold executa somente o ramo correspondente', () {
      const result = FailureResult<int>(NetworkFailure());

      final value = result.fold(
        onSuccess: (success) => 'success: $success',
        onFailure: (failure) => failure.code,
      );

      expect(value, 'network');
    });
  });
}
