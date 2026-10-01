// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $CachedProjectsTable extends CachedProjects
    with TableInfo<$CachedProjectsTable, CachedProject> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedProjectsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
      'code', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _locationMeta =
      const VerificationMeta('location');
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
      'location', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('ACTIVE'));
  static const VerificationMeta _budgetEtbMeta =
      const VerificationMeta('budgetEtb');
  @override
  late final GeneratedColumn<double> budgetEtb = GeneratedColumn<double>(
      'budget_etb', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  @override
  List<GeneratedColumn> get $columns =>
      [id, code, name, location, status, budgetEtb];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_projects';
  @override
  VerificationContext validateIntegrity(Insertable<CachedProject> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
          _codeMeta, code.isAcceptableOrUnknown(data['code']!, _codeMeta));
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('location')) {
      context.handle(_locationMeta,
          location.isAcceptableOrUnknown(data['location']!, _locationMeta));
    } else if (isInserting) {
      context.missing(_locationMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('budget_etb')) {
      context.handle(_budgetEtbMeta,
          budgetEtb.isAcceptableOrUnknown(data['budget_etb']!, _budgetEtbMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedProject map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedProject(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      code: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}code'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      location: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}location'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      budgetEtb: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}budget_etb'])!,
    );
  }

  @override
  $CachedProjectsTable createAlias(String alias) {
    return $CachedProjectsTable(attachedDatabase, alias);
  }
}

class CachedProject extends DataClass implements Insertable<CachedProject> {
  final String id;
  final String code;
  final String name;
  final String location;
  final String status;
  final double budgetEtb;
  const CachedProject(
      {required this.id,
      required this.code,
      required this.name,
      required this.location,
      required this.status,
      required this.budgetEtb});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['code'] = Variable<String>(code);
    map['name'] = Variable<String>(name);
    map['location'] = Variable<String>(location);
    map['status'] = Variable<String>(status);
    map['budget_etb'] = Variable<double>(budgetEtb);
    return map;
  }

  CachedProjectsCompanion toCompanion(bool nullToAbsent) {
    return CachedProjectsCompanion(
      id: Value(id),
      code: Value(code),
      name: Value(name),
      location: Value(location),
      status: Value(status),
      budgetEtb: Value(budgetEtb),
    );
  }

  factory CachedProject.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedProject(
      id: serializer.fromJson<String>(json['id']),
      code: serializer.fromJson<String>(json['code']),
      name: serializer.fromJson<String>(json['name']),
      location: serializer.fromJson<String>(json['location']),
      status: serializer.fromJson<String>(json['status']),
      budgetEtb: serializer.fromJson<double>(json['budgetEtb']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'code': serializer.toJson<String>(code),
      'name': serializer.toJson<String>(name),
      'location': serializer.toJson<String>(location),
      'status': serializer.toJson<String>(status),
      'budgetEtb': serializer.toJson<double>(budgetEtb),
    };
  }

  CachedProject copyWith(
          {String? id,
          String? code,
          String? name,
          String? location,
          String? status,
          double? budgetEtb}) =>
      CachedProject(
        id: id ?? this.id,
        code: code ?? this.code,
        name: name ?? this.name,
        location: location ?? this.location,
        status: status ?? this.status,
        budgetEtb: budgetEtb ?? this.budgetEtb,
      );
  CachedProject copyWithCompanion(CachedProjectsCompanion data) {
    return CachedProject(
      id: data.id.present ? data.id.value : this.id,
      code: data.code.present ? data.code.value : this.code,
      name: data.name.present ? data.name.value : this.name,
      location: data.location.present ? data.location.value : this.location,
      status: data.status.present ? data.status.value : this.status,
      budgetEtb: data.budgetEtb.present ? data.budgetEtb.value : this.budgetEtb,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedProject(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('location: $location, ')
          ..write('status: $status, ')
          ..write('budgetEtb: $budgetEtb')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, code, name, location, status, budgetEtb);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedProject &&
          other.id == this.id &&
          other.code == this.code &&
          other.name == this.name &&
          other.location == this.location &&
          other.status == this.status &&
          other.budgetEtb == this.budgetEtb);
}

class CachedProjectsCompanion extends UpdateCompanion<CachedProject> {
  final Value<String> id;
  final Value<String> code;
  final Value<String> name;
  final Value<String> location;
  final Value<String> status;
  final Value<double> budgetEtb;
  final Value<int> rowid;
  const CachedProjectsCompanion({
    this.id = const Value.absent(),
    this.code = const Value.absent(),
    this.name = const Value.absent(),
    this.location = const Value.absent(),
    this.status = const Value.absent(),
    this.budgetEtb = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedProjectsCompanion.insert({
    required String id,
    required String code,
    required String name,
    required String location,
    this.status = const Value.absent(),
    this.budgetEtb = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        code = Value(code),
        name = Value(name),
        location = Value(location);
  static Insertable<CachedProject> custom({
    Expression<String>? id,
    Expression<String>? code,
    Expression<String>? name,
    Expression<String>? location,
    Expression<String>? status,
    Expression<double>? budgetEtb,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (code != null) 'code': code,
      if (name != null) 'name': name,
      if (location != null) 'location': location,
      if (status != null) 'status': status,
      if (budgetEtb != null) 'budget_etb': budgetEtb,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedProjectsCompanion copyWith(
      {Value<String>? id,
      Value<String>? code,
      Value<String>? name,
      Value<String>? location,
      Value<String>? status,
      Value<double>? budgetEtb,
      Value<int>? rowid}) {
    return CachedProjectsCompanion(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      location: location ?? this.location,
      status: status ?? this.status,
      budgetEtb: budgetEtb ?? this.budgetEtb,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (budgetEtb.present) {
      map['budget_etb'] = Variable<double>(budgetEtb.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedProjectsCompanion(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('location: $location, ')
          ..write('status: $status, ')
          ..write('budgetEtb: $budgetEtb, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CachedOrdersTable extends CachedOrders
    with TableInfo<$CachedOrdersTable, CachedOrder> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedOrdersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _projectIdMeta =
      const VerificationMeta('projectId');
  @override
  late final GeneratedColumn<String> projectId = GeneratedColumn<String>(
      'project_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _poNumberMeta =
      const VerificationMeta('poNumber');
  @override
  late final GeneratedColumn<String> poNumber = GeneratedColumn<String>(
      'po_number', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _supplierNameMeta =
      const VerificationMeta('supplierName');
  @override
  late final GeneratedColumn<String> supplierName = GeneratedColumn<String>(
      'supplier_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _totalAmountEtbMeta =
      const VerificationMeta('totalAmountEtb');
  @override
  late final GeneratedColumn<double> totalAmountEtb = GeneratedColumn<double>(
      'total_amount_etb', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _versionMeta =
      const VerificationMeta('version');
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
      'version', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        projectId,
        poNumber,
        supplierName,
        status,
        totalAmountEtb,
        version,
        notes,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_orders';
  @override
  VerificationContext validateIntegrity(Insertable<CachedOrder> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('project_id')) {
      context.handle(_projectIdMeta,
          projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta));
    } else if (isInserting) {
      context.missing(_projectIdMeta);
    }
    if (data.containsKey('po_number')) {
      context.handle(_poNumberMeta,
          poNumber.isAcceptableOrUnknown(data['po_number']!, _poNumberMeta));
    } else if (isInserting) {
      context.missing(_poNumberMeta);
    }
    if (data.containsKey('supplier_name')) {
      context.handle(
          _supplierNameMeta,
          supplierName.isAcceptableOrUnknown(
              data['supplier_name']!, _supplierNameMeta));
    } else if (isInserting) {
      context.missing(_supplierNameMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('total_amount_etb')) {
      context.handle(
          _totalAmountEtbMeta,
          totalAmountEtb.isAcceptableOrUnknown(
              data['total_amount_etb']!, _totalAmountEtbMeta));
    } else if (isInserting) {
      context.missing(_totalAmountEtbMeta);
    }
    if (data.containsKey('version')) {
      context.handle(_versionMeta,
          version.isAcceptableOrUnknown(data['version']!, _versionMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedOrder map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedOrder(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      projectId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}project_id'])!,
      poNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}po_number'])!,
      supplierName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}supplier_name'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      totalAmountEtb: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}total_amount_etb'])!,
      version: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}version'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $CachedOrdersTable createAlias(String alias) {
    return $CachedOrdersTable(attachedDatabase, alias);
  }
}

class CachedOrder extends DataClass implements Insertable<CachedOrder> {
  final String id;
  final String projectId;
  final String poNumber;
  final String supplierName;
  final String status;
  final double totalAmountEtb;
  final int version;
  final String? notes;
  final DateTime createdAt;
  const CachedOrder(
      {required this.id,
      required this.projectId,
      required this.poNumber,
      required this.supplierName,
      required this.status,
      required this.totalAmountEtb,
      required this.version,
      this.notes,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['project_id'] = Variable<String>(projectId);
    map['po_number'] = Variable<String>(poNumber);
    map['supplier_name'] = Variable<String>(supplierName);
    map['status'] = Variable<String>(status);
    map['total_amount_etb'] = Variable<double>(totalAmountEtb);
    map['version'] = Variable<int>(version);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CachedOrdersCompanion toCompanion(bool nullToAbsent) {
    return CachedOrdersCompanion(
      id: Value(id),
      projectId: Value(projectId),
      poNumber: Value(poNumber),
      supplierName: Value(supplierName),
      status: Value(status),
      totalAmountEtb: Value(totalAmountEtb),
      version: Value(version),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      createdAt: Value(createdAt),
    );
  }

  factory CachedOrder.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedOrder(
      id: serializer.fromJson<String>(json['id']),
      projectId: serializer.fromJson<String>(json['projectId']),
      poNumber: serializer.fromJson<String>(json['poNumber']),
      supplierName: serializer.fromJson<String>(json['supplierName']),
      status: serializer.fromJson<String>(json['status']),
      totalAmountEtb: serializer.fromJson<double>(json['totalAmountEtb']),
      version: serializer.fromJson<int>(json['version']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'projectId': serializer.toJson<String>(projectId),
      'poNumber': serializer.toJson<String>(poNumber),
      'supplierName': serializer.toJson<String>(supplierName),
      'status': serializer.toJson<String>(status),
      'totalAmountEtb': serializer.toJson<double>(totalAmountEtb),
      'version': serializer.toJson<int>(version),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  CachedOrder copyWith(
          {String? id,
          String? projectId,
          String? poNumber,
          String? supplierName,
          String? status,
          double? totalAmountEtb,
          int? version,
          Value<String?> notes = const Value.absent(),
          DateTime? createdAt}) =>
      CachedOrder(
        id: id ?? this.id,
        projectId: projectId ?? this.projectId,
        poNumber: poNumber ?? this.poNumber,
        supplierName: supplierName ?? this.supplierName,
        status: status ?? this.status,
        totalAmountEtb: totalAmountEtb ?? this.totalAmountEtb,
        version: version ?? this.version,
        notes: notes.present ? notes.value : this.notes,
        createdAt: createdAt ?? this.createdAt,
      );
  CachedOrder copyWithCompanion(CachedOrdersCompanion data) {
    return CachedOrder(
      id: data.id.present ? data.id.value : this.id,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      poNumber: data.poNumber.present ? data.poNumber.value : this.poNumber,
      supplierName: data.supplierName.present
          ? data.supplierName.value
          : this.supplierName,
      status: data.status.present ? data.status.value : this.status,
      totalAmountEtb: data.totalAmountEtb.present
          ? data.totalAmountEtb.value
          : this.totalAmountEtb,
      version: data.version.present ? data.version.value : this.version,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedOrder(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('poNumber: $poNumber, ')
          ..write('supplierName: $supplierName, ')
          ..write('status: $status, ')
          ..write('totalAmountEtb: $totalAmountEtb, ')
          ..write('version: $version, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, projectId, poNumber, supplierName, status,
      totalAmountEtb, version, notes, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedOrder &&
          other.id == this.id &&
          other.projectId == this.projectId &&
          other.poNumber == this.poNumber &&
          other.supplierName == this.supplierName &&
          other.status == this.status &&
          other.totalAmountEtb == this.totalAmountEtb &&
          other.version == this.version &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt);
}

class CachedOrdersCompanion extends UpdateCompanion<CachedOrder> {
  final Value<String> id;
  final Value<String> projectId;
  final Value<String> poNumber;
  final Value<String> supplierName;
  final Value<String> status;
  final Value<double> totalAmountEtb;
  final Value<int> version;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const CachedOrdersCompanion({
    this.id = const Value.absent(),
    this.projectId = const Value.absent(),
    this.poNumber = const Value.absent(),
    this.supplierName = const Value.absent(),
    this.status = const Value.absent(),
    this.totalAmountEtb = const Value.absent(),
    this.version = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedOrdersCompanion.insert({
    required String id,
    required String projectId,
    required String poNumber,
    required String supplierName,
    required String status,
    required double totalAmountEtb,
    this.version = const Value.absent(),
    this.notes = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        projectId = Value(projectId),
        poNumber = Value(poNumber),
        supplierName = Value(supplierName),
        status = Value(status),
        totalAmountEtb = Value(totalAmountEtb),
        createdAt = Value(createdAt);
  static Insertable<CachedOrder> custom({
    Expression<String>? id,
    Expression<String>? projectId,
    Expression<String>? poNumber,
    Expression<String>? supplierName,
    Expression<String>? status,
    Expression<double>? totalAmountEtb,
    Expression<int>? version,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (projectId != null) 'project_id': projectId,
      if (poNumber != null) 'po_number': poNumber,
      if (supplierName != null) 'supplier_name': supplierName,
      if (status != null) 'status': status,
      if (totalAmountEtb != null) 'total_amount_etb': totalAmountEtb,
      if (version != null) 'version': version,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedOrdersCompanion copyWith(
      {Value<String>? id,
      Value<String>? projectId,
      Value<String>? poNumber,
      Value<String>? supplierName,
      Value<String>? status,
      Value<double>? totalAmountEtb,
      Value<int>? version,
      Value<String?>? notes,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return CachedOrdersCompanion(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      poNumber: poNumber ?? this.poNumber,
      supplierName: supplierName ?? this.supplierName,
      status: status ?? this.status,
      totalAmountEtb: totalAmountEtb ?? this.totalAmountEtb,
      version: version ?? this.version,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<String>(projectId.value);
    }
    if (poNumber.present) {
      map['po_number'] = Variable<String>(poNumber.value);
    }
    if (supplierName.present) {
      map['supplier_name'] = Variable<String>(supplierName.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (totalAmountEtb.present) {
      map['total_amount_etb'] = Variable<double>(totalAmountEtb.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedOrdersCompanion(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('poNumber: $poNumber, ')
          ..write('supplierName: $supplierName, ')
          ..write('status: $status, ')
          ..write('totalAmountEtb: $totalAmountEtb, ')
          ..write('version: $version, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CachedReceiptsTable extends CachedReceipts
    with TableInfo<$CachedReceiptsTable, CachedReceipt> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedReceiptsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _receiptNumberMeta =
      const VerificationMeta('receiptNumber');
  @override
  late final GeneratedColumn<String> receiptNumber = GeneratedColumn<String>(
      'receipt_number', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _poIdMeta = const VerificationMeta('poId');
  @override
  late final GeneratedColumn<String> poId = GeneratedColumn<String>(
      'po_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _poNumberMeta =
      const VerificationMeta('poNumber');
  @override
  late final GeneratedColumn<String> poNumber = GeneratedColumn<String>(
      'po_number', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _projectIdMeta =
      const VerificationMeta('projectId');
  @override
  late final GeneratedColumn<String> projectId = GeneratedColumn<String>(
      'project_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _projectNameMeta =
      const VerificationMeta('projectName');
  @override
  late final GeneratedColumn<String> projectName = GeneratedColumn<String>(
      'project_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _supplierNameMeta =
      const VerificationMeta('supplierName');
  @override
  late final GeneratedColumn<String> supplierName = GeneratedColumn<String>(
      'supplier_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _waybillNumberMeta =
      const VerificationMeta('waybillNumber');
  @override
  late final GeneratedColumn<String> waybillNumber = GeneratedColumn<String>(
      'waybill_number', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _truckLicensePlateMeta =
      const VerificationMeta('truckLicensePlate');
  @override
  late final GeneratedColumn<String> truckLicensePlate =
      GeneratedColumn<String>('truck_license_plate', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _driverNameMeta =
      const VerificationMeta('driverName');
  @override
  late final GeneratedColumn<String> driverName = GeneratedColumn<String>(
      'driver_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _deliveryTimestampMeta =
      const VerificationMeta('deliveryTimestamp');
  @override
  late final GeneratedColumn<DateTime> deliveryTimestamp =
      GeneratedColumn<DateTime>('delivery_timestamp', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        receiptNumber,
        poId,
        poNumber,
        projectId,
        projectName,
        supplierName,
        waybillNumber,
        truckLicensePlate,
        driverName,
        status,
        notes,
        deliveryTimestamp
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_receipts';
  @override
  VerificationContext validateIntegrity(Insertable<CachedReceipt> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('receipt_number')) {
      context.handle(
          _receiptNumberMeta,
          receiptNumber.isAcceptableOrUnknown(
              data['receipt_number']!, _receiptNumberMeta));
    } else if (isInserting) {
      context.missing(_receiptNumberMeta);
    }
    if (data.containsKey('po_id')) {
      context.handle(
          _poIdMeta, poId.isAcceptableOrUnknown(data['po_id']!, _poIdMeta));
    } else if (isInserting) {
      context.missing(_poIdMeta);
    }
    if (data.containsKey('po_number')) {
      context.handle(_poNumberMeta,
          poNumber.isAcceptableOrUnknown(data['po_number']!, _poNumberMeta));
    } else if (isInserting) {
      context.missing(_poNumberMeta);
    }
    if (data.containsKey('project_id')) {
      context.handle(_projectIdMeta,
          projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta));
    } else if (isInserting) {
      context.missing(_projectIdMeta);
    }
    if (data.containsKey('project_name')) {
      context.handle(
          _projectNameMeta,
          projectName.isAcceptableOrUnknown(
              data['project_name']!, _projectNameMeta));
    } else if (isInserting) {
      context.missing(_projectNameMeta);
    }
    if (data.containsKey('supplier_name')) {
      context.handle(
          _supplierNameMeta,
          supplierName.isAcceptableOrUnknown(
              data['supplier_name']!, _supplierNameMeta));
    } else if (isInserting) {
      context.missing(_supplierNameMeta);
    }
    if (data.containsKey('waybill_number')) {
      context.handle(
          _waybillNumberMeta,
          waybillNumber.isAcceptableOrUnknown(
              data['waybill_number']!, _waybillNumberMeta));
    } else if (isInserting) {
      context.missing(_waybillNumberMeta);
    }
    if (data.containsKey('truck_license_plate')) {
      context.handle(
          _truckLicensePlateMeta,
          truckLicensePlate.isAcceptableOrUnknown(
              data['truck_license_plate']!, _truckLicensePlateMeta));
    } else if (isInserting) {
      context.missing(_truckLicensePlateMeta);
    }
    if (data.containsKey('driver_name')) {
      context.handle(
          _driverNameMeta,
          driverName.isAcceptableOrUnknown(
              data['driver_name']!, _driverNameMeta));
    } else if (isInserting) {
      context.missing(_driverNameMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('delivery_timestamp')) {
      context.handle(
          _deliveryTimestampMeta,
          deliveryTimestamp.isAcceptableOrUnknown(
              data['delivery_timestamp']!, _deliveryTimestampMeta));
    } else if (isInserting) {
      context.missing(_deliveryTimestampMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedReceipt map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedReceipt(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      receiptNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}receipt_number'])!,
      poId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}po_id'])!,
      poNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}po_number'])!,
      projectId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}project_id'])!,
      projectName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}project_name'])!,
      supplierName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}supplier_name'])!,
      waybillNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}waybill_number'])!,
      truckLicensePlate: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}truck_license_plate'])!,
      driverName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}driver_name'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      deliveryTimestamp: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}delivery_timestamp'])!,
    );
  }

  @override
  $CachedReceiptsTable createAlias(String alias) {
    return $CachedReceiptsTable(attachedDatabase, alias);
  }
}

class CachedReceipt extends DataClass implements Insertable<CachedReceipt> {
  final String id;
  final String receiptNumber;
  final String poId;
  final String poNumber;
  final String projectId;
  final String projectName;
  final String supplierName;
  final String waybillNumber;
  final String truckLicensePlate;
  final String driverName;
  final String status;
  final String? notes;
  final DateTime deliveryTimestamp;
  const CachedReceipt(
      {required this.id,
      required this.receiptNumber,
      required this.poId,
      required this.poNumber,
      required this.projectId,
      required this.projectName,
      required this.supplierName,
      required this.waybillNumber,
      required this.truckLicensePlate,
      required this.driverName,
      required this.status,
      this.notes,
      required this.deliveryTimestamp});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['receipt_number'] = Variable<String>(receiptNumber);
    map['po_id'] = Variable<String>(poId);
    map['po_number'] = Variable<String>(poNumber);
    map['project_id'] = Variable<String>(projectId);
    map['project_name'] = Variable<String>(projectName);
    map['supplier_name'] = Variable<String>(supplierName);
    map['waybill_number'] = Variable<String>(waybillNumber);
    map['truck_license_plate'] = Variable<String>(truckLicensePlate);
    map['driver_name'] = Variable<String>(driverName);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['delivery_timestamp'] = Variable<DateTime>(deliveryTimestamp);
    return map;
  }

  CachedReceiptsCompanion toCompanion(bool nullToAbsent) {
    return CachedReceiptsCompanion(
      id: Value(id),
      receiptNumber: Value(receiptNumber),
      poId: Value(poId),
      poNumber: Value(poNumber),
      projectId: Value(projectId),
      projectName: Value(projectName),
      supplierName: Value(supplierName),
      waybillNumber: Value(waybillNumber),
      truckLicensePlate: Value(truckLicensePlate),
      driverName: Value(driverName),
      status: Value(status),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      deliveryTimestamp: Value(deliveryTimestamp),
    );
  }

  factory CachedReceipt.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedReceipt(
      id: serializer.fromJson<String>(json['id']),
      receiptNumber: serializer.fromJson<String>(json['receiptNumber']),
      poId: serializer.fromJson<String>(json['poId']),
      poNumber: serializer.fromJson<String>(json['poNumber']),
      projectId: serializer.fromJson<String>(json['projectId']),
      projectName: serializer.fromJson<String>(json['projectName']),
      supplierName: serializer.fromJson<String>(json['supplierName']),
      waybillNumber: serializer.fromJson<String>(json['waybillNumber']),
      truckLicensePlate: serializer.fromJson<String>(json['truckLicensePlate']),
      driverName: serializer.fromJson<String>(json['driverName']),
      status: serializer.fromJson<String>(json['status']),
      notes: serializer.fromJson<String?>(json['notes']),
      deliveryTimestamp:
          serializer.fromJson<DateTime>(json['deliveryTimestamp']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'receiptNumber': serializer.toJson<String>(receiptNumber),
      'poId': serializer.toJson<String>(poId),
      'poNumber': serializer.toJson<String>(poNumber),
      'projectId': serializer.toJson<String>(projectId),
      'projectName': serializer.toJson<String>(projectName),
      'supplierName': serializer.toJson<String>(supplierName),
      'waybillNumber': serializer.toJson<String>(waybillNumber),
      'truckLicensePlate': serializer.toJson<String>(truckLicensePlate),
      'driverName': serializer.toJson<String>(driverName),
      'status': serializer.toJson<String>(status),
      'notes': serializer.toJson<String?>(notes),
      'deliveryTimestamp': serializer.toJson<DateTime>(deliveryTimestamp),
    };
  }

  CachedReceipt copyWith(
          {String? id,
          String? receiptNumber,
          String? poId,
          String? poNumber,
          String? projectId,
          String? projectName,
          String? supplierName,
          String? waybillNumber,
          String? truckLicensePlate,
          String? driverName,
          String? status,
          Value<String?> notes = const Value.absent(),
          DateTime? deliveryTimestamp}) =>
      CachedReceipt(
        id: id ?? this.id,
        receiptNumber: receiptNumber ?? this.receiptNumber,
        poId: poId ?? this.poId,
        poNumber: poNumber ?? this.poNumber,
        projectId: projectId ?? this.projectId,
        projectName: projectName ?? this.projectName,
        supplierName: supplierName ?? this.supplierName,
        waybillNumber: waybillNumber ?? this.waybillNumber,
        truckLicensePlate: truckLicensePlate ?? this.truckLicensePlate,
        driverName: driverName ?? this.driverName,
        status: status ?? this.status,
        notes: notes.present ? notes.value : this.notes,
        deliveryTimestamp: deliveryTimestamp ?? this.deliveryTimestamp,
      );
  CachedReceipt copyWithCompanion(CachedReceiptsCompanion data) {
    return CachedReceipt(
      id: data.id.present ? data.id.value : this.id,
      receiptNumber: data.receiptNumber.present
          ? data.receiptNumber.value
          : this.receiptNumber,
      poId: data.poId.present ? data.poId.value : this.poId,
      poNumber: data.poNumber.present ? data.poNumber.value : this.poNumber,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      projectName:
          data.projectName.present ? data.projectName.value : this.projectName,
      supplierName: data.supplierName.present
          ? data.supplierName.value
          : this.supplierName,
      waybillNumber: data.waybillNumber.present
          ? data.waybillNumber.value
          : this.waybillNumber,
      truckLicensePlate: data.truckLicensePlate.present
          ? data.truckLicensePlate.value
          : this.truckLicensePlate,
      driverName:
          data.driverName.present ? data.driverName.value : this.driverName,
      status: data.status.present ? data.status.value : this.status,
      notes: data.notes.present ? data.notes.value : this.notes,
      deliveryTimestamp: data.deliveryTimestamp.present
          ? data.deliveryTimestamp.value
          : this.deliveryTimestamp,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedReceipt(')
          ..write('id: $id, ')
          ..write('receiptNumber: $receiptNumber, ')
          ..write('poId: $poId, ')
          ..write('poNumber: $poNumber, ')
          ..write('projectId: $projectId, ')
          ..write('projectName: $projectName, ')
          ..write('supplierName: $supplierName, ')
          ..write('waybillNumber: $waybillNumber, ')
          ..write('truckLicensePlate: $truckLicensePlate, ')
          ..write('driverName: $driverName, ')
          ..write('status: $status, ')
          ..write('notes: $notes, ')
          ..write('deliveryTimestamp: $deliveryTimestamp')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      receiptNumber,
      poId,
      poNumber,
      projectId,
      projectName,
      supplierName,
      waybillNumber,
      truckLicensePlate,
      driverName,
      status,
      notes,
      deliveryTimestamp);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedReceipt &&
          other.id == this.id &&
          other.receiptNumber == this.receiptNumber &&
          other.poId == this.poId &&
          other.poNumber == this.poNumber &&
          other.projectId == this.projectId &&
          other.projectName == this.projectName &&
          other.supplierName == this.supplierName &&
          other.waybillNumber == this.waybillNumber &&
          other.truckLicensePlate == this.truckLicensePlate &&
          other.driverName == this.driverName &&
          other.status == this.status &&
          other.notes == this.notes &&
          other.deliveryTimestamp == this.deliveryTimestamp);
}

class CachedReceiptsCompanion extends UpdateCompanion<CachedReceipt> {
  final Value<String> id;
  final Value<String> receiptNumber;
  final Value<String> poId;
  final Value<String> poNumber;
  final Value<String> projectId;
  final Value<String> projectName;
  final Value<String> supplierName;
  final Value<String> waybillNumber;
  final Value<String> truckLicensePlate;
  final Value<String> driverName;
  final Value<String> status;
  final Value<String?> notes;
  final Value<DateTime> deliveryTimestamp;
  final Value<int> rowid;
  const CachedReceiptsCompanion({
    this.id = const Value.absent(),
    this.receiptNumber = const Value.absent(),
    this.poId = const Value.absent(),
    this.poNumber = const Value.absent(),
    this.projectId = const Value.absent(),
    this.projectName = const Value.absent(),
    this.supplierName = const Value.absent(),
    this.waybillNumber = const Value.absent(),
    this.truckLicensePlate = const Value.absent(),
    this.driverName = const Value.absent(),
    this.status = const Value.absent(),
    this.notes = const Value.absent(),
    this.deliveryTimestamp = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedReceiptsCompanion.insert({
    required String id,
    required String receiptNumber,
    required String poId,
    required String poNumber,
    required String projectId,
    required String projectName,
    required String supplierName,
    required String waybillNumber,
    required String truckLicensePlate,
    required String driverName,
    required String status,
    this.notes = const Value.absent(),
    required DateTime deliveryTimestamp,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        receiptNumber = Value(receiptNumber),
        poId = Value(poId),
        poNumber = Value(poNumber),
        projectId = Value(projectId),
        projectName = Value(projectName),
        supplierName = Value(supplierName),
        waybillNumber = Value(waybillNumber),
        truckLicensePlate = Value(truckLicensePlate),
        driverName = Value(driverName),
        status = Value(status),
        deliveryTimestamp = Value(deliveryTimestamp);
  static Insertable<CachedReceipt> custom({
    Expression<String>? id,
    Expression<String>? receiptNumber,
    Expression<String>? poId,
    Expression<String>? poNumber,
    Expression<String>? projectId,
    Expression<String>? projectName,
    Expression<String>? supplierName,
    Expression<String>? waybillNumber,
    Expression<String>? truckLicensePlate,
    Expression<String>? driverName,
    Expression<String>? status,
    Expression<String>? notes,
    Expression<DateTime>? deliveryTimestamp,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (receiptNumber != null) 'receipt_number': receiptNumber,
      if (poId != null) 'po_id': poId,
      if (poNumber != null) 'po_number': poNumber,
      if (projectId != null) 'project_id': projectId,
      if (projectName != null) 'project_name': projectName,
      if (supplierName != null) 'supplier_name': supplierName,
      if (waybillNumber != null) 'waybill_number': waybillNumber,
      if (truckLicensePlate != null) 'truck_license_plate': truckLicensePlate,
      if (driverName != null) 'driver_name': driverName,
      if (status != null) 'status': status,
      if (notes != null) 'notes': notes,
      if (deliveryTimestamp != null) 'delivery_timestamp': deliveryTimestamp,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedReceiptsCompanion copyWith(
      {Value<String>? id,
      Value<String>? receiptNumber,
      Value<String>? poId,
      Value<String>? poNumber,
      Value<String>? projectId,
      Value<String>? projectName,
      Value<String>? supplierName,
      Value<String>? waybillNumber,
      Value<String>? truckLicensePlate,
      Value<String>? driverName,
      Value<String>? status,
      Value<String?>? notes,
      Value<DateTime>? deliveryTimestamp,
      Value<int>? rowid}) {
    return CachedReceiptsCompanion(
      id: id ?? this.id,
      receiptNumber: receiptNumber ?? this.receiptNumber,
      poId: poId ?? this.poId,
      poNumber: poNumber ?? this.poNumber,
      projectId: projectId ?? this.projectId,
      projectName: projectName ?? this.projectName,
      supplierName: supplierName ?? this.supplierName,
      waybillNumber: waybillNumber ?? this.waybillNumber,
      truckLicensePlate: truckLicensePlate ?? this.truckLicensePlate,
      driverName: driverName ?? this.driverName,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      deliveryTimestamp: deliveryTimestamp ?? this.deliveryTimestamp,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (receiptNumber.present) {
      map['receipt_number'] = Variable<String>(receiptNumber.value);
    }
    if (poId.present) {
      map['po_id'] = Variable<String>(poId.value);
    }
    if (poNumber.present) {
      map['po_number'] = Variable<String>(poNumber.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<String>(projectId.value);
    }
    if (projectName.present) {
      map['project_name'] = Variable<String>(projectName.value);
    }
    if (supplierName.present) {
      map['supplier_name'] = Variable<String>(supplierName.value);
    }
    if (waybillNumber.present) {
      map['waybill_number'] = Variable<String>(waybillNumber.value);
    }
    if (truckLicensePlate.present) {
      map['truck_license_plate'] = Variable<String>(truckLicensePlate.value);
    }
    if (driverName.present) {
      map['driver_name'] = Variable<String>(driverName.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (deliveryTimestamp.present) {
      map['delivery_timestamp'] = Variable<DateTime>(deliveryTimestamp.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedReceiptsCompanion(')
          ..write('id: $id, ')
          ..write('receiptNumber: $receiptNumber, ')
          ..write('poId: $poId, ')
          ..write('poNumber: $poNumber, ')
          ..write('projectId: $projectId, ')
          ..write('projectName: $projectName, ')
          ..write('supplierName: $supplierName, ')
          ..write('waybillNumber: $waybillNumber, ')
          ..write('truckLicensePlate: $truckLicensePlate, ')
          ..write('driverName: $driverName, ')
          ..write('status: $status, ')
          ..write('notes: $notes, ')
          ..write('deliveryTimestamp: $deliveryTimestamp, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CachedDiscrepanciesTable extends CachedDiscrepancies
    with TableInfo<$CachedDiscrepanciesTable, CachedDiscrepancy> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedDiscrepanciesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _projectIdMeta =
      const VerificationMeta('projectId');
  @override
  late final GeneratedColumn<String> projectId = GeneratedColumn<String>(
      'project_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _projectNameMeta =
      const VerificationMeta('projectName');
  @override
  late final GeneratedColumn<String> projectName = GeneratedColumn<String>(
      'project_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _receiptIdMeta =
      const VerificationMeta('receiptId');
  @override
  late final GeneratedColumn<String> receiptId = GeneratedColumn<String>(
      'receipt_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _receiptNumberMeta =
      const VerificationMeta('receiptNumber');
  @override
  late final GeneratedColumn<String> receiptNumber = GeneratedColumn<String>(
      'receipt_number', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _materialNameMeta =
      const VerificationMeta('materialName');
  @override
  late final GeneratedColumn<String> materialName = GeneratedColumn<String>(
      'material_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _severityMeta =
      const VerificationMeta('severity');
  @override
  late final GeneratedColumn<String> severity = GeneratedColumn<String>(
      'severity', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _expectedQuantityMeta =
      const VerificationMeta('expectedQuantity');
  @override
  late final GeneratedColumn<double> expectedQuantity = GeneratedColumn<double>(
      'expected_quantity', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _actualQuantityMeta =
      const VerificationMeta('actualQuantity');
  @override
  late final GeneratedColumn<double> actualQuantity = GeneratedColumn<double>(
      'actual_quantity', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _varianceQuantityMeta =
      const VerificationMeta('varianceQuantity');
  @override
  late final GeneratedColumn<double> varianceQuantity = GeneratedColumn<double>(
      'variance_quantity', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _financialImpactEtbMeta =
      const VerificationMeta('financialImpactEtb');
  @override
  late final GeneratedColumn<double> financialImpactEtb =
      GeneratedColumn<double>('financial_impact_etb', aliasedName, false,
          type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _assignedToNameMeta =
      const VerificationMeta('assignedToName');
  @override
  late final GeneratedColumn<String> assignedToName = GeneratedColumn<String>(
      'assigned_to_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _resolutionNotesMeta =
      const VerificationMeta('resolutionNotes');
  @override
  late final GeneratedColumn<String> resolutionNotes = GeneratedColumn<String>(
      'resolution_notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        projectId,
        projectName,
        receiptId,
        receiptNumber,
        materialName,
        type,
        severity,
        status,
        expectedQuantity,
        actualQuantity,
        varianceQuantity,
        financialImpactEtb,
        description,
        assignedToName,
        resolutionNotes,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_discrepancies';
  @override
  VerificationContext validateIntegrity(Insertable<CachedDiscrepancy> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('project_id')) {
      context.handle(_projectIdMeta,
          projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta));
    } else if (isInserting) {
      context.missing(_projectIdMeta);
    }
    if (data.containsKey('project_name')) {
      context.handle(
          _projectNameMeta,
          projectName.isAcceptableOrUnknown(
              data['project_name']!, _projectNameMeta));
    } else if (isInserting) {
      context.missing(_projectNameMeta);
    }
    if (data.containsKey('receipt_id')) {
      context.handle(_receiptIdMeta,
          receiptId.isAcceptableOrUnknown(data['receipt_id']!, _receiptIdMeta));
    } else if (isInserting) {
      context.missing(_receiptIdMeta);
    }
    if (data.containsKey('receipt_number')) {
      context.handle(
          _receiptNumberMeta,
          receiptNumber.isAcceptableOrUnknown(
              data['receipt_number']!, _receiptNumberMeta));
    } else if (isInserting) {
      context.missing(_receiptNumberMeta);
    }
    if (data.containsKey('material_name')) {
      context.handle(
          _materialNameMeta,
          materialName.isAcceptableOrUnknown(
              data['material_name']!, _materialNameMeta));
    } else if (isInserting) {
      context.missing(_materialNameMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('severity')) {
      context.handle(_severityMeta,
          severity.isAcceptableOrUnknown(data['severity']!, _severityMeta));
    } else if (isInserting) {
      context.missing(_severityMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('expected_quantity')) {
      context.handle(
          _expectedQuantityMeta,
          expectedQuantity.isAcceptableOrUnknown(
              data['expected_quantity']!, _expectedQuantityMeta));
    } else if (isInserting) {
      context.missing(_expectedQuantityMeta);
    }
    if (data.containsKey('actual_quantity')) {
      context.handle(
          _actualQuantityMeta,
          actualQuantity.isAcceptableOrUnknown(
              data['actual_quantity']!, _actualQuantityMeta));
    } else if (isInserting) {
      context.missing(_actualQuantityMeta);
    }
    if (data.containsKey('variance_quantity')) {
      context.handle(
          _varianceQuantityMeta,
          varianceQuantity.isAcceptableOrUnknown(
              data['variance_quantity']!, _varianceQuantityMeta));
    } else if (isInserting) {
      context.missing(_varianceQuantityMeta);
    }
    if (data.containsKey('financial_impact_etb')) {
      context.handle(
          _financialImpactEtbMeta,
          financialImpactEtb.isAcceptableOrUnknown(
              data['financial_impact_etb']!, _financialImpactEtbMeta));
    } else if (isInserting) {
      context.missing(_financialImpactEtbMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('assigned_to_name')) {
      context.handle(
          _assignedToNameMeta,
          assignedToName.isAcceptableOrUnknown(
              data['assigned_to_name']!, _assignedToNameMeta));
    }
    if (data.containsKey('resolution_notes')) {
      context.handle(
          _resolutionNotesMeta,
          resolutionNotes.isAcceptableOrUnknown(
              data['resolution_notes']!, _resolutionNotesMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedDiscrepancy map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedDiscrepancy(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      projectId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}project_id'])!,
      projectName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}project_name'])!,
      receiptId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}receipt_id'])!,
      receiptNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}receipt_number'])!,
      materialName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}material_name'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      severity: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}severity'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      expectedQuantity: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}expected_quantity'])!,
      actualQuantity: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}actual_quantity'])!,
      varianceQuantity: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}variance_quantity'])!,
      financialImpactEtb: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}financial_impact_etb'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      assignedToName: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}assigned_to_name']),
      resolutionNotes: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}resolution_notes']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $CachedDiscrepanciesTable createAlias(String alias) {
    return $CachedDiscrepanciesTable(attachedDatabase, alias);
  }
}

class CachedDiscrepancy extends DataClass
    implements Insertable<CachedDiscrepancy> {
  final String id;
  final String projectId;
  final String projectName;
  final String receiptId;
  final String receiptNumber;
  final String materialName;
  final String type;
  final String severity;
  final String status;
  final double expectedQuantity;
  final double actualQuantity;
  final double varianceQuantity;
  final double financialImpactEtb;
  final String description;
  final String? assignedToName;
  final String? resolutionNotes;
  final DateTime createdAt;
  const CachedDiscrepancy(
      {required this.id,
      required this.projectId,
      required this.projectName,
      required this.receiptId,
      required this.receiptNumber,
      required this.materialName,
      required this.type,
      required this.severity,
      required this.status,
      required this.expectedQuantity,
      required this.actualQuantity,
      required this.varianceQuantity,
      required this.financialImpactEtb,
      required this.description,
      this.assignedToName,
      this.resolutionNotes,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['project_id'] = Variable<String>(projectId);
    map['project_name'] = Variable<String>(projectName);
    map['receipt_id'] = Variable<String>(receiptId);
    map['receipt_number'] = Variable<String>(receiptNumber);
    map['material_name'] = Variable<String>(materialName);
    map['type'] = Variable<String>(type);
    map['severity'] = Variable<String>(severity);
    map['status'] = Variable<String>(status);
    map['expected_quantity'] = Variable<double>(expectedQuantity);
    map['actual_quantity'] = Variable<double>(actualQuantity);
    map['variance_quantity'] = Variable<double>(varianceQuantity);
    map['financial_impact_etb'] = Variable<double>(financialImpactEtb);
    map['description'] = Variable<String>(description);
    if (!nullToAbsent || assignedToName != null) {
      map['assigned_to_name'] = Variable<String>(assignedToName);
    }
    if (!nullToAbsent || resolutionNotes != null) {
      map['resolution_notes'] = Variable<String>(resolutionNotes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CachedDiscrepanciesCompanion toCompanion(bool nullToAbsent) {
    return CachedDiscrepanciesCompanion(
      id: Value(id),
      projectId: Value(projectId),
      projectName: Value(projectName),
      receiptId: Value(receiptId),
      receiptNumber: Value(receiptNumber),
      materialName: Value(materialName),
      type: Value(type),
      severity: Value(severity),
      status: Value(status),
      expectedQuantity: Value(expectedQuantity),
      actualQuantity: Value(actualQuantity),
      varianceQuantity: Value(varianceQuantity),
      financialImpactEtb: Value(financialImpactEtb),
      description: Value(description),
      assignedToName: assignedToName == null && nullToAbsent
          ? const Value.absent()
          : Value(assignedToName),
      resolutionNotes: resolutionNotes == null && nullToAbsent
          ? const Value.absent()
          : Value(resolutionNotes),
      createdAt: Value(createdAt),
    );
  }

  factory CachedDiscrepancy.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedDiscrepancy(
      id: serializer.fromJson<String>(json['id']),
      projectId: serializer.fromJson<String>(json['projectId']),
      projectName: serializer.fromJson<String>(json['projectName']),
      receiptId: serializer.fromJson<String>(json['receiptId']),
      receiptNumber: serializer.fromJson<String>(json['receiptNumber']),
      materialName: serializer.fromJson<String>(json['materialName']),
      type: serializer.fromJson<String>(json['type']),
      severity: serializer.fromJson<String>(json['severity']),
      status: serializer.fromJson<String>(json['status']),
      expectedQuantity: serializer.fromJson<double>(json['expectedQuantity']),
      actualQuantity: serializer.fromJson<double>(json['actualQuantity']),
      varianceQuantity: serializer.fromJson<double>(json['varianceQuantity']),
      financialImpactEtb:
          serializer.fromJson<double>(json['financialImpactEtb']),
      description: serializer.fromJson<String>(json['description']),
      assignedToName: serializer.fromJson<String?>(json['assignedToName']),
      resolutionNotes: serializer.fromJson<String?>(json['resolutionNotes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'projectId': serializer.toJson<String>(projectId),
      'projectName': serializer.toJson<String>(projectName),
      'receiptId': serializer.toJson<String>(receiptId),
      'receiptNumber': serializer.toJson<String>(receiptNumber),
      'materialName': serializer.toJson<String>(materialName),
      'type': serializer.toJson<String>(type),
      'severity': serializer.toJson<String>(severity),
      'status': serializer.toJson<String>(status),
      'expectedQuantity': serializer.toJson<double>(expectedQuantity),
      'actualQuantity': serializer.toJson<double>(actualQuantity),
      'varianceQuantity': serializer.toJson<double>(varianceQuantity),
      'financialImpactEtb': serializer.toJson<double>(financialImpactEtb),
      'description': serializer.toJson<String>(description),
      'assignedToName': serializer.toJson<String?>(assignedToName),
      'resolutionNotes': serializer.toJson<String?>(resolutionNotes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  CachedDiscrepancy copyWith(
          {String? id,
          String? projectId,
          String? projectName,
          String? receiptId,
          String? receiptNumber,
          String? materialName,
          String? type,
          String? severity,
          String? status,
          double? expectedQuantity,
          double? actualQuantity,
          double? varianceQuantity,
          double? financialImpactEtb,
          String? description,
          Value<String?> assignedToName = const Value.absent(),
          Value<String?> resolutionNotes = const Value.absent(),
          DateTime? createdAt}) =>
      CachedDiscrepancy(
        id: id ?? this.id,
        projectId: projectId ?? this.projectId,
        projectName: projectName ?? this.projectName,
        receiptId: receiptId ?? this.receiptId,
        receiptNumber: receiptNumber ?? this.receiptNumber,
        materialName: materialName ?? this.materialName,
        type: type ?? this.type,
        severity: severity ?? this.severity,
        status: status ?? this.status,
        expectedQuantity: expectedQuantity ?? this.expectedQuantity,
        actualQuantity: actualQuantity ?? this.actualQuantity,
        varianceQuantity: varianceQuantity ?? this.varianceQuantity,
        financialImpactEtb: financialImpactEtb ?? this.financialImpactEtb,
        description: description ?? this.description,
        assignedToName:
            assignedToName.present ? assignedToName.value : this.assignedToName,
        resolutionNotes: resolutionNotes.present
            ? resolutionNotes.value
            : this.resolutionNotes,
        createdAt: createdAt ?? this.createdAt,
      );
  CachedDiscrepancy copyWithCompanion(CachedDiscrepanciesCompanion data) {
    return CachedDiscrepancy(
      id: data.id.present ? data.id.value : this.id,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      projectName:
          data.projectName.present ? data.projectName.value : this.projectName,
      receiptId: data.receiptId.present ? data.receiptId.value : this.receiptId,
      receiptNumber: data.receiptNumber.present
          ? data.receiptNumber.value
          : this.receiptNumber,
      materialName: data.materialName.present
          ? data.materialName.value
          : this.materialName,
      type: data.type.present ? data.type.value : this.type,
      severity: data.severity.present ? data.severity.value : this.severity,
      status: data.status.present ? data.status.value : this.status,
      expectedQuantity: data.expectedQuantity.present
          ? data.expectedQuantity.value
          : this.expectedQuantity,
      actualQuantity: data.actualQuantity.present
          ? data.actualQuantity.value
          : this.actualQuantity,
      varianceQuantity: data.varianceQuantity.present
          ? data.varianceQuantity.value
          : this.varianceQuantity,
      financialImpactEtb: data.financialImpactEtb.present
          ? data.financialImpactEtb.value
          : this.financialImpactEtb,
      description:
          data.description.present ? data.description.value : this.description,
      assignedToName: data.assignedToName.present
          ? data.assignedToName.value
          : this.assignedToName,
      resolutionNotes: data.resolutionNotes.present
          ? data.resolutionNotes.value
          : this.resolutionNotes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedDiscrepancy(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('projectName: $projectName, ')
          ..write('receiptId: $receiptId, ')
          ..write('receiptNumber: $receiptNumber, ')
          ..write('materialName: $materialName, ')
          ..write('type: $type, ')
          ..write('severity: $severity, ')
          ..write('status: $status, ')
          ..write('expectedQuantity: $expectedQuantity, ')
          ..write('actualQuantity: $actualQuantity, ')
          ..write('varianceQuantity: $varianceQuantity, ')
          ..write('financialImpactEtb: $financialImpactEtb, ')
          ..write('description: $description, ')
          ..write('assignedToName: $assignedToName, ')
          ..write('resolutionNotes: $resolutionNotes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      projectId,
      projectName,
      receiptId,
      receiptNumber,
      materialName,
      type,
      severity,
      status,
      expectedQuantity,
      actualQuantity,
      varianceQuantity,
      financialImpactEtb,
      description,
      assignedToName,
      resolutionNotes,
      createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedDiscrepancy &&
          other.id == this.id &&
          other.projectId == this.projectId &&
          other.projectName == this.projectName &&
          other.receiptId == this.receiptId &&
          other.receiptNumber == this.receiptNumber &&
          other.materialName == this.materialName &&
          other.type == this.type &&
          other.severity == this.severity &&
          other.status == this.status &&
          other.expectedQuantity == this.expectedQuantity &&
          other.actualQuantity == this.actualQuantity &&
          other.varianceQuantity == this.varianceQuantity &&
          other.financialImpactEtb == this.financialImpactEtb &&
          other.description == this.description &&
          other.assignedToName == this.assignedToName &&
          other.resolutionNotes == this.resolutionNotes &&
          other.createdAt == this.createdAt);
}

class CachedDiscrepanciesCompanion extends UpdateCompanion<CachedDiscrepancy> {
  final Value<String> id;
  final Value<String> projectId;
  final Value<String> projectName;
  final Value<String> receiptId;
  final Value<String> receiptNumber;
  final Value<String> materialName;
  final Value<String> type;
  final Value<String> severity;
  final Value<String> status;
  final Value<double> expectedQuantity;
  final Value<double> actualQuantity;
  final Value<double> varianceQuantity;
  final Value<double> financialImpactEtb;
  final Value<String> description;
  final Value<String?> assignedToName;
  final Value<String?> resolutionNotes;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const CachedDiscrepanciesCompanion({
    this.id = const Value.absent(),
    this.projectId = const Value.absent(),
    this.projectName = const Value.absent(),
    this.receiptId = const Value.absent(),
    this.receiptNumber = const Value.absent(),
    this.materialName = const Value.absent(),
    this.type = const Value.absent(),
    this.severity = const Value.absent(),
    this.status = const Value.absent(),
    this.expectedQuantity = const Value.absent(),
    this.actualQuantity = const Value.absent(),
    this.varianceQuantity = const Value.absent(),
    this.financialImpactEtb = const Value.absent(),
    this.description = const Value.absent(),
    this.assignedToName = const Value.absent(),
    this.resolutionNotes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedDiscrepanciesCompanion.insert({
    required String id,
    required String projectId,
    required String projectName,
    required String receiptId,
    required String receiptNumber,
    required String materialName,
    required String type,
    required String severity,
    required String status,
    required double expectedQuantity,
    required double actualQuantity,
    required double varianceQuantity,
    required double financialImpactEtb,
    required String description,
    this.assignedToName = const Value.absent(),
    this.resolutionNotes = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        projectId = Value(projectId),
        projectName = Value(projectName),
        receiptId = Value(receiptId),
        receiptNumber = Value(receiptNumber),
        materialName = Value(materialName),
        type = Value(type),
        severity = Value(severity),
        status = Value(status),
        expectedQuantity = Value(expectedQuantity),
        actualQuantity = Value(actualQuantity),
        varianceQuantity = Value(varianceQuantity),
        financialImpactEtb = Value(financialImpactEtb),
        description = Value(description),
        createdAt = Value(createdAt);
  static Insertable<CachedDiscrepancy> custom({
    Expression<String>? id,
    Expression<String>? projectId,
    Expression<String>? projectName,
    Expression<String>? receiptId,
    Expression<String>? receiptNumber,
    Expression<String>? materialName,
    Expression<String>? type,
    Expression<String>? severity,
    Expression<String>? status,
    Expression<double>? expectedQuantity,
    Expression<double>? actualQuantity,
    Expression<double>? varianceQuantity,
    Expression<double>? financialImpactEtb,
    Expression<String>? description,
    Expression<String>? assignedToName,
    Expression<String>? resolutionNotes,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (projectId != null) 'project_id': projectId,
      if (projectName != null) 'project_name': projectName,
      if (receiptId != null) 'receipt_id': receiptId,
      if (receiptNumber != null) 'receipt_number': receiptNumber,
      if (materialName != null) 'material_name': materialName,
      if (type != null) 'type': type,
      if (severity != null) 'severity': severity,
      if (status != null) 'status': status,
      if (expectedQuantity != null) 'expected_quantity': expectedQuantity,
      if (actualQuantity != null) 'actual_quantity': actualQuantity,
      if (varianceQuantity != null) 'variance_quantity': varianceQuantity,
      if (financialImpactEtb != null)
        'financial_impact_etb': financialImpactEtb,
      if (description != null) 'description': description,
      if (assignedToName != null) 'assigned_to_name': assignedToName,
      if (resolutionNotes != null) 'resolution_notes': resolutionNotes,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedDiscrepanciesCompanion copyWith(
      {Value<String>? id,
      Value<String>? projectId,
      Value<String>? projectName,
      Value<String>? receiptId,
      Value<String>? receiptNumber,
      Value<String>? materialName,
      Value<String>? type,
      Value<String>? severity,
      Value<String>? status,
      Value<double>? expectedQuantity,
      Value<double>? actualQuantity,
      Value<double>? varianceQuantity,
      Value<double>? financialImpactEtb,
      Value<String>? description,
      Value<String?>? assignedToName,
      Value<String?>? resolutionNotes,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return CachedDiscrepanciesCompanion(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      projectName: projectName ?? this.projectName,
      receiptId: receiptId ?? this.receiptId,
      receiptNumber: receiptNumber ?? this.receiptNumber,
      materialName: materialName ?? this.materialName,
      type: type ?? this.type,
      severity: severity ?? this.severity,
      status: status ?? this.status,
      expectedQuantity: expectedQuantity ?? this.expectedQuantity,
      actualQuantity: actualQuantity ?? this.actualQuantity,
      varianceQuantity: varianceQuantity ?? this.varianceQuantity,
      financialImpactEtb: financialImpactEtb ?? this.financialImpactEtb,
      description: description ?? this.description,
      assignedToName: assignedToName ?? this.assignedToName,
      resolutionNotes: resolutionNotes ?? this.resolutionNotes,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<String>(projectId.value);
    }
    if (projectName.present) {
      map['project_name'] = Variable<String>(projectName.value);
    }
    if (receiptId.present) {
      map['receipt_id'] = Variable<String>(receiptId.value);
    }
    if (receiptNumber.present) {
      map['receipt_number'] = Variable<String>(receiptNumber.value);
    }
    if (materialName.present) {
      map['material_name'] = Variable<String>(materialName.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (severity.present) {
      map['severity'] = Variable<String>(severity.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (expectedQuantity.present) {
      map['expected_quantity'] = Variable<double>(expectedQuantity.value);
    }
    if (actualQuantity.present) {
      map['actual_quantity'] = Variable<double>(actualQuantity.value);
    }
    if (varianceQuantity.present) {
      map['variance_quantity'] = Variable<double>(varianceQuantity.value);
    }
    if (financialImpactEtb.present) {
      map['financial_impact_etb'] = Variable<double>(financialImpactEtb.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (assignedToName.present) {
      map['assigned_to_name'] = Variable<String>(assignedToName.value);
    }
    if (resolutionNotes.present) {
      map['resolution_notes'] = Variable<String>(resolutionNotes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedDiscrepanciesCompanion(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('projectName: $projectName, ')
          ..write('receiptId: $receiptId, ')
          ..write('receiptNumber: $receiptNumber, ')
          ..write('materialName: $materialName, ')
          ..write('type: $type, ')
          ..write('severity: $severity, ')
          ..write('status: $status, ')
          ..write('expectedQuantity: $expectedQuantity, ')
          ..write('actualQuantity: $actualQuantity, ')
          ..write('varianceQuantity: $varianceQuantity, ')
          ..write('financialImpactEtb: $financialImpactEtb, ')
          ..write('description: $description, ')
          ..write('assignedToName: $assignedToName, ')
          ..write('resolutionNotes: $resolutionNotes, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncOutboxTable extends SyncOutbox
    with TableInfo<$SyncOutboxTable, SyncOutboxData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncOutboxTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _idempotencyKeyMeta =
      const VerificationMeta('idempotencyKey');
  @override
  late final GeneratedColumn<String> idempotencyKey = GeneratedColumn<String>(
      'idempotency_key', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _actionTypeMeta =
      const VerificationMeta('actionType');
  @override
  late final GeneratedColumn<String> actionType = GeneratedColumn<String>(
      'action_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _payloadJsonMeta =
      const VerificationMeta('payloadJson');
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
      'payload_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('PENDING'));
  static const VerificationMeta _errorMessageMeta =
      const VerificationMeta('errorMessage');
  @override
  late final GeneratedColumn<String> errorMessage = GeneratedColumn<String>(
      'error_message', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _retryCountMeta =
      const VerificationMeta('retryCount');
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
      'retry_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _lastAttemptAtMeta =
      const VerificationMeta('lastAttemptAt');
  @override
  late final GeneratedColumn<DateTime> lastAttemptAt =
      GeneratedColumn<DateTime>('last_attempt_at', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        idempotencyKey,
        actionType,
        payloadJson,
        syncStatus,
        errorMessage,
        retryCount,
        createdAt,
        lastAttemptAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_outbox';
  @override
  VerificationContext validateIntegrity(Insertable<SyncOutboxData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('idempotency_key')) {
      context.handle(
          _idempotencyKeyMeta,
          idempotencyKey.isAcceptableOrUnknown(
              data['idempotency_key']!, _idempotencyKeyMeta));
    } else if (isInserting) {
      context.missing(_idempotencyKeyMeta);
    }
    if (data.containsKey('action_type')) {
      context.handle(
          _actionTypeMeta,
          actionType.isAcceptableOrUnknown(
              data['action_type']!, _actionTypeMeta));
    } else if (isInserting) {
      context.missing(_actionTypeMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
          _payloadJsonMeta,
          payloadJson.isAcceptableOrUnknown(
              data['payload_json']!, _payloadJsonMeta));
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    if (data.containsKey('error_message')) {
      context.handle(
          _errorMessageMeta,
          errorMessage.isAcceptableOrUnknown(
              data['error_message']!, _errorMessageMeta));
    }
    if (data.containsKey('retry_count')) {
      context.handle(
          _retryCountMeta,
          retryCount.isAcceptableOrUnknown(
              data['retry_count']!, _retryCountMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('last_attempt_at')) {
      context.handle(
          _lastAttemptAtMeta,
          lastAttemptAt.isAcceptableOrUnknown(
              data['last_attempt_at']!, _lastAttemptAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncOutboxData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncOutboxData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      idempotencyKey: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}idempotency_key'])!,
      actionType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}action_type'])!,
      payloadJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload_json'])!,
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
      errorMessage: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}error_message']),
      retryCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}retry_count'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      lastAttemptAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_attempt_at']),
    );
  }

  @override
  $SyncOutboxTable createAlias(String alias) {
    return $SyncOutboxTable(attachedDatabase, alias);
  }
}

class SyncOutboxData extends DataClass implements Insertable<SyncOutboxData> {
  final int id;
  final String idempotencyKey;
  final String actionType;
  final String payloadJson;
  final String syncStatus;
  final String? errorMessage;
  final int retryCount;
  final DateTime createdAt;
  final DateTime? lastAttemptAt;
  const SyncOutboxData(
      {required this.id,
      required this.idempotencyKey,
      required this.actionType,
      required this.payloadJson,
      required this.syncStatus,
      this.errorMessage,
      required this.retryCount,
      required this.createdAt,
      this.lastAttemptAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['idempotency_key'] = Variable<String>(idempotencyKey);
    map['action_type'] = Variable<String>(actionType);
    map['payload_json'] = Variable<String>(payloadJson);
    map['sync_status'] = Variable<String>(syncStatus);
    if (!nullToAbsent || errorMessage != null) {
      map['error_message'] = Variable<String>(errorMessage);
    }
    map['retry_count'] = Variable<int>(retryCount);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || lastAttemptAt != null) {
      map['last_attempt_at'] = Variable<DateTime>(lastAttemptAt);
    }
    return map;
  }

  SyncOutboxCompanion toCompanion(bool nullToAbsent) {
    return SyncOutboxCompanion(
      id: Value(id),
      idempotencyKey: Value(idempotencyKey),
      actionType: Value(actionType),
      payloadJson: Value(payloadJson),
      syncStatus: Value(syncStatus),
      errorMessage: errorMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(errorMessage),
      retryCount: Value(retryCount),
      createdAt: Value(createdAt),
      lastAttemptAt: lastAttemptAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastAttemptAt),
    );
  }

  factory SyncOutboxData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncOutboxData(
      id: serializer.fromJson<int>(json['id']),
      idempotencyKey: serializer.fromJson<String>(json['idempotencyKey']),
      actionType: serializer.fromJson<String>(json['actionType']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      errorMessage: serializer.fromJson<String?>(json['errorMessage']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      lastAttemptAt: serializer.fromJson<DateTime?>(json['lastAttemptAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'idempotencyKey': serializer.toJson<String>(idempotencyKey),
      'actionType': serializer.toJson<String>(actionType),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'errorMessage': serializer.toJson<String?>(errorMessage),
      'retryCount': serializer.toJson<int>(retryCount),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'lastAttemptAt': serializer.toJson<DateTime?>(lastAttemptAt),
    };
  }

  SyncOutboxData copyWith(
          {int? id,
          String? idempotencyKey,
          String? actionType,
          String? payloadJson,
          String? syncStatus,
          Value<String?> errorMessage = const Value.absent(),
          int? retryCount,
          DateTime? createdAt,
          Value<DateTime?> lastAttemptAt = const Value.absent()}) =>
      SyncOutboxData(
        id: id ?? this.id,
        idempotencyKey: idempotencyKey ?? this.idempotencyKey,
        actionType: actionType ?? this.actionType,
        payloadJson: payloadJson ?? this.payloadJson,
        syncStatus: syncStatus ?? this.syncStatus,
        errorMessage:
            errorMessage.present ? errorMessage.value : this.errorMessage,
        retryCount: retryCount ?? this.retryCount,
        createdAt: createdAt ?? this.createdAt,
        lastAttemptAt:
            lastAttemptAt.present ? lastAttemptAt.value : this.lastAttemptAt,
      );
  SyncOutboxData copyWithCompanion(SyncOutboxCompanion data) {
    return SyncOutboxData(
      id: data.id.present ? data.id.value : this.id,
      idempotencyKey: data.idempotencyKey.present
          ? data.idempotencyKey.value
          : this.idempotencyKey,
      actionType:
          data.actionType.present ? data.actionType.value : this.actionType,
      payloadJson:
          data.payloadJson.present ? data.payloadJson.value : this.payloadJson,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
      errorMessage: data.errorMessage.present
          ? data.errorMessage.value
          : this.errorMessage,
      retryCount:
          data.retryCount.present ? data.retryCount.value : this.retryCount,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      lastAttemptAt: data.lastAttemptAt.present
          ? data.lastAttemptAt.value
          : this.lastAttemptAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncOutboxData(')
          ..write('id: $id, ')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('actionType: $actionType, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('retryCount: $retryCount, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastAttemptAt: $lastAttemptAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, idempotencyKey, actionType, payloadJson,
      syncStatus, errorMessage, retryCount, createdAt, lastAttemptAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncOutboxData &&
          other.id == this.id &&
          other.idempotencyKey == this.idempotencyKey &&
          other.actionType == this.actionType &&
          other.payloadJson == this.payloadJson &&
          other.syncStatus == this.syncStatus &&
          other.errorMessage == this.errorMessage &&
          other.retryCount == this.retryCount &&
          other.createdAt == this.createdAt &&
          other.lastAttemptAt == this.lastAttemptAt);
}

class SyncOutboxCompanion extends UpdateCompanion<SyncOutboxData> {
  final Value<int> id;
  final Value<String> idempotencyKey;
  final Value<String> actionType;
  final Value<String> payloadJson;
  final Value<String> syncStatus;
  final Value<String?> errorMessage;
  final Value<int> retryCount;
  final Value<DateTime> createdAt;
  final Value<DateTime?> lastAttemptAt;
  const SyncOutboxCompanion({
    this.id = const Value.absent(),
    this.idempotencyKey = const Value.absent(),
    this.actionType = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.errorMessage = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastAttemptAt = const Value.absent(),
  });
  SyncOutboxCompanion.insert({
    this.id = const Value.absent(),
    required String idempotencyKey,
    required String actionType,
    required String payloadJson,
    this.syncStatus = const Value.absent(),
    this.errorMessage = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastAttemptAt = const Value.absent(),
  })  : idempotencyKey = Value(idempotencyKey),
        actionType = Value(actionType),
        payloadJson = Value(payloadJson);
  static Insertable<SyncOutboxData> custom({
    Expression<int>? id,
    Expression<String>? idempotencyKey,
    Expression<String>? actionType,
    Expression<String>? payloadJson,
    Expression<String>? syncStatus,
    Expression<String>? errorMessage,
    Expression<int>? retryCount,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? lastAttemptAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (idempotencyKey != null) 'idempotency_key': idempotencyKey,
      if (actionType != null) 'action_type': actionType,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (errorMessage != null) 'error_message': errorMessage,
      if (retryCount != null) 'retry_count': retryCount,
      if (createdAt != null) 'created_at': createdAt,
      if (lastAttemptAt != null) 'last_attempt_at': lastAttemptAt,
    });
  }

  SyncOutboxCompanion copyWith(
      {Value<int>? id,
      Value<String>? idempotencyKey,
      Value<String>? actionType,
      Value<String>? payloadJson,
      Value<String>? syncStatus,
      Value<String?>? errorMessage,
      Value<int>? retryCount,
      Value<DateTime>? createdAt,
      Value<DateTime?>? lastAttemptAt}) {
    return SyncOutboxCompanion(
      id: id ?? this.id,
      idempotencyKey: idempotencyKey ?? this.idempotencyKey,
      actionType: actionType ?? this.actionType,
      payloadJson: payloadJson ?? this.payloadJson,
      syncStatus: syncStatus ?? this.syncStatus,
      errorMessage: errorMessage ?? this.errorMessage,
      retryCount: retryCount ?? this.retryCount,
      createdAt: createdAt ?? this.createdAt,
      lastAttemptAt: lastAttemptAt ?? this.lastAttemptAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (idempotencyKey.present) {
      map['idempotency_key'] = Variable<String>(idempotencyKey.value);
    }
    if (actionType.present) {
      map['action_type'] = Variable<String>(actionType.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (errorMessage.present) {
      map['error_message'] = Variable<String>(errorMessage.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (lastAttemptAt.present) {
      map['last_attempt_at'] = Variable<DateTime>(lastAttemptAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncOutboxCompanion(')
          ..write('id: $id, ')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('actionType: $actionType, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('retryCount: $retryCount, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastAttemptAt: $lastAttemptAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CachedProjectsTable cachedProjects = $CachedProjectsTable(this);
  late final $CachedOrdersTable cachedOrders = $CachedOrdersTable(this);
  late final $CachedReceiptsTable cachedReceipts = $CachedReceiptsTable(this);
  late final $CachedDiscrepanciesTable cachedDiscrepancies =
      $CachedDiscrepanciesTable(this);
  late final $SyncOutboxTable syncOutbox = $SyncOutboxTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        cachedProjects,
        cachedOrders,
        cachedReceipts,
        cachedDiscrepancies,
        syncOutbox
      ];
}

typedef $$CachedProjectsTableCreateCompanionBuilder = CachedProjectsCompanion
    Function({
  required String id,
  required String code,
  required String name,
  required String location,
  Value<String> status,
  Value<double> budgetEtb,
  Value<int> rowid,
});
typedef $$CachedProjectsTableUpdateCompanionBuilder = CachedProjectsCompanion
    Function({
  Value<String> id,
  Value<String> code,
  Value<String> name,
  Value<String> location,
  Value<String> status,
  Value<double> budgetEtb,
  Value<int> rowid,
});

class $$CachedProjectsTableFilterComposer
    extends Composer<_$AppDatabase, $CachedProjectsTable> {
  $$CachedProjectsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get code => $composableBuilder(
      column: $table.code, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get location => $composableBuilder(
      column: $table.location, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get budgetEtb => $composableBuilder(
      column: $table.budgetEtb, builder: (column) => ColumnFilters(column));
}

class $$CachedProjectsTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedProjectsTable> {
  $$CachedProjectsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get code => $composableBuilder(
      column: $table.code, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get location => $composableBuilder(
      column: $table.location, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get budgetEtb => $composableBuilder(
      column: $table.budgetEtb, builder: (column) => ColumnOrderings(column));
}

class $$CachedProjectsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedProjectsTable> {
  $$CachedProjectsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<double> get budgetEtb =>
      $composableBuilder(column: $table.budgetEtb, builder: (column) => column);
}

class $$CachedProjectsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CachedProjectsTable,
    CachedProject,
    $$CachedProjectsTableFilterComposer,
    $$CachedProjectsTableOrderingComposer,
    $$CachedProjectsTableAnnotationComposer,
    $$CachedProjectsTableCreateCompanionBuilder,
    $$CachedProjectsTableUpdateCompanionBuilder,
    (
      CachedProject,
      BaseReferences<_$AppDatabase, $CachedProjectsTable, CachedProject>
    ),
    CachedProject,
    PrefetchHooks Function()> {
  $$CachedProjectsTableTableManager(
      _$AppDatabase db, $CachedProjectsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedProjectsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedProjectsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedProjectsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> code = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> location = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<double> budgetEtb = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CachedProjectsCompanion(
            id: id,
            code: code,
            name: name,
            location: location,
            status: status,
            budgetEtb: budgetEtb,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String code,
            required String name,
            required String location,
            Value<String> status = const Value.absent(),
            Value<double> budgetEtb = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CachedProjectsCompanion.insert(
            id: id,
            code: code,
            name: name,
            location: location,
            status: status,
            budgetEtb: budgetEtb,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CachedProjectsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CachedProjectsTable,
    CachedProject,
    $$CachedProjectsTableFilterComposer,
    $$CachedProjectsTableOrderingComposer,
    $$CachedProjectsTableAnnotationComposer,
    $$CachedProjectsTableCreateCompanionBuilder,
    $$CachedProjectsTableUpdateCompanionBuilder,
    (
      CachedProject,
      BaseReferences<_$AppDatabase, $CachedProjectsTable, CachedProject>
    ),
    CachedProject,
    PrefetchHooks Function()>;
typedef $$CachedOrdersTableCreateCompanionBuilder = CachedOrdersCompanion
    Function({
  required String id,
  required String projectId,
  required String poNumber,
  required String supplierName,
  required String status,
  required double totalAmountEtb,
  Value<int> version,
  Value<String?> notes,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$CachedOrdersTableUpdateCompanionBuilder = CachedOrdersCompanion
    Function({
  Value<String> id,
  Value<String> projectId,
  Value<String> poNumber,
  Value<String> supplierName,
  Value<String> status,
  Value<double> totalAmountEtb,
  Value<int> version,
  Value<String?> notes,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$CachedOrdersTableFilterComposer
    extends Composer<_$AppDatabase, $CachedOrdersTable> {
  $$CachedOrdersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get projectId => $composableBuilder(
      column: $table.projectId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get poNumber => $composableBuilder(
      column: $table.poNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get supplierName => $composableBuilder(
      column: $table.supplierName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get totalAmountEtb => $composableBuilder(
      column: $table.totalAmountEtb,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$CachedOrdersTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedOrdersTable> {
  $$CachedOrdersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get projectId => $composableBuilder(
      column: $table.projectId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get poNumber => $composableBuilder(
      column: $table.poNumber, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get supplierName => $composableBuilder(
      column: $table.supplierName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get totalAmountEtb => $composableBuilder(
      column: $table.totalAmountEtb,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$CachedOrdersTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedOrdersTable> {
  $$CachedOrdersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get projectId =>
      $composableBuilder(column: $table.projectId, builder: (column) => column);

  GeneratedColumn<String> get poNumber =>
      $composableBuilder(column: $table.poNumber, builder: (column) => column);

  GeneratedColumn<String> get supplierName => $composableBuilder(
      column: $table.supplierName, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<double> get totalAmountEtb => $composableBuilder(
      column: $table.totalAmountEtb, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$CachedOrdersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CachedOrdersTable,
    CachedOrder,
    $$CachedOrdersTableFilterComposer,
    $$CachedOrdersTableOrderingComposer,
    $$CachedOrdersTableAnnotationComposer,
    $$CachedOrdersTableCreateCompanionBuilder,
    $$CachedOrdersTableUpdateCompanionBuilder,
    (
      CachedOrder,
      BaseReferences<_$AppDatabase, $CachedOrdersTable, CachedOrder>
    ),
    CachedOrder,
    PrefetchHooks Function()> {
  $$CachedOrdersTableTableManager(_$AppDatabase db, $CachedOrdersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedOrdersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedOrdersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedOrdersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> projectId = const Value.absent(),
            Value<String> poNumber = const Value.absent(),
            Value<String> supplierName = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<double> totalAmountEtb = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CachedOrdersCompanion(
            id: id,
            projectId: projectId,
            poNumber: poNumber,
            supplierName: supplierName,
            status: status,
            totalAmountEtb: totalAmountEtb,
            version: version,
            notes: notes,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String projectId,
            required String poNumber,
            required String supplierName,
            required String status,
            required double totalAmountEtb,
            Value<int> version = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              CachedOrdersCompanion.insert(
            id: id,
            projectId: projectId,
            poNumber: poNumber,
            supplierName: supplierName,
            status: status,
            totalAmountEtb: totalAmountEtb,
            version: version,
            notes: notes,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CachedOrdersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CachedOrdersTable,
    CachedOrder,
    $$CachedOrdersTableFilterComposer,
    $$CachedOrdersTableOrderingComposer,
    $$CachedOrdersTableAnnotationComposer,
    $$CachedOrdersTableCreateCompanionBuilder,
    $$CachedOrdersTableUpdateCompanionBuilder,
    (
      CachedOrder,
      BaseReferences<_$AppDatabase, $CachedOrdersTable, CachedOrder>
    ),
    CachedOrder,
    PrefetchHooks Function()>;
typedef $$CachedReceiptsTableCreateCompanionBuilder = CachedReceiptsCompanion
    Function({
  required String id,
  required String receiptNumber,
  required String poId,
  required String poNumber,
  required String projectId,
  required String projectName,
  required String supplierName,
  required String waybillNumber,
  required String truckLicensePlate,
  required String driverName,
  required String status,
  Value<String?> notes,
  required DateTime deliveryTimestamp,
  Value<int> rowid,
});
typedef $$CachedReceiptsTableUpdateCompanionBuilder = CachedReceiptsCompanion
    Function({
  Value<String> id,
  Value<String> receiptNumber,
  Value<String> poId,
  Value<String> poNumber,
  Value<String> projectId,
  Value<String> projectName,
  Value<String> supplierName,
  Value<String> waybillNumber,
  Value<String> truckLicensePlate,
  Value<String> driverName,
  Value<String> status,
  Value<String?> notes,
  Value<DateTime> deliveryTimestamp,
  Value<int> rowid,
});

class $$CachedReceiptsTableFilterComposer
    extends Composer<_$AppDatabase, $CachedReceiptsTable> {
  $$CachedReceiptsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get receiptNumber => $composableBuilder(
      column: $table.receiptNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get poId => $composableBuilder(
      column: $table.poId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get poNumber => $composableBuilder(
      column: $table.poNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get projectId => $composableBuilder(
      column: $table.projectId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get projectName => $composableBuilder(
      column: $table.projectName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get supplierName => $composableBuilder(
      column: $table.supplierName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get waybillNumber => $composableBuilder(
      column: $table.waybillNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get truckLicensePlate => $composableBuilder(
      column: $table.truckLicensePlate,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get driverName => $composableBuilder(
      column: $table.driverName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deliveryTimestamp => $composableBuilder(
      column: $table.deliveryTimestamp,
      builder: (column) => ColumnFilters(column));
}

class $$CachedReceiptsTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedReceiptsTable> {
  $$CachedReceiptsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get receiptNumber => $composableBuilder(
      column: $table.receiptNumber,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get poId => $composableBuilder(
      column: $table.poId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get poNumber => $composableBuilder(
      column: $table.poNumber, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get projectId => $composableBuilder(
      column: $table.projectId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get projectName => $composableBuilder(
      column: $table.projectName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get supplierName => $composableBuilder(
      column: $table.supplierName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get waybillNumber => $composableBuilder(
      column: $table.waybillNumber,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get truckLicensePlate => $composableBuilder(
      column: $table.truckLicensePlate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get driverName => $composableBuilder(
      column: $table.driverName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deliveryTimestamp => $composableBuilder(
      column: $table.deliveryTimestamp,
      builder: (column) => ColumnOrderings(column));
}

class $$CachedReceiptsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedReceiptsTable> {
  $$CachedReceiptsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get receiptNumber => $composableBuilder(
      column: $table.receiptNumber, builder: (column) => column);

  GeneratedColumn<String> get poId =>
      $composableBuilder(column: $table.poId, builder: (column) => column);

  GeneratedColumn<String> get poNumber =>
      $composableBuilder(column: $table.poNumber, builder: (column) => column);

  GeneratedColumn<String> get projectId =>
      $composableBuilder(column: $table.projectId, builder: (column) => column);

  GeneratedColumn<String> get projectName => $composableBuilder(
      column: $table.projectName, builder: (column) => column);

  GeneratedColumn<String> get supplierName => $composableBuilder(
      column: $table.supplierName, builder: (column) => column);

  GeneratedColumn<String> get waybillNumber => $composableBuilder(
      column: $table.waybillNumber, builder: (column) => column);

  GeneratedColumn<String> get truckLicensePlate => $composableBuilder(
      column: $table.truckLicensePlate, builder: (column) => column);

  GeneratedColumn<String> get driverName => $composableBuilder(
      column: $table.driverName, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get deliveryTimestamp => $composableBuilder(
      column: $table.deliveryTimestamp, builder: (column) => column);
}

class $$CachedReceiptsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CachedReceiptsTable,
    CachedReceipt,
    $$CachedReceiptsTableFilterComposer,
    $$CachedReceiptsTableOrderingComposer,
    $$CachedReceiptsTableAnnotationComposer,
    $$CachedReceiptsTableCreateCompanionBuilder,
    $$CachedReceiptsTableUpdateCompanionBuilder,
    (
      CachedReceipt,
      BaseReferences<_$AppDatabase, $CachedReceiptsTable, CachedReceipt>
    ),
    CachedReceipt,
    PrefetchHooks Function()> {
  $$CachedReceiptsTableTableManager(
      _$AppDatabase db, $CachedReceiptsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedReceiptsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedReceiptsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedReceiptsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> receiptNumber = const Value.absent(),
            Value<String> poId = const Value.absent(),
            Value<String> poNumber = const Value.absent(),
            Value<String> projectId = const Value.absent(),
            Value<String> projectName = const Value.absent(),
            Value<String> supplierName = const Value.absent(),
            Value<String> waybillNumber = const Value.absent(),
            Value<String> truckLicensePlate = const Value.absent(),
            Value<String> driverName = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<DateTime> deliveryTimestamp = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CachedReceiptsCompanion(
            id: id,
            receiptNumber: receiptNumber,
            poId: poId,
            poNumber: poNumber,
            projectId: projectId,
            projectName: projectName,
            supplierName: supplierName,
            waybillNumber: waybillNumber,
            truckLicensePlate: truckLicensePlate,
            driverName: driverName,
            status: status,
            notes: notes,
            deliveryTimestamp: deliveryTimestamp,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String receiptNumber,
            required String poId,
            required String poNumber,
            required String projectId,
            required String projectName,
            required String supplierName,
            required String waybillNumber,
            required String truckLicensePlate,
            required String driverName,
            required String status,
            Value<String?> notes = const Value.absent(),
            required DateTime deliveryTimestamp,
            Value<int> rowid = const Value.absent(),
          }) =>
              CachedReceiptsCompanion.insert(
            id: id,
            receiptNumber: receiptNumber,
            poId: poId,
            poNumber: poNumber,
            projectId: projectId,
            projectName: projectName,
            supplierName: supplierName,
            waybillNumber: waybillNumber,
            truckLicensePlate: truckLicensePlate,
            driverName: driverName,
            status: status,
            notes: notes,
            deliveryTimestamp: deliveryTimestamp,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CachedReceiptsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CachedReceiptsTable,
    CachedReceipt,
    $$CachedReceiptsTableFilterComposer,
    $$CachedReceiptsTableOrderingComposer,
    $$CachedReceiptsTableAnnotationComposer,
    $$CachedReceiptsTableCreateCompanionBuilder,
    $$CachedReceiptsTableUpdateCompanionBuilder,
    (
      CachedReceipt,
      BaseReferences<_$AppDatabase, $CachedReceiptsTable, CachedReceipt>
    ),
    CachedReceipt,
    PrefetchHooks Function()>;
typedef $$CachedDiscrepanciesTableCreateCompanionBuilder
    = CachedDiscrepanciesCompanion Function({
  required String id,
  required String projectId,
  required String projectName,
  required String receiptId,
  required String receiptNumber,
  required String materialName,
  required String type,
  required String severity,
  required String status,
  required double expectedQuantity,
  required double actualQuantity,
  required double varianceQuantity,
  required double financialImpactEtb,
  required String description,
  Value<String?> assignedToName,
  Value<String?> resolutionNotes,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$CachedDiscrepanciesTableUpdateCompanionBuilder
    = CachedDiscrepanciesCompanion Function({
  Value<String> id,
  Value<String> projectId,
  Value<String> projectName,
  Value<String> receiptId,
  Value<String> receiptNumber,
  Value<String> materialName,
  Value<String> type,
  Value<String> severity,
  Value<String> status,
  Value<double> expectedQuantity,
  Value<double> actualQuantity,
  Value<double> varianceQuantity,
  Value<double> financialImpactEtb,
  Value<String> description,
  Value<String?> assignedToName,
  Value<String?> resolutionNotes,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$CachedDiscrepanciesTableFilterComposer
    extends Composer<_$AppDatabase, $CachedDiscrepanciesTable> {
  $$CachedDiscrepanciesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get projectId => $composableBuilder(
      column: $table.projectId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get projectName => $composableBuilder(
      column: $table.projectName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get receiptId => $composableBuilder(
      column: $table.receiptId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get receiptNumber => $composableBuilder(
      column: $table.receiptNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get materialName => $composableBuilder(
      column: $table.materialName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get severity => $composableBuilder(
      column: $table.severity, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get expectedQuantity => $composableBuilder(
      column: $table.expectedQuantity,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get actualQuantity => $composableBuilder(
      column: $table.actualQuantity,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get varianceQuantity => $composableBuilder(
      column: $table.varianceQuantity,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get financialImpactEtb => $composableBuilder(
      column: $table.financialImpactEtb,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get assignedToName => $composableBuilder(
      column: $table.assignedToName,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get resolutionNotes => $composableBuilder(
      column: $table.resolutionNotes,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$CachedDiscrepanciesTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedDiscrepanciesTable> {
  $$CachedDiscrepanciesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get projectId => $composableBuilder(
      column: $table.projectId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get projectName => $composableBuilder(
      column: $table.projectName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get receiptId => $composableBuilder(
      column: $table.receiptId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get receiptNumber => $composableBuilder(
      column: $table.receiptNumber,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get materialName => $composableBuilder(
      column: $table.materialName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get severity => $composableBuilder(
      column: $table.severity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get expectedQuantity => $composableBuilder(
      column: $table.expectedQuantity,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get actualQuantity => $composableBuilder(
      column: $table.actualQuantity,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get varianceQuantity => $composableBuilder(
      column: $table.varianceQuantity,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get financialImpactEtb => $composableBuilder(
      column: $table.financialImpactEtb,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get assignedToName => $composableBuilder(
      column: $table.assignedToName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get resolutionNotes => $composableBuilder(
      column: $table.resolutionNotes,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$CachedDiscrepanciesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedDiscrepanciesTable> {
  $$CachedDiscrepanciesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get projectId =>
      $composableBuilder(column: $table.projectId, builder: (column) => column);

  GeneratedColumn<String> get projectName => $composableBuilder(
      column: $table.projectName, builder: (column) => column);

  GeneratedColumn<String> get receiptId =>
      $composableBuilder(column: $table.receiptId, builder: (column) => column);

  GeneratedColumn<String> get receiptNumber => $composableBuilder(
      column: $table.receiptNumber, builder: (column) => column);

  GeneratedColumn<String> get materialName => $composableBuilder(
      column: $table.materialName, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get severity =>
      $composableBuilder(column: $table.severity, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<double> get expectedQuantity => $composableBuilder(
      column: $table.expectedQuantity, builder: (column) => column);

  GeneratedColumn<double> get actualQuantity => $composableBuilder(
      column: $table.actualQuantity, builder: (column) => column);

  GeneratedColumn<double> get varianceQuantity => $composableBuilder(
      column: $table.varianceQuantity, builder: (column) => column);

  GeneratedColumn<double> get financialImpactEtb => $composableBuilder(
      column: $table.financialImpactEtb, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get assignedToName => $composableBuilder(
      column: $table.assignedToName, builder: (column) => column);

  GeneratedColumn<String> get resolutionNotes => $composableBuilder(
      column: $table.resolutionNotes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$CachedDiscrepanciesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CachedDiscrepanciesTable,
    CachedDiscrepancy,
    $$CachedDiscrepanciesTableFilterComposer,
    $$CachedDiscrepanciesTableOrderingComposer,
    $$CachedDiscrepanciesTableAnnotationComposer,
    $$CachedDiscrepanciesTableCreateCompanionBuilder,
    $$CachedDiscrepanciesTableUpdateCompanionBuilder,
    (
      CachedDiscrepancy,
      BaseReferences<_$AppDatabase, $CachedDiscrepanciesTable,
          CachedDiscrepancy>
    ),
    CachedDiscrepancy,
    PrefetchHooks Function()> {
  $$CachedDiscrepanciesTableTableManager(
      _$AppDatabase db, $CachedDiscrepanciesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedDiscrepanciesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedDiscrepanciesTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedDiscrepanciesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> projectId = const Value.absent(),
            Value<String> projectName = const Value.absent(),
            Value<String> receiptId = const Value.absent(),
            Value<String> receiptNumber = const Value.absent(),
            Value<String> materialName = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String> severity = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<double> expectedQuantity = const Value.absent(),
            Value<double> actualQuantity = const Value.absent(),
            Value<double> varianceQuantity = const Value.absent(),
            Value<double> financialImpactEtb = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<String?> assignedToName = const Value.absent(),
            Value<String?> resolutionNotes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CachedDiscrepanciesCompanion(
            id: id,
            projectId: projectId,
            projectName: projectName,
            receiptId: receiptId,
            receiptNumber: receiptNumber,
            materialName: materialName,
            type: type,
            severity: severity,
            status: status,
            expectedQuantity: expectedQuantity,
            actualQuantity: actualQuantity,
            varianceQuantity: varianceQuantity,
            financialImpactEtb: financialImpactEtb,
            description: description,
            assignedToName: assignedToName,
            resolutionNotes: resolutionNotes,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String projectId,
            required String projectName,
            required String receiptId,
            required String receiptNumber,
            required String materialName,
            required String type,
            required String severity,
            required String status,
            required double expectedQuantity,
            required double actualQuantity,
            required double varianceQuantity,
            required double financialImpactEtb,
            required String description,
            Value<String?> assignedToName = const Value.absent(),
            Value<String?> resolutionNotes = const Value.absent(),
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              CachedDiscrepanciesCompanion.insert(
            id: id,
            projectId: projectId,
            projectName: projectName,
            receiptId: receiptId,
            receiptNumber: receiptNumber,
            materialName: materialName,
            type: type,
            severity: severity,
            status: status,
            expectedQuantity: expectedQuantity,
            actualQuantity: actualQuantity,
            varianceQuantity: varianceQuantity,
            financialImpactEtb: financialImpactEtb,
            description: description,
            assignedToName: assignedToName,
            resolutionNotes: resolutionNotes,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CachedDiscrepanciesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CachedDiscrepanciesTable,
    CachedDiscrepancy,
    $$CachedDiscrepanciesTableFilterComposer,
    $$CachedDiscrepanciesTableOrderingComposer,
    $$CachedDiscrepanciesTableAnnotationComposer,
    $$CachedDiscrepanciesTableCreateCompanionBuilder,
    $$CachedDiscrepanciesTableUpdateCompanionBuilder,
    (
      CachedDiscrepancy,
      BaseReferences<_$AppDatabase, $CachedDiscrepanciesTable,
          CachedDiscrepancy>
    ),
    CachedDiscrepancy,
    PrefetchHooks Function()>;
typedef $$SyncOutboxTableCreateCompanionBuilder = SyncOutboxCompanion Function({
  Value<int> id,
  required String idempotencyKey,
  required String actionType,
  required String payloadJson,
  Value<String> syncStatus,
  Value<String?> errorMessage,
  Value<int> retryCount,
  Value<DateTime> createdAt,
  Value<DateTime?> lastAttemptAt,
});
typedef $$SyncOutboxTableUpdateCompanionBuilder = SyncOutboxCompanion Function({
  Value<int> id,
  Value<String> idempotencyKey,
  Value<String> actionType,
  Value<String> payloadJson,
  Value<String> syncStatus,
  Value<String?> errorMessage,
  Value<int> retryCount,
  Value<DateTime> createdAt,
  Value<DateTime?> lastAttemptAt,
});

class $$SyncOutboxTableFilterComposer
    extends Composer<_$AppDatabase, $SyncOutboxTable> {
  $$SyncOutboxTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get idempotencyKey => $composableBuilder(
      column: $table.idempotencyKey,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get actionType => $composableBuilder(
      column: $table.actionType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get errorMessage => $composableBuilder(
      column: $table.errorMessage, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastAttemptAt => $composableBuilder(
      column: $table.lastAttemptAt, builder: (column) => ColumnFilters(column));
}

class $$SyncOutboxTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncOutboxTable> {
  $$SyncOutboxTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get idempotencyKey => $composableBuilder(
      column: $table.idempotencyKey,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get actionType => $composableBuilder(
      column: $table.actionType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get errorMessage => $composableBuilder(
      column: $table.errorMessage,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastAttemptAt => $composableBuilder(
      column: $table.lastAttemptAt,
      builder: (column) => ColumnOrderings(column));
}

class $$SyncOutboxTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncOutboxTable> {
  $$SyncOutboxTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get idempotencyKey => $composableBuilder(
      column: $table.idempotencyKey, builder: (column) => column);

  GeneratedColumn<String> get actionType => $composableBuilder(
      column: $table.actionType, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);

  GeneratedColumn<String> get errorMessage => $composableBuilder(
      column: $table.errorMessage, builder: (column) => column);

  GeneratedColumn<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastAttemptAt => $composableBuilder(
      column: $table.lastAttemptAt, builder: (column) => column);
}

class $$SyncOutboxTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SyncOutboxTable,
    SyncOutboxData,
    $$SyncOutboxTableFilterComposer,
    $$SyncOutboxTableOrderingComposer,
    $$SyncOutboxTableAnnotationComposer,
    $$SyncOutboxTableCreateCompanionBuilder,
    $$SyncOutboxTableUpdateCompanionBuilder,
    (
      SyncOutboxData,
      BaseReferences<_$AppDatabase, $SyncOutboxTable, SyncOutboxData>
    ),
    SyncOutboxData,
    PrefetchHooks Function()> {
  $$SyncOutboxTableTableManager(_$AppDatabase db, $SyncOutboxTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncOutboxTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncOutboxTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncOutboxTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> idempotencyKey = const Value.absent(),
            Value<String> actionType = const Value.absent(),
            Value<String> payloadJson = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<String?> errorMessage = const Value.absent(),
            Value<int> retryCount = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> lastAttemptAt = const Value.absent(),
          }) =>
              SyncOutboxCompanion(
            id: id,
            idempotencyKey: idempotencyKey,
            actionType: actionType,
            payloadJson: payloadJson,
            syncStatus: syncStatus,
            errorMessage: errorMessage,
            retryCount: retryCount,
            createdAt: createdAt,
            lastAttemptAt: lastAttemptAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String idempotencyKey,
            required String actionType,
            required String payloadJson,
            Value<String> syncStatus = const Value.absent(),
            Value<String?> errorMessage = const Value.absent(),
            Value<int> retryCount = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> lastAttemptAt = const Value.absent(),
          }) =>
              SyncOutboxCompanion.insert(
            id: id,
            idempotencyKey: idempotencyKey,
            actionType: actionType,
            payloadJson: payloadJson,
            syncStatus: syncStatus,
            errorMessage: errorMessage,
            retryCount: retryCount,
            createdAt: createdAt,
            lastAttemptAt: lastAttemptAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SyncOutboxTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SyncOutboxTable,
    SyncOutboxData,
    $$SyncOutboxTableFilterComposer,
    $$SyncOutboxTableOrderingComposer,
    $$SyncOutboxTableAnnotationComposer,
    $$SyncOutboxTableCreateCompanionBuilder,
    $$SyncOutboxTableUpdateCompanionBuilder,
    (
      SyncOutboxData,
      BaseReferences<_$AppDatabase, $SyncOutboxTable, SyncOutboxData>
    ),
    SyncOutboxData,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CachedProjectsTableTableManager get cachedProjects =>
      $$CachedProjectsTableTableManager(_db, _db.cachedProjects);
  $$CachedOrdersTableTableManager get cachedOrders =>
      $$CachedOrdersTableTableManager(_db, _db.cachedOrders);
  $$CachedReceiptsTableTableManager get cachedReceipts =>
      $$CachedReceiptsTableTableManager(_db, _db.cachedReceipts);
  $$CachedDiscrepanciesTableTableManager get cachedDiscrepancies =>
      $$CachedDiscrepanciesTableTableManager(_db, _db.cachedDiscrepancies);
  $$SyncOutboxTableTableManager get syncOutbox =>
      $$SyncOutboxTableTableManager(_db, _db.syncOutbox);
}
