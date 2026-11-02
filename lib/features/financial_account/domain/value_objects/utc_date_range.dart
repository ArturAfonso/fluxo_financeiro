import 'package:equatable/equatable.dart';

final class UtcDateRange extends Equatable {
  UtcDateRange({required this.startInclusive, required this.endExclusive}) {
    _requireUtc(startInclusive, 'startInclusive');
    _requireUtc(endExclusive, 'endExclusive');
    if (!startInclusive.isBefore(endExclusive)) {
      throw ArgumentError.value(
        endExclusive,
        'endExclusive',
        'Must be after startInclusive.',
      );
    }
  }

  final DateTime startInclusive;
  final DateTime endExclusive;

  bool contains(DateTime instant) {
    _requireUtc(instant, 'instant');
    return !instant.isBefore(startInclusive) && instant.isBefore(endExclusive);
  }

  static void _requireUtc(DateTime value, String name) {
    if (!value.isUtc) {
      throw ArgumentError.value(value, name, 'Must use UTC.');
    }
  }

  @override
  List<Object?> get props => [startInclusive, endExclusive];
}
