import 'package:equatable/equatable.dart';

final class Money extends Equatable implements Comparable<Money> {
  const Money.fromCents(this.cents);

  static const zero = Money.fromCents(0);

  factory Money.fromDecimalString(String value) {
    final match = _decimalPattern.firstMatch(value.trim());
    if (match == null) {
      throw FormatException('Invalid monetary value.', value);
    }

    final isNegative = match.group(1) == '-';
    final majorUnits = int.parse(match.group(2)!);
    final fraction = match.group(3) ?? '';
    final paddedFraction = fraction.padRight(3, '0');
    final minorUnits = int.parse(paddedFraction.substring(0, 2));
    final mustRound = int.parse(paddedFraction.substring(2, 3)) >= 5;
    final absoluteCents = (majorUnits * 100) + minorUnits + (mustRound ? 1 : 0);

    return Money.fromCents(isNegative ? -absoluteCents : absoluteCents);
  }

  static final RegExp _decimalPattern = RegExp(
    r'^([+-])?(\d+)(?:[\.,](\d+))?$',
  );

  final int cents;

  bool get isZero => cents == 0;
  bool get isNegative => cents < 0;
  bool get isPositive => cents > 0;

  Money get absolute => Money.fromCents(cents.abs());

  Money operator +(Money other) => Money.fromCents(cents + other.cents);

  Money operator -(Money other) => Money.fromCents(cents - other.cents);

  Money operator -() => Money.fromCents(-cents);

  @override
  int compareTo(Money other) => cents.compareTo(other.cents);

  String toDecimalString() {
    final absoluteCents = cents.abs();
    final sign = isNegative ? '-' : '';
    final majorUnits = absoluteCents ~/ 100;
    final minorUnits = (absoluteCents % 100).toString().padLeft(2, '0');
    return '$sign$majorUnits.$minorUnits';
  }

  @override
  List<Object?> get props => [cents];

  @override
  String toString() => 'Money(${toDecimalString()})';
}
