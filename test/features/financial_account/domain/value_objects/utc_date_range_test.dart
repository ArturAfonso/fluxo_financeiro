import 'package:fluxo_financeiro/features/financial_account/domain/value_objects/utc_date_range.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UtcDateRange', () {
    test('inclui o início e exclui o fim', () {
      final range = UtcDateRange(
        startInclusive: DateTime.utc(2026, 1, 1, 3),
        endExclusive: DateTime.utc(2026, 1, 2, 3),
      );

      expect(range.contains(DateTime.utc(2026, 1, 1, 3)), isTrue);
      expect(range.contains(DateTime.utc(2026, 1, 2, 2, 59, 59, 999)), isTrue);
      expect(range.contains(DateTime.utc(2026, 1, 2, 3)), isFalse);
    });

    test('rejeita datas locais e intervalo vazio', () {
      expect(
        () => UtcDateRange(
          startInclusive: DateTime(2026),
          endExclusive: DateTime.utc(2026, 1, 2),
        ),
        throwsArgumentError,
      );
      expect(
        () => UtcDateRange(
          startInclusive: DateTime.utc(2026),
          endExclusive: DateTime.utc(2026),
        ),
        throwsArgumentError,
      );
    });
  });
}
