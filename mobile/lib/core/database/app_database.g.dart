// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ProfilesTable extends Profiles
    with TableInfo<$ProfilesTable, ProfileRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _serverUpdatedAtMeta = const VerificationMeta(
    'serverUpdatedAt',
  );
  @override
  late final GeneratedColumn<int> serverUpdatedAt = GeneratedColumn<int>(
    'server_updated_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _localVersionMeta = const VerificationMeta(
    'localVersion',
  );
  @override
  late final GeneratedColumn<int> localVersion = GeneratedColumn<int>(
    'local_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    check: () => syncStatus.isIn(syncStatuses),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('synced'),
  );
  static const VerificationMeta _localCreatedAtMeta = const VerificationMeta(
    'localCreatedAt',
  );
  @override
  late final GeneratedColumn<int> localCreatedAt = GeneratedColumn<int>(
    'local_created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localUpdatedAtMeta = const VerificationMeta(
    'localUpdatedAt',
  );
  @override
  late final GeneratedColumn<int> localUpdatedAt = GeneratedColumn<int>(
    'local_updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _baseCurrencyMeta = const VerificationMeta(
    'baseCurrency',
  );
  @override
  late final GeneratedColumn<String> baseCurrency = GeneratedColumn<String>(
    'base_currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyExponentMeta = const VerificationMeta(
    'currencyExponent',
  );
  @override
  late final GeneratedColumn<int> currencyExponent = GeneratedColumn<int>(
    'currency_exponent',
    aliasedName,
    false,
    check: () => ComparableExpr(currencyExponent).isBetweenValues(0, 4),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timeZoneMeta = const VerificationMeta(
    'timeZone',
  );
  @override
  late final GeneratedColumn<String> timeZone = GeneratedColumn<String>(
    'time_zone',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _onboardingCompleteMeta =
      const VerificationMeta('onboardingComplete');
  @override
  late final GeneratedColumn<bool> onboardingComplete = GeneratedColumn<bool>(
    'onboarding_complete',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("onboarding_complete" IN (0, 1))',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    userId,
    id,
    revision,
    createdAt,
    serverUpdatedAt,
    deletedAt,
    localVersion,
    syncStatus,
    localCreatedAt,
    localUpdatedAt,
    displayName,
    baseCurrency,
    currencyExponent,
    timeZone,
    onboardingComplete,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProfileRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('server_updated_at')) {
      context.handle(
        _serverUpdatedAtMeta,
        serverUpdatedAt.isAcceptableOrUnknown(
          data['server_updated_at']!,
          _serverUpdatedAtMeta,
        ),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('local_version')) {
      context.handle(
        _localVersionMeta,
        localVersion.isAcceptableOrUnknown(
          data['local_version']!,
          _localVersionMeta,
        ),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('local_created_at')) {
      context.handle(
        _localCreatedAtMeta,
        localCreatedAt.isAcceptableOrUnknown(
          data['local_created_at']!,
          _localCreatedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_localCreatedAtMeta);
    }
    if (data.containsKey('local_updated_at')) {
      context.handle(
        _localUpdatedAtMeta,
        localUpdatedAt.isAcceptableOrUnknown(
          data['local_updated_at']!,
          _localUpdatedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_localUpdatedAtMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('base_currency')) {
      context.handle(
        _baseCurrencyMeta,
        baseCurrency.isAcceptableOrUnknown(
          data['base_currency']!,
          _baseCurrencyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_baseCurrencyMeta);
    }
    if (data.containsKey('currency_exponent')) {
      context.handle(
        _currencyExponentMeta,
        currencyExponent.isAcceptableOrUnknown(
          data['currency_exponent']!,
          _currencyExponentMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_currencyExponentMeta);
    }
    if (data.containsKey('time_zone')) {
      context.handle(
        _timeZoneMeta,
        timeZone.isAcceptableOrUnknown(data['time_zone']!, _timeZoneMeta),
      );
    } else if (isInserting) {
      context.missing(_timeZoneMeta);
    }
    if (data.containsKey('onboarding_complete')) {
      context.handle(
        _onboardingCompleteMeta,
        onboardingComplete.isAcceptableOrUnknown(
          data['onboarding_complete']!,
          _onboardingCompleteMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_onboardingCompleteMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId, id};
  @override
  ProfileRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProfileRow(
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      ),
      serverUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_updated_at'],
      ),
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      localVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}local_version'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      localCreatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}local_created_at'],
      )!,
      localUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}local_updated_at'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      baseCurrency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}base_currency'],
      )!,
      currencyExponent: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}currency_exponent'],
      )!,
      timeZone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}time_zone'],
      )!,
      onboardingComplete: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}onboarding_complete'],
      )!,
    );
  }

  @override
  $ProfilesTable createAlias(String alias) {
    return $ProfilesTable(attachedDatabase, alias);
  }
}

class ProfileRow extends DataClass implements Insertable<ProfileRow> {
  final String userId;
  final String id;

  /// Last accepted remote revision (0 = never accepted).
  final int revision;
  final int? createdAt;
  final int? serverUpdatedAt;
  final int? deletedAt;
  final int localVersion;
  final String syncStatus;
  final int localCreatedAt;
  final int localUpdatedAt;
  final String displayName;
  final String baseCurrency;
  final int currencyExponent;
  final String timeZone;
  final bool onboardingComplete;
  const ProfileRow({
    required this.userId,
    required this.id,
    required this.revision,
    this.createdAt,
    this.serverUpdatedAt,
    this.deletedAt,
    required this.localVersion,
    required this.syncStatus,
    required this.localCreatedAt,
    required this.localUpdatedAt,
    required this.displayName,
    required this.baseCurrency,
    required this.currencyExponent,
    required this.timeZone,
    required this.onboardingComplete,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<String>(userId);
    map['id'] = Variable<String>(id);
    map['revision'] = Variable<int>(revision);
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<int>(createdAt);
    }
    if (!nullToAbsent || serverUpdatedAt != null) {
      map['server_updated_at'] = Variable<int>(serverUpdatedAt);
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['local_version'] = Variable<int>(localVersion);
    map['sync_status'] = Variable<String>(syncStatus);
    map['local_created_at'] = Variable<int>(localCreatedAt);
    map['local_updated_at'] = Variable<int>(localUpdatedAt);
    map['display_name'] = Variable<String>(displayName);
    map['base_currency'] = Variable<String>(baseCurrency);
    map['currency_exponent'] = Variable<int>(currencyExponent);
    map['time_zone'] = Variable<String>(timeZone);
    map['onboarding_complete'] = Variable<bool>(onboardingComplete);
    return map;
  }

  ProfilesCompanion toCompanion(bool nullToAbsent) {
    return ProfilesCompanion(
      userId: Value(userId),
      id: Value(id),
      revision: Value(revision),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      serverUpdatedAt: serverUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(serverUpdatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      localVersion: Value(localVersion),
      syncStatus: Value(syncStatus),
      localCreatedAt: Value(localCreatedAt),
      localUpdatedAt: Value(localUpdatedAt),
      displayName: Value(displayName),
      baseCurrency: Value(baseCurrency),
      currencyExponent: Value(currencyExponent),
      timeZone: Value(timeZone),
      onboardingComplete: Value(onboardingComplete),
    );
  }

  factory ProfileRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProfileRow(
      userId: serializer.fromJson<String>(json['userId']),
      id: serializer.fromJson<String>(json['id']),
      revision: serializer.fromJson<int>(json['revision']),
      createdAt: serializer.fromJson<int?>(json['createdAt']),
      serverUpdatedAt: serializer.fromJson<int?>(json['serverUpdatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      localVersion: serializer.fromJson<int>(json['localVersion']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      localCreatedAt: serializer.fromJson<int>(json['localCreatedAt']),
      localUpdatedAt: serializer.fromJson<int>(json['localUpdatedAt']),
      displayName: serializer.fromJson<String>(json['displayName']),
      baseCurrency: serializer.fromJson<String>(json['baseCurrency']),
      currencyExponent: serializer.fromJson<int>(json['currencyExponent']),
      timeZone: serializer.fromJson<String>(json['timeZone']),
      onboardingComplete: serializer.fromJson<bool>(json['onboardingComplete']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<String>(userId),
      'id': serializer.toJson<String>(id),
      'revision': serializer.toJson<int>(revision),
      'createdAt': serializer.toJson<int?>(createdAt),
      'serverUpdatedAt': serializer.toJson<int?>(serverUpdatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'localVersion': serializer.toJson<int>(localVersion),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'localCreatedAt': serializer.toJson<int>(localCreatedAt),
      'localUpdatedAt': serializer.toJson<int>(localUpdatedAt),
      'displayName': serializer.toJson<String>(displayName),
      'baseCurrency': serializer.toJson<String>(baseCurrency),
      'currencyExponent': serializer.toJson<int>(currencyExponent),
      'timeZone': serializer.toJson<String>(timeZone),
      'onboardingComplete': serializer.toJson<bool>(onboardingComplete),
    };
  }

  ProfileRow copyWith({
    String? userId,
    String? id,
    int? revision,
    Value<int?> createdAt = const Value.absent(),
    Value<int?> serverUpdatedAt = const Value.absent(),
    Value<int?> deletedAt = const Value.absent(),
    int? localVersion,
    String? syncStatus,
    int? localCreatedAt,
    int? localUpdatedAt,
    String? displayName,
    String? baseCurrency,
    int? currencyExponent,
    String? timeZone,
    bool? onboardingComplete,
  }) => ProfileRow(
    userId: userId ?? this.userId,
    id: id ?? this.id,
    revision: revision ?? this.revision,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
    serverUpdatedAt: serverUpdatedAt.present
        ? serverUpdatedAt.value
        : this.serverUpdatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    localVersion: localVersion ?? this.localVersion,
    syncStatus: syncStatus ?? this.syncStatus,
    localCreatedAt: localCreatedAt ?? this.localCreatedAt,
    localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
    displayName: displayName ?? this.displayName,
    baseCurrency: baseCurrency ?? this.baseCurrency,
    currencyExponent: currencyExponent ?? this.currencyExponent,
    timeZone: timeZone ?? this.timeZone,
    onboardingComplete: onboardingComplete ?? this.onboardingComplete,
  );
  ProfileRow copyWithCompanion(ProfilesCompanion data) {
    return ProfileRow(
      userId: data.userId.present ? data.userId.value : this.userId,
      id: data.id.present ? data.id.value : this.id,
      revision: data.revision.present ? data.revision.value : this.revision,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      serverUpdatedAt: data.serverUpdatedAt.present
          ? data.serverUpdatedAt.value
          : this.serverUpdatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      localVersion: data.localVersion.present
          ? data.localVersion.value
          : this.localVersion,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      localCreatedAt: data.localCreatedAt.present
          ? data.localCreatedAt.value
          : this.localCreatedAt,
      localUpdatedAt: data.localUpdatedAt.present
          ? data.localUpdatedAt.value
          : this.localUpdatedAt,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      baseCurrency: data.baseCurrency.present
          ? data.baseCurrency.value
          : this.baseCurrency,
      currencyExponent: data.currencyExponent.present
          ? data.currencyExponent.value
          : this.currencyExponent,
      timeZone: data.timeZone.present ? data.timeZone.value : this.timeZone,
      onboardingComplete: data.onboardingComplete.present
          ? data.onboardingComplete.value
          : this.onboardingComplete,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProfileRow(')
          ..write('userId: $userId, ')
          ..write('id: $id, ')
          ..write('revision: $revision, ')
          ..write('createdAt: $createdAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('localVersion: $localVersion, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('localCreatedAt: $localCreatedAt, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('displayName: $displayName, ')
          ..write('baseCurrency: $baseCurrency, ')
          ..write('currencyExponent: $currencyExponent, ')
          ..write('timeZone: $timeZone, ')
          ..write('onboardingComplete: $onboardingComplete')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    userId,
    id,
    revision,
    createdAt,
    serverUpdatedAt,
    deletedAt,
    localVersion,
    syncStatus,
    localCreatedAt,
    localUpdatedAt,
    displayName,
    baseCurrency,
    currencyExponent,
    timeZone,
    onboardingComplete,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProfileRow &&
          other.userId == this.userId &&
          other.id == this.id &&
          other.revision == this.revision &&
          other.createdAt == this.createdAt &&
          other.serverUpdatedAt == this.serverUpdatedAt &&
          other.deletedAt == this.deletedAt &&
          other.localVersion == this.localVersion &&
          other.syncStatus == this.syncStatus &&
          other.localCreatedAt == this.localCreatedAt &&
          other.localUpdatedAt == this.localUpdatedAt &&
          other.displayName == this.displayName &&
          other.baseCurrency == this.baseCurrency &&
          other.currencyExponent == this.currencyExponent &&
          other.timeZone == this.timeZone &&
          other.onboardingComplete == this.onboardingComplete);
}

class ProfilesCompanion extends UpdateCompanion<ProfileRow> {
  final Value<String> userId;
  final Value<String> id;
  final Value<int> revision;
  final Value<int?> createdAt;
  final Value<int?> serverUpdatedAt;
  final Value<int?> deletedAt;
  final Value<int> localVersion;
  final Value<String> syncStatus;
  final Value<int> localCreatedAt;
  final Value<int> localUpdatedAt;
  final Value<String> displayName;
  final Value<String> baseCurrency;
  final Value<int> currencyExponent;
  final Value<String> timeZone;
  final Value<bool> onboardingComplete;
  final Value<int> rowid;
  const ProfilesCompanion({
    this.userId = const Value.absent(),
    this.id = const Value.absent(),
    this.revision = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.localVersion = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.localCreatedAt = const Value.absent(),
    this.localUpdatedAt = const Value.absent(),
    this.displayName = const Value.absent(),
    this.baseCurrency = const Value.absent(),
    this.currencyExponent = const Value.absent(),
    this.timeZone = const Value.absent(),
    this.onboardingComplete = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProfilesCompanion.insert({
    required String userId,
    required String id,
    this.revision = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.localVersion = const Value.absent(),
    this.syncStatus = const Value.absent(),
    required int localCreatedAt,
    required int localUpdatedAt,
    required String displayName,
    required String baseCurrency,
    required int currencyExponent,
    required String timeZone,
    required bool onboardingComplete,
    this.rowid = const Value.absent(),
  }) : userId = Value(userId),
       id = Value(id),
       localCreatedAt = Value(localCreatedAt),
       localUpdatedAt = Value(localUpdatedAt),
       displayName = Value(displayName),
       baseCurrency = Value(baseCurrency),
       currencyExponent = Value(currencyExponent),
       timeZone = Value(timeZone),
       onboardingComplete = Value(onboardingComplete);
  static Insertable<ProfileRow> custom({
    Expression<String>? userId,
    Expression<String>? id,
    Expression<int>? revision,
    Expression<int>? createdAt,
    Expression<int>? serverUpdatedAt,
    Expression<int>? deletedAt,
    Expression<int>? localVersion,
    Expression<String>? syncStatus,
    Expression<int>? localCreatedAt,
    Expression<int>? localUpdatedAt,
    Expression<String>? displayName,
    Expression<String>? baseCurrency,
    Expression<int>? currencyExponent,
    Expression<String>? timeZone,
    Expression<bool>? onboardingComplete,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (id != null) 'id': id,
      if (revision != null) 'revision': revision,
      if (createdAt != null) 'created_at': createdAt,
      if (serverUpdatedAt != null) 'server_updated_at': serverUpdatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (localVersion != null) 'local_version': localVersion,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (localCreatedAt != null) 'local_created_at': localCreatedAt,
      if (localUpdatedAt != null) 'local_updated_at': localUpdatedAt,
      if (displayName != null) 'display_name': displayName,
      if (baseCurrency != null) 'base_currency': baseCurrency,
      if (currencyExponent != null) 'currency_exponent': currencyExponent,
      if (timeZone != null) 'time_zone': timeZone,
      if (onboardingComplete != null) 'onboarding_complete': onboardingComplete,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProfilesCompanion copyWith({
    Value<String>? userId,
    Value<String>? id,
    Value<int>? revision,
    Value<int?>? createdAt,
    Value<int?>? serverUpdatedAt,
    Value<int?>? deletedAt,
    Value<int>? localVersion,
    Value<String>? syncStatus,
    Value<int>? localCreatedAt,
    Value<int>? localUpdatedAt,
    Value<String>? displayName,
    Value<String>? baseCurrency,
    Value<int>? currencyExponent,
    Value<String>? timeZone,
    Value<bool>? onboardingComplete,
    Value<int>? rowid,
  }) {
    return ProfilesCompanion(
      userId: userId ?? this.userId,
      id: id ?? this.id,
      revision: revision ?? this.revision,
      createdAt: createdAt ?? this.createdAt,
      serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      localVersion: localVersion ?? this.localVersion,
      syncStatus: syncStatus ?? this.syncStatus,
      localCreatedAt: localCreatedAt ?? this.localCreatedAt,
      localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
      displayName: displayName ?? this.displayName,
      baseCurrency: baseCurrency ?? this.baseCurrency,
      currencyExponent: currencyExponent ?? this.currencyExponent,
      timeZone: timeZone ?? this.timeZone,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (serverUpdatedAt.present) {
      map['server_updated_at'] = Variable<int>(serverUpdatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (localVersion.present) {
      map['local_version'] = Variable<int>(localVersion.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (localCreatedAt.present) {
      map['local_created_at'] = Variable<int>(localCreatedAt.value);
    }
    if (localUpdatedAt.present) {
      map['local_updated_at'] = Variable<int>(localUpdatedAt.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (baseCurrency.present) {
      map['base_currency'] = Variable<String>(baseCurrency.value);
    }
    if (currencyExponent.present) {
      map['currency_exponent'] = Variable<int>(currencyExponent.value);
    }
    if (timeZone.present) {
      map['time_zone'] = Variable<String>(timeZone.value);
    }
    if (onboardingComplete.present) {
      map['onboarding_complete'] = Variable<bool>(onboardingComplete.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProfilesCompanion(')
          ..write('userId: $userId, ')
          ..write('id: $id, ')
          ..write('revision: $revision, ')
          ..write('createdAt: $createdAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('localVersion: $localVersion, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('localCreatedAt: $localCreatedAt, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('displayName: $displayName, ')
          ..write('baseCurrency: $baseCurrency, ')
          ..write('currencyExponent: $currencyExponent, ')
          ..write('timeZone: $timeZone, ')
          ..write('onboardingComplete: $onboardingComplete, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SettingsRecordsTable extends SettingsRecords
    with TableInfo<$SettingsRecordsTable, SettingsRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _serverUpdatedAtMeta = const VerificationMeta(
    'serverUpdatedAt',
  );
  @override
  late final GeneratedColumn<int> serverUpdatedAt = GeneratedColumn<int>(
    'server_updated_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _localVersionMeta = const VerificationMeta(
    'localVersion',
  );
  @override
  late final GeneratedColumn<int> localVersion = GeneratedColumn<int>(
    'local_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    check: () => syncStatus.isIn(syncStatuses),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('synced'),
  );
  static const VerificationMeta _localCreatedAtMeta = const VerificationMeta(
    'localCreatedAt',
  );
  @override
  late final GeneratedColumn<int> localCreatedAt = GeneratedColumn<int>(
    'local_created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localUpdatedAtMeta = const VerificationMeta(
    'localUpdatedAt',
  );
  @override
  late final GeneratedColumn<int> localUpdatedAt = GeneratedColumn<int>(
    'local_updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _themeMeta = const VerificationMeta('theme');
  @override
  late final GeneratedColumn<String> theme = GeneratedColumn<String>(
    'theme',
    aliasedName,
    false,
    check: () => theme.isIn(const ['system', 'light', 'dark']),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _aiEnabledMeta = const VerificationMeta(
    'aiEnabled',
  );
  @override
  late final GeneratedColumn<bool> aiEnabled = GeneratedColumn<bool>(
    'ai_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("ai_enabled" IN (0, 1))',
    ),
  );
  static const VerificationMeta _dailyReviewEnabledMeta =
      const VerificationMeta('dailyReviewEnabled');
  @override
  late final GeneratedColumn<bool> dailyReviewEnabled = GeneratedColumn<bool>(
    'daily_review_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("daily_review_enabled" IN (0, 1))',
    ),
  );
  static const VerificationMeta _learningEnabledMeta = const VerificationMeta(
    'learningEnabled',
  );
  @override
  late final GeneratedColumn<bool> learningEnabled = GeneratedColumn<bool>(
    'learning_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("learning_enabled" IN (0, 1))',
    ),
  );
  static const VerificationMeta _fallbackEnabledMeta = const VerificationMeta(
    'fallbackEnabled',
  );
  @override
  late final GeneratedColumn<bool> fallbackEnabled = GeneratedColumn<bool>(
    'fallback_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("fallback_enabled" IN (0, 1))',
    ),
  );
  static const VerificationMeta _privacyPolicyVersionMeta =
      const VerificationMeta('privacyPolicyVersion');
  @override
  late final GeneratedColumn<String> privacyPolicyVersion =
      GeneratedColumn<String>(
        'privacy_policy_version',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _providerConsentAtMeta = const VerificationMeta(
    'providerConsentAt',
  );
  @override
  late final GeneratedColumn<int> providerConsentAt = GeneratedColumn<int>(
    'provider_consent_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _defaultExpenseAccountIdMeta =
      const VerificationMeta('defaultExpenseAccountId');
  @override
  late final GeneratedColumn<String> defaultExpenseAccountId =
      GeneratedColumn<String>(
        'default_expense_account_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    userId,
    id,
    revision,
    createdAt,
    serverUpdatedAt,
    deletedAt,
    localVersion,
    syncStatus,
    localCreatedAt,
    localUpdatedAt,
    theme,
    aiEnabled,
    dailyReviewEnabled,
    learningEnabled,
    fallbackEnabled,
    privacyPolicyVersion,
    providerConsentAt,
    defaultExpenseAccountId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<SettingsRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('server_updated_at')) {
      context.handle(
        _serverUpdatedAtMeta,
        serverUpdatedAt.isAcceptableOrUnknown(
          data['server_updated_at']!,
          _serverUpdatedAtMeta,
        ),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('local_version')) {
      context.handle(
        _localVersionMeta,
        localVersion.isAcceptableOrUnknown(
          data['local_version']!,
          _localVersionMeta,
        ),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('local_created_at')) {
      context.handle(
        _localCreatedAtMeta,
        localCreatedAt.isAcceptableOrUnknown(
          data['local_created_at']!,
          _localCreatedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_localCreatedAtMeta);
    }
    if (data.containsKey('local_updated_at')) {
      context.handle(
        _localUpdatedAtMeta,
        localUpdatedAt.isAcceptableOrUnknown(
          data['local_updated_at']!,
          _localUpdatedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_localUpdatedAtMeta);
    }
    if (data.containsKey('theme')) {
      context.handle(
        _themeMeta,
        theme.isAcceptableOrUnknown(data['theme']!, _themeMeta),
      );
    } else if (isInserting) {
      context.missing(_themeMeta);
    }
    if (data.containsKey('ai_enabled')) {
      context.handle(
        _aiEnabledMeta,
        aiEnabled.isAcceptableOrUnknown(data['ai_enabled']!, _aiEnabledMeta),
      );
    } else if (isInserting) {
      context.missing(_aiEnabledMeta);
    }
    if (data.containsKey('daily_review_enabled')) {
      context.handle(
        _dailyReviewEnabledMeta,
        dailyReviewEnabled.isAcceptableOrUnknown(
          data['daily_review_enabled']!,
          _dailyReviewEnabledMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dailyReviewEnabledMeta);
    }
    if (data.containsKey('learning_enabled')) {
      context.handle(
        _learningEnabledMeta,
        learningEnabled.isAcceptableOrUnknown(
          data['learning_enabled']!,
          _learningEnabledMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_learningEnabledMeta);
    }
    if (data.containsKey('fallback_enabled')) {
      context.handle(
        _fallbackEnabledMeta,
        fallbackEnabled.isAcceptableOrUnknown(
          data['fallback_enabled']!,
          _fallbackEnabledMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fallbackEnabledMeta);
    }
    if (data.containsKey('privacy_policy_version')) {
      context.handle(
        _privacyPolicyVersionMeta,
        privacyPolicyVersion.isAcceptableOrUnknown(
          data['privacy_policy_version']!,
          _privacyPolicyVersionMeta,
        ),
      );
    }
    if (data.containsKey('provider_consent_at')) {
      context.handle(
        _providerConsentAtMeta,
        providerConsentAt.isAcceptableOrUnknown(
          data['provider_consent_at']!,
          _providerConsentAtMeta,
        ),
      );
    }
    if (data.containsKey('default_expense_account_id')) {
      context.handle(
        _defaultExpenseAccountIdMeta,
        defaultExpenseAccountId.isAcceptableOrUnknown(
          data['default_expense_account_id']!,
          _defaultExpenseAccountIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId, id};
  @override
  SettingsRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SettingsRow(
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      ),
      serverUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_updated_at'],
      ),
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      localVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}local_version'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      localCreatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}local_created_at'],
      )!,
      localUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}local_updated_at'],
      )!,
      theme: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}theme'],
      )!,
      aiEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}ai_enabled'],
      )!,
      dailyReviewEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}daily_review_enabled'],
      )!,
      learningEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}learning_enabled'],
      )!,
      fallbackEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}fallback_enabled'],
      )!,
      privacyPolicyVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}privacy_policy_version'],
      ),
      providerConsentAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}provider_consent_at'],
      ),
      defaultExpenseAccountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}default_expense_account_id'],
      ),
    );
  }

  @override
  $SettingsRecordsTable createAlias(String alias) {
    return $SettingsRecordsTable(attachedDatabase, alias);
  }
}

class SettingsRow extends DataClass implements Insertable<SettingsRow> {
  final String userId;
  final String id;

  /// Last accepted remote revision (0 = never accepted).
  final int revision;
  final int? createdAt;
  final int? serverUpdatedAt;
  final int? deletedAt;
  final int localVersion;
  final String syncStatus;
  final int localCreatedAt;
  final int localUpdatedAt;
  final String theme;
  final bool aiEnabled;
  final bool dailyReviewEnabled;
  final bool learningEnabled;
  final bool fallbackEnabled;
  final String? privacyPolicyVersion;
  final int? providerConsentAt;
  final String? defaultExpenseAccountId;
  const SettingsRow({
    required this.userId,
    required this.id,
    required this.revision,
    this.createdAt,
    this.serverUpdatedAt,
    this.deletedAt,
    required this.localVersion,
    required this.syncStatus,
    required this.localCreatedAt,
    required this.localUpdatedAt,
    required this.theme,
    required this.aiEnabled,
    required this.dailyReviewEnabled,
    required this.learningEnabled,
    required this.fallbackEnabled,
    this.privacyPolicyVersion,
    this.providerConsentAt,
    this.defaultExpenseAccountId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<String>(userId);
    map['id'] = Variable<String>(id);
    map['revision'] = Variable<int>(revision);
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<int>(createdAt);
    }
    if (!nullToAbsent || serverUpdatedAt != null) {
      map['server_updated_at'] = Variable<int>(serverUpdatedAt);
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['local_version'] = Variable<int>(localVersion);
    map['sync_status'] = Variable<String>(syncStatus);
    map['local_created_at'] = Variable<int>(localCreatedAt);
    map['local_updated_at'] = Variable<int>(localUpdatedAt);
    map['theme'] = Variable<String>(theme);
    map['ai_enabled'] = Variable<bool>(aiEnabled);
    map['daily_review_enabled'] = Variable<bool>(dailyReviewEnabled);
    map['learning_enabled'] = Variable<bool>(learningEnabled);
    map['fallback_enabled'] = Variable<bool>(fallbackEnabled);
    if (!nullToAbsent || privacyPolicyVersion != null) {
      map['privacy_policy_version'] = Variable<String>(privacyPolicyVersion);
    }
    if (!nullToAbsent || providerConsentAt != null) {
      map['provider_consent_at'] = Variable<int>(providerConsentAt);
    }
    if (!nullToAbsent || defaultExpenseAccountId != null) {
      map['default_expense_account_id'] = Variable<String>(
        defaultExpenseAccountId,
      );
    }
    return map;
  }

  SettingsRecordsCompanion toCompanion(bool nullToAbsent) {
    return SettingsRecordsCompanion(
      userId: Value(userId),
      id: Value(id),
      revision: Value(revision),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      serverUpdatedAt: serverUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(serverUpdatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      localVersion: Value(localVersion),
      syncStatus: Value(syncStatus),
      localCreatedAt: Value(localCreatedAt),
      localUpdatedAt: Value(localUpdatedAt),
      theme: Value(theme),
      aiEnabled: Value(aiEnabled),
      dailyReviewEnabled: Value(dailyReviewEnabled),
      learningEnabled: Value(learningEnabled),
      fallbackEnabled: Value(fallbackEnabled),
      privacyPolicyVersion: privacyPolicyVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(privacyPolicyVersion),
      providerConsentAt: providerConsentAt == null && nullToAbsent
          ? const Value.absent()
          : Value(providerConsentAt),
      defaultExpenseAccountId: defaultExpenseAccountId == null && nullToAbsent
          ? const Value.absent()
          : Value(defaultExpenseAccountId),
    );
  }

  factory SettingsRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SettingsRow(
      userId: serializer.fromJson<String>(json['userId']),
      id: serializer.fromJson<String>(json['id']),
      revision: serializer.fromJson<int>(json['revision']),
      createdAt: serializer.fromJson<int?>(json['createdAt']),
      serverUpdatedAt: serializer.fromJson<int?>(json['serverUpdatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      localVersion: serializer.fromJson<int>(json['localVersion']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      localCreatedAt: serializer.fromJson<int>(json['localCreatedAt']),
      localUpdatedAt: serializer.fromJson<int>(json['localUpdatedAt']),
      theme: serializer.fromJson<String>(json['theme']),
      aiEnabled: serializer.fromJson<bool>(json['aiEnabled']),
      dailyReviewEnabled: serializer.fromJson<bool>(json['dailyReviewEnabled']),
      learningEnabled: serializer.fromJson<bool>(json['learningEnabled']),
      fallbackEnabled: serializer.fromJson<bool>(json['fallbackEnabled']),
      privacyPolicyVersion: serializer.fromJson<String?>(
        json['privacyPolicyVersion'],
      ),
      providerConsentAt: serializer.fromJson<int?>(json['providerConsentAt']),
      defaultExpenseAccountId: serializer.fromJson<String?>(
        json['defaultExpenseAccountId'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<String>(userId),
      'id': serializer.toJson<String>(id),
      'revision': serializer.toJson<int>(revision),
      'createdAt': serializer.toJson<int?>(createdAt),
      'serverUpdatedAt': serializer.toJson<int?>(serverUpdatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'localVersion': serializer.toJson<int>(localVersion),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'localCreatedAt': serializer.toJson<int>(localCreatedAt),
      'localUpdatedAt': serializer.toJson<int>(localUpdatedAt),
      'theme': serializer.toJson<String>(theme),
      'aiEnabled': serializer.toJson<bool>(aiEnabled),
      'dailyReviewEnabled': serializer.toJson<bool>(dailyReviewEnabled),
      'learningEnabled': serializer.toJson<bool>(learningEnabled),
      'fallbackEnabled': serializer.toJson<bool>(fallbackEnabled),
      'privacyPolicyVersion': serializer.toJson<String?>(privacyPolicyVersion),
      'providerConsentAt': serializer.toJson<int?>(providerConsentAt),
      'defaultExpenseAccountId': serializer.toJson<String?>(
        defaultExpenseAccountId,
      ),
    };
  }

  SettingsRow copyWith({
    String? userId,
    String? id,
    int? revision,
    Value<int?> createdAt = const Value.absent(),
    Value<int?> serverUpdatedAt = const Value.absent(),
    Value<int?> deletedAt = const Value.absent(),
    int? localVersion,
    String? syncStatus,
    int? localCreatedAt,
    int? localUpdatedAt,
    String? theme,
    bool? aiEnabled,
    bool? dailyReviewEnabled,
    bool? learningEnabled,
    bool? fallbackEnabled,
    Value<String?> privacyPolicyVersion = const Value.absent(),
    Value<int?> providerConsentAt = const Value.absent(),
    Value<String?> defaultExpenseAccountId = const Value.absent(),
  }) => SettingsRow(
    userId: userId ?? this.userId,
    id: id ?? this.id,
    revision: revision ?? this.revision,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
    serverUpdatedAt: serverUpdatedAt.present
        ? serverUpdatedAt.value
        : this.serverUpdatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    localVersion: localVersion ?? this.localVersion,
    syncStatus: syncStatus ?? this.syncStatus,
    localCreatedAt: localCreatedAt ?? this.localCreatedAt,
    localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
    theme: theme ?? this.theme,
    aiEnabled: aiEnabled ?? this.aiEnabled,
    dailyReviewEnabled: dailyReviewEnabled ?? this.dailyReviewEnabled,
    learningEnabled: learningEnabled ?? this.learningEnabled,
    fallbackEnabled: fallbackEnabled ?? this.fallbackEnabled,
    privacyPolicyVersion: privacyPolicyVersion.present
        ? privacyPolicyVersion.value
        : this.privacyPolicyVersion,
    providerConsentAt: providerConsentAt.present
        ? providerConsentAt.value
        : this.providerConsentAt,
    defaultExpenseAccountId: defaultExpenseAccountId.present
        ? defaultExpenseAccountId.value
        : this.defaultExpenseAccountId,
  );
  SettingsRow copyWithCompanion(SettingsRecordsCompanion data) {
    return SettingsRow(
      userId: data.userId.present ? data.userId.value : this.userId,
      id: data.id.present ? data.id.value : this.id,
      revision: data.revision.present ? data.revision.value : this.revision,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      serverUpdatedAt: data.serverUpdatedAt.present
          ? data.serverUpdatedAt.value
          : this.serverUpdatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      localVersion: data.localVersion.present
          ? data.localVersion.value
          : this.localVersion,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      localCreatedAt: data.localCreatedAt.present
          ? data.localCreatedAt.value
          : this.localCreatedAt,
      localUpdatedAt: data.localUpdatedAt.present
          ? data.localUpdatedAt.value
          : this.localUpdatedAt,
      theme: data.theme.present ? data.theme.value : this.theme,
      aiEnabled: data.aiEnabled.present ? data.aiEnabled.value : this.aiEnabled,
      dailyReviewEnabled: data.dailyReviewEnabled.present
          ? data.dailyReviewEnabled.value
          : this.dailyReviewEnabled,
      learningEnabled: data.learningEnabled.present
          ? data.learningEnabled.value
          : this.learningEnabled,
      fallbackEnabled: data.fallbackEnabled.present
          ? data.fallbackEnabled.value
          : this.fallbackEnabled,
      privacyPolicyVersion: data.privacyPolicyVersion.present
          ? data.privacyPolicyVersion.value
          : this.privacyPolicyVersion,
      providerConsentAt: data.providerConsentAt.present
          ? data.providerConsentAt.value
          : this.providerConsentAt,
      defaultExpenseAccountId: data.defaultExpenseAccountId.present
          ? data.defaultExpenseAccountId.value
          : this.defaultExpenseAccountId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SettingsRow(')
          ..write('userId: $userId, ')
          ..write('id: $id, ')
          ..write('revision: $revision, ')
          ..write('createdAt: $createdAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('localVersion: $localVersion, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('localCreatedAt: $localCreatedAt, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('theme: $theme, ')
          ..write('aiEnabled: $aiEnabled, ')
          ..write('dailyReviewEnabled: $dailyReviewEnabled, ')
          ..write('learningEnabled: $learningEnabled, ')
          ..write('fallbackEnabled: $fallbackEnabled, ')
          ..write('privacyPolicyVersion: $privacyPolicyVersion, ')
          ..write('providerConsentAt: $providerConsentAt, ')
          ..write('defaultExpenseAccountId: $defaultExpenseAccountId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    userId,
    id,
    revision,
    createdAt,
    serverUpdatedAt,
    deletedAt,
    localVersion,
    syncStatus,
    localCreatedAt,
    localUpdatedAt,
    theme,
    aiEnabled,
    dailyReviewEnabled,
    learningEnabled,
    fallbackEnabled,
    privacyPolicyVersion,
    providerConsentAt,
    defaultExpenseAccountId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SettingsRow &&
          other.userId == this.userId &&
          other.id == this.id &&
          other.revision == this.revision &&
          other.createdAt == this.createdAt &&
          other.serverUpdatedAt == this.serverUpdatedAt &&
          other.deletedAt == this.deletedAt &&
          other.localVersion == this.localVersion &&
          other.syncStatus == this.syncStatus &&
          other.localCreatedAt == this.localCreatedAt &&
          other.localUpdatedAt == this.localUpdatedAt &&
          other.theme == this.theme &&
          other.aiEnabled == this.aiEnabled &&
          other.dailyReviewEnabled == this.dailyReviewEnabled &&
          other.learningEnabled == this.learningEnabled &&
          other.fallbackEnabled == this.fallbackEnabled &&
          other.privacyPolicyVersion == this.privacyPolicyVersion &&
          other.providerConsentAt == this.providerConsentAt &&
          other.defaultExpenseAccountId == this.defaultExpenseAccountId);
}

class SettingsRecordsCompanion extends UpdateCompanion<SettingsRow> {
  final Value<String> userId;
  final Value<String> id;
  final Value<int> revision;
  final Value<int?> createdAt;
  final Value<int?> serverUpdatedAt;
  final Value<int?> deletedAt;
  final Value<int> localVersion;
  final Value<String> syncStatus;
  final Value<int> localCreatedAt;
  final Value<int> localUpdatedAt;
  final Value<String> theme;
  final Value<bool> aiEnabled;
  final Value<bool> dailyReviewEnabled;
  final Value<bool> learningEnabled;
  final Value<bool> fallbackEnabled;
  final Value<String?> privacyPolicyVersion;
  final Value<int?> providerConsentAt;
  final Value<String?> defaultExpenseAccountId;
  final Value<int> rowid;
  const SettingsRecordsCompanion({
    this.userId = const Value.absent(),
    this.id = const Value.absent(),
    this.revision = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.localVersion = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.localCreatedAt = const Value.absent(),
    this.localUpdatedAt = const Value.absent(),
    this.theme = const Value.absent(),
    this.aiEnabled = const Value.absent(),
    this.dailyReviewEnabled = const Value.absent(),
    this.learningEnabled = const Value.absent(),
    this.fallbackEnabled = const Value.absent(),
    this.privacyPolicyVersion = const Value.absent(),
    this.providerConsentAt = const Value.absent(),
    this.defaultExpenseAccountId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsRecordsCompanion.insert({
    required String userId,
    required String id,
    this.revision = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.localVersion = const Value.absent(),
    this.syncStatus = const Value.absent(),
    required int localCreatedAt,
    required int localUpdatedAt,
    required String theme,
    required bool aiEnabled,
    required bool dailyReviewEnabled,
    required bool learningEnabled,
    required bool fallbackEnabled,
    this.privacyPolicyVersion = const Value.absent(),
    this.providerConsentAt = const Value.absent(),
    this.defaultExpenseAccountId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : userId = Value(userId),
       id = Value(id),
       localCreatedAt = Value(localCreatedAt),
       localUpdatedAt = Value(localUpdatedAt),
       theme = Value(theme),
       aiEnabled = Value(aiEnabled),
       dailyReviewEnabled = Value(dailyReviewEnabled),
       learningEnabled = Value(learningEnabled),
       fallbackEnabled = Value(fallbackEnabled);
  static Insertable<SettingsRow> custom({
    Expression<String>? userId,
    Expression<String>? id,
    Expression<int>? revision,
    Expression<int>? createdAt,
    Expression<int>? serverUpdatedAt,
    Expression<int>? deletedAt,
    Expression<int>? localVersion,
    Expression<String>? syncStatus,
    Expression<int>? localCreatedAt,
    Expression<int>? localUpdatedAt,
    Expression<String>? theme,
    Expression<bool>? aiEnabled,
    Expression<bool>? dailyReviewEnabled,
    Expression<bool>? learningEnabled,
    Expression<bool>? fallbackEnabled,
    Expression<String>? privacyPolicyVersion,
    Expression<int>? providerConsentAt,
    Expression<String>? defaultExpenseAccountId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (id != null) 'id': id,
      if (revision != null) 'revision': revision,
      if (createdAt != null) 'created_at': createdAt,
      if (serverUpdatedAt != null) 'server_updated_at': serverUpdatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (localVersion != null) 'local_version': localVersion,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (localCreatedAt != null) 'local_created_at': localCreatedAt,
      if (localUpdatedAt != null) 'local_updated_at': localUpdatedAt,
      if (theme != null) 'theme': theme,
      if (aiEnabled != null) 'ai_enabled': aiEnabled,
      if (dailyReviewEnabled != null)
        'daily_review_enabled': dailyReviewEnabled,
      if (learningEnabled != null) 'learning_enabled': learningEnabled,
      if (fallbackEnabled != null) 'fallback_enabled': fallbackEnabled,
      if (privacyPolicyVersion != null)
        'privacy_policy_version': privacyPolicyVersion,
      if (providerConsentAt != null) 'provider_consent_at': providerConsentAt,
      if (defaultExpenseAccountId != null)
        'default_expense_account_id': defaultExpenseAccountId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingsRecordsCompanion copyWith({
    Value<String>? userId,
    Value<String>? id,
    Value<int>? revision,
    Value<int?>? createdAt,
    Value<int?>? serverUpdatedAt,
    Value<int?>? deletedAt,
    Value<int>? localVersion,
    Value<String>? syncStatus,
    Value<int>? localCreatedAt,
    Value<int>? localUpdatedAt,
    Value<String>? theme,
    Value<bool>? aiEnabled,
    Value<bool>? dailyReviewEnabled,
    Value<bool>? learningEnabled,
    Value<bool>? fallbackEnabled,
    Value<String?>? privacyPolicyVersion,
    Value<int?>? providerConsentAt,
    Value<String?>? defaultExpenseAccountId,
    Value<int>? rowid,
  }) {
    return SettingsRecordsCompanion(
      userId: userId ?? this.userId,
      id: id ?? this.id,
      revision: revision ?? this.revision,
      createdAt: createdAt ?? this.createdAt,
      serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      localVersion: localVersion ?? this.localVersion,
      syncStatus: syncStatus ?? this.syncStatus,
      localCreatedAt: localCreatedAt ?? this.localCreatedAt,
      localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
      theme: theme ?? this.theme,
      aiEnabled: aiEnabled ?? this.aiEnabled,
      dailyReviewEnabled: dailyReviewEnabled ?? this.dailyReviewEnabled,
      learningEnabled: learningEnabled ?? this.learningEnabled,
      fallbackEnabled: fallbackEnabled ?? this.fallbackEnabled,
      privacyPolicyVersion: privacyPolicyVersion ?? this.privacyPolicyVersion,
      providerConsentAt: providerConsentAt ?? this.providerConsentAt,
      defaultExpenseAccountId:
          defaultExpenseAccountId ?? this.defaultExpenseAccountId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (serverUpdatedAt.present) {
      map['server_updated_at'] = Variable<int>(serverUpdatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (localVersion.present) {
      map['local_version'] = Variable<int>(localVersion.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (localCreatedAt.present) {
      map['local_created_at'] = Variable<int>(localCreatedAt.value);
    }
    if (localUpdatedAt.present) {
      map['local_updated_at'] = Variable<int>(localUpdatedAt.value);
    }
    if (theme.present) {
      map['theme'] = Variable<String>(theme.value);
    }
    if (aiEnabled.present) {
      map['ai_enabled'] = Variable<bool>(aiEnabled.value);
    }
    if (dailyReviewEnabled.present) {
      map['daily_review_enabled'] = Variable<bool>(dailyReviewEnabled.value);
    }
    if (learningEnabled.present) {
      map['learning_enabled'] = Variable<bool>(learningEnabled.value);
    }
    if (fallbackEnabled.present) {
      map['fallback_enabled'] = Variable<bool>(fallbackEnabled.value);
    }
    if (privacyPolicyVersion.present) {
      map['privacy_policy_version'] = Variable<String>(
        privacyPolicyVersion.value,
      );
    }
    if (providerConsentAt.present) {
      map['provider_consent_at'] = Variable<int>(providerConsentAt.value);
    }
    if (defaultExpenseAccountId.present) {
      map['default_expense_account_id'] = Variable<String>(
        defaultExpenseAccountId.value,
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsRecordsCompanion(')
          ..write('userId: $userId, ')
          ..write('id: $id, ')
          ..write('revision: $revision, ')
          ..write('createdAt: $createdAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('localVersion: $localVersion, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('localCreatedAt: $localCreatedAt, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('theme: $theme, ')
          ..write('aiEnabled: $aiEnabled, ')
          ..write('dailyReviewEnabled: $dailyReviewEnabled, ')
          ..write('learningEnabled: $learningEnabled, ')
          ..write('fallbackEnabled: $fallbackEnabled, ')
          ..write('privacyPolicyVersion: $privacyPolicyVersion, ')
          ..write('providerConsentAt: $providerConsentAt, ')
          ..write('defaultExpenseAccountId: $defaultExpenseAccountId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AccountsTable extends Accounts
    with TableInfo<$AccountsTable, AccountRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AccountsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _serverUpdatedAtMeta = const VerificationMeta(
    'serverUpdatedAt',
  );
  @override
  late final GeneratedColumn<int> serverUpdatedAt = GeneratedColumn<int>(
    'server_updated_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _localVersionMeta = const VerificationMeta(
    'localVersion',
  );
  @override
  late final GeneratedColumn<int> localVersion = GeneratedColumn<int>(
    'local_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    check: () => syncStatus.isIn(syncStatuses),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('synced'),
  );
  static const VerificationMeta _localCreatedAtMeta = const VerificationMeta(
    'localCreatedAt',
  );
  @override
  late final GeneratedColumn<int> localCreatedAt = GeneratedColumn<int>(
    'local_created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localUpdatedAtMeta = const VerificationMeta(
    'localUpdatedAt',
  );
  @override
  late final GeneratedColumn<int> localUpdatedAt = GeneratedColumn<int>(
    'local_updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    check: () => type.isIn(const ['bank', 'cash', 'wallet', 'savings']),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _archivedMeta = const VerificationMeta(
    'archived',
  );
  @override
  late final GeneratedColumn<bool> archived = GeneratedColumn<bool>(
    'archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("archived" IN (0, 1))',
    ),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    userId,
    id,
    revision,
    createdAt,
    serverUpdatedAt,
    deletedAt,
    localVersion,
    syncStatus,
    localCreatedAt,
    localUpdatedAt,
    name,
    type,
    currency,
    archived,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'accounts';
  @override
  VerificationContext validateIntegrity(
    Insertable<AccountRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('server_updated_at')) {
      context.handle(
        _serverUpdatedAtMeta,
        serverUpdatedAt.isAcceptableOrUnknown(
          data['server_updated_at']!,
          _serverUpdatedAtMeta,
        ),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('local_version')) {
      context.handle(
        _localVersionMeta,
        localVersion.isAcceptableOrUnknown(
          data['local_version']!,
          _localVersionMeta,
        ),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('local_created_at')) {
      context.handle(
        _localCreatedAtMeta,
        localCreatedAt.isAcceptableOrUnknown(
          data['local_created_at']!,
          _localCreatedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_localCreatedAtMeta);
    }
    if (data.containsKey('local_updated_at')) {
      context.handle(
        _localUpdatedAtMeta,
        localUpdatedAt.isAcceptableOrUnknown(
          data['local_updated_at']!,
          _localUpdatedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_localUpdatedAtMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    } else if (isInserting) {
      context.missing(_currencyMeta);
    }
    if (data.containsKey('archived')) {
      context.handle(
        _archivedMeta,
        archived.isAcceptableOrUnknown(data['archived']!, _archivedMeta),
      );
    } else if (isInserting) {
      context.missing(_archivedMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId, id};
  @override
  AccountRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AccountRow(
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      ),
      serverUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_updated_at'],
      ),
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      localVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}local_version'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      localCreatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}local_created_at'],
      )!,
      localUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}local_updated_at'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      archived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}archived'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $AccountsTable createAlias(String alias) {
    return $AccountsTable(attachedDatabase, alias);
  }
}

class AccountRow extends DataClass implements Insertable<AccountRow> {
  final String userId;
  final String id;

  /// Last accepted remote revision (0 = never accepted).
  final int revision;
  final int? createdAt;
  final int? serverUpdatedAt;
  final int? deletedAt;
  final int localVersion;
  final String syncStatus;
  final int localCreatedAt;
  final int localUpdatedAt;
  final String name;
  final String type;
  final String currency;
  final bool archived;
  final int sortOrder;
  const AccountRow({
    required this.userId,
    required this.id,
    required this.revision,
    this.createdAt,
    this.serverUpdatedAt,
    this.deletedAt,
    required this.localVersion,
    required this.syncStatus,
    required this.localCreatedAt,
    required this.localUpdatedAt,
    required this.name,
    required this.type,
    required this.currency,
    required this.archived,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<String>(userId);
    map['id'] = Variable<String>(id);
    map['revision'] = Variable<int>(revision);
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<int>(createdAt);
    }
    if (!nullToAbsent || serverUpdatedAt != null) {
      map['server_updated_at'] = Variable<int>(serverUpdatedAt);
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['local_version'] = Variable<int>(localVersion);
    map['sync_status'] = Variable<String>(syncStatus);
    map['local_created_at'] = Variable<int>(localCreatedAt);
    map['local_updated_at'] = Variable<int>(localUpdatedAt);
    map['name'] = Variable<String>(name);
    map['type'] = Variable<String>(type);
    map['currency'] = Variable<String>(currency);
    map['archived'] = Variable<bool>(archived);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  AccountsCompanion toCompanion(bool nullToAbsent) {
    return AccountsCompanion(
      userId: Value(userId),
      id: Value(id),
      revision: Value(revision),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      serverUpdatedAt: serverUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(serverUpdatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      localVersion: Value(localVersion),
      syncStatus: Value(syncStatus),
      localCreatedAt: Value(localCreatedAt),
      localUpdatedAt: Value(localUpdatedAt),
      name: Value(name),
      type: Value(type),
      currency: Value(currency),
      archived: Value(archived),
      sortOrder: Value(sortOrder),
    );
  }

  factory AccountRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AccountRow(
      userId: serializer.fromJson<String>(json['userId']),
      id: serializer.fromJson<String>(json['id']),
      revision: serializer.fromJson<int>(json['revision']),
      createdAt: serializer.fromJson<int?>(json['createdAt']),
      serverUpdatedAt: serializer.fromJson<int?>(json['serverUpdatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      localVersion: serializer.fromJson<int>(json['localVersion']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      localCreatedAt: serializer.fromJson<int>(json['localCreatedAt']),
      localUpdatedAt: serializer.fromJson<int>(json['localUpdatedAt']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<String>(json['type']),
      currency: serializer.fromJson<String>(json['currency']),
      archived: serializer.fromJson<bool>(json['archived']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<String>(userId),
      'id': serializer.toJson<String>(id),
      'revision': serializer.toJson<int>(revision),
      'createdAt': serializer.toJson<int?>(createdAt),
      'serverUpdatedAt': serializer.toJson<int?>(serverUpdatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'localVersion': serializer.toJson<int>(localVersion),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'localCreatedAt': serializer.toJson<int>(localCreatedAt),
      'localUpdatedAt': serializer.toJson<int>(localUpdatedAt),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(type),
      'currency': serializer.toJson<String>(currency),
      'archived': serializer.toJson<bool>(archived),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  AccountRow copyWith({
    String? userId,
    String? id,
    int? revision,
    Value<int?> createdAt = const Value.absent(),
    Value<int?> serverUpdatedAt = const Value.absent(),
    Value<int?> deletedAt = const Value.absent(),
    int? localVersion,
    String? syncStatus,
    int? localCreatedAt,
    int? localUpdatedAt,
    String? name,
    String? type,
    String? currency,
    bool? archived,
    int? sortOrder,
  }) => AccountRow(
    userId: userId ?? this.userId,
    id: id ?? this.id,
    revision: revision ?? this.revision,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
    serverUpdatedAt: serverUpdatedAt.present
        ? serverUpdatedAt.value
        : this.serverUpdatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    localVersion: localVersion ?? this.localVersion,
    syncStatus: syncStatus ?? this.syncStatus,
    localCreatedAt: localCreatedAt ?? this.localCreatedAt,
    localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
    name: name ?? this.name,
    type: type ?? this.type,
    currency: currency ?? this.currency,
    archived: archived ?? this.archived,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  AccountRow copyWithCompanion(AccountsCompanion data) {
    return AccountRow(
      userId: data.userId.present ? data.userId.value : this.userId,
      id: data.id.present ? data.id.value : this.id,
      revision: data.revision.present ? data.revision.value : this.revision,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      serverUpdatedAt: data.serverUpdatedAt.present
          ? data.serverUpdatedAt.value
          : this.serverUpdatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      localVersion: data.localVersion.present
          ? data.localVersion.value
          : this.localVersion,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      localCreatedAt: data.localCreatedAt.present
          ? data.localCreatedAt.value
          : this.localCreatedAt,
      localUpdatedAt: data.localUpdatedAt.present
          ? data.localUpdatedAt.value
          : this.localUpdatedAt,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      currency: data.currency.present ? data.currency.value : this.currency,
      archived: data.archived.present ? data.archived.value : this.archived,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AccountRow(')
          ..write('userId: $userId, ')
          ..write('id: $id, ')
          ..write('revision: $revision, ')
          ..write('createdAt: $createdAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('localVersion: $localVersion, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('localCreatedAt: $localCreatedAt, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('currency: $currency, ')
          ..write('archived: $archived, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    userId,
    id,
    revision,
    createdAt,
    serverUpdatedAt,
    deletedAt,
    localVersion,
    syncStatus,
    localCreatedAt,
    localUpdatedAt,
    name,
    type,
    currency,
    archived,
    sortOrder,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AccountRow &&
          other.userId == this.userId &&
          other.id == this.id &&
          other.revision == this.revision &&
          other.createdAt == this.createdAt &&
          other.serverUpdatedAt == this.serverUpdatedAt &&
          other.deletedAt == this.deletedAt &&
          other.localVersion == this.localVersion &&
          other.syncStatus == this.syncStatus &&
          other.localCreatedAt == this.localCreatedAt &&
          other.localUpdatedAt == this.localUpdatedAt &&
          other.name == this.name &&
          other.type == this.type &&
          other.currency == this.currency &&
          other.archived == this.archived &&
          other.sortOrder == this.sortOrder);
}

class AccountsCompanion extends UpdateCompanion<AccountRow> {
  final Value<String> userId;
  final Value<String> id;
  final Value<int> revision;
  final Value<int?> createdAt;
  final Value<int?> serverUpdatedAt;
  final Value<int?> deletedAt;
  final Value<int> localVersion;
  final Value<String> syncStatus;
  final Value<int> localCreatedAt;
  final Value<int> localUpdatedAt;
  final Value<String> name;
  final Value<String> type;
  final Value<String> currency;
  final Value<bool> archived;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const AccountsCompanion({
    this.userId = const Value.absent(),
    this.id = const Value.absent(),
    this.revision = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.localVersion = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.localCreatedAt = const Value.absent(),
    this.localUpdatedAt = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.currency = const Value.absent(),
    this.archived = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AccountsCompanion.insert({
    required String userId,
    required String id,
    this.revision = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.localVersion = const Value.absent(),
    this.syncStatus = const Value.absent(),
    required int localCreatedAt,
    required int localUpdatedAt,
    required String name,
    required String type,
    required String currency,
    required bool archived,
    required int sortOrder,
    this.rowid = const Value.absent(),
  }) : userId = Value(userId),
       id = Value(id),
       localCreatedAt = Value(localCreatedAt),
       localUpdatedAt = Value(localUpdatedAt),
       name = Value(name),
       type = Value(type),
       currency = Value(currency),
       archived = Value(archived),
       sortOrder = Value(sortOrder);
  static Insertable<AccountRow> custom({
    Expression<String>? userId,
    Expression<String>? id,
    Expression<int>? revision,
    Expression<int>? createdAt,
    Expression<int>? serverUpdatedAt,
    Expression<int>? deletedAt,
    Expression<int>? localVersion,
    Expression<String>? syncStatus,
    Expression<int>? localCreatedAt,
    Expression<int>? localUpdatedAt,
    Expression<String>? name,
    Expression<String>? type,
    Expression<String>? currency,
    Expression<bool>? archived,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (id != null) 'id': id,
      if (revision != null) 'revision': revision,
      if (createdAt != null) 'created_at': createdAt,
      if (serverUpdatedAt != null) 'server_updated_at': serverUpdatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (localVersion != null) 'local_version': localVersion,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (localCreatedAt != null) 'local_created_at': localCreatedAt,
      if (localUpdatedAt != null) 'local_updated_at': localUpdatedAt,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (currency != null) 'currency': currency,
      if (archived != null) 'archived': archived,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AccountsCompanion copyWith({
    Value<String>? userId,
    Value<String>? id,
    Value<int>? revision,
    Value<int?>? createdAt,
    Value<int?>? serverUpdatedAt,
    Value<int?>? deletedAt,
    Value<int>? localVersion,
    Value<String>? syncStatus,
    Value<int>? localCreatedAt,
    Value<int>? localUpdatedAt,
    Value<String>? name,
    Value<String>? type,
    Value<String>? currency,
    Value<bool>? archived,
    Value<int>? sortOrder,
    Value<int>? rowid,
  }) {
    return AccountsCompanion(
      userId: userId ?? this.userId,
      id: id ?? this.id,
      revision: revision ?? this.revision,
      createdAt: createdAt ?? this.createdAt,
      serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      localVersion: localVersion ?? this.localVersion,
      syncStatus: syncStatus ?? this.syncStatus,
      localCreatedAt: localCreatedAt ?? this.localCreatedAt,
      localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
      name: name ?? this.name,
      type: type ?? this.type,
      currency: currency ?? this.currency,
      archived: archived ?? this.archived,
      sortOrder: sortOrder ?? this.sortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (serverUpdatedAt.present) {
      map['server_updated_at'] = Variable<int>(serverUpdatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (localVersion.present) {
      map['local_version'] = Variable<int>(localVersion.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (localCreatedAt.present) {
      map['local_created_at'] = Variable<int>(localCreatedAt.value);
    }
    if (localUpdatedAt.present) {
      map['local_updated_at'] = Variable<int>(localUpdatedAt.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (archived.present) {
      map['archived'] = Variable<bool>(archived.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AccountsCompanion(')
          ..write('userId: $userId, ')
          ..write('id: $id, ')
          ..write('revision: $revision, ')
          ..write('createdAt: $createdAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('localVersion: $localVersion, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('localCreatedAt: $localCreatedAt, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('currency: $currency, ')
          ..write('archived: $archived, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $IncomeSourcesTable extends IncomeSources
    with TableInfo<$IncomeSourcesTable, IncomeSourceRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IncomeSourcesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _serverUpdatedAtMeta = const VerificationMeta(
    'serverUpdatedAt',
  );
  @override
  late final GeneratedColumn<int> serverUpdatedAt = GeneratedColumn<int>(
    'server_updated_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _localVersionMeta = const VerificationMeta(
    'localVersion',
  );
  @override
  late final GeneratedColumn<int> localVersion = GeneratedColumn<int>(
    'local_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    check: () => syncStatus.isIn(syncStatuses),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('synced'),
  );
  static const VerificationMeta _localCreatedAtMeta = const VerificationMeta(
    'localCreatedAt',
  );
  @override
  late final GeneratedColumn<int> localCreatedAt = GeneratedColumn<int>(
    'local_created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localUpdatedAtMeta = const VerificationMeta(
    'localUpdatedAt',
  );
  @override
  late final GeneratedColumn<int> localUpdatedAt = GeneratedColumn<int>(
    'local_updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    check: () => type.isIn(const [
      'employer',
      'freelance',
      'business',
      'investment',
      'other',
    ]),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _defaultAccountIdMeta = const VerificationMeta(
    'defaultAccountId',
  );
  @override
  late final GeneratedColumn<String> defaultAccountId = GeneratedColumn<String>(
    'default_account_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _archivedMeta = const VerificationMeta(
    'archived',
  );
  @override
  late final GeneratedColumn<bool> archived = GeneratedColumn<bool>(
    'archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("archived" IN (0, 1))',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    userId,
    id,
    revision,
    createdAt,
    serverUpdatedAt,
    deletedAt,
    localVersion,
    syncStatus,
    localCreatedAt,
    localUpdatedAt,
    name,
    type,
    defaultAccountId,
    archived,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'income_sources';
  @override
  VerificationContext validateIntegrity(
    Insertable<IncomeSourceRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('server_updated_at')) {
      context.handle(
        _serverUpdatedAtMeta,
        serverUpdatedAt.isAcceptableOrUnknown(
          data['server_updated_at']!,
          _serverUpdatedAtMeta,
        ),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('local_version')) {
      context.handle(
        _localVersionMeta,
        localVersion.isAcceptableOrUnknown(
          data['local_version']!,
          _localVersionMeta,
        ),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('local_created_at')) {
      context.handle(
        _localCreatedAtMeta,
        localCreatedAt.isAcceptableOrUnknown(
          data['local_created_at']!,
          _localCreatedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_localCreatedAtMeta);
    }
    if (data.containsKey('local_updated_at')) {
      context.handle(
        _localUpdatedAtMeta,
        localUpdatedAt.isAcceptableOrUnknown(
          data['local_updated_at']!,
          _localUpdatedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_localUpdatedAtMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('default_account_id')) {
      context.handle(
        _defaultAccountIdMeta,
        defaultAccountId.isAcceptableOrUnknown(
          data['default_account_id']!,
          _defaultAccountIdMeta,
        ),
      );
    }
    if (data.containsKey('archived')) {
      context.handle(
        _archivedMeta,
        archived.isAcceptableOrUnknown(data['archived']!, _archivedMeta),
      );
    } else if (isInserting) {
      context.missing(_archivedMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId, id};
  @override
  IncomeSourceRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return IncomeSourceRow(
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      ),
      serverUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_updated_at'],
      ),
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      localVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}local_version'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      localCreatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}local_created_at'],
      )!,
      localUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}local_updated_at'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      defaultAccountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}default_account_id'],
      ),
      archived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}archived'],
      )!,
    );
  }

  @override
  $IncomeSourcesTable createAlias(String alias) {
    return $IncomeSourcesTable(attachedDatabase, alias);
  }
}

class IncomeSourceRow extends DataClass implements Insertable<IncomeSourceRow> {
  final String userId;
  final String id;

  /// Last accepted remote revision (0 = never accepted).
  final int revision;
  final int? createdAt;
  final int? serverUpdatedAt;
  final int? deletedAt;
  final int localVersion;
  final String syncStatus;
  final int localCreatedAt;
  final int localUpdatedAt;
  final String name;
  final String type;
  final String? defaultAccountId;
  final bool archived;
  const IncomeSourceRow({
    required this.userId,
    required this.id,
    required this.revision,
    this.createdAt,
    this.serverUpdatedAt,
    this.deletedAt,
    required this.localVersion,
    required this.syncStatus,
    required this.localCreatedAt,
    required this.localUpdatedAt,
    required this.name,
    required this.type,
    this.defaultAccountId,
    required this.archived,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<String>(userId);
    map['id'] = Variable<String>(id);
    map['revision'] = Variable<int>(revision);
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<int>(createdAt);
    }
    if (!nullToAbsent || serverUpdatedAt != null) {
      map['server_updated_at'] = Variable<int>(serverUpdatedAt);
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['local_version'] = Variable<int>(localVersion);
    map['sync_status'] = Variable<String>(syncStatus);
    map['local_created_at'] = Variable<int>(localCreatedAt);
    map['local_updated_at'] = Variable<int>(localUpdatedAt);
    map['name'] = Variable<String>(name);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || defaultAccountId != null) {
      map['default_account_id'] = Variable<String>(defaultAccountId);
    }
    map['archived'] = Variable<bool>(archived);
    return map;
  }

  IncomeSourcesCompanion toCompanion(bool nullToAbsent) {
    return IncomeSourcesCompanion(
      userId: Value(userId),
      id: Value(id),
      revision: Value(revision),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      serverUpdatedAt: serverUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(serverUpdatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      localVersion: Value(localVersion),
      syncStatus: Value(syncStatus),
      localCreatedAt: Value(localCreatedAt),
      localUpdatedAt: Value(localUpdatedAt),
      name: Value(name),
      type: Value(type),
      defaultAccountId: defaultAccountId == null && nullToAbsent
          ? const Value.absent()
          : Value(defaultAccountId),
      archived: Value(archived),
    );
  }

  factory IncomeSourceRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return IncomeSourceRow(
      userId: serializer.fromJson<String>(json['userId']),
      id: serializer.fromJson<String>(json['id']),
      revision: serializer.fromJson<int>(json['revision']),
      createdAt: serializer.fromJson<int?>(json['createdAt']),
      serverUpdatedAt: serializer.fromJson<int?>(json['serverUpdatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      localVersion: serializer.fromJson<int>(json['localVersion']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      localCreatedAt: serializer.fromJson<int>(json['localCreatedAt']),
      localUpdatedAt: serializer.fromJson<int>(json['localUpdatedAt']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<String>(json['type']),
      defaultAccountId: serializer.fromJson<String?>(json['defaultAccountId']),
      archived: serializer.fromJson<bool>(json['archived']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<String>(userId),
      'id': serializer.toJson<String>(id),
      'revision': serializer.toJson<int>(revision),
      'createdAt': serializer.toJson<int?>(createdAt),
      'serverUpdatedAt': serializer.toJson<int?>(serverUpdatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'localVersion': serializer.toJson<int>(localVersion),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'localCreatedAt': serializer.toJson<int>(localCreatedAt),
      'localUpdatedAt': serializer.toJson<int>(localUpdatedAt),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(type),
      'defaultAccountId': serializer.toJson<String?>(defaultAccountId),
      'archived': serializer.toJson<bool>(archived),
    };
  }

  IncomeSourceRow copyWith({
    String? userId,
    String? id,
    int? revision,
    Value<int?> createdAt = const Value.absent(),
    Value<int?> serverUpdatedAt = const Value.absent(),
    Value<int?> deletedAt = const Value.absent(),
    int? localVersion,
    String? syncStatus,
    int? localCreatedAt,
    int? localUpdatedAt,
    String? name,
    String? type,
    Value<String?> defaultAccountId = const Value.absent(),
    bool? archived,
  }) => IncomeSourceRow(
    userId: userId ?? this.userId,
    id: id ?? this.id,
    revision: revision ?? this.revision,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
    serverUpdatedAt: serverUpdatedAt.present
        ? serverUpdatedAt.value
        : this.serverUpdatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    localVersion: localVersion ?? this.localVersion,
    syncStatus: syncStatus ?? this.syncStatus,
    localCreatedAt: localCreatedAt ?? this.localCreatedAt,
    localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
    name: name ?? this.name,
    type: type ?? this.type,
    defaultAccountId: defaultAccountId.present
        ? defaultAccountId.value
        : this.defaultAccountId,
    archived: archived ?? this.archived,
  );
  IncomeSourceRow copyWithCompanion(IncomeSourcesCompanion data) {
    return IncomeSourceRow(
      userId: data.userId.present ? data.userId.value : this.userId,
      id: data.id.present ? data.id.value : this.id,
      revision: data.revision.present ? data.revision.value : this.revision,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      serverUpdatedAt: data.serverUpdatedAt.present
          ? data.serverUpdatedAt.value
          : this.serverUpdatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      localVersion: data.localVersion.present
          ? data.localVersion.value
          : this.localVersion,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      localCreatedAt: data.localCreatedAt.present
          ? data.localCreatedAt.value
          : this.localCreatedAt,
      localUpdatedAt: data.localUpdatedAt.present
          ? data.localUpdatedAt.value
          : this.localUpdatedAt,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      defaultAccountId: data.defaultAccountId.present
          ? data.defaultAccountId.value
          : this.defaultAccountId,
      archived: data.archived.present ? data.archived.value : this.archived,
    );
  }

  @override
  String toString() {
    return (StringBuffer('IncomeSourceRow(')
          ..write('userId: $userId, ')
          ..write('id: $id, ')
          ..write('revision: $revision, ')
          ..write('createdAt: $createdAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('localVersion: $localVersion, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('localCreatedAt: $localCreatedAt, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('defaultAccountId: $defaultAccountId, ')
          ..write('archived: $archived')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    userId,
    id,
    revision,
    createdAt,
    serverUpdatedAt,
    deletedAt,
    localVersion,
    syncStatus,
    localCreatedAt,
    localUpdatedAt,
    name,
    type,
    defaultAccountId,
    archived,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is IncomeSourceRow &&
          other.userId == this.userId &&
          other.id == this.id &&
          other.revision == this.revision &&
          other.createdAt == this.createdAt &&
          other.serverUpdatedAt == this.serverUpdatedAt &&
          other.deletedAt == this.deletedAt &&
          other.localVersion == this.localVersion &&
          other.syncStatus == this.syncStatus &&
          other.localCreatedAt == this.localCreatedAt &&
          other.localUpdatedAt == this.localUpdatedAt &&
          other.name == this.name &&
          other.type == this.type &&
          other.defaultAccountId == this.defaultAccountId &&
          other.archived == this.archived);
}

class IncomeSourcesCompanion extends UpdateCompanion<IncomeSourceRow> {
  final Value<String> userId;
  final Value<String> id;
  final Value<int> revision;
  final Value<int?> createdAt;
  final Value<int?> serverUpdatedAt;
  final Value<int?> deletedAt;
  final Value<int> localVersion;
  final Value<String> syncStatus;
  final Value<int> localCreatedAt;
  final Value<int> localUpdatedAt;
  final Value<String> name;
  final Value<String> type;
  final Value<String?> defaultAccountId;
  final Value<bool> archived;
  final Value<int> rowid;
  const IncomeSourcesCompanion({
    this.userId = const Value.absent(),
    this.id = const Value.absent(),
    this.revision = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.localVersion = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.localCreatedAt = const Value.absent(),
    this.localUpdatedAt = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.defaultAccountId = const Value.absent(),
    this.archived = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  IncomeSourcesCompanion.insert({
    required String userId,
    required String id,
    this.revision = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.localVersion = const Value.absent(),
    this.syncStatus = const Value.absent(),
    required int localCreatedAt,
    required int localUpdatedAt,
    required String name,
    required String type,
    this.defaultAccountId = const Value.absent(),
    required bool archived,
    this.rowid = const Value.absent(),
  }) : userId = Value(userId),
       id = Value(id),
       localCreatedAt = Value(localCreatedAt),
       localUpdatedAt = Value(localUpdatedAt),
       name = Value(name),
       type = Value(type),
       archived = Value(archived);
  static Insertable<IncomeSourceRow> custom({
    Expression<String>? userId,
    Expression<String>? id,
    Expression<int>? revision,
    Expression<int>? createdAt,
    Expression<int>? serverUpdatedAt,
    Expression<int>? deletedAt,
    Expression<int>? localVersion,
    Expression<String>? syncStatus,
    Expression<int>? localCreatedAt,
    Expression<int>? localUpdatedAt,
    Expression<String>? name,
    Expression<String>? type,
    Expression<String>? defaultAccountId,
    Expression<bool>? archived,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (id != null) 'id': id,
      if (revision != null) 'revision': revision,
      if (createdAt != null) 'created_at': createdAt,
      if (serverUpdatedAt != null) 'server_updated_at': serverUpdatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (localVersion != null) 'local_version': localVersion,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (localCreatedAt != null) 'local_created_at': localCreatedAt,
      if (localUpdatedAt != null) 'local_updated_at': localUpdatedAt,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (defaultAccountId != null) 'default_account_id': defaultAccountId,
      if (archived != null) 'archived': archived,
      if (rowid != null) 'rowid': rowid,
    });
  }

  IncomeSourcesCompanion copyWith({
    Value<String>? userId,
    Value<String>? id,
    Value<int>? revision,
    Value<int?>? createdAt,
    Value<int?>? serverUpdatedAt,
    Value<int?>? deletedAt,
    Value<int>? localVersion,
    Value<String>? syncStatus,
    Value<int>? localCreatedAt,
    Value<int>? localUpdatedAt,
    Value<String>? name,
    Value<String>? type,
    Value<String?>? defaultAccountId,
    Value<bool>? archived,
    Value<int>? rowid,
  }) {
    return IncomeSourcesCompanion(
      userId: userId ?? this.userId,
      id: id ?? this.id,
      revision: revision ?? this.revision,
      createdAt: createdAt ?? this.createdAt,
      serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      localVersion: localVersion ?? this.localVersion,
      syncStatus: syncStatus ?? this.syncStatus,
      localCreatedAt: localCreatedAt ?? this.localCreatedAt,
      localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
      name: name ?? this.name,
      type: type ?? this.type,
      defaultAccountId: defaultAccountId ?? this.defaultAccountId,
      archived: archived ?? this.archived,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (serverUpdatedAt.present) {
      map['server_updated_at'] = Variable<int>(serverUpdatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (localVersion.present) {
      map['local_version'] = Variable<int>(localVersion.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (localCreatedAt.present) {
      map['local_created_at'] = Variable<int>(localCreatedAt.value);
    }
    if (localUpdatedAt.present) {
      map['local_updated_at'] = Variable<int>(localUpdatedAt.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (defaultAccountId.present) {
      map['default_account_id'] = Variable<String>(defaultAccountId.value);
    }
    if (archived.present) {
      map['archived'] = Variable<bool>(archived.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IncomeSourcesCompanion(')
          ..write('userId: $userId, ')
          ..write('id: $id, ')
          ..write('revision: $revision, ')
          ..write('createdAt: $createdAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('localVersion: $localVersion, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('localCreatedAt: $localCreatedAt, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('defaultAccountId: $defaultAccountId, ')
          ..write('archived: $archived, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, CategoryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _serverUpdatedAtMeta = const VerificationMeta(
    'serverUpdatedAt',
  );
  @override
  late final GeneratedColumn<int> serverUpdatedAt = GeneratedColumn<int>(
    'server_updated_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _localVersionMeta = const VerificationMeta(
    'localVersion',
  );
  @override
  late final GeneratedColumn<int> localVersion = GeneratedColumn<int>(
    'local_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    check: () => syncStatus.isIn(syncStatuses),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('synced'),
  );
  static const VerificationMeta _localCreatedAtMeta = const VerificationMeta(
    'localCreatedAt',
  );
  @override
  late final GeneratedColumn<int> localCreatedAt = GeneratedColumn<int>(
    'local_created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localUpdatedAtMeta = const VerificationMeta(
    'localUpdatedAt',
  );
  @override
  late final GeneratedColumn<int> localUpdatedAt = GeneratedColumn<int>(
    'local_updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    check: () => type.isIn(const ['income', 'expense']),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _parentIdMeta = const VerificationMeta(
    'parentId',
  );
  @override
  late final GeneratedColumn<String> parentId = GeneratedColumn<String>(
    'parent_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isSystemMeta = const VerificationMeta(
    'isSystem',
  );
  @override
  late final GeneratedColumn<bool> isSystem = GeneratedColumn<bool>(
    'is_system',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_system" IN (0, 1))',
    ),
  );
  static const VerificationMeta _archivedMeta = const VerificationMeta(
    'archived',
  );
  @override
  late final GeneratedColumn<bool> archived = GeneratedColumn<bool>(
    'archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("archived" IN (0, 1))',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    userId,
    id,
    revision,
    createdAt,
    serverUpdatedAt,
    deletedAt,
    localVersion,
    syncStatus,
    localCreatedAt,
    localUpdatedAt,
    name,
    type,
    parentId,
    icon,
    sortOrder,
    isSystem,
    archived,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<CategoryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('server_updated_at')) {
      context.handle(
        _serverUpdatedAtMeta,
        serverUpdatedAt.isAcceptableOrUnknown(
          data['server_updated_at']!,
          _serverUpdatedAtMeta,
        ),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('local_version')) {
      context.handle(
        _localVersionMeta,
        localVersion.isAcceptableOrUnknown(
          data['local_version']!,
          _localVersionMeta,
        ),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('local_created_at')) {
      context.handle(
        _localCreatedAtMeta,
        localCreatedAt.isAcceptableOrUnknown(
          data['local_created_at']!,
          _localCreatedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_localCreatedAtMeta);
    }
    if (data.containsKey('local_updated_at')) {
      context.handle(
        _localUpdatedAtMeta,
        localUpdatedAt.isAcceptableOrUnknown(
          data['local_updated_at']!,
          _localUpdatedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_localUpdatedAtMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('parent_id')) {
      context.handle(
        _parentIdMeta,
        parentId.isAcceptableOrUnknown(data['parent_id']!, _parentIdMeta),
      );
    }
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    if (data.containsKey('is_system')) {
      context.handle(
        _isSystemMeta,
        isSystem.isAcceptableOrUnknown(data['is_system']!, _isSystemMeta),
      );
    } else if (isInserting) {
      context.missing(_isSystemMeta);
    }
    if (data.containsKey('archived')) {
      context.handle(
        _archivedMeta,
        archived.isAcceptableOrUnknown(data['archived']!, _archivedMeta),
      );
    } else if (isInserting) {
      context.missing(_archivedMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId, id};
  @override
  CategoryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CategoryRow(
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      ),
      serverUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_updated_at'],
      ),
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      localVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}local_version'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      localCreatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}local_created_at'],
      )!,
      localUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}local_updated_at'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      parentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parent_id'],
      ),
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon'],
      ),
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      isSystem: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_system'],
      )!,
      archived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}archived'],
      )!,
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }
}

class CategoryRow extends DataClass implements Insertable<CategoryRow> {
  final String userId;
  final String id;

  /// Last accepted remote revision (0 = never accepted).
  final int revision;
  final int? createdAt;
  final int? serverUpdatedAt;
  final int? deletedAt;
  final int localVersion;
  final String syncStatus;
  final int localCreatedAt;
  final int localUpdatedAt;
  final String name;
  final String type;
  final String? parentId;
  final String? icon;
  final int sortOrder;
  final bool isSystem;
  final bool archived;
  const CategoryRow({
    required this.userId,
    required this.id,
    required this.revision,
    this.createdAt,
    this.serverUpdatedAt,
    this.deletedAt,
    required this.localVersion,
    required this.syncStatus,
    required this.localCreatedAt,
    required this.localUpdatedAt,
    required this.name,
    required this.type,
    this.parentId,
    this.icon,
    required this.sortOrder,
    required this.isSystem,
    required this.archived,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<String>(userId);
    map['id'] = Variable<String>(id);
    map['revision'] = Variable<int>(revision);
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<int>(createdAt);
    }
    if (!nullToAbsent || serverUpdatedAt != null) {
      map['server_updated_at'] = Variable<int>(serverUpdatedAt);
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['local_version'] = Variable<int>(localVersion);
    map['sync_status'] = Variable<String>(syncStatus);
    map['local_created_at'] = Variable<int>(localCreatedAt);
    map['local_updated_at'] = Variable<int>(localUpdatedAt);
    map['name'] = Variable<String>(name);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || parentId != null) {
      map['parent_id'] = Variable<String>(parentId);
    }
    if (!nullToAbsent || icon != null) {
      map['icon'] = Variable<String>(icon);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    map['is_system'] = Variable<bool>(isSystem);
    map['archived'] = Variable<bool>(archived);
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      userId: Value(userId),
      id: Value(id),
      revision: Value(revision),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      serverUpdatedAt: serverUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(serverUpdatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      localVersion: Value(localVersion),
      syncStatus: Value(syncStatus),
      localCreatedAt: Value(localCreatedAt),
      localUpdatedAt: Value(localUpdatedAt),
      name: Value(name),
      type: Value(type),
      parentId: parentId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentId),
      icon: icon == null && nullToAbsent ? const Value.absent() : Value(icon),
      sortOrder: Value(sortOrder),
      isSystem: Value(isSystem),
      archived: Value(archived),
    );
  }

  factory CategoryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CategoryRow(
      userId: serializer.fromJson<String>(json['userId']),
      id: serializer.fromJson<String>(json['id']),
      revision: serializer.fromJson<int>(json['revision']),
      createdAt: serializer.fromJson<int?>(json['createdAt']),
      serverUpdatedAt: serializer.fromJson<int?>(json['serverUpdatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      localVersion: serializer.fromJson<int>(json['localVersion']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      localCreatedAt: serializer.fromJson<int>(json['localCreatedAt']),
      localUpdatedAt: serializer.fromJson<int>(json['localUpdatedAt']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<String>(json['type']),
      parentId: serializer.fromJson<String?>(json['parentId']),
      icon: serializer.fromJson<String?>(json['icon']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      isSystem: serializer.fromJson<bool>(json['isSystem']),
      archived: serializer.fromJson<bool>(json['archived']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<String>(userId),
      'id': serializer.toJson<String>(id),
      'revision': serializer.toJson<int>(revision),
      'createdAt': serializer.toJson<int?>(createdAt),
      'serverUpdatedAt': serializer.toJson<int?>(serverUpdatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'localVersion': serializer.toJson<int>(localVersion),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'localCreatedAt': serializer.toJson<int>(localCreatedAt),
      'localUpdatedAt': serializer.toJson<int>(localUpdatedAt),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(type),
      'parentId': serializer.toJson<String?>(parentId),
      'icon': serializer.toJson<String?>(icon),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'isSystem': serializer.toJson<bool>(isSystem),
      'archived': serializer.toJson<bool>(archived),
    };
  }

  CategoryRow copyWith({
    String? userId,
    String? id,
    int? revision,
    Value<int?> createdAt = const Value.absent(),
    Value<int?> serverUpdatedAt = const Value.absent(),
    Value<int?> deletedAt = const Value.absent(),
    int? localVersion,
    String? syncStatus,
    int? localCreatedAt,
    int? localUpdatedAt,
    String? name,
    String? type,
    Value<String?> parentId = const Value.absent(),
    Value<String?> icon = const Value.absent(),
    int? sortOrder,
    bool? isSystem,
    bool? archived,
  }) => CategoryRow(
    userId: userId ?? this.userId,
    id: id ?? this.id,
    revision: revision ?? this.revision,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
    serverUpdatedAt: serverUpdatedAt.present
        ? serverUpdatedAt.value
        : this.serverUpdatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    localVersion: localVersion ?? this.localVersion,
    syncStatus: syncStatus ?? this.syncStatus,
    localCreatedAt: localCreatedAt ?? this.localCreatedAt,
    localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
    name: name ?? this.name,
    type: type ?? this.type,
    parentId: parentId.present ? parentId.value : this.parentId,
    icon: icon.present ? icon.value : this.icon,
    sortOrder: sortOrder ?? this.sortOrder,
    isSystem: isSystem ?? this.isSystem,
    archived: archived ?? this.archived,
  );
  CategoryRow copyWithCompanion(CategoriesCompanion data) {
    return CategoryRow(
      userId: data.userId.present ? data.userId.value : this.userId,
      id: data.id.present ? data.id.value : this.id,
      revision: data.revision.present ? data.revision.value : this.revision,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      serverUpdatedAt: data.serverUpdatedAt.present
          ? data.serverUpdatedAt.value
          : this.serverUpdatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      localVersion: data.localVersion.present
          ? data.localVersion.value
          : this.localVersion,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      localCreatedAt: data.localCreatedAt.present
          ? data.localCreatedAt.value
          : this.localCreatedAt,
      localUpdatedAt: data.localUpdatedAt.present
          ? data.localUpdatedAt.value
          : this.localUpdatedAt,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      parentId: data.parentId.present ? data.parentId.value : this.parentId,
      icon: data.icon.present ? data.icon.value : this.icon,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      isSystem: data.isSystem.present ? data.isSystem.value : this.isSystem,
      archived: data.archived.present ? data.archived.value : this.archived,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CategoryRow(')
          ..write('userId: $userId, ')
          ..write('id: $id, ')
          ..write('revision: $revision, ')
          ..write('createdAt: $createdAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('localVersion: $localVersion, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('localCreatedAt: $localCreatedAt, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('parentId: $parentId, ')
          ..write('icon: $icon, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isSystem: $isSystem, ')
          ..write('archived: $archived')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    userId,
    id,
    revision,
    createdAt,
    serverUpdatedAt,
    deletedAt,
    localVersion,
    syncStatus,
    localCreatedAt,
    localUpdatedAt,
    name,
    type,
    parentId,
    icon,
    sortOrder,
    isSystem,
    archived,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CategoryRow &&
          other.userId == this.userId &&
          other.id == this.id &&
          other.revision == this.revision &&
          other.createdAt == this.createdAt &&
          other.serverUpdatedAt == this.serverUpdatedAt &&
          other.deletedAt == this.deletedAt &&
          other.localVersion == this.localVersion &&
          other.syncStatus == this.syncStatus &&
          other.localCreatedAt == this.localCreatedAt &&
          other.localUpdatedAt == this.localUpdatedAt &&
          other.name == this.name &&
          other.type == this.type &&
          other.parentId == this.parentId &&
          other.icon == this.icon &&
          other.sortOrder == this.sortOrder &&
          other.isSystem == this.isSystem &&
          other.archived == this.archived);
}

class CategoriesCompanion extends UpdateCompanion<CategoryRow> {
  final Value<String> userId;
  final Value<String> id;
  final Value<int> revision;
  final Value<int?> createdAt;
  final Value<int?> serverUpdatedAt;
  final Value<int?> deletedAt;
  final Value<int> localVersion;
  final Value<String> syncStatus;
  final Value<int> localCreatedAt;
  final Value<int> localUpdatedAt;
  final Value<String> name;
  final Value<String> type;
  final Value<String?> parentId;
  final Value<String?> icon;
  final Value<int> sortOrder;
  final Value<bool> isSystem;
  final Value<bool> archived;
  final Value<int> rowid;
  const CategoriesCompanion({
    this.userId = const Value.absent(),
    this.id = const Value.absent(),
    this.revision = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.localVersion = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.localCreatedAt = const Value.absent(),
    this.localUpdatedAt = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.parentId = const Value.absent(),
    this.icon = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.isSystem = const Value.absent(),
    this.archived = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CategoriesCompanion.insert({
    required String userId,
    required String id,
    this.revision = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.localVersion = const Value.absent(),
    this.syncStatus = const Value.absent(),
    required int localCreatedAt,
    required int localUpdatedAt,
    required String name,
    required String type,
    this.parentId = const Value.absent(),
    this.icon = const Value.absent(),
    required int sortOrder,
    required bool isSystem,
    required bool archived,
    this.rowid = const Value.absent(),
  }) : userId = Value(userId),
       id = Value(id),
       localCreatedAt = Value(localCreatedAt),
       localUpdatedAt = Value(localUpdatedAt),
       name = Value(name),
       type = Value(type),
       sortOrder = Value(sortOrder),
       isSystem = Value(isSystem),
       archived = Value(archived);
  static Insertable<CategoryRow> custom({
    Expression<String>? userId,
    Expression<String>? id,
    Expression<int>? revision,
    Expression<int>? createdAt,
    Expression<int>? serverUpdatedAt,
    Expression<int>? deletedAt,
    Expression<int>? localVersion,
    Expression<String>? syncStatus,
    Expression<int>? localCreatedAt,
    Expression<int>? localUpdatedAt,
    Expression<String>? name,
    Expression<String>? type,
    Expression<String>? parentId,
    Expression<String>? icon,
    Expression<int>? sortOrder,
    Expression<bool>? isSystem,
    Expression<bool>? archived,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (id != null) 'id': id,
      if (revision != null) 'revision': revision,
      if (createdAt != null) 'created_at': createdAt,
      if (serverUpdatedAt != null) 'server_updated_at': serverUpdatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (localVersion != null) 'local_version': localVersion,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (localCreatedAt != null) 'local_created_at': localCreatedAt,
      if (localUpdatedAt != null) 'local_updated_at': localUpdatedAt,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (parentId != null) 'parent_id': parentId,
      if (icon != null) 'icon': icon,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (isSystem != null) 'is_system': isSystem,
      if (archived != null) 'archived': archived,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CategoriesCompanion copyWith({
    Value<String>? userId,
    Value<String>? id,
    Value<int>? revision,
    Value<int?>? createdAt,
    Value<int?>? serverUpdatedAt,
    Value<int?>? deletedAt,
    Value<int>? localVersion,
    Value<String>? syncStatus,
    Value<int>? localCreatedAt,
    Value<int>? localUpdatedAt,
    Value<String>? name,
    Value<String>? type,
    Value<String?>? parentId,
    Value<String?>? icon,
    Value<int>? sortOrder,
    Value<bool>? isSystem,
    Value<bool>? archived,
    Value<int>? rowid,
  }) {
    return CategoriesCompanion(
      userId: userId ?? this.userId,
      id: id ?? this.id,
      revision: revision ?? this.revision,
      createdAt: createdAt ?? this.createdAt,
      serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      localVersion: localVersion ?? this.localVersion,
      syncStatus: syncStatus ?? this.syncStatus,
      localCreatedAt: localCreatedAt ?? this.localCreatedAt,
      localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
      name: name ?? this.name,
      type: type ?? this.type,
      parentId: parentId ?? this.parentId,
      icon: icon ?? this.icon,
      sortOrder: sortOrder ?? this.sortOrder,
      isSystem: isSystem ?? this.isSystem,
      archived: archived ?? this.archived,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (serverUpdatedAt.present) {
      map['server_updated_at'] = Variable<int>(serverUpdatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (localVersion.present) {
      map['local_version'] = Variable<int>(localVersion.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (localCreatedAt.present) {
      map['local_created_at'] = Variable<int>(localCreatedAt.value);
    }
    if (localUpdatedAt.present) {
      map['local_updated_at'] = Variable<int>(localUpdatedAt.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (parentId.present) {
      map['parent_id'] = Variable<String>(parentId.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (isSystem.present) {
      map['is_system'] = Variable<bool>(isSystem.value);
    }
    if (archived.present) {
      map['archived'] = Variable<bool>(archived.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('userId: $userId, ')
          ..write('id: $id, ')
          ..write('revision: $revision, ')
          ..write('createdAt: $createdAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('localVersion: $localVersion, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('localCreatedAt: $localCreatedAt, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('parentId: $parentId, ')
          ..write('icon: $icon, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isSystem: $isSystem, ')
          ..write('archived: $archived, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TransactionsTable extends Transactions
    with TableInfo<$TransactionsTable, TransactionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _serverUpdatedAtMeta = const VerificationMeta(
    'serverUpdatedAt',
  );
  @override
  late final GeneratedColumn<int> serverUpdatedAt = GeneratedColumn<int>(
    'server_updated_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _localVersionMeta = const VerificationMeta(
    'localVersion',
  );
  @override
  late final GeneratedColumn<int> localVersion = GeneratedColumn<int>(
    'local_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    check: () => syncStatus.isIn(syncStatuses),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('synced'),
  );
  static const VerificationMeta _localCreatedAtMeta = const VerificationMeta(
    'localCreatedAt',
  );
  @override
  late final GeneratedColumn<int> localCreatedAt = GeneratedColumn<int>(
    'local_created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localUpdatedAtMeta = const VerificationMeta(
    'localUpdatedAt',
  );
  @override
  late final GeneratedColumn<int> localUpdatedAt = GeneratedColumn<int>(
    'local_updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    check: () => type.isIn(const ['income', 'expense', 'transfer', 'opening']),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMinorMeta = const VerificationMeta(
    'amountMinor',
  );
  @override
  late final GeneratedColumn<int> amountMinor = GeneratedColumn<int>(
    'amount_minor',
    aliasedName,
    false,
    check: () => ComparableExpr(amountMinor).isBetweenValues(0, 1000000000000),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
    'account_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _destinationAccountIdMeta =
      const VerificationMeta('destinationAccountId');
  @override
  late final GeneratedColumn<String> destinationAccountId =
      GeneratedColumn<String>(
        'destination_account_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _incomeSourceIdMeta = const VerificationMeta(
    'incomeSourceId',
  );
  @override
  late final GeneratedColumn<String> incomeSourceId = GeneratedColumn<String>(
    'income_source_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _merchantMeta = const VerificationMeta(
    'merchant',
  );
  @override
  late final GeneratedColumn<String> merchant = GeneratedColumn<String>(
    'merchant',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  static const VerificationMeta _occurredAtMeta = const VerificationMeta(
    'occurredAt',
  );
  @override
  late final GeneratedColumn<int> occurredAt = GeneratedColumn<int>(
    'occurred_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _effectiveDateMeta = const VerificationMeta(
    'effectiveDate',
  );
  @override
  late final GeneratedColumn<String> effectiveDate = GeneratedColumn<String>(
    'effective_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entryTimeZoneMeta = const VerificationMeta(
    'entryTimeZone',
  );
  @override
  late final GeneratedColumn<String> entryTimeZone = GeneratedColumn<String>(
    'entry_time_zone',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _originMeta = const VerificationMeta('origin');
  @override
  late final GeneratedColumn<String> origin = GeneratedColumn<String>(
    'origin',
    aliasedName,
    false,
    check: () => origin.isIn(const ['manual', 'aiInput', 'opening']),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categorizationSourceMeta =
      const VerificationMeta('categorizationSource');
  @override
  late final GeneratedColumn<String> categorizationSource =
      GeneratedColumn<String>(
        'categorization_source',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _proposalIdMeta = const VerificationMeta(
    'proposalId',
  );
  @override
  late final GeneratedColumn<String> proposalId = GeneratedColumn<String>(
    'proposal_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _openingDirectionMeta = const VerificationMeta(
    'openingDirection',
  );
  @override
  late final GeneratedColumn<String> openingDirection = GeneratedColumn<String>(
    'opening_direction',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    userId,
    id,
    revision,
    createdAt,
    serverUpdatedAt,
    deletedAt,
    localVersion,
    syncStatus,
    localCreatedAt,
    localUpdatedAt,
    type,
    amountMinor,
    currency,
    accountId,
    destinationAccountId,
    incomeSourceId,
    categoryId,
    merchant,
    description,
    occurredAt,
    effectiveDate,
    entryTimeZone,
    origin,
    categorizationSource,
    proposalId,
    openingDirection,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transactions';
  @override
  VerificationContext validateIntegrity(
    Insertable<TransactionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('server_updated_at')) {
      context.handle(
        _serverUpdatedAtMeta,
        serverUpdatedAt.isAcceptableOrUnknown(
          data['server_updated_at']!,
          _serverUpdatedAtMeta,
        ),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('local_version')) {
      context.handle(
        _localVersionMeta,
        localVersion.isAcceptableOrUnknown(
          data['local_version']!,
          _localVersionMeta,
        ),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('local_created_at')) {
      context.handle(
        _localCreatedAtMeta,
        localCreatedAt.isAcceptableOrUnknown(
          data['local_created_at']!,
          _localCreatedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_localCreatedAtMeta);
    }
    if (data.containsKey('local_updated_at')) {
      context.handle(
        _localUpdatedAtMeta,
        localUpdatedAt.isAcceptableOrUnknown(
          data['local_updated_at']!,
          _localUpdatedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_localUpdatedAtMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('amount_minor')) {
      context.handle(
        _amountMinorMeta,
        amountMinor.isAcceptableOrUnknown(
          data['amount_minor']!,
          _amountMinorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountMinorMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    } else if (isInserting) {
      context.missing(_currencyMeta);
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('destination_account_id')) {
      context.handle(
        _destinationAccountIdMeta,
        destinationAccountId.isAcceptableOrUnknown(
          data['destination_account_id']!,
          _destinationAccountIdMeta,
        ),
      );
    }
    if (data.containsKey('income_source_id')) {
      context.handle(
        _incomeSourceIdMeta,
        incomeSourceId.isAcceptableOrUnknown(
          data['income_source_id']!,
          _incomeSourceIdMeta,
        ),
      );
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    }
    if (data.containsKey('merchant')) {
      context.handle(
        _merchantMeta,
        merchant.isAcceptableOrUnknown(data['merchant']!, _merchantMeta),
      );
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
    if (data.containsKey('occurred_at')) {
      context.handle(
        _occurredAtMeta,
        occurredAt.isAcceptableOrUnknown(data['occurred_at']!, _occurredAtMeta),
      );
    } else if (isInserting) {
      context.missing(_occurredAtMeta);
    }
    if (data.containsKey('effective_date')) {
      context.handle(
        _effectiveDateMeta,
        effectiveDate.isAcceptableOrUnknown(
          data['effective_date']!,
          _effectiveDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_effectiveDateMeta);
    }
    if (data.containsKey('entry_time_zone')) {
      context.handle(
        _entryTimeZoneMeta,
        entryTimeZone.isAcceptableOrUnknown(
          data['entry_time_zone']!,
          _entryTimeZoneMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_entryTimeZoneMeta);
    }
    if (data.containsKey('origin')) {
      context.handle(
        _originMeta,
        origin.isAcceptableOrUnknown(data['origin']!, _originMeta),
      );
    } else if (isInserting) {
      context.missing(_originMeta);
    }
    if (data.containsKey('categorization_source')) {
      context.handle(
        _categorizationSourceMeta,
        categorizationSource.isAcceptableOrUnknown(
          data['categorization_source']!,
          _categorizationSourceMeta,
        ),
      );
    }
    if (data.containsKey('proposal_id')) {
      context.handle(
        _proposalIdMeta,
        proposalId.isAcceptableOrUnknown(data['proposal_id']!, _proposalIdMeta),
      );
    }
    if (data.containsKey('opening_direction')) {
      context.handle(
        _openingDirectionMeta,
        openingDirection.isAcceptableOrUnknown(
          data['opening_direction']!,
          _openingDirectionMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId, id};
  @override
  TransactionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TransactionRow(
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      ),
      serverUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_updated_at'],
      ),
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      localVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}local_version'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      localCreatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}local_created_at'],
      )!,
      localUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}local_updated_at'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      amountMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_minor'],
      )!,
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      )!,
      destinationAccountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}destination_account_id'],
      ),
      incomeSourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}income_source_id'],
      ),
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      ),
      merchant: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}merchant'],
      ),
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      occurredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}occurred_at'],
      )!,
      effectiveDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}effective_date'],
      )!,
      entryTimeZone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entry_time_zone'],
      )!,
      origin: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origin'],
      )!,
      categorizationSource: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}categorization_source'],
      ),
      proposalId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}proposal_id'],
      ),
      openingDirection: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}opening_direction'],
      ),
    );
  }

  @override
  $TransactionsTable createAlias(String alias) {
    return $TransactionsTable(attachedDatabase, alias);
  }
}

class TransactionRow extends DataClass implements Insertable<TransactionRow> {
  final String userId;
  final String id;

  /// Last accepted remote revision (0 = never accepted).
  final int revision;
  final int? createdAt;
  final int? serverUpdatedAt;
  final int? deletedAt;
  final int localVersion;
  final String syncStatus;
  final int localCreatedAt;
  final int localUpdatedAt;
  final String type;
  final int amountMinor;
  final String currency;
  final String accountId;
  final String? destinationAccountId;
  final String? incomeSourceId;
  final String? categoryId;
  final String? merchant;
  final String description;
  final int occurredAt;
  final String effectiveDate;
  final String entryTimeZone;
  final String origin;
  final String? categorizationSource;
  final String? proposalId;
  final String? openingDirection;
  const TransactionRow({
    required this.userId,
    required this.id,
    required this.revision,
    this.createdAt,
    this.serverUpdatedAt,
    this.deletedAt,
    required this.localVersion,
    required this.syncStatus,
    required this.localCreatedAt,
    required this.localUpdatedAt,
    required this.type,
    required this.amountMinor,
    required this.currency,
    required this.accountId,
    this.destinationAccountId,
    this.incomeSourceId,
    this.categoryId,
    this.merchant,
    required this.description,
    required this.occurredAt,
    required this.effectiveDate,
    required this.entryTimeZone,
    required this.origin,
    this.categorizationSource,
    this.proposalId,
    this.openingDirection,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<String>(userId);
    map['id'] = Variable<String>(id);
    map['revision'] = Variable<int>(revision);
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<int>(createdAt);
    }
    if (!nullToAbsent || serverUpdatedAt != null) {
      map['server_updated_at'] = Variable<int>(serverUpdatedAt);
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['local_version'] = Variable<int>(localVersion);
    map['sync_status'] = Variable<String>(syncStatus);
    map['local_created_at'] = Variable<int>(localCreatedAt);
    map['local_updated_at'] = Variable<int>(localUpdatedAt);
    map['type'] = Variable<String>(type);
    map['amount_minor'] = Variable<int>(amountMinor);
    map['currency'] = Variable<String>(currency);
    map['account_id'] = Variable<String>(accountId);
    if (!nullToAbsent || destinationAccountId != null) {
      map['destination_account_id'] = Variable<String>(destinationAccountId);
    }
    if (!nullToAbsent || incomeSourceId != null) {
      map['income_source_id'] = Variable<String>(incomeSourceId);
    }
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<String>(categoryId);
    }
    if (!nullToAbsent || merchant != null) {
      map['merchant'] = Variable<String>(merchant);
    }
    map['description'] = Variable<String>(description);
    map['occurred_at'] = Variable<int>(occurredAt);
    map['effective_date'] = Variable<String>(effectiveDate);
    map['entry_time_zone'] = Variable<String>(entryTimeZone);
    map['origin'] = Variable<String>(origin);
    if (!nullToAbsent || categorizationSource != null) {
      map['categorization_source'] = Variable<String>(categorizationSource);
    }
    if (!nullToAbsent || proposalId != null) {
      map['proposal_id'] = Variable<String>(proposalId);
    }
    if (!nullToAbsent || openingDirection != null) {
      map['opening_direction'] = Variable<String>(openingDirection);
    }
    return map;
  }

  TransactionsCompanion toCompanion(bool nullToAbsent) {
    return TransactionsCompanion(
      userId: Value(userId),
      id: Value(id),
      revision: Value(revision),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      serverUpdatedAt: serverUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(serverUpdatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      localVersion: Value(localVersion),
      syncStatus: Value(syncStatus),
      localCreatedAt: Value(localCreatedAt),
      localUpdatedAt: Value(localUpdatedAt),
      type: Value(type),
      amountMinor: Value(amountMinor),
      currency: Value(currency),
      accountId: Value(accountId),
      destinationAccountId: destinationAccountId == null && nullToAbsent
          ? const Value.absent()
          : Value(destinationAccountId),
      incomeSourceId: incomeSourceId == null && nullToAbsent
          ? const Value.absent()
          : Value(incomeSourceId),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      merchant: merchant == null && nullToAbsent
          ? const Value.absent()
          : Value(merchant),
      description: Value(description),
      occurredAt: Value(occurredAt),
      effectiveDate: Value(effectiveDate),
      entryTimeZone: Value(entryTimeZone),
      origin: Value(origin),
      categorizationSource: categorizationSource == null && nullToAbsent
          ? const Value.absent()
          : Value(categorizationSource),
      proposalId: proposalId == null && nullToAbsent
          ? const Value.absent()
          : Value(proposalId),
      openingDirection: openingDirection == null && nullToAbsent
          ? const Value.absent()
          : Value(openingDirection),
    );
  }

  factory TransactionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TransactionRow(
      userId: serializer.fromJson<String>(json['userId']),
      id: serializer.fromJson<String>(json['id']),
      revision: serializer.fromJson<int>(json['revision']),
      createdAt: serializer.fromJson<int?>(json['createdAt']),
      serverUpdatedAt: serializer.fromJson<int?>(json['serverUpdatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      localVersion: serializer.fromJson<int>(json['localVersion']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      localCreatedAt: serializer.fromJson<int>(json['localCreatedAt']),
      localUpdatedAt: serializer.fromJson<int>(json['localUpdatedAt']),
      type: serializer.fromJson<String>(json['type']),
      amountMinor: serializer.fromJson<int>(json['amountMinor']),
      currency: serializer.fromJson<String>(json['currency']),
      accountId: serializer.fromJson<String>(json['accountId']),
      destinationAccountId: serializer.fromJson<String?>(
        json['destinationAccountId'],
      ),
      incomeSourceId: serializer.fromJson<String?>(json['incomeSourceId']),
      categoryId: serializer.fromJson<String?>(json['categoryId']),
      merchant: serializer.fromJson<String?>(json['merchant']),
      description: serializer.fromJson<String>(json['description']),
      occurredAt: serializer.fromJson<int>(json['occurredAt']),
      effectiveDate: serializer.fromJson<String>(json['effectiveDate']),
      entryTimeZone: serializer.fromJson<String>(json['entryTimeZone']),
      origin: serializer.fromJson<String>(json['origin']),
      categorizationSource: serializer.fromJson<String?>(
        json['categorizationSource'],
      ),
      proposalId: serializer.fromJson<String?>(json['proposalId']),
      openingDirection: serializer.fromJson<String?>(json['openingDirection']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<String>(userId),
      'id': serializer.toJson<String>(id),
      'revision': serializer.toJson<int>(revision),
      'createdAt': serializer.toJson<int?>(createdAt),
      'serverUpdatedAt': serializer.toJson<int?>(serverUpdatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'localVersion': serializer.toJson<int>(localVersion),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'localCreatedAt': serializer.toJson<int>(localCreatedAt),
      'localUpdatedAt': serializer.toJson<int>(localUpdatedAt),
      'type': serializer.toJson<String>(type),
      'amountMinor': serializer.toJson<int>(amountMinor),
      'currency': serializer.toJson<String>(currency),
      'accountId': serializer.toJson<String>(accountId),
      'destinationAccountId': serializer.toJson<String?>(destinationAccountId),
      'incomeSourceId': serializer.toJson<String?>(incomeSourceId),
      'categoryId': serializer.toJson<String?>(categoryId),
      'merchant': serializer.toJson<String?>(merchant),
      'description': serializer.toJson<String>(description),
      'occurredAt': serializer.toJson<int>(occurredAt),
      'effectiveDate': serializer.toJson<String>(effectiveDate),
      'entryTimeZone': serializer.toJson<String>(entryTimeZone),
      'origin': serializer.toJson<String>(origin),
      'categorizationSource': serializer.toJson<String?>(categorizationSource),
      'proposalId': serializer.toJson<String?>(proposalId),
      'openingDirection': serializer.toJson<String?>(openingDirection),
    };
  }

  TransactionRow copyWith({
    String? userId,
    String? id,
    int? revision,
    Value<int?> createdAt = const Value.absent(),
    Value<int?> serverUpdatedAt = const Value.absent(),
    Value<int?> deletedAt = const Value.absent(),
    int? localVersion,
    String? syncStatus,
    int? localCreatedAt,
    int? localUpdatedAt,
    String? type,
    int? amountMinor,
    String? currency,
    String? accountId,
    Value<String?> destinationAccountId = const Value.absent(),
    Value<String?> incomeSourceId = const Value.absent(),
    Value<String?> categoryId = const Value.absent(),
    Value<String?> merchant = const Value.absent(),
    String? description,
    int? occurredAt,
    String? effectiveDate,
    String? entryTimeZone,
    String? origin,
    Value<String?> categorizationSource = const Value.absent(),
    Value<String?> proposalId = const Value.absent(),
    Value<String?> openingDirection = const Value.absent(),
  }) => TransactionRow(
    userId: userId ?? this.userId,
    id: id ?? this.id,
    revision: revision ?? this.revision,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
    serverUpdatedAt: serverUpdatedAt.present
        ? serverUpdatedAt.value
        : this.serverUpdatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    localVersion: localVersion ?? this.localVersion,
    syncStatus: syncStatus ?? this.syncStatus,
    localCreatedAt: localCreatedAt ?? this.localCreatedAt,
    localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
    type: type ?? this.type,
    amountMinor: amountMinor ?? this.amountMinor,
    currency: currency ?? this.currency,
    accountId: accountId ?? this.accountId,
    destinationAccountId: destinationAccountId.present
        ? destinationAccountId.value
        : this.destinationAccountId,
    incomeSourceId: incomeSourceId.present
        ? incomeSourceId.value
        : this.incomeSourceId,
    categoryId: categoryId.present ? categoryId.value : this.categoryId,
    merchant: merchant.present ? merchant.value : this.merchant,
    description: description ?? this.description,
    occurredAt: occurredAt ?? this.occurredAt,
    effectiveDate: effectiveDate ?? this.effectiveDate,
    entryTimeZone: entryTimeZone ?? this.entryTimeZone,
    origin: origin ?? this.origin,
    categorizationSource: categorizationSource.present
        ? categorizationSource.value
        : this.categorizationSource,
    proposalId: proposalId.present ? proposalId.value : this.proposalId,
    openingDirection: openingDirection.present
        ? openingDirection.value
        : this.openingDirection,
  );
  TransactionRow copyWithCompanion(TransactionsCompanion data) {
    return TransactionRow(
      userId: data.userId.present ? data.userId.value : this.userId,
      id: data.id.present ? data.id.value : this.id,
      revision: data.revision.present ? data.revision.value : this.revision,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      serverUpdatedAt: data.serverUpdatedAt.present
          ? data.serverUpdatedAt.value
          : this.serverUpdatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      localVersion: data.localVersion.present
          ? data.localVersion.value
          : this.localVersion,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      localCreatedAt: data.localCreatedAt.present
          ? data.localCreatedAt.value
          : this.localCreatedAt,
      localUpdatedAt: data.localUpdatedAt.present
          ? data.localUpdatedAt.value
          : this.localUpdatedAt,
      type: data.type.present ? data.type.value : this.type,
      amountMinor: data.amountMinor.present
          ? data.amountMinor.value
          : this.amountMinor,
      currency: data.currency.present ? data.currency.value : this.currency,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      destinationAccountId: data.destinationAccountId.present
          ? data.destinationAccountId.value
          : this.destinationAccountId,
      incomeSourceId: data.incomeSourceId.present
          ? data.incomeSourceId.value
          : this.incomeSourceId,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      merchant: data.merchant.present ? data.merchant.value : this.merchant,
      description: data.description.present
          ? data.description.value
          : this.description,
      occurredAt: data.occurredAt.present
          ? data.occurredAt.value
          : this.occurredAt,
      effectiveDate: data.effectiveDate.present
          ? data.effectiveDate.value
          : this.effectiveDate,
      entryTimeZone: data.entryTimeZone.present
          ? data.entryTimeZone.value
          : this.entryTimeZone,
      origin: data.origin.present ? data.origin.value : this.origin,
      categorizationSource: data.categorizationSource.present
          ? data.categorizationSource.value
          : this.categorizationSource,
      proposalId: data.proposalId.present
          ? data.proposalId.value
          : this.proposalId,
      openingDirection: data.openingDirection.present
          ? data.openingDirection.value
          : this.openingDirection,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TransactionRow(')
          ..write('userId: $userId, ')
          ..write('id: $id, ')
          ..write('revision: $revision, ')
          ..write('createdAt: $createdAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('localVersion: $localVersion, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('localCreatedAt: $localCreatedAt, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('type: $type, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('currency: $currency, ')
          ..write('accountId: $accountId, ')
          ..write('destinationAccountId: $destinationAccountId, ')
          ..write('incomeSourceId: $incomeSourceId, ')
          ..write('categoryId: $categoryId, ')
          ..write('merchant: $merchant, ')
          ..write('description: $description, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('effectiveDate: $effectiveDate, ')
          ..write('entryTimeZone: $entryTimeZone, ')
          ..write('origin: $origin, ')
          ..write('categorizationSource: $categorizationSource, ')
          ..write('proposalId: $proposalId, ')
          ..write('openingDirection: $openingDirection')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    userId,
    id,
    revision,
    createdAt,
    serverUpdatedAt,
    deletedAt,
    localVersion,
    syncStatus,
    localCreatedAt,
    localUpdatedAt,
    type,
    amountMinor,
    currency,
    accountId,
    destinationAccountId,
    incomeSourceId,
    categoryId,
    merchant,
    description,
    occurredAt,
    effectiveDate,
    entryTimeZone,
    origin,
    categorizationSource,
    proposalId,
    openingDirection,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TransactionRow &&
          other.userId == this.userId &&
          other.id == this.id &&
          other.revision == this.revision &&
          other.createdAt == this.createdAt &&
          other.serverUpdatedAt == this.serverUpdatedAt &&
          other.deletedAt == this.deletedAt &&
          other.localVersion == this.localVersion &&
          other.syncStatus == this.syncStatus &&
          other.localCreatedAt == this.localCreatedAt &&
          other.localUpdatedAt == this.localUpdatedAt &&
          other.type == this.type &&
          other.amountMinor == this.amountMinor &&
          other.currency == this.currency &&
          other.accountId == this.accountId &&
          other.destinationAccountId == this.destinationAccountId &&
          other.incomeSourceId == this.incomeSourceId &&
          other.categoryId == this.categoryId &&
          other.merchant == this.merchant &&
          other.description == this.description &&
          other.occurredAt == this.occurredAt &&
          other.effectiveDate == this.effectiveDate &&
          other.entryTimeZone == this.entryTimeZone &&
          other.origin == this.origin &&
          other.categorizationSource == this.categorizationSource &&
          other.proposalId == this.proposalId &&
          other.openingDirection == this.openingDirection);
}

class TransactionsCompanion extends UpdateCompanion<TransactionRow> {
  final Value<String> userId;
  final Value<String> id;
  final Value<int> revision;
  final Value<int?> createdAt;
  final Value<int?> serverUpdatedAt;
  final Value<int?> deletedAt;
  final Value<int> localVersion;
  final Value<String> syncStatus;
  final Value<int> localCreatedAt;
  final Value<int> localUpdatedAt;
  final Value<String> type;
  final Value<int> amountMinor;
  final Value<String> currency;
  final Value<String> accountId;
  final Value<String?> destinationAccountId;
  final Value<String?> incomeSourceId;
  final Value<String?> categoryId;
  final Value<String?> merchant;
  final Value<String> description;
  final Value<int> occurredAt;
  final Value<String> effectiveDate;
  final Value<String> entryTimeZone;
  final Value<String> origin;
  final Value<String?> categorizationSource;
  final Value<String?> proposalId;
  final Value<String?> openingDirection;
  final Value<int> rowid;
  const TransactionsCompanion({
    this.userId = const Value.absent(),
    this.id = const Value.absent(),
    this.revision = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.localVersion = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.localCreatedAt = const Value.absent(),
    this.localUpdatedAt = const Value.absent(),
    this.type = const Value.absent(),
    this.amountMinor = const Value.absent(),
    this.currency = const Value.absent(),
    this.accountId = const Value.absent(),
    this.destinationAccountId = const Value.absent(),
    this.incomeSourceId = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.merchant = const Value.absent(),
    this.description = const Value.absent(),
    this.occurredAt = const Value.absent(),
    this.effectiveDate = const Value.absent(),
    this.entryTimeZone = const Value.absent(),
    this.origin = const Value.absent(),
    this.categorizationSource = const Value.absent(),
    this.proposalId = const Value.absent(),
    this.openingDirection = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TransactionsCompanion.insert({
    required String userId,
    required String id,
    this.revision = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.localVersion = const Value.absent(),
    this.syncStatus = const Value.absent(),
    required int localCreatedAt,
    required int localUpdatedAt,
    required String type,
    required int amountMinor,
    required String currency,
    required String accountId,
    this.destinationAccountId = const Value.absent(),
    this.incomeSourceId = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.merchant = const Value.absent(),
    required String description,
    required int occurredAt,
    required String effectiveDate,
    required String entryTimeZone,
    required String origin,
    this.categorizationSource = const Value.absent(),
    this.proposalId = const Value.absent(),
    this.openingDirection = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : userId = Value(userId),
       id = Value(id),
       localCreatedAt = Value(localCreatedAt),
       localUpdatedAt = Value(localUpdatedAt),
       type = Value(type),
       amountMinor = Value(amountMinor),
       currency = Value(currency),
       accountId = Value(accountId),
       description = Value(description),
       occurredAt = Value(occurredAt),
       effectiveDate = Value(effectiveDate),
       entryTimeZone = Value(entryTimeZone),
       origin = Value(origin);
  static Insertable<TransactionRow> custom({
    Expression<String>? userId,
    Expression<String>? id,
    Expression<int>? revision,
    Expression<int>? createdAt,
    Expression<int>? serverUpdatedAt,
    Expression<int>? deletedAt,
    Expression<int>? localVersion,
    Expression<String>? syncStatus,
    Expression<int>? localCreatedAt,
    Expression<int>? localUpdatedAt,
    Expression<String>? type,
    Expression<int>? amountMinor,
    Expression<String>? currency,
    Expression<String>? accountId,
    Expression<String>? destinationAccountId,
    Expression<String>? incomeSourceId,
    Expression<String>? categoryId,
    Expression<String>? merchant,
    Expression<String>? description,
    Expression<int>? occurredAt,
    Expression<String>? effectiveDate,
    Expression<String>? entryTimeZone,
    Expression<String>? origin,
    Expression<String>? categorizationSource,
    Expression<String>? proposalId,
    Expression<String>? openingDirection,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (id != null) 'id': id,
      if (revision != null) 'revision': revision,
      if (createdAt != null) 'created_at': createdAt,
      if (serverUpdatedAt != null) 'server_updated_at': serverUpdatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (localVersion != null) 'local_version': localVersion,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (localCreatedAt != null) 'local_created_at': localCreatedAt,
      if (localUpdatedAt != null) 'local_updated_at': localUpdatedAt,
      if (type != null) 'type': type,
      if (amountMinor != null) 'amount_minor': amountMinor,
      if (currency != null) 'currency': currency,
      if (accountId != null) 'account_id': accountId,
      if (destinationAccountId != null)
        'destination_account_id': destinationAccountId,
      if (incomeSourceId != null) 'income_source_id': incomeSourceId,
      if (categoryId != null) 'category_id': categoryId,
      if (merchant != null) 'merchant': merchant,
      if (description != null) 'description': description,
      if (occurredAt != null) 'occurred_at': occurredAt,
      if (effectiveDate != null) 'effective_date': effectiveDate,
      if (entryTimeZone != null) 'entry_time_zone': entryTimeZone,
      if (origin != null) 'origin': origin,
      if (categorizationSource != null)
        'categorization_source': categorizationSource,
      if (proposalId != null) 'proposal_id': proposalId,
      if (openingDirection != null) 'opening_direction': openingDirection,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TransactionsCompanion copyWith({
    Value<String>? userId,
    Value<String>? id,
    Value<int>? revision,
    Value<int?>? createdAt,
    Value<int?>? serverUpdatedAt,
    Value<int?>? deletedAt,
    Value<int>? localVersion,
    Value<String>? syncStatus,
    Value<int>? localCreatedAt,
    Value<int>? localUpdatedAt,
    Value<String>? type,
    Value<int>? amountMinor,
    Value<String>? currency,
    Value<String>? accountId,
    Value<String?>? destinationAccountId,
    Value<String?>? incomeSourceId,
    Value<String?>? categoryId,
    Value<String?>? merchant,
    Value<String>? description,
    Value<int>? occurredAt,
    Value<String>? effectiveDate,
    Value<String>? entryTimeZone,
    Value<String>? origin,
    Value<String?>? categorizationSource,
    Value<String?>? proposalId,
    Value<String?>? openingDirection,
    Value<int>? rowid,
  }) {
    return TransactionsCompanion(
      userId: userId ?? this.userId,
      id: id ?? this.id,
      revision: revision ?? this.revision,
      createdAt: createdAt ?? this.createdAt,
      serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      localVersion: localVersion ?? this.localVersion,
      syncStatus: syncStatus ?? this.syncStatus,
      localCreatedAt: localCreatedAt ?? this.localCreatedAt,
      localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
      type: type ?? this.type,
      amountMinor: amountMinor ?? this.amountMinor,
      currency: currency ?? this.currency,
      accountId: accountId ?? this.accountId,
      destinationAccountId: destinationAccountId ?? this.destinationAccountId,
      incomeSourceId: incomeSourceId ?? this.incomeSourceId,
      categoryId: categoryId ?? this.categoryId,
      merchant: merchant ?? this.merchant,
      description: description ?? this.description,
      occurredAt: occurredAt ?? this.occurredAt,
      effectiveDate: effectiveDate ?? this.effectiveDate,
      entryTimeZone: entryTimeZone ?? this.entryTimeZone,
      origin: origin ?? this.origin,
      categorizationSource: categorizationSource ?? this.categorizationSource,
      proposalId: proposalId ?? this.proposalId,
      openingDirection: openingDirection ?? this.openingDirection,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (serverUpdatedAt.present) {
      map['server_updated_at'] = Variable<int>(serverUpdatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (localVersion.present) {
      map['local_version'] = Variable<int>(localVersion.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (localCreatedAt.present) {
      map['local_created_at'] = Variable<int>(localCreatedAt.value);
    }
    if (localUpdatedAt.present) {
      map['local_updated_at'] = Variable<int>(localUpdatedAt.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (amountMinor.present) {
      map['amount_minor'] = Variable<int>(amountMinor.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (destinationAccountId.present) {
      map['destination_account_id'] = Variable<String>(
        destinationAccountId.value,
      );
    }
    if (incomeSourceId.present) {
      map['income_source_id'] = Variable<String>(incomeSourceId.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (merchant.present) {
      map['merchant'] = Variable<String>(merchant.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (occurredAt.present) {
      map['occurred_at'] = Variable<int>(occurredAt.value);
    }
    if (effectiveDate.present) {
      map['effective_date'] = Variable<String>(effectiveDate.value);
    }
    if (entryTimeZone.present) {
      map['entry_time_zone'] = Variable<String>(entryTimeZone.value);
    }
    if (origin.present) {
      map['origin'] = Variable<String>(origin.value);
    }
    if (categorizationSource.present) {
      map['categorization_source'] = Variable<String>(
        categorizationSource.value,
      );
    }
    if (proposalId.present) {
      map['proposal_id'] = Variable<String>(proposalId.value);
    }
    if (openingDirection.present) {
      map['opening_direction'] = Variable<String>(openingDirection.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionsCompanion(')
          ..write('userId: $userId, ')
          ..write('id: $id, ')
          ..write('revision: $revision, ')
          ..write('createdAt: $createdAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('localVersion: $localVersion, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('localCreatedAt: $localCreatedAt, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('type: $type, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('currency: $currency, ')
          ..write('accountId: $accountId, ')
          ..write('destinationAccountId: $destinationAccountId, ')
          ..write('incomeSourceId: $incomeSourceId, ')
          ..write('categoryId: $categoryId, ')
          ..write('merchant: $merchant, ')
          ..write('description: $description, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('effectiveDate: $effectiveDate, ')
          ..write('entryTimeZone: $entryTimeZone, ')
          ..write('origin: $origin, ')
          ..write('categorizationSource: $categorizationSource, ')
          ..write('proposalId: $proposalId, ')
          ..write('openingDirection: $openingDirection, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CategorizationRulesTable extends CategorizationRules
    with TableInfo<$CategorizationRulesTable, RuleRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategorizationRulesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _serverUpdatedAtMeta = const VerificationMeta(
    'serverUpdatedAt',
  );
  @override
  late final GeneratedColumn<int> serverUpdatedAt = GeneratedColumn<int>(
    'server_updated_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _localVersionMeta = const VerificationMeta(
    'localVersion',
  );
  @override
  late final GeneratedColumn<int> localVersion = GeneratedColumn<int>(
    'local_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    check: () => syncStatus.isIn(syncStatuses),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('synced'),
  );
  static const VerificationMeta _localCreatedAtMeta = const VerificationMeta(
    'localCreatedAt',
  );
  @override
  late final GeneratedColumn<int> localCreatedAt = GeneratedColumn<int>(
    'local_created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localUpdatedAtMeta = const VerificationMeta(
    'localUpdatedAt',
  );
  @override
  late final GeneratedColumn<int> localUpdatedAt = GeneratedColumn<int>(
    'local_updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _matchKindMeta = const VerificationMeta(
    'matchKind',
  );
  @override
  late final GeneratedColumn<String> matchKind = GeneratedColumn<String>(
    'match_kind',
    aliasedName,
    false,
    check: () => matchKind.isIn(const ['merchantExact', 'keyword']),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _normalizedPatternMeta = const VerificationMeta(
    'normalizedPattern',
  );
  @override
  late final GeneratedColumn<String> normalizedPattern =
      GeneratedColumn<String>(
        'normalized_pattern',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _transactionTypeMeta = const VerificationMeta(
    'transactionType',
  );
  @override
  late final GeneratedColumn<String> transactionType = GeneratedColumn<String>(
    'transaction_type',
    aliasedName,
    false,
    check: () => transactionType.isIn(const ['income', 'expense']),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _suggestedAccountIdMeta =
      const VerificationMeta('suggestedAccountId');
  @override
  late final GeneratedColumn<String> suggestedAccountId =
      GeneratedColumn<String>(
        'suggested_account_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _suggestedIncomeSourceIdMeta =
      const VerificationMeta('suggestedIncomeSourceId');
  @override
  late final GeneratedColumn<String> suggestedIncomeSourceId =
      GeneratedColumn<String>(
        'suggested_income_source_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _priorityMeta = const VerificationMeta(
    'priority',
  );
  @override
  late final GeneratedColumn<int> priority = GeneratedColumn<int>(
    'priority',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _enabledMeta = const VerificationMeta(
    'enabled',
  );
  @override
  late final GeneratedColumn<bool> enabled = GeneratedColumn<bool>(
    'enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("enabled" IN (0, 1))',
    ),
  );
  static const VerificationMeta _originMeta = const VerificationMeta('origin');
  @override
  late final GeneratedColumn<String> origin = GeneratedColumn<String>(
    'origin',
    aliasedName,
    false,
    check: () => origin.isIn(const ['user', 'acceptedSuggestion']),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _evidenceJsonMeta = const VerificationMeta(
    'evidenceJson',
  );
  @override
  late final GeneratedColumn<String> evidenceJson = GeneratedColumn<String>(
    'evidence_json',
    aliasedName,
    false,
    check: () => const CustomExpression<bool>('json_valid(evidence_json)'),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    userId,
    id,
    revision,
    createdAt,
    serverUpdatedAt,
    deletedAt,
    localVersion,
    syncStatus,
    localCreatedAt,
    localUpdatedAt,
    matchKind,
    normalizedPattern,
    transactionType,
    categoryId,
    suggestedAccountId,
    suggestedIncomeSourceId,
    priority,
    enabled,
    origin,
    evidenceJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categorization_rules';
  @override
  VerificationContext validateIntegrity(
    Insertable<RuleRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('server_updated_at')) {
      context.handle(
        _serverUpdatedAtMeta,
        serverUpdatedAt.isAcceptableOrUnknown(
          data['server_updated_at']!,
          _serverUpdatedAtMeta,
        ),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('local_version')) {
      context.handle(
        _localVersionMeta,
        localVersion.isAcceptableOrUnknown(
          data['local_version']!,
          _localVersionMeta,
        ),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('local_created_at')) {
      context.handle(
        _localCreatedAtMeta,
        localCreatedAt.isAcceptableOrUnknown(
          data['local_created_at']!,
          _localCreatedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_localCreatedAtMeta);
    }
    if (data.containsKey('local_updated_at')) {
      context.handle(
        _localUpdatedAtMeta,
        localUpdatedAt.isAcceptableOrUnknown(
          data['local_updated_at']!,
          _localUpdatedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_localUpdatedAtMeta);
    }
    if (data.containsKey('match_kind')) {
      context.handle(
        _matchKindMeta,
        matchKind.isAcceptableOrUnknown(data['match_kind']!, _matchKindMeta),
      );
    } else if (isInserting) {
      context.missing(_matchKindMeta);
    }
    if (data.containsKey('normalized_pattern')) {
      context.handle(
        _normalizedPatternMeta,
        normalizedPattern.isAcceptableOrUnknown(
          data['normalized_pattern']!,
          _normalizedPatternMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_normalizedPatternMeta);
    }
    if (data.containsKey('transaction_type')) {
      context.handle(
        _transactionTypeMeta,
        transactionType.isAcceptableOrUnknown(
          data['transaction_type']!,
          _transactionTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_transactionTypeMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('suggested_account_id')) {
      context.handle(
        _suggestedAccountIdMeta,
        suggestedAccountId.isAcceptableOrUnknown(
          data['suggested_account_id']!,
          _suggestedAccountIdMeta,
        ),
      );
    }
    if (data.containsKey('suggested_income_source_id')) {
      context.handle(
        _suggestedIncomeSourceIdMeta,
        suggestedIncomeSourceId.isAcceptableOrUnknown(
          data['suggested_income_source_id']!,
          _suggestedIncomeSourceIdMeta,
        ),
      );
    }
    if (data.containsKey('priority')) {
      context.handle(
        _priorityMeta,
        priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta),
      );
    } else if (isInserting) {
      context.missing(_priorityMeta);
    }
    if (data.containsKey('enabled')) {
      context.handle(
        _enabledMeta,
        enabled.isAcceptableOrUnknown(data['enabled']!, _enabledMeta),
      );
    } else if (isInserting) {
      context.missing(_enabledMeta);
    }
    if (data.containsKey('origin')) {
      context.handle(
        _originMeta,
        origin.isAcceptableOrUnknown(data['origin']!, _originMeta),
      );
    } else if (isInserting) {
      context.missing(_originMeta);
    }
    if (data.containsKey('evidence_json')) {
      context.handle(
        _evidenceJsonMeta,
        evidenceJson.isAcceptableOrUnknown(
          data['evidence_json']!,
          _evidenceJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_evidenceJsonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId, id};
  @override
  RuleRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RuleRow(
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      ),
      serverUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_updated_at'],
      ),
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      localVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}local_version'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      localCreatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}local_created_at'],
      )!,
      localUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}local_updated_at'],
      )!,
      matchKind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}match_kind'],
      )!,
      normalizedPattern: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}normalized_pattern'],
      )!,
      transactionType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transaction_type'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      )!,
      suggestedAccountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}suggested_account_id'],
      ),
      suggestedIncomeSourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}suggested_income_source_id'],
      ),
      priority: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}priority'],
      )!,
      enabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}enabled'],
      )!,
      origin: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origin'],
      )!,
      evidenceJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}evidence_json'],
      )!,
    );
  }

  @override
  $CategorizationRulesTable createAlias(String alias) {
    return $CategorizationRulesTable(attachedDatabase, alias);
  }
}

class RuleRow extends DataClass implements Insertable<RuleRow> {
  final String userId;
  final String id;

  /// Last accepted remote revision (0 = never accepted).
  final int revision;
  final int? createdAt;
  final int? serverUpdatedAt;
  final int? deletedAt;
  final int localVersion;
  final String syncStatus;
  final int localCreatedAt;
  final int localUpdatedAt;
  final String matchKind;
  final String normalizedPattern;
  final String transactionType;
  final String categoryId;
  final String? suggestedAccountId;
  final String? suggestedIncomeSourceId;
  final int priority;
  final bool enabled;
  final String origin;
  final String evidenceJson;
  const RuleRow({
    required this.userId,
    required this.id,
    required this.revision,
    this.createdAt,
    this.serverUpdatedAt,
    this.deletedAt,
    required this.localVersion,
    required this.syncStatus,
    required this.localCreatedAt,
    required this.localUpdatedAt,
    required this.matchKind,
    required this.normalizedPattern,
    required this.transactionType,
    required this.categoryId,
    this.suggestedAccountId,
    this.suggestedIncomeSourceId,
    required this.priority,
    required this.enabled,
    required this.origin,
    required this.evidenceJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<String>(userId);
    map['id'] = Variable<String>(id);
    map['revision'] = Variable<int>(revision);
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<int>(createdAt);
    }
    if (!nullToAbsent || serverUpdatedAt != null) {
      map['server_updated_at'] = Variable<int>(serverUpdatedAt);
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['local_version'] = Variable<int>(localVersion);
    map['sync_status'] = Variable<String>(syncStatus);
    map['local_created_at'] = Variable<int>(localCreatedAt);
    map['local_updated_at'] = Variable<int>(localUpdatedAt);
    map['match_kind'] = Variable<String>(matchKind);
    map['normalized_pattern'] = Variable<String>(normalizedPattern);
    map['transaction_type'] = Variable<String>(transactionType);
    map['category_id'] = Variable<String>(categoryId);
    if (!nullToAbsent || suggestedAccountId != null) {
      map['suggested_account_id'] = Variable<String>(suggestedAccountId);
    }
    if (!nullToAbsent || suggestedIncomeSourceId != null) {
      map['suggested_income_source_id'] = Variable<String>(
        suggestedIncomeSourceId,
      );
    }
    map['priority'] = Variable<int>(priority);
    map['enabled'] = Variable<bool>(enabled);
    map['origin'] = Variable<String>(origin);
    map['evidence_json'] = Variable<String>(evidenceJson);
    return map;
  }

  CategorizationRulesCompanion toCompanion(bool nullToAbsent) {
    return CategorizationRulesCompanion(
      userId: Value(userId),
      id: Value(id),
      revision: Value(revision),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      serverUpdatedAt: serverUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(serverUpdatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      localVersion: Value(localVersion),
      syncStatus: Value(syncStatus),
      localCreatedAt: Value(localCreatedAt),
      localUpdatedAt: Value(localUpdatedAt),
      matchKind: Value(matchKind),
      normalizedPattern: Value(normalizedPattern),
      transactionType: Value(transactionType),
      categoryId: Value(categoryId),
      suggestedAccountId: suggestedAccountId == null && nullToAbsent
          ? const Value.absent()
          : Value(suggestedAccountId),
      suggestedIncomeSourceId: suggestedIncomeSourceId == null && nullToAbsent
          ? const Value.absent()
          : Value(suggestedIncomeSourceId),
      priority: Value(priority),
      enabled: Value(enabled),
      origin: Value(origin),
      evidenceJson: Value(evidenceJson),
    );
  }

  factory RuleRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RuleRow(
      userId: serializer.fromJson<String>(json['userId']),
      id: serializer.fromJson<String>(json['id']),
      revision: serializer.fromJson<int>(json['revision']),
      createdAt: serializer.fromJson<int?>(json['createdAt']),
      serverUpdatedAt: serializer.fromJson<int?>(json['serverUpdatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      localVersion: serializer.fromJson<int>(json['localVersion']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      localCreatedAt: serializer.fromJson<int>(json['localCreatedAt']),
      localUpdatedAt: serializer.fromJson<int>(json['localUpdatedAt']),
      matchKind: serializer.fromJson<String>(json['matchKind']),
      normalizedPattern: serializer.fromJson<String>(json['normalizedPattern']),
      transactionType: serializer.fromJson<String>(json['transactionType']),
      categoryId: serializer.fromJson<String>(json['categoryId']),
      suggestedAccountId: serializer.fromJson<String?>(
        json['suggestedAccountId'],
      ),
      suggestedIncomeSourceId: serializer.fromJson<String?>(
        json['suggestedIncomeSourceId'],
      ),
      priority: serializer.fromJson<int>(json['priority']),
      enabled: serializer.fromJson<bool>(json['enabled']),
      origin: serializer.fromJson<String>(json['origin']),
      evidenceJson: serializer.fromJson<String>(json['evidenceJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<String>(userId),
      'id': serializer.toJson<String>(id),
      'revision': serializer.toJson<int>(revision),
      'createdAt': serializer.toJson<int?>(createdAt),
      'serverUpdatedAt': serializer.toJson<int?>(serverUpdatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'localVersion': serializer.toJson<int>(localVersion),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'localCreatedAt': serializer.toJson<int>(localCreatedAt),
      'localUpdatedAt': serializer.toJson<int>(localUpdatedAt),
      'matchKind': serializer.toJson<String>(matchKind),
      'normalizedPattern': serializer.toJson<String>(normalizedPattern),
      'transactionType': serializer.toJson<String>(transactionType),
      'categoryId': serializer.toJson<String>(categoryId),
      'suggestedAccountId': serializer.toJson<String?>(suggestedAccountId),
      'suggestedIncomeSourceId': serializer.toJson<String?>(
        suggestedIncomeSourceId,
      ),
      'priority': serializer.toJson<int>(priority),
      'enabled': serializer.toJson<bool>(enabled),
      'origin': serializer.toJson<String>(origin),
      'evidenceJson': serializer.toJson<String>(evidenceJson),
    };
  }

  RuleRow copyWith({
    String? userId,
    String? id,
    int? revision,
    Value<int?> createdAt = const Value.absent(),
    Value<int?> serverUpdatedAt = const Value.absent(),
    Value<int?> deletedAt = const Value.absent(),
    int? localVersion,
    String? syncStatus,
    int? localCreatedAt,
    int? localUpdatedAt,
    String? matchKind,
    String? normalizedPattern,
    String? transactionType,
    String? categoryId,
    Value<String?> suggestedAccountId = const Value.absent(),
    Value<String?> suggestedIncomeSourceId = const Value.absent(),
    int? priority,
    bool? enabled,
    String? origin,
    String? evidenceJson,
  }) => RuleRow(
    userId: userId ?? this.userId,
    id: id ?? this.id,
    revision: revision ?? this.revision,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
    serverUpdatedAt: serverUpdatedAt.present
        ? serverUpdatedAt.value
        : this.serverUpdatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    localVersion: localVersion ?? this.localVersion,
    syncStatus: syncStatus ?? this.syncStatus,
    localCreatedAt: localCreatedAt ?? this.localCreatedAt,
    localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
    matchKind: matchKind ?? this.matchKind,
    normalizedPattern: normalizedPattern ?? this.normalizedPattern,
    transactionType: transactionType ?? this.transactionType,
    categoryId: categoryId ?? this.categoryId,
    suggestedAccountId: suggestedAccountId.present
        ? suggestedAccountId.value
        : this.suggestedAccountId,
    suggestedIncomeSourceId: suggestedIncomeSourceId.present
        ? suggestedIncomeSourceId.value
        : this.suggestedIncomeSourceId,
    priority: priority ?? this.priority,
    enabled: enabled ?? this.enabled,
    origin: origin ?? this.origin,
    evidenceJson: evidenceJson ?? this.evidenceJson,
  );
  RuleRow copyWithCompanion(CategorizationRulesCompanion data) {
    return RuleRow(
      userId: data.userId.present ? data.userId.value : this.userId,
      id: data.id.present ? data.id.value : this.id,
      revision: data.revision.present ? data.revision.value : this.revision,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      serverUpdatedAt: data.serverUpdatedAt.present
          ? data.serverUpdatedAt.value
          : this.serverUpdatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      localVersion: data.localVersion.present
          ? data.localVersion.value
          : this.localVersion,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      localCreatedAt: data.localCreatedAt.present
          ? data.localCreatedAt.value
          : this.localCreatedAt,
      localUpdatedAt: data.localUpdatedAt.present
          ? data.localUpdatedAt.value
          : this.localUpdatedAt,
      matchKind: data.matchKind.present ? data.matchKind.value : this.matchKind,
      normalizedPattern: data.normalizedPattern.present
          ? data.normalizedPattern.value
          : this.normalizedPattern,
      transactionType: data.transactionType.present
          ? data.transactionType.value
          : this.transactionType,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      suggestedAccountId: data.suggestedAccountId.present
          ? data.suggestedAccountId.value
          : this.suggestedAccountId,
      suggestedIncomeSourceId: data.suggestedIncomeSourceId.present
          ? data.suggestedIncomeSourceId.value
          : this.suggestedIncomeSourceId,
      priority: data.priority.present ? data.priority.value : this.priority,
      enabled: data.enabled.present ? data.enabled.value : this.enabled,
      origin: data.origin.present ? data.origin.value : this.origin,
      evidenceJson: data.evidenceJson.present
          ? data.evidenceJson.value
          : this.evidenceJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RuleRow(')
          ..write('userId: $userId, ')
          ..write('id: $id, ')
          ..write('revision: $revision, ')
          ..write('createdAt: $createdAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('localVersion: $localVersion, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('localCreatedAt: $localCreatedAt, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('matchKind: $matchKind, ')
          ..write('normalizedPattern: $normalizedPattern, ')
          ..write('transactionType: $transactionType, ')
          ..write('categoryId: $categoryId, ')
          ..write('suggestedAccountId: $suggestedAccountId, ')
          ..write('suggestedIncomeSourceId: $suggestedIncomeSourceId, ')
          ..write('priority: $priority, ')
          ..write('enabled: $enabled, ')
          ..write('origin: $origin, ')
          ..write('evidenceJson: $evidenceJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    userId,
    id,
    revision,
    createdAt,
    serverUpdatedAt,
    deletedAt,
    localVersion,
    syncStatus,
    localCreatedAt,
    localUpdatedAt,
    matchKind,
    normalizedPattern,
    transactionType,
    categoryId,
    suggestedAccountId,
    suggestedIncomeSourceId,
    priority,
    enabled,
    origin,
    evidenceJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RuleRow &&
          other.userId == this.userId &&
          other.id == this.id &&
          other.revision == this.revision &&
          other.createdAt == this.createdAt &&
          other.serverUpdatedAt == this.serverUpdatedAt &&
          other.deletedAt == this.deletedAt &&
          other.localVersion == this.localVersion &&
          other.syncStatus == this.syncStatus &&
          other.localCreatedAt == this.localCreatedAt &&
          other.localUpdatedAt == this.localUpdatedAt &&
          other.matchKind == this.matchKind &&
          other.normalizedPattern == this.normalizedPattern &&
          other.transactionType == this.transactionType &&
          other.categoryId == this.categoryId &&
          other.suggestedAccountId == this.suggestedAccountId &&
          other.suggestedIncomeSourceId == this.suggestedIncomeSourceId &&
          other.priority == this.priority &&
          other.enabled == this.enabled &&
          other.origin == this.origin &&
          other.evidenceJson == this.evidenceJson);
}

class CategorizationRulesCompanion extends UpdateCompanion<RuleRow> {
  final Value<String> userId;
  final Value<String> id;
  final Value<int> revision;
  final Value<int?> createdAt;
  final Value<int?> serverUpdatedAt;
  final Value<int?> deletedAt;
  final Value<int> localVersion;
  final Value<String> syncStatus;
  final Value<int> localCreatedAt;
  final Value<int> localUpdatedAt;
  final Value<String> matchKind;
  final Value<String> normalizedPattern;
  final Value<String> transactionType;
  final Value<String> categoryId;
  final Value<String?> suggestedAccountId;
  final Value<String?> suggestedIncomeSourceId;
  final Value<int> priority;
  final Value<bool> enabled;
  final Value<String> origin;
  final Value<String> evidenceJson;
  final Value<int> rowid;
  const CategorizationRulesCompanion({
    this.userId = const Value.absent(),
    this.id = const Value.absent(),
    this.revision = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.localVersion = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.localCreatedAt = const Value.absent(),
    this.localUpdatedAt = const Value.absent(),
    this.matchKind = const Value.absent(),
    this.normalizedPattern = const Value.absent(),
    this.transactionType = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.suggestedAccountId = const Value.absent(),
    this.suggestedIncomeSourceId = const Value.absent(),
    this.priority = const Value.absent(),
    this.enabled = const Value.absent(),
    this.origin = const Value.absent(),
    this.evidenceJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CategorizationRulesCompanion.insert({
    required String userId,
    required String id,
    this.revision = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.localVersion = const Value.absent(),
    this.syncStatus = const Value.absent(),
    required int localCreatedAt,
    required int localUpdatedAt,
    required String matchKind,
    required String normalizedPattern,
    required String transactionType,
    required String categoryId,
    this.suggestedAccountId = const Value.absent(),
    this.suggestedIncomeSourceId = const Value.absent(),
    required int priority,
    required bool enabled,
    required String origin,
    required String evidenceJson,
    this.rowid = const Value.absent(),
  }) : userId = Value(userId),
       id = Value(id),
       localCreatedAt = Value(localCreatedAt),
       localUpdatedAt = Value(localUpdatedAt),
       matchKind = Value(matchKind),
       normalizedPattern = Value(normalizedPattern),
       transactionType = Value(transactionType),
       categoryId = Value(categoryId),
       priority = Value(priority),
       enabled = Value(enabled),
       origin = Value(origin),
       evidenceJson = Value(evidenceJson);
  static Insertable<RuleRow> custom({
    Expression<String>? userId,
    Expression<String>? id,
    Expression<int>? revision,
    Expression<int>? createdAt,
    Expression<int>? serverUpdatedAt,
    Expression<int>? deletedAt,
    Expression<int>? localVersion,
    Expression<String>? syncStatus,
    Expression<int>? localCreatedAt,
    Expression<int>? localUpdatedAt,
    Expression<String>? matchKind,
    Expression<String>? normalizedPattern,
    Expression<String>? transactionType,
    Expression<String>? categoryId,
    Expression<String>? suggestedAccountId,
    Expression<String>? suggestedIncomeSourceId,
    Expression<int>? priority,
    Expression<bool>? enabled,
    Expression<String>? origin,
    Expression<String>? evidenceJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (id != null) 'id': id,
      if (revision != null) 'revision': revision,
      if (createdAt != null) 'created_at': createdAt,
      if (serverUpdatedAt != null) 'server_updated_at': serverUpdatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (localVersion != null) 'local_version': localVersion,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (localCreatedAt != null) 'local_created_at': localCreatedAt,
      if (localUpdatedAt != null) 'local_updated_at': localUpdatedAt,
      if (matchKind != null) 'match_kind': matchKind,
      if (normalizedPattern != null) 'normalized_pattern': normalizedPattern,
      if (transactionType != null) 'transaction_type': transactionType,
      if (categoryId != null) 'category_id': categoryId,
      if (suggestedAccountId != null)
        'suggested_account_id': suggestedAccountId,
      if (suggestedIncomeSourceId != null)
        'suggested_income_source_id': suggestedIncomeSourceId,
      if (priority != null) 'priority': priority,
      if (enabled != null) 'enabled': enabled,
      if (origin != null) 'origin': origin,
      if (evidenceJson != null) 'evidence_json': evidenceJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CategorizationRulesCompanion copyWith({
    Value<String>? userId,
    Value<String>? id,
    Value<int>? revision,
    Value<int?>? createdAt,
    Value<int?>? serverUpdatedAt,
    Value<int?>? deletedAt,
    Value<int>? localVersion,
    Value<String>? syncStatus,
    Value<int>? localCreatedAt,
    Value<int>? localUpdatedAt,
    Value<String>? matchKind,
    Value<String>? normalizedPattern,
    Value<String>? transactionType,
    Value<String>? categoryId,
    Value<String?>? suggestedAccountId,
    Value<String?>? suggestedIncomeSourceId,
    Value<int>? priority,
    Value<bool>? enabled,
    Value<String>? origin,
    Value<String>? evidenceJson,
    Value<int>? rowid,
  }) {
    return CategorizationRulesCompanion(
      userId: userId ?? this.userId,
      id: id ?? this.id,
      revision: revision ?? this.revision,
      createdAt: createdAt ?? this.createdAt,
      serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      localVersion: localVersion ?? this.localVersion,
      syncStatus: syncStatus ?? this.syncStatus,
      localCreatedAt: localCreatedAt ?? this.localCreatedAt,
      localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
      matchKind: matchKind ?? this.matchKind,
      normalizedPattern: normalizedPattern ?? this.normalizedPattern,
      transactionType: transactionType ?? this.transactionType,
      categoryId: categoryId ?? this.categoryId,
      suggestedAccountId: suggestedAccountId ?? this.suggestedAccountId,
      suggestedIncomeSourceId:
          suggestedIncomeSourceId ?? this.suggestedIncomeSourceId,
      priority: priority ?? this.priority,
      enabled: enabled ?? this.enabled,
      origin: origin ?? this.origin,
      evidenceJson: evidenceJson ?? this.evidenceJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (serverUpdatedAt.present) {
      map['server_updated_at'] = Variable<int>(serverUpdatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (localVersion.present) {
      map['local_version'] = Variable<int>(localVersion.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (localCreatedAt.present) {
      map['local_created_at'] = Variable<int>(localCreatedAt.value);
    }
    if (localUpdatedAt.present) {
      map['local_updated_at'] = Variable<int>(localUpdatedAt.value);
    }
    if (matchKind.present) {
      map['match_kind'] = Variable<String>(matchKind.value);
    }
    if (normalizedPattern.present) {
      map['normalized_pattern'] = Variable<String>(normalizedPattern.value);
    }
    if (transactionType.present) {
      map['transaction_type'] = Variable<String>(transactionType.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (suggestedAccountId.present) {
      map['suggested_account_id'] = Variable<String>(suggestedAccountId.value);
    }
    if (suggestedIncomeSourceId.present) {
      map['suggested_income_source_id'] = Variable<String>(
        suggestedIncomeSourceId.value,
      );
    }
    if (priority.present) {
      map['priority'] = Variable<int>(priority.value);
    }
    if (enabled.present) {
      map['enabled'] = Variable<bool>(enabled.value);
    }
    if (origin.present) {
      map['origin'] = Variable<String>(origin.value);
    }
    if (evidenceJson.present) {
      map['evidence_json'] = Variable<String>(evidenceJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategorizationRulesCompanion(')
          ..write('userId: $userId, ')
          ..write('id: $id, ')
          ..write('revision: $revision, ')
          ..write('createdAt: $createdAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('localVersion: $localVersion, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('localCreatedAt: $localCreatedAt, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('matchKind: $matchKind, ')
          ..write('normalizedPattern: $normalizedPattern, ')
          ..write('transactionType: $transactionType, ')
          ..write('categoryId: $categoryId, ')
          ..write('suggestedAccountId: $suggestedAccountId, ')
          ..write('suggestedIncomeSourceId: $suggestedIncomeSourceId, ')
          ..write('priority: $priority, ')
          ..write('enabled: $enabled, ')
          ..write('origin: $origin, ')
          ..write('evidenceJson: $evidenceJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BudgetsTable extends Budgets with TableInfo<$BudgetsTable, BudgetRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BudgetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _serverUpdatedAtMeta = const VerificationMeta(
    'serverUpdatedAt',
  );
  @override
  late final GeneratedColumn<int> serverUpdatedAt = GeneratedColumn<int>(
    'server_updated_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _localVersionMeta = const VerificationMeta(
    'localVersion',
  );
  @override
  late final GeneratedColumn<int> localVersion = GeneratedColumn<int>(
    'local_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    check: () => syncStatus.isIn(syncStatuses),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('synced'),
  );
  static const VerificationMeta _localCreatedAtMeta = const VerificationMeta(
    'localCreatedAt',
  );
  @override
  late final GeneratedColumn<int> localCreatedAt = GeneratedColumn<int>(
    'local_created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localUpdatedAtMeta = const VerificationMeta(
    'localUpdatedAt',
  );
  @override
  late final GeneratedColumn<int> localUpdatedAt = GeneratedColumn<int>(
    'local_updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _monthMeta = const VerificationMeta('month');
  @override
  late final GeneratedColumn<String> month = GeneratedColumn<String>(
    'month',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _limitMinorMeta = const VerificationMeta(
    'limitMinor',
  );
  @override
  late final GeneratedColumn<int> limitMinor = GeneratedColumn<int>(
    'limit_minor',
    aliasedName,
    false,
    check: () => ComparableExpr(limitMinor).isBiggerThanValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    userId,
    id,
    revision,
    createdAt,
    serverUpdatedAt,
    deletedAt,
    localVersion,
    syncStatus,
    localCreatedAt,
    localUpdatedAt,
    month,
    categoryId,
    limitMinor,
    currency,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'budgets';
  @override
  VerificationContext validateIntegrity(
    Insertable<BudgetRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('server_updated_at')) {
      context.handle(
        _serverUpdatedAtMeta,
        serverUpdatedAt.isAcceptableOrUnknown(
          data['server_updated_at']!,
          _serverUpdatedAtMeta,
        ),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('local_version')) {
      context.handle(
        _localVersionMeta,
        localVersion.isAcceptableOrUnknown(
          data['local_version']!,
          _localVersionMeta,
        ),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('local_created_at')) {
      context.handle(
        _localCreatedAtMeta,
        localCreatedAt.isAcceptableOrUnknown(
          data['local_created_at']!,
          _localCreatedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_localCreatedAtMeta);
    }
    if (data.containsKey('local_updated_at')) {
      context.handle(
        _localUpdatedAtMeta,
        localUpdatedAt.isAcceptableOrUnknown(
          data['local_updated_at']!,
          _localUpdatedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_localUpdatedAtMeta);
    }
    if (data.containsKey('month')) {
      context.handle(
        _monthMeta,
        month.isAcceptableOrUnknown(data['month']!, _monthMeta),
      );
    } else if (isInserting) {
      context.missing(_monthMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('limit_minor')) {
      context.handle(
        _limitMinorMeta,
        limitMinor.isAcceptableOrUnknown(data['limit_minor']!, _limitMinorMeta),
      );
    } else if (isInserting) {
      context.missing(_limitMinorMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    } else if (isInserting) {
      context.missing(_currencyMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId, id};
  @override
  BudgetRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BudgetRow(
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      ),
      serverUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_updated_at'],
      ),
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      localVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}local_version'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      localCreatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}local_created_at'],
      )!,
      localUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}local_updated_at'],
      )!,
      month: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}month'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      )!,
      limitMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}limit_minor'],
      )!,
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
    );
  }

  @override
  $BudgetsTable createAlias(String alias) {
    return $BudgetsTable(attachedDatabase, alias);
  }
}

class BudgetRow extends DataClass implements Insertable<BudgetRow> {
  final String userId;
  final String id;

  /// Last accepted remote revision (0 = never accepted).
  final int revision;
  final int? createdAt;
  final int? serverUpdatedAt;
  final int? deletedAt;
  final int localVersion;
  final String syncStatus;
  final int localCreatedAt;
  final int localUpdatedAt;
  final String month;
  final String categoryId;
  final int limitMinor;
  final String currency;
  const BudgetRow({
    required this.userId,
    required this.id,
    required this.revision,
    this.createdAt,
    this.serverUpdatedAt,
    this.deletedAt,
    required this.localVersion,
    required this.syncStatus,
    required this.localCreatedAt,
    required this.localUpdatedAt,
    required this.month,
    required this.categoryId,
    required this.limitMinor,
    required this.currency,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<String>(userId);
    map['id'] = Variable<String>(id);
    map['revision'] = Variable<int>(revision);
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<int>(createdAt);
    }
    if (!nullToAbsent || serverUpdatedAt != null) {
      map['server_updated_at'] = Variable<int>(serverUpdatedAt);
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['local_version'] = Variable<int>(localVersion);
    map['sync_status'] = Variable<String>(syncStatus);
    map['local_created_at'] = Variable<int>(localCreatedAt);
    map['local_updated_at'] = Variable<int>(localUpdatedAt);
    map['month'] = Variable<String>(month);
    map['category_id'] = Variable<String>(categoryId);
    map['limit_minor'] = Variable<int>(limitMinor);
    map['currency'] = Variable<String>(currency);
    return map;
  }

  BudgetsCompanion toCompanion(bool nullToAbsent) {
    return BudgetsCompanion(
      userId: Value(userId),
      id: Value(id),
      revision: Value(revision),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      serverUpdatedAt: serverUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(serverUpdatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      localVersion: Value(localVersion),
      syncStatus: Value(syncStatus),
      localCreatedAt: Value(localCreatedAt),
      localUpdatedAt: Value(localUpdatedAt),
      month: Value(month),
      categoryId: Value(categoryId),
      limitMinor: Value(limitMinor),
      currency: Value(currency),
    );
  }

  factory BudgetRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BudgetRow(
      userId: serializer.fromJson<String>(json['userId']),
      id: serializer.fromJson<String>(json['id']),
      revision: serializer.fromJson<int>(json['revision']),
      createdAt: serializer.fromJson<int?>(json['createdAt']),
      serverUpdatedAt: serializer.fromJson<int?>(json['serverUpdatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      localVersion: serializer.fromJson<int>(json['localVersion']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      localCreatedAt: serializer.fromJson<int>(json['localCreatedAt']),
      localUpdatedAt: serializer.fromJson<int>(json['localUpdatedAt']),
      month: serializer.fromJson<String>(json['month']),
      categoryId: serializer.fromJson<String>(json['categoryId']),
      limitMinor: serializer.fromJson<int>(json['limitMinor']),
      currency: serializer.fromJson<String>(json['currency']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<String>(userId),
      'id': serializer.toJson<String>(id),
      'revision': serializer.toJson<int>(revision),
      'createdAt': serializer.toJson<int?>(createdAt),
      'serverUpdatedAt': serializer.toJson<int?>(serverUpdatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'localVersion': serializer.toJson<int>(localVersion),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'localCreatedAt': serializer.toJson<int>(localCreatedAt),
      'localUpdatedAt': serializer.toJson<int>(localUpdatedAt),
      'month': serializer.toJson<String>(month),
      'categoryId': serializer.toJson<String>(categoryId),
      'limitMinor': serializer.toJson<int>(limitMinor),
      'currency': serializer.toJson<String>(currency),
    };
  }

  BudgetRow copyWith({
    String? userId,
    String? id,
    int? revision,
    Value<int?> createdAt = const Value.absent(),
    Value<int?> serverUpdatedAt = const Value.absent(),
    Value<int?> deletedAt = const Value.absent(),
    int? localVersion,
    String? syncStatus,
    int? localCreatedAt,
    int? localUpdatedAt,
    String? month,
    String? categoryId,
    int? limitMinor,
    String? currency,
  }) => BudgetRow(
    userId: userId ?? this.userId,
    id: id ?? this.id,
    revision: revision ?? this.revision,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
    serverUpdatedAt: serverUpdatedAt.present
        ? serverUpdatedAt.value
        : this.serverUpdatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    localVersion: localVersion ?? this.localVersion,
    syncStatus: syncStatus ?? this.syncStatus,
    localCreatedAt: localCreatedAt ?? this.localCreatedAt,
    localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
    month: month ?? this.month,
    categoryId: categoryId ?? this.categoryId,
    limitMinor: limitMinor ?? this.limitMinor,
    currency: currency ?? this.currency,
  );
  BudgetRow copyWithCompanion(BudgetsCompanion data) {
    return BudgetRow(
      userId: data.userId.present ? data.userId.value : this.userId,
      id: data.id.present ? data.id.value : this.id,
      revision: data.revision.present ? data.revision.value : this.revision,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      serverUpdatedAt: data.serverUpdatedAt.present
          ? data.serverUpdatedAt.value
          : this.serverUpdatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      localVersion: data.localVersion.present
          ? data.localVersion.value
          : this.localVersion,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      localCreatedAt: data.localCreatedAt.present
          ? data.localCreatedAt.value
          : this.localCreatedAt,
      localUpdatedAt: data.localUpdatedAt.present
          ? data.localUpdatedAt.value
          : this.localUpdatedAt,
      month: data.month.present ? data.month.value : this.month,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      limitMinor: data.limitMinor.present
          ? data.limitMinor.value
          : this.limitMinor,
      currency: data.currency.present ? data.currency.value : this.currency,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BudgetRow(')
          ..write('userId: $userId, ')
          ..write('id: $id, ')
          ..write('revision: $revision, ')
          ..write('createdAt: $createdAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('localVersion: $localVersion, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('localCreatedAt: $localCreatedAt, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('month: $month, ')
          ..write('categoryId: $categoryId, ')
          ..write('limitMinor: $limitMinor, ')
          ..write('currency: $currency')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    userId,
    id,
    revision,
    createdAt,
    serverUpdatedAt,
    deletedAt,
    localVersion,
    syncStatus,
    localCreatedAt,
    localUpdatedAt,
    month,
    categoryId,
    limitMinor,
    currency,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BudgetRow &&
          other.userId == this.userId &&
          other.id == this.id &&
          other.revision == this.revision &&
          other.createdAt == this.createdAt &&
          other.serverUpdatedAt == this.serverUpdatedAt &&
          other.deletedAt == this.deletedAt &&
          other.localVersion == this.localVersion &&
          other.syncStatus == this.syncStatus &&
          other.localCreatedAt == this.localCreatedAt &&
          other.localUpdatedAt == this.localUpdatedAt &&
          other.month == this.month &&
          other.categoryId == this.categoryId &&
          other.limitMinor == this.limitMinor &&
          other.currency == this.currency);
}

class BudgetsCompanion extends UpdateCompanion<BudgetRow> {
  final Value<String> userId;
  final Value<String> id;
  final Value<int> revision;
  final Value<int?> createdAt;
  final Value<int?> serverUpdatedAt;
  final Value<int?> deletedAt;
  final Value<int> localVersion;
  final Value<String> syncStatus;
  final Value<int> localCreatedAt;
  final Value<int> localUpdatedAt;
  final Value<String> month;
  final Value<String> categoryId;
  final Value<int> limitMinor;
  final Value<String> currency;
  final Value<int> rowid;
  const BudgetsCompanion({
    this.userId = const Value.absent(),
    this.id = const Value.absent(),
    this.revision = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.localVersion = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.localCreatedAt = const Value.absent(),
    this.localUpdatedAt = const Value.absent(),
    this.month = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.limitMinor = const Value.absent(),
    this.currency = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BudgetsCompanion.insert({
    required String userId,
    required String id,
    this.revision = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.localVersion = const Value.absent(),
    this.syncStatus = const Value.absent(),
    required int localCreatedAt,
    required int localUpdatedAt,
    required String month,
    required String categoryId,
    required int limitMinor,
    required String currency,
    this.rowid = const Value.absent(),
  }) : userId = Value(userId),
       id = Value(id),
       localCreatedAt = Value(localCreatedAt),
       localUpdatedAt = Value(localUpdatedAt),
       month = Value(month),
       categoryId = Value(categoryId),
       limitMinor = Value(limitMinor),
       currency = Value(currency);
  static Insertable<BudgetRow> custom({
    Expression<String>? userId,
    Expression<String>? id,
    Expression<int>? revision,
    Expression<int>? createdAt,
    Expression<int>? serverUpdatedAt,
    Expression<int>? deletedAt,
    Expression<int>? localVersion,
    Expression<String>? syncStatus,
    Expression<int>? localCreatedAt,
    Expression<int>? localUpdatedAt,
    Expression<String>? month,
    Expression<String>? categoryId,
    Expression<int>? limitMinor,
    Expression<String>? currency,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (id != null) 'id': id,
      if (revision != null) 'revision': revision,
      if (createdAt != null) 'created_at': createdAt,
      if (serverUpdatedAt != null) 'server_updated_at': serverUpdatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (localVersion != null) 'local_version': localVersion,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (localCreatedAt != null) 'local_created_at': localCreatedAt,
      if (localUpdatedAt != null) 'local_updated_at': localUpdatedAt,
      if (month != null) 'month': month,
      if (categoryId != null) 'category_id': categoryId,
      if (limitMinor != null) 'limit_minor': limitMinor,
      if (currency != null) 'currency': currency,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BudgetsCompanion copyWith({
    Value<String>? userId,
    Value<String>? id,
    Value<int>? revision,
    Value<int?>? createdAt,
    Value<int?>? serverUpdatedAt,
    Value<int?>? deletedAt,
    Value<int>? localVersion,
    Value<String>? syncStatus,
    Value<int>? localCreatedAt,
    Value<int>? localUpdatedAt,
    Value<String>? month,
    Value<String>? categoryId,
    Value<int>? limitMinor,
    Value<String>? currency,
    Value<int>? rowid,
  }) {
    return BudgetsCompanion(
      userId: userId ?? this.userId,
      id: id ?? this.id,
      revision: revision ?? this.revision,
      createdAt: createdAt ?? this.createdAt,
      serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      localVersion: localVersion ?? this.localVersion,
      syncStatus: syncStatus ?? this.syncStatus,
      localCreatedAt: localCreatedAt ?? this.localCreatedAt,
      localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
      month: month ?? this.month,
      categoryId: categoryId ?? this.categoryId,
      limitMinor: limitMinor ?? this.limitMinor,
      currency: currency ?? this.currency,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (serverUpdatedAt.present) {
      map['server_updated_at'] = Variable<int>(serverUpdatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (localVersion.present) {
      map['local_version'] = Variable<int>(localVersion.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (localCreatedAt.present) {
      map['local_created_at'] = Variable<int>(localCreatedAt.value);
    }
    if (localUpdatedAt.present) {
      map['local_updated_at'] = Variable<int>(localUpdatedAt.value);
    }
    if (month.present) {
      map['month'] = Variable<String>(month.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (limitMinor.present) {
      map['limit_minor'] = Variable<int>(limitMinor.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BudgetsCompanion(')
          ..write('userId: $userId, ')
          ..write('id: $id, ')
          ..write('revision: $revision, ')
          ..write('createdAt: $createdAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('localVersion: $localVersion, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('localCreatedAt: $localCreatedAt, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('month: $month, ')
          ..write('categoryId: $categoryId, ')
          ..write('limitMinor: $limitMinor, ')
          ..write('currency: $currency, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AiInsightsTable extends AiInsights
    with TableInfo<$AiInsightsTable, InsightRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AiInsightsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _serverUpdatedAtMeta = const VerificationMeta(
    'serverUpdatedAt',
  );
  @override
  late final GeneratedColumn<int> serverUpdatedAt = GeneratedColumn<int>(
    'server_updated_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _localVersionMeta = const VerificationMeta(
    'localVersion',
  );
  @override
  late final GeneratedColumn<int> localVersion = GeneratedColumn<int>(
    'local_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    check: () => syncStatus.isIn(syncStatuses),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('synced'),
  );
  static const VerificationMeta _localCreatedAtMeta = const VerificationMeta(
    'localCreatedAt',
  );
  @override
  late final GeneratedColumn<int> localCreatedAt = GeneratedColumn<int>(
    'local_created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localUpdatedAtMeta = const VerificationMeta(
    'localUpdatedAt',
  );
  @override
  late final GeneratedColumn<int> localUpdatedAt = GeneratedColumn<int>(
    'local_updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _businessDateMeta = const VerificationMeta(
    'businessDate',
  );
  @override
  late final GeneratedColumn<String> businessDate = GeneratedColumn<String>(
    'business_date',
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
  static const VerificationMeta _sourceWatermarkMeta = const VerificationMeta(
    'sourceWatermark',
  );
  @override
  late final GeneratedColumn<int> sourceWatermark = GeneratedColumn<int>(
    'source_watermark',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recordJsonMeta = const VerificationMeta(
    'recordJson',
  );
  @override
  late final GeneratedColumn<String> recordJson = GeneratedColumn<String>(
    'record_json',
    aliasedName,
    false,
    check: () => const CustomExpression<bool>('json_valid(record_json)'),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    userId,
    id,
    revision,
    createdAt,
    serverUpdatedAt,
    deletedAt,
    localVersion,
    syncStatus,
    localCreatedAt,
    localUpdatedAt,
    kind,
    businessDate,
    status,
    sourceWatermark,
    recordJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ai_insights';
  @override
  VerificationContext validateIntegrity(
    Insertable<InsightRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('server_updated_at')) {
      context.handle(
        _serverUpdatedAtMeta,
        serverUpdatedAt.isAcceptableOrUnknown(
          data['server_updated_at']!,
          _serverUpdatedAtMeta,
        ),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('local_version')) {
      context.handle(
        _localVersionMeta,
        localVersion.isAcceptableOrUnknown(
          data['local_version']!,
          _localVersionMeta,
        ),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('local_created_at')) {
      context.handle(
        _localCreatedAtMeta,
        localCreatedAt.isAcceptableOrUnknown(
          data['local_created_at']!,
          _localCreatedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_localCreatedAtMeta);
    }
    if (data.containsKey('local_updated_at')) {
      context.handle(
        _localUpdatedAtMeta,
        localUpdatedAt.isAcceptableOrUnknown(
          data['local_updated_at']!,
          _localUpdatedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_localUpdatedAtMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('business_date')) {
      context.handle(
        _businessDateMeta,
        businessDate.isAcceptableOrUnknown(
          data['business_date']!,
          _businessDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_businessDateMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('source_watermark')) {
      context.handle(
        _sourceWatermarkMeta,
        sourceWatermark.isAcceptableOrUnknown(
          data['source_watermark']!,
          _sourceWatermarkMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sourceWatermarkMeta);
    }
    if (data.containsKey('record_json')) {
      context.handle(
        _recordJsonMeta,
        recordJson.isAcceptableOrUnknown(data['record_json']!, _recordJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_recordJsonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId, id};
  @override
  InsightRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InsightRow(
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      ),
      serverUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_updated_at'],
      ),
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      localVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}local_version'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      localCreatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}local_created_at'],
      )!,
      localUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}local_updated_at'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      businessDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}business_date'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      sourceWatermark: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}source_watermark'],
      )!,
      recordJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}record_json'],
      )!,
    );
  }

  @override
  $AiInsightsTable createAlias(String alias) {
    return $AiInsightsTable(attachedDatabase, alias);
  }
}

class InsightRow extends DataClass implements Insertable<InsightRow> {
  final String userId;
  final String id;

  /// Last accepted remote revision (0 = never accepted).
  final int revision;
  final int? createdAt;
  final int? serverUpdatedAt;
  final int? deletedAt;
  final int localVersion;
  final String syncStatus;
  final int localCreatedAt;
  final int localUpdatedAt;
  final String kind;
  final String businessDate;
  final String status;
  final int sourceWatermark;
  final String recordJson;
  const InsightRow({
    required this.userId,
    required this.id,
    required this.revision,
    this.createdAt,
    this.serverUpdatedAt,
    this.deletedAt,
    required this.localVersion,
    required this.syncStatus,
    required this.localCreatedAt,
    required this.localUpdatedAt,
    required this.kind,
    required this.businessDate,
    required this.status,
    required this.sourceWatermark,
    required this.recordJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<String>(userId);
    map['id'] = Variable<String>(id);
    map['revision'] = Variable<int>(revision);
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<int>(createdAt);
    }
    if (!nullToAbsent || serverUpdatedAt != null) {
      map['server_updated_at'] = Variable<int>(serverUpdatedAt);
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['local_version'] = Variable<int>(localVersion);
    map['sync_status'] = Variable<String>(syncStatus);
    map['local_created_at'] = Variable<int>(localCreatedAt);
    map['local_updated_at'] = Variable<int>(localUpdatedAt);
    map['kind'] = Variable<String>(kind);
    map['business_date'] = Variable<String>(businessDate);
    map['status'] = Variable<String>(status);
    map['source_watermark'] = Variable<int>(sourceWatermark);
    map['record_json'] = Variable<String>(recordJson);
    return map;
  }

  AiInsightsCompanion toCompanion(bool nullToAbsent) {
    return AiInsightsCompanion(
      userId: Value(userId),
      id: Value(id),
      revision: Value(revision),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      serverUpdatedAt: serverUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(serverUpdatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      localVersion: Value(localVersion),
      syncStatus: Value(syncStatus),
      localCreatedAt: Value(localCreatedAt),
      localUpdatedAt: Value(localUpdatedAt),
      kind: Value(kind),
      businessDate: Value(businessDate),
      status: Value(status),
      sourceWatermark: Value(sourceWatermark),
      recordJson: Value(recordJson),
    );
  }

  factory InsightRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InsightRow(
      userId: serializer.fromJson<String>(json['userId']),
      id: serializer.fromJson<String>(json['id']),
      revision: serializer.fromJson<int>(json['revision']),
      createdAt: serializer.fromJson<int?>(json['createdAt']),
      serverUpdatedAt: serializer.fromJson<int?>(json['serverUpdatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      localVersion: serializer.fromJson<int>(json['localVersion']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      localCreatedAt: serializer.fromJson<int>(json['localCreatedAt']),
      localUpdatedAt: serializer.fromJson<int>(json['localUpdatedAt']),
      kind: serializer.fromJson<String>(json['kind']),
      businessDate: serializer.fromJson<String>(json['businessDate']),
      status: serializer.fromJson<String>(json['status']),
      sourceWatermark: serializer.fromJson<int>(json['sourceWatermark']),
      recordJson: serializer.fromJson<String>(json['recordJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<String>(userId),
      'id': serializer.toJson<String>(id),
      'revision': serializer.toJson<int>(revision),
      'createdAt': serializer.toJson<int?>(createdAt),
      'serverUpdatedAt': serializer.toJson<int?>(serverUpdatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'localVersion': serializer.toJson<int>(localVersion),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'localCreatedAt': serializer.toJson<int>(localCreatedAt),
      'localUpdatedAt': serializer.toJson<int>(localUpdatedAt),
      'kind': serializer.toJson<String>(kind),
      'businessDate': serializer.toJson<String>(businessDate),
      'status': serializer.toJson<String>(status),
      'sourceWatermark': serializer.toJson<int>(sourceWatermark),
      'recordJson': serializer.toJson<String>(recordJson),
    };
  }

  InsightRow copyWith({
    String? userId,
    String? id,
    int? revision,
    Value<int?> createdAt = const Value.absent(),
    Value<int?> serverUpdatedAt = const Value.absent(),
    Value<int?> deletedAt = const Value.absent(),
    int? localVersion,
    String? syncStatus,
    int? localCreatedAt,
    int? localUpdatedAt,
    String? kind,
    String? businessDate,
    String? status,
    int? sourceWatermark,
    String? recordJson,
  }) => InsightRow(
    userId: userId ?? this.userId,
    id: id ?? this.id,
    revision: revision ?? this.revision,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
    serverUpdatedAt: serverUpdatedAt.present
        ? serverUpdatedAt.value
        : this.serverUpdatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    localVersion: localVersion ?? this.localVersion,
    syncStatus: syncStatus ?? this.syncStatus,
    localCreatedAt: localCreatedAt ?? this.localCreatedAt,
    localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
    kind: kind ?? this.kind,
    businessDate: businessDate ?? this.businessDate,
    status: status ?? this.status,
    sourceWatermark: sourceWatermark ?? this.sourceWatermark,
    recordJson: recordJson ?? this.recordJson,
  );
  InsightRow copyWithCompanion(AiInsightsCompanion data) {
    return InsightRow(
      userId: data.userId.present ? data.userId.value : this.userId,
      id: data.id.present ? data.id.value : this.id,
      revision: data.revision.present ? data.revision.value : this.revision,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      serverUpdatedAt: data.serverUpdatedAt.present
          ? data.serverUpdatedAt.value
          : this.serverUpdatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      localVersion: data.localVersion.present
          ? data.localVersion.value
          : this.localVersion,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      localCreatedAt: data.localCreatedAt.present
          ? data.localCreatedAt.value
          : this.localCreatedAt,
      localUpdatedAt: data.localUpdatedAt.present
          ? data.localUpdatedAt.value
          : this.localUpdatedAt,
      kind: data.kind.present ? data.kind.value : this.kind,
      businessDate: data.businessDate.present
          ? data.businessDate.value
          : this.businessDate,
      status: data.status.present ? data.status.value : this.status,
      sourceWatermark: data.sourceWatermark.present
          ? data.sourceWatermark.value
          : this.sourceWatermark,
      recordJson: data.recordJson.present
          ? data.recordJson.value
          : this.recordJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InsightRow(')
          ..write('userId: $userId, ')
          ..write('id: $id, ')
          ..write('revision: $revision, ')
          ..write('createdAt: $createdAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('localVersion: $localVersion, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('localCreatedAt: $localCreatedAt, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('kind: $kind, ')
          ..write('businessDate: $businessDate, ')
          ..write('status: $status, ')
          ..write('sourceWatermark: $sourceWatermark, ')
          ..write('recordJson: $recordJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    userId,
    id,
    revision,
    createdAt,
    serverUpdatedAt,
    deletedAt,
    localVersion,
    syncStatus,
    localCreatedAt,
    localUpdatedAt,
    kind,
    businessDate,
    status,
    sourceWatermark,
    recordJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InsightRow &&
          other.userId == this.userId &&
          other.id == this.id &&
          other.revision == this.revision &&
          other.createdAt == this.createdAt &&
          other.serverUpdatedAt == this.serverUpdatedAt &&
          other.deletedAt == this.deletedAt &&
          other.localVersion == this.localVersion &&
          other.syncStatus == this.syncStatus &&
          other.localCreatedAt == this.localCreatedAt &&
          other.localUpdatedAt == this.localUpdatedAt &&
          other.kind == this.kind &&
          other.businessDate == this.businessDate &&
          other.status == this.status &&
          other.sourceWatermark == this.sourceWatermark &&
          other.recordJson == this.recordJson);
}

class AiInsightsCompanion extends UpdateCompanion<InsightRow> {
  final Value<String> userId;
  final Value<String> id;
  final Value<int> revision;
  final Value<int?> createdAt;
  final Value<int?> serverUpdatedAt;
  final Value<int?> deletedAt;
  final Value<int> localVersion;
  final Value<String> syncStatus;
  final Value<int> localCreatedAt;
  final Value<int> localUpdatedAt;
  final Value<String> kind;
  final Value<String> businessDate;
  final Value<String> status;
  final Value<int> sourceWatermark;
  final Value<String> recordJson;
  final Value<int> rowid;
  const AiInsightsCompanion({
    this.userId = const Value.absent(),
    this.id = const Value.absent(),
    this.revision = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.localVersion = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.localCreatedAt = const Value.absent(),
    this.localUpdatedAt = const Value.absent(),
    this.kind = const Value.absent(),
    this.businessDate = const Value.absent(),
    this.status = const Value.absent(),
    this.sourceWatermark = const Value.absent(),
    this.recordJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AiInsightsCompanion.insert({
    required String userId,
    required String id,
    this.revision = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.localVersion = const Value.absent(),
    this.syncStatus = const Value.absent(),
    required int localCreatedAt,
    required int localUpdatedAt,
    required String kind,
    required String businessDate,
    required String status,
    required int sourceWatermark,
    required String recordJson,
    this.rowid = const Value.absent(),
  }) : userId = Value(userId),
       id = Value(id),
       localCreatedAt = Value(localCreatedAt),
       localUpdatedAt = Value(localUpdatedAt),
       kind = Value(kind),
       businessDate = Value(businessDate),
       status = Value(status),
       sourceWatermark = Value(sourceWatermark),
       recordJson = Value(recordJson);
  static Insertable<InsightRow> custom({
    Expression<String>? userId,
    Expression<String>? id,
    Expression<int>? revision,
    Expression<int>? createdAt,
    Expression<int>? serverUpdatedAt,
    Expression<int>? deletedAt,
    Expression<int>? localVersion,
    Expression<String>? syncStatus,
    Expression<int>? localCreatedAt,
    Expression<int>? localUpdatedAt,
    Expression<String>? kind,
    Expression<String>? businessDate,
    Expression<String>? status,
    Expression<int>? sourceWatermark,
    Expression<String>? recordJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (id != null) 'id': id,
      if (revision != null) 'revision': revision,
      if (createdAt != null) 'created_at': createdAt,
      if (serverUpdatedAt != null) 'server_updated_at': serverUpdatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (localVersion != null) 'local_version': localVersion,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (localCreatedAt != null) 'local_created_at': localCreatedAt,
      if (localUpdatedAt != null) 'local_updated_at': localUpdatedAt,
      if (kind != null) 'kind': kind,
      if (businessDate != null) 'business_date': businessDate,
      if (status != null) 'status': status,
      if (sourceWatermark != null) 'source_watermark': sourceWatermark,
      if (recordJson != null) 'record_json': recordJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AiInsightsCompanion copyWith({
    Value<String>? userId,
    Value<String>? id,
    Value<int>? revision,
    Value<int?>? createdAt,
    Value<int?>? serverUpdatedAt,
    Value<int?>? deletedAt,
    Value<int>? localVersion,
    Value<String>? syncStatus,
    Value<int>? localCreatedAt,
    Value<int>? localUpdatedAt,
    Value<String>? kind,
    Value<String>? businessDate,
    Value<String>? status,
    Value<int>? sourceWatermark,
    Value<String>? recordJson,
    Value<int>? rowid,
  }) {
    return AiInsightsCompanion(
      userId: userId ?? this.userId,
      id: id ?? this.id,
      revision: revision ?? this.revision,
      createdAt: createdAt ?? this.createdAt,
      serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      localVersion: localVersion ?? this.localVersion,
      syncStatus: syncStatus ?? this.syncStatus,
      localCreatedAt: localCreatedAt ?? this.localCreatedAt,
      localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
      kind: kind ?? this.kind,
      businessDate: businessDate ?? this.businessDate,
      status: status ?? this.status,
      sourceWatermark: sourceWatermark ?? this.sourceWatermark,
      recordJson: recordJson ?? this.recordJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (serverUpdatedAt.present) {
      map['server_updated_at'] = Variable<int>(serverUpdatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (localVersion.present) {
      map['local_version'] = Variable<int>(localVersion.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (localCreatedAt.present) {
      map['local_created_at'] = Variable<int>(localCreatedAt.value);
    }
    if (localUpdatedAt.present) {
      map['local_updated_at'] = Variable<int>(localUpdatedAt.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (businessDate.present) {
      map['business_date'] = Variable<String>(businessDate.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (sourceWatermark.present) {
      map['source_watermark'] = Variable<int>(sourceWatermark.value);
    }
    if (recordJson.present) {
      map['record_json'] = Variable<String>(recordJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AiInsightsCompanion(')
          ..write('userId: $userId, ')
          ..write('id: $id, ')
          ..write('revision: $revision, ')
          ..write('createdAt: $createdAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('localVersion: $localVersion, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('localCreatedAt: $localCreatedAt, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('kind: $kind, ')
          ..write('businessDate: $businessDate, ')
          ..write('status: $status, ')
          ..write('sourceWatermark: $sourceWatermark, ')
          ..write('recordJson: $recordJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AiProposalsTable extends AiProposals
    with TableInfo<$AiProposalsTable, ProposalRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AiProposalsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _serverUpdatedAtMeta = const VerificationMeta(
    'serverUpdatedAt',
  );
  @override
  late final GeneratedColumn<int> serverUpdatedAt = GeneratedColumn<int>(
    'server_updated_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _localVersionMeta = const VerificationMeta(
    'localVersion',
  );
  @override
  late final GeneratedColumn<int> localVersion = GeneratedColumn<int>(
    'local_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    check: () => syncStatus.isIn(syncStatuses),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('synced'),
  );
  static const VerificationMeta _localCreatedAtMeta = const VerificationMeta(
    'localCreatedAt',
  );
  @override
  late final GeneratedColumn<int> localCreatedAt = GeneratedColumn<int>(
    'local_created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localUpdatedAtMeta = const VerificationMeta(
    'localUpdatedAt',
  );
  @override
  late final GeneratedColumn<int> localUpdatedAt = GeneratedColumn<int>(
    'local_updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
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
  static const VerificationMeta _targetIdMeta = const VerificationMeta(
    'targetId',
  );
  @override
  late final GeneratedColumn<String> targetId = GeneratedColumn<String>(
    'target_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _targetRevisionMeta = const VerificationMeta(
    'targetRevision',
  );
  @override
  late final GeneratedColumn<int> targetRevision = GeneratedColumn<int>(
    'target_revision',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _expiresAtMeta = const VerificationMeta(
    'expiresAt',
  );
  @override
  late final GeneratedColumn<int> expiresAt = GeneratedColumn<int>(
    'expires_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recordJsonMeta = const VerificationMeta(
    'recordJson',
  );
  @override
  late final GeneratedColumn<String> recordJson = GeneratedColumn<String>(
    'record_json',
    aliasedName,
    false,
    check: () => const CustomExpression<bool>('json_valid(record_json)'),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    userId,
    id,
    revision,
    createdAt,
    serverUpdatedAt,
    deletedAt,
    localVersion,
    syncStatus,
    localCreatedAt,
    localUpdatedAt,
    kind,
    status,
    targetId,
    targetRevision,
    expiresAt,
    recordJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ai_proposals';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProposalRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('server_updated_at')) {
      context.handle(
        _serverUpdatedAtMeta,
        serverUpdatedAt.isAcceptableOrUnknown(
          data['server_updated_at']!,
          _serverUpdatedAtMeta,
        ),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('local_version')) {
      context.handle(
        _localVersionMeta,
        localVersion.isAcceptableOrUnknown(
          data['local_version']!,
          _localVersionMeta,
        ),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('local_created_at')) {
      context.handle(
        _localCreatedAtMeta,
        localCreatedAt.isAcceptableOrUnknown(
          data['local_created_at']!,
          _localCreatedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_localCreatedAtMeta);
    }
    if (data.containsKey('local_updated_at')) {
      context.handle(
        _localUpdatedAtMeta,
        localUpdatedAt.isAcceptableOrUnknown(
          data['local_updated_at']!,
          _localUpdatedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_localUpdatedAtMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('target_id')) {
      context.handle(
        _targetIdMeta,
        targetId.isAcceptableOrUnknown(data['target_id']!, _targetIdMeta),
      );
    }
    if (data.containsKey('target_revision')) {
      context.handle(
        _targetRevisionMeta,
        targetRevision.isAcceptableOrUnknown(
          data['target_revision']!,
          _targetRevisionMeta,
        ),
      );
    }
    if (data.containsKey('expires_at')) {
      context.handle(
        _expiresAtMeta,
        expiresAt.isAcceptableOrUnknown(data['expires_at']!, _expiresAtMeta),
      );
    } else if (isInserting) {
      context.missing(_expiresAtMeta);
    }
    if (data.containsKey('record_json')) {
      context.handle(
        _recordJsonMeta,
        recordJson.isAcceptableOrUnknown(data['record_json']!, _recordJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_recordJsonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId, id};
  @override
  ProposalRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProposalRow(
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      ),
      serverUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_updated_at'],
      ),
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      localVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}local_version'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      localCreatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}local_created_at'],
      )!,
      localUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}local_updated_at'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      targetId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_id'],
      ),
      targetRevision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_revision'],
      ),
      expiresAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}expires_at'],
      )!,
      recordJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}record_json'],
      )!,
    );
  }

  @override
  $AiProposalsTable createAlias(String alias) {
    return $AiProposalsTable(attachedDatabase, alias);
  }
}

class ProposalRow extends DataClass implements Insertable<ProposalRow> {
  final String userId;
  final String id;

  /// Last accepted remote revision (0 = never accepted).
  final int revision;
  final int? createdAt;
  final int? serverUpdatedAt;
  final int? deletedAt;
  final int localVersion;
  final String syncStatus;
  final int localCreatedAt;
  final int localUpdatedAt;
  final String kind;
  final String status;
  final String? targetId;
  final int? targetRevision;
  final int expiresAt;
  final String recordJson;
  const ProposalRow({
    required this.userId,
    required this.id,
    required this.revision,
    this.createdAt,
    this.serverUpdatedAt,
    this.deletedAt,
    required this.localVersion,
    required this.syncStatus,
    required this.localCreatedAt,
    required this.localUpdatedAt,
    required this.kind,
    required this.status,
    this.targetId,
    this.targetRevision,
    required this.expiresAt,
    required this.recordJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<String>(userId);
    map['id'] = Variable<String>(id);
    map['revision'] = Variable<int>(revision);
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<int>(createdAt);
    }
    if (!nullToAbsent || serverUpdatedAt != null) {
      map['server_updated_at'] = Variable<int>(serverUpdatedAt);
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['local_version'] = Variable<int>(localVersion);
    map['sync_status'] = Variable<String>(syncStatus);
    map['local_created_at'] = Variable<int>(localCreatedAt);
    map['local_updated_at'] = Variable<int>(localUpdatedAt);
    map['kind'] = Variable<String>(kind);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || targetId != null) {
      map['target_id'] = Variable<String>(targetId);
    }
    if (!nullToAbsent || targetRevision != null) {
      map['target_revision'] = Variable<int>(targetRevision);
    }
    map['expires_at'] = Variable<int>(expiresAt);
    map['record_json'] = Variable<String>(recordJson);
    return map;
  }

  AiProposalsCompanion toCompanion(bool nullToAbsent) {
    return AiProposalsCompanion(
      userId: Value(userId),
      id: Value(id),
      revision: Value(revision),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      serverUpdatedAt: serverUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(serverUpdatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      localVersion: Value(localVersion),
      syncStatus: Value(syncStatus),
      localCreatedAt: Value(localCreatedAt),
      localUpdatedAt: Value(localUpdatedAt),
      kind: Value(kind),
      status: Value(status),
      targetId: targetId == null && nullToAbsent
          ? const Value.absent()
          : Value(targetId),
      targetRevision: targetRevision == null && nullToAbsent
          ? const Value.absent()
          : Value(targetRevision),
      expiresAt: Value(expiresAt),
      recordJson: Value(recordJson),
    );
  }

  factory ProposalRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProposalRow(
      userId: serializer.fromJson<String>(json['userId']),
      id: serializer.fromJson<String>(json['id']),
      revision: serializer.fromJson<int>(json['revision']),
      createdAt: serializer.fromJson<int?>(json['createdAt']),
      serverUpdatedAt: serializer.fromJson<int?>(json['serverUpdatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      localVersion: serializer.fromJson<int>(json['localVersion']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      localCreatedAt: serializer.fromJson<int>(json['localCreatedAt']),
      localUpdatedAt: serializer.fromJson<int>(json['localUpdatedAt']),
      kind: serializer.fromJson<String>(json['kind']),
      status: serializer.fromJson<String>(json['status']),
      targetId: serializer.fromJson<String?>(json['targetId']),
      targetRevision: serializer.fromJson<int?>(json['targetRevision']),
      expiresAt: serializer.fromJson<int>(json['expiresAt']),
      recordJson: serializer.fromJson<String>(json['recordJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<String>(userId),
      'id': serializer.toJson<String>(id),
      'revision': serializer.toJson<int>(revision),
      'createdAt': serializer.toJson<int?>(createdAt),
      'serverUpdatedAt': serializer.toJson<int?>(serverUpdatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'localVersion': serializer.toJson<int>(localVersion),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'localCreatedAt': serializer.toJson<int>(localCreatedAt),
      'localUpdatedAt': serializer.toJson<int>(localUpdatedAt),
      'kind': serializer.toJson<String>(kind),
      'status': serializer.toJson<String>(status),
      'targetId': serializer.toJson<String?>(targetId),
      'targetRevision': serializer.toJson<int?>(targetRevision),
      'expiresAt': serializer.toJson<int>(expiresAt),
      'recordJson': serializer.toJson<String>(recordJson),
    };
  }

  ProposalRow copyWith({
    String? userId,
    String? id,
    int? revision,
    Value<int?> createdAt = const Value.absent(),
    Value<int?> serverUpdatedAt = const Value.absent(),
    Value<int?> deletedAt = const Value.absent(),
    int? localVersion,
    String? syncStatus,
    int? localCreatedAt,
    int? localUpdatedAt,
    String? kind,
    String? status,
    Value<String?> targetId = const Value.absent(),
    Value<int?> targetRevision = const Value.absent(),
    int? expiresAt,
    String? recordJson,
  }) => ProposalRow(
    userId: userId ?? this.userId,
    id: id ?? this.id,
    revision: revision ?? this.revision,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
    serverUpdatedAt: serverUpdatedAt.present
        ? serverUpdatedAt.value
        : this.serverUpdatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    localVersion: localVersion ?? this.localVersion,
    syncStatus: syncStatus ?? this.syncStatus,
    localCreatedAt: localCreatedAt ?? this.localCreatedAt,
    localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
    kind: kind ?? this.kind,
    status: status ?? this.status,
    targetId: targetId.present ? targetId.value : this.targetId,
    targetRevision: targetRevision.present
        ? targetRevision.value
        : this.targetRevision,
    expiresAt: expiresAt ?? this.expiresAt,
    recordJson: recordJson ?? this.recordJson,
  );
  ProposalRow copyWithCompanion(AiProposalsCompanion data) {
    return ProposalRow(
      userId: data.userId.present ? data.userId.value : this.userId,
      id: data.id.present ? data.id.value : this.id,
      revision: data.revision.present ? data.revision.value : this.revision,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      serverUpdatedAt: data.serverUpdatedAt.present
          ? data.serverUpdatedAt.value
          : this.serverUpdatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      localVersion: data.localVersion.present
          ? data.localVersion.value
          : this.localVersion,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      localCreatedAt: data.localCreatedAt.present
          ? data.localCreatedAt.value
          : this.localCreatedAt,
      localUpdatedAt: data.localUpdatedAt.present
          ? data.localUpdatedAt.value
          : this.localUpdatedAt,
      kind: data.kind.present ? data.kind.value : this.kind,
      status: data.status.present ? data.status.value : this.status,
      targetId: data.targetId.present ? data.targetId.value : this.targetId,
      targetRevision: data.targetRevision.present
          ? data.targetRevision.value
          : this.targetRevision,
      expiresAt: data.expiresAt.present ? data.expiresAt.value : this.expiresAt,
      recordJson: data.recordJson.present
          ? data.recordJson.value
          : this.recordJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProposalRow(')
          ..write('userId: $userId, ')
          ..write('id: $id, ')
          ..write('revision: $revision, ')
          ..write('createdAt: $createdAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('localVersion: $localVersion, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('localCreatedAt: $localCreatedAt, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('kind: $kind, ')
          ..write('status: $status, ')
          ..write('targetId: $targetId, ')
          ..write('targetRevision: $targetRevision, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('recordJson: $recordJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    userId,
    id,
    revision,
    createdAt,
    serverUpdatedAt,
    deletedAt,
    localVersion,
    syncStatus,
    localCreatedAt,
    localUpdatedAt,
    kind,
    status,
    targetId,
    targetRevision,
    expiresAt,
    recordJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProposalRow &&
          other.userId == this.userId &&
          other.id == this.id &&
          other.revision == this.revision &&
          other.createdAt == this.createdAt &&
          other.serverUpdatedAt == this.serverUpdatedAt &&
          other.deletedAt == this.deletedAt &&
          other.localVersion == this.localVersion &&
          other.syncStatus == this.syncStatus &&
          other.localCreatedAt == this.localCreatedAt &&
          other.localUpdatedAt == this.localUpdatedAt &&
          other.kind == this.kind &&
          other.status == this.status &&
          other.targetId == this.targetId &&
          other.targetRevision == this.targetRevision &&
          other.expiresAt == this.expiresAt &&
          other.recordJson == this.recordJson);
}

class AiProposalsCompanion extends UpdateCompanion<ProposalRow> {
  final Value<String> userId;
  final Value<String> id;
  final Value<int> revision;
  final Value<int?> createdAt;
  final Value<int?> serverUpdatedAt;
  final Value<int?> deletedAt;
  final Value<int> localVersion;
  final Value<String> syncStatus;
  final Value<int> localCreatedAt;
  final Value<int> localUpdatedAt;
  final Value<String> kind;
  final Value<String> status;
  final Value<String?> targetId;
  final Value<int?> targetRevision;
  final Value<int> expiresAt;
  final Value<String> recordJson;
  final Value<int> rowid;
  const AiProposalsCompanion({
    this.userId = const Value.absent(),
    this.id = const Value.absent(),
    this.revision = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.localVersion = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.localCreatedAt = const Value.absent(),
    this.localUpdatedAt = const Value.absent(),
    this.kind = const Value.absent(),
    this.status = const Value.absent(),
    this.targetId = const Value.absent(),
    this.targetRevision = const Value.absent(),
    this.expiresAt = const Value.absent(),
    this.recordJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AiProposalsCompanion.insert({
    required String userId,
    required String id,
    this.revision = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.localVersion = const Value.absent(),
    this.syncStatus = const Value.absent(),
    required int localCreatedAt,
    required int localUpdatedAt,
    required String kind,
    required String status,
    this.targetId = const Value.absent(),
    this.targetRevision = const Value.absent(),
    required int expiresAt,
    required String recordJson,
    this.rowid = const Value.absent(),
  }) : userId = Value(userId),
       id = Value(id),
       localCreatedAt = Value(localCreatedAt),
       localUpdatedAt = Value(localUpdatedAt),
       kind = Value(kind),
       status = Value(status),
       expiresAt = Value(expiresAt),
       recordJson = Value(recordJson);
  static Insertable<ProposalRow> custom({
    Expression<String>? userId,
    Expression<String>? id,
    Expression<int>? revision,
    Expression<int>? createdAt,
    Expression<int>? serverUpdatedAt,
    Expression<int>? deletedAt,
    Expression<int>? localVersion,
    Expression<String>? syncStatus,
    Expression<int>? localCreatedAt,
    Expression<int>? localUpdatedAt,
    Expression<String>? kind,
    Expression<String>? status,
    Expression<String>? targetId,
    Expression<int>? targetRevision,
    Expression<int>? expiresAt,
    Expression<String>? recordJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (id != null) 'id': id,
      if (revision != null) 'revision': revision,
      if (createdAt != null) 'created_at': createdAt,
      if (serverUpdatedAt != null) 'server_updated_at': serverUpdatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (localVersion != null) 'local_version': localVersion,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (localCreatedAt != null) 'local_created_at': localCreatedAt,
      if (localUpdatedAt != null) 'local_updated_at': localUpdatedAt,
      if (kind != null) 'kind': kind,
      if (status != null) 'status': status,
      if (targetId != null) 'target_id': targetId,
      if (targetRevision != null) 'target_revision': targetRevision,
      if (expiresAt != null) 'expires_at': expiresAt,
      if (recordJson != null) 'record_json': recordJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AiProposalsCompanion copyWith({
    Value<String>? userId,
    Value<String>? id,
    Value<int>? revision,
    Value<int?>? createdAt,
    Value<int?>? serverUpdatedAt,
    Value<int?>? deletedAt,
    Value<int>? localVersion,
    Value<String>? syncStatus,
    Value<int>? localCreatedAt,
    Value<int>? localUpdatedAt,
    Value<String>? kind,
    Value<String>? status,
    Value<String?>? targetId,
    Value<int?>? targetRevision,
    Value<int>? expiresAt,
    Value<String>? recordJson,
    Value<int>? rowid,
  }) {
    return AiProposalsCompanion(
      userId: userId ?? this.userId,
      id: id ?? this.id,
      revision: revision ?? this.revision,
      createdAt: createdAt ?? this.createdAt,
      serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      localVersion: localVersion ?? this.localVersion,
      syncStatus: syncStatus ?? this.syncStatus,
      localCreatedAt: localCreatedAt ?? this.localCreatedAt,
      localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
      kind: kind ?? this.kind,
      status: status ?? this.status,
      targetId: targetId ?? this.targetId,
      targetRevision: targetRevision ?? this.targetRevision,
      expiresAt: expiresAt ?? this.expiresAt,
      recordJson: recordJson ?? this.recordJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (serverUpdatedAt.present) {
      map['server_updated_at'] = Variable<int>(serverUpdatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (localVersion.present) {
      map['local_version'] = Variable<int>(localVersion.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (localCreatedAt.present) {
      map['local_created_at'] = Variable<int>(localCreatedAt.value);
    }
    if (localUpdatedAt.present) {
      map['local_updated_at'] = Variable<int>(localUpdatedAt.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (targetId.present) {
      map['target_id'] = Variable<String>(targetId.value);
    }
    if (targetRevision.present) {
      map['target_revision'] = Variable<int>(targetRevision.value);
    }
    if (expiresAt.present) {
      map['expires_at'] = Variable<int>(expiresAt.value);
    }
    if (recordJson.present) {
      map['record_json'] = Variable<String>(recordJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AiProposalsCompanion(')
          ..write('userId: $userId, ')
          ..write('id: $id, ')
          ..write('revision: $revision, ')
          ..write('createdAt: $createdAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('localVersion: $localVersion, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('localCreatedAt: $localCreatedAt, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('kind: $kind, ')
          ..write('status: $status, ')
          ..write('targetId: $targetId, ')
          ..write('targetRevision: $targetRevision, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('recordJson: $recordJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReviewStatesTable extends ReviewStates
    with TableInfo<$ReviewStatesTable, ReviewStateRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReviewStatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _serverUpdatedAtMeta = const VerificationMeta(
    'serverUpdatedAt',
  );
  @override
  late final GeneratedColumn<int> serverUpdatedAt = GeneratedColumn<int>(
    'server_updated_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _localVersionMeta = const VerificationMeta(
    'localVersion',
  );
  @override
  late final GeneratedColumn<int> localVersion = GeneratedColumn<int>(
    'local_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    check: () => syncStatus.isIn(syncStatuses),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('synced'),
  );
  static const VerificationMeta _localCreatedAtMeta = const VerificationMeta(
    'localCreatedAt',
  );
  @override
  late final GeneratedColumn<int> localCreatedAt = GeneratedColumn<int>(
    'local_created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localUpdatedAtMeta = const VerificationMeta(
    'localUpdatedAt',
  );
  @override
  late final GeneratedColumn<int> localUpdatedAt = GeneratedColumn<int>(
    'local_updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _transactionRevisionMeta =
      const VerificationMeta('transactionRevision');
  @override
  late final GeneratedColumn<int> transactionRevision = GeneratedColumn<int>(
    'transaction_revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
    'state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _proposalIdMeta = const VerificationMeta(
    'proposalId',
  );
  @override
  late final GeneratedColumn<String> proposalId = GeneratedColumn<String>(
    'proposal_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    userId,
    id,
    revision,
    createdAt,
    serverUpdatedAt,
    deletedAt,
    localVersion,
    syncStatus,
    localCreatedAt,
    localUpdatedAt,
    transactionRevision,
    state,
    proposalId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'review_states';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReviewStateRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('server_updated_at')) {
      context.handle(
        _serverUpdatedAtMeta,
        serverUpdatedAt.isAcceptableOrUnknown(
          data['server_updated_at']!,
          _serverUpdatedAtMeta,
        ),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('local_version')) {
      context.handle(
        _localVersionMeta,
        localVersion.isAcceptableOrUnknown(
          data['local_version']!,
          _localVersionMeta,
        ),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('local_created_at')) {
      context.handle(
        _localCreatedAtMeta,
        localCreatedAt.isAcceptableOrUnknown(
          data['local_created_at']!,
          _localCreatedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_localCreatedAtMeta);
    }
    if (data.containsKey('local_updated_at')) {
      context.handle(
        _localUpdatedAtMeta,
        localUpdatedAt.isAcceptableOrUnknown(
          data['local_updated_at']!,
          _localUpdatedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_localUpdatedAtMeta);
    }
    if (data.containsKey('transaction_revision')) {
      context.handle(
        _transactionRevisionMeta,
        transactionRevision.isAcceptableOrUnknown(
          data['transaction_revision']!,
          _transactionRevisionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_transactionRevisionMeta);
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    } else if (isInserting) {
      context.missing(_stateMeta);
    }
    if (data.containsKey('proposal_id')) {
      context.handle(
        _proposalIdMeta,
        proposalId.isAcceptableOrUnknown(data['proposal_id']!, _proposalIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId, id};
  @override
  ReviewStateRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReviewStateRow(
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      ),
      serverUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_updated_at'],
      ),
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      localVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}local_version'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      localCreatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}local_created_at'],
      )!,
      localUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}local_updated_at'],
      )!,
      transactionRevision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}transaction_revision'],
      )!,
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      )!,
      proposalId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}proposal_id'],
      ),
    );
  }

  @override
  $ReviewStatesTable createAlias(String alias) {
    return $ReviewStatesTable(attachedDatabase, alias);
  }
}

class ReviewStateRow extends DataClass implements Insertable<ReviewStateRow> {
  final String userId;
  final String id;

  /// Last accepted remote revision (0 = never accepted).
  final int revision;
  final int? createdAt;
  final int? serverUpdatedAt;
  final int? deletedAt;
  final int localVersion;
  final String syncStatus;
  final int localCreatedAt;
  final int localUpdatedAt;
  final int transactionRevision;
  final String state;
  final String? proposalId;
  const ReviewStateRow({
    required this.userId,
    required this.id,
    required this.revision,
    this.createdAt,
    this.serverUpdatedAt,
    this.deletedAt,
    required this.localVersion,
    required this.syncStatus,
    required this.localCreatedAt,
    required this.localUpdatedAt,
    required this.transactionRevision,
    required this.state,
    this.proposalId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<String>(userId);
    map['id'] = Variable<String>(id);
    map['revision'] = Variable<int>(revision);
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<int>(createdAt);
    }
    if (!nullToAbsent || serverUpdatedAt != null) {
      map['server_updated_at'] = Variable<int>(serverUpdatedAt);
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['local_version'] = Variable<int>(localVersion);
    map['sync_status'] = Variable<String>(syncStatus);
    map['local_created_at'] = Variable<int>(localCreatedAt);
    map['local_updated_at'] = Variable<int>(localUpdatedAt);
    map['transaction_revision'] = Variable<int>(transactionRevision);
    map['state'] = Variable<String>(state);
    if (!nullToAbsent || proposalId != null) {
      map['proposal_id'] = Variable<String>(proposalId);
    }
    return map;
  }

  ReviewStatesCompanion toCompanion(bool nullToAbsent) {
    return ReviewStatesCompanion(
      userId: Value(userId),
      id: Value(id),
      revision: Value(revision),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      serverUpdatedAt: serverUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(serverUpdatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      localVersion: Value(localVersion),
      syncStatus: Value(syncStatus),
      localCreatedAt: Value(localCreatedAt),
      localUpdatedAt: Value(localUpdatedAt),
      transactionRevision: Value(transactionRevision),
      state: Value(state),
      proposalId: proposalId == null && nullToAbsent
          ? const Value.absent()
          : Value(proposalId),
    );
  }

  factory ReviewStateRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReviewStateRow(
      userId: serializer.fromJson<String>(json['userId']),
      id: serializer.fromJson<String>(json['id']),
      revision: serializer.fromJson<int>(json['revision']),
      createdAt: serializer.fromJson<int?>(json['createdAt']),
      serverUpdatedAt: serializer.fromJson<int?>(json['serverUpdatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      localVersion: serializer.fromJson<int>(json['localVersion']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      localCreatedAt: serializer.fromJson<int>(json['localCreatedAt']),
      localUpdatedAt: serializer.fromJson<int>(json['localUpdatedAt']),
      transactionRevision: serializer.fromJson<int>(
        json['transactionRevision'],
      ),
      state: serializer.fromJson<String>(json['state']),
      proposalId: serializer.fromJson<String?>(json['proposalId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<String>(userId),
      'id': serializer.toJson<String>(id),
      'revision': serializer.toJson<int>(revision),
      'createdAt': serializer.toJson<int?>(createdAt),
      'serverUpdatedAt': serializer.toJson<int?>(serverUpdatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'localVersion': serializer.toJson<int>(localVersion),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'localCreatedAt': serializer.toJson<int>(localCreatedAt),
      'localUpdatedAt': serializer.toJson<int>(localUpdatedAt),
      'transactionRevision': serializer.toJson<int>(transactionRevision),
      'state': serializer.toJson<String>(state),
      'proposalId': serializer.toJson<String?>(proposalId),
    };
  }

  ReviewStateRow copyWith({
    String? userId,
    String? id,
    int? revision,
    Value<int?> createdAt = const Value.absent(),
    Value<int?> serverUpdatedAt = const Value.absent(),
    Value<int?> deletedAt = const Value.absent(),
    int? localVersion,
    String? syncStatus,
    int? localCreatedAt,
    int? localUpdatedAt,
    int? transactionRevision,
    String? state,
    Value<String?> proposalId = const Value.absent(),
  }) => ReviewStateRow(
    userId: userId ?? this.userId,
    id: id ?? this.id,
    revision: revision ?? this.revision,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
    serverUpdatedAt: serverUpdatedAt.present
        ? serverUpdatedAt.value
        : this.serverUpdatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    localVersion: localVersion ?? this.localVersion,
    syncStatus: syncStatus ?? this.syncStatus,
    localCreatedAt: localCreatedAt ?? this.localCreatedAt,
    localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
    transactionRevision: transactionRevision ?? this.transactionRevision,
    state: state ?? this.state,
    proposalId: proposalId.present ? proposalId.value : this.proposalId,
  );
  ReviewStateRow copyWithCompanion(ReviewStatesCompanion data) {
    return ReviewStateRow(
      userId: data.userId.present ? data.userId.value : this.userId,
      id: data.id.present ? data.id.value : this.id,
      revision: data.revision.present ? data.revision.value : this.revision,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      serverUpdatedAt: data.serverUpdatedAt.present
          ? data.serverUpdatedAt.value
          : this.serverUpdatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      localVersion: data.localVersion.present
          ? data.localVersion.value
          : this.localVersion,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      localCreatedAt: data.localCreatedAt.present
          ? data.localCreatedAt.value
          : this.localCreatedAt,
      localUpdatedAt: data.localUpdatedAt.present
          ? data.localUpdatedAt.value
          : this.localUpdatedAt,
      transactionRevision: data.transactionRevision.present
          ? data.transactionRevision.value
          : this.transactionRevision,
      state: data.state.present ? data.state.value : this.state,
      proposalId: data.proposalId.present
          ? data.proposalId.value
          : this.proposalId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReviewStateRow(')
          ..write('userId: $userId, ')
          ..write('id: $id, ')
          ..write('revision: $revision, ')
          ..write('createdAt: $createdAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('localVersion: $localVersion, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('localCreatedAt: $localCreatedAt, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('transactionRevision: $transactionRevision, ')
          ..write('state: $state, ')
          ..write('proposalId: $proposalId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    userId,
    id,
    revision,
    createdAt,
    serverUpdatedAt,
    deletedAt,
    localVersion,
    syncStatus,
    localCreatedAt,
    localUpdatedAt,
    transactionRevision,
    state,
    proposalId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReviewStateRow &&
          other.userId == this.userId &&
          other.id == this.id &&
          other.revision == this.revision &&
          other.createdAt == this.createdAt &&
          other.serverUpdatedAt == this.serverUpdatedAt &&
          other.deletedAt == this.deletedAt &&
          other.localVersion == this.localVersion &&
          other.syncStatus == this.syncStatus &&
          other.localCreatedAt == this.localCreatedAt &&
          other.localUpdatedAt == this.localUpdatedAt &&
          other.transactionRevision == this.transactionRevision &&
          other.state == this.state &&
          other.proposalId == this.proposalId);
}

class ReviewStatesCompanion extends UpdateCompanion<ReviewStateRow> {
  final Value<String> userId;
  final Value<String> id;
  final Value<int> revision;
  final Value<int?> createdAt;
  final Value<int?> serverUpdatedAt;
  final Value<int?> deletedAt;
  final Value<int> localVersion;
  final Value<String> syncStatus;
  final Value<int> localCreatedAt;
  final Value<int> localUpdatedAt;
  final Value<int> transactionRevision;
  final Value<String> state;
  final Value<String?> proposalId;
  final Value<int> rowid;
  const ReviewStatesCompanion({
    this.userId = const Value.absent(),
    this.id = const Value.absent(),
    this.revision = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.localVersion = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.localCreatedAt = const Value.absent(),
    this.localUpdatedAt = const Value.absent(),
    this.transactionRevision = const Value.absent(),
    this.state = const Value.absent(),
    this.proposalId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReviewStatesCompanion.insert({
    required String userId,
    required String id,
    this.revision = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.localVersion = const Value.absent(),
    this.syncStatus = const Value.absent(),
    required int localCreatedAt,
    required int localUpdatedAt,
    required int transactionRevision,
    required String state,
    this.proposalId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : userId = Value(userId),
       id = Value(id),
       localCreatedAt = Value(localCreatedAt),
       localUpdatedAt = Value(localUpdatedAt),
       transactionRevision = Value(transactionRevision),
       state = Value(state);
  static Insertable<ReviewStateRow> custom({
    Expression<String>? userId,
    Expression<String>? id,
    Expression<int>? revision,
    Expression<int>? createdAt,
    Expression<int>? serverUpdatedAt,
    Expression<int>? deletedAt,
    Expression<int>? localVersion,
    Expression<String>? syncStatus,
    Expression<int>? localCreatedAt,
    Expression<int>? localUpdatedAt,
    Expression<int>? transactionRevision,
    Expression<String>? state,
    Expression<String>? proposalId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (id != null) 'id': id,
      if (revision != null) 'revision': revision,
      if (createdAt != null) 'created_at': createdAt,
      if (serverUpdatedAt != null) 'server_updated_at': serverUpdatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (localVersion != null) 'local_version': localVersion,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (localCreatedAt != null) 'local_created_at': localCreatedAt,
      if (localUpdatedAt != null) 'local_updated_at': localUpdatedAt,
      if (transactionRevision != null)
        'transaction_revision': transactionRevision,
      if (state != null) 'state': state,
      if (proposalId != null) 'proposal_id': proposalId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReviewStatesCompanion copyWith({
    Value<String>? userId,
    Value<String>? id,
    Value<int>? revision,
    Value<int?>? createdAt,
    Value<int?>? serverUpdatedAt,
    Value<int?>? deletedAt,
    Value<int>? localVersion,
    Value<String>? syncStatus,
    Value<int>? localCreatedAt,
    Value<int>? localUpdatedAt,
    Value<int>? transactionRevision,
    Value<String>? state,
    Value<String?>? proposalId,
    Value<int>? rowid,
  }) {
    return ReviewStatesCompanion(
      userId: userId ?? this.userId,
      id: id ?? this.id,
      revision: revision ?? this.revision,
      createdAt: createdAt ?? this.createdAt,
      serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      localVersion: localVersion ?? this.localVersion,
      syncStatus: syncStatus ?? this.syncStatus,
      localCreatedAt: localCreatedAt ?? this.localCreatedAt,
      localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
      transactionRevision: transactionRevision ?? this.transactionRevision,
      state: state ?? this.state,
      proposalId: proposalId ?? this.proposalId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (serverUpdatedAt.present) {
      map['server_updated_at'] = Variable<int>(serverUpdatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (localVersion.present) {
      map['local_version'] = Variable<int>(localVersion.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (localCreatedAt.present) {
      map['local_created_at'] = Variable<int>(localCreatedAt.value);
    }
    if (localUpdatedAt.present) {
      map['local_updated_at'] = Variable<int>(localUpdatedAt.value);
    }
    if (transactionRevision.present) {
      map['transaction_revision'] = Variable<int>(transactionRevision.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (proposalId.present) {
      map['proposal_id'] = Variable<String>(proposalId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReviewStatesCompanion(')
          ..write('userId: $userId, ')
          ..write('id: $id, ')
          ..write('revision: $revision, ')
          ..write('createdAt: $createdAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('localVersion: $localVersion, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('localCreatedAt: $localCreatedAt, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('transactionRevision: $transactionRevision, ')
          ..write('state: $state, ')
          ..write('proposalId: $proposalId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AiActivitiesTable extends AiActivities
    with TableInfo<$AiActivitiesTable, ActivityRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AiActivitiesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _serverUpdatedAtMeta = const VerificationMeta(
    'serverUpdatedAt',
  );
  @override
  late final GeneratedColumn<int> serverUpdatedAt = GeneratedColumn<int>(
    'server_updated_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _localVersionMeta = const VerificationMeta(
    'localVersion',
  );
  @override
  late final GeneratedColumn<int> localVersion = GeneratedColumn<int>(
    'local_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    check: () => syncStatus.isIn(syncStatuses),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('synced'),
  );
  static const VerificationMeta _localCreatedAtMeta = const VerificationMeta(
    'localCreatedAt',
  );
  @override
  late final GeneratedColumn<int> localCreatedAt = GeneratedColumn<int>(
    'local_created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localUpdatedAtMeta = const VerificationMeta(
    'localUpdatedAt',
  );
  @override
  late final GeneratedColumn<int> localUpdatedAt = GeneratedColumn<int>(
    'local_updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _agentTypeMeta = const VerificationMeta(
    'agentType',
  );
  @override
  late final GeneratedColumn<String> agentType = GeneratedColumn<String>(
    'agent_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _outcomeMeta = const VerificationMeta(
    'outcome',
  );
  @override
  late final GeneratedColumn<String> outcome = GeneratedColumn<String>(
    'outcome',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recordJsonMeta = const VerificationMeta(
    'recordJson',
  );
  @override
  late final GeneratedColumn<String> recordJson = GeneratedColumn<String>(
    'record_json',
    aliasedName,
    false,
    check: () => const CustomExpression<bool>('json_valid(record_json)'),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    userId,
    id,
    revision,
    createdAt,
    serverUpdatedAt,
    deletedAt,
    localVersion,
    syncStatus,
    localCreatedAt,
    localUpdatedAt,
    agentType,
    outcome,
    recordJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ai_activities';
  @override
  VerificationContext validateIntegrity(
    Insertable<ActivityRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('server_updated_at')) {
      context.handle(
        _serverUpdatedAtMeta,
        serverUpdatedAt.isAcceptableOrUnknown(
          data['server_updated_at']!,
          _serverUpdatedAtMeta,
        ),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('local_version')) {
      context.handle(
        _localVersionMeta,
        localVersion.isAcceptableOrUnknown(
          data['local_version']!,
          _localVersionMeta,
        ),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('local_created_at')) {
      context.handle(
        _localCreatedAtMeta,
        localCreatedAt.isAcceptableOrUnknown(
          data['local_created_at']!,
          _localCreatedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_localCreatedAtMeta);
    }
    if (data.containsKey('local_updated_at')) {
      context.handle(
        _localUpdatedAtMeta,
        localUpdatedAt.isAcceptableOrUnknown(
          data['local_updated_at']!,
          _localUpdatedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_localUpdatedAtMeta);
    }
    if (data.containsKey('agent_type')) {
      context.handle(
        _agentTypeMeta,
        agentType.isAcceptableOrUnknown(data['agent_type']!, _agentTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_agentTypeMeta);
    }
    if (data.containsKey('outcome')) {
      context.handle(
        _outcomeMeta,
        outcome.isAcceptableOrUnknown(data['outcome']!, _outcomeMeta),
      );
    } else if (isInserting) {
      context.missing(_outcomeMeta);
    }
    if (data.containsKey('record_json')) {
      context.handle(
        _recordJsonMeta,
        recordJson.isAcceptableOrUnknown(data['record_json']!, _recordJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_recordJsonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId, id};
  @override
  ActivityRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ActivityRow(
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      ),
      serverUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_updated_at'],
      ),
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      localVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}local_version'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      localCreatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}local_created_at'],
      )!,
      localUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}local_updated_at'],
      )!,
      agentType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}agent_type'],
      )!,
      outcome: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}outcome'],
      )!,
      recordJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}record_json'],
      )!,
    );
  }

  @override
  $AiActivitiesTable createAlias(String alias) {
    return $AiActivitiesTable(attachedDatabase, alias);
  }
}

class ActivityRow extends DataClass implements Insertable<ActivityRow> {
  final String userId;
  final String id;

  /// Last accepted remote revision (0 = never accepted).
  final int revision;
  final int? createdAt;
  final int? serverUpdatedAt;
  final int? deletedAt;
  final int localVersion;
  final String syncStatus;
  final int localCreatedAt;
  final int localUpdatedAt;
  final String agentType;
  final String outcome;
  final String recordJson;
  const ActivityRow({
    required this.userId,
    required this.id,
    required this.revision,
    this.createdAt,
    this.serverUpdatedAt,
    this.deletedAt,
    required this.localVersion,
    required this.syncStatus,
    required this.localCreatedAt,
    required this.localUpdatedAt,
    required this.agentType,
    required this.outcome,
    required this.recordJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<String>(userId);
    map['id'] = Variable<String>(id);
    map['revision'] = Variable<int>(revision);
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<int>(createdAt);
    }
    if (!nullToAbsent || serverUpdatedAt != null) {
      map['server_updated_at'] = Variable<int>(serverUpdatedAt);
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['local_version'] = Variable<int>(localVersion);
    map['sync_status'] = Variable<String>(syncStatus);
    map['local_created_at'] = Variable<int>(localCreatedAt);
    map['local_updated_at'] = Variable<int>(localUpdatedAt);
    map['agent_type'] = Variable<String>(agentType);
    map['outcome'] = Variable<String>(outcome);
    map['record_json'] = Variable<String>(recordJson);
    return map;
  }

  AiActivitiesCompanion toCompanion(bool nullToAbsent) {
    return AiActivitiesCompanion(
      userId: Value(userId),
      id: Value(id),
      revision: Value(revision),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      serverUpdatedAt: serverUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(serverUpdatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      localVersion: Value(localVersion),
      syncStatus: Value(syncStatus),
      localCreatedAt: Value(localCreatedAt),
      localUpdatedAt: Value(localUpdatedAt),
      agentType: Value(agentType),
      outcome: Value(outcome),
      recordJson: Value(recordJson),
    );
  }

  factory ActivityRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ActivityRow(
      userId: serializer.fromJson<String>(json['userId']),
      id: serializer.fromJson<String>(json['id']),
      revision: serializer.fromJson<int>(json['revision']),
      createdAt: serializer.fromJson<int?>(json['createdAt']),
      serverUpdatedAt: serializer.fromJson<int?>(json['serverUpdatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      localVersion: serializer.fromJson<int>(json['localVersion']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      localCreatedAt: serializer.fromJson<int>(json['localCreatedAt']),
      localUpdatedAt: serializer.fromJson<int>(json['localUpdatedAt']),
      agentType: serializer.fromJson<String>(json['agentType']),
      outcome: serializer.fromJson<String>(json['outcome']),
      recordJson: serializer.fromJson<String>(json['recordJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<String>(userId),
      'id': serializer.toJson<String>(id),
      'revision': serializer.toJson<int>(revision),
      'createdAt': serializer.toJson<int?>(createdAt),
      'serverUpdatedAt': serializer.toJson<int?>(serverUpdatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'localVersion': serializer.toJson<int>(localVersion),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'localCreatedAt': serializer.toJson<int>(localCreatedAt),
      'localUpdatedAt': serializer.toJson<int>(localUpdatedAt),
      'agentType': serializer.toJson<String>(agentType),
      'outcome': serializer.toJson<String>(outcome),
      'recordJson': serializer.toJson<String>(recordJson),
    };
  }

  ActivityRow copyWith({
    String? userId,
    String? id,
    int? revision,
    Value<int?> createdAt = const Value.absent(),
    Value<int?> serverUpdatedAt = const Value.absent(),
    Value<int?> deletedAt = const Value.absent(),
    int? localVersion,
    String? syncStatus,
    int? localCreatedAt,
    int? localUpdatedAt,
    String? agentType,
    String? outcome,
    String? recordJson,
  }) => ActivityRow(
    userId: userId ?? this.userId,
    id: id ?? this.id,
    revision: revision ?? this.revision,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
    serverUpdatedAt: serverUpdatedAt.present
        ? serverUpdatedAt.value
        : this.serverUpdatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    localVersion: localVersion ?? this.localVersion,
    syncStatus: syncStatus ?? this.syncStatus,
    localCreatedAt: localCreatedAt ?? this.localCreatedAt,
    localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
    agentType: agentType ?? this.agentType,
    outcome: outcome ?? this.outcome,
    recordJson: recordJson ?? this.recordJson,
  );
  ActivityRow copyWithCompanion(AiActivitiesCompanion data) {
    return ActivityRow(
      userId: data.userId.present ? data.userId.value : this.userId,
      id: data.id.present ? data.id.value : this.id,
      revision: data.revision.present ? data.revision.value : this.revision,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      serverUpdatedAt: data.serverUpdatedAt.present
          ? data.serverUpdatedAt.value
          : this.serverUpdatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      localVersion: data.localVersion.present
          ? data.localVersion.value
          : this.localVersion,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      localCreatedAt: data.localCreatedAt.present
          ? data.localCreatedAt.value
          : this.localCreatedAt,
      localUpdatedAt: data.localUpdatedAt.present
          ? data.localUpdatedAt.value
          : this.localUpdatedAt,
      agentType: data.agentType.present ? data.agentType.value : this.agentType,
      outcome: data.outcome.present ? data.outcome.value : this.outcome,
      recordJson: data.recordJson.present
          ? data.recordJson.value
          : this.recordJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ActivityRow(')
          ..write('userId: $userId, ')
          ..write('id: $id, ')
          ..write('revision: $revision, ')
          ..write('createdAt: $createdAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('localVersion: $localVersion, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('localCreatedAt: $localCreatedAt, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('agentType: $agentType, ')
          ..write('outcome: $outcome, ')
          ..write('recordJson: $recordJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    userId,
    id,
    revision,
    createdAt,
    serverUpdatedAt,
    deletedAt,
    localVersion,
    syncStatus,
    localCreatedAt,
    localUpdatedAt,
    agentType,
    outcome,
    recordJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ActivityRow &&
          other.userId == this.userId &&
          other.id == this.id &&
          other.revision == this.revision &&
          other.createdAt == this.createdAt &&
          other.serverUpdatedAt == this.serverUpdatedAt &&
          other.deletedAt == this.deletedAt &&
          other.localVersion == this.localVersion &&
          other.syncStatus == this.syncStatus &&
          other.localCreatedAt == this.localCreatedAt &&
          other.localUpdatedAt == this.localUpdatedAt &&
          other.agentType == this.agentType &&
          other.outcome == this.outcome &&
          other.recordJson == this.recordJson);
}

class AiActivitiesCompanion extends UpdateCompanion<ActivityRow> {
  final Value<String> userId;
  final Value<String> id;
  final Value<int> revision;
  final Value<int?> createdAt;
  final Value<int?> serverUpdatedAt;
  final Value<int?> deletedAt;
  final Value<int> localVersion;
  final Value<String> syncStatus;
  final Value<int> localCreatedAt;
  final Value<int> localUpdatedAt;
  final Value<String> agentType;
  final Value<String> outcome;
  final Value<String> recordJson;
  final Value<int> rowid;
  const AiActivitiesCompanion({
    this.userId = const Value.absent(),
    this.id = const Value.absent(),
    this.revision = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.localVersion = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.localCreatedAt = const Value.absent(),
    this.localUpdatedAt = const Value.absent(),
    this.agentType = const Value.absent(),
    this.outcome = const Value.absent(),
    this.recordJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AiActivitiesCompanion.insert({
    required String userId,
    required String id,
    this.revision = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.localVersion = const Value.absent(),
    this.syncStatus = const Value.absent(),
    required int localCreatedAt,
    required int localUpdatedAt,
    required String agentType,
    required String outcome,
    required String recordJson,
    this.rowid = const Value.absent(),
  }) : userId = Value(userId),
       id = Value(id),
       localCreatedAt = Value(localCreatedAt),
       localUpdatedAt = Value(localUpdatedAt),
       agentType = Value(agentType),
       outcome = Value(outcome),
       recordJson = Value(recordJson);
  static Insertable<ActivityRow> custom({
    Expression<String>? userId,
    Expression<String>? id,
    Expression<int>? revision,
    Expression<int>? createdAt,
    Expression<int>? serverUpdatedAt,
    Expression<int>? deletedAt,
    Expression<int>? localVersion,
    Expression<String>? syncStatus,
    Expression<int>? localCreatedAt,
    Expression<int>? localUpdatedAt,
    Expression<String>? agentType,
    Expression<String>? outcome,
    Expression<String>? recordJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (id != null) 'id': id,
      if (revision != null) 'revision': revision,
      if (createdAt != null) 'created_at': createdAt,
      if (serverUpdatedAt != null) 'server_updated_at': serverUpdatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (localVersion != null) 'local_version': localVersion,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (localCreatedAt != null) 'local_created_at': localCreatedAt,
      if (localUpdatedAt != null) 'local_updated_at': localUpdatedAt,
      if (agentType != null) 'agent_type': agentType,
      if (outcome != null) 'outcome': outcome,
      if (recordJson != null) 'record_json': recordJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AiActivitiesCompanion copyWith({
    Value<String>? userId,
    Value<String>? id,
    Value<int>? revision,
    Value<int?>? createdAt,
    Value<int?>? serverUpdatedAt,
    Value<int?>? deletedAt,
    Value<int>? localVersion,
    Value<String>? syncStatus,
    Value<int>? localCreatedAt,
    Value<int>? localUpdatedAt,
    Value<String>? agentType,
    Value<String>? outcome,
    Value<String>? recordJson,
    Value<int>? rowid,
  }) {
    return AiActivitiesCompanion(
      userId: userId ?? this.userId,
      id: id ?? this.id,
      revision: revision ?? this.revision,
      createdAt: createdAt ?? this.createdAt,
      serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      localVersion: localVersion ?? this.localVersion,
      syncStatus: syncStatus ?? this.syncStatus,
      localCreatedAt: localCreatedAt ?? this.localCreatedAt,
      localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
      agentType: agentType ?? this.agentType,
      outcome: outcome ?? this.outcome,
      recordJson: recordJson ?? this.recordJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (serverUpdatedAt.present) {
      map['server_updated_at'] = Variable<int>(serverUpdatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (localVersion.present) {
      map['local_version'] = Variable<int>(localVersion.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (localCreatedAt.present) {
      map['local_created_at'] = Variable<int>(localCreatedAt.value);
    }
    if (localUpdatedAt.present) {
      map['local_updated_at'] = Variable<int>(localUpdatedAt.value);
    }
    if (agentType.present) {
      map['agent_type'] = Variable<String>(agentType.value);
    }
    if (outcome.present) {
      map['outcome'] = Variable<String>(outcome.value);
    }
    if (recordJson.present) {
      map['record_json'] = Variable<String>(recordJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AiActivitiesCompanion(')
          ..write('userId: $userId, ')
          ..write('id: $id, ')
          ..write('revision: $revision, ')
          ..write('createdAt: $createdAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('localVersion: $localVersion, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('localCreatedAt: $localCreatedAt, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('agentType: $agentType, ')
          ..write('outcome: $outcome, ')
          ..write('recordJson: $recordJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AgentRunsTable extends AgentRuns
    with TableInfo<$AgentRunsTable, AgentRunRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AgentRunsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _serverUpdatedAtMeta = const VerificationMeta(
    'serverUpdatedAt',
  );
  @override
  late final GeneratedColumn<int> serverUpdatedAt = GeneratedColumn<int>(
    'server_updated_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _localVersionMeta = const VerificationMeta(
    'localVersion',
  );
  @override
  late final GeneratedColumn<int> localVersion = GeneratedColumn<int>(
    'local_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    check: () => syncStatus.isIn(syncStatuses),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('synced'),
  );
  static const VerificationMeta _localCreatedAtMeta = const VerificationMeta(
    'localCreatedAt',
  );
  @override
  late final GeneratedColumn<int> localCreatedAt = GeneratedColumn<int>(
    'local_created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localUpdatedAtMeta = const VerificationMeta(
    'localUpdatedAt',
  );
  @override
  late final GeneratedColumn<int> localUpdatedAt = GeneratedColumn<int>(
    'local_updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _agentTypeMeta = const VerificationMeta(
    'agentType',
  );
  @override
  late final GeneratedColumn<String> agentType = GeneratedColumn<String>(
    'agent_type',
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
  static const VerificationMeta _businessDateMeta = const VerificationMeta(
    'businessDate',
  );
  @override
  late final GeneratedColumn<String> businessDate = GeneratedColumn<String>(
    'business_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _recordJsonMeta = const VerificationMeta(
    'recordJson',
  );
  @override
  late final GeneratedColumn<String> recordJson = GeneratedColumn<String>(
    'record_json',
    aliasedName,
    false,
    check: () => const CustomExpression<bool>('json_valid(record_json)'),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    userId,
    id,
    revision,
    createdAt,
    serverUpdatedAt,
    deletedAt,
    localVersion,
    syncStatus,
    localCreatedAt,
    localUpdatedAt,
    agentType,
    status,
    businessDate,
    recordJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'agent_runs';
  @override
  VerificationContext validateIntegrity(
    Insertable<AgentRunRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('server_updated_at')) {
      context.handle(
        _serverUpdatedAtMeta,
        serverUpdatedAt.isAcceptableOrUnknown(
          data['server_updated_at']!,
          _serverUpdatedAtMeta,
        ),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('local_version')) {
      context.handle(
        _localVersionMeta,
        localVersion.isAcceptableOrUnknown(
          data['local_version']!,
          _localVersionMeta,
        ),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('local_created_at')) {
      context.handle(
        _localCreatedAtMeta,
        localCreatedAt.isAcceptableOrUnknown(
          data['local_created_at']!,
          _localCreatedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_localCreatedAtMeta);
    }
    if (data.containsKey('local_updated_at')) {
      context.handle(
        _localUpdatedAtMeta,
        localUpdatedAt.isAcceptableOrUnknown(
          data['local_updated_at']!,
          _localUpdatedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_localUpdatedAtMeta);
    }
    if (data.containsKey('agent_type')) {
      context.handle(
        _agentTypeMeta,
        agentType.isAcceptableOrUnknown(data['agent_type']!, _agentTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_agentTypeMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('business_date')) {
      context.handle(
        _businessDateMeta,
        businessDate.isAcceptableOrUnknown(
          data['business_date']!,
          _businessDateMeta,
        ),
      );
    }
    if (data.containsKey('record_json')) {
      context.handle(
        _recordJsonMeta,
        recordJson.isAcceptableOrUnknown(data['record_json']!, _recordJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_recordJsonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId, id};
  @override
  AgentRunRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AgentRunRow(
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      ),
      serverUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_updated_at'],
      ),
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      localVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}local_version'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      localCreatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}local_created_at'],
      )!,
      localUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}local_updated_at'],
      )!,
      agentType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}agent_type'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      businessDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}business_date'],
      ),
      recordJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}record_json'],
      )!,
    );
  }

  @override
  $AgentRunsTable createAlias(String alias) {
    return $AgentRunsTable(attachedDatabase, alias);
  }
}

class AgentRunRow extends DataClass implements Insertable<AgentRunRow> {
  final String userId;
  final String id;

  /// Last accepted remote revision (0 = never accepted).
  final int revision;
  final int? createdAt;
  final int? serverUpdatedAt;
  final int? deletedAt;
  final int localVersion;
  final String syncStatus;
  final int localCreatedAt;
  final int localUpdatedAt;
  final String agentType;
  final String status;
  final String? businessDate;
  final String recordJson;
  const AgentRunRow({
    required this.userId,
    required this.id,
    required this.revision,
    this.createdAt,
    this.serverUpdatedAt,
    this.deletedAt,
    required this.localVersion,
    required this.syncStatus,
    required this.localCreatedAt,
    required this.localUpdatedAt,
    required this.agentType,
    required this.status,
    this.businessDate,
    required this.recordJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<String>(userId);
    map['id'] = Variable<String>(id);
    map['revision'] = Variable<int>(revision);
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<int>(createdAt);
    }
    if (!nullToAbsent || serverUpdatedAt != null) {
      map['server_updated_at'] = Variable<int>(serverUpdatedAt);
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['local_version'] = Variable<int>(localVersion);
    map['sync_status'] = Variable<String>(syncStatus);
    map['local_created_at'] = Variable<int>(localCreatedAt);
    map['local_updated_at'] = Variable<int>(localUpdatedAt);
    map['agent_type'] = Variable<String>(agentType);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || businessDate != null) {
      map['business_date'] = Variable<String>(businessDate);
    }
    map['record_json'] = Variable<String>(recordJson);
    return map;
  }

  AgentRunsCompanion toCompanion(bool nullToAbsent) {
    return AgentRunsCompanion(
      userId: Value(userId),
      id: Value(id),
      revision: Value(revision),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      serverUpdatedAt: serverUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(serverUpdatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      localVersion: Value(localVersion),
      syncStatus: Value(syncStatus),
      localCreatedAt: Value(localCreatedAt),
      localUpdatedAt: Value(localUpdatedAt),
      agentType: Value(agentType),
      status: Value(status),
      businessDate: businessDate == null && nullToAbsent
          ? const Value.absent()
          : Value(businessDate),
      recordJson: Value(recordJson),
    );
  }

  factory AgentRunRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AgentRunRow(
      userId: serializer.fromJson<String>(json['userId']),
      id: serializer.fromJson<String>(json['id']),
      revision: serializer.fromJson<int>(json['revision']),
      createdAt: serializer.fromJson<int?>(json['createdAt']),
      serverUpdatedAt: serializer.fromJson<int?>(json['serverUpdatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      localVersion: serializer.fromJson<int>(json['localVersion']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      localCreatedAt: serializer.fromJson<int>(json['localCreatedAt']),
      localUpdatedAt: serializer.fromJson<int>(json['localUpdatedAt']),
      agentType: serializer.fromJson<String>(json['agentType']),
      status: serializer.fromJson<String>(json['status']),
      businessDate: serializer.fromJson<String?>(json['businessDate']),
      recordJson: serializer.fromJson<String>(json['recordJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<String>(userId),
      'id': serializer.toJson<String>(id),
      'revision': serializer.toJson<int>(revision),
      'createdAt': serializer.toJson<int?>(createdAt),
      'serverUpdatedAt': serializer.toJson<int?>(serverUpdatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'localVersion': serializer.toJson<int>(localVersion),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'localCreatedAt': serializer.toJson<int>(localCreatedAt),
      'localUpdatedAt': serializer.toJson<int>(localUpdatedAt),
      'agentType': serializer.toJson<String>(agentType),
      'status': serializer.toJson<String>(status),
      'businessDate': serializer.toJson<String?>(businessDate),
      'recordJson': serializer.toJson<String>(recordJson),
    };
  }

  AgentRunRow copyWith({
    String? userId,
    String? id,
    int? revision,
    Value<int?> createdAt = const Value.absent(),
    Value<int?> serverUpdatedAt = const Value.absent(),
    Value<int?> deletedAt = const Value.absent(),
    int? localVersion,
    String? syncStatus,
    int? localCreatedAt,
    int? localUpdatedAt,
    String? agentType,
    String? status,
    Value<String?> businessDate = const Value.absent(),
    String? recordJson,
  }) => AgentRunRow(
    userId: userId ?? this.userId,
    id: id ?? this.id,
    revision: revision ?? this.revision,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
    serverUpdatedAt: serverUpdatedAt.present
        ? serverUpdatedAt.value
        : this.serverUpdatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    localVersion: localVersion ?? this.localVersion,
    syncStatus: syncStatus ?? this.syncStatus,
    localCreatedAt: localCreatedAt ?? this.localCreatedAt,
    localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
    agentType: agentType ?? this.agentType,
    status: status ?? this.status,
    businessDate: businessDate.present ? businessDate.value : this.businessDate,
    recordJson: recordJson ?? this.recordJson,
  );
  AgentRunRow copyWithCompanion(AgentRunsCompanion data) {
    return AgentRunRow(
      userId: data.userId.present ? data.userId.value : this.userId,
      id: data.id.present ? data.id.value : this.id,
      revision: data.revision.present ? data.revision.value : this.revision,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      serverUpdatedAt: data.serverUpdatedAt.present
          ? data.serverUpdatedAt.value
          : this.serverUpdatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      localVersion: data.localVersion.present
          ? data.localVersion.value
          : this.localVersion,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      localCreatedAt: data.localCreatedAt.present
          ? data.localCreatedAt.value
          : this.localCreatedAt,
      localUpdatedAt: data.localUpdatedAt.present
          ? data.localUpdatedAt.value
          : this.localUpdatedAt,
      agentType: data.agentType.present ? data.agentType.value : this.agentType,
      status: data.status.present ? data.status.value : this.status,
      businessDate: data.businessDate.present
          ? data.businessDate.value
          : this.businessDate,
      recordJson: data.recordJson.present
          ? data.recordJson.value
          : this.recordJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AgentRunRow(')
          ..write('userId: $userId, ')
          ..write('id: $id, ')
          ..write('revision: $revision, ')
          ..write('createdAt: $createdAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('localVersion: $localVersion, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('localCreatedAt: $localCreatedAt, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('agentType: $agentType, ')
          ..write('status: $status, ')
          ..write('businessDate: $businessDate, ')
          ..write('recordJson: $recordJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    userId,
    id,
    revision,
    createdAt,
    serverUpdatedAt,
    deletedAt,
    localVersion,
    syncStatus,
    localCreatedAt,
    localUpdatedAt,
    agentType,
    status,
    businessDate,
    recordJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AgentRunRow &&
          other.userId == this.userId &&
          other.id == this.id &&
          other.revision == this.revision &&
          other.createdAt == this.createdAt &&
          other.serverUpdatedAt == this.serverUpdatedAt &&
          other.deletedAt == this.deletedAt &&
          other.localVersion == this.localVersion &&
          other.syncStatus == this.syncStatus &&
          other.localCreatedAt == this.localCreatedAt &&
          other.localUpdatedAt == this.localUpdatedAt &&
          other.agentType == this.agentType &&
          other.status == this.status &&
          other.businessDate == this.businessDate &&
          other.recordJson == this.recordJson);
}

class AgentRunsCompanion extends UpdateCompanion<AgentRunRow> {
  final Value<String> userId;
  final Value<String> id;
  final Value<int> revision;
  final Value<int?> createdAt;
  final Value<int?> serverUpdatedAt;
  final Value<int?> deletedAt;
  final Value<int> localVersion;
  final Value<String> syncStatus;
  final Value<int> localCreatedAt;
  final Value<int> localUpdatedAt;
  final Value<String> agentType;
  final Value<String> status;
  final Value<String?> businessDate;
  final Value<String> recordJson;
  final Value<int> rowid;
  const AgentRunsCompanion({
    this.userId = const Value.absent(),
    this.id = const Value.absent(),
    this.revision = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.localVersion = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.localCreatedAt = const Value.absent(),
    this.localUpdatedAt = const Value.absent(),
    this.agentType = const Value.absent(),
    this.status = const Value.absent(),
    this.businessDate = const Value.absent(),
    this.recordJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AgentRunsCompanion.insert({
    required String userId,
    required String id,
    this.revision = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.localVersion = const Value.absent(),
    this.syncStatus = const Value.absent(),
    required int localCreatedAt,
    required int localUpdatedAt,
    required String agentType,
    required String status,
    this.businessDate = const Value.absent(),
    required String recordJson,
    this.rowid = const Value.absent(),
  }) : userId = Value(userId),
       id = Value(id),
       localCreatedAt = Value(localCreatedAt),
       localUpdatedAt = Value(localUpdatedAt),
       agentType = Value(agentType),
       status = Value(status),
       recordJson = Value(recordJson);
  static Insertable<AgentRunRow> custom({
    Expression<String>? userId,
    Expression<String>? id,
    Expression<int>? revision,
    Expression<int>? createdAt,
    Expression<int>? serverUpdatedAt,
    Expression<int>? deletedAt,
    Expression<int>? localVersion,
    Expression<String>? syncStatus,
    Expression<int>? localCreatedAt,
    Expression<int>? localUpdatedAt,
    Expression<String>? agentType,
    Expression<String>? status,
    Expression<String>? businessDate,
    Expression<String>? recordJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (id != null) 'id': id,
      if (revision != null) 'revision': revision,
      if (createdAt != null) 'created_at': createdAt,
      if (serverUpdatedAt != null) 'server_updated_at': serverUpdatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (localVersion != null) 'local_version': localVersion,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (localCreatedAt != null) 'local_created_at': localCreatedAt,
      if (localUpdatedAt != null) 'local_updated_at': localUpdatedAt,
      if (agentType != null) 'agent_type': agentType,
      if (status != null) 'status': status,
      if (businessDate != null) 'business_date': businessDate,
      if (recordJson != null) 'record_json': recordJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AgentRunsCompanion copyWith({
    Value<String>? userId,
    Value<String>? id,
    Value<int>? revision,
    Value<int?>? createdAt,
    Value<int?>? serverUpdatedAt,
    Value<int?>? deletedAt,
    Value<int>? localVersion,
    Value<String>? syncStatus,
    Value<int>? localCreatedAt,
    Value<int>? localUpdatedAt,
    Value<String>? agentType,
    Value<String>? status,
    Value<String?>? businessDate,
    Value<String>? recordJson,
    Value<int>? rowid,
  }) {
    return AgentRunsCompanion(
      userId: userId ?? this.userId,
      id: id ?? this.id,
      revision: revision ?? this.revision,
      createdAt: createdAt ?? this.createdAt,
      serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      localVersion: localVersion ?? this.localVersion,
      syncStatus: syncStatus ?? this.syncStatus,
      localCreatedAt: localCreatedAt ?? this.localCreatedAt,
      localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
      agentType: agentType ?? this.agentType,
      status: status ?? this.status,
      businessDate: businessDate ?? this.businessDate,
      recordJson: recordJson ?? this.recordJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (serverUpdatedAt.present) {
      map['server_updated_at'] = Variable<int>(serverUpdatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (localVersion.present) {
      map['local_version'] = Variable<int>(localVersion.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (localCreatedAt.present) {
      map['local_created_at'] = Variable<int>(localCreatedAt.value);
    }
    if (localUpdatedAt.present) {
      map['local_updated_at'] = Variable<int>(localUpdatedAt.value);
    }
    if (agentType.present) {
      map['agent_type'] = Variable<String>(agentType.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (businessDate.present) {
      map['business_date'] = Variable<String>(businessDate.value);
    }
    if (recordJson.present) {
      map['record_json'] = Variable<String>(recordJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AgentRunsCompanion(')
          ..write('userId: $userId, ')
          ..write('id: $id, ')
          ..write('revision: $revision, ')
          ..write('createdAt: $createdAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('localVersion: $localVersion, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('localCreatedAt: $localCreatedAt, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('agentType: $agentType, ')
          ..write('status: $status, ')
          ..write('businessDate: $businessDate, ')
          ..write('recordJson: $recordJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OutboxOpsTable extends OutboxOps
    with TableInfo<$OutboxOpsTable, OutboxRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OutboxOpsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _ordinalMeta = const VerificationMeta(
    'ordinal',
  );
  @override
  late final GeneratedColumn<int> ordinal = GeneratedColumn<int>(
    'ordinal',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _opIdMeta = const VerificationMeta('opId');
  @override
  late final GeneratedColumn<String> opId = GeneratedColumn<String>(
    'op_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actionMeta = const VerificationMeta('action');
  @override
  late final GeneratedColumn<String> action = GeneratedColumn<String>(
    'action',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _baseRevisionMeta = const VerificationMeta(
    'baseRevision',
  );
  @override
  late final GeneratedColumn<int> baseRevision = GeneratedColumn<int>(
    'base_revision',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dependsOnOpIdMeta = const VerificationMeta(
    'dependsOnOpId',
  );
  @override
  late final GeneratedColumn<String> dependsOnOpId = GeneratedColumn<String>(
    'depends_on_op_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _confirmationJsonMeta = const VerificationMeta(
    'confirmationJson',
  );
  @override
  late final GeneratedColumn<String> confirmationJson = GeneratedColumn<String>(
    'confirmation_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _requestHashMeta = const VerificationMeta(
    'requestHash',
  );
  @override
  late final GeneratedColumn<String> requestHash = GeneratedColumn<String>(
    'request_hash',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localVersionMeta = const VerificationMeta(
    'localVersion',
  );
  @override
  late final GeneratedColumn<int> localVersion = GeneratedColumn<int>(
    'local_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
    'state',
    aliasedName,
    false,
    check: () => state.isIn(outboxStates),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _attemptsMeta = const VerificationMeta(
    'attempts',
  );
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
    'attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _nextAttemptAtMeta = const VerificationMeta(
    'nextAttemptAt',
  );
  @override
  late final GeneratedColumn<int> nextAttemptAt = GeneratedColumn<int>(
    'next_attempt_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _errorCodeMeta = const VerificationMeta(
    'errorCode',
  );
  @override
  late final GeneratedColumn<String> errorCode = GeneratedColumn<String>(
    'error_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    ordinal,
    opId,
    userId,
    entityType,
    entityId,
    action,
    baseRevision,
    dependsOnOpId,
    payloadJson,
    confirmationJson,
    requestHash,
    localVersion,
    state,
    attempts,
    nextAttemptAt,
    errorCode,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'outbox_ops';
  @override
  VerificationContext validateIntegrity(
    Insertable<OutboxRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('ordinal')) {
      context.handle(
        _ordinalMeta,
        ordinal.isAcceptableOrUnknown(data['ordinal']!, _ordinalMeta),
      );
    }
    if (data.containsKey('op_id')) {
      context.handle(
        _opIdMeta,
        opId.isAcceptableOrUnknown(data['op_id']!, _opIdMeta),
      );
    } else if (isInserting) {
      context.missing(_opIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('action')) {
      context.handle(
        _actionMeta,
        action.isAcceptableOrUnknown(data['action']!, _actionMeta),
      );
    } else if (isInserting) {
      context.missing(_actionMeta);
    }
    if (data.containsKey('base_revision')) {
      context.handle(
        _baseRevisionMeta,
        baseRevision.isAcceptableOrUnknown(
          data['base_revision']!,
          _baseRevisionMeta,
        ),
      );
    }
    if (data.containsKey('depends_on_op_id')) {
      context.handle(
        _dependsOnOpIdMeta,
        dependsOnOpId.isAcceptableOrUnknown(
          data['depends_on_op_id']!,
          _dependsOnOpIdMeta,
        ),
      );
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    }
    if (data.containsKey('confirmation_json')) {
      context.handle(
        _confirmationJsonMeta,
        confirmationJson.isAcceptableOrUnknown(
          data['confirmation_json']!,
          _confirmationJsonMeta,
        ),
      );
    }
    if (data.containsKey('request_hash')) {
      context.handle(
        _requestHashMeta,
        requestHash.isAcceptableOrUnknown(
          data['request_hash']!,
          _requestHashMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_requestHashMeta);
    }
    if (data.containsKey('local_version')) {
      context.handle(
        _localVersionMeta,
        localVersion.isAcceptableOrUnknown(
          data['local_version']!,
          _localVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_localVersionMeta);
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    } else if (isInserting) {
      context.missing(_stateMeta);
    }
    if (data.containsKey('attempts')) {
      context.handle(
        _attemptsMeta,
        attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta),
      );
    }
    if (data.containsKey('next_attempt_at')) {
      context.handle(
        _nextAttemptAtMeta,
        nextAttemptAt.isAcceptableOrUnknown(
          data['next_attempt_at']!,
          _nextAttemptAtMeta,
        ),
      );
    }
    if (data.containsKey('error_code')) {
      context.handle(
        _errorCodeMeta,
        errorCode.isAcceptableOrUnknown(data['error_code']!, _errorCodeMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {ordinal};
  @override
  OutboxRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OutboxRow(
      ordinal: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ordinal'],
      )!,
      opId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}op_id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      action: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}action'],
      )!,
      baseRevision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}base_revision'],
      ),
      dependsOnOpId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}depends_on_op_id'],
      ),
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      ),
      confirmationJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}confirmation_json'],
      ),
      requestHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}request_hash'],
      )!,
      localVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}local_version'],
      )!,
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      )!,
      attempts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempts'],
      )!,
      nextAttemptAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}next_attempt_at'],
      ),
      errorCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error_code'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $OutboxOpsTable createAlias(String alias) {
    return $OutboxOpsTable(attachedDatabase, alias);
  }
}

class OutboxRow extends DataClass implements Insertable<OutboxRow> {
  final int ordinal;
  final String opId;
  final String userId;
  final String entityType;
  final String entityId;
  final String action;
  final int? baseRevision;
  final String? dependsOnOpId;
  final String? payloadJson;
  final String? confirmationJson;
  final String requestHash;
  final int localVersion;
  final String state;
  final int attempts;
  final int? nextAttemptAt;
  final String? errorCode;
  final int createdAt;
  const OutboxRow({
    required this.ordinal,
    required this.opId,
    required this.userId,
    required this.entityType,
    required this.entityId,
    required this.action,
    this.baseRevision,
    this.dependsOnOpId,
    this.payloadJson,
    this.confirmationJson,
    required this.requestHash,
    required this.localVersion,
    required this.state,
    required this.attempts,
    this.nextAttemptAt,
    this.errorCode,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['ordinal'] = Variable<int>(ordinal);
    map['op_id'] = Variable<String>(opId);
    map['user_id'] = Variable<String>(userId);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    map['action'] = Variable<String>(action);
    if (!nullToAbsent || baseRevision != null) {
      map['base_revision'] = Variable<int>(baseRevision);
    }
    if (!nullToAbsent || dependsOnOpId != null) {
      map['depends_on_op_id'] = Variable<String>(dependsOnOpId);
    }
    if (!nullToAbsent || payloadJson != null) {
      map['payload_json'] = Variable<String>(payloadJson);
    }
    if (!nullToAbsent || confirmationJson != null) {
      map['confirmation_json'] = Variable<String>(confirmationJson);
    }
    map['request_hash'] = Variable<String>(requestHash);
    map['local_version'] = Variable<int>(localVersion);
    map['state'] = Variable<String>(state);
    map['attempts'] = Variable<int>(attempts);
    if (!nullToAbsent || nextAttemptAt != null) {
      map['next_attempt_at'] = Variable<int>(nextAttemptAt);
    }
    if (!nullToAbsent || errorCode != null) {
      map['error_code'] = Variable<String>(errorCode);
    }
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  OutboxOpsCompanion toCompanion(bool nullToAbsent) {
    return OutboxOpsCompanion(
      ordinal: Value(ordinal),
      opId: Value(opId),
      userId: Value(userId),
      entityType: Value(entityType),
      entityId: Value(entityId),
      action: Value(action),
      baseRevision: baseRevision == null && nullToAbsent
          ? const Value.absent()
          : Value(baseRevision),
      dependsOnOpId: dependsOnOpId == null && nullToAbsent
          ? const Value.absent()
          : Value(dependsOnOpId),
      payloadJson: payloadJson == null && nullToAbsent
          ? const Value.absent()
          : Value(payloadJson),
      confirmationJson: confirmationJson == null && nullToAbsent
          ? const Value.absent()
          : Value(confirmationJson),
      requestHash: Value(requestHash),
      localVersion: Value(localVersion),
      state: Value(state),
      attempts: Value(attempts),
      nextAttemptAt: nextAttemptAt == null && nullToAbsent
          ? const Value.absent()
          : Value(nextAttemptAt),
      errorCode: errorCode == null && nullToAbsent
          ? const Value.absent()
          : Value(errorCode),
      createdAt: Value(createdAt),
    );
  }

  factory OutboxRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OutboxRow(
      ordinal: serializer.fromJson<int>(json['ordinal']),
      opId: serializer.fromJson<String>(json['opId']),
      userId: serializer.fromJson<String>(json['userId']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      action: serializer.fromJson<String>(json['action']),
      baseRevision: serializer.fromJson<int?>(json['baseRevision']),
      dependsOnOpId: serializer.fromJson<String?>(json['dependsOnOpId']),
      payloadJson: serializer.fromJson<String?>(json['payloadJson']),
      confirmationJson: serializer.fromJson<String?>(json['confirmationJson']),
      requestHash: serializer.fromJson<String>(json['requestHash']),
      localVersion: serializer.fromJson<int>(json['localVersion']),
      state: serializer.fromJson<String>(json['state']),
      attempts: serializer.fromJson<int>(json['attempts']),
      nextAttemptAt: serializer.fromJson<int?>(json['nextAttemptAt']),
      errorCode: serializer.fromJson<String?>(json['errorCode']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'ordinal': serializer.toJson<int>(ordinal),
      'opId': serializer.toJson<String>(opId),
      'userId': serializer.toJson<String>(userId),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'action': serializer.toJson<String>(action),
      'baseRevision': serializer.toJson<int?>(baseRevision),
      'dependsOnOpId': serializer.toJson<String?>(dependsOnOpId),
      'payloadJson': serializer.toJson<String?>(payloadJson),
      'confirmationJson': serializer.toJson<String?>(confirmationJson),
      'requestHash': serializer.toJson<String>(requestHash),
      'localVersion': serializer.toJson<int>(localVersion),
      'state': serializer.toJson<String>(state),
      'attempts': serializer.toJson<int>(attempts),
      'nextAttemptAt': serializer.toJson<int?>(nextAttemptAt),
      'errorCode': serializer.toJson<String?>(errorCode),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  OutboxRow copyWith({
    int? ordinal,
    String? opId,
    String? userId,
    String? entityType,
    String? entityId,
    String? action,
    Value<int?> baseRevision = const Value.absent(),
    Value<String?> dependsOnOpId = const Value.absent(),
    Value<String?> payloadJson = const Value.absent(),
    Value<String?> confirmationJson = const Value.absent(),
    String? requestHash,
    int? localVersion,
    String? state,
    int? attempts,
    Value<int?> nextAttemptAt = const Value.absent(),
    Value<String?> errorCode = const Value.absent(),
    int? createdAt,
  }) => OutboxRow(
    ordinal: ordinal ?? this.ordinal,
    opId: opId ?? this.opId,
    userId: userId ?? this.userId,
    entityType: entityType ?? this.entityType,
    entityId: entityId ?? this.entityId,
    action: action ?? this.action,
    baseRevision: baseRevision.present ? baseRevision.value : this.baseRevision,
    dependsOnOpId: dependsOnOpId.present
        ? dependsOnOpId.value
        : this.dependsOnOpId,
    payloadJson: payloadJson.present ? payloadJson.value : this.payloadJson,
    confirmationJson: confirmationJson.present
        ? confirmationJson.value
        : this.confirmationJson,
    requestHash: requestHash ?? this.requestHash,
    localVersion: localVersion ?? this.localVersion,
    state: state ?? this.state,
    attempts: attempts ?? this.attempts,
    nextAttemptAt: nextAttemptAt.present
        ? nextAttemptAt.value
        : this.nextAttemptAt,
    errorCode: errorCode.present ? errorCode.value : this.errorCode,
    createdAt: createdAt ?? this.createdAt,
  );
  OutboxRow copyWithCompanion(OutboxOpsCompanion data) {
    return OutboxRow(
      ordinal: data.ordinal.present ? data.ordinal.value : this.ordinal,
      opId: data.opId.present ? data.opId.value : this.opId,
      userId: data.userId.present ? data.userId.value : this.userId,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      action: data.action.present ? data.action.value : this.action,
      baseRevision: data.baseRevision.present
          ? data.baseRevision.value
          : this.baseRevision,
      dependsOnOpId: data.dependsOnOpId.present
          ? data.dependsOnOpId.value
          : this.dependsOnOpId,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      confirmationJson: data.confirmationJson.present
          ? data.confirmationJson.value
          : this.confirmationJson,
      requestHash: data.requestHash.present
          ? data.requestHash.value
          : this.requestHash,
      localVersion: data.localVersion.present
          ? data.localVersion.value
          : this.localVersion,
      state: data.state.present ? data.state.value : this.state,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      nextAttemptAt: data.nextAttemptAt.present
          ? data.nextAttemptAt.value
          : this.nextAttemptAt,
      errorCode: data.errorCode.present ? data.errorCode.value : this.errorCode,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OutboxRow(')
          ..write('ordinal: $ordinal, ')
          ..write('opId: $opId, ')
          ..write('userId: $userId, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('action: $action, ')
          ..write('baseRevision: $baseRevision, ')
          ..write('dependsOnOpId: $dependsOnOpId, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('confirmationJson: $confirmationJson, ')
          ..write('requestHash: $requestHash, ')
          ..write('localVersion: $localVersion, ')
          ..write('state: $state, ')
          ..write('attempts: $attempts, ')
          ..write('nextAttemptAt: $nextAttemptAt, ')
          ..write('errorCode: $errorCode, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    ordinal,
    opId,
    userId,
    entityType,
    entityId,
    action,
    baseRevision,
    dependsOnOpId,
    payloadJson,
    confirmationJson,
    requestHash,
    localVersion,
    state,
    attempts,
    nextAttemptAt,
    errorCode,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OutboxRow &&
          other.ordinal == this.ordinal &&
          other.opId == this.opId &&
          other.userId == this.userId &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.action == this.action &&
          other.baseRevision == this.baseRevision &&
          other.dependsOnOpId == this.dependsOnOpId &&
          other.payloadJson == this.payloadJson &&
          other.confirmationJson == this.confirmationJson &&
          other.requestHash == this.requestHash &&
          other.localVersion == this.localVersion &&
          other.state == this.state &&
          other.attempts == this.attempts &&
          other.nextAttemptAt == this.nextAttemptAt &&
          other.errorCode == this.errorCode &&
          other.createdAt == this.createdAt);
}

class OutboxOpsCompanion extends UpdateCompanion<OutboxRow> {
  final Value<int> ordinal;
  final Value<String> opId;
  final Value<String> userId;
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<String> action;
  final Value<int?> baseRevision;
  final Value<String?> dependsOnOpId;
  final Value<String?> payloadJson;
  final Value<String?> confirmationJson;
  final Value<String> requestHash;
  final Value<int> localVersion;
  final Value<String> state;
  final Value<int> attempts;
  final Value<int?> nextAttemptAt;
  final Value<String?> errorCode;
  final Value<int> createdAt;
  const OutboxOpsCompanion({
    this.ordinal = const Value.absent(),
    this.opId = const Value.absent(),
    this.userId = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.action = const Value.absent(),
    this.baseRevision = const Value.absent(),
    this.dependsOnOpId = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.confirmationJson = const Value.absent(),
    this.requestHash = const Value.absent(),
    this.localVersion = const Value.absent(),
    this.state = const Value.absent(),
    this.attempts = const Value.absent(),
    this.nextAttemptAt = const Value.absent(),
    this.errorCode = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  OutboxOpsCompanion.insert({
    this.ordinal = const Value.absent(),
    required String opId,
    required String userId,
    required String entityType,
    required String entityId,
    required String action,
    this.baseRevision = const Value.absent(),
    this.dependsOnOpId = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.confirmationJson = const Value.absent(),
    required String requestHash,
    required int localVersion,
    required String state,
    this.attempts = const Value.absent(),
    this.nextAttemptAt = const Value.absent(),
    this.errorCode = const Value.absent(),
    required int createdAt,
  }) : opId = Value(opId),
       userId = Value(userId),
       entityType = Value(entityType),
       entityId = Value(entityId),
       action = Value(action),
       requestHash = Value(requestHash),
       localVersion = Value(localVersion),
       state = Value(state),
       createdAt = Value(createdAt);
  static Insertable<OutboxRow> custom({
    Expression<int>? ordinal,
    Expression<String>? opId,
    Expression<String>? userId,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? action,
    Expression<int>? baseRevision,
    Expression<String>? dependsOnOpId,
    Expression<String>? payloadJson,
    Expression<String>? confirmationJson,
    Expression<String>? requestHash,
    Expression<int>? localVersion,
    Expression<String>? state,
    Expression<int>? attempts,
    Expression<int>? nextAttemptAt,
    Expression<String>? errorCode,
    Expression<int>? createdAt,
  }) {
    return RawValuesInsertable({
      if (ordinal != null) 'ordinal': ordinal,
      if (opId != null) 'op_id': opId,
      if (userId != null) 'user_id': userId,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (action != null) 'action': action,
      if (baseRevision != null) 'base_revision': baseRevision,
      if (dependsOnOpId != null) 'depends_on_op_id': dependsOnOpId,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (confirmationJson != null) 'confirmation_json': confirmationJson,
      if (requestHash != null) 'request_hash': requestHash,
      if (localVersion != null) 'local_version': localVersion,
      if (state != null) 'state': state,
      if (attempts != null) 'attempts': attempts,
      if (nextAttemptAt != null) 'next_attempt_at': nextAttemptAt,
      if (errorCode != null) 'error_code': errorCode,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  OutboxOpsCompanion copyWith({
    Value<int>? ordinal,
    Value<String>? opId,
    Value<String>? userId,
    Value<String>? entityType,
    Value<String>? entityId,
    Value<String>? action,
    Value<int?>? baseRevision,
    Value<String?>? dependsOnOpId,
    Value<String?>? payloadJson,
    Value<String?>? confirmationJson,
    Value<String>? requestHash,
    Value<int>? localVersion,
    Value<String>? state,
    Value<int>? attempts,
    Value<int?>? nextAttemptAt,
    Value<String?>? errorCode,
    Value<int>? createdAt,
  }) {
    return OutboxOpsCompanion(
      ordinal: ordinal ?? this.ordinal,
      opId: opId ?? this.opId,
      userId: userId ?? this.userId,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      action: action ?? this.action,
      baseRevision: baseRevision ?? this.baseRevision,
      dependsOnOpId: dependsOnOpId ?? this.dependsOnOpId,
      payloadJson: payloadJson ?? this.payloadJson,
      confirmationJson: confirmationJson ?? this.confirmationJson,
      requestHash: requestHash ?? this.requestHash,
      localVersion: localVersion ?? this.localVersion,
      state: state ?? this.state,
      attempts: attempts ?? this.attempts,
      nextAttemptAt: nextAttemptAt ?? this.nextAttemptAt,
      errorCode: errorCode ?? this.errorCode,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (ordinal.present) {
      map['ordinal'] = Variable<int>(ordinal.value);
    }
    if (opId.present) {
      map['op_id'] = Variable<String>(opId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(action.value);
    }
    if (baseRevision.present) {
      map['base_revision'] = Variable<int>(baseRevision.value);
    }
    if (dependsOnOpId.present) {
      map['depends_on_op_id'] = Variable<String>(dependsOnOpId.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (confirmationJson.present) {
      map['confirmation_json'] = Variable<String>(confirmationJson.value);
    }
    if (requestHash.present) {
      map['request_hash'] = Variable<String>(requestHash.value);
    }
    if (localVersion.present) {
      map['local_version'] = Variable<int>(localVersion.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (nextAttemptAt.present) {
      map['next_attempt_at'] = Variable<int>(nextAttemptAt.value);
    }
    if (errorCode.present) {
      map['error_code'] = Variable<String>(errorCode.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OutboxOpsCompanion(')
          ..write('ordinal: $ordinal, ')
          ..write('opId: $opId, ')
          ..write('userId: $userId, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('action: $action, ')
          ..write('baseRevision: $baseRevision, ')
          ..write('dependsOnOpId: $dependsOnOpId, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('confirmationJson: $confirmationJson, ')
          ..write('requestHash: $requestHash, ')
          ..write('localVersion: $localVersion, ')
          ..write('state: $state, ')
          ..write('attempts: $attempts, ')
          ..write('nextAttemptAt: $nextAttemptAt, ')
          ..write('errorCode: $errorCode, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $RemoteShadowsTable extends RemoteShadows
    with TableInfo<$RemoteShadowsTable, ShadowRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RemoteShadowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _canonicalJsonMeta = const VerificationMeta(
    'canonicalJson',
  );
  @override
  late final GeneratedColumn<String> canonicalJson = GeneratedColumn<String>(
    'canonical_json',
    aliasedName,
    false,
    check: () => const CustomExpression<bool>('json_valid(canonical_json)'),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    userId,
    entityType,
    entityId,
    revision,
    canonicalJson,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'remote_shadows';
  @override
  VerificationContext validateIntegrity(
    Insertable<ShadowRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    } else if (isInserting) {
      context.missing(_revisionMeta);
    }
    if (data.containsKey('canonical_json')) {
      context.handle(
        _canonicalJsonMeta,
        canonicalJson.isAcceptableOrUnknown(
          data['canonical_json']!,
          _canonicalJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_canonicalJsonMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId, entityType, entityId};
  @override
  ShadowRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ShadowRow(
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      )!,
      canonicalJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}canonical_json'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $RemoteShadowsTable createAlias(String alias) {
    return $RemoteShadowsTable(attachedDatabase, alias);
  }
}

class ShadowRow extends DataClass implements Insertable<ShadowRow> {
  final String userId;
  final String entityType;
  final String entityId;
  final int revision;
  final String canonicalJson;
  final int? deletedAt;
  const ShadowRow({
    required this.userId,
    required this.entityType,
    required this.entityId,
    required this.revision,
    required this.canonicalJson,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<String>(userId);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    map['revision'] = Variable<int>(revision);
    map['canonical_json'] = Variable<String>(canonicalJson);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    return map;
  }

  RemoteShadowsCompanion toCompanion(bool nullToAbsent) {
    return RemoteShadowsCompanion(
      userId: Value(userId),
      entityType: Value(entityType),
      entityId: Value(entityId),
      revision: Value(revision),
      canonicalJson: Value(canonicalJson),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory ShadowRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ShadowRow(
      userId: serializer.fromJson<String>(json['userId']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      revision: serializer.fromJson<int>(json['revision']),
      canonicalJson: serializer.fromJson<String>(json['canonicalJson']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<String>(userId),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'revision': serializer.toJson<int>(revision),
      'canonicalJson': serializer.toJson<String>(canonicalJson),
      'deletedAt': serializer.toJson<int?>(deletedAt),
    };
  }

  ShadowRow copyWith({
    String? userId,
    String? entityType,
    String? entityId,
    int? revision,
    String? canonicalJson,
    Value<int?> deletedAt = const Value.absent(),
  }) => ShadowRow(
    userId: userId ?? this.userId,
    entityType: entityType ?? this.entityType,
    entityId: entityId ?? this.entityId,
    revision: revision ?? this.revision,
    canonicalJson: canonicalJson ?? this.canonicalJson,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  ShadowRow copyWithCompanion(RemoteShadowsCompanion data) {
    return ShadowRow(
      userId: data.userId.present ? data.userId.value : this.userId,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      revision: data.revision.present ? data.revision.value : this.revision,
      canonicalJson: data.canonicalJson.present
          ? data.canonicalJson.value
          : this.canonicalJson,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ShadowRow(')
          ..write('userId: $userId, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('revision: $revision, ')
          ..write('canonicalJson: $canonicalJson, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    userId,
    entityType,
    entityId,
    revision,
    canonicalJson,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ShadowRow &&
          other.userId == this.userId &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.revision == this.revision &&
          other.canonicalJson == this.canonicalJson &&
          other.deletedAt == this.deletedAt);
}

class RemoteShadowsCompanion extends UpdateCompanion<ShadowRow> {
  final Value<String> userId;
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<int> revision;
  final Value<String> canonicalJson;
  final Value<int?> deletedAt;
  final Value<int> rowid;
  const RemoteShadowsCompanion({
    this.userId = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.revision = const Value.absent(),
    this.canonicalJson = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RemoteShadowsCompanion.insert({
    required String userId,
    required String entityType,
    required String entityId,
    required int revision,
    required String canonicalJson,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : userId = Value(userId),
       entityType = Value(entityType),
       entityId = Value(entityId),
       revision = Value(revision),
       canonicalJson = Value(canonicalJson);
  static Insertable<ShadowRow> custom({
    Expression<String>? userId,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<int>? revision,
    Expression<String>? canonicalJson,
    Expression<int>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (revision != null) 'revision': revision,
      if (canonicalJson != null) 'canonical_json': canonicalJson,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RemoteShadowsCompanion copyWith({
    Value<String>? userId,
    Value<String>? entityType,
    Value<String>? entityId,
    Value<int>? revision,
    Value<String>? canonicalJson,
    Value<int?>? deletedAt,
    Value<int>? rowid,
  }) {
    return RemoteShadowsCompanion(
      userId: userId ?? this.userId,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      revision: revision ?? this.revision,
      canonicalJson: canonicalJson ?? this.canonicalJson,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (canonicalJson.present) {
      map['canonical_json'] = Variable<String>(canonicalJson.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RemoteShadowsCompanion(')
          ..write('userId: $userId, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('revision: $revision, ')
          ..write('canonicalJson: $canonicalJson, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncCursorsTable extends SyncCursors
    with TableInfo<$SyncCursorsTable, CursorRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncCursorsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastAppliedSeqMeta = const VerificationMeta(
    'lastAppliedSeq',
  );
  @override
  late final GeneratedColumn<int> lastAppliedSeq = GeneratedColumn<int>(
    'last_applied_seq',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastLedgerSeqMeta = const VerificationMeta(
    'lastLedgerSeq',
  );
  @override
  late final GeneratedColumn<int> lastLedgerSeq = GeneratedColumn<int>(
    'last_ledger_seq',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _pageWatermarkMeta = const VerificationMeta(
    'pageWatermark',
  );
  @override
  late final GeneratedColumn<int> pageWatermark = GeneratedColumn<int>(
    'page_watermark',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _protocolVersionMeta = const VerificationMeta(
    'protocolVersion',
  );
  @override
  late final GeneratedColumn<int> protocolVersion = GeneratedColumn<int>(
    'protocol_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _lastSyncedAtMeta = const VerificationMeta(
    'lastSyncedAt',
  );
  @override
  late final GeneratedColumn<int> lastSyncedAt = GeneratedColumn<int>(
    'last_synced_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pausedReasonMeta = const VerificationMeta(
    'pausedReason',
  );
  @override
  late final GeneratedColumn<String> pausedReason = GeneratedColumn<String>(
    'paused_reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    userId,
    lastAppliedSeq,
    lastLedgerSeq,
    pageWatermark,
    protocolVersion,
    lastSyncedAt,
    pausedReason,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_cursors';
  @override
  VerificationContext validateIntegrity(
    Insertable<CursorRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('last_applied_seq')) {
      context.handle(
        _lastAppliedSeqMeta,
        lastAppliedSeq.isAcceptableOrUnknown(
          data['last_applied_seq']!,
          _lastAppliedSeqMeta,
        ),
      );
    }
    if (data.containsKey('last_ledger_seq')) {
      context.handle(
        _lastLedgerSeqMeta,
        lastLedgerSeq.isAcceptableOrUnknown(
          data['last_ledger_seq']!,
          _lastLedgerSeqMeta,
        ),
      );
    }
    if (data.containsKey('page_watermark')) {
      context.handle(
        _pageWatermarkMeta,
        pageWatermark.isAcceptableOrUnknown(
          data['page_watermark']!,
          _pageWatermarkMeta,
        ),
      );
    }
    if (data.containsKey('protocol_version')) {
      context.handle(
        _protocolVersionMeta,
        protocolVersion.isAcceptableOrUnknown(
          data['protocol_version']!,
          _protocolVersionMeta,
        ),
      );
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
        _lastSyncedAtMeta,
        lastSyncedAt.isAcceptableOrUnknown(
          data['last_synced_at']!,
          _lastSyncedAtMeta,
        ),
      );
    }
    if (data.containsKey('paused_reason')) {
      context.handle(
        _pausedReasonMeta,
        pausedReason.isAcceptableOrUnknown(
          data['paused_reason']!,
          _pausedReasonMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId};
  @override
  CursorRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CursorRow(
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      lastAppliedSeq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_applied_seq'],
      )!,
      lastLedgerSeq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_ledger_seq'],
      )!,
      pageWatermark: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}page_watermark'],
      ),
      protocolVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}protocol_version'],
      )!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_synced_at'],
      ),
      pausedReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}paused_reason'],
      ),
    );
  }

  @override
  $SyncCursorsTable createAlias(String alias) {
    return $SyncCursorsTable(attachedDatabase, alias);
  }
}

class CursorRow extends DataClass implements Insertable<CursorRow> {
  final String userId;
  final int lastAppliedSeq;
  final int lastLedgerSeq;
  final int? pageWatermark;
  final int protocolVersion;
  final int? lastSyncedAt;
  final String? pausedReason;
  const CursorRow({
    required this.userId,
    required this.lastAppliedSeq,
    required this.lastLedgerSeq,
    this.pageWatermark,
    required this.protocolVersion,
    this.lastSyncedAt,
    this.pausedReason,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<String>(userId);
    map['last_applied_seq'] = Variable<int>(lastAppliedSeq);
    map['last_ledger_seq'] = Variable<int>(lastLedgerSeq);
    if (!nullToAbsent || pageWatermark != null) {
      map['page_watermark'] = Variable<int>(pageWatermark);
    }
    map['protocol_version'] = Variable<int>(protocolVersion);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<int>(lastSyncedAt);
    }
    if (!nullToAbsent || pausedReason != null) {
      map['paused_reason'] = Variable<String>(pausedReason);
    }
    return map;
  }

  SyncCursorsCompanion toCompanion(bool nullToAbsent) {
    return SyncCursorsCompanion(
      userId: Value(userId),
      lastAppliedSeq: Value(lastAppliedSeq),
      lastLedgerSeq: Value(lastLedgerSeq),
      pageWatermark: pageWatermark == null && nullToAbsent
          ? const Value.absent()
          : Value(pageWatermark),
      protocolVersion: Value(protocolVersion),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
      pausedReason: pausedReason == null && nullToAbsent
          ? const Value.absent()
          : Value(pausedReason),
    );
  }

  factory CursorRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CursorRow(
      userId: serializer.fromJson<String>(json['userId']),
      lastAppliedSeq: serializer.fromJson<int>(json['lastAppliedSeq']),
      lastLedgerSeq: serializer.fromJson<int>(json['lastLedgerSeq']),
      pageWatermark: serializer.fromJson<int?>(json['pageWatermark']),
      protocolVersion: serializer.fromJson<int>(json['protocolVersion']),
      lastSyncedAt: serializer.fromJson<int?>(json['lastSyncedAt']),
      pausedReason: serializer.fromJson<String?>(json['pausedReason']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<String>(userId),
      'lastAppliedSeq': serializer.toJson<int>(lastAppliedSeq),
      'lastLedgerSeq': serializer.toJson<int>(lastLedgerSeq),
      'pageWatermark': serializer.toJson<int?>(pageWatermark),
      'protocolVersion': serializer.toJson<int>(protocolVersion),
      'lastSyncedAt': serializer.toJson<int?>(lastSyncedAt),
      'pausedReason': serializer.toJson<String?>(pausedReason),
    };
  }

  CursorRow copyWith({
    String? userId,
    int? lastAppliedSeq,
    int? lastLedgerSeq,
    Value<int?> pageWatermark = const Value.absent(),
    int? protocolVersion,
    Value<int?> lastSyncedAt = const Value.absent(),
    Value<String?> pausedReason = const Value.absent(),
  }) => CursorRow(
    userId: userId ?? this.userId,
    lastAppliedSeq: lastAppliedSeq ?? this.lastAppliedSeq,
    lastLedgerSeq: lastLedgerSeq ?? this.lastLedgerSeq,
    pageWatermark: pageWatermark.present
        ? pageWatermark.value
        : this.pageWatermark,
    protocolVersion: protocolVersion ?? this.protocolVersion,
    lastSyncedAt: lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
    pausedReason: pausedReason.present ? pausedReason.value : this.pausedReason,
  );
  CursorRow copyWithCompanion(SyncCursorsCompanion data) {
    return CursorRow(
      userId: data.userId.present ? data.userId.value : this.userId,
      lastAppliedSeq: data.lastAppliedSeq.present
          ? data.lastAppliedSeq.value
          : this.lastAppliedSeq,
      lastLedgerSeq: data.lastLedgerSeq.present
          ? data.lastLedgerSeq.value
          : this.lastLedgerSeq,
      pageWatermark: data.pageWatermark.present
          ? data.pageWatermark.value
          : this.pageWatermark,
      protocolVersion: data.protocolVersion.present
          ? data.protocolVersion.value
          : this.protocolVersion,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
      pausedReason: data.pausedReason.present
          ? data.pausedReason.value
          : this.pausedReason,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CursorRow(')
          ..write('userId: $userId, ')
          ..write('lastAppliedSeq: $lastAppliedSeq, ')
          ..write('lastLedgerSeq: $lastLedgerSeq, ')
          ..write('pageWatermark: $pageWatermark, ')
          ..write('protocolVersion: $protocolVersion, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('pausedReason: $pausedReason')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    userId,
    lastAppliedSeq,
    lastLedgerSeq,
    pageWatermark,
    protocolVersion,
    lastSyncedAt,
    pausedReason,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CursorRow &&
          other.userId == this.userId &&
          other.lastAppliedSeq == this.lastAppliedSeq &&
          other.lastLedgerSeq == this.lastLedgerSeq &&
          other.pageWatermark == this.pageWatermark &&
          other.protocolVersion == this.protocolVersion &&
          other.lastSyncedAt == this.lastSyncedAt &&
          other.pausedReason == this.pausedReason);
}

class SyncCursorsCompanion extends UpdateCompanion<CursorRow> {
  final Value<String> userId;
  final Value<int> lastAppliedSeq;
  final Value<int> lastLedgerSeq;
  final Value<int?> pageWatermark;
  final Value<int> protocolVersion;
  final Value<int?> lastSyncedAt;
  final Value<String?> pausedReason;
  final Value<int> rowid;
  const SyncCursorsCompanion({
    this.userId = const Value.absent(),
    this.lastAppliedSeq = const Value.absent(),
    this.lastLedgerSeq = const Value.absent(),
    this.pageWatermark = const Value.absent(),
    this.protocolVersion = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.pausedReason = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncCursorsCompanion.insert({
    required String userId,
    this.lastAppliedSeq = const Value.absent(),
    this.lastLedgerSeq = const Value.absent(),
    this.pageWatermark = const Value.absent(),
    this.protocolVersion = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.pausedReason = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : userId = Value(userId);
  static Insertable<CursorRow> custom({
    Expression<String>? userId,
    Expression<int>? lastAppliedSeq,
    Expression<int>? lastLedgerSeq,
    Expression<int>? pageWatermark,
    Expression<int>? protocolVersion,
    Expression<int>? lastSyncedAt,
    Expression<String>? pausedReason,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (lastAppliedSeq != null) 'last_applied_seq': lastAppliedSeq,
      if (lastLedgerSeq != null) 'last_ledger_seq': lastLedgerSeq,
      if (pageWatermark != null) 'page_watermark': pageWatermark,
      if (protocolVersion != null) 'protocol_version': protocolVersion,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (pausedReason != null) 'paused_reason': pausedReason,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncCursorsCompanion copyWith({
    Value<String>? userId,
    Value<int>? lastAppliedSeq,
    Value<int>? lastLedgerSeq,
    Value<int?>? pageWatermark,
    Value<int>? protocolVersion,
    Value<int?>? lastSyncedAt,
    Value<String?>? pausedReason,
    Value<int>? rowid,
  }) {
    return SyncCursorsCompanion(
      userId: userId ?? this.userId,
      lastAppliedSeq: lastAppliedSeq ?? this.lastAppliedSeq,
      lastLedgerSeq: lastLedgerSeq ?? this.lastLedgerSeq,
      pageWatermark: pageWatermark ?? this.pageWatermark,
      protocolVersion: protocolVersion ?? this.protocolVersion,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      pausedReason: pausedReason ?? this.pausedReason,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (lastAppliedSeq.present) {
      map['last_applied_seq'] = Variable<int>(lastAppliedSeq.value);
    }
    if (lastLedgerSeq.present) {
      map['last_ledger_seq'] = Variable<int>(lastLedgerSeq.value);
    }
    if (pageWatermark.present) {
      map['page_watermark'] = Variable<int>(pageWatermark.value);
    }
    if (protocolVersion.present) {
      map['protocol_version'] = Variable<int>(protocolVersion.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<int>(lastSyncedAt.value);
    }
    if (pausedReason.present) {
      map['paused_reason'] = Variable<String>(pausedReason.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncCursorsCompanion(')
          ..write('userId: $userId, ')
          ..write('lastAppliedSeq: $lastAppliedSeq, ')
          ..write('lastLedgerSeq: $lastLedgerSeq, ')
          ..write('pageWatermark: $pageWatermark, ')
          ..write('protocolVersion: $protocolVersion, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('pausedReason: $pausedReason, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncConflictsTable extends SyncConflicts
    with TableInfo<$SyncConflictsTable, ConflictRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncConflictsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _opIdMeta = const VerificationMeta('opId');
  @override
  late final GeneratedColumn<String> opId = GeneratedColumn<String>(
    'op_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _baseJsonMeta = const VerificationMeta(
    'baseJson',
  );
  @override
  late final GeneratedColumn<String> baseJson = GeneratedColumn<String>(
    'base_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _proposedJsonMeta = const VerificationMeta(
    'proposedJson',
  );
  @override
  late final GeneratedColumn<String> proposedJson = GeneratedColumn<String>(
    'proposed_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _serverJsonMeta = const VerificationMeta(
    'serverJson',
  );
  @override
  late final GeneratedColumn<String> serverJson = GeneratedColumn<String>(
    'server_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _serverRevisionMeta = const VerificationMeta(
    'serverRevision',
  );
  @override
  late final GeneratedColumn<int> serverRevision = GeneratedColumn<int>(
    'server_revision',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _detectedAtMeta = const VerificationMeta(
    'detectedAt',
  );
  @override
  late final GeneratedColumn<int> detectedAt = GeneratedColumn<int>(
    'detected_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _resolvedAtMeta = const VerificationMeta(
    'resolvedAt',
  );
  @override
  late final GeneratedColumn<int> resolvedAt = GeneratedColumn<int>(
    'resolved_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    opId,
    userId,
    entityType,
    entityId,
    baseJson,
    proposedJson,
    serverJson,
    serverRevision,
    detectedAt,
    resolvedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_conflicts';
  @override
  VerificationContext validateIntegrity(
    Insertable<ConflictRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('op_id')) {
      context.handle(
        _opIdMeta,
        opId.isAcceptableOrUnknown(data['op_id']!, _opIdMeta),
      );
    } else if (isInserting) {
      context.missing(_opIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('base_json')) {
      context.handle(
        _baseJsonMeta,
        baseJson.isAcceptableOrUnknown(data['base_json']!, _baseJsonMeta),
      );
    }
    if (data.containsKey('proposed_json')) {
      context.handle(
        _proposedJsonMeta,
        proposedJson.isAcceptableOrUnknown(
          data['proposed_json']!,
          _proposedJsonMeta,
        ),
      );
    }
    if (data.containsKey('server_json')) {
      context.handle(
        _serverJsonMeta,
        serverJson.isAcceptableOrUnknown(data['server_json']!, _serverJsonMeta),
      );
    }
    if (data.containsKey('server_revision')) {
      context.handle(
        _serverRevisionMeta,
        serverRevision.isAcceptableOrUnknown(
          data['server_revision']!,
          _serverRevisionMeta,
        ),
      );
    }
    if (data.containsKey('detected_at')) {
      context.handle(
        _detectedAtMeta,
        detectedAt.isAcceptableOrUnknown(data['detected_at']!, _detectedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_detectedAtMeta);
    }
    if (data.containsKey('resolved_at')) {
      context.handle(
        _resolvedAtMeta,
        resolvedAt.isAcceptableOrUnknown(data['resolved_at']!, _resolvedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {opId};
  @override
  ConflictRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ConflictRow(
      opId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}op_id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      baseJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}base_json'],
      ),
      proposedJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}proposed_json'],
      ),
      serverJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}server_json'],
      ),
      serverRevision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_revision'],
      ),
      detectedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}detected_at'],
      )!,
      resolvedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}resolved_at'],
      ),
    );
  }

  @override
  $SyncConflictsTable createAlias(String alias) {
    return $SyncConflictsTable(attachedDatabase, alias);
  }
}

class ConflictRow extends DataClass implements Insertable<ConflictRow> {
  final String opId;
  final String userId;
  final String entityType;
  final String entityId;
  final String? baseJson;
  final String? proposedJson;
  final String? serverJson;
  final int? serverRevision;
  final int detectedAt;
  final int? resolvedAt;
  const ConflictRow({
    required this.opId,
    required this.userId,
    required this.entityType,
    required this.entityId,
    this.baseJson,
    this.proposedJson,
    this.serverJson,
    this.serverRevision,
    required this.detectedAt,
    this.resolvedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['op_id'] = Variable<String>(opId);
    map['user_id'] = Variable<String>(userId);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    if (!nullToAbsent || baseJson != null) {
      map['base_json'] = Variable<String>(baseJson);
    }
    if (!nullToAbsent || proposedJson != null) {
      map['proposed_json'] = Variable<String>(proposedJson);
    }
    if (!nullToAbsent || serverJson != null) {
      map['server_json'] = Variable<String>(serverJson);
    }
    if (!nullToAbsent || serverRevision != null) {
      map['server_revision'] = Variable<int>(serverRevision);
    }
    map['detected_at'] = Variable<int>(detectedAt);
    if (!nullToAbsent || resolvedAt != null) {
      map['resolved_at'] = Variable<int>(resolvedAt);
    }
    return map;
  }

  SyncConflictsCompanion toCompanion(bool nullToAbsent) {
    return SyncConflictsCompanion(
      opId: Value(opId),
      userId: Value(userId),
      entityType: Value(entityType),
      entityId: Value(entityId),
      baseJson: baseJson == null && nullToAbsent
          ? const Value.absent()
          : Value(baseJson),
      proposedJson: proposedJson == null && nullToAbsent
          ? const Value.absent()
          : Value(proposedJson),
      serverJson: serverJson == null && nullToAbsent
          ? const Value.absent()
          : Value(serverJson),
      serverRevision: serverRevision == null && nullToAbsent
          ? const Value.absent()
          : Value(serverRevision),
      detectedAt: Value(detectedAt),
      resolvedAt: resolvedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(resolvedAt),
    );
  }

  factory ConflictRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ConflictRow(
      opId: serializer.fromJson<String>(json['opId']),
      userId: serializer.fromJson<String>(json['userId']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      baseJson: serializer.fromJson<String?>(json['baseJson']),
      proposedJson: serializer.fromJson<String?>(json['proposedJson']),
      serverJson: serializer.fromJson<String?>(json['serverJson']),
      serverRevision: serializer.fromJson<int?>(json['serverRevision']),
      detectedAt: serializer.fromJson<int>(json['detectedAt']),
      resolvedAt: serializer.fromJson<int?>(json['resolvedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'opId': serializer.toJson<String>(opId),
      'userId': serializer.toJson<String>(userId),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'baseJson': serializer.toJson<String?>(baseJson),
      'proposedJson': serializer.toJson<String?>(proposedJson),
      'serverJson': serializer.toJson<String?>(serverJson),
      'serverRevision': serializer.toJson<int?>(serverRevision),
      'detectedAt': serializer.toJson<int>(detectedAt),
      'resolvedAt': serializer.toJson<int?>(resolvedAt),
    };
  }

  ConflictRow copyWith({
    String? opId,
    String? userId,
    String? entityType,
    String? entityId,
    Value<String?> baseJson = const Value.absent(),
    Value<String?> proposedJson = const Value.absent(),
    Value<String?> serverJson = const Value.absent(),
    Value<int?> serverRevision = const Value.absent(),
    int? detectedAt,
    Value<int?> resolvedAt = const Value.absent(),
  }) => ConflictRow(
    opId: opId ?? this.opId,
    userId: userId ?? this.userId,
    entityType: entityType ?? this.entityType,
    entityId: entityId ?? this.entityId,
    baseJson: baseJson.present ? baseJson.value : this.baseJson,
    proposedJson: proposedJson.present ? proposedJson.value : this.proposedJson,
    serverJson: serverJson.present ? serverJson.value : this.serverJson,
    serverRevision: serverRevision.present
        ? serverRevision.value
        : this.serverRevision,
    detectedAt: detectedAt ?? this.detectedAt,
    resolvedAt: resolvedAt.present ? resolvedAt.value : this.resolvedAt,
  );
  ConflictRow copyWithCompanion(SyncConflictsCompanion data) {
    return ConflictRow(
      opId: data.opId.present ? data.opId.value : this.opId,
      userId: data.userId.present ? data.userId.value : this.userId,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      baseJson: data.baseJson.present ? data.baseJson.value : this.baseJson,
      proposedJson: data.proposedJson.present
          ? data.proposedJson.value
          : this.proposedJson,
      serverJson: data.serverJson.present
          ? data.serverJson.value
          : this.serverJson,
      serverRevision: data.serverRevision.present
          ? data.serverRevision.value
          : this.serverRevision,
      detectedAt: data.detectedAt.present
          ? data.detectedAt.value
          : this.detectedAt,
      resolvedAt: data.resolvedAt.present
          ? data.resolvedAt.value
          : this.resolvedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ConflictRow(')
          ..write('opId: $opId, ')
          ..write('userId: $userId, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('baseJson: $baseJson, ')
          ..write('proposedJson: $proposedJson, ')
          ..write('serverJson: $serverJson, ')
          ..write('serverRevision: $serverRevision, ')
          ..write('detectedAt: $detectedAt, ')
          ..write('resolvedAt: $resolvedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    opId,
    userId,
    entityType,
    entityId,
    baseJson,
    proposedJson,
    serverJson,
    serverRevision,
    detectedAt,
    resolvedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ConflictRow &&
          other.opId == this.opId &&
          other.userId == this.userId &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.baseJson == this.baseJson &&
          other.proposedJson == this.proposedJson &&
          other.serverJson == this.serverJson &&
          other.serverRevision == this.serverRevision &&
          other.detectedAt == this.detectedAt &&
          other.resolvedAt == this.resolvedAt);
}

class SyncConflictsCompanion extends UpdateCompanion<ConflictRow> {
  final Value<String> opId;
  final Value<String> userId;
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<String?> baseJson;
  final Value<String?> proposedJson;
  final Value<String?> serverJson;
  final Value<int?> serverRevision;
  final Value<int> detectedAt;
  final Value<int?> resolvedAt;
  final Value<int> rowid;
  const SyncConflictsCompanion({
    this.opId = const Value.absent(),
    this.userId = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.baseJson = const Value.absent(),
    this.proposedJson = const Value.absent(),
    this.serverJson = const Value.absent(),
    this.serverRevision = const Value.absent(),
    this.detectedAt = const Value.absent(),
    this.resolvedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncConflictsCompanion.insert({
    required String opId,
    required String userId,
    required String entityType,
    required String entityId,
    this.baseJson = const Value.absent(),
    this.proposedJson = const Value.absent(),
    this.serverJson = const Value.absent(),
    this.serverRevision = const Value.absent(),
    required int detectedAt,
    this.resolvedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : opId = Value(opId),
       userId = Value(userId),
       entityType = Value(entityType),
       entityId = Value(entityId),
       detectedAt = Value(detectedAt);
  static Insertable<ConflictRow> custom({
    Expression<String>? opId,
    Expression<String>? userId,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? baseJson,
    Expression<String>? proposedJson,
    Expression<String>? serverJson,
    Expression<int>? serverRevision,
    Expression<int>? detectedAt,
    Expression<int>? resolvedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (opId != null) 'op_id': opId,
      if (userId != null) 'user_id': userId,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (baseJson != null) 'base_json': baseJson,
      if (proposedJson != null) 'proposed_json': proposedJson,
      if (serverJson != null) 'server_json': serverJson,
      if (serverRevision != null) 'server_revision': serverRevision,
      if (detectedAt != null) 'detected_at': detectedAt,
      if (resolvedAt != null) 'resolved_at': resolvedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncConflictsCompanion copyWith({
    Value<String>? opId,
    Value<String>? userId,
    Value<String>? entityType,
    Value<String>? entityId,
    Value<String?>? baseJson,
    Value<String?>? proposedJson,
    Value<String?>? serverJson,
    Value<int?>? serverRevision,
    Value<int>? detectedAt,
    Value<int?>? resolvedAt,
    Value<int>? rowid,
  }) {
    return SyncConflictsCompanion(
      opId: opId ?? this.opId,
      userId: userId ?? this.userId,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      baseJson: baseJson ?? this.baseJson,
      proposedJson: proposedJson ?? this.proposedJson,
      serverJson: serverJson ?? this.serverJson,
      serverRevision: serverRevision ?? this.serverRevision,
      detectedAt: detectedAt ?? this.detectedAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (opId.present) {
      map['op_id'] = Variable<String>(opId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (baseJson.present) {
      map['base_json'] = Variable<String>(baseJson.value);
    }
    if (proposedJson.present) {
      map['proposed_json'] = Variable<String>(proposedJson.value);
    }
    if (serverJson.present) {
      map['server_json'] = Variable<String>(serverJson.value);
    }
    if (serverRevision.present) {
      map['server_revision'] = Variable<int>(serverRevision.value);
    }
    if (detectedAt.present) {
      map['detected_at'] = Variable<int>(detectedAt.value);
    }
    if (resolvedAt.present) {
      map['resolved_at'] = Variable<int>(resolvedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncConflictsCompanion(')
          ..write('opId: $opId, ')
          ..write('userId: $userId, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('baseJson: $baseJson, ')
          ..write('proposedJson: $proposedJson, ')
          ..write('serverJson: $serverJson, ')
          ..write('serverRevision: $serverRevision, ')
          ..write('detectedAt: $detectedAt, ')
          ..write('resolvedAt: $resolvedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DraftsTable extends Drafts with TableInfo<$DraftsTable, DraftRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DraftsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rawInputMeta = const VerificationMeta(
    'rawInput',
  );
  @override
  late final GeneratedColumn<String> rawInput = GeneratedColumn<String>(
    'raw_input',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _candidateJsonMeta = const VerificationMeta(
    'candidateJson',
  );
  @override
  late final GeneratedColumn<String> candidateJson = GeneratedColumn<String>(
    'candidate_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _expiresAtMeta = const VerificationMeta(
    'expiresAt',
  );
  @override
  late final GeneratedColumn<int> expiresAt = GeneratedColumn<int>(
    'expires_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    rawInput,
    candidateJson,
    createdAt,
    updatedAt,
    expiresAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'drafts';
  @override
  VerificationContext validateIntegrity(
    Insertable<DraftRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('raw_input')) {
      context.handle(
        _rawInputMeta,
        rawInput.isAcceptableOrUnknown(data['raw_input']!, _rawInputMeta),
      );
    } else if (isInserting) {
      context.missing(_rawInputMeta);
    }
    if (data.containsKey('candidate_json')) {
      context.handle(
        _candidateJsonMeta,
        candidateJson.isAcceptableOrUnknown(
          data['candidate_json']!,
          _candidateJsonMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('expires_at')) {
      context.handle(
        _expiresAtMeta,
        expiresAt.isAcceptableOrUnknown(data['expires_at']!, _expiresAtMeta),
      );
    } else if (isInserting) {
      context.missing(_expiresAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DraftRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DraftRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      rawInput: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw_input'],
      )!,
      candidateJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}candidate_json'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      expiresAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}expires_at'],
      )!,
    );
  }

  @override
  $DraftsTable createAlias(String alias) {
    return $DraftsTable(attachedDatabase, alias);
  }
}

class DraftRow extends DataClass implements Insertable<DraftRow> {
  final String id;
  final String userId;
  final String rawInput;
  final String? candidateJson;
  final int createdAt;
  final int updatedAt;
  final int expiresAt;
  const DraftRow({
    required this.id,
    required this.userId,
    required this.rawInput,
    this.candidateJson,
    required this.createdAt,
    required this.updatedAt,
    required this.expiresAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['raw_input'] = Variable<String>(rawInput);
    if (!nullToAbsent || candidateJson != null) {
      map['candidate_json'] = Variable<String>(candidateJson);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['expires_at'] = Variable<int>(expiresAt);
    return map;
  }

  DraftsCompanion toCompanion(bool nullToAbsent) {
    return DraftsCompanion(
      id: Value(id),
      userId: Value(userId),
      rawInput: Value(rawInput),
      candidateJson: candidateJson == null && nullToAbsent
          ? const Value.absent()
          : Value(candidateJson),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      expiresAt: Value(expiresAt),
    );
  }

  factory DraftRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DraftRow(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      rawInput: serializer.fromJson<String>(json['rawInput']),
      candidateJson: serializer.fromJson<String?>(json['candidateJson']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      expiresAt: serializer.fromJson<int>(json['expiresAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'rawInput': serializer.toJson<String>(rawInput),
      'candidateJson': serializer.toJson<String?>(candidateJson),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'expiresAt': serializer.toJson<int>(expiresAt),
    };
  }

  DraftRow copyWith({
    String? id,
    String? userId,
    String? rawInput,
    Value<String?> candidateJson = const Value.absent(),
    int? createdAt,
    int? updatedAt,
    int? expiresAt,
  }) => DraftRow(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    rawInput: rawInput ?? this.rawInput,
    candidateJson: candidateJson.present
        ? candidateJson.value
        : this.candidateJson,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    expiresAt: expiresAt ?? this.expiresAt,
  );
  DraftRow copyWithCompanion(DraftsCompanion data) {
    return DraftRow(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      rawInput: data.rawInput.present ? data.rawInput.value : this.rawInput,
      candidateJson: data.candidateJson.present
          ? data.candidateJson.value
          : this.candidateJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      expiresAt: data.expiresAt.present ? data.expiresAt.value : this.expiresAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DraftRow(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('rawInput: $rawInput, ')
          ..write('candidateJson: $candidateJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('expiresAt: $expiresAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    rawInput,
    candidateJson,
    createdAt,
    updatedAt,
    expiresAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DraftRow &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.rawInput == this.rawInput &&
          other.candidateJson == this.candidateJson &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.expiresAt == this.expiresAt);
}

class DraftsCompanion extends UpdateCompanion<DraftRow> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> rawInput;
  final Value<String?> candidateJson;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int> expiresAt;
  final Value<int> rowid;
  const DraftsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.rawInput = const Value.absent(),
    this.candidateJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.expiresAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DraftsCompanion.insert({
    required String id,
    required String userId,
    required String rawInput,
    this.candidateJson = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    required int expiresAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       rawInput = Value(rawInput),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       expiresAt = Value(expiresAt);
  static Insertable<DraftRow> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? rawInput,
    Expression<String>? candidateJson,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? expiresAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (rawInput != null) 'raw_input': rawInput,
      if (candidateJson != null) 'candidate_json': candidateJson,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (expiresAt != null) 'expires_at': expiresAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DraftsCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? rawInput,
    Value<String?>? candidateJson,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int>? expiresAt,
    Value<int>? rowid,
  }) {
    return DraftsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      rawInput: rawInput ?? this.rawInput,
      candidateJson: candidateJson ?? this.candidateJson,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (rawInput.present) {
      map['raw_input'] = Variable<String>(rawInput.value);
    }
    if (candidateJson.present) {
      map['candidate_json'] = Variable<String>(candidateJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (expiresAt.present) {
      map['expires_at'] = Variable<int>(expiresAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DraftsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('rawInput: $rawInput, ')
          ..write('candidateJson: $candidateJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ProfilesTable profiles = $ProfilesTable(this);
  late final $SettingsRecordsTable settingsRecords = $SettingsRecordsTable(
    this,
  );
  late final $AccountsTable accounts = $AccountsTable(this);
  late final $IncomeSourcesTable incomeSources = $IncomeSourcesTable(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $TransactionsTable transactions = $TransactionsTable(this);
  late final $CategorizationRulesTable categorizationRules =
      $CategorizationRulesTable(this);
  late final $BudgetsTable budgets = $BudgetsTable(this);
  late final $AiInsightsTable aiInsights = $AiInsightsTable(this);
  late final $AiProposalsTable aiProposals = $AiProposalsTable(this);
  late final $ReviewStatesTable reviewStates = $ReviewStatesTable(this);
  late final $AiActivitiesTable aiActivities = $AiActivitiesTable(this);
  late final $AgentRunsTable agentRuns = $AgentRunsTable(this);
  late final $OutboxOpsTable outboxOps = $OutboxOpsTable(this);
  late final $RemoteShadowsTable remoteShadows = $RemoteShadowsTable(this);
  late final $SyncCursorsTable syncCursors = $SyncCursorsTable(this);
  late final $SyncConflictsTable syncConflicts = $SyncConflictsTable(this);
  late final $DraftsTable drafts = $DraftsTable(this);
  late final Index txDateId = Index(
    'tx_date_id',
    'CREATE INDEX tx_date_id ON transactions (effective_date, id)',
  );
  late final Index txAccountDate = Index(
    'tx_account_date',
    'CREATE INDEX tx_account_date ON transactions (account_id, effective_date)',
  );
  late final Index txDestinationDate = Index(
    'tx_destination_date',
    'CREATE INDEX tx_destination_date ON transactions (destination_account_id, effective_date)',
  );
  late final Index txCategoryDate = Index(
    'tx_category_date',
    'CREATE INDEX tx_category_date ON transactions (category_id, effective_date)',
  );
  late final Index activityCreated = Index(
    'activity_created',
    'CREATE INDEX activity_created ON ai_activities (created_at, id)',
  );
  late final Index outboxStateNext = Index(
    'outbox_state_next',
    'CREATE INDEX outbox_state_next ON outbox_ops (state, next_attempt_at)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    profiles,
    settingsRecords,
    accounts,
    incomeSources,
    categories,
    transactions,
    categorizationRules,
    budgets,
    aiInsights,
    aiProposals,
    reviewStates,
    aiActivities,
    agentRuns,
    outboxOps,
    remoteShadows,
    syncCursors,
    syncConflicts,
    drafts,
    txDateId,
    txAccountDate,
    txDestinationDate,
    txCategoryDate,
    activityCreated,
    outboxStateNext,
  ];
}

typedef $$ProfilesTableCreateCompanionBuilder = ProfilesCompanion Function({
  required String userId,
  required String id,
  Value<int> revision,
  Value<int?> createdAt,
  Value<int?> serverUpdatedAt,
  Value<int?> deletedAt,
  Value<int> localVersion,
  Value<String> syncStatus,
  required int localCreatedAt,
  required int localUpdatedAt,
  required String displayName,
  required String baseCurrency,
  required int currencyExponent,
  required String timeZone,
  required bool onboardingComplete,
  Value<int> rowid,
});
typedef $$ProfilesTableUpdateCompanionBuilder = ProfilesCompanion Function({
  Value<String> userId,
  Value<String> id,
  Value<int> revision,
  Value<int?> createdAt,
  Value<int?> serverUpdatedAt,
  Value<int?> deletedAt,
  Value<int> localVersion,
  Value<String> syncStatus,
  Value<int> localCreatedAt,
  Value<int> localUpdatedAt,
  Value<String> displayName,
  Value<String> baseCurrency,
  Value<int> currencyExponent,
  Value<String> timeZone,
  Value<bool> onboardingComplete,
  Value<int> rowid,
});

class $$ProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get localVersion => $composableBuilder(
    column: $table.localVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get localCreatedAt => $composableBuilder(
    column: $table.localCreatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get baseCurrency => $composableBuilder(
    column: $table.baseCurrency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get currencyExponent => $composableBuilder(
    column: $table.currencyExponent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get timeZone => $composableBuilder(
    column: $table.timeZone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get onboardingComplete => $composableBuilder(
    column: $table.onboardingComplete,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get localVersion => $composableBuilder(
    column: $table.localVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get localCreatedAt => $composableBuilder(
    column: $table.localCreatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get baseCurrency => $composableBuilder(
    column: $table.baseCurrency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get currencyExponent => $composableBuilder(
    column: $table.currencyExponent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get timeZone => $composableBuilder(
    column: $table.timeZone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get onboardingComplete => $composableBuilder(
    column: $table.onboardingComplete,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get localVersion => $composableBuilder(
    column: $table.localVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<int> get localCreatedAt => $composableBuilder(
    column: $table.localCreatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get baseCurrency => $composableBuilder(
    column: $table.baseCurrency,
    builder: (column) => column,
  );

  GeneratedColumn<int> get currencyExponent => $composableBuilder(
    column: $table.currencyExponent,
    builder: (column) => column,
  );

  GeneratedColumn<String> get timeZone =>
      $composableBuilder(column: $table.timeZone, builder: (column) => column);

  GeneratedColumn<bool> get onboardingComplete => $composableBuilder(
    column: $table.onboardingComplete,
    builder: (column) => column,
  );
}

class $$ProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProfilesTable,
          ProfileRow,
          $$ProfilesTableFilterComposer,
          $$ProfilesTableOrderingComposer,
          $$ProfilesTableAnnotationComposer,
          $$ProfilesTableCreateCompanionBuilder,
          $$ProfilesTableUpdateCompanionBuilder,
          (
            ProfileRow,
            BaseReferences<_$AppDatabase, $ProfilesTable, ProfileRow>,
          ),
          ProfileRow,
          PrefetchHooks Function()
        > {
  $$ProfilesTableTableManager(_$AppDatabase db, $ProfilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> userId = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<int?> createdAt = const Value.absent(),
                Value<int?> serverUpdatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<int> localVersion = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> localCreatedAt = const Value.absent(),
                Value<int> localUpdatedAt = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<String> baseCurrency = const Value.absent(),
                Value<int> currencyExponent = const Value.absent(),
                Value<String> timeZone = const Value.absent(),
                Value<bool> onboardingComplete = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProfilesCompanion(
                userId: userId,
                id: id,
                revision: revision,
                createdAt: createdAt,
                serverUpdatedAt: serverUpdatedAt,
                deletedAt: deletedAt,
                localVersion: localVersion,
                syncStatus: syncStatus,
                localCreatedAt: localCreatedAt,
                localUpdatedAt: localUpdatedAt,
                displayName: displayName,
                baseCurrency: baseCurrency,
                currencyExponent: currencyExponent,
                timeZone: timeZone,
                onboardingComplete: onboardingComplete,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String userId,
                required String id,
                Value<int> revision = const Value.absent(),
                Value<int?> createdAt = const Value.absent(),
                Value<int?> serverUpdatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<int> localVersion = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                required int localCreatedAt,
                required int localUpdatedAt,
                required String displayName,
                required String baseCurrency,
                required int currencyExponent,
                required String timeZone,
                required bool onboardingComplete,
                Value<int> rowid = const Value.absent(),
              }) => ProfilesCompanion.insert(
                userId: userId,
                id: id,
                revision: revision,
                createdAt: createdAt,
                serverUpdatedAt: serverUpdatedAt,
                deletedAt: deletedAt,
                localVersion: localVersion,
                syncStatus: syncStatus,
                localCreatedAt: localCreatedAt,
                localUpdatedAt: localUpdatedAt,
                displayName: displayName,
                baseCurrency: baseCurrency,
                currencyExponent: currencyExponent,
                timeZone: timeZone,
                onboardingComplete: onboardingComplete,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ProfilesTable, ProfileRow>(table),
                  BaseReferences<_$AppDatabase, $ProfilesTable, ProfileRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProfilesTable,
      ProfileRow,
      $$ProfilesTableFilterComposer,
      $$ProfilesTableOrderingComposer,
      $$ProfilesTableAnnotationComposer,
      $$ProfilesTableCreateCompanionBuilder,
      $$ProfilesTableUpdateCompanionBuilder,
      (ProfileRow, BaseReferences<_$AppDatabase, $ProfilesTable, ProfileRow>),
      ProfileRow,
      PrefetchHooks Function()
    >;
typedef $$SettingsRecordsTableCreateCompanionBuilder =
    SettingsRecordsCompanion Function({
      required String userId,
      required String id,
      Value<int> revision,
      Value<int?> createdAt,
      Value<int?> serverUpdatedAt,
      Value<int?> deletedAt,
      Value<int> localVersion,
      Value<String> syncStatus,
      required int localCreatedAt,
      required int localUpdatedAt,
      required String theme,
      required bool aiEnabled,
      required bool dailyReviewEnabled,
      required bool learningEnabled,
      required bool fallbackEnabled,
      Value<String?> privacyPolicyVersion,
      Value<int?> providerConsentAt,
      Value<String?> defaultExpenseAccountId,
      Value<int> rowid,
    });
typedef $$SettingsRecordsTableUpdateCompanionBuilder =
    SettingsRecordsCompanion Function({
      Value<String> userId,
      Value<String> id,
      Value<int> revision,
      Value<int?> createdAt,
      Value<int?> serverUpdatedAt,
      Value<int?> deletedAt,
      Value<int> localVersion,
      Value<String> syncStatus,
      Value<int> localCreatedAt,
      Value<int> localUpdatedAt,
      Value<String> theme,
      Value<bool> aiEnabled,
      Value<bool> dailyReviewEnabled,
      Value<bool> learningEnabled,
      Value<bool> fallbackEnabled,
      Value<String?> privacyPolicyVersion,
      Value<int?> providerConsentAt,
      Value<String?> defaultExpenseAccountId,
      Value<int> rowid,
    });

class $$SettingsRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsRecordsTable> {
  $$SettingsRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get localVersion => $composableBuilder(
    column: $table.localVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get localCreatedAt => $composableBuilder(
    column: $table.localCreatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get theme => $composableBuilder(
    column: $table.theme,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get aiEnabled => $composableBuilder(
    column: $table.aiEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get dailyReviewEnabled => $composableBuilder(
    column: $table.dailyReviewEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get learningEnabled => $composableBuilder(
    column: $table.learningEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get fallbackEnabled => $composableBuilder(
    column: $table.fallbackEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get privacyPolicyVersion => $composableBuilder(
    column: $table.privacyPolicyVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get providerConsentAt => $composableBuilder(
    column: $table.providerConsentAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get defaultExpenseAccountId => $composableBuilder(
    column: $table.defaultExpenseAccountId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SettingsRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsRecordsTable> {
  $$SettingsRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get localVersion => $composableBuilder(
    column: $table.localVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get localCreatedAt => $composableBuilder(
    column: $table.localCreatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get theme => $composableBuilder(
    column: $table.theme,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get aiEnabled => $composableBuilder(
    column: $table.aiEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get dailyReviewEnabled => $composableBuilder(
    column: $table.dailyReviewEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get learningEnabled => $composableBuilder(
    column: $table.learningEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get fallbackEnabled => $composableBuilder(
    column: $table.fallbackEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get privacyPolicyVersion => $composableBuilder(
    column: $table.privacyPolicyVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get providerConsentAt => $composableBuilder(
    column: $table.providerConsentAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get defaultExpenseAccountId => $composableBuilder(
    column: $table.defaultExpenseAccountId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SettingsRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsRecordsTable> {
  $$SettingsRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get localVersion => $composableBuilder(
    column: $table.localVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<int> get localCreatedAt => $composableBuilder(
    column: $table.localCreatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get theme =>
      $composableBuilder(column: $table.theme, builder: (column) => column);

  GeneratedColumn<bool> get aiEnabled =>
      $composableBuilder(column: $table.aiEnabled, builder: (column) => column);

  GeneratedColumn<bool> get dailyReviewEnabled => $composableBuilder(
    column: $table.dailyReviewEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get learningEnabled => $composableBuilder(
    column: $table.learningEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get fallbackEnabled => $composableBuilder(
    column: $table.fallbackEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<String> get privacyPolicyVersion => $composableBuilder(
    column: $table.privacyPolicyVersion,
    builder: (column) => column,
  );

  GeneratedColumn<int> get providerConsentAt => $composableBuilder(
    column: $table.providerConsentAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get defaultExpenseAccountId => $composableBuilder(
    column: $table.defaultExpenseAccountId,
    builder: (column) => column,
  );
}

class $$SettingsRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SettingsRecordsTable,
          SettingsRow,
          $$SettingsRecordsTableFilterComposer,
          $$SettingsRecordsTableOrderingComposer,
          $$SettingsRecordsTableAnnotationComposer,
          $$SettingsRecordsTableCreateCompanionBuilder,
          $$SettingsRecordsTableUpdateCompanionBuilder,
          (
            SettingsRow,
            BaseReferences<_$AppDatabase, $SettingsRecordsTable, SettingsRow>,
          ),
          SettingsRow,
          PrefetchHooks Function()
        > {
  $$SettingsRecordsTableTableManager(
    _$AppDatabase db,
    $SettingsRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> userId = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<int?> createdAt = const Value.absent(),
                Value<int?> serverUpdatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<int> localVersion = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> localCreatedAt = const Value.absent(),
                Value<int> localUpdatedAt = const Value.absent(),
                Value<String> theme = const Value.absent(),
                Value<bool> aiEnabled = const Value.absent(),
                Value<bool> dailyReviewEnabled = const Value.absent(),
                Value<bool> learningEnabled = const Value.absent(),
                Value<bool> fallbackEnabled = const Value.absent(),
                Value<String?> privacyPolicyVersion = const Value.absent(),
                Value<int?> providerConsentAt = const Value.absent(),
                Value<String?> defaultExpenseAccountId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SettingsRecordsCompanion(
                userId: userId,
                id: id,
                revision: revision,
                createdAt: createdAt,
                serverUpdatedAt: serverUpdatedAt,
                deletedAt: deletedAt,
                localVersion: localVersion,
                syncStatus: syncStatus,
                localCreatedAt: localCreatedAt,
                localUpdatedAt: localUpdatedAt,
                theme: theme,
                aiEnabled: aiEnabled,
                dailyReviewEnabled: dailyReviewEnabled,
                learningEnabled: learningEnabled,
                fallbackEnabled: fallbackEnabled,
                privacyPolicyVersion: privacyPolicyVersion,
                providerConsentAt: providerConsentAt,
                defaultExpenseAccountId: defaultExpenseAccountId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String userId,
                required String id,
                Value<int> revision = const Value.absent(),
                Value<int?> createdAt = const Value.absent(),
                Value<int?> serverUpdatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<int> localVersion = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                required int localCreatedAt,
                required int localUpdatedAt,
                required String theme,
                required bool aiEnabled,
                required bool dailyReviewEnabled,
                required bool learningEnabled,
                required bool fallbackEnabled,
                Value<String?> privacyPolicyVersion = const Value.absent(),
                Value<int?> providerConsentAt = const Value.absent(),
                Value<String?> defaultExpenseAccountId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SettingsRecordsCompanion.insert(
                userId: userId,
                id: id,
                revision: revision,
                createdAt: createdAt,
                serverUpdatedAt: serverUpdatedAt,
                deletedAt: deletedAt,
                localVersion: localVersion,
                syncStatus: syncStatus,
                localCreatedAt: localCreatedAt,
                localUpdatedAt: localUpdatedAt,
                theme: theme,
                aiEnabled: aiEnabled,
                dailyReviewEnabled: dailyReviewEnabled,
                learningEnabled: learningEnabled,
                fallbackEnabled: fallbackEnabled,
                privacyPolicyVersion: privacyPolicyVersion,
                providerConsentAt: providerConsentAt,
                defaultExpenseAccountId: defaultExpenseAccountId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SettingsRecordsTable, SettingsRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $SettingsRecordsTable,
                    SettingsRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettingsRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SettingsRecordsTable,
      SettingsRow,
      $$SettingsRecordsTableFilterComposer,
      $$SettingsRecordsTableOrderingComposer,
      $$SettingsRecordsTableAnnotationComposer,
      $$SettingsRecordsTableCreateCompanionBuilder,
      $$SettingsRecordsTableUpdateCompanionBuilder,
      (
        SettingsRow,
        BaseReferences<_$AppDatabase, $SettingsRecordsTable, SettingsRow>,
      ),
      SettingsRow,
      PrefetchHooks Function()
    >;
typedef $$AccountsTableCreateCompanionBuilder = AccountsCompanion Function({
  required String userId,
  required String id,
  Value<int> revision,
  Value<int?> createdAt,
  Value<int?> serverUpdatedAt,
  Value<int?> deletedAt,
  Value<int> localVersion,
  Value<String> syncStatus,
  required int localCreatedAt,
  required int localUpdatedAt,
  required String name,
  required String type,
  required String currency,
  required bool archived,
  required int sortOrder,
  Value<int> rowid,
});
typedef $$AccountsTableUpdateCompanionBuilder = AccountsCompanion Function({
  Value<String> userId,
  Value<String> id,
  Value<int> revision,
  Value<int?> createdAt,
  Value<int?> serverUpdatedAt,
  Value<int?> deletedAt,
  Value<int> localVersion,
  Value<String> syncStatus,
  Value<int> localCreatedAt,
  Value<int> localUpdatedAt,
  Value<String> name,
  Value<String> type,
  Value<String> currency,
  Value<bool> archived,
  Value<int> sortOrder,
  Value<int> rowid,
});

class $$AccountsTableFilterComposer
    extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get localVersion => $composableBuilder(
    column: $table.localVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get localCreatedAt => $composableBuilder(
    column: $table.localCreatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AccountsTableOrderingComposer
    extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get localVersion => $composableBuilder(
    column: $table.localVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get localCreatedAt => $composableBuilder(
    column: $table.localCreatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AccountsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get localVersion => $composableBuilder(
    column: $table.localVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<int> get localCreatedAt => $composableBuilder(
    column: $table.localCreatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<bool> get archived =>
      $composableBuilder(column: $table.archived, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);
}

class $$AccountsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AccountsTable,
          AccountRow,
          $$AccountsTableFilterComposer,
          $$AccountsTableOrderingComposer,
          $$AccountsTableAnnotationComposer,
          $$AccountsTableCreateCompanionBuilder,
          $$AccountsTableUpdateCompanionBuilder,
          (
            AccountRow,
            BaseReferences<_$AppDatabase, $AccountsTable, AccountRow>,
          ),
          AccountRow,
          PrefetchHooks Function()
        > {
  $$AccountsTableTableManager(_$AppDatabase db, $AccountsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AccountsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AccountsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AccountsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> userId = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<int?> createdAt = const Value.absent(),
                Value<int?> serverUpdatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<int> localVersion = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> localCreatedAt = const Value.absent(),
                Value<int> localUpdatedAt = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<bool> archived = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AccountsCompanion(
                userId: userId,
                id: id,
                revision: revision,
                createdAt: createdAt,
                serverUpdatedAt: serverUpdatedAt,
                deletedAt: deletedAt,
                localVersion: localVersion,
                syncStatus: syncStatus,
                localCreatedAt: localCreatedAt,
                localUpdatedAt: localUpdatedAt,
                name: name,
                type: type,
                currency: currency,
                archived: archived,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String userId,
                required String id,
                Value<int> revision = const Value.absent(),
                Value<int?> createdAt = const Value.absent(),
                Value<int?> serverUpdatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<int> localVersion = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                required int localCreatedAt,
                required int localUpdatedAt,
                required String name,
                required String type,
                required String currency,
                required bool archived,
                required int sortOrder,
                Value<int> rowid = const Value.absent(),
              }) => AccountsCompanion.insert(
                userId: userId,
                id: id,
                revision: revision,
                createdAt: createdAt,
                serverUpdatedAt: serverUpdatedAt,
                deletedAt: deletedAt,
                localVersion: localVersion,
                syncStatus: syncStatus,
                localCreatedAt: localCreatedAt,
                localUpdatedAt: localUpdatedAt,
                name: name,
                type: type,
                currency: currency,
                archived: archived,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AccountsTable, AccountRow>(table),
                  BaseReferences<_$AppDatabase, $AccountsTable, AccountRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AccountsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AccountsTable,
      AccountRow,
      $$AccountsTableFilterComposer,
      $$AccountsTableOrderingComposer,
      $$AccountsTableAnnotationComposer,
      $$AccountsTableCreateCompanionBuilder,
      $$AccountsTableUpdateCompanionBuilder,
      (AccountRow, BaseReferences<_$AppDatabase, $AccountsTable, AccountRow>),
      AccountRow,
      PrefetchHooks Function()
    >;
typedef $$IncomeSourcesTableCreateCompanionBuilder =
    IncomeSourcesCompanion Function({
      required String userId,
      required String id,
      Value<int> revision,
      Value<int?> createdAt,
      Value<int?> serverUpdatedAt,
      Value<int?> deletedAt,
      Value<int> localVersion,
      Value<String> syncStatus,
      required int localCreatedAt,
      required int localUpdatedAt,
      required String name,
      required String type,
      Value<String?> defaultAccountId,
      required bool archived,
      Value<int> rowid,
    });
typedef $$IncomeSourcesTableUpdateCompanionBuilder =
    IncomeSourcesCompanion Function({
      Value<String> userId,
      Value<String> id,
      Value<int> revision,
      Value<int?> createdAt,
      Value<int?> serverUpdatedAt,
      Value<int?> deletedAt,
      Value<int> localVersion,
      Value<String> syncStatus,
      Value<int> localCreatedAt,
      Value<int> localUpdatedAt,
      Value<String> name,
      Value<String> type,
      Value<String?> defaultAccountId,
      Value<bool> archived,
      Value<int> rowid,
    });

class $$IncomeSourcesTableFilterComposer
    extends Composer<_$AppDatabase, $IncomeSourcesTable> {
  $$IncomeSourcesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get localVersion => $composableBuilder(
    column: $table.localVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get localCreatedAt => $composableBuilder(
    column: $table.localCreatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get defaultAccountId => $composableBuilder(
    column: $table.defaultAccountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnFilters(column),
  );
}

class $$IncomeSourcesTableOrderingComposer
    extends Composer<_$AppDatabase, $IncomeSourcesTable> {
  $$IncomeSourcesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get localVersion => $composableBuilder(
    column: $table.localVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get localCreatedAt => $composableBuilder(
    column: $table.localCreatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get defaultAccountId => $composableBuilder(
    column: $table.defaultAccountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$IncomeSourcesTableAnnotationComposer
    extends Composer<_$AppDatabase, $IncomeSourcesTable> {
  $$IncomeSourcesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get localVersion => $composableBuilder(
    column: $table.localVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<int> get localCreatedAt => $composableBuilder(
    column: $table.localCreatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get defaultAccountId => $composableBuilder(
    column: $table.defaultAccountId,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get archived =>
      $composableBuilder(column: $table.archived, builder: (column) => column);
}

class $$IncomeSourcesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $IncomeSourcesTable,
          IncomeSourceRow,
          $$IncomeSourcesTableFilterComposer,
          $$IncomeSourcesTableOrderingComposer,
          $$IncomeSourcesTableAnnotationComposer,
          $$IncomeSourcesTableCreateCompanionBuilder,
          $$IncomeSourcesTableUpdateCompanionBuilder,
          (
            IncomeSourceRow,
            BaseReferences<_$AppDatabase, $IncomeSourcesTable, IncomeSourceRow>,
          ),
          IncomeSourceRow,
          PrefetchHooks Function()
        > {
  $$IncomeSourcesTableTableManager(_$AppDatabase db, $IncomeSourcesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$IncomeSourcesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$IncomeSourcesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$IncomeSourcesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> userId = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<int?> createdAt = const Value.absent(),
                Value<int?> serverUpdatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<int> localVersion = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> localCreatedAt = const Value.absent(),
                Value<int> localUpdatedAt = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String?> defaultAccountId = const Value.absent(),
                Value<bool> archived = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => IncomeSourcesCompanion(
                userId: userId,
                id: id,
                revision: revision,
                createdAt: createdAt,
                serverUpdatedAt: serverUpdatedAt,
                deletedAt: deletedAt,
                localVersion: localVersion,
                syncStatus: syncStatus,
                localCreatedAt: localCreatedAt,
                localUpdatedAt: localUpdatedAt,
                name: name,
                type: type,
                defaultAccountId: defaultAccountId,
                archived: archived,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String userId,
                required String id,
                Value<int> revision = const Value.absent(),
                Value<int?> createdAt = const Value.absent(),
                Value<int?> serverUpdatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<int> localVersion = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                required int localCreatedAt,
                required int localUpdatedAt,
                required String name,
                required String type,
                Value<String?> defaultAccountId = const Value.absent(),
                required bool archived,
                Value<int> rowid = const Value.absent(),
              }) => IncomeSourcesCompanion.insert(
                userId: userId,
                id: id,
                revision: revision,
                createdAt: createdAt,
                serverUpdatedAt: serverUpdatedAt,
                deletedAt: deletedAt,
                localVersion: localVersion,
                syncStatus: syncStatus,
                localCreatedAt: localCreatedAt,
                localUpdatedAt: localUpdatedAt,
                name: name,
                type: type,
                defaultAccountId: defaultAccountId,
                archived: archived,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$IncomeSourcesTable, IncomeSourceRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $IncomeSourcesTable,
                    IncomeSourceRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$IncomeSourcesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $IncomeSourcesTable,
      IncomeSourceRow,
      $$IncomeSourcesTableFilterComposer,
      $$IncomeSourcesTableOrderingComposer,
      $$IncomeSourcesTableAnnotationComposer,
      $$IncomeSourcesTableCreateCompanionBuilder,
      $$IncomeSourcesTableUpdateCompanionBuilder,
      (
        IncomeSourceRow,
        BaseReferences<_$AppDatabase, $IncomeSourcesTable, IncomeSourceRow>,
      ),
      IncomeSourceRow,
      PrefetchHooks Function()
    >;
typedef $$CategoriesTableCreateCompanionBuilder = CategoriesCompanion Function({
  required String userId,
  required String id,
  Value<int> revision,
  Value<int?> createdAt,
  Value<int?> serverUpdatedAt,
  Value<int?> deletedAt,
  Value<int> localVersion,
  Value<String> syncStatus,
  required int localCreatedAt,
  required int localUpdatedAt,
  required String name,
  required String type,
  Value<String?> parentId,
  Value<String?> icon,
  required int sortOrder,
  required bool isSystem,
  required bool archived,
  Value<int> rowid,
});
typedef $$CategoriesTableUpdateCompanionBuilder = CategoriesCompanion Function({
  Value<String> userId,
  Value<String> id,
  Value<int> revision,
  Value<int?> createdAt,
  Value<int?> serverUpdatedAt,
  Value<int?> deletedAt,
  Value<int> localVersion,
  Value<String> syncStatus,
  Value<int> localCreatedAt,
  Value<int> localUpdatedAt,
  Value<String> name,
  Value<String> type,
  Value<String?> parentId,
  Value<String?> icon,
  Value<int> sortOrder,
  Value<bool> isSystem,
  Value<bool> archived,
  Value<int> rowid,
});

class $$CategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get localVersion => $composableBuilder(
    column: $table.localVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get localCreatedAt => $composableBuilder(
    column: $table.localCreatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get parentId => $composableBuilder(
    column: $table.parentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSystem => $composableBuilder(
    column: $table.isSystem,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get localVersion => $composableBuilder(
    column: $table.localVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get localCreatedAt => $composableBuilder(
    column: $table.localCreatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parentId => $composableBuilder(
    column: $table.parentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSystem => $composableBuilder(
    column: $table.isSystem,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get localVersion => $composableBuilder(
    column: $table.localVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<int> get localCreatedAt => $composableBuilder(
    column: $table.localCreatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get parentId =>
      $composableBuilder(column: $table.parentId, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<bool> get isSystem =>
      $composableBuilder(column: $table.isSystem, builder: (column) => column);

  GeneratedColumn<bool> get archived =>
      $composableBuilder(column: $table.archived, builder: (column) => column);
}

class $$CategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CategoriesTable,
          CategoryRow,
          $$CategoriesTableFilterComposer,
          $$CategoriesTableOrderingComposer,
          $$CategoriesTableAnnotationComposer,
          $$CategoriesTableCreateCompanionBuilder,
          $$CategoriesTableUpdateCompanionBuilder,
          (
            CategoryRow,
            BaseReferences<_$AppDatabase, $CategoriesTable, CategoryRow>,
          ),
          CategoryRow,
          PrefetchHooks Function()
        > {
  $$CategoriesTableTableManager(_$AppDatabase db, $CategoriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> userId = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<int?> createdAt = const Value.absent(),
                Value<int?> serverUpdatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<int> localVersion = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> localCreatedAt = const Value.absent(),
                Value<int> localUpdatedAt = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String?> parentId = const Value.absent(),
                Value<String?> icon = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<bool> isSystem = const Value.absent(),
                Value<bool> archived = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoriesCompanion(
                userId: userId,
                id: id,
                revision: revision,
                createdAt: createdAt,
                serverUpdatedAt: serverUpdatedAt,
                deletedAt: deletedAt,
                localVersion: localVersion,
                syncStatus: syncStatus,
                localCreatedAt: localCreatedAt,
                localUpdatedAt: localUpdatedAt,
                name: name,
                type: type,
                parentId: parentId,
                icon: icon,
                sortOrder: sortOrder,
                isSystem: isSystem,
                archived: archived,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String userId,
                required String id,
                Value<int> revision = const Value.absent(),
                Value<int?> createdAt = const Value.absent(),
                Value<int?> serverUpdatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<int> localVersion = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                required int localCreatedAt,
                required int localUpdatedAt,
                required String name,
                required String type,
                Value<String?> parentId = const Value.absent(),
                Value<String?> icon = const Value.absent(),
                required int sortOrder,
                required bool isSystem,
                required bool archived,
                Value<int> rowid = const Value.absent(),
              }) => CategoriesCompanion.insert(
                userId: userId,
                id: id,
                revision: revision,
                createdAt: createdAt,
                serverUpdatedAt: serverUpdatedAt,
                deletedAt: deletedAt,
                localVersion: localVersion,
                syncStatus: syncStatus,
                localCreatedAt: localCreatedAt,
                localUpdatedAt: localUpdatedAt,
                name: name,
                type: type,
                parentId: parentId,
                icon: icon,
                sortOrder: sortOrder,
                isSystem: isSystem,
                archived: archived,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CategoriesTable, CategoryRow>(table),
                  BaseReferences<_$AppDatabase, $CategoriesTable, CategoryRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CategoriesTable,
      CategoryRow,
      $$CategoriesTableFilterComposer,
      $$CategoriesTableOrderingComposer,
      $$CategoriesTableAnnotationComposer,
      $$CategoriesTableCreateCompanionBuilder,
      $$CategoriesTableUpdateCompanionBuilder,
      (
        CategoryRow,
        BaseReferences<_$AppDatabase, $CategoriesTable, CategoryRow>,
      ),
      CategoryRow,
      PrefetchHooks Function()
    >;
typedef $$TransactionsTableCreateCompanionBuilder =
    TransactionsCompanion Function({
      required String userId,
      required String id,
      Value<int> revision,
      Value<int?> createdAt,
      Value<int?> serverUpdatedAt,
      Value<int?> deletedAt,
      Value<int> localVersion,
      Value<String> syncStatus,
      required int localCreatedAt,
      required int localUpdatedAt,
      required String type,
      required int amountMinor,
      required String currency,
      required String accountId,
      Value<String?> destinationAccountId,
      Value<String?> incomeSourceId,
      Value<String?> categoryId,
      Value<String?> merchant,
      required String description,
      required int occurredAt,
      required String effectiveDate,
      required String entryTimeZone,
      required String origin,
      Value<String?> categorizationSource,
      Value<String?> proposalId,
      Value<String?> openingDirection,
      Value<int> rowid,
    });
typedef $$TransactionsTableUpdateCompanionBuilder =
    TransactionsCompanion Function({
      Value<String> userId,
      Value<String> id,
      Value<int> revision,
      Value<int?> createdAt,
      Value<int?> serverUpdatedAt,
      Value<int?> deletedAt,
      Value<int> localVersion,
      Value<String> syncStatus,
      Value<int> localCreatedAt,
      Value<int> localUpdatedAt,
      Value<String> type,
      Value<int> amountMinor,
      Value<String> currency,
      Value<String> accountId,
      Value<String?> destinationAccountId,
      Value<String?> incomeSourceId,
      Value<String?> categoryId,
      Value<String?> merchant,
      Value<String> description,
      Value<int> occurredAt,
      Value<String> effectiveDate,
      Value<String> entryTimeZone,
      Value<String> origin,
      Value<String?> categorizationSource,
      Value<String?> proposalId,
      Value<String?> openingDirection,
      Value<int> rowid,
    });

class $$TransactionsTableFilterComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get localVersion => $composableBuilder(
    column: $table.localVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get localCreatedAt => $composableBuilder(
    column: $table.localCreatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get destinationAccountId => $composableBuilder(
    column: $table.destinationAccountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get incomeSourceId => $composableBuilder(
    column: $table.incomeSourceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get merchant => $composableBuilder(
    column: $table.merchant,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get effectiveDate => $composableBuilder(
    column: $table.effectiveDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entryTimeZone => $composableBuilder(
    column: $table.entryTimeZone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get origin => $composableBuilder(
    column: $table.origin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categorizationSource => $composableBuilder(
    column: $table.categorizationSource,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get proposalId => $composableBuilder(
    column: $table.proposalId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get openingDirection => $composableBuilder(
    column: $table.openingDirection,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TransactionsTableOrderingComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get localVersion => $composableBuilder(
    column: $table.localVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get localCreatedAt => $composableBuilder(
    column: $table.localCreatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get destinationAccountId => $composableBuilder(
    column: $table.destinationAccountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get incomeSourceId => $composableBuilder(
    column: $table.incomeSourceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get merchant => $composableBuilder(
    column: $table.merchant,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get effectiveDate => $composableBuilder(
    column: $table.effectiveDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entryTimeZone => $composableBuilder(
    column: $table.entryTimeZone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get origin => $composableBuilder(
    column: $table.origin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categorizationSource => $composableBuilder(
    column: $table.categorizationSource,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get proposalId => $composableBuilder(
    column: $table.proposalId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get openingDirection => $composableBuilder(
    column: $table.openingDirection,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TransactionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get localVersion => $composableBuilder(
    column: $table.localVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<int> get localCreatedAt => $composableBuilder(
    column: $table.localCreatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<String> get accountId =>
      $composableBuilder(column: $table.accountId, builder: (column) => column);

  GeneratedColumn<String> get destinationAccountId => $composableBuilder(
    column: $table.destinationAccountId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get incomeSourceId => $composableBuilder(
    column: $table.incomeSourceId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get merchant =>
      $composableBuilder(column: $table.merchant, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<int> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get effectiveDate => $composableBuilder(
    column: $table.effectiveDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entryTimeZone => $composableBuilder(
    column: $table.entryTimeZone,
    builder: (column) => column,
  );

  GeneratedColumn<String> get origin =>
      $composableBuilder(column: $table.origin, builder: (column) => column);

  GeneratedColumn<String> get categorizationSource => $composableBuilder(
    column: $table.categorizationSource,
    builder: (column) => column,
  );

  GeneratedColumn<String> get proposalId => $composableBuilder(
    column: $table.proposalId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get openingDirection => $composableBuilder(
    column: $table.openingDirection,
    builder: (column) => column,
  );
}

class $$TransactionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TransactionsTable,
          TransactionRow,
          $$TransactionsTableFilterComposer,
          $$TransactionsTableOrderingComposer,
          $$TransactionsTableAnnotationComposer,
          $$TransactionsTableCreateCompanionBuilder,
          $$TransactionsTableUpdateCompanionBuilder,
          (
            TransactionRow,
            BaseReferences<_$AppDatabase, $TransactionsTable, TransactionRow>,
          ),
          TransactionRow,
          PrefetchHooks Function()
        > {
  $$TransactionsTableTableManager(_$AppDatabase db, $TransactionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransactionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransactionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransactionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> userId = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<int?> createdAt = const Value.absent(),
                Value<int?> serverUpdatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<int> localVersion = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> localCreatedAt = const Value.absent(),
                Value<int> localUpdatedAt = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<int> amountMinor = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<String> accountId = const Value.absent(),
                Value<String?> destinationAccountId = const Value.absent(),
                Value<String?> incomeSourceId = const Value.absent(),
                Value<String?> categoryId = const Value.absent(),
                Value<String?> merchant = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<int> occurredAt = const Value.absent(),
                Value<String> effectiveDate = const Value.absent(),
                Value<String> entryTimeZone = const Value.absent(),
                Value<String> origin = const Value.absent(),
                Value<String?> categorizationSource = const Value.absent(),
                Value<String?> proposalId = const Value.absent(),
                Value<String?> openingDirection = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransactionsCompanion(
                userId: userId,
                id: id,
                revision: revision,
                createdAt: createdAt,
                serverUpdatedAt: serverUpdatedAt,
                deletedAt: deletedAt,
                localVersion: localVersion,
                syncStatus: syncStatus,
                localCreatedAt: localCreatedAt,
                localUpdatedAt: localUpdatedAt,
                type: type,
                amountMinor: amountMinor,
                currency: currency,
                accountId: accountId,
                destinationAccountId: destinationAccountId,
                incomeSourceId: incomeSourceId,
                categoryId: categoryId,
                merchant: merchant,
                description: description,
                occurredAt: occurredAt,
                effectiveDate: effectiveDate,
                entryTimeZone: entryTimeZone,
                origin: origin,
                categorizationSource: categorizationSource,
                proposalId: proposalId,
                openingDirection: openingDirection,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String userId,
                required String id,
                Value<int> revision = const Value.absent(),
                Value<int?> createdAt = const Value.absent(),
                Value<int?> serverUpdatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<int> localVersion = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                required int localCreatedAt,
                required int localUpdatedAt,
                required String type,
                required int amountMinor,
                required String currency,
                required String accountId,
                Value<String?> destinationAccountId = const Value.absent(),
                Value<String?> incomeSourceId = const Value.absent(),
                Value<String?> categoryId = const Value.absent(),
                Value<String?> merchant = const Value.absent(),
                required String description,
                required int occurredAt,
                required String effectiveDate,
                required String entryTimeZone,
                required String origin,
                Value<String?> categorizationSource = const Value.absent(),
                Value<String?> proposalId = const Value.absent(),
                Value<String?> openingDirection = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransactionsCompanion.insert(
                userId: userId,
                id: id,
                revision: revision,
                createdAt: createdAt,
                serverUpdatedAt: serverUpdatedAt,
                deletedAt: deletedAt,
                localVersion: localVersion,
                syncStatus: syncStatus,
                localCreatedAt: localCreatedAt,
                localUpdatedAt: localUpdatedAt,
                type: type,
                amountMinor: amountMinor,
                currency: currency,
                accountId: accountId,
                destinationAccountId: destinationAccountId,
                incomeSourceId: incomeSourceId,
                categoryId: categoryId,
                merchant: merchant,
                description: description,
                occurredAt: occurredAt,
                effectiveDate: effectiveDate,
                entryTimeZone: entryTimeZone,
                origin: origin,
                categorizationSource: categorizationSource,
                proposalId: proposalId,
                openingDirection: openingDirection,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TransactionsTable, TransactionRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $TransactionsTable,
                    TransactionRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TransactionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TransactionsTable,
      TransactionRow,
      $$TransactionsTableFilterComposer,
      $$TransactionsTableOrderingComposer,
      $$TransactionsTableAnnotationComposer,
      $$TransactionsTableCreateCompanionBuilder,
      $$TransactionsTableUpdateCompanionBuilder,
      (
        TransactionRow,
        BaseReferences<_$AppDatabase, $TransactionsTable, TransactionRow>,
      ),
      TransactionRow,
      PrefetchHooks Function()
    >;
typedef $$CategorizationRulesTableCreateCompanionBuilder =
    CategorizationRulesCompanion Function({
      required String userId,
      required String id,
      Value<int> revision,
      Value<int?> createdAt,
      Value<int?> serverUpdatedAt,
      Value<int?> deletedAt,
      Value<int> localVersion,
      Value<String> syncStatus,
      required int localCreatedAt,
      required int localUpdatedAt,
      required String matchKind,
      required String normalizedPattern,
      required String transactionType,
      required String categoryId,
      Value<String?> suggestedAccountId,
      Value<String?> suggestedIncomeSourceId,
      required int priority,
      required bool enabled,
      required String origin,
      required String evidenceJson,
      Value<int> rowid,
    });
typedef $$CategorizationRulesTableUpdateCompanionBuilder =
    CategorizationRulesCompanion Function({
      Value<String> userId,
      Value<String> id,
      Value<int> revision,
      Value<int?> createdAt,
      Value<int?> serverUpdatedAt,
      Value<int?> deletedAt,
      Value<int> localVersion,
      Value<String> syncStatus,
      Value<int> localCreatedAt,
      Value<int> localUpdatedAt,
      Value<String> matchKind,
      Value<String> normalizedPattern,
      Value<String> transactionType,
      Value<String> categoryId,
      Value<String?> suggestedAccountId,
      Value<String?> suggestedIncomeSourceId,
      Value<int> priority,
      Value<bool> enabled,
      Value<String> origin,
      Value<String> evidenceJson,
      Value<int> rowid,
    });

class $$CategorizationRulesTableFilterComposer
    extends Composer<_$AppDatabase, $CategorizationRulesTable> {
  $$CategorizationRulesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get localVersion => $composableBuilder(
    column: $table.localVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get localCreatedAt => $composableBuilder(
    column: $table.localCreatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get matchKind => $composableBuilder(
    column: $table.matchKind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get normalizedPattern => $composableBuilder(
    column: $table.normalizedPattern,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get transactionType => $composableBuilder(
    column: $table.transactionType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get suggestedAccountId => $composableBuilder(
    column: $table.suggestedAccountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get suggestedIncomeSourceId => $composableBuilder(
    column: $table.suggestedIncomeSourceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get origin => $composableBuilder(
    column: $table.origin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get evidenceJson => $composableBuilder(
    column: $table.evidenceJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CategorizationRulesTableOrderingComposer
    extends Composer<_$AppDatabase, $CategorizationRulesTable> {
  $$CategorizationRulesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get localVersion => $composableBuilder(
    column: $table.localVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get localCreatedAt => $composableBuilder(
    column: $table.localCreatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get matchKind => $composableBuilder(
    column: $table.matchKind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get normalizedPattern => $composableBuilder(
    column: $table.normalizedPattern,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get transactionType => $composableBuilder(
    column: $table.transactionType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get suggestedAccountId => $composableBuilder(
    column: $table.suggestedAccountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get suggestedIncomeSourceId => $composableBuilder(
    column: $table.suggestedIncomeSourceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get origin => $composableBuilder(
    column: $table.origin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get evidenceJson => $composableBuilder(
    column: $table.evidenceJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CategorizationRulesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategorizationRulesTable> {
  $$CategorizationRulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get localVersion => $composableBuilder(
    column: $table.localVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<int> get localCreatedAt => $composableBuilder(
    column: $table.localCreatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get matchKind =>
      $composableBuilder(column: $table.matchKind, builder: (column) => column);

  GeneratedColumn<String> get normalizedPattern => $composableBuilder(
    column: $table.normalizedPattern,
    builder: (column) => column,
  );

  GeneratedColumn<String> get transactionType => $composableBuilder(
    column: $table.transactionType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get suggestedAccountId => $composableBuilder(
    column: $table.suggestedAccountId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get suggestedIncomeSourceId => $composableBuilder(
    column: $table.suggestedIncomeSourceId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<bool> get enabled =>
      $composableBuilder(column: $table.enabled, builder: (column) => column);

  GeneratedColumn<String> get origin =>
      $composableBuilder(column: $table.origin, builder: (column) => column);

  GeneratedColumn<String> get evidenceJson => $composableBuilder(
    column: $table.evidenceJson,
    builder: (column) => column,
  );
}

class $$CategorizationRulesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CategorizationRulesTable,
          RuleRow,
          $$CategorizationRulesTableFilterComposer,
          $$CategorizationRulesTableOrderingComposer,
          $$CategorizationRulesTableAnnotationComposer,
          $$CategorizationRulesTableCreateCompanionBuilder,
          $$CategorizationRulesTableUpdateCompanionBuilder,
          (
            RuleRow,
            BaseReferences<_$AppDatabase, $CategorizationRulesTable, RuleRow>,
          ),
          RuleRow,
          PrefetchHooks Function()
        > {
  $$CategorizationRulesTableTableManager(
    _$AppDatabase db,
    $CategorizationRulesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategorizationRulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategorizationRulesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$CategorizationRulesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> userId = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<int?> createdAt = const Value.absent(),
                Value<int?> serverUpdatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<int> localVersion = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> localCreatedAt = const Value.absent(),
                Value<int> localUpdatedAt = const Value.absent(),
                Value<String> matchKind = const Value.absent(),
                Value<String> normalizedPattern = const Value.absent(),
                Value<String> transactionType = const Value.absent(),
                Value<String> categoryId = const Value.absent(),
                Value<String?> suggestedAccountId = const Value.absent(),
                Value<String?> suggestedIncomeSourceId = const Value.absent(),
                Value<int> priority = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
                Value<String> origin = const Value.absent(),
                Value<String> evidenceJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategorizationRulesCompanion(
                userId: userId,
                id: id,
                revision: revision,
                createdAt: createdAt,
                serverUpdatedAt: serverUpdatedAt,
                deletedAt: deletedAt,
                localVersion: localVersion,
                syncStatus: syncStatus,
                localCreatedAt: localCreatedAt,
                localUpdatedAt: localUpdatedAt,
                matchKind: matchKind,
                normalizedPattern: normalizedPattern,
                transactionType: transactionType,
                categoryId: categoryId,
                suggestedAccountId: suggestedAccountId,
                suggestedIncomeSourceId: suggestedIncomeSourceId,
                priority: priority,
                enabled: enabled,
                origin: origin,
                evidenceJson: evidenceJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String userId,
                required String id,
                Value<int> revision = const Value.absent(),
                Value<int?> createdAt = const Value.absent(),
                Value<int?> serverUpdatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<int> localVersion = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                required int localCreatedAt,
                required int localUpdatedAt,
                required String matchKind,
                required String normalizedPattern,
                required String transactionType,
                required String categoryId,
                Value<String?> suggestedAccountId = const Value.absent(),
                Value<String?> suggestedIncomeSourceId = const Value.absent(),
                required int priority,
                required bool enabled,
                required String origin,
                required String evidenceJson,
                Value<int> rowid = const Value.absent(),
              }) => CategorizationRulesCompanion.insert(
                userId: userId,
                id: id,
                revision: revision,
                createdAt: createdAt,
                serverUpdatedAt: serverUpdatedAt,
                deletedAt: deletedAt,
                localVersion: localVersion,
                syncStatus: syncStatus,
                localCreatedAt: localCreatedAt,
                localUpdatedAt: localUpdatedAt,
                matchKind: matchKind,
                normalizedPattern: normalizedPattern,
                transactionType: transactionType,
                categoryId: categoryId,
                suggestedAccountId: suggestedAccountId,
                suggestedIncomeSourceId: suggestedIncomeSourceId,
                priority: priority,
                enabled: enabled,
                origin: origin,
                evidenceJson: evidenceJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CategorizationRulesTable, RuleRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $CategorizationRulesTable,
                    RuleRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CategorizationRulesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CategorizationRulesTable,
      RuleRow,
      $$CategorizationRulesTableFilterComposer,
      $$CategorizationRulesTableOrderingComposer,
      $$CategorizationRulesTableAnnotationComposer,
      $$CategorizationRulesTableCreateCompanionBuilder,
      $$CategorizationRulesTableUpdateCompanionBuilder,
      (
        RuleRow,
        BaseReferences<_$AppDatabase, $CategorizationRulesTable, RuleRow>,
      ),
      RuleRow,
      PrefetchHooks Function()
    >;
typedef $$BudgetsTableCreateCompanionBuilder = BudgetsCompanion Function({
  required String userId,
  required String id,
  Value<int> revision,
  Value<int?> createdAt,
  Value<int?> serverUpdatedAt,
  Value<int?> deletedAt,
  Value<int> localVersion,
  Value<String> syncStatus,
  required int localCreatedAt,
  required int localUpdatedAt,
  required String month,
  required String categoryId,
  required int limitMinor,
  required String currency,
  Value<int> rowid,
});
typedef $$BudgetsTableUpdateCompanionBuilder = BudgetsCompanion Function({
  Value<String> userId,
  Value<String> id,
  Value<int> revision,
  Value<int?> createdAt,
  Value<int?> serverUpdatedAt,
  Value<int?> deletedAt,
  Value<int> localVersion,
  Value<String> syncStatus,
  Value<int> localCreatedAt,
  Value<int> localUpdatedAt,
  Value<String> month,
  Value<String> categoryId,
  Value<int> limitMinor,
  Value<String> currency,
  Value<int> rowid,
});

class $$BudgetsTableFilterComposer
    extends Composer<_$AppDatabase, $BudgetsTable> {
  $$BudgetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get localVersion => $composableBuilder(
    column: $table.localVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get localCreatedAt => $composableBuilder(
    column: $table.localCreatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get month => $composableBuilder(
    column: $table.month,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get limitMinor => $composableBuilder(
    column: $table.limitMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BudgetsTableOrderingComposer
    extends Composer<_$AppDatabase, $BudgetsTable> {
  $$BudgetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get localVersion => $composableBuilder(
    column: $table.localVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get localCreatedAt => $composableBuilder(
    column: $table.localCreatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get month => $composableBuilder(
    column: $table.month,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get limitMinor => $composableBuilder(
    column: $table.limitMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BudgetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BudgetsTable> {
  $$BudgetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get localVersion => $composableBuilder(
    column: $table.localVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<int> get localCreatedAt => $composableBuilder(
    column: $table.localCreatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get month =>
      $composableBuilder(column: $table.month, builder: (column) => column);

  GeneratedColumn<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get limitMinor => $composableBuilder(
    column: $table.limitMinor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);
}

class $$BudgetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BudgetsTable,
          BudgetRow,
          $$BudgetsTableFilterComposer,
          $$BudgetsTableOrderingComposer,
          $$BudgetsTableAnnotationComposer,
          $$BudgetsTableCreateCompanionBuilder,
          $$BudgetsTableUpdateCompanionBuilder,
          (BudgetRow, BaseReferences<_$AppDatabase, $BudgetsTable, BudgetRow>),
          BudgetRow,
          PrefetchHooks Function()
        > {
  $$BudgetsTableTableManager(_$AppDatabase db, $BudgetsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BudgetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BudgetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BudgetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> userId = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<int?> createdAt = const Value.absent(),
                Value<int?> serverUpdatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<int> localVersion = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> localCreatedAt = const Value.absent(),
                Value<int> localUpdatedAt = const Value.absent(),
                Value<String> month = const Value.absent(),
                Value<String> categoryId = const Value.absent(),
                Value<int> limitMinor = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BudgetsCompanion(
                userId: userId,
                id: id,
                revision: revision,
                createdAt: createdAt,
                serverUpdatedAt: serverUpdatedAt,
                deletedAt: deletedAt,
                localVersion: localVersion,
                syncStatus: syncStatus,
                localCreatedAt: localCreatedAt,
                localUpdatedAt: localUpdatedAt,
                month: month,
                categoryId: categoryId,
                limitMinor: limitMinor,
                currency: currency,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String userId,
                required String id,
                Value<int> revision = const Value.absent(),
                Value<int?> createdAt = const Value.absent(),
                Value<int?> serverUpdatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<int> localVersion = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                required int localCreatedAt,
                required int localUpdatedAt,
                required String month,
                required String categoryId,
                required int limitMinor,
                required String currency,
                Value<int> rowid = const Value.absent(),
              }) => BudgetsCompanion.insert(
                userId: userId,
                id: id,
                revision: revision,
                createdAt: createdAt,
                serverUpdatedAt: serverUpdatedAt,
                deletedAt: deletedAt,
                localVersion: localVersion,
                syncStatus: syncStatus,
                localCreatedAt: localCreatedAt,
                localUpdatedAt: localUpdatedAt,
                month: month,
                categoryId: categoryId,
                limitMinor: limitMinor,
                currency: currency,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$BudgetsTable, BudgetRow>(table),
                  BaseReferences<_$AppDatabase, $BudgetsTable, BudgetRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BudgetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BudgetsTable,
      BudgetRow,
      $$BudgetsTableFilterComposer,
      $$BudgetsTableOrderingComposer,
      $$BudgetsTableAnnotationComposer,
      $$BudgetsTableCreateCompanionBuilder,
      $$BudgetsTableUpdateCompanionBuilder,
      (BudgetRow, BaseReferences<_$AppDatabase, $BudgetsTable, BudgetRow>),
      BudgetRow,
      PrefetchHooks Function()
    >;
typedef $$AiInsightsTableCreateCompanionBuilder = AiInsightsCompanion Function({
  required String userId,
  required String id,
  Value<int> revision,
  Value<int?> createdAt,
  Value<int?> serverUpdatedAt,
  Value<int?> deletedAt,
  Value<int> localVersion,
  Value<String> syncStatus,
  required int localCreatedAt,
  required int localUpdatedAt,
  required String kind,
  required String businessDate,
  required String status,
  required int sourceWatermark,
  required String recordJson,
  Value<int> rowid,
});
typedef $$AiInsightsTableUpdateCompanionBuilder = AiInsightsCompanion Function({
  Value<String> userId,
  Value<String> id,
  Value<int> revision,
  Value<int?> createdAt,
  Value<int?> serverUpdatedAt,
  Value<int?> deletedAt,
  Value<int> localVersion,
  Value<String> syncStatus,
  Value<int> localCreatedAt,
  Value<int> localUpdatedAt,
  Value<String> kind,
  Value<String> businessDate,
  Value<String> status,
  Value<int> sourceWatermark,
  Value<String> recordJson,
  Value<int> rowid,
});

class $$AiInsightsTableFilterComposer
    extends Composer<_$AppDatabase, $AiInsightsTable> {
  $$AiInsightsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get localVersion => $composableBuilder(
    column: $table.localVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get localCreatedAt => $composableBuilder(
    column: $table.localCreatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get businessDate => $composableBuilder(
    column: $table.businessDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sourceWatermark => $composableBuilder(
    column: $table.sourceWatermark,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recordJson => $composableBuilder(
    column: $table.recordJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AiInsightsTableOrderingComposer
    extends Composer<_$AppDatabase, $AiInsightsTable> {
  $$AiInsightsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get localVersion => $composableBuilder(
    column: $table.localVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get localCreatedAt => $composableBuilder(
    column: $table.localCreatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get businessDate => $composableBuilder(
    column: $table.businessDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sourceWatermark => $composableBuilder(
    column: $table.sourceWatermark,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recordJson => $composableBuilder(
    column: $table.recordJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AiInsightsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AiInsightsTable> {
  $$AiInsightsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get localVersion => $composableBuilder(
    column: $table.localVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<int> get localCreatedAt => $composableBuilder(
    column: $table.localCreatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get businessDate => $composableBuilder(
    column: $table.businessDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get sourceWatermark => $composableBuilder(
    column: $table.sourceWatermark,
    builder: (column) => column,
  );

  GeneratedColumn<String> get recordJson => $composableBuilder(
    column: $table.recordJson,
    builder: (column) => column,
  );
}

class $$AiInsightsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AiInsightsTable,
          InsightRow,
          $$AiInsightsTableFilterComposer,
          $$AiInsightsTableOrderingComposer,
          $$AiInsightsTableAnnotationComposer,
          $$AiInsightsTableCreateCompanionBuilder,
          $$AiInsightsTableUpdateCompanionBuilder,
          (
            InsightRow,
            BaseReferences<_$AppDatabase, $AiInsightsTable, InsightRow>,
          ),
          InsightRow,
          PrefetchHooks Function()
        > {
  $$AiInsightsTableTableManager(_$AppDatabase db, $AiInsightsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AiInsightsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AiInsightsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AiInsightsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> userId = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<int?> createdAt = const Value.absent(),
                Value<int?> serverUpdatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<int> localVersion = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> localCreatedAt = const Value.absent(),
                Value<int> localUpdatedAt = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> businessDate = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> sourceWatermark = const Value.absent(),
                Value<String> recordJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AiInsightsCompanion(
                userId: userId,
                id: id,
                revision: revision,
                createdAt: createdAt,
                serverUpdatedAt: serverUpdatedAt,
                deletedAt: deletedAt,
                localVersion: localVersion,
                syncStatus: syncStatus,
                localCreatedAt: localCreatedAt,
                localUpdatedAt: localUpdatedAt,
                kind: kind,
                businessDate: businessDate,
                status: status,
                sourceWatermark: sourceWatermark,
                recordJson: recordJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String userId,
                required String id,
                Value<int> revision = const Value.absent(),
                Value<int?> createdAt = const Value.absent(),
                Value<int?> serverUpdatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<int> localVersion = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                required int localCreatedAt,
                required int localUpdatedAt,
                required String kind,
                required String businessDate,
                required String status,
                required int sourceWatermark,
                required String recordJson,
                Value<int> rowid = const Value.absent(),
              }) => AiInsightsCompanion.insert(
                userId: userId,
                id: id,
                revision: revision,
                createdAt: createdAt,
                serverUpdatedAt: serverUpdatedAt,
                deletedAt: deletedAt,
                localVersion: localVersion,
                syncStatus: syncStatus,
                localCreatedAt: localCreatedAt,
                localUpdatedAt: localUpdatedAt,
                kind: kind,
                businessDate: businessDate,
                status: status,
                sourceWatermark: sourceWatermark,
                recordJson: recordJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AiInsightsTable, InsightRow>(table),
                  BaseReferences<_$AppDatabase, $AiInsightsTable, InsightRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AiInsightsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AiInsightsTable,
      InsightRow,
      $$AiInsightsTableFilterComposer,
      $$AiInsightsTableOrderingComposer,
      $$AiInsightsTableAnnotationComposer,
      $$AiInsightsTableCreateCompanionBuilder,
      $$AiInsightsTableUpdateCompanionBuilder,
      (InsightRow, BaseReferences<_$AppDatabase, $AiInsightsTable, InsightRow>),
      InsightRow,
      PrefetchHooks Function()
    >;
typedef $$AiProposalsTableCreateCompanionBuilder =
    AiProposalsCompanion Function({
      required String userId,
      required String id,
      Value<int> revision,
      Value<int?> createdAt,
      Value<int?> serverUpdatedAt,
      Value<int?> deletedAt,
      Value<int> localVersion,
      Value<String> syncStatus,
      required int localCreatedAt,
      required int localUpdatedAt,
      required String kind,
      required String status,
      Value<String?> targetId,
      Value<int?> targetRevision,
      required int expiresAt,
      required String recordJson,
      Value<int> rowid,
    });
typedef $$AiProposalsTableUpdateCompanionBuilder =
    AiProposalsCompanion Function({
      Value<String> userId,
      Value<String> id,
      Value<int> revision,
      Value<int?> createdAt,
      Value<int?> serverUpdatedAt,
      Value<int?> deletedAt,
      Value<int> localVersion,
      Value<String> syncStatus,
      Value<int> localCreatedAt,
      Value<int> localUpdatedAt,
      Value<String> kind,
      Value<String> status,
      Value<String?> targetId,
      Value<int?> targetRevision,
      Value<int> expiresAt,
      Value<String> recordJson,
      Value<int> rowid,
    });

class $$AiProposalsTableFilterComposer
    extends Composer<_$AppDatabase, $AiProposalsTable> {
  $$AiProposalsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get localVersion => $composableBuilder(
    column: $table.localVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get localCreatedAt => $composableBuilder(
    column: $table.localCreatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetId => $composableBuilder(
    column: $table.targetId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetRevision => $composableBuilder(
    column: $table.targetRevision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recordJson => $composableBuilder(
    column: $table.recordJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AiProposalsTableOrderingComposer
    extends Composer<_$AppDatabase, $AiProposalsTable> {
  $$AiProposalsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get localVersion => $composableBuilder(
    column: $table.localVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get localCreatedAt => $composableBuilder(
    column: $table.localCreatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetId => $composableBuilder(
    column: $table.targetId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetRevision => $composableBuilder(
    column: $table.targetRevision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recordJson => $composableBuilder(
    column: $table.recordJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AiProposalsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AiProposalsTable> {
  $$AiProposalsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get localVersion => $composableBuilder(
    column: $table.localVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<int> get localCreatedAt => $composableBuilder(
    column: $table.localCreatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get targetId =>
      $composableBuilder(column: $table.targetId, builder: (column) => column);

  GeneratedColumn<int> get targetRevision => $composableBuilder(
    column: $table.targetRevision,
    builder: (column) => column,
  );

  GeneratedColumn<int> get expiresAt =>
      $composableBuilder(column: $table.expiresAt, builder: (column) => column);

  GeneratedColumn<String> get recordJson => $composableBuilder(
    column: $table.recordJson,
    builder: (column) => column,
  );
}

class $$AiProposalsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AiProposalsTable,
          ProposalRow,
          $$AiProposalsTableFilterComposer,
          $$AiProposalsTableOrderingComposer,
          $$AiProposalsTableAnnotationComposer,
          $$AiProposalsTableCreateCompanionBuilder,
          $$AiProposalsTableUpdateCompanionBuilder,
          (
            ProposalRow,
            BaseReferences<_$AppDatabase, $AiProposalsTable, ProposalRow>,
          ),
          ProposalRow,
          PrefetchHooks Function()
        > {
  $$AiProposalsTableTableManager(_$AppDatabase db, $AiProposalsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AiProposalsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AiProposalsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AiProposalsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> userId = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<int?> createdAt = const Value.absent(),
                Value<int?> serverUpdatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<int> localVersion = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> localCreatedAt = const Value.absent(),
                Value<int> localUpdatedAt = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> targetId = const Value.absent(),
                Value<int?> targetRevision = const Value.absent(),
                Value<int> expiresAt = const Value.absent(),
                Value<String> recordJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AiProposalsCompanion(
                userId: userId,
                id: id,
                revision: revision,
                createdAt: createdAt,
                serverUpdatedAt: serverUpdatedAt,
                deletedAt: deletedAt,
                localVersion: localVersion,
                syncStatus: syncStatus,
                localCreatedAt: localCreatedAt,
                localUpdatedAt: localUpdatedAt,
                kind: kind,
                status: status,
                targetId: targetId,
                targetRevision: targetRevision,
                expiresAt: expiresAt,
                recordJson: recordJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String userId,
                required String id,
                Value<int> revision = const Value.absent(),
                Value<int?> createdAt = const Value.absent(),
                Value<int?> serverUpdatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<int> localVersion = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                required int localCreatedAt,
                required int localUpdatedAt,
                required String kind,
                required String status,
                Value<String?> targetId = const Value.absent(),
                Value<int?> targetRevision = const Value.absent(),
                required int expiresAt,
                required String recordJson,
                Value<int> rowid = const Value.absent(),
              }) => AiProposalsCompanion.insert(
                userId: userId,
                id: id,
                revision: revision,
                createdAt: createdAt,
                serverUpdatedAt: serverUpdatedAt,
                deletedAt: deletedAt,
                localVersion: localVersion,
                syncStatus: syncStatus,
                localCreatedAt: localCreatedAt,
                localUpdatedAt: localUpdatedAt,
                kind: kind,
                status: status,
                targetId: targetId,
                targetRevision: targetRevision,
                expiresAt: expiresAt,
                recordJson: recordJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AiProposalsTable, ProposalRow>(table),
                  BaseReferences<_$AppDatabase, $AiProposalsTable, ProposalRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AiProposalsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AiProposalsTable,
      ProposalRow,
      $$AiProposalsTableFilterComposer,
      $$AiProposalsTableOrderingComposer,
      $$AiProposalsTableAnnotationComposer,
      $$AiProposalsTableCreateCompanionBuilder,
      $$AiProposalsTableUpdateCompanionBuilder,
      (
        ProposalRow,
        BaseReferences<_$AppDatabase, $AiProposalsTable, ProposalRow>,
      ),
      ProposalRow,
      PrefetchHooks Function()
    >;
typedef $$ReviewStatesTableCreateCompanionBuilder =
    ReviewStatesCompanion Function({
      required String userId,
      required String id,
      Value<int> revision,
      Value<int?> createdAt,
      Value<int?> serverUpdatedAt,
      Value<int?> deletedAt,
      Value<int> localVersion,
      Value<String> syncStatus,
      required int localCreatedAt,
      required int localUpdatedAt,
      required int transactionRevision,
      required String state,
      Value<String?> proposalId,
      Value<int> rowid,
    });
typedef $$ReviewStatesTableUpdateCompanionBuilder =
    ReviewStatesCompanion Function({
      Value<String> userId,
      Value<String> id,
      Value<int> revision,
      Value<int?> createdAt,
      Value<int?> serverUpdatedAt,
      Value<int?> deletedAt,
      Value<int> localVersion,
      Value<String> syncStatus,
      Value<int> localCreatedAt,
      Value<int> localUpdatedAt,
      Value<int> transactionRevision,
      Value<String> state,
      Value<String?> proposalId,
      Value<int> rowid,
    });

class $$ReviewStatesTableFilterComposer
    extends Composer<_$AppDatabase, $ReviewStatesTable> {
  $$ReviewStatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get localVersion => $composableBuilder(
    column: $table.localVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get localCreatedAt => $composableBuilder(
    column: $table.localCreatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get transactionRevision => $composableBuilder(
    column: $table.transactionRevision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get proposalId => $composableBuilder(
    column: $table.proposalId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ReviewStatesTableOrderingComposer
    extends Composer<_$AppDatabase, $ReviewStatesTable> {
  $$ReviewStatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get localVersion => $composableBuilder(
    column: $table.localVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get localCreatedAt => $composableBuilder(
    column: $table.localCreatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get transactionRevision => $composableBuilder(
    column: $table.transactionRevision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get proposalId => $composableBuilder(
    column: $table.proposalId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ReviewStatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReviewStatesTable> {
  $$ReviewStatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get localVersion => $composableBuilder(
    column: $table.localVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<int> get localCreatedAt => $composableBuilder(
    column: $table.localCreatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get transactionRevision => $composableBuilder(
    column: $table.transactionRevision,
    builder: (column) => column,
  );

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<String> get proposalId => $composableBuilder(
    column: $table.proposalId,
    builder: (column) => column,
  );
}

class $$ReviewStatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReviewStatesTable,
          ReviewStateRow,
          $$ReviewStatesTableFilterComposer,
          $$ReviewStatesTableOrderingComposer,
          $$ReviewStatesTableAnnotationComposer,
          $$ReviewStatesTableCreateCompanionBuilder,
          $$ReviewStatesTableUpdateCompanionBuilder,
          (
            ReviewStateRow,
            BaseReferences<_$AppDatabase, $ReviewStatesTable, ReviewStateRow>,
          ),
          ReviewStateRow,
          PrefetchHooks Function()
        > {
  $$ReviewStatesTableTableManager(_$AppDatabase db, $ReviewStatesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReviewStatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReviewStatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReviewStatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> userId = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<int?> createdAt = const Value.absent(),
                Value<int?> serverUpdatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<int> localVersion = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> localCreatedAt = const Value.absent(),
                Value<int> localUpdatedAt = const Value.absent(),
                Value<int> transactionRevision = const Value.absent(),
                Value<String> state = const Value.absent(),
                Value<String?> proposalId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReviewStatesCompanion(
                userId: userId,
                id: id,
                revision: revision,
                createdAt: createdAt,
                serverUpdatedAt: serverUpdatedAt,
                deletedAt: deletedAt,
                localVersion: localVersion,
                syncStatus: syncStatus,
                localCreatedAt: localCreatedAt,
                localUpdatedAt: localUpdatedAt,
                transactionRevision: transactionRevision,
                state: state,
                proposalId: proposalId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String userId,
                required String id,
                Value<int> revision = const Value.absent(),
                Value<int?> createdAt = const Value.absent(),
                Value<int?> serverUpdatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<int> localVersion = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                required int localCreatedAt,
                required int localUpdatedAt,
                required int transactionRevision,
                required String state,
                Value<String?> proposalId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReviewStatesCompanion.insert(
                userId: userId,
                id: id,
                revision: revision,
                createdAt: createdAt,
                serverUpdatedAt: serverUpdatedAt,
                deletedAt: deletedAt,
                localVersion: localVersion,
                syncStatus: syncStatus,
                localCreatedAt: localCreatedAt,
                localUpdatedAt: localUpdatedAt,
                transactionRevision: transactionRevision,
                state: state,
                proposalId: proposalId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ReviewStatesTable, ReviewStateRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $ReviewStatesTable,
                    ReviewStateRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ReviewStatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReviewStatesTable,
      ReviewStateRow,
      $$ReviewStatesTableFilterComposer,
      $$ReviewStatesTableOrderingComposer,
      $$ReviewStatesTableAnnotationComposer,
      $$ReviewStatesTableCreateCompanionBuilder,
      $$ReviewStatesTableUpdateCompanionBuilder,
      (
        ReviewStateRow,
        BaseReferences<_$AppDatabase, $ReviewStatesTable, ReviewStateRow>,
      ),
      ReviewStateRow,
      PrefetchHooks Function()
    >;
typedef $$AiActivitiesTableCreateCompanionBuilder =
    AiActivitiesCompanion Function({
      required String userId,
      required String id,
      Value<int> revision,
      Value<int?> createdAt,
      Value<int?> serverUpdatedAt,
      Value<int?> deletedAt,
      Value<int> localVersion,
      Value<String> syncStatus,
      required int localCreatedAt,
      required int localUpdatedAt,
      required String agentType,
      required String outcome,
      required String recordJson,
      Value<int> rowid,
    });
typedef $$AiActivitiesTableUpdateCompanionBuilder =
    AiActivitiesCompanion Function({
      Value<String> userId,
      Value<String> id,
      Value<int> revision,
      Value<int?> createdAt,
      Value<int?> serverUpdatedAt,
      Value<int?> deletedAt,
      Value<int> localVersion,
      Value<String> syncStatus,
      Value<int> localCreatedAt,
      Value<int> localUpdatedAt,
      Value<String> agentType,
      Value<String> outcome,
      Value<String> recordJson,
      Value<int> rowid,
    });

class $$AiActivitiesTableFilterComposer
    extends Composer<_$AppDatabase, $AiActivitiesTable> {
  $$AiActivitiesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get localVersion => $composableBuilder(
    column: $table.localVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get localCreatedAt => $composableBuilder(
    column: $table.localCreatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get agentType => $composableBuilder(
    column: $table.agentType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get outcome => $composableBuilder(
    column: $table.outcome,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recordJson => $composableBuilder(
    column: $table.recordJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AiActivitiesTableOrderingComposer
    extends Composer<_$AppDatabase, $AiActivitiesTable> {
  $$AiActivitiesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get localVersion => $composableBuilder(
    column: $table.localVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get localCreatedAt => $composableBuilder(
    column: $table.localCreatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get agentType => $composableBuilder(
    column: $table.agentType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get outcome => $composableBuilder(
    column: $table.outcome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recordJson => $composableBuilder(
    column: $table.recordJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AiActivitiesTableAnnotationComposer
    extends Composer<_$AppDatabase, $AiActivitiesTable> {
  $$AiActivitiesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get localVersion => $composableBuilder(
    column: $table.localVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<int> get localCreatedAt => $composableBuilder(
    column: $table.localCreatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get agentType =>
      $composableBuilder(column: $table.agentType, builder: (column) => column);

  GeneratedColumn<String> get outcome =>
      $composableBuilder(column: $table.outcome, builder: (column) => column);

  GeneratedColumn<String> get recordJson => $composableBuilder(
    column: $table.recordJson,
    builder: (column) => column,
  );
}

class $$AiActivitiesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AiActivitiesTable,
          ActivityRow,
          $$AiActivitiesTableFilterComposer,
          $$AiActivitiesTableOrderingComposer,
          $$AiActivitiesTableAnnotationComposer,
          $$AiActivitiesTableCreateCompanionBuilder,
          $$AiActivitiesTableUpdateCompanionBuilder,
          (
            ActivityRow,
            BaseReferences<_$AppDatabase, $AiActivitiesTable, ActivityRow>,
          ),
          ActivityRow,
          PrefetchHooks Function()
        > {
  $$AiActivitiesTableTableManager(_$AppDatabase db, $AiActivitiesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AiActivitiesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AiActivitiesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AiActivitiesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> userId = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<int?> createdAt = const Value.absent(),
                Value<int?> serverUpdatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<int> localVersion = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> localCreatedAt = const Value.absent(),
                Value<int> localUpdatedAt = const Value.absent(),
                Value<String> agentType = const Value.absent(),
                Value<String> outcome = const Value.absent(),
                Value<String> recordJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AiActivitiesCompanion(
                userId: userId,
                id: id,
                revision: revision,
                createdAt: createdAt,
                serverUpdatedAt: serverUpdatedAt,
                deletedAt: deletedAt,
                localVersion: localVersion,
                syncStatus: syncStatus,
                localCreatedAt: localCreatedAt,
                localUpdatedAt: localUpdatedAt,
                agentType: agentType,
                outcome: outcome,
                recordJson: recordJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String userId,
                required String id,
                Value<int> revision = const Value.absent(),
                Value<int?> createdAt = const Value.absent(),
                Value<int?> serverUpdatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<int> localVersion = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                required int localCreatedAt,
                required int localUpdatedAt,
                required String agentType,
                required String outcome,
                required String recordJson,
                Value<int> rowid = const Value.absent(),
              }) => AiActivitiesCompanion.insert(
                userId: userId,
                id: id,
                revision: revision,
                createdAt: createdAt,
                serverUpdatedAt: serverUpdatedAt,
                deletedAt: deletedAt,
                localVersion: localVersion,
                syncStatus: syncStatus,
                localCreatedAt: localCreatedAt,
                localUpdatedAt: localUpdatedAt,
                agentType: agentType,
                outcome: outcome,
                recordJson: recordJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AiActivitiesTable, ActivityRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $AiActivitiesTable,
                    ActivityRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AiActivitiesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AiActivitiesTable,
      ActivityRow,
      $$AiActivitiesTableFilterComposer,
      $$AiActivitiesTableOrderingComposer,
      $$AiActivitiesTableAnnotationComposer,
      $$AiActivitiesTableCreateCompanionBuilder,
      $$AiActivitiesTableUpdateCompanionBuilder,
      (
        ActivityRow,
        BaseReferences<_$AppDatabase, $AiActivitiesTable, ActivityRow>,
      ),
      ActivityRow,
      PrefetchHooks Function()
    >;
typedef $$AgentRunsTableCreateCompanionBuilder = AgentRunsCompanion Function({
  required String userId,
  required String id,
  Value<int> revision,
  Value<int?> createdAt,
  Value<int?> serverUpdatedAt,
  Value<int?> deletedAt,
  Value<int> localVersion,
  Value<String> syncStatus,
  required int localCreatedAt,
  required int localUpdatedAt,
  required String agentType,
  required String status,
  Value<String?> businessDate,
  required String recordJson,
  Value<int> rowid,
});
typedef $$AgentRunsTableUpdateCompanionBuilder = AgentRunsCompanion Function({
  Value<String> userId,
  Value<String> id,
  Value<int> revision,
  Value<int?> createdAt,
  Value<int?> serverUpdatedAt,
  Value<int?> deletedAt,
  Value<int> localVersion,
  Value<String> syncStatus,
  Value<int> localCreatedAt,
  Value<int> localUpdatedAt,
  Value<String> agentType,
  Value<String> status,
  Value<String?> businessDate,
  Value<String> recordJson,
  Value<int> rowid,
});

class $$AgentRunsTableFilterComposer
    extends Composer<_$AppDatabase, $AgentRunsTable> {
  $$AgentRunsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get localVersion => $composableBuilder(
    column: $table.localVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get localCreatedAt => $composableBuilder(
    column: $table.localCreatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get agentType => $composableBuilder(
    column: $table.agentType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get businessDate => $composableBuilder(
    column: $table.businessDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recordJson => $composableBuilder(
    column: $table.recordJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AgentRunsTableOrderingComposer
    extends Composer<_$AppDatabase, $AgentRunsTable> {
  $$AgentRunsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get localVersion => $composableBuilder(
    column: $table.localVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get localCreatedAt => $composableBuilder(
    column: $table.localCreatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get agentType => $composableBuilder(
    column: $table.agentType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get businessDate => $composableBuilder(
    column: $table.businessDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recordJson => $composableBuilder(
    column: $table.recordJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AgentRunsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AgentRunsTable> {
  $$AgentRunsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get localVersion => $composableBuilder(
    column: $table.localVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<int> get localCreatedAt => $composableBuilder(
    column: $table.localCreatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get agentType =>
      $composableBuilder(column: $table.agentType, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get businessDate => $composableBuilder(
    column: $table.businessDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get recordJson => $composableBuilder(
    column: $table.recordJson,
    builder: (column) => column,
  );
}

class $$AgentRunsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AgentRunsTable,
          AgentRunRow,
          $$AgentRunsTableFilterComposer,
          $$AgentRunsTableOrderingComposer,
          $$AgentRunsTableAnnotationComposer,
          $$AgentRunsTableCreateCompanionBuilder,
          $$AgentRunsTableUpdateCompanionBuilder,
          (
            AgentRunRow,
            BaseReferences<_$AppDatabase, $AgentRunsTable, AgentRunRow>,
          ),
          AgentRunRow,
          PrefetchHooks Function()
        > {
  $$AgentRunsTableTableManager(_$AppDatabase db, $AgentRunsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AgentRunsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AgentRunsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AgentRunsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> userId = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<int?> createdAt = const Value.absent(),
                Value<int?> serverUpdatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<int> localVersion = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> localCreatedAt = const Value.absent(),
                Value<int> localUpdatedAt = const Value.absent(),
                Value<String> agentType = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> businessDate = const Value.absent(),
                Value<String> recordJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AgentRunsCompanion(
                userId: userId,
                id: id,
                revision: revision,
                createdAt: createdAt,
                serverUpdatedAt: serverUpdatedAt,
                deletedAt: deletedAt,
                localVersion: localVersion,
                syncStatus: syncStatus,
                localCreatedAt: localCreatedAt,
                localUpdatedAt: localUpdatedAt,
                agentType: agentType,
                status: status,
                businessDate: businessDate,
                recordJson: recordJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String userId,
                required String id,
                Value<int> revision = const Value.absent(),
                Value<int?> createdAt = const Value.absent(),
                Value<int?> serverUpdatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<int> localVersion = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                required int localCreatedAt,
                required int localUpdatedAt,
                required String agentType,
                required String status,
                Value<String?> businessDate = const Value.absent(),
                required String recordJson,
                Value<int> rowid = const Value.absent(),
              }) => AgentRunsCompanion.insert(
                userId: userId,
                id: id,
                revision: revision,
                createdAt: createdAt,
                serverUpdatedAt: serverUpdatedAt,
                deletedAt: deletedAt,
                localVersion: localVersion,
                syncStatus: syncStatus,
                localCreatedAt: localCreatedAt,
                localUpdatedAt: localUpdatedAt,
                agentType: agentType,
                status: status,
                businessDate: businessDate,
                recordJson: recordJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AgentRunsTable, AgentRunRow>(table),
                  BaseReferences<_$AppDatabase, $AgentRunsTable, AgentRunRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AgentRunsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AgentRunsTable,
      AgentRunRow,
      $$AgentRunsTableFilterComposer,
      $$AgentRunsTableOrderingComposer,
      $$AgentRunsTableAnnotationComposer,
      $$AgentRunsTableCreateCompanionBuilder,
      $$AgentRunsTableUpdateCompanionBuilder,
      (
        AgentRunRow,
        BaseReferences<_$AppDatabase, $AgentRunsTable, AgentRunRow>,
      ),
      AgentRunRow,
      PrefetchHooks Function()
    >;
typedef $$OutboxOpsTableCreateCompanionBuilder = OutboxOpsCompanion Function({
  Value<int> ordinal,
  required String opId,
  required String userId,
  required String entityType,
  required String entityId,
  required String action,
  Value<int?> baseRevision,
  Value<String?> dependsOnOpId,
  Value<String?> payloadJson,
  Value<String?> confirmationJson,
  required String requestHash,
  required int localVersion,
  required String state,
  Value<int> attempts,
  Value<int?> nextAttemptAt,
  Value<String?> errorCode,
  required int createdAt,
});
typedef $$OutboxOpsTableUpdateCompanionBuilder = OutboxOpsCompanion Function({
  Value<int> ordinal,
  Value<String> opId,
  Value<String> userId,
  Value<String> entityType,
  Value<String> entityId,
  Value<String> action,
  Value<int?> baseRevision,
  Value<String?> dependsOnOpId,
  Value<String?> payloadJson,
  Value<String?> confirmationJson,
  Value<String> requestHash,
  Value<int> localVersion,
  Value<String> state,
  Value<int> attempts,
  Value<int?> nextAttemptAt,
  Value<String?> errorCode,
  Value<int> createdAt,
});

class $$OutboxOpsTableFilterComposer
    extends Composer<_$AppDatabase, $OutboxOpsTable> {
  $$OutboxOpsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get ordinal => $composableBuilder(
    column: $table.ordinal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get opId => $composableBuilder(
    column: $table.opId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get baseRevision => $composableBuilder(
    column: $table.baseRevision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dependsOnOpId => $composableBuilder(
    column: $table.dependsOnOpId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get confirmationJson => $composableBuilder(
    column: $table.confirmationJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get requestHash => $composableBuilder(
    column: $table.requestHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get localVersion => $composableBuilder(
    column: $table.localVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get nextAttemptAt => $composableBuilder(
    column: $table.nextAttemptAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get errorCode => $composableBuilder(
    column: $table.errorCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$OutboxOpsTableOrderingComposer
    extends Composer<_$AppDatabase, $OutboxOpsTable> {
  $$OutboxOpsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get ordinal => $composableBuilder(
    column: $table.ordinal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get opId => $composableBuilder(
    column: $table.opId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get baseRevision => $composableBuilder(
    column: $table.baseRevision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dependsOnOpId => $composableBuilder(
    column: $table.dependsOnOpId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get confirmationJson => $composableBuilder(
    column: $table.confirmationJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get requestHash => $composableBuilder(
    column: $table.requestHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get localVersion => $composableBuilder(
    column: $table.localVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get nextAttemptAt => $composableBuilder(
    column: $table.nextAttemptAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get errorCode => $composableBuilder(
    column: $table.errorCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$OutboxOpsTableAnnotationComposer
    extends Composer<_$AppDatabase, $OutboxOpsTable> {
  $$OutboxOpsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get ordinal =>
      $composableBuilder(column: $table.ordinal, builder: (column) => column);

  GeneratedColumn<String> get opId =>
      $composableBuilder(column: $table.opId, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<int> get baseRevision => $composableBuilder(
    column: $table.baseRevision,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dependsOnOpId => $composableBuilder(
    column: $table.dependsOnOpId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get confirmationJson => $composableBuilder(
    column: $table.confirmationJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get requestHash => $composableBuilder(
    column: $table.requestHash,
    builder: (column) => column,
  );

  GeneratedColumn<int> get localVersion => $composableBuilder(
    column: $table.localVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<int> get nextAttemptAt => $composableBuilder(
    column: $table.nextAttemptAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get errorCode =>
      $composableBuilder(column: $table.errorCode, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$OutboxOpsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OutboxOpsTable,
          OutboxRow,
          $$OutboxOpsTableFilterComposer,
          $$OutboxOpsTableOrderingComposer,
          $$OutboxOpsTableAnnotationComposer,
          $$OutboxOpsTableCreateCompanionBuilder,
          $$OutboxOpsTableUpdateCompanionBuilder,
          (
            OutboxRow,
            BaseReferences<_$AppDatabase, $OutboxOpsTable, OutboxRow>,
          ),
          OutboxRow,
          PrefetchHooks Function()
        > {
  $$OutboxOpsTableTableManager(_$AppDatabase db, $OutboxOpsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OutboxOpsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OutboxOpsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OutboxOpsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> ordinal = const Value.absent(),
                Value<String> opId = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> entityType = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String> action = const Value.absent(),
                Value<int?> baseRevision = const Value.absent(),
                Value<String?> dependsOnOpId = const Value.absent(),
                Value<String?> payloadJson = const Value.absent(),
                Value<String?> confirmationJson = const Value.absent(),
                Value<String> requestHash = const Value.absent(),
                Value<int> localVersion = const Value.absent(),
                Value<String> state = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<int?> nextAttemptAt = const Value.absent(),
                Value<String?> errorCode = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
              }) => OutboxOpsCompanion(
                ordinal: ordinal,
                opId: opId,
                userId: userId,
                entityType: entityType,
                entityId: entityId,
                action: action,
                baseRevision: baseRevision,
                dependsOnOpId: dependsOnOpId,
                payloadJson: payloadJson,
                confirmationJson: confirmationJson,
                requestHash: requestHash,
                localVersion: localVersion,
                state: state,
                attempts: attempts,
                nextAttemptAt: nextAttemptAt,
                errorCode: errorCode,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> ordinal = const Value.absent(),
                required String opId,
                required String userId,
                required String entityType,
                required String entityId,
                required String action,
                Value<int?> baseRevision = const Value.absent(),
                Value<String?> dependsOnOpId = const Value.absent(),
                Value<String?> payloadJson = const Value.absent(),
                Value<String?> confirmationJson = const Value.absent(),
                required String requestHash,
                required int localVersion,
                required String state,
                Value<int> attempts = const Value.absent(),
                Value<int?> nextAttemptAt = const Value.absent(),
                Value<String?> errorCode = const Value.absent(),
                required int createdAt,
              }) => OutboxOpsCompanion.insert(
                ordinal: ordinal,
                opId: opId,
                userId: userId,
                entityType: entityType,
                entityId: entityId,
                action: action,
                baseRevision: baseRevision,
                dependsOnOpId: dependsOnOpId,
                payloadJson: payloadJson,
                confirmationJson: confirmationJson,
                requestHash: requestHash,
                localVersion: localVersion,
                state: state,
                attempts: attempts,
                nextAttemptAt: nextAttemptAt,
                errorCode: errorCode,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$OutboxOpsTable, OutboxRow>(table),
                  BaseReferences<_$AppDatabase, $OutboxOpsTable, OutboxRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$OutboxOpsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OutboxOpsTable,
      OutboxRow,
      $$OutboxOpsTableFilterComposer,
      $$OutboxOpsTableOrderingComposer,
      $$OutboxOpsTableAnnotationComposer,
      $$OutboxOpsTableCreateCompanionBuilder,
      $$OutboxOpsTableUpdateCompanionBuilder,
      (OutboxRow, BaseReferences<_$AppDatabase, $OutboxOpsTable, OutboxRow>),
      OutboxRow,
      PrefetchHooks Function()
    >;
typedef $$RemoteShadowsTableCreateCompanionBuilder =
    RemoteShadowsCompanion Function({
      required String userId,
      required String entityType,
      required String entityId,
      required int revision,
      required String canonicalJson,
      Value<int?> deletedAt,
      Value<int> rowid,
    });
typedef $$RemoteShadowsTableUpdateCompanionBuilder =
    RemoteShadowsCompanion Function({
      Value<String> userId,
      Value<String> entityType,
      Value<String> entityId,
      Value<int> revision,
      Value<String> canonicalJson,
      Value<int?> deletedAt,
      Value<int> rowid,
    });

class $$RemoteShadowsTableFilterComposer
    extends Composer<_$AppDatabase, $RemoteShadowsTable> {
  $$RemoteShadowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get canonicalJson => $composableBuilder(
    column: $table.canonicalJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RemoteShadowsTableOrderingComposer
    extends Composer<_$AppDatabase, $RemoteShadowsTable> {
  $$RemoteShadowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get canonicalJson => $composableBuilder(
    column: $table.canonicalJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RemoteShadowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RemoteShadowsTable> {
  $$RemoteShadowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);

  GeneratedColumn<String> get canonicalJson => $composableBuilder(
    column: $table.canonicalJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$RemoteShadowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RemoteShadowsTable,
          ShadowRow,
          $$RemoteShadowsTableFilterComposer,
          $$RemoteShadowsTableOrderingComposer,
          $$RemoteShadowsTableAnnotationComposer,
          $$RemoteShadowsTableCreateCompanionBuilder,
          $$RemoteShadowsTableUpdateCompanionBuilder,
          (
            ShadowRow,
            BaseReferences<_$AppDatabase, $RemoteShadowsTable, ShadowRow>,
          ),
          ShadowRow,
          PrefetchHooks Function()
        > {
  $$RemoteShadowsTableTableManager(_$AppDatabase db, $RemoteShadowsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RemoteShadowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RemoteShadowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RemoteShadowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> userId = const Value.absent(),
                Value<String> entityType = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<String> canonicalJson = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RemoteShadowsCompanion(
                userId: userId,
                entityType: entityType,
                entityId: entityId,
                revision: revision,
                canonicalJson: canonicalJson,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String userId,
                required String entityType,
                required String entityId,
                required int revision,
                required String canonicalJson,
                Value<int?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RemoteShadowsCompanion.insert(
                userId: userId,
                entityType: entityType,
                entityId: entityId,
                revision: revision,
                canonicalJson: canonicalJson,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RemoteShadowsTable, ShadowRow>(table),
                  BaseReferences<_$AppDatabase, $RemoteShadowsTable, ShadowRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RemoteShadowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RemoteShadowsTable,
      ShadowRow,
      $$RemoteShadowsTableFilterComposer,
      $$RemoteShadowsTableOrderingComposer,
      $$RemoteShadowsTableAnnotationComposer,
      $$RemoteShadowsTableCreateCompanionBuilder,
      $$RemoteShadowsTableUpdateCompanionBuilder,
      (
        ShadowRow,
        BaseReferences<_$AppDatabase, $RemoteShadowsTable, ShadowRow>,
      ),
      ShadowRow,
      PrefetchHooks Function()
    >;
typedef $$SyncCursorsTableCreateCompanionBuilder =
    SyncCursorsCompanion Function({
      required String userId,
      Value<int> lastAppliedSeq,
      Value<int> lastLedgerSeq,
      Value<int?> pageWatermark,
      Value<int> protocolVersion,
      Value<int?> lastSyncedAt,
      Value<String?> pausedReason,
      Value<int> rowid,
    });
typedef $$SyncCursorsTableUpdateCompanionBuilder =
    SyncCursorsCompanion Function({
      Value<String> userId,
      Value<int> lastAppliedSeq,
      Value<int> lastLedgerSeq,
      Value<int?> pageWatermark,
      Value<int> protocolVersion,
      Value<int?> lastSyncedAt,
      Value<String?> pausedReason,
      Value<int> rowid,
    });

class $$SyncCursorsTableFilterComposer
    extends Composer<_$AppDatabase, $SyncCursorsTable> {
  $$SyncCursorsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastAppliedSeq => $composableBuilder(
    column: $table.lastAppliedSeq,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastLedgerSeq => $composableBuilder(
    column: $table.lastLedgerSeq,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pageWatermark => $composableBuilder(
    column: $table.pageWatermark,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get protocolVersion => $composableBuilder(
    column: $table.protocolVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pausedReason => $composableBuilder(
    column: $table.pausedReason,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncCursorsTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncCursorsTable> {
  $$SyncCursorsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastAppliedSeq => $composableBuilder(
    column: $table.lastAppliedSeq,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastLedgerSeq => $composableBuilder(
    column: $table.lastLedgerSeq,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pageWatermark => $composableBuilder(
    column: $table.pageWatermark,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get protocolVersion => $composableBuilder(
    column: $table.protocolVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pausedReason => $composableBuilder(
    column: $table.pausedReason,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncCursorsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncCursorsTable> {
  $$SyncCursorsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<int> get lastAppliedSeq => $composableBuilder(
    column: $table.lastAppliedSeq,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastLedgerSeq => $composableBuilder(
    column: $table.lastLedgerSeq,
    builder: (column) => column,
  );

  GeneratedColumn<int> get pageWatermark => $composableBuilder(
    column: $table.pageWatermark,
    builder: (column) => column,
  );

  GeneratedColumn<int> get protocolVersion => $composableBuilder(
    column: $table.protocolVersion,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get pausedReason => $composableBuilder(
    column: $table.pausedReason,
    builder: (column) => column,
  );
}

class $$SyncCursorsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncCursorsTable,
          CursorRow,
          $$SyncCursorsTableFilterComposer,
          $$SyncCursorsTableOrderingComposer,
          $$SyncCursorsTableAnnotationComposer,
          $$SyncCursorsTableCreateCompanionBuilder,
          $$SyncCursorsTableUpdateCompanionBuilder,
          (
            CursorRow,
            BaseReferences<_$AppDatabase, $SyncCursorsTable, CursorRow>,
          ),
          CursorRow,
          PrefetchHooks Function()
        > {
  $$SyncCursorsTableTableManager(_$AppDatabase db, $SyncCursorsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncCursorsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncCursorsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncCursorsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> userId = const Value.absent(),
                Value<int> lastAppliedSeq = const Value.absent(),
                Value<int> lastLedgerSeq = const Value.absent(),
                Value<int?> pageWatermark = const Value.absent(),
                Value<int> protocolVersion = const Value.absent(),
                Value<int?> lastSyncedAt = const Value.absent(),
                Value<String?> pausedReason = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncCursorsCompanion(
                userId: userId,
                lastAppliedSeq: lastAppliedSeq,
                lastLedgerSeq: lastLedgerSeq,
                pageWatermark: pageWatermark,
                protocolVersion: protocolVersion,
                lastSyncedAt: lastSyncedAt,
                pausedReason: pausedReason,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String userId,
                Value<int> lastAppliedSeq = const Value.absent(),
                Value<int> lastLedgerSeq = const Value.absent(),
                Value<int?> pageWatermark = const Value.absent(),
                Value<int> protocolVersion = const Value.absent(),
                Value<int?> lastSyncedAt = const Value.absent(),
                Value<String?> pausedReason = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncCursorsCompanion.insert(
                userId: userId,
                lastAppliedSeq: lastAppliedSeq,
                lastLedgerSeq: lastLedgerSeq,
                pageWatermark: pageWatermark,
                protocolVersion: protocolVersion,
                lastSyncedAt: lastSyncedAt,
                pausedReason: pausedReason,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SyncCursorsTable, CursorRow>(table),
                  BaseReferences<_$AppDatabase, $SyncCursorsTable, CursorRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncCursorsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncCursorsTable,
      CursorRow,
      $$SyncCursorsTableFilterComposer,
      $$SyncCursorsTableOrderingComposer,
      $$SyncCursorsTableAnnotationComposer,
      $$SyncCursorsTableCreateCompanionBuilder,
      $$SyncCursorsTableUpdateCompanionBuilder,
      (CursorRow, BaseReferences<_$AppDatabase, $SyncCursorsTable, CursorRow>),
      CursorRow,
      PrefetchHooks Function()
    >;
typedef $$SyncConflictsTableCreateCompanionBuilder =
    SyncConflictsCompanion Function({
      required String opId,
      required String userId,
      required String entityType,
      required String entityId,
      Value<String?> baseJson,
      Value<String?> proposedJson,
      Value<String?> serverJson,
      Value<int?> serverRevision,
      required int detectedAt,
      Value<int?> resolvedAt,
      Value<int> rowid,
    });
typedef $$SyncConflictsTableUpdateCompanionBuilder =
    SyncConflictsCompanion Function({
      Value<String> opId,
      Value<String> userId,
      Value<String> entityType,
      Value<String> entityId,
      Value<String?> baseJson,
      Value<String?> proposedJson,
      Value<String?> serverJson,
      Value<int?> serverRevision,
      Value<int> detectedAt,
      Value<int?> resolvedAt,
      Value<int> rowid,
    });

class $$SyncConflictsTableFilterComposer
    extends Composer<_$AppDatabase, $SyncConflictsTable> {
  $$SyncConflictsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get opId => $composableBuilder(
    column: $table.opId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get baseJson => $composableBuilder(
    column: $table.baseJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get proposedJson => $composableBuilder(
    column: $table.proposedJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serverJson => $composableBuilder(
    column: $table.serverJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverRevision => $composableBuilder(
    column: $table.serverRevision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get detectedAt => $composableBuilder(
    column: $table.detectedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get resolvedAt => $composableBuilder(
    column: $table.resolvedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncConflictsTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncConflictsTable> {
  $$SyncConflictsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get opId => $composableBuilder(
    column: $table.opId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get baseJson => $composableBuilder(
    column: $table.baseJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get proposedJson => $composableBuilder(
    column: $table.proposedJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serverJson => $composableBuilder(
    column: $table.serverJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverRevision => $composableBuilder(
    column: $table.serverRevision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get detectedAt => $composableBuilder(
    column: $table.detectedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get resolvedAt => $composableBuilder(
    column: $table.resolvedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncConflictsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncConflictsTable> {
  $$SyncConflictsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get opId =>
      $composableBuilder(column: $table.opId, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get baseJson =>
      $composableBuilder(column: $table.baseJson, builder: (column) => column);

  GeneratedColumn<String> get proposedJson => $composableBuilder(
    column: $table.proposedJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get serverJson => $composableBuilder(
    column: $table.serverJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get serverRevision => $composableBuilder(
    column: $table.serverRevision,
    builder: (column) => column,
  );

  GeneratedColumn<int> get detectedAt => $composableBuilder(
    column: $table.detectedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get resolvedAt => $composableBuilder(
    column: $table.resolvedAt,
    builder: (column) => column,
  );
}

class $$SyncConflictsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncConflictsTable,
          ConflictRow,
          $$SyncConflictsTableFilterComposer,
          $$SyncConflictsTableOrderingComposer,
          $$SyncConflictsTableAnnotationComposer,
          $$SyncConflictsTableCreateCompanionBuilder,
          $$SyncConflictsTableUpdateCompanionBuilder,
          (
            ConflictRow,
            BaseReferences<_$AppDatabase, $SyncConflictsTable, ConflictRow>,
          ),
          ConflictRow,
          PrefetchHooks Function()
        > {
  $$SyncConflictsTableTableManager(_$AppDatabase db, $SyncConflictsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncConflictsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncConflictsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncConflictsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> opId = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> entityType = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String?> baseJson = const Value.absent(),
                Value<String?> proposedJson = const Value.absent(),
                Value<String?> serverJson = const Value.absent(),
                Value<int?> serverRevision = const Value.absent(),
                Value<int> detectedAt = const Value.absent(),
                Value<int?> resolvedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncConflictsCompanion(
                opId: opId,
                userId: userId,
                entityType: entityType,
                entityId: entityId,
                baseJson: baseJson,
                proposedJson: proposedJson,
                serverJson: serverJson,
                serverRevision: serverRevision,
                detectedAt: detectedAt,
                resolvedAt: resolvedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String opId,
                required String userId,
                required String entityType,
                required String entityId,
                Value<String?> baseJson = const Value.absent(),
                Value<String?> proposedJson = const Value.absent(),
                Value<String?> serverJson = const Value.absent(),
                Value<int?> serverRevision = const Value.absent(),
                required int detectedAt,
                Value<int?> resolvedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncConflictsCompanion.insert(
                opId: opId,
                userId: userId,
                entityType: entityType,
                entityId: entityId,
                baseJson: baseJson,
                proposedJson: proposedJson,
                serverJson: serverJson,
                serverRevision: serverRevision,
                detectedAt: detectedAt,
                resolvedAt: resolvedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SyncConflictsTable, ConflictRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $SyncConflictsTable,
                    ConflictRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncConflictsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncConflictsTable,
      ConflictRow,
      $$SyncConflictsTableFilterComposer,
      $$SyncConflictsTableOrderingComposer,
      $$SyncConflictsTableAnnotationComposer,
      $$SyncConflictsTableCreateCompanionBuilder,
      $$SyncConflictsTableUpdateCompanionBuilder,
      (
        ConflictRow,
        BaseReferences<_$AppDatabase, $SyncConflictsTable, ConflictRow>,
      ),
      ConflictRow,
      PrefetchHooks Function()
    >;
typedef $$DraftsTableCreateCompanionBuilder = DraftsCompanion Function({
  required String id,
  required String userId,
  required String rawInput,
  Value<String?> candidateJson,
  required int createdAt,
  required int updatedAt,
  required int expiresAt,
  Value<int> rowid,
});
typedef $$DraftsTableUpdateCompanionBuilder = DraftsCompanion Function({
  Value<String> id,
  Value<String> userId,
  Value<String> rawInput,
  Value<String?> candidateJson,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<int> expiresAt,
  Value<int> rowid,
});

class $$DraftsTableFilterComposer
    extends Composer<_$AppDatabase, $DraftsTable> {
  $$DraftsTableFilterComposer({
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

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rawInput => $composableBuilder(
    column: $table.rawInput,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get candidateJson => $composableBuilder(
    column: $table.candidateJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DraftsTableOrderingComposer
    extends Composer<_$AppDatabase, $DraftsTable> {
  $$DraftsTableOrderingComposer({
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

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rawInput => $composableBuilder(
    column: $table.rawInput,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get candidateJson => $composableBuilder(
    column: $table.candidateJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DraftsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DraftsTable> {
  $$DraftsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get rawInput =>
      $composableBuilder(column: $table.rawInput, builder: (column) => column);

  GeneratedColumn<String> get candidateJson => $composableBuilder(
    column: $table.candidateJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get expiresAt =>
      $composableBuilder(column: $table.expiresAt, builder: (column) => column);
}

class $$DraftsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DraftsTable,
          DraftRow,
          $$DraftsTableFilterComposer,
          $$DraftsTableOrderingComposer,
          $$DraftsTableAnnotationComposer,
          $$DraftsTableCreateCompanionBuilder,
          $$DraftsTableUpdateCompanionBuilder,
          (DraftRow, BaseReferences<_$AppDatabase, $DraftsTable, DraftRow>),
          DraftRow,
          PrefetchHooks Function()
        > {
  $$DraftsTableTableManager(_$AppDatabase db, $DraftsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DraftsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DraftsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DraftsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> rawInput = const Value.absent(),
                Value<String?> candidateJson = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> expiresAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DraftsCompanion(
                id: id,
                userId: userId,
                rawInput: rawInput,
                candidateJson: candidateJson,
                createdAt: createdAt,
                updatedAt: updatedAt,
                expiresAt: expiresAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required String rawInput,
                Value<String?> candidateJson = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                required int expiresAt,
                Value<int> rowid = const Value.absent(),
              }) => DraftsCompanion.insert(
                id: id,
                userId: userId,
                rawInput: rawInput,
                candidateJson: candidateJson,
                createdAt: createdAt,
                updatedAt: updatedAt,
                expiresAt: expiresAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DraftsTable, DraftRow>(table),
                  BaseReferences<_$AppDatabase, $DraftsTable, DraftRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DraftsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DraftsTable,
      DraftRow,
      $$DraftsTableFilterComposer,
      $$DraftsTableOrderingComposer,
      $$DraftsTableAnnotationComposer,
      $$DraftsTableCreateCompanionBuilder,
      $$DraftsTableUpdateCompanionBuilder,
      (DraftRow, BaseReferences<_$AppDatabase, $DraftsTable, DraftRow>),
      DraftRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ProfilesTableTableManager get profiles =>
      $$ProfilesTableTableManager(_db, _db.profiles);
  $$SettingsRecordsTableTableManager get settingsRecords =>
      $$SettingsRecordsTableTableManager(_db, _db.settingsRecords);
  $$AccountsTableTableManager get accounts =>
      $$AccountsTableTableManager(_db, _db.accounts);
  $$IncomeSourcesTableTableManager get incomeSources =>
      $$IncomeSourcesTableTableManager(_db, _db.incomeSources);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$TransactionsTableTableManager get transactions =>
      $$TransactionsTableTableManager(_db, _db.transactions);
  $$CategorizationRulesTableTableManager get categorizationRules =>
      $$CategorizationRulesTableTableManager(_db, _db.categorizationRules);
  $$BudgetsTableTableManager get budgets =>
      $$BudgetsTableTableManager(_db, _db.budgets);
  $$AiInsightsTableTableManager get aiInsights =>
      $$AiInsightsTableTableManager(_db, _db.aiInsights);
  $$AiProposalsTableTableManager get aiProposals =>
      $$AiProposalsTableTableManager(_db, _db.aiProposals);
  $$ReviewStatesTableTableManager get reviewStates =>
      $$ReviewStatesTableTableManager(_db, _db.reviewStates);
  $$AiActivitiesTableTableManager get aiActivities =>
      $$AiActivitiesTableTableManager(_db, _db.aiActivities);
  $$AgentRunsTableTableManager get agentRuns =>
      $$AgentRunsTableTableManager(_db, _db.agentRuns);
  $$OutboxOpsTableTableManager get outboxOps =>
      $$OutboxOpsTableTableManager(_db, _db.outboxOps);
  $$RemoteShadowsTableTableManager get remoteShadows =>
      $$RemoteShadowsTableTableManager(_db, _db.remoteShadows);
  $$SyncCursorsTableTableManager get syncCursors =>
      $$SyncCursorsTableTableManager(_db, _db.syncCursors);
  $$SyncConflictsTableTableManager get syncConflicts =>
      $$SyncConflictsTableTableManager(_db, _db.syncConflicts);
  $$DraftsTableTableManager get drafts =>
      $$DraftsTableTableManager(_db, _db.drafts);
}
