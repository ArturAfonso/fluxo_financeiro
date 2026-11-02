// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'financial_database.dart';

// ignore_for_file: type=lint
class $LedgerRecordsTable extends LedgerRecords
    with TableInfo<$LedgerRecordsTable, LedgerRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LedgerRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _singletonMeta = const VerificationMeta(
    'singleton',
  );
  @override
  late final GeneratedColumn<int> singleton = GeneratedColumn<int>(
    'singleton',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _openingBalanceCentsMeta =
      const VerificationMeta('openingBalanceCents');
  @override
  late final GeneratedColumn<int> openingBalanceCents = GeneratedColumn<int>(
    'opening_balance_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _openingBalanceAtMeta = const VerificationMeta(
    'openingBalanceAt',
  );
  @override
  late final GeneratedColumn<DateTime> openingBalanceAt =
      GeneratedColumn<DateTime>(
        'opening_balance_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _asOfMeta = const VerificationMeta('asOf');
  @override
  late final GeneratedColumn<DateTime> asOf = GeneratedColumn<DateTime>(
    'as_of',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cachedAtMeta = const VerificationMeta(
    'cachedAt',
  );
  @override
  late final GeneratedColumn<DateTime> cachedAt = GeneratedColumn<DateTime>(
    'cached_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    singleton,
    openingBalanceCents,
    openingBalanceAt,
    asOf,
    cachedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ledger_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<LedgerRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('singleton')) {
      context.handle(
        _singletonMeta,
        singleton.isAcceptableOrUnknown(data['singleton']!, _singletonMeta),
      );
    }
    if (data.containsKey('opening_balance_cents')) {
      context.handle(
        _openingBalanceCentsMeta,
        openingBalanceCents.isAcceptableOrUnknown(
          data['opening_balance_cents']!,
          _openingBalanceCentsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_openingBalanceCentsMeta);
    }
    if (data.containsKey('opening_balance_at')) {
      context.handle(
        _openingBalanceAtMeta,
        openingBalanceAt.isAcceptableOrUnknown(
          data['opening_balance_at']!,
          _openingBalanceAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_openingBalanceAtMeta);
    }
    if (data.containsKey('as_of')) {
      context.handle(
        _asOfMeta,
        asOf.isAcceptableOrUnknown(data['as_of']!, _asOfMeta),
      );
    } else if (isInserting) {
      context.missing(_asOfMeta);
    }
    if (data.containsKey('cached_at')) {
      context.handle(
        _cachedAtMeta,
        cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_cachedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {singleton};
  @override
  LedgerRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LedgerRecord(
      singleton: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}singleton'],
      )!,
      openingBalanceCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}opening_balance_cents'],
      )!,
      openingBalanceAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}opening_balance_at'],
      )!,
      asOf: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}as_of'],
      )!,
      cachedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}cached_at'],
      )!,
    );
  }

  @override
  $LedgerRecordsTable createAlias(String alias) {
    return $LedgerRecordsTable(attachedDatabase, alias);
  }
}

class LedgerRecord extends DataClass implements Insertable<LedgerRecord> {
  final int singleton;
  final int openingBalanceCents;
  final DateTime openingBalanceAt;
  final DateTime asOf;
  final DateTime cachedAt;
  const LedgerRecord({
    required this.singleton,
    required this.openingBalanceCents,
    required this.openingBalanceAt,
    required this.asOf,
    required this.cachedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['singleton'] = Variable<int>(singleton);
    map['opening_balance_cents'] = Variable<int>(openingBalanceCents);
    map['opening_balance_at'] = Variable<DateTime>(openingBalanceAt);
    map['as_of'] = Variable<DateTime>(asOf);
    map['cached_at'] = Variable<DateTime>(cachedAt);
    return map;
  }

  LedgerRecordsCompanion toCompanion(bool nullToAbsent) {
    return LedgerRecordsCompanion(
      singleton: Value(singleton),
      openingBalanceCents: Value(openingBalanceCents),
      openingBalanceAt: Value(openingBalanceAt),
      asOf: Value(asOf),
      cachedAt: Value(cachedAt),
    );
  }

  factory LedgerRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LedgerRecord(
      singleton: serializer.fromJson<int>(json['singleton']),
      openingBalanceCents: serializer.fromJson<int>(
        json['openingBalanceCents'],
      ),
      openingBalanceAt: serializer.fromJson<DateTime>(json['openingBalanceAt']),
      asOf: serializer.fromJson<DateTime>(json['asOf']),
      cachedAt: serializer.fromJson<DateTime>(json['cachedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'singleton': serializer.toJson<int>(singleton),
      'openingBalanceCents': serializer.toJson<int>(openingBalanceCents),
      'openingBalanceAt': serializer.toJson<DateTime>(openingBalanceAt),
      'asOf': serializer.toJson<DateTime>(asOf),
      'cachedAt': serializer.toJson<DateTime>(cachedAt),
    };
  }

  LedgerRecord copyWith({
    int? singleton,
    int? openingBalanceCents,
    DateTime? openingBalanceAt,
    DateTime? asOf,
    DateTime? cachedAt,
  }) => LedgerRecord(
    singleton: singleton ?? this.singleton,
    openingBalanceCents: openingBalanceCents ?? this.openingBalanceCents,
    openingBalanceAt: openingBalanceAt ?? this.openingBalanceAt,
    asOf: asOf ?? this.asOf,
    cachedAt: cachedAt ?? this.cachedAt,
  );
  LedgerRecord copyWithCompanion(LedgerRecordsCompanion data) {
    return LedgerRecord(
      singleton: data.singleton.present ? data.singleton.value : this.singleton,
      openingBalanceCents: data.openingBalanceCents.present
          ? data.openingBalanceCents.value
          : this.openingBalanceCents,
      openingBalanceAt: data.openingBalanceAt.present
          ? data.openingBalanceAt.value
          : this.openingBalanceAt,
      asOf: data.asOf.present ? data.asOf.value : this.asOf,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LedgerRecord(')
          ..write('singleton: $singleton, ')
          ..write('openingBalanceCents: $openingBalanceCents, ')
          ..write('openingBalanceAt: $openingBalanceAt, ')
          ..write('asOf: $asOf, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    singleton,
    openingBalanceCents,
    openingBalanceAt,
    asOf,
    cachedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LedgerRecord &&
          other.singleton == this.singleton &&
          other.openingBalanceCents == this.openingBalanceCents &&
          other.openingBalanceAt == this.openingBalanceAt &&
          other.asOf == this.asOf &&
          other.cachedAt == this.cachedAt);
}

class LedgerRecordsCompanion extends UpdateCompanion<LedgerRecord> {
  final Value<int> singleton;
  final Value<int> openingBalanceCents;
  final Value<DateTime> openingBalanceAt;
  final Value<DateTime> asOf;
  final Value<DateTime> cachedAt;
  const LedgerRecordsCompanion({
    this.singleton = const Value.absent(),
    this.openingBalanceCents = const Value.absent(),
    this.openingBalanceAt = const Value.absent(),
    this.asOf = const Value.absent(),
    this.cachedAt = const Value.absent(),
  });
  LedgerRecordsCompanion.insert({
    this.singleton = const Value.absent(),
    required int openingBalanceCents,
    required DateTime openingBalanceAt,
    required DateTime asOf,
    required DateTime cachedAt,
  }) : openingBalanceCents = Value(openingBalanceCents),
       openingBalanceAt = Value(openingBalanceAt),
       asOf = Value(asOf),
       cachedAt = Value(cachedAt);
  static Insertable<LedgerRecord> custom({
    Expression<int>? singleton,
    Expression<int>? openingBalanceCents,
    Expression<DateTime>? openingBalanceAt,
    Expression<DateTime>? asOf,
    Expression<DateTime>? cachedAt,
  }) {
    return RawValuesInsertable({
      if (singleton != null) 'singleton': singleton,
      if (openingBalanceCents != null)
        'opening_balance_cents': openingBalanceCents,
      if (openingBalanceAt != null) 'opening_balance_at': openingBalanceAt,
      if (asOf != null) 'as_of': asOf,
      if (cachedAt != null) 'cached_at': cachedAt,
    });
  }

  LedgerRecordsCompanion copyWith({
    Value<int>? singleton,
    Value<int>? openingBalanceCents,
    Value<DateTime>? openingBalanceAt,
    Value<DateTime>? asOf,
    Value<DateTime>? cachedAt,
  }) {
    return LedgerRecordsCompanion(
      singleton: singleton ?? this.singleton,
      openingBalanceCents: openingBalanceCents ?? this.openingBalanceCents,
      openingBalanceAt: openingBalanceAt ?? this.openingBalanceAt,
      asOf: asOf ?? this.asOf,
      cachedAt: cachedAt ?? this.cachedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (singleton.present) {
      map['singleton'] = Variable<int>(singleton.value);
    }
    if (openingBalanceCents.present) {
      map['opening_balance_cents'] = Variable<int>(openingBalanceCents.value);
    }
    if (openingBalanceAt.present) {
      map['opening_balance_at'] = Variable<DateTime>(openingBalanceAt.value);
    }
    if (asOf.present) {
      map['as_of'] = Variable<DateTime>(asOf.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<DateTime>(cachedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LedgerRecordsCompanion(')
          ..write('singleton: $singleton, ')
          ..write('openingBalanceCents: $openingBalanceCents, ')
          ..write('openingBalanceAt: $openingBalanceAt, ')
          ..write('asOf: $asOf, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }
}

class $TransactionRecordsTable extends TransactionRecords
    with TableInfo<$TransactionRecordsTable, TransactionRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountCentsMeta = const VerificationMeta(
    'amountCents',
  );
  @override
  late final GeneratedColumn<int> amountCents = GeneratedColumn<int>(
    'amount_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _occurredAtMeta = const VerificationMeta(
    'occurredAt',
  );
  @override
  late final GeneratedColumn<DateTime> occurredAt = GeneratedColumn<DateTime>(
    'occurred_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _metadataJsonMeta = const VerificationMeta(
    'metadataJson',
  );
  @override
  late final GeneratedColumn<String> metadataJson = GeneratedColumn<String>(
    'metadata_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    description,
    amountCents,
    occurredAt,
    type,
    status,
    metadataJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transaction_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<TransactionRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('amount_cents')) {
      context.handle(
        _amountCentsMeta,
        amountCents.isAcceptableOrUnknown(
          data['amount_cents']!,
          _amountCentsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountCentsMeta);
    }
    if (data.containsKey('occurred_at')) {
      context.handle(
        _occurredAtMeta,
        occurredAt.isAcceptableOrUnknown(data['occurred_at']!, _occurredAtMeta),
      );
    } else if (isInserting) {
      context.missing(_occurredAtMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('metadata_json')) {
      context.handle(
        _metadataJsonMeta,
        metadataJson.isAcceptableOrUnknown(
          data['metadata_json']!,
          _metadataJsonMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TransactionRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TransactionRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      amountCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_cents'],
      )!,
      occurredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}occurred_at'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      metadataJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}metadata_json'],
      )!,
    );
  }

  @override
  $TransactionRecordsTable createAlias(String alias) {
    return $TransactionRecordsTable(attachedDatabase, alias);
  }
}

class TransactionRecord extends DataClass
    implements Insertable<TransactionRecord> {
  final String id;
  final String description;
  final int amountCents;
  final DateTime occurredAt;
  final String type;
  final String status;
  final String metadataJson;
  const TransactionRecord({
    required this.id,
    required this.description,
    required this.amountCents,
    required this.occurredAt,
    required this.type,
    required this.status,
    required this.metadataJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['description'] = Variable<String>(description);
    map['amount_cents'] = Variable<int>(amountCents);
    map['occurred_at'] = Variable<DateTime>(occurredAt);
    map['type'] = Variable<String>(type);
    map['status'] = Variable<String>(status);
    map['metadata_json'] = Variable<String>(metadataJson);
    return map;
  }

  TransactionRecordsCompanion toCompanion(bool nullToAbsent) {
    return TransactionRecordsCompanion(
      id: Value(id),
      description: Value(description),
      amountCents: Value(amountCents),
      occurredAt: Value(occurredAt),
      type: Value(type),
      status: Value(status),
      metadataJson: Value(metadataJson),
    );
  }

  factory TransactionRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TransactionRecord(
      id: serializer.fromJson<String>(json['id']),
      description: serializer.fromJson<String>(json['description']),
      amountCents: serializer.fromJson<int>(json['amountCents']),
      occurredAt: serializer.fromJson<DateTime>(json['occurredAt']),
      type: serializer.fromJson<String>(json['type']),
      status: serializer.fromJson<String>(json['status']),
      metadataJson: serializer.fromJson<String>(json['metadataJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'description': serializer.toJson<String>(description),
      'amountCents': serializer.toJson<int>(amountCents),
      'occurredAt': serializer.toJson<DateTime>(occurredAt),
      'type': serializer.toJson<String>(type),
      'status': serializer.toJson<String>(status),
      'metadataJson': serializer.toJson<String>(metadataJson),
    };
  }

  TransactionRecord copyWith({
    String? id,
    String? description,
    int? amountCents,
    DateTime? occurredAt,
    String? type,
    String? status,
    String? metadataJson,
  }) => TransactionRecord(
    id: id ?? this.id,
    description: description ?? this.description,
    amountCents: amountCents ?? this.amountCents,
    occurredAt: occurredAt ?? this.occurredAt,
    type: type ?? this.type,
    status: status ?? this.status,
    metadataJson: metadataJson ?? this.metadataJson,
  );
  TransactionRecord copyWithCompanion(TransactionRecordsCompanion data) {
    return TransactionRecord(
      id: data.id.present ? data.id.value : this.id,
      description: data.description.present
          ? data.description.value
          : this.description,
      amountCents: data.amountCents.present
          ? data.amountCents.value
          : this.amountCents,
      occurredAt: data.occurredAt.present
          ? data.occurredAt.value
          : this.occurredAt,
      type: data.type.present ? data.type.value : this.type,
      status: data.status.present ? data.status.value : this.status,
      metadataJson: data.metadataJson.present
          ? data.metadataJson.value
          : this.metadataJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TransactionRecord(')
          ..write('id: $id, ')
          ..write('description: $description, ')
          ..write('amountCents: $amountCents, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('type: $type, ')
          ..write('status: $status, ')
          ..write('metadataJson: $metadataJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    description,
    amountCents,
    occurredAt,
    type,
    status,
    metadataJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TransactionRecord &&
          other.id == this.id &&
          other.description == this.description &&
          other.amountCents == this.amountCents &&
          other.occurredAt == this.occurredAt &&
          other.type == this.type &&
          other.status == this.status &&
          other.metadataJson == this.metadataJson);
}

class TransactionRecordsCompanion extends UpdateCompanion<TransactionRecord> {
  final Value<String> id;
  final Value<String> description;
  final Value<int> amountCents;
  final Value<DateTime> occurredAt;
  final Value<String> type;
  final Value<String> status;
  final Value<String> metadataJson;
  final Value<int> rowid;
  const TransactionRecordsCompanion({
    this.id = const Value.absent(),
    this.description = const Value.absent(),
    this.amountCents = const Value.absent(),
    this.occurredAt = const Value.absent(),
    this.type = const Value.absent(),
    this.status = const Value.absent(),
    this.metadataJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TransactionRecordsCompanion.insert({
    required String id,
    required String description,
    required int amountCents,
    required DateTime occurredAt,
    required String type,
    required String status,
    this.metadataJson = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       description = Value(description),
       amountCents = Value(amountCents),
       occurredAt = Value(occurredAt),
       type = Value(type),
       status = Value(status);
  static Insertable<TransactionRecord> custom({
    Expression<String>? id,
    Expression<String>? description,
    Expression<int>? amountCents,
    Expression<DateTime>? occurredAt,
    Expression<String>? type,
    Expression<String>? status,
    Expression<String>? metadataJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (description != null) 'description': description,
      if (amountCents != null) 'amount_cents': amountCents,
      if (occurredAt != null) 'occurred_at': occurredAt,
      if (type != null) 'type': type,
      if (status != null) 'status': status,
      if (metadataJson != null) 'metadata_json': metadataJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TransactionRecordsCompanion copyWith({
    Value<String>? id,
    Value<String>? description,
    Value<int>? amountCents,
    Value<DateTime>? occurredAt,
    Value<String>? type,
    Value<String>? status,
    Value<String>? metadataJson,
    Value<int>? rowid,
  }) {
    return TransactionRecordsCompanion(
      id: id ?? this.id,
      description: description ?? this.description,
      amountCents: amountCents ?? this.amountCents,
      occurredAt: occurredAt ?? this.occurredAt,
      type: type ?? this.type,
      status: status ?? this.status,
      metadataJson: metadataJson ?? this.metadataJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (amountCents.present) {
      map['amount_cents'] = Variable<int>(amountCents.value);
    }
    if (occurredAt.present) {
      map['occurred_at'] = Variable<DateTime>(occurredAt.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (metadataJson.present) {
      map['metadata_json'] = Variable<String>(metadataJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionRecordsCompanion(')
          ..write('id: $id, ')
          ..write('description: $description, ')
          ..write('amountCents: $amountCents, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('type: $type, ')
          ..write('status: $status, ')
          ..write('metadataJson: $metadataJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$FinancialDatabase extends GeneratedDatabase {
  _$FinancialDatabase(QueryExecutor e) : super(e);
  $FinancialDatabaseManager get managers => $FinancialDatabaseManager(this);
  late final $LedgerRecordsTable ledgerRecords = $LedgerRecordsTable(this);
  late final $TransactionRecordsTable transactionRecords =
      $TransactionRecordsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    ledgerRecords,
    transactionRecords,
  ];
}

typedef $$LedgerRecordsTableCreateCompanionBuilder =
    LedgerRecordsCompanion Function({
      Value<int> singleton,
      required int openingBalanceCents,
      required DateTime openingBalanceAt,
      required DateTime asOf,
      required DateTime cachedAt,
    });
typedef $$LedgerRecordsTableUpdateCompanionBuilder =
    LedgerRecordsCompanion Function({
      Value<int> singleton,
      Value<int> openingBalanceCents,
      Value<DateTime> openingBalanceAt,
      Value<DateTime> asOf,
      Value<DateTime> cachedAt,
    });

class $$LedgerRecordsTableFilterComposer
    extends Composer<_$FinancialDatabase, $LedgerRecordsTable> {
  $$LedgerRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get singleton => $composableBuilder(
    column: $table.singleton,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get openingBalanceCents => $composableBuilder(
    column: $table.openingBalanceCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get openingBalanceAt => $composableBuilder(
    column: $table.openingBalanceAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get asOf => $composableBuilder(
    column: $table.asOf,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LedgerRecordsTableOrderingComposer
    extends Composer<_$FinancialDatabase, $LedgerRecordsTable> {
  $$LedgerRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get singleton => $composableBuilder(
    column: $table.singleton,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get openingBalanceCents => $composableBuilder(
    column: $table.openingBalanceCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get openingBalanceAt => $composableBuilder(
    column: $table.openingBalanceAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get asOf => $composableBuilder(
    column: $table.asOf,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LedgerRecordsTableAnnotationComposer
    extends Composer<_$FinancialDatabase, $LedgerRecordsTable> {
  $$LedgerRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get singleton =>
      $composableBuilder(column: $table.singleton, builder: (column) => column);

  GeneratedColumn<int> get openingBalanceCents => $composableBuilder(
    column: $table.openingBalanceCents,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get openingBalanceAt => $composableBuilder(
    column: $table.openingBalanceAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get asOf =>
      $composableBuilder(column: $table.asOf, builder: (column) => column);

  GeneratedColumn<DateTime> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);
}

class $$LedgerRecordsTableTableManager
    extends
        RootTableManager<
          _$FinancialDatabase,
          $LedgerRecordsTable,
          LedgerRecord,
          $$LedgerRecordsTableFilterComposer,
          $$LedgerRecordsTableOrderingComposer,
          $$LedgerRecordsTableAnnotationComposer,
          $$LedgerRecordsTableCreateCompanionBuilder,
          $$LedgerRecordsTableUpdateCompanionBuilder,
          (
            LedgerRecord,
            BaseReferences<
              _$FinancialDatabase,
              $LedgerRecordsTable,
              LedgerRecord
            >,
          ),
          LedgerRecord,
          PrefetchHooks Function()
        > {
  $$LedgerRecordsTableTableManager(
    _$FinancialDatabase db,
    $LedgerRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LedgerRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LedgerRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LedgerRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> singleton = const Value.absent(),
                Value<int> openingBalanceCents = const Value.absent(),
                Value<DateTime> openingBalanceAt = const Value.absent(),
                Value<DateTime> asOf = const Value.absent(),
                Value<DateTime> cachedAt = const Value.absent(),
              }) => LedgerRecordsCompanion(
                singleton: singleton,
                openingBalanceCents: openingBalanceCents,
                openingBalanceAt: openingBalanceAt,
                asOf: asOf,
                cachedAt: cachedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> singleton = const Value.absent(),
                required int openingBalanceCents,
                required DateTime openingBalanceAt,
                required DateTime asOf,
                required DateTime cachedAt,
              }) => LedgerRecordsCompanion.insert(
                singleton: singleton,
                openingBalanceCents: openingBalanceCents,
                openingBalanceAt: openingBalanceAt,
                asOf: asOf,
                cachedAt: cachedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LedgerRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$FinancialDatabase,
      $LedgerRecordsTable,
      LedgerRecord,
      $$LedgerRecordsTableFilterComposer,
      $$LedgerRecordsTableOrderingComposer,
      $$LedgerRecordsTableAnnotationComposer,
      $$LedgerRecordsTableCreateCompanionBuilder,
      $$LedgerRecordsTableUpdateCompanionBuilder,
      (
        LedgerRecord,
        BaseReferences<_$FinancialDatabase, $LedgerRecordsTable, LedgerRecord>,
      ),
      LedgerRecord,
      PrefetchHooks Function()
    >;
typedef $$TransactionRecordsTableCreateCompanionBuilder =
    TransactionRecordsCompanion Function({
      required String id,
      required String description,
      required int amountCents,
      required DateTime occurredAt,
      required String type,
      required String status,
      Value<String> metadataJson,
      Value<int> rowid,
    });
typedef $$TransactionRecordsTableUpdateCompanionBuilder =
    TransactionRecordsCompanion Function({
      Value<String> id,
      Value<String> description,
      Value<int> amountCents,
      Value<DateTime> occurredAt,
      Value<String> type,
      Value<String> status,
      Value<String> metadataJson,
      Value<int> rowid,
    });

class $$TransactionRecordsTableFilterComposer
    extends Composer<_$FinancialDatabase, $TransactionRecordsTable> {
  $$TransactionRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountCents => $composableBuilder(
    column: $table.amountCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get metadataJson => $composableBuilder(
    column: $table.metadataJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TransactionRecordsTableOrderingComposer
    extends Composer<_$FinancialDatabase, $TransactionRecordsTable> {
  $$TransactionRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountCents => $composableBuilder(
    column: $table.amountCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get metadataJson => $composableBuilder(
    column: $table.metadataJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TransactionRecordsTableAnnotationComposer
    extends Composer<_$FinancialDatabase, $TransactionRecordsTable> {
  $$TransactionRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<int> get amountCents => $composableBuilder(
    column: $table.amountCents,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get metadataJson => $composableBuilder(
    column: $table.metadataJson,
    builder: (column) => column,
  );
}

class $$TransactionRecordsTableTableManager
    extends
        RootTableManager<
          _$FinancialDatabase,
          $TransactionRecordsTable,
          TransactionRecord,
          $$TransactionRecordsTableFilterComposer,
          $$TransactionRecordsTableOrderingComposer,
          $$TransactionRecordsTableAnnotationComposer,
          $$TransactionRecordsTableCreateCompanionBuilder,
          $$TransactionRecordsTableUpdateCompanionBuilder,
          (
            TransactionRecord,
            BaseReferences<
              _$FinancialDatabase,
              $TransactionRecordsTable,
              TransactionRecord
            >,
          ),
          TransactionRecord,
          PrefetchHooks Function()
        > {
  $$TransactionRecordsTableTableManager(
    _$FinancialDatabase db,
    $TransactionRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransactionRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransactionRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransactionRecordsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<int> amountCents = const Value.absent(),
                Value<DateTime> occurredAt = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> metadataJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransactionRecordsCompanion(
                id: id,
                description: description,
                amountCents: amountCents,
                occurredAt: occurredAt,
                type: type,
                status: status,
                metadataJson: metadataJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String description,
                required int amountCents,
                required DateTime occurredAt,
                required String type,
                required String status,
                Value<String> metadataJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransactionRecordsCompanion.insert(
                id: id,
                description: description,
                amountCents: amountCents,
                occurredAt: occurredAt,
                type: type,
                status: status,
                metadataJson: metadataJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TransactionRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$FinancialDatabase,
      $TransactionRecordsTable,
      TransactionRecord,
      $$TransactionRecordsTableFilterComposer,
      $$TransactionRecordsTableOrderingComposer,
      $$TransactionRecordsTableAnnotationComposer,
      $$TransactionRecordsTableCreateCompanionBuilder,
      $$TransactionRecordsTableUpdateCompanionBuilder,
      (
        TransactionRecord,
        BaseReferences<
          _$FinancialDatabase,
          $TransactionRecordsTable,
          TransactionRecord
        >,
      ),
      TransactionRecord,
      PrefetchHooks Function()
    >;

class $FinancialDatabaseManager {
  final _$FinancialDatabase _db;
  $FinancialDatabaseManager(this._db);
  $$LedgerRecordsTableTableManager get ledgerRecords =>
      $$LedgerRecordsTableTableManager(_db, _db.ledgerRecords);
  $$TransactionRecordsTableTableManager get transactionRecords =>
      $$TransactionRecordsTableTableManager(_db, _db.transactionRecords);
}
