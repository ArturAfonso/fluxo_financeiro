import 'package:equatable/equatable.dart';
import 'package:fluxo_financeiro/features/financial_account/data/dtos/dto_parsing_exception.dart';

final class TransactionDto extends Equatable {
  const TransactionDto({
    required this.id,
    required this.description,
    required this.amountCents,
    required this.occurredAt,
    required this.type,
    required this.status,
    required this.metadata,
  });

  factory TransactionDto.fromJson(Object? json) {
    final map = _requireMap(json, 'transaction');
    final metadataMap = _requireMap(map['metadata'] ?? const {}, 'metadata');
    final metadata = <String, String>{};
    for (final entry in metadataMap.entries) {
      final value = entry.value;
      if (value is! String) {
        throw DtoParsingException(
          'metadata.${entry.key} must be a string.',
          source: value,
        );
      }
      metadata[entry.key] = value;
    }

    return TransactionDto(
      id: _requireString(map, 'id'),
      description: _requireString(map, 'description'),
      amountCents: _requireInt(map, 'amount_cents'),
      occurredAt: _requireUtcDateTime(map, 'occurred_at'),
      type: _requireString(map, 'type'),
      status: _requireString(map, 'status'),
      metadata: Map.unmodifiable(metadata),
    );
  }

  final String id;
  final String description;
  final int amountCents;
  final DateTime occurredAt;
  final String type;
  final String status;
  final Map<String, String> metadata;

  @override
  List<Object?> get props => [
    id,
    description,
    amountCents,
    occurredAt,
    type,
    status,
    metadata,
  ];
}

Map<String, Object?> _requireMap(Object? value, String field) {
  if (value is! Map) {
    throw DtoParsingException('$field must be an object.', source: value);
  }
  final result = <String, Object?>{};
  for (final entry in value.entries) {
    if (entry.key is! String) {
      throw DtoParsingException('$field keys must be strings.', source: value);
    }
    result[entry.key as String] = entry.value;
  }
  return result;
}

String _requireString(Map<String, Object?> map, String field) {
  final value = map[field];
  if (value is! String || value.trim().isEmpty) {
    throw DtoParsingException(
      '$field must be a non-empty string.',
      source: value,
    );
  }
  return value;
}

int _requireInt(Map<String, Object?> map, String field) {
  final value = map[field];
  if (value is! int) {
    throw DtoParsingException('$field must be an integer.', source: value);
  }
  return value;
}

DateTime _requireUtcDateTime(Map<String, Object?> map, String field) {
  final value = _requireString(map, field);
  if (!value.endsWith('Z')) {
    throw DtoParsingException('$field must be an ISO 8601 UTC instant.');
  }
  final parsed = DateTime.tryParse(value);
  if (parsed == null || !parsed.isUtc) {
    throw DtoParsingException('$field must be an ISO 8601 UTC instant.');
  }
  return parsed;
}

Map<String, Object?> requireJsonMap(Object? value, String field) =>
    _requireMap(value, field);

String requireJsonString(Map<String, Object?> map, String field) =>
    _requireString(map, field);

int requireJsonInt(Map<String, Object?> map, String field) =>
    _requireInt(map, field);

DateTime requireJsonUtcDateTime(Map<String, Object?> map, String field) =>
    _requireUtcDateTime(map, field);
