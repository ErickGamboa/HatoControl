// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $PlanesTable extends Planes with TableInfo<$PlanesTable, PlanRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlanesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _codigoMeta = const VerificationMeta('codigo');
  @override
  late final GeneratedColumn<String> codigo = GeneratedColumn<String>(
    'codigo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nombreMeta = const VerificationMeta('nombre');
  @override
  late final GeneratedColumn<String> nombre = GeneratedColumn<String>(
    'nombre',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _limiteFincasMeta = const VerificationMeta(
    'limiteFincas',
  );
  @override
  late final GeneratedColumn<int> limiteFincas = GeneratedColumn<int>(
    'limite_fincas',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    codigo,
    nombre,
    limiteFincas,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'planes';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlanRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('codigo')) {
      context.handle(
        _codigoMeta,
        codigo.isAcceptableOrUnknown(data['codigo']!, _codigoMeta),
      );
    } else if (isInserting) {
      context.missing(_codigoMeta);
    }
    if (data.containsKey('nombre')) {
      context.handle(
        _nombreMeta,
        nombre.isAcceptableOrUnknown(data['nombre']!, _nombreMeta),
      );
    } else if (isInserting) {
      context.missing(_nombreMeta);
    }
    if (data.containsKey('limite_fincas')) {
      context.handle(
        _limiteFincasMeta,
        limiteFincas.isAcceptableOrUnknown(
          data['limite_fincas']!,
          _limiteFincasMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_limiteFincasMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {codigo};
  @override
  PlanRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlanRow(
      codigo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}codigo'],
      )!,
      nombre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nombre'],
      )!,
      limiteFincas: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}limite_fincas'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $PlanesTable createAlias(String alias) {
    return $PlanesTable(attachedDatabase, alias);
  }
}

class PlanRow extends DataClass implements Insertable<PlanRow> {
  final String codigo;
  final String nombre;
  final int limiteFincas;
  final DateTime updatedAt;
  const PlanRow({
    required this.codigo,
    required this.nombre,
    required this.limiteFincas,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['codigo'] = Variable<String>(codigo);
    map['nombre'] = Variable<String>(nombre);
    map['limite_fincas'] = Variable<int>(limiteFincas);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  PlanesCompanion toCompanion(bool nullToAbsent) {
    return PlanesCompanion(
      codigo: Value(codigo),
      nombre: Value(nombre),
      limiteFincas: Value(limiteFincas),
      updatedAt: Value(updatedAt),
    );
  }

  factory PlanRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlanRow(
      codigo: serializer.fromJson<String>(json['codigo']),
      nombre: serializer.fromJson<String>(json['nombre']),
      limiteFincas: serializer.fromJson<int>(json['limiteFincas']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'codigo': serializer.toJson<String>(codigo),
      'nombre': serializer.toJson<String>(nombre),
      'limiteFincas': serializer.toJson<int>(limiteFincas),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  PlanRow copyWith({
    String? codigo,
    String? nombre,
    int? limiteFincas,
    DateTime? updatedAt,
  }) => PlanRow(
    codigo: codigo ?? this.codigo,
    nombre: nombre ?? this.nombre,
    limiteFincas: limiteFincas ?? this.limiteFincas,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  PlanRow copyWithCompanion(PlanesCompanion data) {
    return PlanRow(
      codigo: data.codigo.present ? data.codigo.value : this.codigo,
      nombre: data.nombre.present ? data.nombre.value : this.nombre,
      limiteFincas: data.limiteFincas.present
          ? data.limiteFincas.value
          : this.limiteFincas,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlanRow(')
          ..write('codigo: $codigo, ')
          ..write('nombre: $nombre, ')
          ..write('limiteFincas: $limiteFincas, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(codigo, nombre, limiteFincas, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlanRow &&
          other.codigo == this.codigo &&
          other.nombre == this.nombre &&
          other.limiteFincas == this.limiteFincas &&
          other.updatedAt == this.updatedAt);
}

class PlanesCompanion extends UpdateCompanion<PlanRow> {
  final Value<String> codigo;
  final Value<String> nombre;
  final Value<int> limiteFincas;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const PlanesCompanion({
    this.codigo = const Value.absent(),
    this.nombre = const Value.absent(),
    this.limiteFincas = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlanesCompanion.insert({
    required String codigo,
    required String nombre,
    required int limiteFincas,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : codigo = Value(codigo),
       nombre = Value(nombre),
       limiteFincas = Value(limiteFincas),
       updatedAt = Value(updatedAt);
  static Insertable<PlanRow> custom({
    Expression<String>? codigo,
    Expression<String>? nombre,
    Expression<int>? limiteFincas,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (codigo != null) 'codigo': codigo,
      if (nombre != null) 'nombre': nombre,
      if (limiteFincas != null) 'limite_fincas': limiteFincas,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlanesCompanion copyWith({
    Value<String>? codigo,
    Value<String>? nombre,
    Value<int>? limiteFincas,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return PlanesCompanion(
      codigo: codigo ?? this.codigo,
      nombre: nombre ?? this.nombre,
      limiteFincas: limiteFincas ?? this.limiteFincas,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (codigo.present) {
      map['codigo'] = Variable<String>(codigo.value);
    }
    if (nombre.present) {
      map['nombre'] = Variable<String>(nombre.value);
    }
    if (limiteFincas.present) {
      map['limite_fincas'] = Variable<int>(limiteFincas.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlanesCompanion(')
          ..write('codigo: $codigo, ')
          ..write('nombre: $nombre, ')
          ..write('limiteFincas: $limiteFincas, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CuentasTable extends Cuentas with TableInfo<$CuentasTable, CuentaRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CuentasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nombreMeta = const VerificationMeta('nombre');
  @override
  late final GeneratedColumn<String> nombre = GeneratedColumn<String>(
    'nombre',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _duenoIdMeta = const VerificationMeta(
    'duenoId',
  );
  @override
  late final GeneratedColumn<String> duenoId = GeneratedColumn<String>(
    'dueno_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _planMeta = const VerificationMeta('plan');
  @override
  late final GeneratedColumn<String> plan = GeneratedColumn<String>(
    'plan',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _estadoMeta = const VerificationMeta('estado');
  @override
  late final GeneratedColumn<String> estado = GeneratedColumn<String>(
    'estado',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pendienteMeta = const VerificationMeta(
    'pendiente',
  );
  @override
  late final GeneratedColumn<bool> pendiente = GeneratedColumn<bool>(
    'pendiente',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("pendiente" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    nombre,
    duenoId,
    plan,
    estado,
    createdAt,
    updatedAt,
    deletedAt,
    pendiente,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cuentas';
  @override
  VerificationContext validateIntegrity(
    Insertable<CuentaRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('nombre')) {
      context.handle(
        _nombreMeta,
        nombre.isAcceptableOrUnknown(data['nombre']!, _nombreMeta),
      );
    } else if (isInserting) {
      context.missing(_nombreMeta);
    }
    if (data.containsKey('dueno_id')) {
      context.handle(
        _duenoIdMeta,
        duenoId.isAcceptableOrUnknown(data['dueno_id']!, _duenoIdMeta),
      );
    } else if (isInserting) {
      context.missing(_duenoIdMeta);
    }
    if (data.containsKey('plan')) {
      context.handle(
        _planMeta,
        plan.isAcceptableOrUnknown(data['plan']!, _planMeta),
      );
    } else if (isInserting) {
      context.missing(_planMeta);
    }
    if (data.containsKey('estado')) {
      context.handle(
        _estadoMeta,
        estado.isAcceptableOrUnknown(data['estado']!, _estadoMeta),
      );
    } else if (isInserting) {
      context.missing(_estadoMeta);
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
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('pendiente')) {
      context.handle(
        _pendienteMeta,
        pendiente.isAcceptableOrUnknown(data['pendiente']!, _pendienteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CuentaRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CuentaRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      nombre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nombre'],
      )!,
      duenoId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dueno_id'],
      )!,
      plan: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}plan'],
      )!,
      estado: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}estado'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      pendiente: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}pendiente'],
      )!,
    );
  }

  @override
  $CuentasTable createAlias(String alias) {
    return $CuentasTable(attachedDatabase, alias);
  }
}

class CuentaRow extends DataClass implements Insertable<CuentaRow> {
  final String id;
  final String nombre;
  final String duenoId;
  final String plan;
  final String estado;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final bool pendiente;
  const CuentaRow({
    required this.id,
    required this.nombre,
    required this.duenoId,
    required this.plan,
    required this.estado,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.pendiente,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['nombre'] = Variable<String>(nombre);
    map['dueno_id'] = Variable<String>(duenoId);
    map['plan'] = Variable<String>(plan);
    map['estado'] = Variable<String>(estado);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['pendiente'] = Variable<bool>(pendiente);
    return map;
  }

  CuentasCompanion toCompanion(bool nullToAbsent) {
    return CuentasCompanion(
      id: Value(id),
      nombre: Value(nombre),
      duenoId: Value(duenoId),
      plan: Value(plan),
      estado: Value(estado),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      pendiente: Value(pendiente),
    );
  }

  factory CuentaRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CuentaRow(
      id: serializer.fromJson<String>(json['id']),
      nombre: serializer.fromJson<String>(json['nombre']),
      duenoId: serializer.fromJson<String>(json['duenoId']),
      plan: serializer.fromJson<String>(json['plan']),
      estado: serializer.fromJson<String>(json['estado']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      pendiente: serializer.fromJson<bool>(json['pendiente']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'nombre': serializer.toJson<String>(nombre),
      'duenoId': serializer.toJson<String>(duenoId),
      'plan': serializer.toJson<String>(plan),
      'estado': serializer.toJson<String>(estado),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'pendiente': serializer.toJson<bool>(pendiente),
    };
  }

  CuentaRow copyWith({
    String? id,
    String? nombre,
    String? duenoId,
    String? plan,
    String? estado,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    bool? pendiente,
  }) => CuentaRow(
    id: id ?? this.id,
    nombre: nombre ?? this.nombre,
    duenoId: duenoId ?? this.duenoId,
    plan: plan ?? this.plan,
    estado: estado ?? this.estado,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    pendiente: pendiente ?? this.pendiente,
  );
  CuentaRow copyWithCompanion(CuentasCompanion data) {
    return CuentaRow(
      id: data.id.present ? data.id.value : this.id,
      nombre: data.nombre.present ? data.nombre.value : this.nombre,
      duenoId: data.duenoId.present ? data.duenoId.value : this.duenoId,
      plan: data.plan.present ? data.plan.value : this.plan,
      estado: data.estado.present ? data.estado.value : this.estado,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      pendiente: data.pendiente.present ? data.pendiente.value : this.pendiente,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CuentaRow(')
          ..write('id: $id, ')
          ..write('nombre: $nombre, ')
          ..write('duenoId: $duenoId, ')
          ..write('plan: $plan, ')
          ..write('estado: $estado, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('pendiente: $pendiente')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    nombre,
    duenoId,
    plan,
    estado,
    createdAt,
    updatedAt,
    deletedAt,
    pendiente,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CuentaRow &&
          other.id == this.id &&
          other.nombre == this.nombre &&
          other.duenoId == this.duenoId &&
          other.plan == this.plan &&
          other.estado == this.estado &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.pendiente == this.pendiente);
}

class CuentasCompanion extends UpdateCompanion<CuentaRow> {
  final Value<String> id;
  final Value<String> nombre;
  final Value<String> duenoId;
  final Value<String> plan;
  final Value<String> estado;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<bool> pendiente;
  final Value<int> rowid;
  const CuentasCompanion({
    this.id = const Value.absent(),
    this.nombre = const Value.absent(),
    this.duenoId = const Value.absent(),
    this.plan = const Value.absent(),
    this.estado = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.pendiente = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CuentasCompanion.insert({
    required String id,
    required String nombre,
    required String duenoId,
    required String plan,
    required String estado,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.pendiente = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       nombre = Value(nombre),
       duenoId = Value(duenoId),
       plan = Value(plan),
       estado = Value(estado),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<CuentaRow> custom({
    Expression<String>? id,
    Expression<String>? nombre,
    Expression<String>? duenoId,
    Expression<String>? plan,
    Expression<String>? estado,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<bool>? pendiente,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nombre != null) 'nombre': nombre,
      if (duenoId != null) 'dueno_id': duenoId,
      if (plan != null) 'plan': plan,
      if (estado != null) 'estado': estado,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (pendiente != null) 'pendiente': pendiente,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CuentasCompanion copyWith({
    Value<String>? id,
    Value<String>? nombre,
    Value<String>? duenoId,
    Value<String>? plan,
    Value<String>? estado,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<bool>? pendiente,
    Value<int>? rowid,
  }) {
    return CuentasCompanion(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      duenoId: duenoId ?? this.duenoId,
      plan: plan ?? this.plan,
      estado: estado ?? this.estado,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      pendiente: pendiente ?? this.pendiente,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (nombre.present) {
      map['nombre'] = Variable<String>(nombre.value);
    }
    if (duenoId.present) {
      map['dueno_id'] = Variable<String>(duenoId.value);
    }
    if (plan.present) {
      map['plan'] = Variable<String>(plan.value);
    }
    if (estado.present) {
      map['estado'] = Variable<String>(estado.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (pendiente.present) {
      map['pendiente'] = Variable<bool>(pendiente.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CuentasCompanion(')
          ..write('id: $id, ')
          ..write('nombre: $nombre, ')
          ..write('duenoId: $duenoId, ')
          ..write('plan: $plan, ')
          ..write('estado: $estado, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('pendiente: $pendiente, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UsuariosTable extends Usuarios
    with TableInfo<$UsuariosTable, UsuarioRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsuariosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nombreMeta = const VerificationMeta('nombre');
  @override
  late final GeneratedColumn<String> nombre = GeneratedColumn<String>(
    'nombre',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cuentaIdMeta = const VerificationMeta(
    'cuentaId',
  );
  @override
  late final GeneratedColumn<String> cuentaId = GeneratedColumn<String>(
    'cuenta_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pendienteMeta = const VerificationMeta(
    'pendiente',
  );
  @override
  late final GeneratedColumn<bool> pendiente = GeneratedColumn<bool>(
    'pendiente',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("pendiente" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    nombre,
    email,
    cuentaId,
    createdAt,
    updatedAt,
    pendiente,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'usuarios';
  @override
  VerificationContext validateIntegrity(
    Insertable<UsuarioRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('nombre')) {
      context.handle(
        _nombreMeta,
        nombre.isAcceptableOrUnknown(data['nombre']!, _nombreMeta),
      );
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    }
    if (data.containsKey('cuenta_id')) {
      context.handle(
        _cuentaIdMeta,
        cuentaId.isAcceptableOrUnknown(data['cuenta_id']!, _cuentaIdMeta),
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
    if (data.containsKey('pendiente')) {
      context.handle(
        _pendienteMeta,
        pendiente.isAcceptableOrUnknown(data['pendiente']!, _pendienteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UsuarioRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UsuarioRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      nombre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nombre'],
      ),
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      ),
      cuentaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cuenta_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      pendiente: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}pendiente'],
      )!,
    );
  }

  @override
  $UsuariosTable createAlias(String alias) {
    return $UsuariosTable(attachedDatabase, alias);
  }
}

class UsuarioRow extends DataClass implements Insertable<UsuarioRow> {
  final String id;
  final String? nombre;
  final String? email;
  final String? cuentaId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool pendiente;
  const UsuarioRow({
    required this.id,
    this.nombre,
    this.email,
    this.cuentaId,
    required this.createdAt,
    required this.updatedAt,
    required this.pendiente,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || nombre != null) {
      map['nombre'] = Variable<String>(nombre);
    }
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || cuentaId != null) {
      map['cuenta_id'] = Variable<String>(cuentaId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['pendiente'] = Variable<bool>(pendiente);
    return map;
  }

  UsuariosCompanion toCompanion(bool nullToAbsent) {
    return UsuariosCompanion(
      id: Value(id),
      nombre: nombre == null && nullToAbsent
          ? const Value.absent()
          : Value(nombre),
      email: email == null && nullToAbsent
          ? const Value.absent()
          : Value(email),
      cuentaId: cuentaId == null && nullToAbsent
          ? const Value.absent()
          : Value(cuentaId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      pendiente: Value(pendiente),
    );
  }

  factory UsuarioRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UsuarioRow(
      id: serializer.fromJson<String>(json['id']),
      nombre: serializer.fromJson<String?>(json['nombre']),
      email: serializer.fromJson<String?>(json['email']),
      cuentaId: serializer.fromJson<String?>(json['cuentaId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      pendiente: serializer.fromJson<bool>(json['pendiente']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'nombre': serializer.toJson<String?>(nombre),
      'email': serializer.toJson<String?>(email),
      'cuentaId': serializer.toJson<String?>(cuentaId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'pendiente': serializer.toJson<bool>(pendiente),
    };
  }

  UsuarioRow copyWith({
    String? id,
    Value<String?> nombre = const Value.absent(),
    Value<String?> email = const Value.absent(),
    Value<String?> cuentaId = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? pendiente,
  }) => UsuarioRow(
    id: id ?? this.id,
    nombre: nombre.present ? nombre.value : this.nombre,
    email: email.present ? email.value : this.email,
    cuentaId: cuentaId.present ? cuentaId.value : this.cuentaId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    pendiente: pendiente ?? this.pendiente,
  );
  UsuarioRow copyWithCompanion(UsuariosCompanion data) {
    return UsuarioRow(
      id: data.id.present ? data.id.value : this.id,
      nombre: data.nombre.present ? data.nombre.value : this.nombre,
      email: data.email.present ? data.email.value : this.email,
      cuentaId: data.cuentaId.present ? data.cuentaId.value : this.cuentaId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      pendiente: data.pendiente.present ? data.pendiente.value : this.pendiente,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UsuarioRow(')
          ..write('id: $id, ')
          ..write('nombre: $nombre, ')
          ..write('email: $email, ')
          ..write('cuentaId: $cuentaId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('pendiente: $pendiente')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, nombre, email, cuentaId, createdAt, updatedAt, pendiente);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UsuarioRow &&
          other.id == this.id &&
          other.nombre == this.nombre &&
          other.email == this.email &&
          other.cuentaId == this.cuentaId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.pendiente == this.pendiente);
}

class UsuariosCompanion extends UpdateCompanion<UsuarioRow> {
  final Value<String> id;
  final Value<String?> nombre;
  final Value<String?> email;
  final Value<String?> cuentaId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> pendiente;
  final Value<int> rowid;
  const UsuariosCompanion({
    this.id = const Value.absent(),
    this.nombre = const Value.absent(),
    this.email = const Value.absent(),
    this.cuentaId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.pendiente = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UsuariosCompanion.insert({
    required String id,
    this.nombre = const Value.absent(),
    this.email = const Value.absent(),
    this.cuentaId = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.pendiente = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<UsuarioRow> custom({
    Expression<String>? id,
    Expression<String>? nombre,
    Expression<String>? email,
    Expression<String>? cuentaId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? pendiente,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nombre != null) 'nombre': nombre,
      if (email != null) 'email': email,
      if (cuentaId != null) 'cuenta_id': cuentaId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (pendiente != null) 'pendiente': pendiente,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UsuariosCompanion copyWith({
    Value<String>? id,
    Value<String?>? nombre,
    Value<String?>? email,
    Value<String?>? cuentaId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<bool>? pendiente,
    Value<int>? rowid,
  }) {
    return UsuariosCompanion(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      email: email ?? this.email,
      cuentaId: cuentaId ?? this.cuentaId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      pendiente: pendiente ?? this.pendiente,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (nombre.present) {
      map['nombre'] = Variable<String>(nombre.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (cuentaId.present) {
      map['cuenta_id'] = Variable<String>(cuentaId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (pendiente.present) {
      map['pendiente'] = Variable<bool>(pendiente.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsuariosCompanion(')
          ..write('id: $id, ')
          ..write('nombre: $nombre, ')
          ..write('email: $email, ')
          ..write('cuentaId: $cuentaId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('pendiente: $pendiente, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FincasTable extends Fincas with TableInfo<$FincasTable, FincaRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FincasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nombreMeta = const VerificationMeta('nombre');
  @override
  late final GeneratedColumn<String> nombre = GeneratedColumn<String>(
    'nombre',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fotoUrlMeta = const VerificationMeta(
    'fotoUrl',
  );
  @override
  late final GeneratedColumn<String> fotoUrl = GeneratedColumn<String>(
    'foto_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _creadaPorMeta = const VerificationMeta(
    'creadaPor',
  );
  @override
  late final GeneratedColumn<String> creadaPor = GeneratedColumn<String>(
    'creada_por',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cuentaIdMeta = const VerificationMeta(
    'cuentaId',
  );
  @override
  late final GeneratedColumn<String> cuentaId = GeneratedColumn<String>(
    'cuenta_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fotoLocalPathMeta = const VerificationMeta(
    'fotoLocalPath',
  );
  @override
  late final GeneratedColumn<String> fotoLocalPath = GeneratedColumn<String>(
    'foto_local_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fotoPendienteMeta = const VerificationMeta(
    'fotoPendiente',
  );
  @override
  late final GeneratedColumn<bool> fotoPendiente = GeneratedColumn<bool>(
    'foto_pendiente',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("foto_pendiente" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pendienteMeta = const VerificationMeta(
    'pendiente',
  );
  @override
  late final GeneratedColumn<bool> pendiente = GeneratedColumn<bool>(
    'pendiente',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("pendiente" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    nombre,
    fotoUrl,
    creadaPor,
    cuentaId,
    fotoLocalPath,
    fotoPendiente,
    createdAt,
    updatedAt,
    deletedAt,
    pendiente,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'fincas';
  @override
  VerificationContext validateIntegrity(
    Insertable<FincaRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('nombre')) {
      context.handle(
        _nombreMeta,
        nombre.isAcceptableOrUnknown(data['nombre']!, _nombreMeta),
      );
    } else if (isInserting) {
      context.missing(_nombreMeta);
    }
    if (data.containsKey('foto_url')) {
      context.handle(
        _fotoUrlMeta,
        fotoUrl.isAcceptableOrUnknown(data['foto_url']!, _fotoUrlMeta),
      );
    }
    if (data.containsKey('creada_por')) {
      context.handle(
        _creadaPorMeta,
        creadaPor.isAcceptableOrUnknown(data['creada_por']!, _creadaPorMeta),
      );
    } else if (isInserting) {
      context.missing(_creadaPorMeta);
    }
    if (data.containsKey('cuenta_id')) {
      context.handle(
        _cuentaIdMeta,
        cuentaId.isAcceptableOrUnknown(data['cuenta_id']!, _cuentaIdMeta),
      );
    }
    if (data.containsKey('foto_local_path')) {
      context.handle(
        _fotoLocalPathMeta,
        fotoLocalPath.isAcceptableOrUnknown(
          data['foto_local_path']!,
          _fotoLocalPathMeta,
        ),
      );
    }
    if (data.containsKey('foto_pendiente')) {
      context.handle(
        _fotoPendienteMeta,
        fotoPendiente.isAcceptableOrUnknown(
          data['foto_pendiente']!,
          _fotoPendienteMeta,
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
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('pendiente')) {
      context.handle(
        _pendienteMeta,
        pendiente.isAcceptableOrUnknown(data['pendiente']!, _pendienteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FincaRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FincaRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      nombre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nombre'],
      )!,
      fotoUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}foto_url'],
      ),
      creadaPor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}creada_por'],
      )!,
      cuentaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cuenta_id'],
      ),
      fotoLocalPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}foto_local_path'],
      ),
      fotoPendiente: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}foto_pendiente'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      pendiente: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}pendiente'],
      )!,
    );
  }

  @override
  $FincasTable createAlias(String alias) {
    return $FincasTable(attachedDatabase, alias);
  }
}

class FincaRow extends DataClass implements Insertable<FincaRow> {
  final String id;
  final String nombre;
  final String? fotoUrl;
  final String creadaPor;
  final String? cuentaId;
  final String? fotoLocalPath;
  final bool fotoPendiente;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final bool pendiente;
  const FincaRow({
    required this.id,
    required this.nombre,
    this.fotoUrl,
    required this.creadaPor,
    this.cuentaId,
    this.fotoLocalPath,
    required this.fotoPendiente,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.pendiente,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['nombre'] = Variable<String>(nombre);
    if (!nullToAbsent || fotoUrl != null) {
      map['foto_url'] = Variable<String>(fotoUrl);
    }
    map['creada_por'] = Variable<String>(creadaPor);
    if (!nullToAbsent || cuentaId != null) {
      map['cuenta_id'] = Variable<String>(cuentaId);
    }
    if (!nullToAbsent || fotoLocalPath != null) {
      map['foto_local_path'] = Variable<String>(fotoLocalPath);
    }
    map['foto_pendiente'] = Variable<bool>(fotoPendiente);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['pendiente'] = Variable<bool>(pendiente);
    return map;
  }

  FincasCompanion toCompanion(bool nullToAbsent) {
    return FincasCompanion(
      id: Value(id),
      nombre: Value(nombre),
      fotoUrl: fotoUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(fotoUrl),
      creadaPor: Value(creadaPor),
      cuentaId: cuentaId == null && nullToAbsent
          ? const Value.absent()
          : Value(cuentaId),
      fotoLocalPath: fotoLocalPath == null && nullToAbsent
          ? const Value.absent()
          : Value(fotoLocalPath),
      fotoPendiente: Value(fotoPendiente),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      pendiente: Value(pendiente),
    );
  }

  factory FincaRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FincaRow(
      id: serializer.fromJson<String>(json['id']),
      nombre: serializer.fromJson<String>(json['nombre']),
      fotoUrl: serializer.fromJson<String?>(json['fotoUrl']),
      creadaPor: serializer.fromJson<String>(json['creadaPor']),
      cuentaId: serializer.fromJson<String?>(json['cuentaId']),
      fotoLocalPath: serializer.fromJson<String?>(json['fotoLocalPath']),
      fotoPendiente: serializer.fromJson<bool>(json['fotoPendiente']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      pendiente: serializer.fromJson<bool>(json['pendiente']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'nombre': serializer.toJson<String>(nombre),
      'fotoUrl': serializer.toJson<String?>(fotoUrl),
      'creadaPor': serializer.toJson<String>(creadaPor),
      'cuentaId': serializer.toJson<String?>(cuentaId),
      'fotoLocalPath': serializer.toJson<String?>(fotoLocalPath),
      'fotoPendiente': serializer.toJson<bool>(fotoPendiente),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'pendiente': serializer.toJson<bool>(pendiente),
    };
  }

  FincaRow copyWith({
    String? id,
    String? nombre,
    Value<String?> fotoUrl = const Value.absent(),
    String? creadaPor,
    Value<String?> cuentaId = const Value.absent(),
    Value<String?> fotoLocalPath = const Value.absent(),
    bool? fotoPendiente,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    bool? pendiente,
  }) => FincaRow(
    id: id ?? this.id,
    nombre: nombre ?? this.nombre,
    fotoUrl: fotoUrl.present ? fotoUrl.value : this.fotoUrl,
    creadaPor: creadaPor ?? this.creadaPor,
    cuentaId: cuentaId.present ? cuentaId.value : this.cuentaId,
    fotoLocalPath: fotoLocalPath.present
        ? fotoLocalPath.value
        : this.fotoLocalPath,
    fotoPendiente: fotoPendiente ?? this.fotoPendiente,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    pendiente: pendiente ?? this.pendiente,
  );
  FincaRow copyWithCompanion(FincasCompanion data) {
    return FincaRow(
      id: data.id.present ? data.id.value : this.id,
      nombre: data.nombre.present ? data.nombre.value : this.nombre,
      fotoUrl: data.fotoUrl.present ? data.fotoUrl.value : this.fotoUrl,
      creadaPor: data.creadaPor.present ? data.creadaPor.value : this.creadaPor,
      cuentaId: data.cuentaId.present ? data.cuentaId.value : this.cuentaId,
      fotoLocalPath: data.fotoLocalPath.present
          ? data.fotoLocalPath.value
          : this.fotoLocalPath,
      fotoPendiente: data.fotoPendiente.present
          ? data.fotoPendiente.value
          : this.fotoPendiente,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      pendiente: data.pendiente.present ? data.pendiente.value : this.pendiente,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FincaRow(')
          ..write('id: $id, ')
          ..write('nombre: $nombre, ')
          ..write('fotoUrl: $fotoUrl, ')
          ..write('creadaPor: $creadaPor, ')
          ..write('cuentaId: $cuentaId, ')
          ..write('fotoLocalPath: $fotoLocalPath, ')
          ..write('fotoPendiente: $fotoPendiente, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('pendiente: $pendiente')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    nombre,
    fotoUrl,
    creadaPor,
    cuentaId,
    fotoLocalPath,
    fotoPendiente,
    createdAt,
    updatedAt,
    deletedAt,
    pendiente,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FincaRow &&
          other.id == this.id &&
          other.nombre == this.nombre &&
          other.fotoUrl == this.fotoUrl &&
          other.creadaPor == this.creadaPor &&
          other.cuentaId == this.cuentaId &&
          other.fotoLocalPath == this.fotoLocalPath &&
          other.fotoPendiente == this.fotoPendiente &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.pendiente == this.pendiente);
}

class FincasCompanion extends UpdateCompanion<FincaRow> {
  final Value<String> id;
  final Value<String> nombre;
  final Value<String?> fotoUrl;
  final Value<String> creadaPor;
  final Value<String?> cuentaId;
  final Value<String?> fotoLocalPath;
  final Value<bool> fotoPendiente;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<bool> pendiente;
  final Value<int> rowid;
  const FincasCompanion({
    this.id = const Value.absent(),
    this.nombre = const Value.absent(),
    this.fotoUrl = const Value.absent(),
    this.creadaPor = const Value.absent(),
    this.cuentaId = const Value.absent(),
    this.fotoLocalPath = const Value.absent(),
    this.fotoPendiente = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.pendiente = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FincasCompanion.insert({
    required String id,
    required String nombre,
    this.fotoUrl = const Value.absent(),
    required String creadaPor,
    this.cuentaId = const Value.absent(),
    this.fotoLocalPath = const Value.absent(),
    this.fotoPendiente = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.pendiente = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       nombre = Value(nombre),
       creadaPor = Value(creadaPor),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<FincaRow> custom({
    Expression<String>? id,
    Expression<String>? nombre,
    Expression<String>? fotoUrl,
    Expression<String>? creadaPor,
    Expression<String>? cuentaId,
    Expression<String>? fotoLocalPath,
    Expression<bool>? fotoPendiente,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<bool>? pendiente,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nombre != null) 'nombre': nombre,
      if (fotoUrl != null) 'foto_url': fotoUrl,
      if (creadaPor != null) 'creada_por': creadaPor,
      if (cuentaId != null) 'cuenta_id': cuentaId,
      if (fotoLocalPath != null) 'foto_local_path': fotoLocalPath,
      if (fotoPendiente != null) 'foto_pendiente': fotoPendiente,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (pendiente != null) 'pendiente': pendiente,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FincasCompanion copyWith({
    Value<String>? id,
    Value<String>? nombre,
    Value<String?>? fotoUrl,
    Value<String>? creadaPor,
    Value<String?>? cuentaId,
    Value<String?>? fotoLocalPath,
    Value<bool>? fotoPendiente,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<bool>? pendiente,
    Value<int>? rowid,
  }) {
    return FincasCompanion(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      fotoUrl: fotoUrl ?? this.fotoUrl,
      creadaPor: creadaPor ?? this.creadaPor,
      cuentaId: cuentaId ?? this.cuentaId,
      fotoLocalPath: fotoLocalPath ?? this.fotoLocalPath,
      fotoPendiente: fotoPendiente ?? this.fotoPendiente,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      pendiente: pendiente ?? this.pendiente,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (nombre.present) {
      map['nombre'] = Variable<String>(nombre.value);
    }
    if (fotoUrl.present) {
      map['foto_url'] = Variable<String>(fotoUrl.value);
    }
    if (creadaPor.present) {
      map['creada_por'] = Variable<String>(creadaPor.value);
    }
    if (cuentaId.present) {
      map['cuenta_id'] = Variable<String>(cuentaId.value);
    }
    if (fotoLocalPath.present) {
      map['foto_local_path'] = Variable<String>(fotoLocalPath.value);
    }
    if (fotoPendiente.present) {
      map['foto_pendiente'] = Variable<bool>(fotoPendiente.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (pendiente.present) {
      map['pendiente'] = Variable<bool>(pendiente.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FincasCompanion(')
          ..write('id: $id, ')
          ..write('nombre: $nombre, ')
          ..write('fotoUrl: $fotoUrl, ')
          ..write('creadaPor: $creadaPor, ')
          ..write('cuentaId: $cuentaId, ')
          ..write('fotoLocalPath: $fotoLocalPath, ')
          ..write('fotoPendiente: $fotoPendiente, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('pendiente: $pendiente, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FincaMiembrosTable extends FincaMiembros
    with TableInfo<$FincaMiembrosTable, FincaMiembroRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FincaMiembrosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fincaIdMeta = const VerificationMeta(
    'fincaId',
  );
  @override
  late final GeneratedColumn<String> fincaId = GeneratedColumn<String>(
    'finca_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _usuarioIdMeta = const VerificationMeta(
    'usuarioId',
  );
  @override
  late final GeneratedColumn<String> usuarioId = GeneratedColumn<String>(
    'usuario_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rolMeta = const VerificationMeta('rol');
  @override
  late final GeneratedColumn<String> rol = GeneratedColumn<String>(
    'rol',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pendienteMeta = const VerificationMeta(
    'pendiente',
  );
  @override
  late final GeneratedColumn<bool> pendiente = GeneratedColumn<bool>(
    'pendiente',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("pendiente" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    fincaId,
    usuarioId,
    rol,
    createdAt,
    updatedAt,
    deletedAt,
    pendiente,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'finca_miembros';
  @override
  VerificationContext validateIntegrity(
    Insertable<FincaMiembroRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('finca_id')) {
      context.handle(
        _fincaIdMeta,
        fincaId.isAcceptableOrUnknown(data['finca_id']!, _fincaIdMeta),
      );
    } else if (isInserting) {
      context.missing(_fincaIdMeta);
    }
    if (data.containsKey('usuario_id')) {
      context.handle(
        _usuarioIdMeta,
        usuarioId.isAcceptableOrUnknown(data['usuario_id']!, _usuarioIdMeta),
      );
    } else if (isInserting) {
      context.missing(_usuarioIdMeta);
    }
    if (data.containsKey('rol')) {
      context.handle(
        _rolMeta,
        rol.isAcceptableOrUnknown(data['rol']!, _rolMeta),
      );
    } else if (isInserting) {
      context.missing(_rolMeta);
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
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('pendiente')) {
      context.handle(
        _pendienteMeta,
        pendiente.isAcceptableOrUnknown(data['pendiente']!, _pendienteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FincaMiembroRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FincaMiembroRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      fincaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}finca_id'],
      )!,
      usuarioId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}usuario_id'],
      )!,
      rol: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rol'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      pendiente: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}pendiente'],
      )!,
    );
  }

  @override
  $FincaMiembrosTable createAlias(String alias) {
    return $FincaMiembrosTable(attachedDatabase, alias);
  }
}

class FincaMiembroRow extends DataClass implements Insertable<FincaMiembroRow> {
  final String id;
  final String fincaId;
  final String usuarioId;
  final String rol;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final bool pendiente;
  const FincaMiembroRow({
    required this.id,
    required this.fincaId,
    required this.usuarioId,
    required this.rol,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.pendiente,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['finca_id'] = Variable<String>(fincaId);
    map['usuario_id'] = Variable<String>(usuarioId);
    map['rol'] = Variable<String>(rol);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['pendiente'] = Variable<bool>(pendiente);
    return map;
  }

  FincaMiembrosCompanion toCompanion(bool nullToAbsent) {
    return FincaMiembrosCompanion(
      id: Value(id),
      fincaId: Value(fincaId),
      usuarioId: Value(usuarioId),
      rol: Value(rol),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      pendiente: Value(pendiente),
    );
  }

  factory FincaMiembroRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FincaMiembroRow(
      id: serializer.fromJson<String>(json['id']),
      fincaId: serializer.fromJson<String>(json['fincaId']),
      usuarioId: serializer.fromJson<String>(json['usuarioId']),
      rol: serializer.fromJson<String>(json['rol']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      pendiente: serializer.fromJson<bool>(json['pendiente']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'fincaId': serializer.toJson<String>(fincaId),
      'usuarioId': serializer.toJson<String>(usuarioId),
      'rol': serializer.toJson<String>(rol),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'pendiente': serializer.toJson<bool>(pendiente),
    };
  }

  FincaMiembroRow copyWith({
    String? id,
    String? fincaId,
    String? usuarioId,
    String? rol,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    bool? pendiente,
  }) => FincaMiembroRow(
    id: id ?? this.id,
    fincaId: fincaId ?? this.fincaId,
    usuarioId: usuarioId ?? this.usuarioId,
    rol: rol ?? this.rol,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    pendiente: pendiente ?? this.pendiente,
  );
  FincaMiembroRow copyWithCompanion(FincaMiembrosCompanion data) {
    return FincaMiembroRow(
      id: data.id.present ? data.id.value : this.id,
      fincaId: data.fincaId.present ? data.fincaId.value : this.fincaId,
      usuarioId: data.usuarioId.present ? data.usuarioId.value : this.usuarioId,
      rol: data.rol.present ? data.rol.value : this.rol,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      pendiente: data.pendiente.present ? data.pendiente.value : this.pendiente,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FincaMiembroRow(')
          ..write('id: $id, ')
          ..write('fincaId: $fincaId, ')
          ..write('usuarioId: $usuarioId, ')
          ..write('rol: $rol, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('pendiente: $pendiente')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    fincaId,
    usuarioId,
    rol,
    createdAt,
    updatedAt,
    deletedAt,
    pendiente,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FincaMiembroRow &&
          other.id == this.id &&
          other.fincaId == this.fincaId &&
          other.usuarioId == this.usuarioId &&
          other.rol == this.rol &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.pendiente == this.pendiente);
}

class FincaMiembrosCompanion extends UpdateCompanion<FincaMiembroRow> {
  final Value<String> id;
  final Value<String> fincaId;
  final Value<String> usuarioId;
  final Value<String> rol;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<bool> pendiente;
  final Value<int> rowid;
  const FincaMiembrosCompanion({
    this.id = const Value.absent(),
    this.fincaId = const Value.absent(),
    this.usuarioId = const Value.absent(),
    this.rol = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.pendiente = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FincaMiembrosCompanion.insert({
    required String id,
    required String fincaId,
    required String usuarioId,
    required String rol,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.pendiente = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       fincaId = Value(fincaId),
       usuarioId = Value(usuarioId),
       rol = Value(rol),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<FincaMiembroRow> custom({
    Expression<String>? id,
    Expression<String>? fincaId,
    Expression<String>? usuarioId,
    Expression<String>? rol,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<bool>? pendiente,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (fincaId != null) 'finca_id': fincaId,
      if (usuarioId != null) 'usuario_id': usuarioId,
      if (rol != null) 'rol': rol,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (pendiente != null) 'pendiente': pendiente,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FincaMiembrosCompanion copyWith({
    Value<String>? id,
    Value<String>? fincaId,
    Value<String>? usuarioId,
    Value<String>? rol,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<bool>? pendiente,
    Value<int>? rowid,
  }) {
    return FincaMiembrosCompanion(
      id: id ?? this.id,
      fincaId: fincaId ?? this.fincaId,
      usuarioId: usuarioId ?? this.usuarioId,
      rol: rol ?? this.rol,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      pendiente: pendiente ?? this.pendiente,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (fincaId.present) {
      map['finca_id'] = Variable<String>(fincaId.value);
    }
    if (usuarioId.present) {
      map['usuario_id'] = Variable<String>(usuarioId.value);
    }
    if (rol.present) {
      map['rol'] = Variable<String>(rol.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (pendiente.present) {
      map['pendiente'] = Variable<bool>(pendiente.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FincaMiembrosCompanion(')
          ..write('id: $id, ')
          ..write('fincaId: $fincaId, ')
          ..write('usuarioId: $usuarioId, ')
          ..write('rol: $rol, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('pendiente: $pendiente, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LotesTable extends Lotes with TableInfo<$LotesTable, LoteRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LotesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fincaIdMeta = const VerificationMeta(
    'fincaId',
  );
  @override
  late final GeneratedColumn<String> fincaId = GeneratedColumn<String>(
    'finca_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nombreMeta = const VerificationMeta('nombre');
  @override
  late final GeneratedColumn<String> nombre = GeneratedColumn<String>(
    'nombre',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _numeroMeta = const VerificationMeta('numero');
  @override
  late final GeneratedColumn<int> numero = GeneratedColumn<int>(
    'numero',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pendienteMeta = const VerificationMeta(
    'pendiente',
  );
  @override
  late final GeneratedColumn<bool> pendiente = GeneratedColumn<bool>(
    'pendiente',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("pendiente" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    fincaId,
    nombre,
    numero,
    createdAt,
    updatedAt,
    deletedAt,
    pendiente,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'lotes';
  @override
  VerificationContext validateIntegrity(
    Insertable<LoteRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('finca_id')) {
      context.handle(
        _fincaIdMeta,
        fincaId.isAcceptableOrUnknown(data['finca_id']!, _fincaIdMeta),
      );
    } else if (isInserting) {
      context.missing(_fincaIdMeta);
    }
    if (data.containsKey('nombre')) {
      context.handle(
        _nombreMeta,
        nombre.isAcceptableOrUnknown(data['nombre']!, _nombreMeta),
      );
    } else if (isInserting) {
      context.missing(_nombreMeta);
    }
    if (data.containsKey('numero')) {
      context.handle(
        _numeroMeta,
        numero.isAcceptableOrUnknown(data['numero']!, _numeroMeta),
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
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('pendiente')) {
      context.handle(
        _pendienteMeta,
        pendiente.isAcceptableOrUnknown(data['pendiente']!, _pendienteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LoteRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LoteRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      fincaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}finca_id'],
      )!,
      nombre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nombre'],
      )!,
      numero: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}numero'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      pendiente: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}pendiente'],
      )!,
    );
  }

  @override
  $LotesTable createAlias(String alias) {
    return $LotesTable(attachedDatabase, alias);
  }
}

class LoteRow extends DataClass implements Insertable<LoteRow> {
  final String id;
  final String fincaId;
  final String nombre;
  final int? numero;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final bool pendiente;
  const LoteRow({
    required this.id,
    required this.fincaId,
    required this.nombre,
    this.numero,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.pendiente,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['finca_id'] = Variable<String>(fincaId);
    map['nombre'] = Variable<String>(nombre);
    if (!nullToAbsent || numero != null) {
      map['numero'] = Variable<int>(numero);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['pendiente'] = Variable<bool>(pendiente);
    return map;
  }

  LotesCompanion toCompanion(bool nullToAbsent) {
    return LotesCompanion(
      id: Value(id),
      fincaId: Value(fincaId),
      nombre: Value(nombre),
      numero: numero == null && nullToAbsent
          ? const Value.absent()
          : Value(numero),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      pendiente: Value(pendiente),
    );
  }

  factory LoteRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LoteRow(
      id: serializer.fromJson<String>(json['id']),
      fincaId: serializer.fromJson<String>(json['fincaId']),
      nombre: serializer.fromJson<String>(json['nombre']),
      numero: serializer.fromJson<int?>(json['numero']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      pendiente: serializer.fromJson<bool>(json['pendiente']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'fincaId': serializer.toJson<String>(fincaId),
      'nombre': serializer.toJson<String>(nombre),
      'numero': serializer.toJson<int?>(numero),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'pendiente': serializer.toJson<bool>(pendiente),
    };
  }

  LoteRow copyWith({
    String? id,
    String? fincaId,
    String? nombre,
    Value<int?> numero = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    bool? pendiente,
  }) => LoteRow(
    id: id ?? this.id,
    fincaId: fincaId ?? this.fincaId,
    nombre: nombre ?? this.nombre,
    numero: numero.present ? numero.value : this.numero,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    pendiente: pendiente ?? this.pendiente,
  );
  LoteRow copyWithCompanion(LotesCompanion data) {
    return LoteRow(
      id: data.id.present ? data.id.value : this.id,
      fincaId: data.fincaId.present ? data.fincaId.value : this.fincaId,
      nombre: data.nombre.present ? data.nombre.value : this.nombre,
      numero: data.numero.present ? data.numero.value : this.numero,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      pendiente: data.pendiente.present ? data.pendiente.value : this.pendiente,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LoteRow(')
          ..write('id: $id, ')
          ..write('fincaId: $fincaId, ')
          ..write('nombre: $nombre, ')
          ..write('numero: $numero, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('pendiente: $pendiente')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    fincaId,
    nombre,
    numero,
    createdAt,
    updatedAt,
    deletedAt,
    pendiente,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LoteRow &&
          other.id == this.id &&
          other.fincaId == this.fincaId &&
          other.nombre == this.nombre &&
          other.numero == this.numero &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.pendiente == this.pendiente);
}

class LotesCompanion extends UpdateCompanion<LoteRow> {
  final Value<String> id;
  final Value<String> fincaId;
  final Value<String> nombre;
  final Value<int?> numero;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<bool> pendiente;
  final Value<int> rowid;
  const LotesCompanion({
    this.id = const Value.absent(),
    this.fincaId = const Value.absent(),
    this.nombre = const Value.absent(),
    this.numero = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.pendiente = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LotesCompanion.insert({
    required String id,
    required String fincaId,
    required String nombre,
    this.numero = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.pendiente = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       fincaId = Value(fincaId),
       nombre = Value(nombre),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<LoteRow> custom({
    Expression<String>? id,
    Expression<String>? fincaId,
    Expression<String>? nombre,
    Expression<int>? numero,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<bool>? pendiente,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (fincaId != null) 'finca_id': fincaId,
      if (nombre != null) 'nombre': nombre,
      if (numero != null) 'numero': numero,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (pendiente != null) 'pendiente': pendiente,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LotesCompanion copyWith({
    Value<String>? id,
    Value<String>? fincaId,
    Value<String>? nombre,
    Value<int?>? numero,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<bool>? pendiente,
    Value<int>? rowid,
  }) {
    return LotesCompanion(
      id: id ?? this.id,
      fincaId: fincaId ?? this.fincaId,
      nombre: nombre ?? this.nombre,
      numero: numero ?? this.numero,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      pendiente: pendiente ?? this.pendiente,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (fincaId.present) {
      map['finca_id'] = Variable<String>(fincaId.value);
    }
    if (nombre.present) {
      map['nombre'] = Variable<String>(nombre.value);
    }
    if (numero.present) {
      map['numero'] = Variable<int>(numero.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (pendiente.present) {
      map['pendiente'] = Variable<bool>(pendiente.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LotesCompanion(')
          ..write('id: $id, ')
          ..write('fincaId: $fincaId, ')
          ..write('nombre: $nombre, ')
          ..write('numero: $numero, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('pendiente: $pendiente, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AnimalesTable extends Animales
    with TableInfo<$AnimalesTable, AnimalRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AnimalesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fincaIdMeta = const VerificationMeta(
    'fincaId',
  );
  @override
  late final GeneratedColumn<String> fincaId = GeneratedColumn<String>(
    'finca_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _loteIdMeta = const VerificationMeta('loteId');
  @override
  late final GeneratedColumn<String> loteId = GeneratedColumn<String>(
    'lote_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _identificadorMeta = const VerificationMeta(
    'identificador',
  );
  @override
  late final GeneratedColumn<String> identificador = GeneratedColumn<String>(
    'identificador',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pendienteMeta = const VerificationMeta(
    'pendiente',
  );
  @override
  late final GeneratedColumn<bool> pendiente = GeneratedColumn<bool>(
    'pendiente',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("pendiente" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    fincaId,
    loteId,
    identificador,
    createdAt,
    updatedAt,
    deletedAt,
    pendiente,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'animales';
  @override
  VerificationContext validateIntegrity(
    Insertable<AnimalRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('finca_id')) {
      context.handle(
        _fincaIdMeta,
        fincaId.isAcceptableOrUnknown(data['finca_id']!, _fincaIdMeta),
      );
    } else if (isInserting) {
      context.missing(_fincaIdMeta);
    }
    if (data.containsKey('lote_id')) {
      context.handle(
        _loteIdMeta,
        loteId.isAcceptableOrUnknown(data['lote_id']!, _loteIdMeta),
      );
    } else if (isInserting) {
      context.missing(_loteIdMeta);
    }
    if (data.containsKey('identificador')) {
      context.handle(
        _identificadorMeta,
        identificador.isAcceptableOrUnknown(
          data['identificador']!,
          _identificadorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_identificadorMeta);
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
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('pendiente')) {
      context.handle(
        _pendienteMeta,
        pendiente.isAcceptableOrUnknown(data['pendiente']!, _pendienteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AnimalRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AnimalRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      fincaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}finca_id'],
      )!,
      loteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lote_id'],
      )!,
      identificador: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}identificador'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      pendiente: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}pendiente'],
      )!,
    );
  }

  @override
  $AnimalesTable createAlias(String alias) {
    return $AnimalesTable(attachedDatabase, alias);
  }
}

class AnimalRow extends DataClass implements Insertable<AnimalRow> {
  final String id;
  final String fincaId;
  final String loteId;
  final String identificador;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final bool pendiente;
  const AnimalRow({
    required this.id,
    required this.fincaId,
    required this.loteId,
    required this.identificador,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.pendiente,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['finca_id'] = Variable<String>(fincaId);
    map['lote_id'] = Variable<String>(loteId);
    map['identificador'] = Variable<String>(identificador);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['pendiente'] = Variable<bool>(pendiente);
    return map;
  }

  AnimalesCompanion toCompanion(bool nullToAbsent) {
    return AnimalesCompanion(
      id: Value(id),
      fincaId: Value(fincaId),
      loteId: Value(loteId),
      identificador: Value(identificador),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      pendiente: Value(pendiente),
    );
  }

  factory AnimalRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AnimalRow(
      id: serializer.fromJson<String>(json['id']),
      fincaId: serializer.fromJson<String>(json['fincaId']),
      loteId: serializer.fromJson<String>(json['loteId']),
      identificador: serializer.fromJson<String>(json['identificador']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      pendiente: serializer.fromJson<bool>(json['pendiente']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'fincaId': serializer.toJson<String>(fincaId),
      'loteId': serializer.toJson<String>(loteId),
      'identificador': serializer.toJson<String>(identificador),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'pendiente': serializer.toJson<bool>(pendiente),
    };
  }

  AnimalRow copyWith({
    String? id,
    String? fincaId,
    String? loteId,
    String? identificador,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    bool? pendiente,
  }) => AnimalRow(
    id: id ?? this.id,
    fincaId: fincaId ?? this.fincaId,
    loteId: loteId ?? this.loteId,
    identificador: identificador ?? this.identificador,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    pendiente: pendiente ?? this.pendiente,
  );
  AnimalRow copyWithCompanion(AnimalesCompanion data) {
    return AnimalRow(
      id: data.id.present ? data.id.value : this.id,
      fincaId: data.fincaId.present ? data.fincaId.value : this.fincaId,
      loteId: data.loteId.present ? data.loteId.value : this.loteId,
      identificador: data.identificador.present
          ? data.identificador.value
          : this.identificador,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      pendiente: data.pendiente.present ? data.pendiente.value : this.pendiente,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AnimalRow(')
          ..write('id: $id, ')
          ..write('fincaId: $fincaId, ')
          ..write('loteId: $loteId, ')
          ..write('identificador: $identificador, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('pendiente: $pendiente')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    fincaId,
    loteId,
    identificador,
    createdAt,
    updatedAt,
    deletedAt,
    pendiente,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AnimalRow &&
          other.id == this.id &&
          other.fincaId == this.fincaId &&
          other.loteId == this.loteId &&
          other.identificador == this.identificador &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.pendiente == this.pendiente);
}

class AnimalesCompanion extends UpdateCompanion<AnimalRow> {
  final Value<String> id;
  final Value<String> fincaId;
  final Value<String> loteId;
  final Value<String> identificador;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<bool> pendiente;
  final Value<int> rowid;
  const AnimalesCompanion({
    this.id = const Value.absent(),
    this.fincaId = const Value.absent(),
    this.loteId = const Value.absent(),
    this.identificador = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.pendiente = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AnimalesCompanion.insert({
    required String id,
    required String fincaId,
    required String loteId,
    required String identificador,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.pendiente = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       fincaId = Value(fincaId),
       loteId = Value(loteId),
       identificador = Value(identificador),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<AnimalRow> custom({
    Expression<String>? id,
    Expression<String>? fincaId,
    Expression<String>? loteId,
    Expression<String>? identificador,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<bool>? pendiente,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (fincaId != null) 'finca_id': fincaId,
      if (loteId != null) 'lote_id': loteId,
      if (identificador != null) 'identificador': identificador,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (pendiente != null) 'pendiente': pendiente,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AnimalesCompanion copyWith({
    Value<String>? id,
    Value<String>? fincaId,
    Value<String>? loteId,
    Value<String>? identificador,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<bool>? pendiente,
    Value<int>? rowid,
  }) {
    return AnimalesCompanion(
      id: id ?? this.id,
      fincaId: fincaId ?? this.fincaId,
      loteId: loteId ?? this.loteId,
      identificador: identificador ?? this.identificador,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      pendiente: pendiente ?? this.pendiente,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (fincaId.present) {
      map['finca_id'] = Variable<String>(fincaId.value);
    }
    if (loteId.present) {
      map['lote_id'] = Variable<String>(loteId.value);
    }
    if (identificador.present) {
      map['identificador'] = Variable<String>(identificador.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (pendiente.present) {
      map['pendiente'] = Variable<bool>(pendiente.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AnimalesCompanion(')
          ..write('id: $id, ')
          ..write('fincaId: $fincaId, ')
          ..write('loteId: $loteId, ')
          ..write('identificador: $identificador, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('pendiente: $pendiente, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PesajesTable extends Pesajes with TableInfo<$PesajesTable, PesajeRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PesajesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _animalIdMeta = const VerificationMeta(
    'animalId',
  );
  @override
  late final GeneratedColumn<String> animalId = GeneratedColumn<String>(
    'animal_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pesoMeta = const VerificationMeta('peso');
  @override
  late final GeneratedColumn<double> peso = GeneratedColumn<double>(
    'peso',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fechaMeta = const VerificationMeta('fecha');
  @override
  late final GeneratedColumn<DateTime> fecha = GeneratedColumn<DateTime>(
    'fecha',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _registradoPorMeta = const VerificationMeta(
    'registradoPor',
  );
  @override
  late final GeneratedColumn<String> registradoPor = GeneratedColumn<String>(
    'registrado_por',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pendienteMeta = const VerificationMeta(
    'pendiente',
  );
  @override
  late final GeneratedColumn<bool> pendiente = GeneratedColumn<bool>(
    'pendiente',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("pendiente" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    animalId,
    peso,
    fecha,
    registradoPor,
    createdAt,
    updatedAt,
    deletedAt,
    pendiente,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pesajes';
  @override
  VerificationContext validateIntegrity(
    Insertable<PesajeRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('animal_id')) {
      context.handle(
        _animalIdMeta,
        animalId.isAcceptableOrUnknown(data['animal_id']!, _animalIdMeta),
      );
    } else if (isInserting) {
      context.missing(_animalIdMeta);
    }
    if (data.containsKey('peso')) {
      context.handle(
        _pesoMeta,
        peso.isAcceptableOrUnknown(data['peso']!, _pesoMeta),
      );
    } else if (isInserting) {
      context.missing(_pesoMeta);
    }
    if (data.containsKey('fecha')) {
      context.handle(
        _fechaMeta,
        fecha.isAcceptableOrUnknown(data['fecha']!, _fechaMeta),
      );
    } else if (isInserting) {
      context.missing(_fechaMeta);
    }
    if (data.containsKey('registrado_por')) {
      context.handle(
        _registradoPorMeta,
        registradoPor.isAcceptableOrUnknown(
          data['registrado_por']!,
          _registradoPorMeta,
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
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('pendiente')) {
      context.handle(
        _pendienteMeta,
        pendiente.isAcceptableOrUnknown(data['pendiente']!, _pendienteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PesajeRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PesajeRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      animalId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}animal_id'],
      )!,
      peso: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}peso'],
      )!,
      fecha: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fecha'],
      )!,
      registradoPor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}registrado_por'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      pendiente: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}pendiente'],
      )!,
    );
  }

  @override
  $PesajesTable createAlias(String alias) {
    return $PesajesTable(attachedDatabase, alias);
  }
}

class PesajeRow extends DataClass implements Insertable<PesajeRow> {
  final String id;
  final String animalId;
  final double peso;
  final DateTime fecha;
  final String? registradoPor;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final bool pendiente;
  const PesajeRow({
    required this.id,
    required this.animalId,
    required this.peso,
    required this.fecha,
    this.registradoPor,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.pendiente,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['animal_id'] = Variable<String>(animalId);
    map['peso'] = Variable<double>(peso);
    map['fecha'] = Variable<DateTime>(fecha);
    if (!nullToAbsent || registradoPor != null) {
      map['registrado_por'] = Variable<String>(registradoPor);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['pendiente'] = Variable<bool>(pendiente);
    return map;
  }

  PesajesCompanion toCompanion(bool nullToAbsent) {
    return PesajesCompanion(
      id: Value(id),
      animalId: Value(animalId),
      peso: Value(peso),
      fecha: Value(fecha),
      registradoPor: registradoPor == null && nullToAbsent
          ? const Value.absent()
          : Value(registradoPor),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      pendiente: Value(pendiente),
    );
  }

  factory PesajeRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PesajeRow(
      id: serializer.fromJson<String>(json['id']),
      animalId: serializer.fromJson<String>(json['animalId']),
      peso: serializer.fromJson<double>(json['peso']),
      fecha: serializer.fromJson<DateTime>(json['fecha']),
      registradoPor: serializer.fromJson<String?>(json['registradoPor']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      pendiente: serializer.fromJson<bool>(json['pendiente']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'animalId': serializer.toJson<String>(animalId),
      'peso': serializer.toJson<double>(peso),
      'fecha': serializer.toJson<DateTime>(fecha),
      'registradoPor': serializer.toJson<String?>(registradoPor),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'pendiente': serializer.toJson<bool>(pendiente),
    };
  }

  PesajeRow copyWith({
    String? id,
    String? animalId,
    double? peso,
    DateTime? fecha,
    Value<String?> registradoPor = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    bool? pendiente,
  }) => PesajeRow(
    id: id ?? this.id,
    animalId: animalId ?? this.animalId,
    peso: peso ?? this.peso,
    fecha: fecha ?? this.fecha,
    registradoPor: registradoPor.present
        ? registradoPor.value
        : this.registradoPor,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    pendiente: pendiente ?? this.pendiente,
  );
  PesajeRow copyWithCompanion(PesajesCompanion data) {
    return PesajeRow(
      id: data.id.present ? data.id.value : this.id,
      animalId: data.animalId.present ? data.animalId.value : this.animalId,
      peso: data.peso.present ? data.peso.value : this.peso,
      fecha: data.fecha.present ? data.fecha.value : this.fecha,
      registradoPor: data.registradoPor.present
          ? data.registradoPor.value
          : this.registradoPor,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      pendiente: data.pendiente.present ? data.pendiente.value : this.pendiente,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PesajeRow(')
          ..write('id: $id, ')
          ..write('animalId: $animalId, ')
          ..write('peso: $peso, ')
          ..write('fecha: $fecha, ')
          ..write('registradoPor: $registradoPor, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('pendiente: $pendiente')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    animalId,
    peso,
    fecha,
    registradoPor,
    createdAt,
    updatedAt,
    deletedAt,
    pendiente,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PesajeRow &&
          other.id == this.id &&
          other.animalId == this.animalId &&
          other.peso == this.peso &&
          other.fecha == this.fecha &&
          other.registradoPor == this.registradoPor &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.pendiente == this.pendiente);
}

class PesajesCompanion extends UpdateCompanion<PesajeRow> {
  final Value<String> id;
  final Value<String> animalId;
  final Value<double> peso;
  final Value<DateTime> fecha;
  final Value<String?> registradoPor;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<bool> pendiente;
  final Value<int> rowid;
  const PesajesCompanion({
    this.id = const Value.absent(),
    this.animalId = const Value.absent(),
    this.peso = const Value.absent(),
    this.fecha = const Value.absent(),
    this.registradoPor = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.pendiente = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PesajesCompanion.insert({
    required String id,
    required String animalId,
    required double peso,
    required DateTime fecha,
    this.registradoPor = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.pendiente = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       animalId = Value(animalId),
       peso = Value(peso),
       fecha = Value(fecha),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<PesajeRow> custom({
    Expression<String>? id,
    Expression<String>? animalId,
    Expression<double>? peso,
    Expression<DateTime>? fecha,
    Expression<String>? registradoPor,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<bool>? pendiente,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (animalId != null) 'animal_id': animalId,
      if (peso != null) 'peso': peso,
      if (fecha != null) 'fecha': fecha,
      if (registradoPor != null) 'registrado_por': registradoPor,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (pendiente != null) 'pendiente': pendiente,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PesajesCompanion copyWith({
    Value<String>? id,
    Value<String>? animalId,
    Value<double>? peso,
    Value<DateTime>? fecha,
    Value<String?>? registradoPor,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<bool>? pendiente,
    Value<int>? rowid,
  }) {
    return PesajesCompanion(
      id: id ?? this.id,
      animalId: animalId ?? this.animalId,
      peso: peso ?? this.peso,
      fecha: fecha ?? this.fecha,
      registradoPor: registradoPor ?? this.registradoPor,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      pendiente: pendiente ?? this.pendiente,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (animalId.present) {
      map['animal_id'] = Variable<String>(animalId.value);
    }
    if (peso.present) {
      map['peso'] = Variable<double>(peso.value);
    }
    if (fecha.present) {
      map['fecha'] = Variable<DateTime>(fecha.value);
    }
    if (registradoPor.present) {
      map['registrado_por'] = Variable<String>(registradoPor.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (pendiente.present) {
      map['pendiente'] = Variable<bool>(pendiente.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PesajesCompanion(')
          ..write('id: $id, ')
          ..write('animalId: $animalId, ')
          ..write('peso: $peso, ')
          ..write('fecha: $fecha, ')
          ..write('registradoPor: $registradoPor, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('pendiente: $pendiente, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncCursoresTable extends SyncCursores
    with TableInfo<$SyncCursoresTable, SyncCursorRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncCursoresTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _tablaMeta = const VerificationMeta('tabla');
  @override
  late final GeneratedColumn<String> tabla = GeneratedColumn<String>(
    'tabla',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ultimaBajadaMeta = const VerificationMeta(
    'ultimaBajada',
  );
  @override
  late final GeneratedColumn<DateTime> ultimaBajada = GeneratedColumn<DateTime>(
    'ultima_bajada',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [tabla, ultimaBajada];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_cursores';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncCursorRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('tabla')) {
      context.handle(
        _tablaMeta,
        tabla.isAcceptableOrUnknown(data['tabla']!, _tablaMeta),
      );
    } else if (isInserting) {
      context.missing(_tablaMeta);
    }
    if (data.containsKey('ultima_bajada')) {
      context.handle(
        _ultimaBajadaMeta,
        ultimaBajada.isAcceptableOrUnknown(
          data['ultima_bajada']!,
          _ultimaBajadaMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {tabla};
  @override
  SyncCursorRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncCursorRow(
      tabla: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tabla'],
      )!,
      ultimaBajada: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ultima_bajada'],
      ),
    );
  }

  @override
  $SyncCursoresTable createAlias(String alias) {
    return $SyncCursoresTable(attachedDatabase, alias);
  }
}

class SyncCursorRow extends DataClass implements Insertable<SyncCursorRow> {
  final String tabla;
  final DateTime? ultimaBajada;
  const SyncCursorRow({required this.tabla, this.ultimaBajada});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['tabla'] = Variable<String>(tabla);
    if (!nullToAbsent || ultimaBajada != null) {
      map['ultima_bajada'] = Variable<DateTime>(ultimaBajada);
    }
    return map;
  }

  SyncCursoresCompanion toCompanion(bool nullToAbsent) {
    return SyncCursoresCompanion(
      tabla: Value(tabla),
      ultimaBajada: ultimaBajada == null && nullToAbsent
          ? const Value.absent()
          : Value(ultimaBajada),
    );
  }

  factory SyncCursorRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncCursorRow(
      tabla: serializer.fromJson<String>(json['tabla']),
      ultimaBajada: serializer.fromJson<DateTime?>(json['ultimaBajada']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'tabla': serializer.toJson<String>(tabla),
      'ultimaBajada': serializer.toJson<DateTime?>(ultimaBajada),
    };
  }

  SyncCursorRow copyWith({
    String? tabla,
    Value<DateTime?> ultimaBajada = const Value.absent(),
  }) => SyncCursorRow(
    tabla: tabla ?? this.tabla,
    ultimaBajada: ultimaBajada.present ? ultimaBajada.value : this.ultimaBajada,
  );
  SyncCursorRow copyWithCompanion(SyncCursoresCompanion data) {
    return SyncCursorRow(
      tabla: data.tabla.present ? data.tabla.value : this.tabla,
      ultimaBajada: data.ultimaBajada.present
          ? data.ultimaBajada.value
          : this.ultimaBajada,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncCursorRow(')
          ..write('tabla: $tabla, ')
          ..write('ultimaBajada: $ultimaBajada')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(tabla, ultimaBajada);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncCursorRow &&
          other.tabla == this.tabla &&
          other.ultimaBajada == this.ultimaBajada);
}

class SyncCursoresCompanion extends UpdateCompanion<SyncCursorRow> {
  final Value<String> tabla;
  final Value<DateTime?> ultimaBajada;
  final Value<int> rowid;
  const SyncCursoresCompanion({
    this.tabla = const Value.absent(),
    this.ultimaBajada = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncCursoresCompanion.insert({
    required String tabla,
    this.ultimaBajada = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : tabla = Value(tabla);
  static Insertable<SyncCursorRow> custom({
    Expression<String>? tabla,
    Expression<DateTime>? ultimaBajada,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (tabla != null) 'tabla': tabla,
      if (ultimaBajada != null) 'ultima_bajada': ultimaBajada,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncCursoresCompanion copyWith({
    Value<String>? tabla,
    Value<DateTime?>? ultimaBajada,
    Value<int>? rowid,
  }) {
    return SyncCursoresCompanion(
      tabla: tabla ?? this.tabla,
      ultimaBajada: ultimaBajada ?? this.ultimaBajada,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (tabla.present) {
      map['tabla'] = Variable<String>(tabla.value);
    }
    if (ultimaBajada.present) {
      map['ultima_bajada'] = Variable<DateTime>(ultimaBajada.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncCursoresCompanion(')
          ..write('tabla: $tabla, ')
          ..write('ultimaBajada: $ultimaBajada, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PlanesTable planes = $PlanesTable(this);
  late final $CuentasTable cuentas = $CuentasTable(this);
  late final $UsuariosTable usuarios = $UsuariosTable(this);
  late final $FincasTable fincas = $FincasTable(this);
  late final $FincaMiembrosTable fincaMiembros = $FincaMiembrosTable(this);
  late final $LotesTable lotes = $LotesTable(this);
  late final $AnimalesTable animales = $AnimalesTable(this);
  late final $PesajesTable pesajes = $PesajesTable(this);
  late final $SyncCursoresTable syncCursores = $SyncCursoresTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    planes,
    cuentas,
    usuarios,
    fincas,
    fincaMiembros,
    lotes,
    animales,
    pesajes,
    syncCursores,
  ];
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);
}

typedef $$PlanesTableCreateCompanionBuilder =
    PlanesCompanion Function({
      required String codigo,
      required String nombre,
      required int limiteFincas,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$PlanesTableUpdateCompanionBuilder =
    PlanesCompanion Function({
      Value<String> codigo,
      Value<String> nombre,
      Value<int> limiteFincas,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$PlanesTableFilterComposer
    extends Composer<_$AppDatabase, $PlanesTable> {
  $$PlanesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get codigo => $composableBuilder(
    column: $table.codigo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get limiteFincas => $composableBuilder(
    column: $table.limiteFincas,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PlanesTableOrderingComposer
    extends Composer<_$AppDatabase, $PlanesTable> {
  $$PlanesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get codigo => $composableBuilder(
    column: $table.codigo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get limiteFincas => $composableBuilder(
    column: $table.limiteFincas,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlanesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlanesTable> {
  $$PlanesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get codigo =>
      $composableBuilder(column: $table.codigo, builder: (column) => column);

  GeneratedColumn<String> get nombre =>
      $composableBuilder(column: $table.nombre, builder: (column) => column);

  GeneratedColumn<int> get limiteFincas => $composableBuilder(
    column: $table.limiteFincas,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$PlanesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlanesTable,
          PlanRow,
          $$PlanesTableFilterComposer,
          $$PlanesTableOrderingComposer,
          $$PlanesTableAnnotationComposer,
          $$PlanesTableCreateCompanionBuilder,
          $$PlanesTableUpdateCompanionBuilder,
          (PlanRow, BaseReferences<_$AppDatabase, $PlanesTable, PlanRow>),
          PlanRow,
          PrefetchHooks Function()
        > {
  $$PlanesTableTableManager(_$AppDatabase db, $PlanesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlanesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlanesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlanesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> codigo = const Value.absent(),
                Value<String> nombre = const Value.absent(),
                Value<int> limiteFincas = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlanesCompanion(
                codigo: codigo,
                nombre: nombre,
                limiteFincas: limiteFincas,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String codigo,
                required String nombre,
                required int limiteFincas,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => PlanesCompanion.insert(
                codigo: codigo,
                nombre: nombre,
                limiteFincas: limiteFincas,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PlanesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlanesTable,
      PlanRow,
      $$PlanesTableFilterComposer,
      $$PlanesTableOrderingComposer,
      $$PlanesTableAnnotationComposer,
      $$PlanesTableCreateCompanionBuilder,
      $$PlanesTableUpdateCompanionBuilder,
      (PlanRow, BaseReferences<_$AppDatabase, $PlanesTable, PlanRow>),
      PlanRow,
      PrefetchHooks Function()
    >;
typedef $$CuentasTableCreateCompanionBuilder =
    CuentasCompanion Function({
      required String id,
      required String nombre,
      required String duenoId,
      required String plan,
      required String estado,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<bool> pendiente,
      Value<int> rowid,
    });
typedef $$CuentasTableUpdateCompanionBuilder =
    CuentasCompanion Function({
      Value<String> id,
      Value<String> nombre,
      Value<String> duenoId,
      Value<String> plan,
      Value<String> estado,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<bool> pendiente,
      Value<int> rowid,
    });

class $$CuentasTableFilterComposer
    extends Composer<_$AppDatabase, $CuentasTable> {
  $$CuentasTableFilterComposer({
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

  ColumnFilters<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get duenoId => $composableBuilder(
    column: $table.duenoId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get plan => $composableBuilder(
    column: $table.plan,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get estado => $composableBuilder(
    column: $table.estado,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get pendiente => $composableBuilder(
    column: $table.pendiente,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CuentasTableOrderingComposer
    extends Composer<_$AppDatabase, $CuentasTable> {
  $$CuentasTableOrderingComposer({
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

  ColumnOrderings<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get duenoId => $composableBuilder(
    column: $table.duenoId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get plan => $composableBuilder(
    column: $table.plan,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get estado => $composableBuilder(
    column: $table.estado,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get pendiente => $composableBuilder(
    column: $table.pendiente,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CuentasTableAnnotationComposer
    extends Composer<_$AppDatabase, $CuentasTable> {
  $$CuentasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nombre =>
      $composableBuilder(column: $table.nombre, builder: (column) => column);

  GeneratedColumn<String> get duenoId =>
      $composableBuilder(column: $table.duenoId, builder: (column) => column);

  GeneratedColumn<String> get plan =>
      $composableBuilder(column: $table.plan, builder: (column) => column);

  GeneratedColumn<String> get estado =>
      $composableBuilder(column: $table.estado, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<bool> get pendiente =>
      $composableBuilder(column: $table.pendiente, builder: (column) => column);
}

class $$CuentasTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CuentasTable,
          CuentaRow,
          $$CuentasTableFilterComposer,
          $$CuentasTableOrderingComposer,
          $$CuentasTableAnnotationComposer,
          $$CuentasTableCreateCompanionBuilder,
          $$CuentasTableUpdateCompanionBuilder,
          (CuentaRow, BaseReferences<_$AppDatabase, $CuentasTable, CuentaRow>),
          CuentaRow,
          PrefetchHooks Function()
        > {
  $$CuentasTableTableManager(_$AppDatabase db, $CuentasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CuentasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CuentasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CuentasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> nombre = const Value.absent(),
                Value<String> duenoId = const Value.absent(),
                Value<String> plan = const Value.absent(),
                Value<String> estado = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<bool> pendiente = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CuentasCompanion(
                id: id,
                nombre: nombre,
                duenoId: duenoId,
                plan: plan,
                estado: estado,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                pendiente: pendiente,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String nombre,
                required String duenoId,
                required String plan,
                required String estado,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<bool> pendiente = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CuentasCompanion.insert(
                id: id,
                nombre: nombre,
                duenoId: duenoId,
                plan: plan,
                estado: estado,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                pendiente: pendiente,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CuentasTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CuentasTable,
      CuentaRow,
      $$CuentasTableFilterComposer,
      $$CuentasTableOrderingComposer,
      $$CuentasTableAnnotationComposer,
      $$CuentasTableCreateCompanionBuilder,
      $$CuentasTableUpdateCompanionBuilder,
      (CuentaRow, BaseReferences<_$AppDatabase, $CuentasTable, CuentaRow>),
      CuentaRow,
      PrefetchHooks Function()
    >;
typedef $$UsuariosTableCreateCompanionBuilder =
    UsuariosCompanion Function({
      required String id,
      Value<String?> nombre,
      Value<String?> email,
      Value<String?> cuentaId,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<bool> pendiente,
      Value<int> rowid,
    });
typedef $$UsuariosTableUpdateCompanionBuilder =
    UsuariosCompanion Function({
      Value<String> id,
      Value<String?> nombre,
      Value<String?> email,
      Value<String?> cuentaId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> pendiente,
      Value<int> rowid,
    });

class $$UsuariosTableFilterComposer
    extends Composer<_$AppDatabase, $UsuariosTable> {
  $$UsuariosTableFilterComposer({
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

  ColumnFilters<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cuentaId => $composableBuilder(
    column: $table.cuentaId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get pendiente => $composableBuilder(
    column: $table.pendiente,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UsuariosTableOrderingComposer
    extends Composer<_$AppDatabase, $UsuariosTable> {
  $$UsuariosTableOrderingComposer({
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

  ColumnOrderings<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cuentaId => $composableBuilder(
    column: $table.cuentaId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get pendiente => $composableBuilder(
    column: $table.pendiente,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UsuariosTableAnnotationComposer
    extends Composer<_$AppDatabase, $UsuariosTable> {
  $$UsuariosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nombre =>
      $composableBuilder(column: $table.nombre, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get cuentaId =>
      $composableBuilder(column: $table.cuentaId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get pendiente =>
      $composableBuilder(column: $table.pendiente, builder: (column) => column);
}

class $$UsuariosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UsuariosTable,
          UsuarioRow,
          $$UsuariosTableFilterComposer,
          $$UsuariosTableOrderingComposer,
          $$UsuariosTableAnnotationComposer,
          $$UsuariosTableCreateCompanionBuilder,
          $$UsuariosTableUpdateCompanionBuilder,
          (
            UsuarioRow,
            BaseReferences<_$AppDatabase, $UsuariosTable, UsuarioRow>,
          ),
          UsuarioRow,
          PrefetchHooks Function()
        > {
  $$UsuariosTableTableManager(_$AppDatabase db, $UsuariosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsuariosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UsuariosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UsuariosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> nombre = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> cuentaId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> pendiente = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UsuariosCompanion(
                id: id,
                nombre: nombre,
                email: email,
                cuentaId: cuentaId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                pendiente: pendiente,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> nombre = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> cuentaId = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<bool> pendiente = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UsuariosCompanion.insert(
                id: id,
                nombre: nombre,
                email: email,
                cuentaId: cuentaId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                pendiente: pendiente,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UsuariosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UsuariosTable,
      UsuarioRow,
      $$UsuariosTableFilterComposer,
      $$UsuariosTableOrderingComposer,
      $$UsuariosTableAnnotationComposer,
      $$UsuariosTableCreateCompanionBuilder,
      $$UsuariosTableUpdateCompanionBuilder,
      (UsuarioRow, BaseReferences<_$AppDatabase, $UsuariosTable, UsuarioRow>),
      UsuarioRow,
      PrefetchHooks Function()
    >;
typedef $$FincasTableCreateCompanionBuilder =
    FincasCompanion Function({
      required String id,
      required String nombre,
      Value<String?> fotoUrl,
      required String creadaPor,
      Value<String?> cuentaId,
      Value<String?> fotoLocalPath,
      Value<bool> fotoPendiente,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<bool> pendiente,
      Value<int> rowid,
    });
typedef $$FincasTableUpdateCompanionBuilder =
    FincasCompanion Function({
      Value<String> id,
      Value<String> nombre,
      Value<String?> fotoUrl,
      Value<String> creadaPor,
      Value<String?> cuentaId,
      Value<String?> fotoLocalPath,
      Value<bool> fotoPendiente,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<bool> pendiente,
      Value<int> rowid,
    });

class $$FincasTableFilterComposer
    extends Composer<_$AppDatabase, $FincasTable> {
  $$FincasTableFilterComposer({
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

  ColumnFilters<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fotoUrl => $composableBuilder(
    column: $table.fotoUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get creadaPor => $composableBuilder(
    column: $table.creadaPor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cuentaId => $composableBuilder(
    column: $table.cuentaId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fotoLocalPath => $composableBuilder(
    column: $table.fotoLocalPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get fotoPendiente => $composableBuilder(
    column: $table.fotoPendiente,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get pendiente => $composableBuilder(
    column: $table.pendiente,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FincasTableOrderingComposer
    extends Composer<_$AppDatabase, $FincasTable> {
  $$FincasTableOrderingComposer({
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

  ColumnOrderings<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fotoUrl => $composableBuilder(
    column: $table.fotoUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get creadaPor => $composableBuilder(
    column: $table.creadaPor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cuentaId => $composableBuilder(
    column: $table.cuentaId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fotoLocalPath => $composableBuilder(
    column: $table.fotoLocalPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get fotoPendiente => $composableBuilder(
    column: $table.fotoPendiente,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get pendiente => $composableBuilder(
    column: $table.pendiente,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FincasTableAnnotationComposer
    extends Composer<_$AppDatabase, $FincasTable> {
  $$FincasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nombre =>
      $composableBuilder(column: $table.nombre, builder: (column) => column);

  GeneratedColumn<String> get fotoUrl =>
      $composableBuilder(column: $table.fotoUrl, builder: (column) => column);

  GeneratedColumn<String> get creadaPor =>
      $composableBuilder(column: $table.creadaPor, builder: (column) => column);

  GeneratedColumn<String> get cuentaId =>
      $composableBuilder(column: $table.cuentaId, builder: (column) => column);

  GeneratedColumn<String> get fotoLocalPath => $composableBuilder(
    column: $table.fotoLocalPath,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get fotoPendiente => $composableBuilder(
    column: $table.fotoPendiente,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<bool> get pendiente =>
      $composableBuilder(column: $table.pendiente, builder: (column) => column);
}

class $$FincasTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FincasTable,
          FincaRow,
          $$FincasTableFilterComposer,
          $$FincasTableOrderingComposer,
          $$FincasTableAnnotationComposer,
          $$FincasTableCreateCompanionBuilder,
          $$FincasTableUpdateCompanionBuilder,
          (FincaRow, BaseReferences<_$AppDatabase, $FincasTable, FincaRow>),
          FincaRow,
          PrefetchHooks Function()
        > {
  $$FincasTableTableManager(_$AppDatabase db, $FincasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FincasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FincasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FincasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> nombre = const Value.absent(),
                Value<String?> fotoUrl = const Value.absent(),
                Value<String> creadaPor = const Value.absent(),
                Value<String?> cuentaId = const Value.absent(),
                Value<String?> fotoLocalPath = const Value.absent(),
                Value<bool> fotoPendiente = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<bool> pendiente = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FincasCompanion(
                id: id,
                nombre: nombre,
                fotoUrl: fotoUrl,
                creadaPor: creadaPor,
                cuentaId: cuentaId,
                fotoLocalPath: fotoLocalPath,
                fotoPendiente: fotoPendiente,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                pendiente: pendiente,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String nombre,
                Value<String?> fotoUrl = const Value.absent(),
                required String creadaPor,
                Value<String?> cuentaId = const Value.absent(),
                Value<String?> fotoLocalPath = const Value.absent(),
                Value<bool> fotoPendiente = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<bool> pendiente = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FincasCompanion.insert(
                id: id,
                nombre: nombre,
                fotoUrl: fotoUrl,
                creadaPor: creadaPor,
                cuentaId: cuentaId,
                fotoLocalPath: fotoLocalPath,
                fotoPendiente: fotoPendiente,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                pendiente: pendiente,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FincasTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FincasTable,
      FincaRow,
      $$FincasTableFilterComposer,
      $$FincasTableOrderingComposer,
      $$FincasTableAnnotationComposer,
      $$FincasTableCreateCompanionBuilder,
      $$FincasTableUpdateCompanionBuilder,
      (FincaRow, BaseReferences<_$AppDatabase, $FincasTable, FincaRow>),
      FincaRow,
      PrefetchHooks Function()
    >;
typedef $$FincaMiembrosTableCreateCompanionBuilder =
    FincaMiembrosCompanion Function({
      required String id,
      required String fincaId,
      required String usuarioId,
      required String rol,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<bool> pendiente,
      Value<int> rowid,
    });
typedef $$FincaMiembrosTableUpdateCompanionBuilder =
    FincaMiembrosCompanion Function({
      Value<String> id,
      Value<String> fincaId,
      Value<String> usuarioId,
      Value<String> rol,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<bool> pendiente,
      Value<int> rowid,
    });

class $$FincaMiembrosTableFilterComposer
    extends Composer<_$AppDatabase, $FincaMiembrosTable> {
  $$FincaMiembrosTableFilterComposer({
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

  ColumnFilters<String> get fincaId => $composableBuilder(
    column: $table.fincaId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get usuarioId => $composableBuilder(
    column: $table.usuarioId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rol => $composableBuilder(
    column: $table.rol,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get pendiente => $composableBuilder(
    column: $table.pendiente,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FincaMiembrosTableOrderingComposer
    extends Composer<_$AppDatabase, $FincaMiembrosTable> {
  $$FincaMiembrosTableOrderingComposer({
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

  ColumnOrderings<String> get fincaId => $composableBuilder(
    column: $table.fincaId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get usuarioId => $composableBuilder(
    column: $table.usuarioId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rol => $composableBuilder(
    column: $table.rol,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get pendiente => $composableBuilder(
    column: $table.pendiente,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FincaMiembrosTableAnnotationComposer
    extends Composer<_$AppDatabase, $FincaMiembrosTable> {
  $$FincaMiembrosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get fincaId =>
      $composableBuilder(column: $table.fincaId, builder: (column) => column);

  GeneratedColumn<String> get usuarioId =>
      $composableBuilder(column: $table.usuarioId, builder: (column) => column);

  GeneratedColumn<String> get rol =>
      $composableBuilder(column: $table.rol, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<bool> get pendiente =>
      $composableBuilder(column: $table.pendiente, builder: (column) => column);
}

class $$FincaMiembrosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FincaMiembrosTable,
          FincaMiembroRow,
          $$FincaMiembrosTableFilterComposer,
          $$FincaMiembrosTableOrderingComposer,
          $$FincaMiembrosTableAnnotationComposer,
          $$FincaMiembrosTableCreateCompanionBuilder,
          $$FincaMiembrosTableUpdateCompanionBuilder,
          (
            FincaMiembroRow,
            BaseReferences<_$AppDatabase, $FincaMiembrosTable, FincaMiembroRow>,
          ),
          FincaMiembroRow,
          PrefetchHooks Function()
        > {
  $$FincaMiembrosTableTableManager(_$AppDatabase db, $FincaMiembrosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FincaMiembrosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FincaMiembrosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FincaMiembrosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> fincaId = const Value.absent(),
                Value<String> usuarioId = const Value.absent(),
                Value<String> rol = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<bool> pendiente = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FincaMiembrosCompanion(
                id: id,
                fincaId: fincaId,
                usuarioId: usuarioId,
                rol: rol,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                pendiente: pendiente,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String fincaId,
                required String usuarioId,
                required String rol,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<bool> pendiente = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FincaMiembrosCompanion.insert(
                id: id,
                fincaId: fincaId,
                usuarioId: usuarioId,
                rol: rol,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                pendiente: pendiente,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FincaMiembrosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FincaMiembrosTable,
      FincaMiembroRow,
      $$FincaMiembrosTableFilterComposer,
      $$FincaMiembrosTableOrderingComposer,
      $$FincaMiembrosTableAnnotationComposer,
      $$FincaMiembrosTableCreateCompanionBuilder,
      $$FincaMiembrosTableUpdateCompanionBuilder,
      (
        FincaMiembroRow,
        BaseReferences<_$AppDatabase, $FincaMiembrosTable, FincaMiembroRow>,
      ),
      FincaMiembroRow,
      PrefetchHooks Function()
    >;
typedef $$LotesTableCreateCompanionBuilder =
    LotesCompanion Function({
      required String id,
      required String fincaId,
      required String nombre,
      Value<int?> numero,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<bool> pendiente,
      Value<int> rowid,
    });
typedef $$LotesTableUpdateCompanionBuilder =
    LotesCompanion Function({
      Value<String> id,
      Value<String> fincaId,
      Value<String> nombre,
      Value<int?> numero,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<bool> pendiente,
      Value<int> rowid,
    });

class $$LotesTableFilterComposer extends Composer<_$AppDatabase, $LotesTable> {
  $$LotesTableFilterComposer({
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

  ColumnFilters<String> get fincaId => $composableBuilder(
    column: $table.fincaId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get numero => $composableBuilder(
    column: $table.numero,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get pendiente => $composableBuilder(
    column: $table.pendiente,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LotesTableOrderingComposer
    extends Composer<_$AppDatabase, $LotesTable> {
  $$LotesTableOrderingComposer({
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

  ColumnOrderings<String> get fincaId => $composableBuilder(
    column: $table.fincaId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get numero => $composableBuilder(
    column: $table.numero,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get pendiente => $composableBuilder(
    column: $table.pendiente,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LotesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LotesTable> {
  $$LotesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get fincaId =>
      $composableBuilder(column: $table.fincaId, builder: (column) => column);

  GeneratedColumn<String> get nombre =>
      $composableBuilder(column: $table.nombre, builder: (column) => column);

  GeneratedColumn<int> get numero =>
      $composableBuilder(column: $table.numero, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<bool> get pendiente =>
      $composableBuilder(column: $table.pendiente, builder: (column) => column);
}

class $$LotesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LotesTable,
          LoteRow,
          $$LotesTableFilterComposer,
          $$LotesTableOrderingComposer,
          $$LotesTableAnnotationComposer,
          $$LotesTableCreateCompanionBuilder,
          $$LotesTableUpdateCompanionBuilder,
          (LoteRow, BaseReferences<_$AppDatabase, $LotesTable, LoteRow>),
          LoteRow,
          PrefetchHooks Function()
        > {
  $$LotesTableTableManager(_$AppDatabase db, $LotesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LotesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LotesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LotesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> fincaId = const Value.absent(),
                Value<String> nombre = const Value.absent(),
                Value<int?> numero = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<bool> pendiente = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LotesCompanion(
                id: id,
                fincaId: fincaId,
                nombre: nombre,
                numero: numero,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                pendiente: pendiente,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String fincaId,
                required String nombre,
                Value<int?> numero = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<bool> pendiente = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LotesCompanion.insert(
                id: id,
                fincaId: fincaId,
                nombre: nombre,
                numero: numero,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                pendiente: pendiente,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LotesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LotesTable,
      LoteRow,
      $$LotesTableFilterComposer,
      $$LotesTableOrderingComposer,
      $$LotesTableAnnotationComposer,
      $$LotesTableCreateCompanionBuilder,
      $$LotesTableUpdateCompanionBuilder,
      (LoteRow, BaseReferences<_$AppDatabase, $LotesTable, LoteRow>),
      LoteRow,
      PrefetchHooks Function()
    >;
typedef $$AnimalesTableCreateCompanionBuilder =
    AnimalesCompanion Function({
      required String id,
      required String fincaId,
      required String loteId,
      required String identificador,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<bool> pendiente,
      Value<int> rowid,
    });
typedef $$AnimalesTableUpdateCompanionBuilder =
    AnimalesCompanion Function({
      Value<String> id,
      Value<String> fincaId,
      Value<String> loteId,
      Value<String> identificador,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<bool> pendiente,
      Value<int> rowid,
    });

class $$AnimalesTableFilterComposer
    extends Composer<_$AppDatabase, $AnimalesTable> {
  $$AnimalesTableFilterComposer({
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

  ColumnFilters<String> get fincaId => $composableBuilder(
    column: $table.fincaId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get loteId => $composableBuilder(
    column: $table.loteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get identificador => $composableBuilder(
    column: $table.identificador,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get pendiente => $composableBuilder(
    column: $table.pendiente,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AnimalesTableOrderingComposer
    extends Composer<_$AppDatabase, $AnimalesTable> {
  $$AnimalesTableOrderingComposer({
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

  ColumnOrderings<String> get fincaId => $composableBuilder(
    column: $table.fincaId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get loteId => $composableBuilder(
    column: $table.loteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get identificador => $composableBuilder(
    column: $table.identificador,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get pendiente => $composableBuilder(
    column: $table.pendiente,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AnimalesTableAnnotationComposer
    extends Composer<_$AppDatabase, $AnimalesTable> {
  $$AnimalesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get fincaId =>
      $composableBuilder(column: $table.fincaId, builder: (column) => column);

  GeneratedColumn<String> get loteId =>
      $composableBuilder(column: $table.loteId, builder: (column) => column);

  GeneratedColumn<String> get identificador => $composableBuilder(
    column: $table.identificador,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<bool> get pendiente =>
      $composableBuilder(column: $table.pendiente, builder: (column) => column);
}

class $$AnimalesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AnimalesTable,
          AnimalRow,
          $$AnimalesTableFilterComposer,
          $$AnimalesTableOrderingComposer,
          $$AnimalesTableAnnotationComposer,
          $$AnimalesTableCreateCompanionBuilder,
          $$AnimalesTableUpdateCompanionBuilder,
          (AnimalRow, BaseReferences<_$AppDatabase, $AnimalesTable, AnimalRow>),
          AnimalRow,
          PrefetchHooks Function()
        > {
  $$AnimalesTableTableManager(_$AppDatabase db, $AnimalesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AnimalesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AnimalesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AnimalesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> fincaId = const Value.absent(),
                Value<String> loteId = const Value.absent(),
                Value<String> identificador = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<bool> pendiente = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AnimalesCompanion(
                id: id,
                fincaId: fincaId,
                loteId: loteId,
                identificador: identificador,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                pendiente: pendiente,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String fincaId,
                required String loteId,
                required String identificador,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<bool> pendiente = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AnimalesCompanion.insert(
                id: id,
                fincaId: fincaId,
                loteId: loteId,
                identificador: identificador,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                pendiente: pendiente,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AnimalesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AnimalesTable,
      AnimalRow,
      $$AnimalesTableFilterComposer,
      $$AnimalesTableOrderingComposer,
      $$AnimalesTableAnnotationComposer,
      $$AnimalesTableCreateCompanionBuilder,
      $$AnimalesTableUpdateCompanionBuilder,
      (AnimalRow, BaseReferences<_$AppDatabase, $AnimalesTable, AnimalRow>),
      AnimalRow,
      PrefetchHooks Function()
    >;
typedef $$PesajesTableCreateCompanionBuilder =
    PesajesCompanion Function({
      required String id,
      required String animalId,
      required double peso,
      required DateTime fecha,
      Value<String?> registradoPor,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<bool> pendiente,
      Value<int> rowid,
    });
typedef $$PesajesTableUpdateCompanionBuilder =
    PesajesCompanion Function({
      Value<String> id,
      Value<String> animalId,
      Value<double> peso,
      Value<DateTime> fecha,
      Value<String?> registradoPor,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<bool> pendiente,
      Value<int> rowid,
    });

class $$PesajesTableFilterComposer
    extends Composer<_$AppDatabase, $PesajesTable> {
  $$PesajesTableFilterComposer({
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

  ColumnFilters<String> get animalId => $composableBuilder(
    column: $table.animalId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get peso => $composableBuilder(
    column: $table.peso,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fecha => $composableBuilder(
    column: $table.fecha,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get registradoPor => $composableBuilder(
    column: $table.registradoPor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get pendiente => $composableBuilder(
    column: $table.pendiente,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PesajesTableOrderingComposer
    extends Composer<_$AppDatabase, $PesajesTable> {
  $$PesajesTableOrderingComposer({
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

  ColumnOrderings<String> get animalId => $composableBuilder(
    column: $table.animalId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get peso => $composableBuilder(
    column: $table.peso,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fecha => $composableBuilder(
    column: $table.fecha,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get registradoPor => $composableBuilder(
    column: $table.registradoPor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get pendiente => $composableBuilder(
    column: $table.pendiente,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PesajesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PesajesTable> {
  $$PesajesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get animalId =>
      $composableBuilder(column: $table.animalId, builder: (column) => column);

  GeneratedColumn<double> get peso =>
      $composableBuilder(column: $table.peso, builder: (column) => column);

  GeneratedColumn<DateTime> get fecha =>
      $composableBuilder(column: $table.fecha, builder: (column) => column);

  GeneratedColumn<String> get registradoPor => $composableBuilder(
    column: $table.registradoPor,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<bool> get pendiente =>
      $composableBuilder(column: $table.pendiente, builder: (column) => column);
}

class $$PesajesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PesajesTable,
          PesajeRow,
          $$PesajesTableFilterComposer,
          $$PesajesTableOrderingComposer,
          $$PesajesTableAnnotationComposer,
          $$PesajesTableCreateCompanionBuilder,
          $$PesajesTableUpdateCompanionBuilder,
          (PesajeRow, BaseReferences<_$AppDatabase, $PesajesTable, PesajeRow>),
          PesajeRow,
          PrefetchHooks Function()
        > {
  $$PesajesTableTableManager(_$AppDatabase db, $PesajesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PesajesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PesajesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PesajesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> animalId = const Value.absent(),
                Value<double> peso = const Value.absent(),
                Value<DateTime> fecha = const Value.absent(),
                Value<String?> registradoPor = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<bool> pendiente = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PesajesCompanion(
                id: id,
                animalId: animalId,
                peso: peso,
                fecha: fecha,
                registradoPor: registradoPor,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                pendiente: pendiente,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String animalId,
                required double peso,
                required DateTime fecha,
                Value<String?> registradoPor = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<bool> pendiente = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PesajesCompanion.insert(
                id: id,
                animalId: animalId,
                peso: peso,
                fecha: fecha,
                registradoPor: registradoPor,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                pendiente: pendiente,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PesajesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PesajesTable,
      PesajeRow,
      $$PesajesTableFilterComposer,
      $$PesajesTableOrderingComposer,
      $$PesajesTableAnnotationComposer,
      $$PesajesTableCreateCompanionBuilder,
      $$PesajesTableUpdateCompanionBuilder,
      (PesajeRow, BaseReferences<_$AppDatabase, $PesajesTable, PesajeRow>),
      PesajeRow,
      PrefetchHooks Function()
    >;
typedef $$SyncCursoresTableCreateCompanionBuilder =
    SyncCursoresCompanion Function({
      required String tabla,
      Value<DateTime?> ultimaBajada,
      Value<int> rowid,
    });
typedef $$SyncCursoresTableUpdateCompanionBuilder =
    SyncCursoresCompanion Function({
      Value<String> tabla,
      Value<DateTime?> ultimaBajada,
      Value<int> rowid,
    });

class $$SyncCursoresTableFilterComposer
    extends Composer<_$AppDatabase, $SyncCursoresTable> {
  $$SyncCursoresTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get tabla => $composableBuilder(
    column: $table.tabla,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get ultimaBajada => $composableBuilder(
    column: $table.ultimaBajada,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncCursoresTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncCursoresTable> {
  $$SyncCursoresTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get tabla => $composableBuilder(
    column: $table.tabla,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get ultimaBajada => $composableBuilder(
    column: $table.ultimaBajada,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncCursoresTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncCursoresTable> {
  $$SyncCursoresTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get tabla =>
      $composableBuilder(column: $table.tabla, builder: (column) => column);

  GeneratedColumn<DateTime> get ultimaBajada => $composableBuilder(
    column: $table.ultimaBajada,
    builder: (column) => column,
  );
}

class $$SyncCursoresTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncCursoresTable,
          SyncCursorRow,
          $$SyncCursoresTableFilterComposer,
          $$SyncCursoresTableOrderingComposer,
          $$SyncCursoresTableAnnotationComposer,
          $$SyncCursoresTableCreateCompanionBuilder,
          $$SyncCursoresTableUpdateCompanionBuilder,
          (
            SyncCursorRow,
            BaseReferences<_$AppDatabase, $SyncCursoresTable, SyncCursorRow>,
          ),
          SyncCursorRow,
          PrefetchHooks Function()
        > {
  $$SyncCursoresTableTableManager(_$AppDatabase db, $SyncCursoresTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncCursoresTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncCursoresTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncCursoresTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> tabla = const Value.absent(),
                Value<DateTime?> ultimaBajada = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncCursoresCompanion(
                tabla: tabla,
                ultimaBajada: ultimaBajada,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String tabla,
                Value<DateTime?> ultimaBajada = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncCursoresCompanion.insert(
                tabla: tabla,
                ultimaBajada: ultimaBajada,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncCursoresTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncCursoresTable,
      SyncCursorRow,
      $$SyncCursoresTableFilterComposer,
      $$SyncCursoresTableOrderingComposer,
      $$SyncCursoresTableAnnotationComposer,
      $$SyncCursoresTableCreateCompanionBuilder,
      $$SyncCursoresTableUpdateCompanionBuilder,
      (
        SyncCursorRow,
        BaseReferences<_$AppDatabase, $SyncCursoresTable, SyncCursorRow>,
      ),
      SyncCursorRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PlanesTableTableManager get planes =>
      $$PlanesTableTableManager(_db, _db.planes);
  $$CuentasTableTableManager get cuentas =>
      $$CuentasTableTableManager(_db, _db.cuentas);
  $$UsuariosTableTableManager get usuarios =>
      $$UsuariosTableTableManager(_db, _db.usuarios);
  $$FincasTableTableManager get fincas =>
      $$FincasTableTableManager(_db, _db.fincas);
  $$FincaMiembrosTableTableManager get fincaMiembros =>
      $$FincaMiembrosTableTableManager(_db, _db.fincaMiembros);
  $$LotesTableTableManager get lotes =>
      $$LotesTableTableManager(_db, _db.lotes);
  $$AnimalesTableTableManager get animales =>
      $$AnimalesTableTableManager(_db, _db.animales);
  $$PesajesTableTableManager get pesajes =>
      $$PesajesTableTableManager(_db, _db.pesajes);
  $$SyncCursoresTableTableManager get syncCursores =>
      $$SyncCursoresTableTableManager(_db, _db.syncCursores);
}
