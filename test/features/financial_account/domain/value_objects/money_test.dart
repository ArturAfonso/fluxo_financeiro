import 'package:fluxo_financeiro/features/financial_account/domain/value_objects/money.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Money', () {
    test('representa zero e valores grandes em centavos inteiros', () {
      const largeValue = 9000000000000000000;

      expect(Money.zero.cents, 0);
      expect(const Money.fromCents(largeValue).cents, largeValue);
    });

    test('converte texto decimal sem usar double', () {
      expect(Money.fromDecimalString('10').cents, 1000);
      expect(Money.fromDecimalString('10,1').cents, 1010);
      expect(Money.fromDecimalString('-0.99').cents, -99);
    });

    test('arredonda a terceira casa para longe de zero', () {
      expect(Money.fromDecimalString('10.004').cents, 1000);
      expect(Money.fromDecimalString('10.005').cents, 1001);
      expect(Money.fromDecimalString('-10.005').cents, -1001);
    });

    test('rejeita texto monetário inválido', () {
      expect(() => Money.fromDecimalString('R\$ 10,00'), throwsFormatException);
      expect(() => Money.fromDecimalString('10,'), throwsFormatException);
    });

    test('soma e subtrai preservando precisão', () {
      const first = Money.fromCents(1234);
      const second = Money.fromCents(99);

      expect(first + second, const Money.fromCents(1333));
      expect(first - second, const Money.fromCents(1135));
      expect(-second, const Money.fromCents(-99));
      expect(second.absolute, second);
      expect(const Money.fromCents(-99).absolute, second);
      expect(const Money.fromCents(-99).toDecimalString(), '-0.99');
    });
  });
}
