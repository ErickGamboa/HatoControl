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
  static const VerificationMeta _pruebaTerminaMeta = const VerificationMeta(
    'pruebaTermina',
  );
  @override
  late final GeneratedColumn<DateTime> pruebaTermina =
      GeneratedColumn<DateTime>(
        'prueba_termina',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
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
    nombre,
    duenoId,
    plan,
    estado,
    pruebaTermina,
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
    if (data.containsKey('prueba_termina')) {
      context.handle(
        _pruebaTerminaMeta,
        pruebaTermina.isAcceptableOrUnknown(
          data['prueba_termina']!,
          _pruebaTerminaMeta,
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
      pruebaTermina: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}prueba_termina'],
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
  final DateTime? pruebaTermina;
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
    this.pruebaTermina,
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
    if (!nullToAbsent || pruebaTermina != null) {
      map['prueba_termina'] = Variable<DateTime>(pruebaTermina);
    }
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
      pruebaTermina: pruebaTermina == null && nullToAbsent
          ? const Value.absent()
          : Value(pruebaTermina),
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
      pruebaTermina: serializer.fromJson<DateTime?>(json['pruebaTermina']),
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
      'pruebaTermina': serializer.toJson<DateTime?>(pruebaTermina),
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
    Value<DateTime?> pruebaTermina = const Value.absent(),
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
    pruebaTermina: pruebaTermina.present
        ? pruebaTermina.value
        : this.pruebaTermina,
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
      pruebaTermina: data.pruebaTermina.present
          ? data.pruebaTermina.value
          : this.pruebaTermina,
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
          ..write('pruebaTermina: $pruebaTermina, ')
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
    pruebaTermina,
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
          other.pruebaTermina == this.pruebaTermina &&
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
  final Value<DateTime?> pruebaTermina;
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
    this.pruebaTermina = const Value.absent(),
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
    this.pruebaTermina = const Value.absent(),
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
    Expression<DateTime>? pruebaTermina,
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
      if (pruebaTermina != null) 'prueba_termina': pruebaTermina,
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
    Value<DateTime?>? pruebaTermina,
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
      pruebaTermina: pruebaTermina ?? this.pruebaTermina,
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
    if (pruebaTermina.present) {
      map['prueba_termina'] = Variable<DateTime>(pruebaTermina.value);
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
          ..write('pruebaTermina: $pruebaTermina, ')
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
  static const VerificationMeta _estadoMeta = const VerificationMeta('estado');
  @override
  late final GeneratedColumn<String> estado = GeneratedColumn<String>(
    'estado',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('activo'),
  );
  static const VerificationMeta _precioCompraMeta = const VerificationMeta(
    'precioCompra',
  );
  @override
  late final GeneratedColumn<double> precioCompra = GeneratedColumn<double>(
    'precio_compra',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fechaCompraMeta = const VerificationMeta(
    'fechaCompra',
  );
  @override
  late final GeneratedColumn<DateTime> fechaCompra = GeneratedColumn<DateTime>(
    'fecha_compra',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
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
    loteId,
    identificador,
    estado,
    precioCompra,
    fechaCompra,
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
    if (data.containsKey('estado')) {
      context.handle(
        _estadoMeta,
        estado.isAcceptableOrUnknown(data['estado']!, _estadoMeta),
      );
    }
    if (data.containsKey('precio_compra')) {
      context.handle(
        _precioCompraMeta,
        precioCompra.isAcceptableOrUnknown(
          data['precio_compra']!,
          _precioCompraMeta,
        ),
      );
    }
    if (data.containsKey('fecha_compra')) {
      context.handle(
        _fechaCompraMeta,
        fechaCompra.isAcceptableOrUnknown(
          data['fecha_compra']!,
          _fechaCompraMeta,
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
      estado: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}estado'],
      )!,
      precioCompra: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}precio_compra'],
      ),
      fechaCompra: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fecha_compra'],
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
  $AnimalesTable createAlias(String alias) {
    return $AnimalesTable(attachedDatabase, alias);
  }
}

class AnimalRow extends DataClass implements Insertable<AnimalRow> {
  final String id;
  final String fincaId;
  final String loteId;
  final String identificador;

  /// activo | vendido | muerto (D-08)
  final String estado;
  final double? precioCompra;
  final DateTime? fechaCompra;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final bool pendiente;
  const AnimalRow({
    required this.id,
    required this.fincaId,
    required this.loteId,
    required this.identificador,
    required this.estado,
    this.precioCompra,
    this.fechaCompra,
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
    map['estado'] = Variable<String>(estado);
    if (!nullToAbsent || precioCompra != null) {
      map['precio_compra'] = Variable<double>(precioCompra);
    }
    if (!nullToAbsent || fechaCompra != null) {
      map['fecha_compra'] = Variable<DateTime>(fechaCompra);
    }
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
      estado: Value(estado),
      precioCompra: precioCompra == null && nullToAbsent
          ? const Value.absent()
          : Value(precioCompra),
      fechaCompra: fechaCompra == null && nullToAbsent
          ? const Value.absent()
          : Value(fechaCompra),
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
      estado: serializer.fromJson<String>(json['estado']),
      precioCompra: serializer.fromJson<double?>(json['precioCompra']),
      fechaCompra: serializer.fromJson<DateTime?>(json['fechaCompra']),
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
      'estado': serializer.toJson<String>(estado),
      'precioCompra': serializer.toJson<double?>(precioCompra),
      'fechaCompra': serializer.toJson<DateTime?>(fechaCompra),
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
    String? estado,
    Value<double?> precioCompra = const Value.absent(),
    Value<DateTime?> fechaCompra = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    bool? pendiente,
  }) => AnimalRow(
    id: id ?? this.id,
    fincaId: fincaId ?? this.fincaId,
    loteId: loteId ?? this.loteId,
    identificador: identificador ?? this.identificador,
    estado: estado ?? this.estado,
    precioCompra: precioCompra.present ? precioCompra.value : this.precioCompra,
    fechaCompra: fechaCompra.present ? fechaCompra.value : this.fechaCompra,
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
      estado: data.estado.present ? data.estado.value : this.estado,
      precioCompra: data.precioCompra.present
          ? data.precioCompra.value
          : this.precioCompra,
      fechaCompra: data.fechaCompra.present
          ? data.fechaCompra.value
          : this.fechaCompra,
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
          ..write('estado: $estado, ')
          ..write('precioCompra: $precioCompra, ')
          ..write('fechaCompra: $fechaCompra, ')
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
    estado,
    precioCompra,
    fechaCompra,
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
          other.estado == this.estado &&
          other.precioCompra == this.precioCompra &&
          other.fechaCompra == this.fechaCompra &&
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
  final Value<String> estado;
  final Value<double?> precioCompra;
  final Value<DateTime?> fechaCompra;
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
    this.estado = const Value.absent(),
    this.precioCompra = const Value.absent(),
    this.fechaCompra = const Value.absent(),
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
    this.estado = const Value.absent(),
    this.precioCompra = const Value.absent(),
    this.fechaCompra = const Value.absent(),
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
    Expression<String>? estado,
    Expression<double>? precioCompra,
    Expression<DateTime>? fechaCompra,
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
      if (estado != null) 'estado': estado,
      if (precioCompra != null) 'precio_compra': precioCompra,
      if (fechaCompra != null) 'fecha_compra': fechaCompra,
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
    Value<String>? estado,
    Value<double?>? precioCompra,
    Value<DateTime?>? fechaCompra,
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
      estado: estado ?? this.estado,
      precioCompra: precioCompra ?? this.precioCompra,
      fechaCompra: fechaCompra ?? this.fechaCompra,
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
    if (estado.present) {
      map['estado'] = Variable<String>(estado.value);
    }
    if (precioCompra.present) {
      map['precio_compra'] = Variable<double>(precioCompra.value);
    }
    if (fechaCompra.present) {
      map['fecha_compra'] = Variable<DateTime>(fechaCompra.value);
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
          ..write('estado: $estado, ')
          ..write('precioCompra: $precioCompra, ')
          ..write('fechaCompra: $fechaCompra, ')
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

class $DietasTable extends Dietas with TableInfo<$DietasTable, DietaRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DietasTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _descripcionMeta = const VerificationMeta(
    'descripcion',
  );
  @override
  late final GeneratedColumn<String> descripcion = GeneratedColumn<String>(
    'descripcion',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _costoAnimalDiaMeta = const VerificationMeta(
    'costoAnimalDia',
  );
  @override
  late final GeneratedColumn<double> costoAnimalDia = GeneratedColumn<double>(
    'costo_animal_dia',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _monedaMeta = const VerificationMeta('moneda');
  @override
  late final GeneratedColumn<String> moneda = GeneratedColumn<String>(
    'moneda',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('CRC'),
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
    descripcion,
    costoAnimalDia,
    moneda,
    createdAt,
    updatedAt,
    deletedAt,
    pendiente,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'dietas';
  @override
  VerificationContext validateIntegrity(
    Insertable<DietaRow> instance, {
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
    if (data.containsKey('descripcion')) {
      context.handle(
        _descripcionMeta,
        descripcion.isAcceptableOrUnknown(
          data['descripcion']!,
          _descripcionMeta,
        ),
      );
    }
    if (data.containsKey('costo_animal_dia')) {
      context.handle(
        _costoAnimalDiaMeta,
        costoAnimalDia.isAcceptableOrUnknown(
          data['costo_animal_dia']!,
          _costoAnimalDiaMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_costoAnimalDiaMeta);
    }
    if (data.containsKey('moneda')) {
      context.handle(
        _monedaMeta,
        moneda.isAcceptableOrUnknown(data['moneda']!, _monedaMeta),
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
  DietaRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DietaRow(
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
      descripcion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}descripcion'],
      ),
      costoAnimalDia: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}costo_animal_dia'],
      )!,
      moneda: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}moneda'],
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
  $DietasTable createAlias(String alias) {
    return $DietasTable(attachedDatabase, alias);
  }
}

class DietaRow extends DataClass implements Insertable<DietaRow> {
  final String id;
  final String fincaId;
  final String nombre;
  final String? descripcion;
  final double costoAnimalDia;
  final String moneda;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final bool pendiente;
  const DietaRow({
    required this.id,
    required this.fincaId,
    required this.nombre,
    this.descripcion,
    required this.costoAnimalDia,
    required this.moneda,
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
    if (!nullToAbsent || descripcion != null) {
      map['descripcion'] = Variable<String>(descripcion);
    }
    map['costo_animal_dia'] = Variable<double>(costoAnimalDia);
    map['moneda'] = Variable<String>(moneda);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['pendiente'] = Variable<bool>(pendiente);
    return map;
  }

  DietasCompanion toCompanion(bool nullToAbsent) {
    return DietasCompanion(
      id: Value(id),
      fincaId: Value(fincaId),
      nombre: Value(nombre),
      descripcion: descripcion == null && nullToAbsent
          ? const Value.absent()
          : Value(descripcion),
      costoAnimalDia: Value(costoAnimalDia),
      moneda: Value(moneda),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      pendiente: Value(pendiente),
    );
  }

  factory DietaRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DietaRow(
      id: serializer.fromJson<String>(json['id']),
      fincaId: serializer.fromJson<String>(json['fincaId']),
      nombre: serializer.fromJson<String>(json['nombre']),
      descripcion: serializer.fromJson<String?>(json['descripcion']),
      costoAnimalDia: serializer.fromJson<double>(json['costoAnimalDia']),
      moneda: serializer.fromJson<String>(json['moneda']),
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
      'descripcion': serializer.toJson<String?>(descripcion),
      'costoAnimalDia': serializer.toJson<double>(costoAnimalDia),
      'moneda': serializer.toJson<String>(moneda),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'pendiente': serializer.toJson<bool>(pendiente),
    };
  }

  DietaRow copyWith({
    String? id,
    String? fincaId,
    String? nombre,
    Value<String?> descripcion = const Value.absent(),
    double? costoAnimalDia,
    String? moneda,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    bool? pendiente,
  }) => DietaRow(
    id: id ?? this.id,
    fincaId: fincaId ?? this.fincaId,
    nombre: nombre ?? this.nombre,
    descripcion: descripcion.present ? descripcion.value : this.descripcion,
    costoAnimalDia: costoAnimalDia ?? this.costoAnimalDia,
    moneda: moneda ?? this.moneda,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    pendiente: pendiente ?? this.pendiente,
  );
  DietaRow copyWithCompanion(DietasCompanion data) {
    return DietaRow(
      id: data.id.present ? data.id.value : this.id,
      fincaId: data.fincaId.present ? data.fincaId.value : this.fincaId,
      nombre: data.nombre.present ? data.nombre.value : this.nombre,
      descripcion: data.descripcion.present
          ? data.descripcion.value
          : this.descripcion,
      costoAnimalDia: data.costoAnimalDia.present
          ? data.costoAnimalDia.value
          : this.costoAnimalDia,
      moneda: data.moneda.present ? data.moneda.value : this.moneda,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      pendiente: data.pendiente.present ? data.pendiente.value : this.pendiente,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DietaRow(')
          ..write('id: $id, ')
          ..write('fincaId: $fincaId, ')
          ..write('nombre: $nombre, ')
          ..write('descripcion: $descripcion, ')
          ..write('costoAnimalDia: $costoAnimalDia, ')
          ..write('moneda: $moneda, ')
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
    descripcion,
    costoAnimalDia,
    moneda,
    createdAt,
    updatedAt,
    deletedAt,
    pendiente,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DietaRow &&
          other.id == this.id &&
          other.fincaId == this.fincaId &&
          other.nombre == this.nombre &&
          other.descripcion == this.descripcion &&
          other.costoAnimalDia == this.costoAnimalDia &&
          other.moneda == this.moneda &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.pendiente == this.pendiente);
}

class DietasCompanion extends UpdateCompanion<DietaRow> {
  final Value<String> id;
  final Value<String> fincaId;
  final Value<String> nombre;
  final Value<String?> descripcion;
  final Value<double> costoAnimalDia;
  final Value<String> moneda;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<bool> pendiente;
  final Value<int> rowid;
  const DietasCompanion({
    this.id = const Value.absent(),
    this.fincaId = const Value.absent(),
    this.nombre = const Value.absent(),
    this.descripcion = const Value.absent(),
    this.costoAnimalDia = const Value.absent(),
    this.moneda = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.pendiente = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DietasCompanion.insert({
    required String id,
    required String fincaId,
    required String nombre,
    this.descripcion = const Value.absent(),
    required double costoAnimalDia,
    this.moneda = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.pendiente = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       fincaId = Value(fincaId),
       nombre = Value(nombre),
       costoAnimalDia = Value(costoAnimalDia),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<DietaRow> custom({
    Expression<String>? id,
    Expression<String>? fincaId,
    Expression<String>? nombre,
    Expression<String>? descripcion,
    Expression<double>? costoAnimalDia,
    Expression<String>? moneda,
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
      if (descripcion != null) 'descripcion': descripcion,
      if (costoAnimalDia != null) 'costo_animal_dia': costoAnimalDia,
      if (moneda != null) 'moneda': moneda,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (pendiente != null) 'pendiente': pendiente,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DietasCompanion copyWith({
    Value<String>? id,
    Value<String>? fincaId,
    Value<String>? nombre,
    Value<String?>? descripcion,
    Value<double>? costoAnimalDia,
    Value<String>? moneda,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<bool>? pendiente,
    Value<int>? rowid,
  }) {
    return DietasCompanion(
      id: id ?? this.id,
      fincaId: fincaId ?? this.fincaId,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      costoAnimalDia: costoAnimalDia ?? this.costoAnimalDia,
      moneda: moneda ?? this.moneda,
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
    if (descripcion.present) {
      map['descripcion'] = Variable<String>(descripcion.value);
    }
    if (costoAnimalDia.present) {
      map['costo_animal_dia'] = Variable<double>(costoAnimalDia.value);
    }
    if (moneda.present) {
      map['moneda'] = Variable<String>(moneda.value);
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
    return (StringBuffer('DietasCompanion(')
          ..write('id: $id, ')
          ..write('fincaId: $fincaId, ')
          ..write('nombre: $nombre, ')
          ..write('descripcion: $descripcion, ')
          ..write('costoAnimalDia: $costoAnimalDia, ')
          ..write('moneda: $moneda, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('pendiente: $pendiente, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DietaIngredientesTable extends DietaIngredientes
    with TableInfo<$DietaIngredientesTable, DietaIngredienteRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DietaIngredientesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dietaIdMeta = const VerificationMeta(
    'dietaId',
  );
  @override
  late final GeneratedColumn<String> dietaId = GeneratedColumn<String>(
    'dieta_id',
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
  static const VerificationMeta _costoAnimalDiaMeta = const VerificationMeta(
    'costoAnimalDia',
  );
  @override
  late final GeneratedColumn<double> costoAnimalDia = GeneratedColumn<double>(
    'costo_animal_dia',
    aliasedName,
    false,
    type: DriftSqlType.double,
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
    dietaId,
    nombre,
    costoAnimalDia,
    createdAt,
    updatedAt,
    deletedAt,
    pendiente,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'dieta_ingredientes';
  @override
  VerificationContext validateIntegrity(
    Insertable<DietaIngredienteRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('dieta_id')) {
      context.handle(
        _dietaIdMeta,
        dietaId.isAcceptableOrUnknown(data['dieta_id']!, _dietaIdMeta),
      );
    } else if (isInserting) {
      context.missing(_dietaIdMeta);
    }
    if (data.containsKey('nombre')) {
      context.handle(
        _nombreMeta,
        nombre.isAcceptableOrUnknown(data['nombre']!, _nombreMeta),
      );
    } else if (isInserting) {
      context.missing(_nombreMeta);
    }
    if (data.containsKey('costo_animal_dia')) {
      context.handle(
        _costoAnimalDiaMeta,
        costoAnimalDia.isAcceptableOrUnknown(
          data['costo_animal_dia']!,
          _costoAnimalDiaMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_costoAnimalDiaMeta);
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
  DietaIngredienteRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DietaIngredienteRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      dietaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dieta_id'],
      )!,
      nombre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nombre'],
      )!,
      costoAnimalDia: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}costo_animal_dia'],
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
  $DietaIngredientesTable createAlias(String alias) {
    return $DietaIngredientesTable(attachedDatabase, alias);
  }
}

class DietaIngredienteRow extends DataClass
    implements Insertable<DietaIngredienteRow> {
  final String id;
  final String dietaId;
  final String nombre;
  final double costoAnimalDia;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final bool pendiente;
  const DietaIngredienteRow({
    required this.id,
    required this.dietaId,
    required this.nombre,
    required this.costoAnimalDia,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.pendiente,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['dieta_id'] = Variable<String>(dietaId);
    map['nombre'] = Variable<String>(nombre);
    map['costo_animal_dia'] = Variable<double>(costoAnimalDia);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['pendiente'] = Variable<bool>(pendiente);
    return map;
  }

  DietaIngredientesCompanion toCompanion(bool nullToAbsent) {
    return DietaIngredientesCompanion(
      id: Value(id),
      dietaId: Value(dietaId),
      nombre: Value(nombre),
      costoAnimalDia: Value(costoAnimalDia),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      pendiente: Value(pendiente),
    );
  }

  factory DietaIngredienteRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DietaIngredienteRow(
      id: serializer.fromJson<String>(json['id']),
      dietaId: serializer.fromJson<String>(json['dietaId']),
      nombre: serializer.fromJson<String>(json['nombre']),
      costoAnimalDia: serializer.fromJson<double>(json['costoAnimalDia']),
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
      'dietaId': serializer.toJson<String>(dietaId),
      'nombre': serializer.toJson<String>(nombre),
      'costoAnimalDia': serializer.toJson<double>(costoAnimalDia),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'pendiente': serializer.toJson<bool>(pendiente),
    };
  }

  DietaIngredienteRow copyWith({
    String? id,
    String? dietaId,
    String? nombre,
    double? costoAnimalDia,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    bool? pendiente,
  }) => DietaIngredienteRow(
    id: id ?? this.id,
    dietaId: dietaId ?? this.dietaId,
    nombre: nombre ?? this.nombre,
    costoAnimalDia: costoAnimalDia ?? this.costoAnimalDia,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    pendiente: pendiente ?? this.pendiente,
  );
  DietaIngredienteRow copyWithCompanion(DietaIngredientesCompanion data) {
    return DietaIngredienteRow(
      id: data.id.present ? data.id.value : this.id,
      dietaId: data.dietaId.present ? data.dietaId.value : this.dietaId,
      nombre: data.nombre.present ? data.nombre.value : this.nombre,
      costoAnimalDia: data.costoAnimalDia.present
          ? data.costoAnimalDia.value
          : this.costoAnimalDia,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      pendiente: data.pendiente.present ? data.pendiente.value : this.pendiente,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DietaIngredienteRow(')
          ..write('id: $id, ')
          ..write('dietaId: $dietaId, ')
          ..write('nombre: $nombre, ')
          ..write('costoAnimalDia: $costoAnimalDia, ')
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
    dietaId,
    nombre,
    costoAnimalDia,
    createdAt,
    updatedAt,
    deletedAt,
    pendiente,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DietaIngredienteRow &&
          other.id == this.id &&
          other.dietaId == this.dietaId &&
          other.nombre == this.nombre &&
          other.costoAnimalDia == this.costoAnimalDia &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.pendiente == this.pendiente);
}

class DietaIngredientesCompanion extends UpdateCompanion<DietaIngredienteRow> {
  final Value<String> id;
  final Value<String> dietaId;
  final Value<String> nombre;
  final Value<double> costoAnimalDia;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<bool> pendiente;
  final Value<int> rowid;
  const DietaIngredientesCompanion({
    this.id = const Value.absent(),
    this.dietaId = const Value.absent(),
    this.nombre = const Value.absent(),
    this.costoAnimalDia = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.pendiente = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DietaIngredientesCompanion.insert({
    required String id,
    required String dietaId,
    required String nombre,
    required double costoAnimalDia,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.pendiente = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       dietaId = Value(dietaId),
       nombre = Value(nombre),
       costoAnimalDia = Value(costoAnimalDia),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<DietaIngredienteRow> custom({
    Expression<String>? id,
    Expression<String>? dietaId,
    Expression<String>? nombre,
    Expression<double>? costoAnimalDia,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<bool>? pendiente,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (dietaId != null) 'dieta_id': dietaId,
      if (nombre != null) 'nombre': nombre,
      if (costoAnimalDia != null) 'costo_animal_dia': costoAnimalDia,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (pendiente != null) 'pendiente': pendiente,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DietaIngredientesCompanion copyWith({
    Value<String>? id,
    Value<String>? dietaId,
    Value<String>? nombre,
    Value<double>? costoAnimalDia,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<bool>? pendiente,
    Value<int>? rowid,
  }) {
    return DietaIngredientesCompanion(
      id: id ?? this.id,
      dietaId: dietaId ?? this.dietaId,
      nombre: nombre ?? this.nombre,
      costoAnimalDia: costoAnimalDia ?? this.costoAnimalDia,
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
    if (dietaId.present) {
      map['dieta_id'] = Variable<String>(dietaId.value);
    }
    if (nombre.present) {
      map['nombre'] = Variable<String>(nombre.value);
    }
    if (costoAnimalDia.present) {
      map['costo_animal_dia'] = Variable<double>(costoAnimalDia.value);
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
    return (StringBuffer('DietaIngredientesCompanion(')
          ..write('id: $id, ')
          ..write('dietaId: $dietaId, ')
          ..write('nombre: $nombre, ')
          ..write('costoAnimalDia: $costoAnimalDia, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('pendiente: $pendiente, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LoteDietasTable extends LoteDietas
    with TableInfo<$LoteDietasTable, LoteDietaRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LoteDietasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
  static const VerificationMeta _dietaIdMeta = const VerificationMeta(
    'dietaId',
  );
  @override
  late final GeneratedColumn<String> dietaId = GeneratedColumn<String>(
    'dieta_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _desdeMeta = const VerificationMeta('desde');
  @override
  late final GeneratedColumn<DateTime> desde = GeneratedColumn<DateTime>(
    'desde',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hastaMeta = const VerificationMeta('hasta');
  @override
  late final GeneratedColumn<DateTime> hasta = GeneratedColumn<DateTime>(
    'hasta',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _costoAnimalDiaSnapshotMeta =
      const VerificationMeta('costoAnimalDiaSnapshot');
  @override
  late final GeneratedColumn<double> costoAnimalDiaSnapshot =
      GeneratedColumn<double>(
        'costo_animal_dia_snapshot',
        aliasedName,
        false,
        type: DriftSqlType.double,
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
    loteId,
    dietaId,
    desde,
    hasta,
    costoAnimalDiaSnapshot,
    createdAt,
    updatedAt,
    deletedAt,
    pendiente,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'lote_dietas';
  @override
  VerificationContext validateIntegrity(
    Insertable<LoteDietaRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('lote_id')) {
      context.handle(
        _loteIdMeta,
        loteId.isAcceptableOrUnknown(data['lote_id']!, _loteIdMeta),
      );
    } else if (isInserting) {
      context.missing(_loteIdMeta);
    }
    if (data.containsKey('dieta_id')) {
      context.handle(
        _dietaIdMeta,
        dietaId.isAcceptableOrUnknown(data['dieta_id']!, _dietaIdMeta),
      );
    } else if (isInserting) {
      context.missing(_dietaIdMeta);
    }
    if (data.containsKey('desde')) {
      context.handle(
        _desdeMeta,
        desde.isAcceptableOrUnknown(data['desde']!, _desdeMeta),
      );
    } else if (isInserting) {
      context.missing(_desdeMeta);
    }
    if (data.containsKey('hasta')) {
      context.handle(
        _hastaMeta,
        hasta.isAcceptableOrUnknown(data['hasta']!, _hastaMeta),
      );
    }
    if (data.containsKey('costo_animal_dia_snapshot')) {
      context.handle(
        _costoAnimalDiaSnapshotMeta,
        costoAnimalDiaSnapshot.isAcceptableOrUnknown(
          data['costo_animal_dia_snapshot']!,
          _costoAnimalDiaSnapshotMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_costoAnimalDiaSnapshotMeta);
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
  LoteDietaRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LoteDietaRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      loteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lote_id'],
      )!,
      dietaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dieta_id'],
      )!,
      desde: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}desde'],
      )!,
      hasta: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}hasta'],
      ),
      costoAnimalDiaSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}costo_animal_dia_snapshot'],
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
  $LoteDietasTable createAlias(String alias) {
    return $LoteDietasTable(attachedDatabase, alias);
  }
}

class LoteDietaRow extends DataClass implements Insertable<LoteDietaRow> {
  final String id;
  final String loteId;
  final String dietaId;
  final DateTime desde;
  final DateTime? hasta;
  final double costoAnimalDiaSnapshot;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final bool pendiente;
  const LoteDietaRow({
    required this.id,
    required this.loteId,
    required this.dietaId,
    required this.desde,
    this.hasta,
    required this.costoAnimalDiaSnapshot,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.pendiente,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['lote_id'] = Variable<String>(loteId);
    map['dieta_id'] = Variable<String>(dietaId);
    map['desde'] = Variable<DateTime>(desde);
    if (!nullToAbsent || hasta != null) {
      map['hasta'] = Variable<DateTime>(hasta);
    }
    map['costo_animal_dia_snapshot'] = Variable<double>(costoAnimalDiaSnapshot);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['pendiente'] = Variable<bool>(pendiente);
    return map;
  }

  LoteDietasCompanion toCompanion(bool nullToAbsent) {
    return LoteDietasCompanion(
      id: Value(id),
      loteId: Value(loteId),
      dietaId: Value(dietaId),
      desde: Value(desde),
      hasta: hasta == null && nullToAbsent
          ? const Value.absent()
          : Value(hasta),
      costoAnimalDiaSnapshot: Value(costoAnimalDiaSnapshot),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      pendiente: Value(pendiente),
    );
  }

  factory LoteDietaRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LoteDietaRow(
      id: serializer.fromJson<String>(json['id']),
      loteId: serializer.fromJson<String>(json['loteId']),
      dietaId: serializer.fromJson<String>(json['dietaId']),
      desde: serializer.fromJson<DateTime>(json['desde']),
      hasta: serializer.fromJson<DateTime?>(json['hasta']),
      costoAnimalDiaSnapshot: serializer.fromJson<double>(
        json['costoAnimalDiaSnapshot'],
      ),
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
      'loteId': serializer.toJson<String>(loteId),
      'dietaId': serializer.toJson<String>(dietaId),
      'desde': serializer.toJson<DateTime>(desde),
      'hasta': serializer.toJson<DateTime?>(hasta),
      'costoAnimalDiaSnapshot': serializer.toJson<double>(
        costoAnimalDiaSnapshot,
      ),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'pendiente': serializer.toJson<bool>(pendiente),
    };
  }

  LoteDietaRow copyWith({
    String? id,
    String? loteId,
    String? dietaId,
    DateTime? desde,
    Value<DateTime?> hasta = const Value.absent(),
    double? costoAnimalDiaSnapshot,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    bool? pendiente,
  }) => LoteDietaRow(
    id: id ?? this.id,
    loteId: loteId ?? this.loteId,
    dietaId: dietaId ?? this.dietaId,
    desde: desde ?? this.desde,
    hasta: hasta.present ? hasta.value : this.hasta,
    costoAnimalDiaSnapshot:
        costoAnimalDiaSnapshot ?? this.costoAnimalDiaSnapshot,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    pendiente: pendiente ?? this.pendiente,
  );
  LoteDietaRow copyWithCompanion(LoteDietasCompanion data) {
    return LoteDietaRow(
      id: data.id.present ? data.id.value : this.id,
      loteId: data.loteId.present ? data.loteId.value : this.loteId,
      dietaId: data.dietaId.present ? data.dietaId.value : this.dietaId,
      desde: data.desde.present ? data.desde.value : this.desde,
      hasta: data.hasta.present ? data.hasta.value : this.hasta,
      costoAnimalDiaSnapshot: data.costoAnimalDiaSnapshot.present
          ? data.costoAnimalDiaSnapshot.value
          : this.costoAnimalDiaSnapshot,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      pendiente: data.pendiente.present ? data.pendiente.value : this.pendiente,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LoteDietaRow(')
          ..write('id: $id, ')
          ..write('loteId: $loteId, ')
          ..write('dietaId: $dietaId, ')
          ..write('desde: $desde, ')
          ..write('hasta: $hasta, ')
          ..write('costoAnimalDiaSnapshot: $costoAnimalDiaSnapshot, ')
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
    loteId,
    dietaId,
    desde,
    hasta,
    costoAnimalDiaSnapshot,
    createdAt,
    updatedAt,
    deletedAt,
    pendiente,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LoteDietaRow &&
          other.id == this.id &&
          other.loteId == this.loteId &&
          other.dietaId == this.dietaId &&
          other.desde == this.desde &&
          other.hasta == this.hasta &&
          other.costoAnimalDiaSnapshot == this.costoAnimalDiaSnapshot &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.pendiente == this.pendiente);
}

class LoteDietasCompanion extends UpdateCompanion<LoteDietaRow> {
  final Value<String> id;
  final Value<String> loteId;
  final Value<String> dietaId;
  final Value<DateTime> desde;
  final Value<DateTime?> hasta;
  final Value<double> costoAnimalDiaSnapshot;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<bool> pendiente;
  final Value<int> rowid;
  const LoteDietasCompanion({
    this.id = const Value.absent(),
    this.loteId = const Value.absent(),
    this.dietaId = const Value.absent(),
    this.desde = const Value.absent(),
    this.hasta = const Value.absent(),
    this.costoAnimalDiaSnapshot = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.pendiente = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LoteDietasCompanion.insert({
    required String id,
    required String loteId,
    required String dietaId,
    required DateTime desde,
    this.hasta = const Value.absent(),
    required double costoAnimalDiaSnapshot,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.pendiente = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       loteId = Value(loteId),
       dietaId = Value(dietaId),
       desde = Value(desde),
       costoAnimalDiaSnapshot = Value(costoAnimalDiaSnapshot),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<LoteDietaRow> custom({
    Expression<String>? id,
    Expression<String>? loteId,
    Expression<String>? dietaId,
    Expression<DateTime>? desde,
    Expression<DateTime>? hasta,
    Expression<double>? costoAnimalDiaSnapshot,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<bool>? pendiente,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (loteId != null) 'lote_id': loteId,
      if (dietaId != null) 'dieta_id': dietaId,
      if (desde != null) 'desde': desde,
      if (hasta != null) 'hasta': hasta,
      if (costoAnimalDiaSnapshot != null)
        'costo_animal_dia_snapshot': costoAnimalDiaSnapshot,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (pendiente != null) 'pendiente': pendiente,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LoteDietasCompanion copyWith({
    Value<String>? id,
    Value<String>? loteId,
    Value<String>? dietaId,
    Value<DateTime>? desde,
    Value<DateTime?>? hasta,
    Value<double>? costoAnimalDiaSnapshot,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<bool>? pendiente,
    Value<int>? rowid,
  }) {
    return LoteDietasCompanion(
      id: id ?? this.id,
      loteId: loteId ?? this.loteId,
      dietaId: dietaId ?? this.dietaId,
      desde: desde ?? this.desde,
      hasta: hasta ?? this.hasta,
      costoAnimalDiaSnapshot:
          costoAnimalDiaSnapshot ?? this.costoAnimalDiaSnapshot,
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
    if (loteId.present) {
      map['lote_id'] = Variable<String>(loteId.value);
    }
    if (dietaId.present) {
      map['dieta_id'] = Variable<String>(dietaId.value);
    }
    if (desde.present) {
      map['desde'] = Variable<DateTime>(desde.value);
    }
    if (hasta.present) {
      map['hasta'] = Variable<DateTime>(hasta.value);
    }
    if (costoAnimalDiaSnapshot.present) {
      map['costo_animal_dia_snapshot'] = Variable<double>(
        costoAnimalDiaSnapshot.value,
      );
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
    return (StringBuffer('LoteDietasCompanion(')
          ..write('id: $id, ')
          ..write('loteId: $loteId, ')
          ..write('dietaId: $dietaId, ')
          ..write('desde: $desde, ')
          ..write('hasta: $hasta, ')
          ..write('costoAnimalDiaSnapshot: $costoAnimalDiaSnapshot, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('pendiente: $pendiente, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MovimientosLoteTable extends MovimientosLote
    with TableInfo<$MovimientosLoteTable, MovimientoLoteRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MovimientosLoteTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _loteOrigenMeta = const VerificationMeta(
    'loteOrigen',
  );
  @override
  late final GeneratedColumn<String> loteOrigen = GeneratedColumn<String>(
    'lote_origen',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _loteDestinoMeta = const VerificationMeta(
    'loteDestino',
  );
  @override
  late final GeneratedColumn<String> loteDestino = GeneratedColumn<String>(
    'lote_destino',
    aliasedName,
    false,
    type: DriftSqlType.string,
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
    loteOrigen,
    loteDestino,
    fecha,
    createdAt,
    updatedAt,
    deletedAt,
    pendiente,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'movimientos_lote';
  @override
  VerificationContext validateIntegrity(
    Insertable<MovimientoLoteRow> instance, {
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
    if (data.containsKey('lote_origen')) {
      context.handle(
        _loteOrigenMeta,
        loteOrigen.isAcceptableOrUnknown(data['lote_origen']!, _loteOrigenMeta),
      );
    }
    if (data.containsKey('lote_destino')) {
      context.handle(
        _loteDestinoMeta,
        loteDestino.isAcceptableOrUnknown(
          data['lote_destino']!,
          _loteDestinoMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_loteDestinoMeta);
    }
    if (data.containsKey('fecha')) {
      context.handle(
        _fechaMeta,
        fecha.isAcceptableOrUnknown(data['fecha']!, _fechaMeta),
      );
    } else if (isInserting) {
      context.missing(_fechaMeta);
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
  MovimientoLoteRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MovimientoLoteRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      animalId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}animal_id'],
      )!,
      loteOrigen: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lote_origen'],
      ),
      loteDestino: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lote_destino'],
      )!,
      fecha: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fecha'],
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
  $MovimientosLoteTable createAlias(String alias) {
    return $MovimientosLoteTable(attachedDatabase, alias);
  }
}

class MovimientoLoteRow extends DataClass
    implements Insertable<MovimientoLoteRow> {
  final String id;
  final String animalId;
  final String? loteOrigen;
  final String loteDestino;
  final DateTime fecha;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final bool pendiente;
  const MovimientoLoteRow({
    required this.id,
    required this.animalId,
    this.loteOrigen,
    required this.loteDestino,
    required this.fecha,
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
    if (!nullToAbsent || loteOrigen != null) {
      map['lote_origen'] = Variable<String>(loteOrigen);
    }
    map['lote_destino'] = Variable<String>(loteDestino);
    map['fecha'] = Variable<DateTime>(fecha);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['pendiente'] = Variable<bool>(pendiente);
    return map;
  }

  MovimientosLoteCompanion toCompanion(bool nullToAbsent) {
    return MovimientosLoteCompanion(
      id: Value(id),
      animalId: Value(animalId),
      loteOrigen: loteOrigen == null && nullToAbsent
          ? const Value.absent()
          : Value(loteOrigen),
      loteDestino: Value(loteDestino),
      fecha: Value(fecha),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      pendiente: Value(pendiente),
    );
  }

  factory MovimientoLoteRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MovimientoLoteRow(
      id: serializer.fromJson<String>(json['id']),
      animalId: serializer.fromJson<String>(json['animalId']),
      loteOrigen: serializer.fromJson<String?>(json['loteOrigen']),
      loteDestino: serializer.fromJson<String>(json['loteDestino']),
      fecha: serializer.fromJson<DateTime>(json['fecha']),
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
      'loteOrigen': serializer.toJson<String?>(loteOrigen),
      'loteDestino': serializer.toJson<String>(loteDestino),
      'fecha': serializer.toJson<DateTime>(fecha),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'pendiente': serializer.toJson<bool>(pendiente),
    };
  }

  MovimientoLoteRow copyWith({
    String? id,
    String? animalId,
    Value<String?> loteOrigen = const Value.absent(),
    String? loteDestino,
    DateTime? fecha,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    bool? pendiente,
  }) => MovimientoLoteRow(
    id: id ?? this.id,
    animalId: animalId ?? this.animalId,
    loteOrigen: loteOrigen.present ? loteOrigen.value : this.loteOrigen,
    loteDestino: loteDestino ?? this.loteDestino,
    fecha: fecha ?? this.fecha,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    pendiente: pendiente ?? this.pendiente,
  );
  MovimientoLoteRow copyWithCompanion(MovimientosLoteCompanion data) {
    return MovimientoLoteRow(
      id: data.id.present ? data.id.value : this.id,
      animalId: data.animalId.present ? data.animalId.value : this.animalId,
      loteOrigen: data.loteOrigen.present
          ? data.loteOrigen.value
          : this.loteOrigen,
      loteDestino: data.loteDestino.present
          ? data.loteDestino.value
          : this.loteDestino,
      fecha: data.fecha.present ? data.fecha.value : this.fecha,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      pendiente: data.pendiente.present ? data.pendiente.value : this.pendiente,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MovimientoLoteRow(')
          ..write('id: $id, ')
          ..write('animalId: $animalId, ')
          ..write('loteOrigen: $loteOrigen, ')
          ..write('loteDestino: $loteDestino, ')
          ..write('fecha: $fecha, ')
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
    loteOrigen,
    loteDestino,
    fecha,
    createdAt,
    updatedAt,
    deletedAt,
    pendiente,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MovimientoLoteRow &&
          other.id == this.id &&
          other.animalId == this.animalId &&
          other.loteOrigen == this.loteOrigen &&
          other.loteDestino == this.loteDestino &&
          other.fecha == this.fecha &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.pendiente == this.pendiente);
}

class MovimientosLoteCompanion extends UpdateCompanion<MovimientoLoteRow> {
  final Value<String> id;
  final Value<String> animalId;
  final Value<String?> loteOrigen;
  final Value<String> loteDestino;
  final Value<DateTime> fecha;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<bool> pendiente;
  final Value<int> rowid;
  const MovimientosLoteCompanion({
    this.id = const Value.absent(),
    this.animalId = const Value.absent(),
    this.loteOrigen = const Value.absent(),
    this.loteDestino = const Value.absent(),
    this.fecha = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.pendiente = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MovimientosLoteCompanion.insert({
    required String id,
    required String animalId,
    this.loteOrigen = const Value.absent(),
    required String loteDestino,
    required DateTime fecha,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.pendiente = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       animalId = Value(animalId),
       loteDestino = Value(loteDestino),
       fecha = Value(fecha),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<MovimientoLoteRow> custom({
    Expression<String>? id,
    Expression<String>? animalId,
    Expression<String>? loteOrigen,
    Expression<String>? loteDestino,
    Expression<DateTime>? fecha,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<bool>? pendiente,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (animalId != null) 'animal_id': animalId,
      if (loteOrigen != null) 'lote_origen': loteOrigen,
      if (loteDestino != null) 'lote_destino': loteDestino,
      if (fecha != null) 'fecha': fecha,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (pendiente != null) 'pendiente': pendiente,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MovimientosLoteCompanion copyWith({
    Value<String>? id,
    Value<String>? animalId,
    Value<String?>? loteOrigen,
    Value<String>? loteDestino,
    Value<DateTime>? fecha,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<bool>? pendiente,
    Value<int>? rowid,
  }) {
    return MovimientosLoteCompanion(
      id: id ?? this.id,
      animalId: animalId ?? this.animalId,
      loteOrigen: loteOrigen ?? this.loteOrigen,
      loteDestino: loteDestino ?? this.loteDestino,
      fecha: fecha ?? this.fecha,
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
    if (loteOrigen.present) {
      map['lote_origen'] = Variable<String>(loteOrigen.value);
    }
    if (loteDestino.present) {
      map['lote_destino'] = Variable<String>(loteDestino.value);
    }
    if (fecha.present) {
      map['fecha'] = Variable<DateTime>(fecha.value);
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
    return (StringBuffer('MovimientosLoteCompanion(')
          ..write('id: $id, ')
          ..write('animalId: $animalId, ')
          ..write('loteOrigen: $loteOrigen, ')
          ..write('loteDestino: $loteDestino, ')
          ..write('fecha: $fecha, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('pendiente: $pendiente, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MedicamentosTable extends Medicamentos
    with TableInfo<$MedicamentosTable, MedicamentoRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MedicamentosTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _costoEnvaseMeta = const VerificationMeta(
    'costoEnvase',
  );
  @override
  late final GeneratedColumn<double> costoEnvase = GeneratedColumn<double>(
    'costo_envase',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tipoAplicacionMeta = const VerificationMeta(
    'tipoAplicacion',
  );
  @override
  late final GeneratedColumn<String> tipoAplicacion = GeneratedColumn<String>(
    'tipo_aplicacion',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mlEnvaseMeta = const VerificationMeta(
    'mlEnvase',
  );
  @override
  late final GeneratedColumn<double> mlEnvase = GeneratedColumn<double>(
    'ml_envase',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _aplicacionesPorEnvaseMeta =
      const VerificationMeta('aplicacionesPorEnvase');
  @override
  late final GeneratedColumn<double> aplicacionesPorEnvase =
      GeneratedColumn<double>(
        'aplicaciones_por_envase',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _dosisCantidadMeta = const VerificationMeta(
    'dosisCantidad',
  );
  @override
  late final GeneratedColumn<double> dosisCantidad = GeneratedColumn<double>(
    'dosis_cantidad',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dosisPorCadaKgMeta = const VerificationMeta(
    'dosisPorCadaKg',
  );
  @override
  late final GeneratedColumn<double> dosisPorCadaKg = GeneratedColumn<double>(
    'dosis_por_cada_kg',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _diasRetiroMeta = const VerificationMeta(
    'diasRetiro',
  );
  @override
  late final GeneratedColumn<int> diasRetiro = GeneratedColumn<int>(
    'dias_retiro',
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
    costoEnvase,
    tipoAplicacion,
    mlEnvase,
    aplicacionesPorEnvase,
    dosisCantidad,
    dosisPorCadaKg,
    diasRetiro,
    createdAt,
    updatedAt,
    deletedAt,
    pendiente,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'medicamentos';
  @override
  VerificationContext validateIntegrity(
    Insertable<MedicamentoRow> instance, {
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
    if (data.containsKey('costo_envase')) {
      context.handle(
        _costoEnvaseMeta,
        costoEnvase.isAcceptableOrUnknown(
          data['costo_envase']!,
          _costoEnvaseMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_costoEnvaseMeta);
    }
    if (data.containsKey('tipo_aplicacion')) {
      context.handle(
        _tipoAplicacionMeta,
        tipoAplicacion.isAcceptableOrUnknown(
          data['tipo_aplicacion']!,
          _tipoAplicacionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_tipoAplicacionMeta);
    }
    if (data.containsKey('ml_envase')) {
      context.handle(
        _mlEnvaseMeta,
        mlEnvase.isAcceptableOrUnknown(data['ml_envase']!, _mlEnvaseMeta),
      );
    }
    if (data.containsKey('aplicaciones_por_envase')) {
      context.handle(
        _aplicacionesPorEnvaseMeta,
        aplicacionesPorEnvase.isAcceptableOrUnknown(
          data['aplicaciones_por_envase']!,
          _aplicacionesPorEnvaseMeta,
        ),
      );
    }
    if (data.containsKey('dosis_cantidad')) {
      context.handle(
        _dosisCantidadMeta,
        dosisCantidad.isAcceptableOrUnknown(
          data['dosis_cantidad']!,
          _dosisCantidadMeta,
        ),
      );
    }
    if (data.containsKey('dosis_por_cada_kg')) {
      context.handle(
        _dosisPorCadaKgMeta,
        dosisPorCadaKg.isAcceptableOrUnknown(
          data['dosis_por_cada_kg']!,
          _dosisPorCadaKgMeta,
        ),
      );
    }
    if (data.containsKey('dias_retiro')) {
      context.handle(
        _diasRetiroMeta,
        diasRetiro.isAcceptableOrUnknown(data['dias_retiro']!, _diasRetiroMeta),
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
  MedicamentoRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MedicamentoRow(
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
      costoEnvase: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}costo_envase'],
      )!,
      tipoAplicacion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tipo_aplicacion'],
      )!,
      mlEnvase: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}ml_envase'],
      ),
      aplicacionesPorEnvase: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}aplicaciones_por_envase'],
      ),
      dosisCantidad: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}dosis_cantidad'],
      ),
      dosisPorCadaKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}dosis_por_cada_kg'],
      ),
      diasRetiro: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}dias_retiro'],
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
  $MedicamentosTable createAlias(String alias) {
    return $MedicamentosTable(attachedDatabase, alias);
  }
}

class MedicamentoRow extends DataClass implements Insertable<MedicamentoRow> {
  final String id;
  final String fincaId;
  final String nombre;
  final double costoEnvase;

  /// por_peso | dosis_fija | por_aplicacion
  final String tipoAplicacion;
  final double? mlEnvase;
  final double? aplicacionesPorEnvase;

  /// ml de la dosis (por peso o fija).
  final double? dosisCantidad;

  /// "cada X kg" para por_peso.
  final double? dosisPorCadaKg;
  final int diasRetiro;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final bool pendiente;
  const MedicamentoRow({
    required this.id,
    required this.fincaId,
    required this.nombre,
    required this.costoEnvase,
    required this.tipoAplicacion,
    this.mlEnvase,
    this.aplicacionesPorEnvase,
    this.dosisCantidad,
    this.dosisPorCadaKg,
    required this.diasRetiro,
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
    map['costo_envase'] = Variable<double>(costoEnvase);
    map['tipo_aplicacion'] = Variable<String>(tipoAplicacion);
    if (!nullToAbsent || mlEnvase != null) {
      map['ml_envase'] = Variable<double>(mlEnvase);
    }
    if (!nullToAbsent || aplicacionesPorEnvase != null) {
      map['aplicaciones_por_envase'] = Variable<double>(aplicacionesPorEnvase);
    }
    if (!nullToAbsent || dosisCantidad != null) {
      map['dosis_cantidad'] = Variable<double>(dosisCantidad);
    }
    if (!nullToAbsent || dosisPorCadaKg != null) {
      map['dosis_por_cada_kg'] = Variable<double>(dosisPorCadaKg);
    }
    map['dias_retiro'] = Variable<int>(diasRetiro);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['pendiente'] = Variable<bool>(pendiente);
    return map;
  }

  MedicamentosCompanion toCompanion(bool nullToAbsent) {
    return MedicamentosCompanion(
      id: Value(id),
      fincaId: Value(fincaId),
      nombre: Value(nombre),
      costoEnvase: Value(costoEnvase),
      tipoAplicacion: Value(tipoAplicacion),
      mlEnvase: mlEnvase == null && nullToAbsent
          ? const Value.absent()
          : Value(mlEnvase),
      aplicacionesPorEnvase: aplicacionesPorEnvase == null && nullToAbsent
          ? const Value.absent()
          : Value(aplicacionesPorEnvase),
      dosisCantidad: dosisCantidad == null && nullToAbsent
          ? const Value.absent()
          : Value(dosisCantidad),
      dosisPorCadaKg: dosisPorCadaKg == null && nullToAbsent
          ? const Value.absent()
          : Value(dosisPorCadaKg),
      diasRetiro: Value(diasRetiro),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      pendiente: Value(pendiente),
    );
  }

  factory MedicamentoRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MedicamentoRow(
      id: serializer.fromJson<String>(json['id']),
      fincaId: serializer.fromJson<String>(json['fincaId']),
      nombre: serializer.fromJson<String>(json['nombre']),
      costoEnvase: serializer.fromJson<double>(json['costoEnvase']),
      tipoAplicacion: serializer.fromJson<String>(json['tipoAplicacion']),
      mlEnvase: serializer.fromJson<double?>(json['mlEnvase']),
      aplicacionesPorEnvase: serializer.fromJson<double?>(
        json['aplicacionesPorEnvase'],
      ),
      dosisCantidad: serializer.fromJson<double?>(json['dosisCantidad']),
      dosisPorCadaKg: serializer.fromJson<double?>(json['dosisPorCadaKg']),
      diasRetiro: serializer.fromJson<int>(json['diasRetiro']),
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
      'costoEnvase': serializer.toJson<double>(costoEnvase),
      'tipoAplicacion': serializer.toJson<String>(tipoAplicacion),
      'mlEnvase': serializer.toJson<double?>(mlEnvase),
      'aplicacionesPorEnvase': serializer.toJson<double?>(
        aplicacionesPorEnvase,
      ),
      'dosisCantidad': serializer.toJson<double?>(dosisCantidad),
      'dosisPorCadaKg': serializer.toJson<double?>(dosisPorCadaKg),
      'diasRetiro': serializer.toJson<int>(diasRetiro),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'pendiente': serializer.toJson<bool>(pendiente),
    };
  }

  MedicamentoRow copyWith({
    String? id,
    String? fincaId,
    String? nombre,
    double? costoEnvase,
    String? tipoAplicacion,
    Value<double?> mlEnvase = const Value.absent(),
    Value<double?> aplicacionesPorEnvase = const Value.absent(),
    Value<double?> dosisCantidad = const Value.absent(),
    Value<double?> dosisPorCadaKg = const Value.absent(),
    int? diasRetiro,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    bool? pendiente,
  }) => MedicamentoRow(
    id: id ?? this.id,
    fincaId: fincaId ?? this.fincaId,
    nombre: nombre ?? this.nombre,
    costoEnvase: costoEnvase ?? this.costoEnvase,
    tipoAplicacion: tipoAplicacion ?? this.tipoAplicacion,
    mlEnvase: mlEnvase.present ? mlEnvase.value : this.mlEnvase,
    aplicacionesPorEnvase: aplicacionesPorEnvase.present
        ? aplicacionesPorEnvase.value
        : this.aplicacionesPorEnvase,
    dosisCantidad: dosisCantidad.present
        ? dosisCantidad.value
        : this.dosisCantidad,
    dosisPorCadaKg: dosisPorCadaKg.present
        ? dosisPorCadaKg.value
        : this.dosisPorCadaKg,
    diasRetiro: diasRetiro ?? this.diasRetiro,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    pendiente: pendiente ?? this.pendiente,
  );
  MedicamentoRow copyWithCompanion(MedicamentosCompanion data) {
    return MedicamentoRow(
      id: data.id.present ? data.id.value : this.id,
      fincaId: data.fincaId.present ? data.fincaId.value : this.fincaId,
      nombre: data.nombre.present ? data.nombre.value : this.nombre,
      costoEnvase: data.costoEnvase.present
          ? data.costoEnvase.value
          : this.costoEnvase,
      tipoAplicacion: data.tipoAplicacion.present
          ? data.tipoAplicacion.value
          : this.tipoAplicacion,
      mlEnvase: data.mlEnvase.present ? data.mlEnvase.value : this.mlEnvase,
      aplicacionesPorEnvase: data.aplicacionesPorEnvase.present
          ? data.aplicacionesPorEnvase.value
          : this.aplicacionesPorEnvase,
      dosisCantidad: data.dosisCantidad.present
          ? data.dosisCantidad.value
          : this.dosisCantidad,
      dosisPorCadaKg: data.dosisPorCadaKg.present
          ? data.dosisPorCadaKg.value
          : this.dosisPorCadaKg,
      diasRetiro: data.diasRetiro.present
          ? data.diasRetiro.value
          : this.diasRetiro,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      pendiente: data.pendiente.present ? data.pendiente.value : this.pendiente,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MedicamentoRow(')
          ..write('id: $id, ')
          ..write('fincaId: $fincaId, ')
          ..write('nombre: $nombre, ')
          ..write('costoEnvase: $costoEnvase, ')
          ..write('tipoAplicacion: $tipoAplicacion, ')
          ..write('mlEnvase: $mlEnvase, ')
          ..write('aplicacionesPorEnvase: $aplicacionesPorEnvase, ')
          ..write('dosisCantidad: $dosisCantidad, ')
          ..write('dosisPorCadaKg: $dosisPorCadaKg, ')
          ..write('diasRetiro: $diasRetiro, ')
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
    costoEnvase,
    tipoAplicacion,
    mlEnvase,
    aplicacionesPorEnvase,
    dosisCantidad,
    dosisPorCadaKg,
    diasRetiro,
    createdAt,
    updatedAt,
    deletedAt,
    pendiente,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MedicamentoRow &&
          other.id == this.id &&
          other.fincaId == this.fincaId &&
          other.nombre == this.nombre &&
          other.costoEnvase == this.costoEnvase &&
          other.tipoAplicacion == this.tipoAplicacion &&
          other.mlEnvase == this.mlEnvase &&
          other.aplicacionesPorEnvase == this.aplicacionesPorEnvase &&
          other.dosisCantidad == this.dosisCantidad &&
          other.dosisPorCadaKg == this.dosisPorCadaKg &&
          other.diasRetiro == this.diasRetiro &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.pendiente == this.pendiente);
}

class MedicamentosCompanion extends UpdateCompanion<MedicamentoRow> {
  final Value<String> id;
  final Value<String> fincaId;
  final Value<String> nombre;
  final Value<double> costoEnvase;
  final Value<String> tipoAplicacion;
  final Value<double?> mlEnvase;
  final Value<double?> aplicacionesPorEnvase;
  final Value<double?> dosisCantidad;
  final Value<double?> dosisPorCadaKg;
  final Value<int> diasRetiro;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<bool> pendiente;
  final Value<int> rowid;
  const MedicamentosCompanion({
    this.id = const Value.absent(),
    this.fincaId = const Value.absent(),
    this.nombre = const Value.absent(),
    this.costoEnvase = const Value.absent(),
    this.tipoAplicacion = const Value.absent(),
    this.mlEnvase = const Value.absent(),
    this.aplicacionesPorEnvase = const Value.absent(),
    this.dosisCantidad = const Value.absent(),
    this.dosisPorCadaKg = const Value.absent(),
    this.diasRetiro = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.pendiente = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MedicamentosCompanion.insert({
    required String id,
    required String fincaId,
    required String nombre,
    required double costoEnvase,
    required String tipoAplicacion,
    this.mlEnvase = const Value.absent(),
    this.aplicacionesPorEnvase = const Value.absent(),
    this.dosisCantidad = const Value.absent(),
    this.dosisPorCadaKg = const Value.absent(),
    this.diasRetiro = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.pendiente = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       fincaId = Value(fincaId),
       nombre = Value(nombre),
       costoEnvase = Value(costoEnvase),
       tipoAplicacion = Value(tipoAplicacion),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<MedicamentoRow> custom({
    Expression<String>? id,
    Expression<String>? fincaId,
    Expression<String>? nombre,
    Expression<double>? costoEnvase,
    Expression<String>? tipoAplicacion,
    Expression<double>? mlEnvase,
    Expression<double>? aplicacionesPorEnvase,
    Expression<double>? dosisCantidad,
    Expression<double>? dosisPorCadaKg,
    Expression<int>? diasRetiro,
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
      if (costoEnvase != null) 'costo_envase': costoEnvase,
      if (tipoAplicacion != null) 'tipo_aplicacion': tipoAplicacion,
      if (mlEnvase != null) 'ml_envase': mlEnvase,
      if (aplicacionesPorEnvase != null)
        'aplicaciones_por_envase': aplicacionesPorEnvase,
      if (dosisCantidad != null) 'dosis_cantidad': dosisCantidad,
      if (dosisPorCadaKg != null) 'dosis_por_cada_kg': dosisPorCadaKg,
      if (diasRetiro != null) 'dias_retiro': diasRetiro,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (pendiente != null) 'pendiente': pendiente,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MedicamentosCompanion copyWith({
    Value<String>? id,
    Value<String>? fincaId,
    Value<String>? nombre,
    Value<double>? costoEnvase,
    Value<String>? tipoAplicacion,
    Value<double?>? mlEnvase,
    Value<double?>? aplicacionesPorEnvase,
    Value<double?>? dosisCantidad,
    Value<double?>? dosisPorCadaKg,
    Value<int>? diasRetiro,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<bool>? pendiente,
    Value<int>? rowid,
  }) {
    return MedicamentosCompanion(
      id: id ?? this.id,
      fincaId: fincaId ?? this.fincaId,
      nombre: nombre ?? this.nombre,
      costoEnvase: costoEnvase ?? this.costoEnvase,
      tipoAplicacion: tipoAplicacion ?? this.tipoAplicacion,
      mlEnvase: mlEnvase ?? this.mlEnvase,
      aplicacionesPorEnvase:
          aplicacionesPorEnvase ?? this.aplicacionesPorEnvase,
      dosisCantidad: dosisCantidad ?? this.dosisCantidad,
      dosisPorCadaKg: dosisPorCadaKg ?? this.dosisPorCadaKg,
      diasRetiro: diasRetiro ?? this.diasRetiro,
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
    if (costoEnvase.present) {
      map['costo_envase'] = Variable<double>(costoEnvase.value);
    }
    if (tipoAplicacion.present) {
      map['tipo_aplicacion'] = Variable<String>(tipoAplicacion.value);
    }
    if (mlEnvase.present) {
      map['ml_envase'] = Variable<double>(mlEnvase.value);
    }
    if (aplicacionesPorEnvase.present) {
      map['aplicaciones_por_envase'] = Variable<double>(
        aplicacionesPorEnvase.value,
      );
    }
    if (dosisCantidad.present) {
      map['dosis_cantidad'] = Variable<double>(dosisCantidad.value);
    }
    if (dosisPorCadaKg.present) {
      map['dosis_por_cada_kg'] = Variable<double>(dosisPorCadaKg.value);
    }
    if (diasRetiro.present) {
      map['dias_retiro'] = Variable<int>(diasRetiro.value);
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
    return (StringBuffer('MedicamentosCompanion(')
          ..write('id: $id, ')
          ..write('fincaId: $fincaId, ')
          ..write('nombre: $nombre, ')
          ..write('costoEnvase: $costoEnvase, ')
          ..write('tipoAplicacion: $tipoAplicacion, ')
          ..write('mlEnvase: $mlEnvase, ')
          ..write('aplicacionesPorEnvase: $aplicacionesPorEnvase, ')
          ..write('dosisCantidad: $dosisCantidad, ')
          ..write('dosisPorCadaKg: $dosisPorCadaKg, ')
          ..write('diasRetiro: $diasRetiro, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('pendiente: $pendiente, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EventosSanitariosTable extends EventosSanitarios
    with TableInfo<$EventosSanitariosTable, EventoSanitarioRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EventosSanitariosTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _tipoMeta = const VerificationMeta('tipo');
  @override
  late final GeneratedColumn<String> tipo = GeneratedColumn<String>(
    'tipo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _productoMeta = const VerificationMeta(
    'producto',
  );
  @override
  late final GeneratedColumn<String> producto = GeneratedColumn<String>(
    'producto',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dosisMeta = const VerificationMeta('dosis');
  @override
  late final GeneratedColumn<String> dosis = GeneratedColumn<String>(
    'dosis',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  static const VerificationMeta _responsableIdMeta = const VerificationMeta(
    'responsableId',
  );
  @override
  late final GeneratedColumn<String> responsableId = GeneratedColumn<String>(
    'responsable_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _observacionesMeta = const VerificationMeta(
    'observaciones',
  );
  @override
  late final GeneratedColumn<String> observaciones = GeneratedColumn<String>(
    'observaciones',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _costoMeta = const VerificationMeta('costo');
  @override
  late final GeneratedColumn<double> costo = GeneratedColumn<double>(
    'costo',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _medicamentoIdMeta = const VerificationMeta(
    'medicamentoId',
  );
  @override
  late final GeneratedColumn<String> medicamentoId = GeneratedColumn<String>(
    'medicamento_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _mlAplicadosMeta = const VerificationMeta(
    'mlAplicados',
  );
  @override
  late final GeneratedColumn<double> mlAplicados = GeneratedColumn<double>(
    'ml_aplicados',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _aplicacionesMeta = const VerificationMeta(
    'aplicaciones',
  );
  @override
  late final GeneratedColumn<int> aplicaciones = GeneratedColumn<int>(
    'aplicaciones',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _diasRetiroMeta = const VerificationMeta(
    'diasRetiro',
  );
  @override
  late final GeneratedColumn<int> diasRetiro = GeneratedColumn<int>(
    'dias_retiro',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _retiroHastaMeta = const VerificationMeta(
    'retiroHasta',
  );
  @override
  late final GeneratedColumn<DateTime> retiroHasta = GeneratedColumn<DateTime>(
    'retiro_hasta',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
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
    tipo,
    producto,
    dosis,
    fecha,
    responsableId,
    observaciones,
    costo,
    medicamentoId,
    mlAplicados,
    aplicaciones,
    diasRetiro,
    retiroHasta,
    createdAt,
    updatedAt,
    deletedAt,
    pendiente,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'eventos_sanitarios';
  @override
  VerificationContext validateIntegrity(
    Insertable<EventoSanitarioRow> instance, {
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
    if (data.containsKey('tipo')) {
      context.handle(
        _tipoMeta,
        tipo.isAcceptableOrUnknown(data['tipo']!, _tipoMeta),
      );
    } else if (isInserting) {
      context.missing(_tipoMeta);
    }
    if (data.containsKey('producto')) {
      context.handle(
        _productoMeta,
        producto.isAcceptableOrUnknown(data['producto']!, _productoMeta),
      );
    } else if (isInserting) {
      context.missing(_productoMeta);
    }
    if (data.containsKey('dosis')) {
      context.handle(
        _dosisMeta,
        dosis.isAcceptableOrUnknown(data['dosis']!, _dosisMeta),
      );
    }
    if (data.containsKey('fecha')) {
      context.handle(
        _fechaMeta,
        fecha.isAcceptableOrUnknown(data['fecha']!, _fechaMeta),
      );
    } else if (isInserting) {
      context.missing(_fechaMeta);
    }
    if (data.containsKey('responsable_id')) {
      context.handle(
        _responsableIdMeta,
        responsableId.isAcceptableOrUnknown(
          data['responsable_id']!,
          _responsableIdMeta,
        ),
      );
    }
    if (data.containsKey('observaciones')) {
      context.handle(
        _observacionesMeta,
        observaciones.isAcceptableOrUnknown(
          data['observaciones']!,
          _observacionesMeta,
        ),
      );
    }
    if (data.containsKey('costo')) {
      context.handle(
        _costoMeta,
        costo.isAcceptableOrUnknown(data['costo']!, _costoMeta),
      );
    }
    if (data.containsKey('medicamento_id')) {
      context.handle(
        _medicamentoIdMeta,
        medicamentoId.isAcceptableOrUnknown(
          data['medicamento_id']!,
          _medicamentoIdMeta,
        ),
      );
    }
    if (data.containsKey('ml_aplicados')) {
      context.handle(
        _mlAplicadosMeta,
        mlAplicados.isAcceptableOrUnknown(
          data['ml_aplicados']!,
          _mlAplicadosMeta,
        ),
      );
    }
    if (data.containsKey('aplicaciones')) {
      context.handle(
        _aplicacionesMeta,
        aplicaciones.isAcceptableOrUnknown(
          data['aplicaciones']!,
          _aplicacionesMeta,
        ),
      );
    }
    if (data.containsKey('dias_retiro')) {
      context.handle(
        _diasRetiroMeta,
        diasRetiro.isAcceptableOrUnknown(data['dias_retiro']!, _diasRetiroMeta),
      );
    }
    if (data.containsKey('retiro_hasta')) {
      context.handle(
        _retiroHastaMeta,
        retiroHasta.isAcceptableOrUnknown(
          data['retiro_hasta']!,
          _retiroHastaMeta,
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
  EventoSanitarioRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EventoSanitarioRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      animalId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}animal_id'],
      )!,
      tipo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tipo'],
      )!,
      producto: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}producto'],
      )!,
      dosis: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dosis'],
      ),
      fecha: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fecha'],
      )!,
      responsableId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}responsable_id'],
      ),
      observaciones: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}observaciones'],
      ),
      costo: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}costo'],
      ),
      medicamentoId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}medicamento_id'],
      ),
      mlAplicados: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}ml_aplicados'],
      ),
      aplicaciones: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}aplicaciones'],
      ),
      diasRetiro: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}dias_retiro'],
      ),
      retiroHasta: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}retiro_hasta'],
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
  $EventosSanitariosTable createAlias(String alias) {
    return $EventosSanitariosTable(attachedDatabase, alias);
  }
}

class EventoSanitarioRow extends DataClass
    implements Insertable<EventoSanitarioRow> {
  final String id;
  final String animalId;
  final String tipo;
  final String producto;
  final String? dosis;
  final DateTime fecha;
  final String? responsableId;
  final String? observaciones;
  final double? costo;
  final String? medicamentoId;
  final double? mlAplicados;
  final int? aplicaciones;
  final int? diasRetiro;
  final DateTime? retiroHasta;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final bool pendiente;
  const EventoSanitarioRow({
    required this.id,
    required this.animalId,
    required this.tipo,
    required this.producto,
    this.dosis,
    required this.fecha,
    this.responsableId,
    this.observaciones,
    this.costo,
    this.medicamentoId,
    this.mlAplicados,
    this.aplicaciones,
    this.diasRetiro,
    this.retiroHasta,
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
    map['tipo'] = Variable<String>(tipo);
    map['producto'] = Variable<String>(producto);
    if (!nullToAbsent || dosis != null) {
      map['dosis'] = Variable<String>(dosis);
    }
    map['fecha'] = Variable<DateTime>(fecha);
    if (!nullToAbsent || responsableId != null) {
      map['responsable_id'] = Variable<String>(responsableId);
    }
    if (!nullToAbsent || observaciones != null) {
      map['observaciones'] = Variable<String>(observaciones);
    }
    if (!nullToAbsent || costo != null) {
      map['costo'] = Variable<double>(costo);
    }
    if (!nullToAbsent || medicamentoId != null) {
      map['medicamento_id'] = Variable<String>(medicamentoId);
    }
    if (!nullToAbsent || mlAplicados != null) {
      map['ml_aplicados'] = Variable<double>(mlAplicados);
    }
    if (!nullToAbsent || aplicaciones != null) {
      map['aplicaciones'] = Variable<int>(aplicaciones);
    }
    if (!nullToAbsent || diasRetiro != null) {
      map['dias_retiro'] = Variable<int>(diasRetiro);
    }
    if (!nullToAbsent || retiroHasta != null) {
      map['retiro_hasta'] = Variable<DateTime>(retiroHasta);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['pendiente'] = Variable<bool>(pendiente);
    return map;
  }

  EventosSanitariosCompanion toCompanion(bool nullToAbsent) {
    return EventosSanitariosCompanion(
      id: Value(id),
      animalId: Value(animalId),
      tipo: Value(tipo),
      producto: Value(producto),
      dosis: dosis == null && nullToAbsent
          ? const Value.absent()
          : Value(dosis),
      fecha: Value(fecha),
      responsableId: responsableId == null && nullToAbsent
          ? const Value.absent()
          : Value(responsableId),
      observaciones: observaciones == null && nullToAbsent
          ? const Value.absent()
          : Value(observaciones),
      costo: costo == null && nullToAbsent
          ? const Value.absent()
          : Value(costo),
      medicamentoId: medicamentoId == null && nullToAbsent
          ? const Value.absent()
          : Value(medicamentoId),
      mlAplicados: mlAplicados == null && nullToAbsent
          ? const Value.absent()
          : Value(mlAplicados),
      aplicaciones: aplicaciones == null && nullToAbsent
          ? const Value.absent()
          : Value(aplicaciones),
      diasRetiro: diasRetiro == null && nullToAbsent
          ? const Value.absent()
          : Value(diasRetiro),
      retiroHasta: retiroHasta == null && nullToAbsent
          ? const Value.absent()
          : Value(retiroHasta),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      pendiente: Value(pendiente),
    );
  }

  factory EventoSanitarioRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EventoSanitarioRow(
      id: serializer.fromJson<String>(json['id']),
      animalId: serializer.fromJson<String>(json['animalId']),
      tipo: serializer.fromJson<String>(json['tipo']),
      producto: serializer.fromJson<String>(json['producto']),
      dosis: serializer.fromJson<String?>(json['dosis']),
      fecha: serializer.fromJson<DateTime>(json['fecha']),
      responsableId: serializer.fromJson<String?>(json['responsableId']),
      observaciones: serializer.fromJson<String?>(json['observaciones']),
      costo: serializer.fromJson<double?>(json['costo']),
      medicamentoId: serializer.fromJson<String?>(json['medicamentoId']),
      mlAplicados: serializer.fromJson<double?>(json['mlAplicados']),
      aplicaciones: serializer.fromJson<int?>(json['aplicaciones']),
      diasRetiro: serializer.fromJson<int?>(json['diasRetiro']),
      retiroHasta: serializer.fromJson<DateTime?>(json['retiroHasta']),
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
      'tipo': serializer.toJson<String>(tipo),
      'producto': serializer.toJson<String>(producto),
      'dosis': serializer.toJson<String?>(dosis),
      'fecha': serializer.toJson<DateTime>(fecha),
      'responsableId': serializer.toJson<String?>(responsableId),
      'observaciones': serializer.toJson<String?>(observaciones),
      'costo': serializer.toJson<double?>(costo),
      'medicamentoId': serializer.toJson<String?>(medicamentoId),
      'mlAplicados': serializer.toJson<double?>(mlAplicados),
      'aplicaciones': serializer.toJson<int?>(aplicaciones),
      'diasRetiro': serializer.toJson<int?>(diasRetiro),
      'retiroHasta': serializer.toJson<DateTime?>(retiroHasta),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'pendiente': serializer.toJson<bool>(pendiente),
    };
  }

  EventoSanitarioRow copyWith({
    String? id,
    String? animalId,
    String? tipo,
    String? producto,
    Value<String?> dosis = const Value.absent(),
    DateTime? fecha,
    Value<String?> responsableId = const Value.absent(),
    Value<String?> observaciones = const Value.absent(),
    Value<double?> costo = const Value.absent(),
    Value<String?> medicamentoId = const Value.absent(),
    Value<double?> mlAplicados = const Value.absent(),
    Value<int?> aplicaciones = const Value.absent(),
    Value<int?> diasRetiro = const Value.absent(),
    Value<DateTime?> retiroHasta = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    bool? pendiente,
  }) => EventoSanitarioRow(
    id: id ?? this.id,
    animalId: animalId ?? this.animalId,
    tipo: tipo ?? this.tipo,
    producto: producto ?? this.producto,
    dosis: dosis.present ? dosis.value : this.dosis,
    fecha: fecha ?? this.fecha,
    responsableId: responsableId.present
        ? responsableId.value
        : this.responsableId,
    observaciones: observaciones.present
        ? observaciones.value
        : this.observaciones,
    costo: costo.present ? costo.value : this.costo,
    medicamentoId: medicamentoId.present
        ? medicamentoId.value
        : this.medicamentoId,
    mlAplicados: mlAplicados.present ? mlAplicados.value : this.mlAplicados,
    aplicaciones: aplicaciones.present ? aplicaciones.value : this.aplicaciones,
    diasRetiro: diasRetiro.present ? diasRetiro.value : this.diasRetiro,
    retiroHasta: retiroHasta.present ? retiroHasta.value : this.retiroHasta,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    pendiente: pendiente ?? this.pendiente,
  );
  EventoSanitarioRow copyWithCompanion(EventosSanitariosCompanion data) {
    return EventoSanitarioRow(
      id: data.id.present ? data.id.value : this.id,
      animalId: data.animalId.present ? data.animalId.value : this.animalId,
      tipo: data.tipo.present ? data.tipo.value : this.tipo,
      producto: data.producto.present ? data.producto.value : this.producto,
      dosis: data.dosis.present ? data.dosis.value : this.dosis,
      fecha: data.fecha.present ? data.fecha.value : this.fecha,
      responsableId: data.responsableId.present
          ? data.responsableId.value
          : this.responsableId,
      observaciones: data.observaciones.present
          ? data.observaciones.value
          : this.observaciones,
      costo: data.costo.present ? data.costo.value : this.costo,
      medicamentoId: data.medicamentoId.present
          ? data.medicamentoId.value
          : this.medicamentoId,
      mlAplicados: data.mlAplicados.present
          ? data.mlAplicados.value
          : this.mlAplicados,
      aplicaciones: data.aplicaciones.present
          ? data.aplicaciones.value
          : this.aplicaciones,
      diasRetiro: data.diasRetiro.present
          ? data.diasRetiro.value
          : this.diasRetiro,
      retiroHasta: data.retiroHasta.present
          ? data.retiroHasta.value
          : this.retiroHasta,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      pendiente: data.pendiente.present ? data.pendiente.value : this.pendiente,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EventoSanitarioRow(')
          ..write('id: $id, ')
          ..write('animalId: $animalId, ')
          ..write('tipo: $tipo, ')
          ..write('producto: $producto, ')
          ..write('dosis: $dosis, ')
          ..write('fecha: $fecha, ')
          ..write('responsableId: $responsableId, ')
          ..write('observaciones: $observaciones, ')
          ..write('costo: $costo, ')
          ..write('medicamentoId: $medicamentoId, ')
          ..write('mlAplicados: $mlAplicados, ')
          ..write('aplicaciones: $aplicaciones, ')
          ..write('diasRetiro: $diasRetiro, ')
          ..write('retiroHasta: $retiroHasta, ')
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
    tipo,
    producto,
    dosis,
    fecha,
    responsableId,
    observaciones,
    costo,
    medicamentoId,
    mlAplicados,
    aplicaciones,
    diasRetiro,
    retiroHasta,
    createdAt,
    updatedAt,
    deletedAt,
    pendiente,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EventoSanitarioRow &&
          other.id == this.id &&
          other.animalId == this.animalId &&
          other.tipo == this.tipo &&
          other.producto == this.producto &&
          other.dosis == this.dosis &&
          other.fecha == this.fecha &&
          other.responsableId == this.responsableId &&
          other.observaciones == this.observaciones &&
          other.costo == this.costo &&
          other.medicamentoId == this.medicamentoId &&
          other.mlAplicados == this.mlAplicados &&
          other.aplicaciones == this.aplicaciones &&
          other.diasRetiro == this.diasRetiro &&
          other.retiroHasta == this.retiroHasta &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.pendiente == this.pendiente);
}

class EventosSanitariosCompanion extends UpdateCompanion<EventoSanitarioRow> {
  final Value<String> id;
  final Value<String> animalId;
  final Value<String> tipo;
  final Value<String> producto;
  final Value<String?> dosis;
  final Value<DateTime> fecha;
  final Value<String?> responsableId;
  final Value<String?> observaciones;
  final Value<double?> costo;
  final Value<String?> medicamentoId;
  final Value<double?> mlAplicados;
  final Value<int?> aplicaciones;
  final Value<int?> diasRetiro;
  final Value<DateTime?> retiroHasta;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<bool> pendiente;
  final Value<int> rowid;
  const EventosSanitariosCompanion({
    this.id = const Value.absent(),
    this.animalId = const Value.absent(),
    this.tipo = const Value.absent(),
    this.producto = const Value.absent(),
    this.dosis = const Value.absent(),
    this.fecha = const Value.absent(),
    this.responsableId = const Value.absent(),
    this.observaciones = const Value.absent(),
    this.costo = const Value.absent(),
    this.medicamentoId = const Value.absent(),
    this.mlAplicados = const Value.absent(),
    this.aplicaciones = const Value.absent(),
    this.diasRetiro = const Value.absent(),
    this.retiroHasta = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.pendiente = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EventosSanitariosCompanion.insert({
    required String id,
    required String animalId,
    required String tipo,
    required String producto,
    this.dosis = const Value.absent(),
    required DateTime fecha,
    this.responsableId = const Value.absent(),
    this.observaciones = const Value.absent(),
    this.costo = const Value.absent(),
    this.medicamentoId = const Value.absent(),
    this.mlAplicados = const Value.absent(),
    this.aplicaciones = const Value.absent(),
    this.diasRetiro = const Value.absent(),
    this.retiroHasta = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.pendiente = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       animalId = Value(animalId),
       tipo = Value(tipo),
       producto = Value(producto),
       fecha = Value(fecha),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<EventoSanitarioRow> custom({
    Expression<String>? id,
    Expression<String>? animalId,
    Expression<String>? tipo,
    Expression<String>? producto,
    Expression<String>? dosis,
    Expression<DateTime>? fecha,
    Expression<String>? responsableId,
    Expression<String>? observaciones,
    Expression<double>? costo,
    Expression<String>? medicamentoId,
    Expression<double>? mlAplicados,
    Expression<int>? aplicaciones,
    Expression<int>? diasRetiro,
    Expression<DateTime>? retiroHasta,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<bool>? pendiente,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (animalId != null) 'animal_id': animalId,
      if (tipo != null) 'tipo': tipo,
      if (producto != null) 'producto': producto,
      if (dosis != null) 'dosis': dosis,
      if (fecha != null) 'fecha': fecha,
      if (responsableId != null) 'responsable_id': responsableId,
      if (observaciones != null) 'observaciones': observaciones,
      if (costo != null) 'costo': costo,
      if (medicamentoId != null) 'medicamento_id': medicamentoId,
      if (mlAplicados != null) 'ml_aplicados': mlAplicados,
      if (aplicaciones != null) 'aplicaciones': aplicaciones,
      if (diasRetiro != null) 'dias_retiro': diasRetiro,
      if (retiroHasta != null) 'retiro_hasta': retiroHasta,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (pendiente != null) 'pendiente': pendiente,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EventosSanitariosCompanion copyWith({
    Value<String>? id,
    Value<String>? animalId,
    Value<String>? tipo,
    Value<String>? producto,
    Value<String?>? dosis,
    Value<DateTime>? fecha,
    Value<String?>? responsableId,
    Value<String?>? observaciones,
    Value<double?>? costo,
    Value<String?>? medicamentoId,
    Value<double?>? mlAplicados,
    Value<int?>? aplicaciones,
    Value<int?>? diasRetiro,
    Value<DateTime?>? retiroHasta,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<bool>? pendiente,
    Value<int>? rowid,
  }) {
    return EventosSanitariosCompanion(
      id: id ?? this.id,
      animalId: animalId ?? this.animalId,
      tipo: tipo ?? this.tipo,
      producto: producto ?? this.producto,
      dosis: dosis ?? this.dosis,
      fecha: fecha ?? this.fecha,
      responsableId: responsableId ?? this.responsableId,
      observaciones: observaciones ?? this.observaciones,
      costo: costo ?? this.costo,
      medicamentoId: medicamentoId ?? this.medicamentoId,
      mlAplicados: mlAplicados ?? this.mlAplicados,
      aplicaciones: aplicaciones ?? this.aplicaciones,
      diasRetiro: diasRetiro ?? this.diasRetiro,
      retiroHasta: retiroHasta ?? this.retiroHasta,
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
    if (tipo.present) {
      map['tipo'] = Variable<String>(tipo.value);
    }
    if (producto.present) {
      map['producto'] = Variable<String>(producto.value);
    }
    if (dosis.present) {
      map['dosis'] = Variable<String>(dosis.value);
    }
    if (fecha.present) {
      map['fecha'] = Variable<DateTime>(fecha.value);
    }
    if (responsableId.present) {
      map['responsable_id'] = Variable<String>(responsableId.value);
    }
    if (observaciones.present) {
      map['observaciones'] = Variable<String>(observaciones.value);
    }
    if (costo.present) {
      map['costo'] = Variable<double>(costo.value);
    }
    if (medicamentoId.present) {
      map['medicamento_id'] = Variable<String>(medicamentoId.value);
    }
    if (mlAplicados.present) {
      map['ml_aplicados'] = Variable<double>(mlAplicados.value);
    }
    if (aplicaciones.present) {
      map['aplicaciones'] = Variable<int>(aplicaciones.value);
    }
    if (diasRetiro.present) {
      map['dias_retiro'] = Variable<int>(diasRetiro.value);
    }
    if (retiroHasta.present) {
      map['retiro_hasta'] = Variable<DateTime>(retiroHasta.value);
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
    return (StringBuffer('EventosSanitariosCompanion(')
          ..write('id: $id, ')
          ..write('animalId: $animalId, ')
          ..write('tipo: $tipo, ')
          ..write('producto: $producto, ')
          ..write('dosis: $dosis, ')
          ..write('fecha: $fecha, ')
          ..write('responsableId: $responsableId, ')
          ..write('observaciones: $observaciones, ')
          ..write('costo: $costo, ')
          ..write('medicamentoId: $medicamentoId, ')
          ..write('mlAplicados: $mlAplicados, ')
          ..write('aplicaciones: $aplicaciones, ')
          ..write('diasRetiro: $diasRetiro, ')
          ..write('retiroHasta: $retiroHasta, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('pendiente: $pendiente, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LotesVentaTable extends LotesVenta
    with TableInfo<$LotesVentaTable, LoteVentaRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LotesVentaTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _fechaMeta = const VerificationMeta('fecha');
  @override
  late final GeneratedColumn<DateTime> fecha = GeneratedColumn<DateTime>(
    'fecha',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
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
    fecha,
    createdAt,
    updatedAt,
    deletedAt,
    pendiente,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'lotes_venta';
  @override
  VerificationContext validateIntegrity(
    Insertable<LoteVentaRow> instance, {
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
    if (data.containsKey('fecha')) {
      context.handle(
        _fechaMeta,
        fecha.isAcceptableOrUnknown(data['fecha']!, _fechaMeta),
      );
    } else if (isInserting) {
      context.missing(_fechaMeta);
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
  LoteVentaRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LoteVentaRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      fincaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}finca_id'],
      )!,
      fecha: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fecha'],
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
  $LotesVentaTable createAlias(String alias) {
    return $LotesVentaTable(attachedDatabase, alias);
  }
}

class LoteVentaRow extends DataClass implements Insertable<LoteVentaRow> {
  final String id;
  final String fincaId;
  final DateTime fecha;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final bool pendiente;
  const LoteVentaRow({
    required this.id,
    required this.fincaId,
    required this.fecha,
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
    map['fecha'] = Variable<DateTime>(fecha);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['pendiente'] = Variable<bool>(pendiente);
    return map;
  }

  LotesVentaCompanion toCompanion(bool nullToAbsent) {
    return LotesVentaCompanion(
      id: Value(id),
      fincaId: Value(fincaId),
      fecha: Value(fecha),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      pendiente: Value(pendiente),
    );
  }

  factory LoteVentaRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LoteVentaRow(
      id: serializer.fromJson<String>(json['id']),
      fincaId: serializer.fromJson<String>(json['fincaId']),
      fecha: serializer.fromJson<DateTime>(json['fecha']),
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
      'fecha': serializer.toJson<DateTime>(fecha),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'pendiente': serializer.toJson<bool>(pendiente),
    };
  }

  LoteVentaRow copyWith({
    String? id,
    String? fincaId,
    DateTime? fecha,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    bool? pendiente,
  }) => LoteVentaRow(
    id: id ?? this.id,
    fincaId: fincaId ?? this.fincaId,
    fecha: fecha ?? this.fecha,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    pendiente: pendiente ?? this.pendiente,
  );
  LoteVentaRow copyWithCompanion(LotesVentaCompanion data) {
    return LoteVentaRow(
      id: data.id.present ? data.id.value : this.id,
      fincaId: data.fincaId.present ? data.fincaId.value : this.fincaId,
      fecha: data.fecha.present ? data.fecha.value : this.fecha,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      pendiente: data.pendiente.present ? data.pendiente.value : this.pendiente,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LoteVentaRow(')
          ..write('id: $id, ')
          ..write('fincaId: $fincaId, ')
          ..write('fecha: $fecha, ')
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
    fecha,
    createdAt,
    updatedAt,
    deletedAt,
    pendiente,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LoteVentaRow &&
          other.id == this.id &&
          other.fincaId == this.fincaId &&
          other.fecha == this.fecha &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.pendiente == this.pendiente);
}

class LotesVentaCompanion extends UpdateCompanion<LoteVentaRow> {
  final Value<String> id;
  final Value<String> fincaId;
  final Value<DateTime> fecha;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<bool> pendiente;
  final Value<int> rowid;
  const LotesVentaCompanion({
    this.id = const Value.absent(),
    this.fincaId = const Value.absent(),
    this.fecha = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.pendiente = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LotesVentaCompanion.insert({
    required String id,
    required String fincaId,
    required DateTime fecha,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.pendiente = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       fincaId = Value(fincaId),
       fecha = Value(fecha),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<LoteVentaRow> custom({
    Expression<String>? id,
    Expression<String>? fincaId,
    Expression<DateTime>? fecha,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<bool>? pendiente,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (fincaId != null) 'finca_id': fincaId,
      if (fecha != null) 'fecha': fecha,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (pendiente != null) 'pendiente': pendiente,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LotesVentaCompanion copyWith({
    Value<String>? id,
    Value<String>? fincaId,
    Value<DateTime>? fecha,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<bool>? pendiente,
    Value<int>? rowid,
  }) {
    return LotesVentaCompanion(
      id: id ?? this.id,
      fincaId: fincaId ?? this.fincaId,
      fecha: fecha ?? this.fecha,
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
    if (fecha.present) {
      map['fecha'] = Variable<DateTime>(fecha.value);
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
    return (StringBuffer('LotesVentaCompanion(')
          ..write('id: $id, ')
          ..write('fincaId: $fincaId, ')
          ..write('fecha: $fecha, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('pendiente: $pendiente, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $VentasTable extends Ventas with TableInfo<$VentasTable, VentaRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VentasTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _loteVentaIdMeta = const VerificationMeta(
    'loteVentaId',
  );
  @override
  late final GeneratedColumn<String> loteVentaId = GeneratedColumn<String>(
    'lote_venta_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  static const VerificationMeta _precioMeta = const VerificationMeta('precio');
  @override
  late final GeneratedColumn<double> precio = GeneratedColumn<double>(
    'precio',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pesoMeta = const VerificationMeta('peso');
  @override
  late final GeneratedColumn<double> peso = GeneratedColumn<double>(
    'peso',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _compradorMeta = const VerificationMeta(
    'comprador',
  );
  @override
  late final GeneratedColumn<String> comprador = GeneratedColumn<String>(
    'comprador',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _observacionesMeta = const VerificationMeta(
    'observaciones',
  );
  @override
  late final GeneratedColumn<String> observaciones = GeneratedColumn<String>(
    'observaciones',
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
    loteVentaId,
    fecha,
    precio,
    peso,
    comprador,
    observaciones,
    createdAt,
    updatedAt,
    deletedAt,
    pendiente,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ventas';
  @override
  VerificationContext validateIntegrity(
    Insertable<VentaRow> instance, {
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
    if (data.containsKey('lote_venta_id')) {
      context.handle(
        _loteVentaIdMeta,
        loteVentaId.isAcceptableOrUnknown(
          data['lote_venta_id']!,
          _loteVentaIdMeta,
        ),
      );
    }
    if (data.containsKey('fecha')) {
      context.handle(
        _fechaMeta,
        fecha.isAcceptableOrUnknown(data['fecha']!, _fechaMeta),
      );
    } else if (isInserting) {
      context.missing(_fechaMeta);
    }
    if (data.containsKey('precio')) {
      context.handle(
        _precioMeta,
        precio.isAcceptableOrUnknown(data['precio']!, _precioMeta),
      );
    } else if (isInserting) {
      context.missing(_precioMeta);
    }
    if (data.containsKey('peso')) {
      context.handle(
        _pesoMeta,
        peso.isAcceptableOrUnknown(data['peso']!, _pesoMeta),
      );
    }
    if (data.containsKey('comprador')) {
      context.handle(
        _compradorMeta,
        comprador.isAcceptableOrUnknown(data['comprador']!, _compradorMeta),
      );
    }
    if (data.containsKey('observaciones')) {
      context.handle(
        _observacionesMeta,
        observaciones.isAcceptableOrUnknown(
          data['observaciones']!,
          _observacionesMeta,
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
  VentaRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VentaRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      animalId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}animal_id'],
      )!,
      loteVentaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lote_venta_id'],
      ),
      fecha: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fecha'],
      )!,
      precio: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}precio'],
      )!,
      peso: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}peso'],
      ),
      comprador: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}comprador'],
      ),
      observaciones: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}observaciones'],
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
  $VentasTable createAlias(String alias) {
    return $VentasTable(attachedDatabase, alias);
  }
}

class VentaRow extends DataClass implements Insertable<VentaRow> {
  final String id;
  final String animalId;
  final String? loteVentaId;
  final DateTime fecha;
  final double precio;
  final double? peso;
  final String? comprador;
  final String? observaciones;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final bool pendiente;
  const VentaRow({
    required this.id,
    required this.animalId,
    this.loteVentaId,
    required this.fecha,
    required this.precio,
    this.peso,
    this.comprador,
    this.observaciones,
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
    if (!nullToAbsent || loteVentaId != null) {
      map['lote_venta_id'] = Variable<String>(loteVentaId);
    }
    map['fecha'] = Variable<DateTime>(fecha);
    map['precio'] = Variable<double>(precio);
    if (!nullToAbsent || peso != null) {
      map['peso'] = Variable<double>(peso);
    }
    if (!nullToAbsent || comprador != null) {
      map['comprador'] = Variable<String>(comprador);
    }
    if (!nullToAbsent || observaciones != null) {
      map['observaciones'] = Variable<String>(observaciones);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['pendiente'] = Variable<bool>(pendiente);
    return map;
  }

  VentasCompanion toCompanion(bool nullToAbsent) {
    return VentasCompanion(
      id: Value(id),
      animalId: Value(animalId),
      loteVentaId: loteVentaId == null && nullToAbsent
          ? const Value.absent()
          : Value(loteVentaId),
      fecha: Value(fecha),
      precio: Value(precio),
      peso: peso == null && nullToAbsent ? const Value.absent() : Value(peso),
      comprador: comprador == null && nullToAbsent
          ? const Value.absent()
          : Value(comprador),
      observaciones: observaciones == null && nullToAbsent
          ? const Value.absent()
          : Value(observaciones),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      pendiente: Value(pendiente),
    );
  }

  factory VentaRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VentaRow(
      id: serializer.fromJson<String>(json['id']),
      animalId: serializer.fromJson<String>(json['animalId']),
      loteVentaId: serializer.fromJson<String?>(json['loteVentaId']),
      fecha: serializer.fromJson<DateTime>(json['fecha']),
      precio: serializer.fromJson<double>(json['precio']),
      peso: serializer.fromJson<double?>(json['peso']),
      comprador: serializer.fromJson<String?>(json['comprador']),
      observaciones: serializer.fromJson<String?>(json['observaciones']),
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
      'loteVentaId': serializer.toJson<String?>(loteVentaId),
      'fecha': serializer.toJson<DateTime>(fecha),
      'precio': serializer.toJson<double>(precio),
      'peso': serializer.toJson<double?>(peso),
      'comprador': serializer.toJson<String?>(comprador),
      'observaciones': serializer.toJson<String?>(observaciones),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'pendiente': serializer.toJson<bool>(pendiente),
    };
  }

  VentaRow copyWith({
    String? id,
    String? animalId,
    Value<String?> loteVentaId = const Value.absent(),
    DateTime? fecha,
    double? precio,
    Value<double?> peso = const Value.absent(),
    Value<String?> comprador = const Value.absent(),
    Value<String?> observaciones = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    bool? pendiente,
  }) => VentaRow(
    id: id ?? this.id,
    animalId: animalId ?? this.animalId,
    loteVentaId: loteVentaId.present ? loteVentaId.value : this.loteVentaId,
    fecha: fecha ?? this.fecha,
    precio: precio ?? this.precio,
    peso: peso.present ? peso.value : this.peso,
    comprador: comprador.present ? comprador.value : this.comprador,
    observaciones: observaciones.present
        ? observaciones.value
        : this.observaciones,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    pendiente: pendiente ?? this.pendiente,
  );
  VentaRow copyWithCompanion(VentasCompanion data) {
    return VentaRow(
      id: data.id.present ? data.id.value : this.id,
      animalId: data.animalId.present ? data.animalId.value : this.animalId,
      loteVentaId: data.loteVentaId.present
          ? data.loteVentaId.value
          : this.loteVentaId,
      fecha: data.fecha.present ? data.fecha.value : this.fecha,
      precio: data.precio.present ? data.precio.value : this.precio,
      peso: data.peso.present ? data.peso.value : this.peso,
      comprador: data.comprador.present ? data.comprador.value : this.comprador,
      observaciones: data.observaciones.present
          ? data.observaciones.value
          : this.observaciones,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      pendiente: data.pendiente.present ? data.pendiente.value : this.pendiente,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VentaRow(')
          ..write('id: $id, ')
          ..write('animalId: $animalId, ')
          ..write('loteVentaId: $loteVentaId, ')
          ..write('fecha: $fecha, ')
          ..write('precio: $precio, ')
          ..write('peso: $peso, ')
          ..write('comprador: $comprador, ')
          ..write('observaciones: $observaciones, ')
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
    loteVentaId,
    fecha,
    precio,
    peso,
    comprador,
    observaciones,
    createdAt,
    updatedAt,
    deletedAt,
    pendiente,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VentaRow &&
          other.id == this.id &&
          other.animalId == this.animalId &&
          other.loteVentaId == this.loteVentaId &&
          other.fecha == this.fecha &&
          other.precio == this.precio &&
          other.peso == this.peso &&
          other.comprador == this.comprador &&
          other.observaciones == this.observaciones &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.pendiente == this.pendiente);
}

class VentasCompanion extends UpdateCompanion<VentaRow> {
  final Value<String> id;
  final Value<String> animalId;
  final Value<String?> loteVentaId;
  final Value<DateTime> fecha;
  final Value<double> precio;
  final Value<double?> peso;
  final Value<String?> comprador;
  final Value<String?> observaciones;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<bool> pendiente;
  final Value<int> rowid;
  const VentasCompanion({
    this.id = const Value.absent(),
    this.animalId = const Value.absent(),
    this.loteVentaId = const Value.absent(),
    this.fecha = const Value.absent(),
    this.precio = const Value.absent(),
    this.peso = const Value.absent(),
    this.comprador = const Value.absent(),
    this.observaciones = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.pendiente = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VentasCompanion.insert({
    required String id,
    required String animalId,
    this.loteVentaId = const Value.absent(),
    required DateTime fecha,
    required double precio,
    this.peso = const Value.absent(),
    this.comprador = const Value.absent(),
    this.observaciones = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.pendiente = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       animalId = Value(animalId),
       fecha = Value(fecha),
       precio = Value(precio),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<VentaRow> custom({
    Expression<String>? id,
    Expression<String>? animalId,
    Expression<String>? loteVentaId,
    Expression<DateTime>? fecha,
    Expression<double>? precio,
    Expression<double>? peso,
    Expression<String>? comprador,
    Expression<String>? observaciones,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<bool>? pendiente,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (animalId != null) 'animal_id': animalId,
      if (loteVentaId != null) 'lote_venta_id': loteVentaId,
      if (fecha != null) 'fecha': fecha,
      if (precio != null) 'precio': precio,
      if (peso != null) 'peso': peso,
      if (comprador != null) 'comprador': comprador,
      if (observaciones != null) 'observaciones': observaciones,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (pendiente != null) 'pendiente': pendiente,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VentasCompanion copyWith({
    Value<String>? id,
    Value<String>? animalId,
    Value<String?>? loteVentaId,
    Value<DateTime>? fecha,
    Value<double>? precio,
    Value<double?>? peso,
    Value<String?>? comprador,
    Value<String?>? observaciones,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<bool>? pendiente,
    Value<int>? rowid,
  }) {
    return VentasCompanion(
      id: id ?? this.id,
      animalId: animalId ?? this.animalId,
      loteVentaId: loteVentaId ?? this.loteVentaId,
      fecha: fecha ?? this.fecha,
      precio: precio ?? this.precio,
      peso: peso ?? this.peso,
      comprador: comprador ?? this.comprador,
      observaciones: observaciones ?? this.observaciones,
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
    if (loteVentaId.present) {
      map['lote_venta_id'] = Variable<String>(loteVentaId.value);
    }
    if (fecha.present) {
      map['fecha'] = Variable<DateTime>(fecha.value);
    }
    if (precio.present) {
      map['precio'] = Variable<double>(precio.value);
    }
    if (peso.present) {
      map['peso'] = Variable<double>(peso.value);
    }
    if (comprador.present) {
      map['comprador'] = Variable<String>(comprador.value);
    }
    if (observaciones.present) {
      map['observaciones'] = Variable<String>(observaciones.value);
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
    return (StringBuffer('VentasCompanion(')
          ..write('id: $id, ')
          ..write('animalId: $animalId, ')
          ..write('loteVentaId: $loteVentaId, ')
          ..write('fecha: $fecha, ')
          ..write('precio: $precio, ')
          ..write('peso: $peso, ')
          ..write('comprador: $comprador, ')
          ..write('observaciones: $observaciones, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('pendiente: $pendiente, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CostosOtrosTable extends CostosOtros
    with TableInfo<$CostosOtrosTable, CostoOtroRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CostosOtrosTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _conceptoMeta = const VerificationMeta(
    'concepto',
  );
  @override
  late final GeneratedColumn<String> concepto = GeneratedColumn<String>(
    'concepto',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _montoMeta = const VerificationMeta('monto');
  @override
  late final GeneratedColumn<double> monto = GeneratedColumn<double>(
    'monto',
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
    concepto,
    monto,
    fecha,
    createdAt,
    updatedAt,
    deletedAt,
    pendiente,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'costos_otros';
  @override
  VerificationContext validateIntegrity(
    Insertable<CostoOtroRow> instance, {
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
    if (data.containsKey('concepto')) {
      context.handle(
        _conceptoMeta,
        concepto.isAcceptableOrUnknown(data['concepto']!, _conceptoMeta),
      );
    } else if (isInserting) {
      context.missing(_conceptoMeta);
    }
    if (data.containsKey('monto')) {
      context.handle(
        _montoMeta,
        monto.isAcceptableOrUnknown(data['monto']!, _montoMeta),
      );
    } else if (isInserting) {
      context.missing(_montoMeta);
    }
    if (data.containsKey('fecha')) {
      context.handle(
        _fechaMeta,
        fecha.isAcceptableOrUnknown(data['fecha']!, _fechaMeta),
      );
    } else if (isInserting) {
      context.missing(_fechaMeta);
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
  CostoOtroRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CostoOtroRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      animalId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}animal_id'],
      )!,
      concepto: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}concepto'],
      )!,
      monto: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}monto'],
      )!,
      fecha: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fecha'],
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
  $CostosOtrosTable createAlias(String alias) {
    return $CostosOtrosTable(attachedDatabase, alias);
  }
}

class CostoOtroRow extends DataClass implements Insertable<CostoOtroRow> {
  final String id;
  final String animalId;
  final String concepto;
  final double monto;
  final DateTime fecha;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final bool pendiente;
  const CostoOtroRow({
    required this.id,
    required this.animalId,
    required this.concepto,
    required this.monto,
    required this.fecha,
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
    map['concepto'] = Variable<String>(concepto);
    map['monto'] = Variable<double>(monto);
    map['fecha'] = Variable<DateTime>(fecha);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['pendiente'] = Variable<bool>(pendiente);
    return map;
  }

  CostosOtrosCompanion toCompanion(bool nullToAbsent) {
    return CostosOtrosCompanion(
      id: Value(id),
      animalId: Value(animalId),
      concepto: Value(concepto),
      monto: Value(monto),
      fecha: Value(fecha),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      pendiente: Value(pendiente),
    );
  }

  factory CostoOtroRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CostoOtroRow(
      id: serializer.fromJson<String>(json['id']),
      animalId: serializer.fromJson<String>(json['animalId']),
      concepto: serializer.fromJson<String>(json['concepto']),
      monto: serializer.fromJson<double>(json['monto']),
      fecha: serializer.fromJson<DateTime>(json['fecha']),
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
      'concepto': serializer.toJson<String>(concepto),
      'monto': serializer.toJson<double>(monto),
      'fecha': serializer.toJson<DateTime>(fecha),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'pendiente': serializer.toJson<bool>(pendiente),
    };
  }

  CostoOtroRow copyWith({
    String? id,
    String? animalId,
    String? concepto,
    double? monto,
    DateTime? fecha,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    bool? pendiente,
  }) => CostoOtroRow(
    id: id ?? this.id,
    animalId: animalId ?? this.animalId,
    concepto: concepto ?? this.concepto,
    monto: monto ?? this.monto,
    fecha: fecha ?? this.fecha,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    pendiente: pendiente ?? this.pendiente,
  );
  CostoOtroRow copyWithCompanion(CostosOtrosCompanion data) {
    return CostoOtroRow(
      id: data.id.present ? data.id.value : this.id,
      animalId: data.animalId.present ? data.animalId.value : this.animalId,
      concepto: data.concepto.present ? data.concepto.value : this.concepto,
      monto: data.monto.present ? data.monto.value : this.monto,
      fecha: data.fecha.present ? data.fecha.value : this.fecha,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      pendiente: data.pendiente.present ? data.pendiente.value : this.pendiente,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CostoOtroRow(')
          ..write('id: $id, ')
          ..write('animalId: $animalId, ')
          ..write('concepto: $concepto, ')
          ..write('monto: $monto, ')
          ..write('fecha: $fecha, ')
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
    concepto,
    monto,
    fecha,
    createdAt,
    updatedAt,
    deletedAt,
    pendiente,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CostoOtroRow &&
          other.id == this.id &&
          other.animalId == this.animalId &&
          other.concepto == this.concepto &&
          other.monto == this.monto &&
          other.fecha == this.fecha &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.pendiente == this.pendiente);
}

class CostosOtrosCompanion extends UpdateCompanion<CostoOtroRow> {
  final Value<String> id;
  final Value<String> animalId;
  final Value<String> concepto;
  final Value<double> monto;
  final Value<DateTime> fecha;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<bool> pendiente;
  final Value<int> rowid;
  const CostosOtrosCompanion({
    this.id = const Value.absent(),
    this.animalId = const Value.absent(),
    this.concepto = const Value.absent(),
    this.monto = const Value.absent(),
    this.fecha = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.pendiente = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CostosOtrosCompanion.insert({
    required String id,
    required String animalId,
    required String concepto,
    required double monto,
    required DateTime fecha,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.pendiente = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       animalId = Value(animalId),
       concepto = Value(concepto),
       monto = Value(monto),
       fecha = Value(fecha),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<CostoOtroRow> custom({
    Expression<String>? id,
    Expression<String>? animalId,
    Expression<String>? concepto,
    Expression<double>? monto,
    Expression<DateTime>? fecha,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<bool>? pendiente,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (animalId != null) 'animal_id': animalId,
      if (concepto != null) 'concepto': concepto,
      if (monto != null) 'monto': monto,
      if (fecha != null) 'fecha': fecha,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (pendiente != null) 'pendiente': pendiente,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CostosOtrosCompanion copyWith({
    Value<String>? id,
    Value<String>? animalId,
    Value<String>? concepto,
    Value<double>? monto,
    Value<DateTime>? fecha,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<bool>? pendiente,
    Value<int>? rowid,
  }) {
    return CostosOtrosCompanion(
      id: id ?? this.id,
      animalId: animalId ?? this.animalId,
      concepto: concepto ?? this.concepto,
      monto: monto ?? this.monto,
      fecha: fecha ?? this.fecha,
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
    if (concepto.present) {
      map['concepto'] = Variable<String>(concepto.value);
    }
    if (monto.present) {
      map['monto'] = Variable<double>(monto.value);
    }
    if (fecha.present) {
      map['fecha'] = Variable<DateTime>(fecha.value);
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
    return (StringBuffer('CostosOtrosCompanion(')
          ..write('id: $id, ')
          ..write('animalId: $animalId, ')
          ..write('concepto: $concepto, ')
          ..write('monto: $monto, ')
          ..write('fecha: $fecha, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('pendiente: $pendiente, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FeatureFlagsTable extends FeatureFlags
    with TableInfo<$FeatureFlagsTable, FeatureFlagRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FeatureFlagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scopeMeta = const VerificationMeta('scope');
  @override
  late final GeneratedColumn<String> scope = GeneratedColumn<String>(
    'scope',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scopeIdMeta = const VerificationMeta(
    'scopeId',
  );
  @override
  late final GeneratedColumn<String> scopeId = GeneratedColumn<String>(
    'scope_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _claveMeta = const VerificationMeta('clave');
  @override
  late final GeneratedColumn<String> clave = GeneratedColumn<String>(
    'clave',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _habilitadoMeta = const VerificationMeta(
    'habilitado',
  );
  @override
  late final GeneratedColumn<bool> habilitado = GeneratedColumn<bool>(
    'habilitado',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("habilitado" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _notaMeta = const VerificationMeta('nota');
  @override
  late final GeneratedColumn<String> nota = GeneratedColumn<String>(
    'nota',
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    scope,
    scopeId,
    clave,
    habilitado,
    nota,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'feature_flags';
  @override
  VerificationContext validateIntegrity(
    Insertable<FeatureFlagRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('scope')) {
      context.handle(
        _scopeMeta,
        scope.isAcceptableOrUnknown(data['scope']!, _scopeMeta),
      );
    } else if (isInserting) {
      context.missing(_scopeMeta);
    }
    if (data.containsKey('scope_id')) {
      context.handle(
        _scopeIdMeta,
        scopeId.isAcceptableOrUnknown(data['scope_id']!, _scopeIdMeta),
      );
    }
    if (data.containsKey('clave')) {
      context.handle(
        _claveMeta,
        clave.isAcceptableOrUnknown(data['clave']!, _claveMeta),
      );
    } else if (isInserting) {
      context.missing(_claveMeta);
    }
    if (data.containsKey('habilitado')) {
      context.handle(
        _habilitadoMeta,
        habilitado.isAcceptableOrUnknown(data['habilitado']!, _habilitadoMeta),
      );
    }
    if (data.containsKey('nota')) {
      context.handle(
        _notaMeta,
        nota.isAcceptableOrUnknown(data['nota']!, _notaMeta),
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FeatureFlagRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FeatureFlagRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      scope: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scope'],
      )!,
      scopeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scope_id'],
      ),
      clave: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}clave'],
      )!,
      habilitado: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}habilitado'],
      )!,
      nota: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nota'],
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
    );
  }

  @override
  $FeatureFlagsTable createAlias(String alias) {
    return $FeatureFlagsTable(attachedDatabase, alias);
  }
}

class FeatureFlagRow extends DataClass implements Insertable<FeatureFlagRow> {
  final String id;
  final String scope;
  final String? scopeId;
  final String clave;
  final bool habilitado;
  final String? nota;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const FeatureFlagRow({
    required this.id,
    required this.scope,
    this.scopeId,
    required this.clave,
    required this.habilitado,
    this.nota,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['scope'] = Variable<String>(scope);
    if (!nullToAbsent || scopeId != null) {
      map['scope_id'] = Variable<String>(scopeId);
    }
    map['clave'] = Variable<String>(clave);
    map['habilitado'] = Variable<bool>(habilitado);
    if (!nullToAbsent || nota != null) {
      map['nota'] = Variable<String>(nota);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  FeatureFlagsCompanion toCompanion(bool nullToAbsent) {
    return FeatureFlagsCompanion(
      id: Value(id),
      scope: Value(scope),
      scopeId: scopeId == null && nullToAbsent
          ? const Value.absent()
          : Value(scopeId),
      clave: Value(clave),
      habilitado: Value(habilitado),
      nota: nota == null && nullToAbsent ? const Value.absent() : Value(nota),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory FeatureFlagRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FeatureFlagRow(
      id: serializer.fromJson<String>(json['id']),
      scope: serializer.fromJson<String>(json['scope']),
      scopeId: serializer.fromJson<String?>(json['scopeId']),
      clave: serializer.fromJson<String>(json['clave']),
      habilitado: serializer.fromJson<bool>(json['habilitado']),
      nota: serializer.fromJson<String?>(json['nota']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'scope': serializer.toJson<String>(scope),
      'scopeId': serializer.toJson<String?>(scopeId),
      'clave': serializer.toJson<String>(clave),
      'habilitado': serializer.toJson<bool>(habilitado),
      'nota': serializer.toJson<String?>(nota),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  FeatureFlagRow copyWith({
    String? id,
    String? scope,
    Value<String?> scopeId = const Value.absent(),
    String? clave,
    bool? habilitado,
    Value<String?> nota = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => FeatureFlagRow(
    id: id ?? this.id,
    scope: scope ?? this.scope,
    scopeId: scopeId.present ? scopeId.value : this.scopeId,
    clave: clave ?? this.clave,
    habilitado: habilitado ?? this.habilitado,
    nota: nota.present ? nota.value : this.nota,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  FeatureFlagRow copyWithCompanion(FeatureFlagsCompanion data) {
    return FeatureFlagRow(
      id: data.id.present ? data.id.value : this.id,
      scope: data.scope.present ? data.scope.value : this.scope,
      scopeId: data.scopeId.present ? data.scopeId.value : this.scopeId,
      clave: data.clave.present ? data.clave.value : this.clave,
      habilitado: data.habilitado.present
          ? data.habilitado.value
          : this.habilitado,
      nota: data.nota.present ? data.nota.value : this.nota,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FeatureFlagRow(')
          ..write('id: $id, ')
          ..write('scope: $scope, ')
          ..write('scopeId: $scopeId, ')
          ..write('clave: $clave, ')
          ..write('habilitado: $habilitado, ')
          ..write('nota: $nota, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    scope,
    scopeId,
    clave,
    habilitado,
    nota,
    createdAt,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FeatureFlagRow &&
          other.id == this.id &&
          other.scope == this.scope &&
          other.scopeId == this.scopeId &&
          other.clave == this.clave &&
          other.habilitado == this.habilitado &&
          other.nota == this.nota &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class FeatureFlagsCompanion extends UpdateCompanion<FeatureFlagRow> {
  final Value<String> id;
  final Value<String> scope;
  final Value<String?> scopeId;
  final Value<String> clave;
  final Value<bool> habilitado;
  final Value<String?> nota;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const FeatureFlagsCompanion({
    this.id = const Value.absent(),
    this.scope = const Value.absent(),
    this.scopeId = const Value.absent(),
    this.clave = const Value.absent(),
    this.habilitado = const Value.absent(),
    this.nota = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FeatureFlagsCompanion.insert({
    required String id,
    required String scope,
    this.scopeId = const Value.absent(),
    required String clave,
    this.habilitado = const Value.absent(),
    this.nota = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       scope = Value(scope),
       clave = Value(clave),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<FeatureFlagRow> custom({
    Expression<String>? id,
    Expression<String>? scope,
    Expression<String>? scopeId,
    Expression<String>? clave,
    Expression<bool>? habilitado,
    Expression<String>? nota,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (scope != null) 'scope': scope,
      if (scopeId != null) 'scope_id': scopeId,
      if (clave != null) 'clave': clave,
      if (habilitado != null) 'habilitado': habilitado,
      if (nota != null) 'nota': nota,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FeatureFlagsCompanion copyWith({
    Value<String>? id,
    Value<String>? scope,
    Value<String?>? scopeId,
    Value<String>? clave,
    Value<bool>? habilitado,
    Value<String?>? nota,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return FeatureFlagsCompanion(
      id: id ?? this.id,
      scope: scope ?? this.scope,
      scopeId: scopeId ?? this.scopeId,
      clave: clave ?? this.clave,
      habilitado: habilitado ?? this.habilitado,
      nota: nota ?? this.nota,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (scope.present) {
      map['scope'] = Variable<String>(scope.value);
    }
    if (scopeId.present) {
      map['scope_id'] = Variable<String>(scopeId.value);
    }
    if (clave.present) {
      map['clave'] = Variable<String>(clave.value);
    }
    if (habilitado.present) {
      map['habilitado'] = Variable<bool>(habilitado.value);
    }
    if (nota.present) {
      map['nota'] = Variable<String>(nota.value);
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
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FeatureFlagsCompanion(')
          ..write('id: $id, ')
          ..write('scope: $scope, ')
          ..write('scopeId: $scopeId, ')
          ..write('clave: $clave, ')
          ..write('habilitado: $habilitado, ')
          ..write('nota: $nota, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
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
  static const VerificationMeta _ultimaBajadaIdMeta = const VerificationMeta(
    'ultimaBajadaId',
  );
  @override
  late final GeneratedColumn<String> ultimaBajadaId = GeneratedColumn<String>(
    'ultima_bajada_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [tabla, ultimaBajada, ultimaBajadaId];
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
    if (data.containsKey('ultima_bajada_id')) {
      context.handle(
        _ultimaBajadaIdMeta,
        ultimaBajadaId.isAcceptableOrUnknown(
          data['ultima_bajada_id']!,
          _ultimaBajadaIdMeta,
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
      ultimaBajadaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ultima_bajada_id'],
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
  final String? ultimaBajadaId;
  const SyncCursorRow({
    required this.tabla,
    this.ultimaBajada,
    this.ultimaBajadaId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['tabla'] = Variable<String>(tabla);
    if (!nullToAbsent || ultimaBajada != null) {
      map['ultima_bajada'] = Variable<DateTime>(ultimaBajada);
    }
    if (!nullToAbsent || ultimaBajadaId != null) {
      map['ultima_bajada_id'] = Variable<String>(ultimaBajadaId);
    }
    return map;
  }

  SyncCursoresCompanion toCompanion(bool nullToAbsent) {
    return SyncCursoresCompanion(
      tabla: Value(tabla),
      ultimaBajada: ultimaBajada == null && nullToAbsent
          ? const Value.absent()
          : Value(ultimaBajada),
      ultimaBajadaId: ultimaBajadaId == null && nullToAbsent
          ? const Value.absent()
          : Value(ultimaBajadaId),
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
      ultimaBajadaId: serializer.fromJson<String?>(json['ultimaBajadaId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'tabla': serializer.toJson<String>(tabla),
      'ultimaBajada': serializer.toJson<DateTime?>(ultimaBajada),
      'ultimaBajadaId': serializer.toJson<String?>(ultimaBajadaId),
    };
  }

  SyncCursorRow copyWith({
    String? tabla,
    Value<DateTime?> ultimaBajada = const Value.absent(),
    Value<String?> ultimaBajadaId = const Value.absent(),
  }) => SyncCursorRow(
    tabla: tabla ?? this.tabla,
    ultimaBajada: ultimaBajada.present ? ultimaBajada.value : this.ultimaBajada,
    ultimaBajadaId: ultimaBajadaId.present
        ? ultimaBajadaId.value
        : this.ultimaBajadaId,
  );
  SyncCursorRow copyWithCompanion(SyncCursoresCompanion data) {
    return SyncCursorRow(
      tabla: data.tabla.present ? data.tabla.value : this.tabla,
      ultimaBajada: data.ultimaBajada.present
          ? data.ultimaBajada.value
          : this.ultimaBajada,
      ultimaBajadaId: data.ultimaBajadaId.present
          ? data.ultimaBajadaId.value
          : this.ultimaBajadaId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncCursorRow(')
          ..write('tabla: $tabla, ')
          ..write('ultimaBajada: $ultimaBajada, ')
          ..write('ultimaBajadaId: $ultimaBajadaId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(tabla, ultimaBajada, ultimaBajadaId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncCursorRow &&
          other.tabla == this.tabla &&
          other.ultimaBajada == this.ultimaBajada &&
          other.ultimaBajadaId == this.ultimaBajadaId);
}

class SyncCursoresCompanion extends UpdateCompanion<SyncCursorRow> {
  final Value<String> tabla;
  final Value<DateTime?> ultimaBajada;
  final Value<String?> ultimaBajadaId;
  final Value<int> rowid;
  const SyncCursoresCompanion({
    this.tabla = const Value.absent(),
    this.ultimaBajada = const Value.absent(),
    this.ultimaBajadaId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncCursoresCompanion.insert({
    required String tabla,
    this.ultimaBajada = const Value.absent(),
    this.ultimaBajadaId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : tabla = Value(tabla);
  static Insertable<SyncCursorRow> custom({
    Expression<String>? tabla,
    Expression<DateTime>? ultimaBajada,
    Expression<String>? ultimaBajadaId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (tabla != null) 'tabla': tabla,
      if (ultimaBajada != null) 'ultima_bajada': ultimaBajada,
      if (ultimaBajadaId != null) 'ultima_bajada_id': ultimaBajadaId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncCursoresCompanion copyWith({
    Value<String>? tabla,
    Value<DateTime?>? ultimaBajada,
    Value<String?>? ultimaBajadaId,
    Value<int>? rowid,
  }) {
    return SyncCursoresCompanion(
      tabla: tabla ?? this.tabla,
      ultimaBajada: ultimaBajada ?? this.ultimaBajada,
      ultimaBajadaId: ultimaBajadaId ?? this.ultimaBajadaId,
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
    if (ultimaBajadaId.present) {
      map['ultima_bajada_id'] = Variable<String>(ultimaBajadaId.value);
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
          ..write('ultimaBajadaId: $ultimaBajadaId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncEstadosTable extends SyncEstados
    with TableInfo<$SyncEstadosTable, SyncEstadoRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncEstadosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _tablaMeta = const VerificationMeta('tabla');
  @override
  late final GeneratedColumn<String> tabla = GeneratedColumn<String>(
    'tabla',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ultimaSincronizacionOkMeta =
      const VerificationMeta('ultimaSincronizacionOk');
  @override
  late final GeneratedColumn<DateTime> ultimaSincronizacionOk =
      GeneratedColumn<DateTime>(
        'ultima_sincronizacion_ok',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _ultimoErrorMeta = const VerificationMeta(
    'ultimoError',
  );
  @override
  late final GeneratedColumn<String> ultimoError = GeneratedColumn<String>(
    'ultimo_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ultimoErrorEnMeta = const VerificationMeta(
    'ultimoErrorEn',
  );
  @override
  late final GeneratedColumn<DateTime> ultimoErrorEn =
      GeneratedColumn<DateTime>(
        'ultimo_error_en',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    tabla,
    ultimaSincronizacionOk,
    ultimoError,
    ultimoErrorEn,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_estados';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncEstadoRow> instance, {
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
    if (data.containsKey('ultima_sincronizacion_ok')) {
      context.handle(
        _ultimaSincronizacionOkMeta,
        ultimaSincronizacionOk.isAcceptableOrUnknown(
          data['ultima_sincronizacion_ok']!,
          _ultimaSincronizacionOkMeta,
        ),
      );
    }
    if (data.containsKey('ultimo_error')) {
      context.handle(
        _ultimoErrorMeta,
        ultimoError.isAcceptableOrUnknown(
          data['ultimo_error']!,
          _ultimoErrorMeta,
        ),
      );
    }
    if (data.containsKey('ultimo_error_en')) {
      context.handle(
        _ultimoErrorEnMeta,
        ultimoErrorEn.isAcceptableOrUnknown(
          data['ultimo_error_en']!,
          _ultimoErrorEnMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {tabla};
  @override
  SyncEstadoRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncEstadoRow(
      tabla: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tabla'],
      )!,
      ultimaSincronizacionOk: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ultima_sincronizacion_ok'],
      ),
      ultimoError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ultimo_error'],
      ),
      ultimoErrorEn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ultimo_error_en'],
      ),
    );
  }

  @override
  $SyncEstadosTable createAlias(String alias) {
    return $SyncEstadosTable(attachedDatabase, alias);
  }
}

class SyncEstadoRow extends DataClass implements Insertable<SyncEstadoRow> {
  final String tabla;
  final DateTime? ultimaSincronizacionOk;
  final String? ultimoError;
  final DateTime? ultimoErrorEn;
  const SyncEstadoRow({
    required this.tabla,
    this.ultimaSincronizacionOk,
    this.ultimoError,
    this.ultimoErrorEn,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['tabla'] = Variable<String>(tabla);
    if (!nullToAbsent || ultimaSincronizacionOk != null) {
      map['ultima_sincronizacion_ok'] = Variable<DateTime>(
        ultimaSincronizacionOk,
      );
    }
    if (!nullToAbsent || ultimoError != null) {
      map['ultimo_error'] = Variable<String>(ultimoError);
    }
    if (!nullToAbsent || ultimoErrorEn != null) {
      map['ultimo_error_en'] = Variable<DateTime>(ultimoErrorEn);
    }
    return map;
  }

  SyncEstadosCompanion toCompanion(bool nullToAbsent) {
    return SyncEstadosCompanion(
      tabla: Value(tabla),
      ultimaSincronizacionOk: ultimaSincronizacionOk == null && nullToAbsent
          ? const Value.absent()
          : Value(ultimaSincronizacionOk),
      ultimoError: ultimoError == null && nullToAbsent
          ? const Value.absent()
          : Value(ultimoError),
      ultimoErrorEn: ultimoErrorEn == null && nullToAbsent
          ? const Value.absent()
          : Value(ultimoErrorEn),
    );
  }

  factory SyncEstadoRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncEstadoRow(
      tabla: serializer.fromJson<String>(json['tabla']),
      ultimaSincronizacionOk: serializer.fromJson<DateTime?>(
        json['ultimaSincronizacionOk'],
      ),
      ultimoError: serializer.fromJson<String?>(json['ultimoError']),
      ultimoErrorEn: serializer.fromJson<DateTime?>(json['ultimoErrorEn']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'tabla': serializer.toJson<String>(tabla),
      'ultimaSincronizacionOk': serializer.toJson<DateTime?>(
        ultimaSincronizacionOk,
      ),
      'ultimoError': serializer.toJson<String?>(ultimoError),
      'ultimoErrorEn': serializer.toJson<DateTime?>(ultimoErrorEn),
    };
  }

  SyncEstadoRow copyWith({
    String? tabla,
    Value<DateTime?> ultimaSincronizacionOk = const Value.absent(),
    Value<String?> ultimoError = const Value.absent(),
    Value<DateTime?> ultimoErrorEn = const Value.absent(),
  }) => SyncEstadoRow(
    tabla: tabla ?? this.tabla,
    ultimaSincronizacionOk: ultimaSincronizacionOk.present
        ? ultimaSincronizacionOk.value
        : this.ultimaSincronizacionOk,
    ultimoError: ultimoError.present ? ultimoError.value : this.ultimoError,
    ultimoErrorEn: ultimoErrorEn.present
        ? ultimoErrorEn.value
        : this.ultimoErrorEn,
  );
  SyncEstadoRow copyWithCompanion(SyncEstadosCompanion data) {
    return SyncEstadoRow(
      tabla: data.tabla.present ? data.tabla.value : this.tabla,
      ultimaSincronizacionOk: data.ultimaSincronizacionOk.present
          ? data.ultimaSincronizacionOk.value
          : this.ultimaSincronizacionOk,
      ultimoError: data.ultimoError.present
          ? data.ultimoError.value
          : this.ultimoError,
      ultimoErrorEn: data.ultimoErrorEn.present
          ? data.ultimoErrorEn.value
          : this.ultimoErrorEn,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncEstadoRow(')
          ..write('tabla: $tabla, ')
          ..write('ultimaSincronizacionOk: $ultimaSincronizacionOk, ')
          ..write('ultimoError: $ultimoError, ')
          ..write('ultimoErrorEn: $ultimoErrorEn')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(tabla, ultimaSincronizacionOk, ultimoError, ultimoErrorEn);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncEstadoRow &&
          other.tabla == this.tabla &&
          other.ultimaSincronizacionOk == this.ultimaSincronizacionOk &&
          other.ultimoError == this.ultimoError &&
          other.ultimoErrorEn == this.ultimoErrorEn);
}

class SyncEstadosCompanion extends UpdateCompanion<SyncEstadoRow> {
  final Value<String> tabla;
  final Value<DateTime?> ultimaSincronizacionOk;
  final Value<String?> ultimoError;
  final Value<DateTime?> ultimoErrorEn;
  final Value<int> rowid;
  const SyncEstadosCompanion({
    this.tabla = const Value.absent(),
    this.ultimaSincronizacionOk = const Value.absent(),
    this.ultimoError = const Value.absent(),
    this.ultimoErrorEn = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncEstadosCompanion.insert({
    required String tabla,
    this.ultimaSincronizacionOk = const Value.absent(),
    this.ultimoError = const Value.absent(),
    this.ultimoErrorEn = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : tabla = Value(tabla);
  static Insertable<SyncEstadoRow> custom({
    Expression<String>? tabla,
    Expression<DateTime>? ultimaSincronizacionOk,
    Expression<String>? ultimoError,
    Expression<DateTime>? ultimoErrorEn,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (tabla != null) 'tabla': tabla,
      if (ultimaSincronizacionOk != null)
        'ultima_sincronizacion_ok': ultimaSincronizacionOk,
      if (ultimoError != null) 'ultimo_error': ultimoError,
      if (ultimoErrorEn != null) 'ultimo_error_en': ultimoErrorEn,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncEstadosCompanion copyWith({
    Value<String>? tabla,
    Value<DateTime?>? ultimaSincronizacionOk,
    Value<String?>? ultimoError,
    Value<DateTime?>? ultimoErrorEn,
    Value<int>? rowid,
  }) {
    return SyncEstadosCompanion(
      tabla: tabla ?? this.tabla,
      ultimaSincronizacionOk:
          ultimaSincronizacionOk ?? this.ultimaSincronizacionOk,
      ultimoError: ultimoError ?? this.ultimoError,
      ultimoErrorEn: ultimoErrorEn ?? this.ultimoErrorEn,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (tabla.present) {
      map['tabla'] = Variable<String>(tabla.value);
    }
    if (ultimaSincronizacionOk.present) {
      map['ultima_sincronizacion_ok'] = Variable<DateTime>(
        ultimaSincronizacionOk.value,
      );
    }
    if (ultimoError.present) {
      map['ultimo_error'] = Variable<String>(ultimoError.value);
    }
    if (ultimoErrorEn.present) {
      map['ultimo_error_en'] = Variable<DateTime>(ultimoErrorEn.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncEstadosCompanion(')
          ..write('tabla: $tabla, ')
          ..write('ultimaSincronizacionOk: $ultimaSincronizacionOk, ')
          ..write('ultimoError: $ultimoError, ')
          ..write('ultimoErrorEn: $ultimoErrorEn, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SesionesLocalesTable extends SesionesLocales
    with TableInfo<$SesionesLocalesTable, SesionLocalRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SesionesLocalesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  static const VerificationMeta _ultimoLoginOnlineMeta = const VerificationMeta(
    'ultimoLoginOnline',
  );
  @override
  late final GeneratedColumn<DateTime> ultimoLoginOnline =
      GeneratedColumn<DateTime>(
        'ultimo_login_online',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _offlineActivaMeta = const VerificationMeta(
    'offlineActiva',
  );
  @override
  late final GeneratedColumn<bool> offlineActiva = GeneratedColumn<bool>(
    'offline_activa',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("offline_activa" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    usuarioId,
    email,
    nombre,
    ultimoLoginOnline,
    offlineActiva,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sesiones_locales';
  @override
  VerificationContext validateIntegrity(
    Insertable<SesionLocalRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('usuario_id')) {
      context.handle(
        _usuarioIdMeta,
        usuarioId.isAcceptableOrUnknown(data['usuario_id']!, _usuarioIdMeta),
      );
    } else if (isInserting) {
      context.missing(_usuarioIdMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    }
    if (data.containsKey('nombre')) {
      context.handle(
        _nombreMeta,
        nombre.isAcceptableOrUnknown(data['nombre']!, _nombreMeta),
      );
    }
    if (data.containsKey('ultimo_login_online')) {
      context.handle(
        _ultimoLoginOnlineMeta,
        ultimoLoginOnline.isAcceptableOrUnknown(
          data['ultimo_login_online']!,
          _ultimoLoginOnlineMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_ultimoLoginOnlineMeta);
    }
    if (data.containsKey('offline_activa')) {
      context.handle(
        _offlineActivaMeta,
        offlineActiva.isAcceptableOrUnknown(
          data['offline_activa']!,
          _offlineActivaMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SesionLocalRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SesionLocalRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      usuarioId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}usuario_id'],
      )!,
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      ),
      nombre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nombre'],
      ),
      ultimoLoginOnline: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ultimo_login_online'],
      )!,
      offlineActiva: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}offline_activa'],
      )!,
    );
  }

  @override
  $SesionesLocalesTable createAlias(String alias) {
    return $SesionesLocalesTable(attachedDatabase, alias);
  }
}

class SesionLocalRow extends DataClass implements Insertable<SesionLocalRow> {
  final String id;
  final String usuarioId;
  final String? email;
  final String? nombre;
  final DateTime ultimoLoginOnline;
  final bool offlineActiva;
  const SesionLocalRow({
    required this.id,
    required this.usuarioId,
    this.email,
    this.nombre,
    required this.ultimoLoginOnline,
    required this.offlineActiva,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['usuario_id'] = Variable<String>(usuarioId);
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || nombre != null) {
      map['nombre'] = Variable<String>(nombre);
    }
    map['ultimo_login_online'] = Variable<DateTime>(ultimoLoginOnline);
    map['offline_activa'] = Variable<bool>(offlineActiva);
    return map;
  }

  SesionesLocalesCompanion toCompanion(bool nullToAbsent) {
    return SesionesLocalesCompanion(
      id: Value(id),
      usuarioId: Value(usuarioId),
      email: email == null && nullToAbsent
          ? const Value.absent()
          : Value(email),
      nombre: nombre == null && nullToAbsent
          ? const Value.absent()
          : Value(nombre),
      ultimoLoginOnline: Value(ultimoLoginOnline),
      offlineActiva: Value(offlineActiva),
    );
  }

  factory SesionLocalRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SesionLocalRow(
      id: serializer.fromJson<String>(json['id']),
      usuarioId: serializer.fromJson<String>(json['usuarioId']),
      email: serializer.fromJson<String?>(json['email']),
      nombre: serializer.fromJson<String?>(json['nombre']),
      ultimoLoginOnline: serializer.fromJson<DateTime>(
        json['ultimoLoginOnline'],
      ),
      offlineActiva: serializer.fromJson<bool>(json['offlineActiva']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'usuarioId': serializer.toJson<String>(usuarioId),
      'email': serializer.toJson<String?>(email),
      'nombre': serializer.toJson<String?>(nombre),
      'ultimoLoginOnline': serializer.toJson<DateTime>(ultimoLoginOnline),
      'offlineActiva': serializer.toJson<bool>(offlineActiva),
    };
  }

  SesionLocalRow copyWith({
    String? id,
    String? usuarioId,
    Value<String?> email = const Value.absent(),
    Value<String?> nombre = const Value.absent(),
    DateTime? ultimoLoginOnline,
    bool? offlineActiva,
  }) => SesionLocalRow(
    id: id ?? this.id,
    usuarioId: usuarioId ?? this.usuarioId,
    email: email.present ? email.value : this.email,
    nombre: nombre.present ? nombre.value : this.nombre,
    ultimoLoginOnline: ultimoLoginOnline ?? this.ultimoLoginOnline,
    offlineActiva: offlineActiva ?? this.offlineActiva,
  );
  SesionLocalRow copyWithCompanion(SesionesLocalesCompanion data) {
    return SesionLocalRow(
      id: data.id.present ? data.id.value : this.id,
      usuarioId: data.usuarioId.present ? data.usuarioId.value : this.usuarioId,
      email: data.email.present ? data.email.value : this.email,
      nombre: data.nombre.present ? data.nombre.value : this.nombre,
      ultimoLoginOnline: data.ultimoLoginOnline.present
          ? data.ultimoLoginOnline.value
          : this.ultimoLoginOnline,
      offlineActiva: data.offlineActiva.present
          ? data.offlineActiva.value
          : this.offlineActiva,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SesionLocalRow(')
          ..write('id: $id, ')
          ..write('usuarioId: $usuarioId, ')
          ..write('email: $email, ')
          ..write('nombre: $nombre, ')
          ..write('ultimoLoginOnline: $ultimoLoginOnline, ')
          ..write('offlineActiva: $offlineActiva')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    usuarioId,
    email,
    nombre,
    ultimoLoginOnline,
    offlineActiva,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SesionLocalRow &&
          other.id == this.id &&
          other.usuarioId == this.usuarioId &&
          other.email == this.email &&
          other.nombre == this.nombre &&
          other.ultimoLoginOnline == this.ultimoLoginOnline &&
          other.offlineActiva == this.offlineActiva);
}

class SesionesLocalesCompanion extends UpdateCompanion<SesionLocalRow> {
  final Value<String> id;
  final Value<String> usuarioId;
  final Value<String?> email;
  final Value<String?> nombre;
  final Value<DateTime> ultimoLoginOnline;
  final Value<bool> offlineActiva;
  final Value<int> rowid;
  const SesionesLocalesCompanion({
    this.id = const Value.absent(),
    this.usuarioId = const Value.absent(),
    this.email = const Value.absent(),
    this.nombre = const Value.absent(),
    this.ultimoLoginOnline = const Value.absent(),
    this.offlineActiva = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SesionesLocalesCompanion.insert({
    required String id,
    required String usuarioId,
    this.email = const Value.absent(),
    this.nombre = const Value.absent(),
    required DateTime ultimoLoginOnline,
    this.offlineActiva = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       usuarioId = Value(usuarioId),
       ultimoLoginOnline = Value(ultimoLoginOnline);
  static Insertable<SesionLocalRow> custom({
    Expression<String>? id,
    Expression<String>? usuarioId,
    Expression<String>? email,
    Expression<String>? nombre,
    Expression<DateTime>? ultimoLoginOnline,
    Expression<bool>? offlineActiva,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (usuarioId != null) 'usuario_id': usuarioId,
      if (email != null) 'email': email,
      if (nombre != null) 'nombre': nombre,
      if (ultimoLoginOnline != null) 'ultimo_login_online': ultimoLoginOnline,
      if (offlineActiva != null) 'offline_activa': offlineActiva,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SesionesLocalesCompanion copyWith({
    Value<String>? id,
    Value<String>? usuarioId,
    Value<String?>? email,
    Value<String?>? nombre,
    Value<DateTime>? ultimoLoginOnline,
    Value<bool>? offlineActiva,
    Value<int>? rowid,
  }) {
    return SesionesLocalesCompanion(
      id: id ?? this.id,
      usuarioId: usuarioId ?? this.usuarioId,
      email: email ?? this.email,
      nombre: nombre ?? this.nombre,
      ultimoLoginOnline: ultimoLoginOnline ?? this.ultimoLoginOnline,
      offlineActiva: offlineActiva ?? this.offlineActiva,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (usuarioId.present) {
      map['usuario_id'] = Variable<String>(usuarioId.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (nombre.present) {
      map['nombre'] = Variable<String>(nombre.value);
    }
    if (ultimoLoginOnline.present) {
      map['ultimo_login_online'] = Variable<DateTime>(ultimoLoginOnline.value);
    }
    if (offlineActiva.present) {
      map['offline_activa'] = Variable<bool>(offlineActiva.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SesionesLocalesCompanion(')
          ..write('id: $id, ')
          ..write('usuarioId: $usuarioId, ')
          ..write('email: $email, ')
          ..write('nombre: $nombre, ')
          ..write('ultimoLoginOnline: $ultimoLoginOnline, ')
          ..write('offlineActiva: $offlineActiva, ')
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
  late final $DietasTable dietas = $DietasTable(this);
  late final $DietaIngredientesTable dietaIngredientes =
      $DietaIngredientesTable(this);
  late final $LoteDietasTable loteDietas = $LoteDietasTable(this);
  late final $MovimientosLoteTable movimientosLote = $MovimientosLoteTable(
    this,
  );
  late final $MedicamentosTable medicamentos = $MedicamentosTable(this);
  late final $EventosSanitariosTable eventosSanitarios =
      $EventosSanitariosTable(this);
  late final $LotesVentaTable lotesVenta = $LotesVentaTable(this);
  late final $VentasTable ventas = $VentasTable(this);
  late final $CostosOtrosTable costosOtros = $CostosOtrosTable(this);
  late final $FeatureFlagsTable featureFlags = $FeatureFlagsTable(this);
  late final $SyncCursoresTable syncCursores = $SyncCursoresTable(this);
  late final $SyncEstadosTable syncEstados = $SyncEstadosTable(this);
  late final $SesionesLocalesTable sesionesLocales = $SesionesLocalesTable(
    this,
  );
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
    dietas,
    dietaIngredientes,
    loteDietas,
    movimientosLote,
    medicamentos,
    eventosSanitarios,
    lotesVenta,
    ventas,
    costosOtros,
    featureFlags,
    syncCursores,
    syncEstados,
    sesionesLocales,
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
      Value<DateTime?> pruebaTermina,
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
      Value<DateTime?> pruebaTermina,
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

  ColumnFilters<DateTime> get pruebaTermina => $composableBuilder(
    column: $table.pruebaTermina,
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

  ColumnOrderings<DateTime> get pruebaTermina => $composableBuilder(
    column: $table.pruebaTermina,
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

  GeneratedColumn<DateTime> get pruebaTermina => $composableBuilder(
    column: $table.pruebaTermina,
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
                Value<DateTime?> pruebaTermina = const Value.absent(),
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
                pruebaTermina: pruebaTermina,
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
                Value<DateTime?> pruebaTermina = const Value.absent(),
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
                pruebaTermina: pruebaTermina,
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
      Value<String> estado,
      Value<double?> precioCompra,
      Value<DateTime?> fechaCompra,
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
      Value<String> estado,
      Value<double?> precioCompra,
      Value<DateTime?> fechaCompra,
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

  ColumnFilters<String> get estado => $composableBuilder(
    column: $table.estado,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get precioCompra => $composableBuilder(
    column: $table.precioCompra,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fechaCompra => $composableBuilder(
    column: $table.fechaCompra,
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

  ColumnOrderings<String> get estado => $composableBuilder(
    column: $table.estado,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get precioCompra => $composableBuilder(
    column: $table.precioCompra,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fechaCompra => $composableBuilder(
    column: $table.fechaCompra,
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

  GeneratedColumn<String> get estado =>
      $composableBuilder(column: $table.estado, builder: (column) => column);

  GeneratedColumn<double> get precioCompra => $composableBuilder(
    column: $table.precioCompra,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get fechaCompra => $composableBuilder(
    column: $table.fechaCompra,
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
                Value<String> estado = const Value.absent(),
                Value<double?> precioCompra = const Value.absent(),
                Value<DateTime?> fechaCompra = const Value.absent(),
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
                estado: estado,
                precioCompra: precioCompra,
                fechaCompra: fechaCompra,
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
                Value<String> estado = const Value.absent(),
                Value<double?> precioCompra = const Value.absent(),
                Value<DateTime?> fechaCompra = const Value.absent(),
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
                estado: estado,
                precioCompra: precioCompra,
                fechaCompra: fechaCompra,
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
typedef $$DietasTableCreateCompanionBuilder =
    DietasCompanion Function({
      required String id,
      required String fincaId,
      required String nombre,
      Value<String?> descripcion,
      required double costoAnimalDia,
      Value<String> moneda,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<bool> pendiente,
      Value<int> rowid,
    });
typedef $$DietasTableUpdateCompanionBuilder =
    DietasCompanion Function({
      Value<String> id,
      Value<String> fincaId,
      Value<String> nombre,
      Value<String?> descripcion,
      Value<double> costoAnimalDia,
      Value<String> moneda,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<bool> pendiente,
      Value<int> rowid,
    });

class $$DietasTableFilterComposer
    extends Composer<_$AppDatabase, $DietasTable> {
  $$DietasTableFilterComposer({
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

  ColumnFilters<String> get descripcion => $composableBuilder(
    column: $table.descripcion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get costoAnimalDia => $composableBuilder(
    column: $table.costoAnimalDia,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get moneda => $composableBuilder(
    column: $table.moneda,
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

class $$DietasTableOrderingComposer
    extends Composer<_$AppDatabase, $DietasTable> {
  $$DietasTableOrderingComposer({
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

  ColumnOrderings<String> get descripcion => $composableBuilder(
    column: $table.descripcion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get costoAnimalDia => $composableBuilder(
    column: $table.costoAnimalDia,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get moneda => $composableBuilder(
    column: $table.moneda,
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

class $$DietasTableAnnotationComposer
    extends Composer<_$AppDatabase, $DietasTable> {
  $$DietasTableAnnotationComposer({
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

  GeneratedColumn<String> get descripcion => $composableBuilder(
    column: $table.descripcion,
    builder: (column) => column,
  );

  GeneratedColumn<double> get costoAnimalDia => $composableBuilder(
    column: $table.costoAnimalDia,
    builder: (column) => column,
  );

  GeneratedColumn<String> get moneda =>
      $composableBuilder(column: $table.moneda, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<bool> get pendiente =>
      $composableBuilder(column: $table.pendiente, builder: (column) => column);
}

class $$DietasTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DietasTable,
          DietaRow,
          $$DietasTableFilterComposer,
          $$DietasTableOrderingComposer,
          $$DietasTableAnnotationComposer,
          $$DietasTableCreateCompanionBuilder,
          $$DietasTableUpdateCompanionBuilder,
          (DietaRow, BaseReferences<_$AppDatabase, $DietasTable, DietaRow>),
          DietaRow,
          PrefetchHooks Function()
        > {
  $$DietasTableTableManager(_$AppDatabase db, $DietasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DietasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DietasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DietasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> fincaId = const Value.absent(),
                Value<String> nombre = const Value.absent(),
                Value<String?> descripcion = const Value.absent(),
                Value<double> costoAnimalDia = const Value.absent(),
                Value<String> moneda = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<bool> pendiente = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DietasCompanion(
                id: id,
                fincaId: fincaId,
                nombre: nombre,
                descripcion: descripcion,
                costoAnimalDia: costoAnimalDia,
                moneda: moneda,
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
                Value<String?> descripcion = const Value.absent(),
                required double costoAnimalDia,
                Value<String> moneda = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<bool> pendiente = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DietasCompanion.insert(
                id: id,
                fincaId: fincaId,
                nombre: nombre,
                descripcion: descripcion,
                costoAnimalDia: costoAnimalDia,
                moneda: moneda,
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

typedef $$DietasTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DietasTable,
      DietaRow,
      $$DietasTableFilterComposer,
      $$DietasTableOrderingComposer,
      $$DietasTableAnnotationComposer,
      $$DietasTableCreateCompanionBuilder,
      $$DietasTableUpdateCompanionBuilder,
      (DietaRow, BaseReferences<_$AppDatabase, $DietasTable, DietaRow>),
      DietaRow,
      PrefetchHooks Function()
    >;
typedef $$DietaIngredientesTableCreateCompanionBuilder =
    DietaIngredientesCompanion Function({
      required String id,
      required String dietaId,
      required String nombre,
      required double costoAnimalDia,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<bool> pendiente,
      Value<int> rowid,
    });
typedef $$DietaIngredientesTableUpdateCompanionBuilder =
    DietaIngredientesCompanion Function({
      Value<String> id,
      Value<String> dietaId,
      Value<String> nombre,
      Value<double> costoAnimalDia,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<bool> pendiente,
      Value<int> rowid,
    });

class $$DietaIngredientesTableFilterComposer
    extends Composer<_$AppDatabase, $DietaIngredientesTable> {
  $$DietaIngredientesTableFilterComposer({
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

  ColumnFilters<String> get dietaId => $composableBuilder(
    column: $table.dietaId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get costoAnimalDia => $composableBuilder(
    column: $table.costoAnimalDia,
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

class $$DietaIngredientesTableOrderingComposer
    extends Composer<_$AppDatabase, $DietaIngredientesTable> {
  $$DietaIngredientesTableOrderingComposer({
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

  ColumnOrderings<String> get dietaId => $composableBuilder(
    column: $table.dietaId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get costoAnimalDia => $composableBuilder(
    column: $table.costoAnimalDia,
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

class $$DietaIngredientesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DietaIngredientesTable> {
  $$DietaIngredientesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get dietaId =>
      $composableBuilder(column: $table.dietaId, builder: (column) => column);

  GeneratedColumn<String> get nombre =>
      $composableBuilder(column: $table.nombre, builder: (column) => column);

  GeneratedColumn<double> get costoAnimalDia => $composableBuilder(
    column: $table.costoAnimalDia,
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

class $$DietaIngredientesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DietaIngredientesTable,
          DietaIngredienteRow,
          $$DietaIngredientesTableFilterComposer,
          $$DietaIngredientesTableOrderingComposer,
          $$DietaIngredientesTableAnnotationComposer,
          $$DietaIngredientesTableCreateCompanionBuilder,
          $$DietaIngredientesTableUpdateCompanionBuilder,
          (
            DietaIngredienteRow,
            BaseReferences<
              _$AppDatabase,
              $DietaIngredientesTable,
              DietaIngredienteRow
            >,
          ),
          DietaIngredienteRow,
          PrefetchHooks Function()
        > {
  $$DietaIngredientesTableTableManager(
    _$AppDatabase db,
    $DietaIngredientesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DietaIngredientesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DietaIngredientesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DietaIngredientesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> dietaId = const Value.absent(),
                Value<String> nombre = const Value.absent(),
                Value<double> costoAnimalDia = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<bool> pendiente = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DietaIngredientesCompanion(
                id: id,
                dietaId: dietaId,
                nombre: nombre,
                costoAnimalDia: costoAnimalDia,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                pendiente: pendiente,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String dietaId,
                required String nombre,
                required double costoAnimalDia,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<bool> pendiente = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DietaIngredientesCompanion.insert(
                id: id,
                dietaId: dietaId,
                nombre: nombre,
                costoAnimalDia: costoAnimalDia,
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

typedef $$DietaIngredientesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DietaIngredientesTable,
      DietaIngredienteRow,
      $$DietaIngredientesTableFilterComposer,
      $$DietaIngredientesTableOrderingComposer,
      $$DietaIngredientesTableAnnotationComposer,
      $$DietaIngredientesTableCreateCompanionBuilder,
      $$DietaIngredientesTableUpdateCompanionBuilder,
      (
        DietaIngredienteRow,
        BaseReferences<
          _$AppDatabase,
          $DietaIngredientesTable,
          DietaIngredienteRow
        >,
      ),
      DietaIngredienteRow,
      PrefetchHooks Function()
    >;
typedef $$LoteDietasTableCreateCompanionBuilder =
    LoteDietasCompanion Function({
      required String id,
      required String loteId,
      required String dietaId,
      required DateTime desde,
      Value<DateTime?> hasta,
      required double costoAnimalDiaSnapshot,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<bool> pendiente,
      Value<int> rowid,
    });
typedef $$LoteDietasTableUpdateCompanionBuilder =
    LoteDietasCompanion Function({
      Value<String> id,
      Value<String> loteId,
      Value<String> dietaId,
      Value<DateTime> desde,
      Value<DateTime?> hasta,
      Value<double> costoAnimalDiaSnapshot,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<bool> pendiente,
      Value<int> rowid,
    });

class $$LoteDietasTableFilterComposer
    extends Composer<_$AppDatabase, $LoteDietasTable> {
  $$LoteDietasTableFilterComposer({
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

  ColumnFilters<String> get loteId => $composableBuilder(
    column: $table.loteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dietaId => $composableBuilder(
    column: $table.dietaId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get desde => $composableBuilder(
    column: $table.desde,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get hasta => $composableBuilder(
    column: $table.hasta,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get costoAnimalDiaSnapshot => $composableBuilder(
    column: $table.costoAnimalDiaSnapshot,
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

class $$LoteDietasTableOrderingComposer
    extends Composer<_$AppDatabase, $LoteDietasTable> {
  $$LoteDietasTableOrderingComposer({
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

  ColumnOrderings<String> get loteId => $composableBuilder(
    column: $table.loteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dietaId => $composableBuilder(
    column: $table.dietaId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get desde => $composableBuilder(
    column: $table.desde,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get hasta => $composableBuilder(
    column: $table.hasta,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get costoAnimalDiaSnapshot => $composableBuilder(
    column: $table.costoAnimalDiaSnapshot,
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

class $$LoteDietasTableAnnotationComposer
    extends Composer<_$AppDatabase, $LoteDietasTable> {
  $$LoteDietasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get loteId =>
      $composableBuilder(column: $table.loteId, builder: (column) => column);

  GeneratedColumn<String> get dietaId =>
      $composableBuilder(column: $table.dietaId, builder: (column) => column);

  GeneratedColumn<DateTime> get desde =>
      $composableBuilder(column: $table.desde, builder: (column) => column);

  GeneratedColumn<DateTime> get hasta =>
      $composableBuilder(column: $table.hasta, builder: (column) => column);

  GeneratedColumn<double> get costoAnimalDiaSnapshot => $composableBuilder(
    column: $table.costoAnimalDiaSnapshot,
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

class $$LoteDietasTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LoteDietasTable,
          LoteDietaRow,
          $$LoteDietasTableFilterComposer,
          $$LoteDietasTableOrderingComposer,
          $$LoteDietasTableAnnotationComposer,
          $$LoteDietasTableCreateCompanionBuilder,
          $$LoteDietasTableUpdateCompanionBuilder,
          (
            LoteDietaRow,
            BaseReferences<_$AppDatabase, $LoteDietasTable, LoteDietaRow>,
          ),
          LoteDietaRow,
          PrefetchHooks Function()
        > {
  $$LoteDietasTableTableManager(_$AppDatabase db, $LoteDietasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LoteDietasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LoteDietasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LoteDietasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> loteId = const Value.absent(),
                Value<String> dietaId = const Value.absent(),
                Value<DateTime> desde = const Value.absent(),
                Value<DateTime?> hasta = const Value.absent(),
                Value<double> costoAnimalDiaSnapshot = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<bool> pendiente = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LoteDietasCompanion(
                id: id,
                loteId: loteId,
                dietaId: dietaId,
                desde: desde,
                hasta: hasta,
                costoAnimalDiaSnapshot: costoAnimalDiaSnapshot,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                pendiente: pendiente,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String loteId,
                required String dietaId,
                required DateTime desde,
                Value<DateTime?> hasta = const Value.absent(),
                required double costoAnimalDiaSnapshot,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<bool> pendiente = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LoteDietasCompanion.insert(
                id: id,
                loteId: loteId,
                dietaId: dietaId,
                desde: desde,
                hasta: hasta,
                costoAnimalDiaSnapshot: costoAnimalDiaSnapshot,
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

typedef $$LoteDietasTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LoteDietasTable,
      LoteDietaRow,
      $$LoteDietasTableFilterComposer,
      $$LoteDietasTableOrderingComposer,
      $$LoteDietasTableAnnotationComposer,
      $$LoteDietasTableCreateCompanionBuilder,
      $$LoteDietasTableUpdateCompanionBuilder,
      (
        LoteDietaRow,
        BaseReferences<_$AppDatabase, $LoteDietasTable, LoteDietaRow>,
      ),
      LoteDietaRow,
      PrefetchHooks Function()
    >;
typedef $$MovimientosLoteTableCreateCompanionBuilder =
    MovimientosLoteCompanion Function({
      required String id,
      required String animalId,
      Value<String?> loteOrigen,
      required String loteDestino,
      required DateTime fecha,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<bool> pendiente,
      Value<int> rowid,
    });
typedef $$MovimientosLoteTableUpdateCompanionBuilder =
    MovimientosLoteCompanion Function({
      Value<String> id,
      Value<String> animalId,
      Value<String?> loteOrigen,
      Value<String> loteDestino,
      Value<DateTime> fecha,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<bool> pendiente,
      Value<int> rowid,
    });

class $$MovimientosLoteTableFilterComposer
    extends Composer<_$AppDatabase, $MovimientosLoteTable> {
  $$MovimientosLoteTableFilterComposer({
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

  ColumnFilters<String> get loteOrigen => $composableBuilder(
    column: $table.loteOrigen,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get loteDestino => $composableBuilder(
    column: $table.loteDestino,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fecha => $composableBuilder(
    column: $table.fecha,
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

class $$MovimientosLoteTableOrderingComposer
    extends Composer<_$AppDatabase, $MovimientosLoteTable> {
  $$MovimientosLoteTableOrderingComposer({
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

  ColumnOrderings<String> get loteOrigen => $composableBuilder(
    column: $table.loteOrigen,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get loteDestino => $composableBuilder(
    column: $table.loteDestino,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fecha => $composableBuilder(
    column: $table.fecha,
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

class $$MovimientosLoteTableAnnotationComposer
    extends Composer<_$AppDatabase, $MovimientosLoteTable> {
  $$MovimientosLoteTableAnnotationComposer({
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

  GeneratedColumn<String> get loteOrigen => $composableBuilder(
    column: $table.loteOrigen,
    builder: (column) => column,
  );

  GeneratedColumn<String> get loteDestino => $composableBuilder(
    column: $table.loteDestino,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get fecha =>
      $composableBuilder(column: $table.fecha, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<bool> get pendiente =>
      $composableBuilder(column: $table.pendiente, builder: (column) => column);
}

class $$MovimientosLoteTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MovimientosLoteTable,
          MovimientoLoteRow,
          $$MovimientosLoteTableFilterComposer,
          $$MovimientosLoteTableOrderingComposer,
          $$MovimientosLoteTableAnnotationComposer,
          $$MovimientosLoteTableCreateCompanionBuilder,
          $$MovimientosLoteTableUpdateCompanionBuilder,
          (
            MovimientoLoteRow,
            BaseReferences<
              _$AppDatabase,
              $MovimientosLoteTable,
              MovimientoLoteRow
            >,
          ),
          MovimientoLoteRow,
          PrefetchHooks Function()
        > {
  $$MovimientosLoteTableTableManager(
    _$AppDatabase db,
    $MovimientosLoteTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MovimientosLoteTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MovimientosLoteTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MovimientosLoteTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> animalId = const Value.absent(),
                Value<String?> loteOrigen = const Value.absent(),
                Value<String> loteDestino = const Value.absent(),
                Value<DateTime> fecha = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<bool> pendiente = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MovimientosLoteCompanion(
                id: id,
                animalId: animalId,
                loteOrigen: loteOrigen,
                loteDestino: loteDestino,
                fecha: fecha,
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
                Value<String?> loteOrigen = const Value.absent(),
                required String loteDestino,
                required DateTime fecha,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<bool> pendiente = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MovimientosLoteCompanion.insert(
                id: id,
                animalId: animalId,
                loteOrigen: loteOrigen,
                loteDestino: loteDestino,
                fecha: fecha,
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

typedef $$MovimientosLoteTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MovimientosLoteTable,
      MovimientoLoteRow,
      $$MovimientosLoteTableFilterComposer,
      $$MovimientosLoteTableOrderingComposer,
      $$MovimientosLoteTableAnnotationComposer,
      $$MovimientosLoteTableCreateCompanionBuilder,
      $$MovimientosLoteTableUpdateCompanionBuilder,
      (
        MovimientoLoteRow,
        BaseReferences<_$AppDatabase, $MovimientosLoteTable, MovimientoLoteRow>,
      ),
      MovimientoLoteRow,
      PrefetchHooks Function()
    >;
typedef $$MedicamentosTableCreateCompanionBuilder =
    MedicamentosCompanion Function({
      required String id,
      required String fincaId,
      required String nombre,
      required double costoEnvase,
      required String tipoAplicacion,
      Value<double?> mlEnvase,
      Value<double?> aplicacionesPorEnvase,
      Value<double?> dosisCantidad,
      Value<double?> dosisPorCadaKg,
      Value<int> diasRetiro,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<bool> pendiente,
      Value<int> rowid,
    });
typedef $$MedicamentosTableUpdateCompanionBuilder =
    MedicamentosCompanion Function({
      Value<String> id,
      Value<String> fincaId,
      Value<String> nombre,
      Value<double> costoEnvase,
      Value<String> tipoAplicacion,
      Value<double?> mlEnvase,
      Value<double?> aplicacionesPorEnvase,
      Value<double?> dosisCantidad,
      Value<double?> dosisPorCadaKg,
      Value<int> diasRetiro,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<bool> pendiente,
      Value<int> rowid,
    });

class $$MedicamentosTableFilterComposer
    extends Composer<_$AppDatabase, $MedicamentosTable> {
  $$MedicamentosTableFilterComposer({
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

  ColumnFilters<double> get costoEnvase => $composableBuilder(
    column: $table.costoEnvase,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tipoAplicacion => $composableBuilder(
    column: $table.tipoAplicacion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get mlEnvase => $composableBuilder(
    column: $table.mlEnvase,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get aplicacionesPorEnvase => $composableBuilder(
    column: $table.aplicacionesPorEnvase,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get dosisCantidad => $composableBuilder(
    column: $table.dosisCantidad,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get dosisPorCadaKg => $composableBuilder(
    column: $table.dosisPorCadaKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get diasRetiro => $composableBuilder(
    column: $table.diasRetiro,
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

class $$MedicamentosTableOrderingComposer
    extends Composer<_$AppDatabase, $MedicamentosTable> {
  $$MedicamentosTableOrderingComposer({
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

  ColumnOrderings<double> get costoEnvase => $composableBuilder(
    column: $table.costoEnvase,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tipoAplicacion => $composableBuilder(
    column: $table.tipoAplicacion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get mlEnvase => $composableBuilder(
    column: $table.mlEnvase,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get aplicacionesPorEnvase => $composableBuilder(
    column: $table.aplicacionesPorEnvase,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get dosisCantidad => $composableBuilder(
    column: $table.dosisCantidad,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get dosisPorCadaKg => $composableBuilder(
    column: $table.dosisPorCadaKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get diasRetiro => $composableBuilder(
    column: $table.diasRetiro,
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

class $$MedicamentosTableAnnotationComposer
    extends Composer<_$AppDatabase, $MedicamentosTable> {
  $$MedicamentosTableAnnotationComposer({
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

  GeneratedColumn<double> get costoEnvase => $composableBuilder(
    column: $table.costoEnvase,
    builder: (column) => column,
  );

  GeneratedColumn<String> get tipoAplicacion => $composableBuilder(
    column: $table.tipoAplicacion,
    builder: (column) => column,
  );

  GeneratedColumn<double> get mlEnvase =>
      $composableBuilder(column: $table.mlEnvase, builder: (column) => column);

  GeneratedColumn<double> get aplicacionesPorEnvase => $composableBuilder(
    column: $table.aplicacionesPorEnvase,
    builder: (column) => column,
  );

  GeneratedColumn<double> get dosisCantidad => $composableBuilder(
    column: $table.dosisCantidad,
    builder: (column) => column,
  );

  GeneratedColumn<double> get dosisPorCadaKg => $composableBuilder(
    column: $table.dosisPorCadaKg,
    builder: (column) => column,
  );

  GeneratedColumn<int> get diasRetiro => $composableBuilder(
    column: $table.diasRetiro,
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

class $$MedicamentosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MedicamentosTable,
          MedicamentoRow,
          $$MedicamentosTableFilterComposer,
          $$MedicamentosTableOrderingComposer,
          $$MedicamentosTableAnnotationComposer,
          $$MedicamentosTableCreateCompanionBuilder,
          $$MedicamentosTableUpdateCompanionBuilder,
          (
            MedicamentoRow,
            BaseReferences<_$AppDatabase, $MedicamentosTable, MedicamentoRow>,
          ),
          MedicamentoRow,
          PrefetchHooks Function()
        > {
  $$MedicamentosTableTableManager(_$AppDatabase db, $MedicamentosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MedicamentosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MedicamentosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MedicamentosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> fincaId = const Value.absent(),
                Value<String> nombre = const Value.absent(),
                Value<double> costoEnvase = const Value.absent(),
                Value<String> tipoAplicacion = const Value.absent(),
                Value<double?> mlEnvase = const Value.absent(),
                Value<double?> aplicacionesPorEnvase = const Value.absent(),
                Value<double?> dosisCantidad = const Value.absent(),
                Value<double?> dosisPorCadaKg = const Value.absent(),
                Value<int> diasRetiro = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<bool> pendiente = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MedicamentosCompanion(
                id: id,
                fincaId: fincaId,
                nombre: nombre,
                costoEnvase: costoEnvase,
                tipoAplicacion: tipoAplicacion,
                mlEnvase: mlEnvase,
                aplicacionesPorEnvase: aplicacionesPorEnvase,
                dosisCantidad: dosisCantidad,
                dosisPorCadaKg: dosisPorCadaKg,
                diasRetiro: diasRetiro,
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
                required double costoEnvase,
                required String tipoAplicacion,
                Value<double?> mlEnvase = const Value.absent(),
                Value<double?> aplicacionesPorEnvase = const Value.absent(),
                Value<double?> dosisCantidad = const Value.absent(),
                Value<double?> dosisPorCadaKg = const Value.absent(),
                Value<int> diasRetiro = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<bool> pendiente = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MedicamentosCompanion.insert(
                id: id,
                fincaId: fincaId,
                nombre: nombre,
                costoEnvase: costoEnvase,
                tipoAplicacion: tipoAplicacion,
                mlEnvase: mlEnvase,
                aplicacionesPorEnvase: aplicacionesPorEnvase,
                dosisCantidad: dosisCantidad,
                dosisPorCadaKg: dosisPorCadaKg,
                diasRetiro: diasRetiro,
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

typedef $$MedicamentosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MedicamentosTable,
      MedicamentoRow,
      $$MedicamentosTableFilterComposer,
      $$MedicamentosTableOrderingComposer,
      $$MedicamentosTableAnnotationComposer,
      $$MedicamentosTableCreateCompanionBuilder,
      $$MedicamentosTableUpdateCompanionBuilder,
      (
        MedicamentoRow,
        BaseReferences<_$AppDatabase, $MedicamentosTable, MedicamentoRow>,
      ),
      MedicamentoRow,
      PrefetchHooks Function()
    >;
typedef $$EventosSanitariosTableCreateCompanionBuilder =
    EventosSanitariosCompanion Function({
      required String id,
      required String animalId,
      required String tipo,
      required String producto,
      Value<String?> dosis,
      required DateTime fecha,
      Value<String?> responsableId,
      Value<String?> observaciones,
      Value<double?> costo,
      Value<String?> medicamentoId,
      Value<double?> mlAplicados,
      Value<int?> aplicaciones,
      Value<int?> diasRetiro,
      Value<DateTime?> retiroHasta,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<bool> pendiente,
      Value<int> rowid,
    });
typedef $$EventosSanitariosTableUpdateCompanionBuilder =
    EventosSanitariosCompanion Function({
      Value<String> id,
      Value<String> animalId,
      Value<String> tipo,
      Value<String> producto,
      Value<String?> dosis,
      Value<DateTime> fecha,
      Value<String?> responsableId,
      Value<String?> observaciones,
      Value<double?> costo,
      Value<String?> medicamentoId,
      Value<double?> mlAplicados,
      Value<int?> aplicaciones,
      Value<int?> diasRetiro,
      Value<DateTime?> retiroHasta,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<bool> pendiente,
      Value<int> rowid,
    });

class $$EventosSanitariosTableFilterComposer
    extends Composer<_$AppDatabase, $EventosSanitariosTable> {
  $$EventosSanitariosTableFilterComposer({
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

  ColumnFilters<String> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get producto => $composableBuilder(
    column: $table.producto,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dosis => $composableBuilder(
    column: $table.dosis,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fecha => $composableBuilder(
    column: $table.fecha,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get responsableId => $composableBuilder(
    column: $table.responsableId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get observaciones => $composableBuilder(
    column: $table.observaciones,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get costo => $composableBuilder(
    column: $table.costo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get medicamentoId => $composableBuilder(
    column: $table.medicamentoId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get mlAplicados => $composableBuilder(
    column: $table.mlAplicados,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get aplicaciones => $composableBuilder(
    column: $table.aplicaciones,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get diasRetiro => $composableBuilder(
    column: $table.diasRetiro,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get retiroHasta => $composableBuilder(
    column: $table.retiroHasta,
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

class $$EventosSanitariosTableOrderingComposer
    extends Composer<_$AppDatabase, $EventosSanitariosTable> {
  $$EventosSanitariosTableOrderingComposer({
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

  ColumnOrderings<String> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get producto => $composableBuilder(
    column: $table.producto,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dosis => $composableBuilder(
    column: $table.dosis,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fecha => $composableBuilder(
    column: $table.fecha,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get responsableId => $composableBuilder(
    column: $table.responsableId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get observaciones => $composableBuilder(
    column: $table.observaciones,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get costo => $composableBuilder(
    column: $table.costo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get medicamentoId => $composableBuilder(
    column: $table.medicamentoId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get mlAplicados => $composableBuilder(
    column: $table.mlAplicados,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get aplicaciones => $composableBuilder(
    column: $table.aplicaciones,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get diasRetiro => $composableBuilder(
    column: $table.diasRetiro,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get retiroHasta => $composableBuilder(
    column: $table.retiroHasta,
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

class $$EventosSanitariosTableAnnotationComposer
    extends Composer<_$AppDatabase, $EventosSanitariosTable> {
  $$EventosSanitariosTableAnnotationComposer({
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

  GeneratedColumn<String> get tipo =>
      $composableBuilder(column: $table.tipo, builder: (column) => column);

  GeneratedColumn<String> get producto =>
      $composableBuilder(column: $table.producto, builder: (column) => column);

  GeneratedColumn<String> get dosis =>
      $composableBuilder(column: $table.dosis, builder: (column) => column);

  GeneratedColumn<DateTime> get fecha =>
      $composableBuilder(column: $table.fecha, builder: (column) => column);

  GeneratedColumn<String> get responsableId => $composableBuilder(
    column: $table.responsableId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get observaciones => $composableBuilder(
    column: $table.observaciones,
    builder: (column) => column,
  );

  GeneratedColumn<double> get costo =>
      $composableBuilder(column: $table.costo, builder: (column) => column);

  GeneratedColumn<String> get medicamentoId => $composableBuilder(
    column: $table.medicamentoId,
    builder: (column) => column,
  );

  GeneratedColumn<double> get mlAplicados => $composableBuilder(
    column: $table.mlAplicados,
    builder: (column) => column,
  );

  GeneratedColumn<int> get aplicaciones => $composableBuilder(
    column: $table.aplicaciones,
    builder: (column) => column,
  );

  GeneratedColumn<int> get diasRetiro => $composableBuilder(
    column: $table.diasRetiro,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get retiroHasta => $composableBuilder(
    column: $table.retiroHasta,
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

class $$EventosSanitariosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EventosSanitariosTable,
          EventoSanitarioRow,
          $$EventosSanitariosTableFilterComposer,
          $$EventosSanitariosTableOrderingComposer,
          $$EventosSanitariosTableAnnotationComposer,
          $$EventosSanitariosTableCreateCompanionBuilder,
          $$EventosSanitariosTableUpdateCompanionBuilder,
          (
            EventoSanitarioRow,
            BaseReferences<
              _$AppDatabase,
              $EventosSanitariosTable,
              EventoSanitarioRow
            >,
          ),
          EventoSanitarioRow,
          PrefetchHooks Function()
        > {
  $$EventosSanitariosTableTableManager(
    _$AppDatabase db,
    $EventosSanitariosTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EventosSanitariosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EventosSanitariosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EventosSanitariosTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> animalId = const Value.absent(),
                Value<String> tipo = const Value.absent(),
                Value<String> producto = const Value.absent(),
                Value<String?> dosis = const Value.absent(),
                Value<DateTime> fecha = const Value.absent(),
                Value<String?> responsableId = const Value.absent(),
                Value<String?> observaciones = const Value.absent(),
                Value<double?> costo = const Value.absent(),
                Value<String?> medicamentoId = const Value.absent(),
                Value<double?> mlAplicados = const Value.absent(),
                Value<int?> aplicaciones = const Value.absent(),
                Value<int?> diasRetiro = const Value.absent(),
                Value<DateTime?> retiroHasta = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<bool> pendiente = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EventosSanitariosCompanion(
                id: id,
                animalId: animalId,
                tipo: tipo,
                producto: producto,
                dosis: dosis,
                fecha: fecha,
                responsableId: responsableId,
                observaciones: observaciones,
                costo: costo,
                medicamentoId: medicamentoId,
                mlAplicados: mlAplicados,
                aplicaciones: aplicaciones,
                diasRetiro: diasRetiro,
                retiroHasta: retiroHasta,
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
                required String tipo,
                required String producto,
                Value<String?> dosis = const Value.absent(),
                required DateTime fecha,
                Value<String?> responsableId = const Value.absent(),
                Value<String?> observaciones = const Value.absent(),
                Value<double?> costo = const Value.absent(),
                Value<String?> medicamentoId = const Value.absent(),
                Value<double?> mlAplicados = const Value.absent(),
                Value<int?> aplicaciones = const Value.absent(),
                Value<int?> diasRetiro = const Value.absent(),
                Value<DateTime?> retiroHasta = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<bool> pendiente = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EventosSanitariosCompanion.insert(
                id: id,
                animalId: animalId,
                tipo: tipo,
                producto: producto,
                dosis: dosis,
                fecha: fecha,
                responsableId: responsableId,
                observaciones: observaciones,
                costo: costo,
                medicamentoId: medicamentoId,
                mlAplicados: mlAplicados,
                aplicaciones: aplicaciones,
                diasRetiro: diasRetiro,
                retiroHasta: retiroHasta,
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

typedef $$EventosSanitariosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EventosSanitariosTable,
      EventoSanitarioRow,
      $$EventosSanitariosTableFilterComposer,
      $$EventosSanitariosTableOrderingComposer,
      $$EventosSanitariosTableAnnotationComposer,
      $$EventosSanitariosTableCreateCompanionBuilder,
      $$EventosSanitariosTableUpdateCompanionBuilder,
      (
        EventoSanitarioRow,
        BaseReferences<
          _$AppDatabase,
          $EventosSanitariosTable,
          EventoSanitarioRow
        >,
      ),
      EventoSanitarioRow,
      PrefetchHooks Function()
    >;
typedef $$LotesVentaTableCreateCompanionBuilder =
    LotesVentaCompanion Function({
      required String id,
      required String fincaId,
      required DateTime fecha,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<bool> pendiente,
      Value<int> rowid,
    });
typedef $$LotesVentaTableUpdateCompanionBuilder =
    LotesVentaCompanion Function({
      Value<String> id,
      Value<String> fincaId,
      Value<DateTime> fecha,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<bool> pendiente,
      Value<int> rowid,
    });

class $$LotesVentaTableFilterComposer
    extends Composer<_$AppDatabase, $LotesVentaTable> {
  $$LotesVentaTableFilterComposer({
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

  ColumnFilters<DateTime> get fecha => $composableBuilder(
    column: $table.fecha,
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

class $$LotesVentaTableOrderingComposer
    extends Composer<_$AppDatabase, $LotesVentaTable> {
  $$LotesVentaTableOrderingComposer({
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

  ColumnOrderings<DateTime> get fecha => $composableBuilder(
    column: $table.fecha,
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

class $$LotesVentaTableAnnotationComposer
    extends Composer<_$AppDatabase, $LotesVentaTable> {
  $$LotesVentaTableAnnotationComposer({
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

  GeneratedColumn<DateTime> get fecha =>
      $composableBuilder(column: $table.fecha, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<bool> get pendiente =>
      $composableBuilder(column: $table.pendiente, builder: (column) => column);
}

class $$LotesVentaTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LotesVentaTable,
          LoteVentaRow,
          $$LotesVentaTableFilterComposer,
          $$LotesVentaTableOrderingComposer,
          $$LotesVentaTableAnnotationComposer,
          $$LotesVentaTableCreateCompanionBuilder,
          $$LotesVentaTableUpdateCompanionBuilder,
          (
            LoteVentaRow,
            BaseReferences<_$AppDatabase, $LotesVentaTable, LoteVentaRow>,
          ),
          LoteVentaRow,
          PrefetchHooks Function()
        > {
  $$LotesVentaTableTableManager(_$AppDatabase db, $LotesVentaTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LotesVentaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LotesVentaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LotesVentaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> fincaId = const Value.absent(),
                Value<DateTime> fecha = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<bool> pendiente = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LotesVentaCompanion(
                id: id,
                fincaId: fincaId,
                fecha: fecha,
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
                required DateTime fecha,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<bool> pendiente = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LotesVentaCompanion.insert(
                id: id,
                fincaId: fincaId,
                fecha: fecha,
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

typedef $$LotesVentaTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LotesVentaTable,
      LoteVentaRow,
      $$LotesVentaTableFilterComposer,
      $$LotesVentaTableOrderingComposer,
      $$LotesVentaTableAnnotationComposer,
      $$LotesVentaTableCreateCompanionBuilder,
      $$LotesVentaTableUpdateCompanionBuilder,
      (
        LoteVentaRow,
        BaseReferences<_$AppDatabase, $LotesVentaTable, LoteVentaRow>,
      ),
      LoteVentaRow,
      PrefetchHooks Function()
    >;
typedef $$VentasTableCreateCompanionBuilder =
    VentasCompanion Function({
      required String id,
      required String animalId,
      Value<String?> loteVentaId,
      required DateTime fecha,
      required double precio,
      Value<double?> peso,
      Value<String?> comprador,
      Value<String?> observaciones,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<bool> pendiente,
      Value<int> rowid,
    });
typedef $$VentasTableUpdateCompanionBuilder =
    VentasCompanion Function({
      Value<String> id,
      Value<String> animalId,
      Value<String?> loteVentaId,
      Value<DateTime> fecha,
      Value<double> precio,
      Value<double?> peso,
      Value<String?> comprador,
      Value<String?> observaciones,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<bool> pendiente,
      Value<int> rowid,
    });

class $$VentasTableFilterComposer
    extends Composer<_$AppDatabase, $VentasTable> {
  $$VentasTableFilterComposer({
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

  ColumnFilters<String> get loteVentaId => $composableBuilder(
    column: $table.loteVentaId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fecha => $composableBuilder(
    column: $table.fecha,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get precio => $composableBuilder(
    column: $table.precio,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get peso => $composableBuilder(
    column: $table.peso,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get comprador => $composableBuilder(
    column: $table.comprador,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get observaciones => $composableBuilder(
    column: $table.observaciones,
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

class $$VentasTableOrderingComposer
    extends Composer<_$AppDatabase, $VentasTable> {
  $$VentasTableOrderingComposer({
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

  ColumnOrderings<String> get loteVentaId => $composableBuilder(
    column: $table.loteVentaId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fecha => $composableBuilder(
    column: $table.fecha,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get precio => $composableBuilder(
    column: $table.precio,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get peso => $composableBuilder(
    column: $table.peso,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get comprador => $composableBuilder(
    column: $table.comprador,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get observaciones => $composableBuilder(
    column: $table.observaciones,
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

class $$VentasTableAnnotationComposer
    extends Composer<_$AppDatabase, $VentasTable> {
  $$VentasTableAnnotationComposer({
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

  GeneratedColumn<String> get loteVentaId => $composableBuilder(
    column: $table.loteVentaId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get fecha =>
      $composableBuilder(column: $table.fecha, builder: (column) => column);

  GeneratedColumn<double> get precio =>
      $composableBuilder(column: $table.precio, builder: (column) => column);

  GeneratedColumn<double> get peso =>
      $composableBuilder(column: $table.peso, builder: (column) => column);

  GeneratedColumn<String> get comprador =>
      $composableBuilder(column: $table.comprador, builder: (column) => column);

  GeneratedColumn<String> get observaciones => $composableBuilder(
    column: $table.observaciones,
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

class $$VentasTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VentasTable,
          VentaRow,
          $$VentasTableFilterComposer,
          $$VentasTableOrderingComposer,
          $$VentasTableAnnotationComposer,
          $$VentasTableCreateCompanionBuilder,
          $$VentasTableUpdateCompanionBuilder,
          (VentaRow, BaseReferences<_$AppDatabase, $VentasTable, VentaRow>),
          VentaRow,
          PrefetchHooks Function()
        > {
  $$VentasTableTableManager(_$AppDatabase db, $VentasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VentasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VentasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VentasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> animalId = const Value.absent(),
                Value<String?> loteVentaId = const Value.absent(),
                Value<DateTime> fecha = const Value.absent(),
                Value<double> precio = const Value.absent(),
                Value<double?> peso = const Value.absent(),
                Value<String?> comprador = const Value.absent(),
                Value<String?> observaciones = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<bool> pendiente = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VentasCompanion(
                id: id,
                animalId: animalId,
                loteVentaId: loteVentaId,
                fecha: fecha,
                precio: precio,
                peso: peso,
                comprador: comprador,
                observaciones: observaciones,
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
                Value<String?> loteVentaId = const Value.absent(),
                required DateTime fecha,
                required double precio,
                Value<double?> peso = const Value.absent(),
                Value<String?> comprador = const Value.absent(),
                Value<String?> observaciones = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<bool> pendiente = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VentasCompanion.insert(
                id: id,
                animalId: animalId,
                loteVentaId: loteVentaId,
                fecha: fecha,
                precio: precio,
                peso: peso,
                comprador: comprador,
                observaciones: observaciones,
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

typedef $$VentasTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VentasTable,
      VentaRow,
      $$VentasTableFilterComposer,
      $$VentasTableOrderingComposer,
      $$VentasTableAnnotationComposer,
      $$VentasTableCreateCompanionBuilder,
      $$VentasTableUpdateCompanionBuilder,
      (VentaRow, BaseReferences<_$AppDatabase, $VentasTable, VentaRow>),
      VentaRow,
      PrefetchHooks Function()
    >;
typedef $$CostosOtrosTableCreateCompanionBuilder =
    CostosOtrosCompanion Function({
      required String id,
      required String animalId,
      required String concepto,
      required double monto,
      required DateTime fecha,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<bool> pendiente,
      Value<int> rowid,
    });
typedef $$CostosOtrosTableUpdateCompanionBuilder =
    CostosOtrosCompanion Function({
      Value<String> id,
      Value<String> animalId,
      Value<String> concepto,
      Value<double> monto,
      Value<DateTime> fecha,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<bool> pendiente,
      Value<int> rowid,
    });

class $$CostosOtrosTableFilterComposer
    extends Composer<_$AppDatabase, $CostosOtrosTable> {
  $$CostosOtrosTableFilterComposer({
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

  ColumnFilters<String> get concepto => $composableBuilder(
    column: $table.concepto,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get monto => $composableBuilder(
    column: $table.monto,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fecha => $composableBuilder(
    column: $table.fecha,
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

class $$CostosOtrosTableOrderingComposer
    extends Composer<_$AppDatabase, $CostosOtrosTable> {
  $$CostosOtrosTableOrderingComposer({
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

  ColumnOrderings<String> get concepto => $composableBuilder(
    column: $table.concepto,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get monto => $composableBuilder(
    column: $table.monto,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fecha => $composableBuilder(
    column: $table.fecha,
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

class $$CostosOtrosTableAnnotationComposer
    extends Composer<_$AppDatabase, $CostosOtrosTable> {
  $$CostosOtrosTableAnnotationComposer({
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

  GeneratedColumn<String> get concepto =>
      $composableBuilder(column: $table.concepto, builder: (column) => column);

  GeneratedColumn<double> get monto =>
      $composableBuilder(column: $table.monto, builder: (column) => column);

  GeneratedColumn<DateTime> get fecha =>
      $composableBuilder(column: $table.fecha, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<bool> get pendiente =>
      $composableBuilder(column: $table.pendiente, builder: (column) => column);
}

class $$CostosOtrosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CostosOtrosTable,
          CostoOtroRow,
          $$CostosOtrosTableFilterComposer,
          $$CostosOtrosTableOrderingComposer,
          $$CostosOtrosTableAnnotationComposer,
          $$CostosOtrosTableCreateCompanionBuilder,
          $$CostosOtrosTableUpdateCompanionBuilder,
          (
            CostoOtroRow,
            BaseReferences<_$AppDatabase, $CostosOtrosTable, CostoOtroRow>,
          ),
          CostoOtroRow,
          PrefetchHooks Function()
        > {
  $$CostosOtrosTableTableManager(_$AppDatabase db, $CostosOtrosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CostosOtrosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CostosOtrosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CostosOtrosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> animalId = const Value.absent(),
                Value<String> concepto = const Value.absent(),
                Value<double> monto = const Value.absent(),
                Value<DateTime> fecha = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<bool> pendiente = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CostosOtrosCompanion(
                id: id,
                animalId: animalId,
                concepto: concepto,
                monto: monto,
                fecha: fecha,
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
                required String concepto,
                required double monto,
                required DateTime fecha,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<bool> pendiente = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CostosOtrosCompanion.insert(
                id: id,
                animalId: animalId,
                concepto: concepto,
                monto: monto,
                fecha: fecha,
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

typedef $$CostosOtrosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CostosOtrosTable,
      CostoOtroRow,
      $$CostosOtrosTableFilterComposer,
      $$CostosOtrosTableOrderingComposer,
      $$CostosOtrosTableAnnotationComposer,
      $$CostosOtrosTableCreateCompanionBuilder,
      $$CostosOtrosTableUpdateCompanionBuilder,
      (
        CostoOtroRow,
        BaseReferences<_$AppDatabase, $CostosOtrosTable, CostoOtroRow>,
      ),
      CostoOtroRow,
      PrefetchHooks Function()
    >;
typedef $$FeatureFlagsTableCreateCompanionBuilder =
    FeatureFlagsCompanion Function({
      required String id,
      required String scope,
      Value<String?> scopeId,
      required String clave,
      Value<bool> habilitado,
      Value<String?> nota,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$FeatureFlagsTableUpdateCompanionBuilder =
    FeatureFlagsCompanion Function({
      Value<String> id,
      Value<String> scope,
      Value<String?> scopeId,
      Value<String> clave,
      Value<bool> habilitado,
      Value<String?> nota,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

class $$FeatureFlagsTableFilterComposer
    extends Composer<_$AppDatabase, $FeatureFlagsTable> {
  $$FeatureFlagsTableFilterComposer({
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

  ColumnFilters<String> get scope => $composableBuilder(
    column: $table.scope,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scopeId => $composableBuilder(
    column: $table.scopeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get clave => $composableBuilder(
    column: $table.clave,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get habilitado => $composableBuilder(
    column: $table.habilitado,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nota => $composableBuilder(
    column: $table.nota,
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
}

class $$FeatureFlagsTableOrderingComposer
    extends Composer<_$AppDatabase, $FeatureFlagsTable> {
  $$FeatureFlagsTableOrderingComposer({
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

  ColumnOrderings<String> get scope => $composableBuilder(
    column: $table.scope,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scopeId => $composableBuilder(
    column: $table.scopeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get clave => $composableBuilder(
    column: $table.clave,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get habilitado => $composableBuilder(
    column: $table.habilitado,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nota => $composableBuilder(
    column: $table.nota,
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
}

class $$FeatureFlagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FeatureFlagsTable> {
  $$FeatureFlagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get scope =>
      $composableBuilder(column: $table.scope, builder: (column) => column);

  GeneratedColumn<String> get scopeId =>
      $composableBuilder(column: $table.scopeId, builder: (column) => column);

  GeneratedColumn<String> get clave =>
      $composableBuilder(column: $table.clave, builder: (column) => column);

  GeneratedColumn<bool> get habilitado => $composableBuilder(
    column: $table.habilitado,
    builder: (column) => column,
  );

  GeneratedColumn<String> get nota =>
      $composableBuilder(column: $table.nota, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$FeatureFlagsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FeatureFlagsTable,
          FeatureFlagRow,
          $$FeatureFlagsTableFilterComposer,
          $$FeatureFlagsTableOrderingComposer,
          $$FeatureFlagsTableAnnotationComposer,
          $$FeatureFlagsTableCreateCompanionBuilder,
          $$FeatureFlagsTableUpdateCompanionBuilder,
          (
            FeatureFlagRow,
            BaseReferences<_$AppDatabase, $FeatureFlagsTable, FeatureFlagRow>,
          ),
          FeatureFlagRow,
          PrefetchHooks Function()
        > {
  $$FeatureFlagsTableTableManager(_$AppDatabase db, $FeatureFlagsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FeatureFlagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FeatureFlagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FeatureFlagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> scope = const Value.absent(),
                Value<String?> scopeId = const Value.absent(),
                Value<String> clave = const Value.absent(),
                Value<bool> habilitado = const Value.absent(),
                Value<String?> nota = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FeatureFlagsCompanion(
                id: id,
                scope: scope,
                scopeId: scopeId,
                clave: clave,
                habilitado: habilitado,
                nota: nota,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String scope,
                Value<String?> scopeId = const Value.absent(),
                required String clave,
                Value<bool> habilitado = const Value.absent(),
                Value<String?> nota = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FeatureFlagsCompanion.insert(
                id: id,
                scope: scope,
                scopeId: scopeId,
                clave: clave,
                habilitado: habilitado,
                nota: nota,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FeatureFlagsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FeatureFlagsTable,
      FeatureFlagRow,
      $$FeatureFlagsTableFilterComposer,
      $$FeatureFlagsTableOrderingComposer,
      $$FeatureFlagsTableAnnotationComposer,
      $$FeatureFlagsTableCreateCompanionBuilder,
      $$FeatureFlagsTableUpdateCompanionBuilder,
      (
        FeatureFlagRow,
        BaseReferences<_$AppDatabase, $FeatureFlagsTable, FeatureFlagRow>,
      ),
      FeatureFlagRow,
      PrefetchHooks Function()
    >;
typedef $$SyncCursoresTableCreateCompanionBuilder =
    SyncCursoresCompanion Function({
      required String tabla,
      Value<DateTime?> ultimaBajada,
      Value<String?> ultimaBajadaId,
      Value<int> rowid,
    });
typedef $$SyncCursoresTableUpdateCompanionBuilder =
    SyncCursoresCompanion Function({
      Value<String> tabla,
      Value<DateTime?> ultimaBajada,
      Value<String?> ultimaBajadaId,
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

  ColumnFilters<String> get ultimaBajadaId => $composableBuilder(
    column: $table.ultimaBajadaId,
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

  ColumnOrderings<String> get ultimaBajadaId => $composableBuilder(
    column: $table.ultimaBajadaId,
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

  GeneratedColumn<String> get ultimaBajadaId => $composableBuilder(
    column: $table.ultimaBajadaId,
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
                Value<String?> ultimaBajadaId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncCursoresCompanion(
                tabla: tabla,
                ultimaBajada: ultimaBajada,
                ultimaBajadaId: ultimaBajadaId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String tabla,
                Value<DateTime?> ultimaBajada = const Value.absent(),
                Value<String?> ultimaBajadaId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncCursoresCompanion.insert(
                tabla: tabla,
                ultimaBajada: ultimaBajada,
                ultimaBajadaId: ultimaBajadaId,
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
typedef $$SyncEstadosTableCreateCompanionBuilder =
    SyncEstadosCompanion Function({
      required String tabla,
      Value<DateTime?> ultimaSincronizacionOk,
      Value<String?> ultimoError,
      Value<DateTime?> ultimoErrorEn,
      Value<int> rowid,
    });
typedef $$SyncEstadosTableUpdateCompanionBuilder =
    SyncEstadosCompanion Function({
      Value<String> tabla,
      Value<DateTime?> ultimaSincronizacionOk,
      Value<String?> ultimoError,
      Value<DateTime?> ultimoErrorEn,
      Value<int> rowid,
    });

class $$SyncEstadosTableFilterComposer
    extends Composer<_$AppDatabase, $SyncEstadosTable> {
  $$SyncEstadosTableFilterComposer({
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

  ColumnFilters<DateTime> get ultimaSincronizacionOk => $composableBuilder(
    column: $table.ultimaSincronizacionOk,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ultimoError => $composableBuilder(
    column: $table.ultimoError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get ultimoErrorEn => $composableBuilder(
    column: $table.ultimoErrorEn,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncEstadosTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncEstadosTable> {
  $$SyncEstadosTableOrderingComposer({
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

  ColumnOrderings<DateTime> get ultimaSincronizacionOk => $composableBuilder(
    column: $table.ultimaSincronizacionOk,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ultimoError => $composableBuilder(
    column: $table.ultimoError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get ultimoErrorEn => $composableBuilder(
    column: $table.ultimoErrorEn,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncEstadosTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncEstadosTable> {
  $$SyncEstadosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get tabla =>
      $composableBuilder(column: $table.tabla, builder: (column) => column);

  GeneratedColumn<DateTime> get ultimaSincronizacionOk => $composableBuilder(
    column: $table.ultimaSincronizacionOk,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ultimoError => $composableBuilder(
    column: $table.ultimoError,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get ultimoErrorEn => $composableBuilder(
    column: $table.ultimoErrorEn,
    builder: (column) => column,
  );
}

class $$SyncEstadosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncEstadosTable,
          SyncEstadoRow,
          $$SyncEstadosTableFilterComposer,
          $$SyncEstadosTableOrderingComposer,
          $$SyncEstadosTableAnnotationComposer,
          $$SyncEstadosTableCreateCompanionBuilder,
          $$SyncEstadosTableUpdateCompanionBuilder,
          (
            SyncEstadoRow,
            BaseReferences<_$AppDatabase, $SyncEstadosTable, SyncEstadoRow>,
          ),
          SyncEstadoRow,
          PrefetchHooks Function()
        > {
  $$SyncEstadosTableTableManager(_$AppDatabase db, $SyncEstadosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncEstadosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncEstadosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncEstadosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> tabla = const Value.absent(),
                Value<DateTime?> ultimaSincronizacionOk = const Value.absent(),
                Value<String?> ultimoError = const Value.absent(),
                Value<DateTime?> ultimoErrorEn = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncEstadosCompanion(
                tabla: tabla,
                ultimaSincronizacionOk: ultimaSincronizacionOk,
                ultimoError: ultimoError,
                ultimoErrorEn: ultimoErrorEn,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String tabla,
                Value<DateTime?> ultimaSincronizacionOk = const Value.absent(),
                Value<String?> ultimoError = const Value.absent(),
                Value<DateTime?> ultimoErrorEn = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncEstadosCompanion.insert(
                tabla: tabla,
                ultimaSincronizacionOk: ultimaSincronizacionOk,
                ultimoError: ultimoError,
                ultimoErrorEn: ultimoErrorEn,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncEstadosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncEstadosTable,
      SyncEstadoRow,
      $$SyncEstadosTableFilterComposer,
      $$SyncEstadosTableOrderingComposer,
      $$SyncEstadosTableAnnotationComposer,
      $$SyncEstadosTableCreateCompanionBuilder,
      $$SyncEstadosTableUpdateCompanionBuilder,
      (
        SyncEstadoRow,
        BaseReferences<_$AppDatabase, $SyncEstadosTable, SyncEstadoRow>,
      ),
      SyncEstadoRow,
      PrefetchHooks Function()
    >;
typedef $$SesionesLocalesTableCreateCompanionBuilder =
    SesionesLocalesCompanion Function({
      required String id,
      required String usuarioId,
      Value<String?> email,
      Value<String?> nombre,
      required DateTime ultimoLoginOnline,
      Value<bool> offlineActiva,
      Value<int> rowid,
    });
typedef $$SesionesLocalesTableUpdateCompanionBuilder =
    SesionesLocalesCompanion Function({
      Value<String> id,
      Value<String> usuarioId,
      Value<String?> email,
      Value<String?> nombre,
      Value<DateTime> ultimoLoginOnline,
      Value<bool> offlineActiva,
      Value<int> rowid,
    });

class $$SesionesLocalesTableFilterComposer
    extends Composer<_$AppDatabase, $SesionesLocalesTable> {
  $$SesionesLocalesTableFilterComposer({
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

  ColumnFilters<String> get usuarioId => $composableBuilder(
    column: $table.usuarioId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get ultimoLoginOnline => $composableBuilder(
    column: $table.ultimoLoginOnline,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get offlineActiva => $composableBuilder(
    column: $table.offlineActiva,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SesionesLocalesTableOrderingComposer
    extends Composer<_$AppDatabase, $SesionesLocalesTable> {
  $$SesionesLocalesTableOrderingComposer({
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

  ColumnOrderings<String> get usuarioId => $composableBuilder(
    column: $table.usuarioId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get ultimoLoginOnline => $composableBuilder(
    column: $table.ultimoLoginOnline,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get offlineActiva => $composableBuilder(
    column: $table.offlineActiva,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SesionesLocalesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SesionesLocalesTable> {
  $$SesionesLocalesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get usuarioId =>
      $composableBuilder(column: $table.usuarioId, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get nombre =>
      $composableBuilder(column: $table.nombre, builder: (column) => column);

  GeneratedColumn<DateTime> get ultimoLoginOnline => $composableBuilder(
    column: $table.ultimoLoginOnline,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get offlineActiva => $composableBuilder(
    column: $table.offlineActiva,
    builder: (column) => column,
  );
}

class $$SesionesLocalesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SesionesLocalesTable,
          SesionLocalRow,
          $$SesionesLocalesTableFilterComposer,
          $$SesionesLocalesTableOrderingComposer,
          $$SesionesLocalesTableAnnotationComposer,
          $$SesionesLocalesTableCreateCompanionBuilder,
          $$SesionesLocalesTableUpdateCompanionBuilder,
          (
            SesionLocalRow,
            BaseReferences<
              _$AppDatabase,
              $SesionesLocalesTable,
              SesionLocalRow
            >,
          ),
          SesionLocalRow,
          PrefetchHooks Function()
        > {
  $$SesionesLocalesTableTableManager(
    _$AppDatabase db,
    $SesionesLocalesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SesionesLocalesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SesionesLocalesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SesionesLocalesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> usuarioId = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> nombre = const Value.absent(),
                Value<DateTime> ultimoLoginOnline = const Value.absent(),
                Value<bool> offlineActiva = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SesionesLocalesCompanion(
                id: id,
                usuarioId: usuarioId,
                email: email,
                nombre: nombre,
                ultimoLoginOnline: ultimoLoginOnline,
                offlineActiva: offlineActiva,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String usuarioId,
                Value<String?> email = const Value.absent(),
                Value<String?> nombre = const Value.absent(),
                required DateTime ultimoLoginOnline,
                Value<bool> offlineActiva = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SesionesLocalesCompanion.insert(
                id: id,
                usuarioId: usuarioId,
                email: email,
                nombre: nombre,
                ultimoLoginOnline: ultimoLoginOnline,
                offlineActiva: offlineActiva,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SesionesLocalesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SesionesLocalesTable,
      SesionLocalRow,
      $$SesionesLocalesTableFilterComposer,
      $$SesionesLocalesTableOrderingComposer,
      $$SesionesLocalesTableAnnotationComposer,
      $$SesionesLocalesTableCreateCompanionBuilder,
      $$SesionesLocalesTableUpdateCompanionBuilder,
      (
        SesionLocalRow,
        BaseReferences<_$AppDatabase, $SesionesLocalesTable, SesionLocalRow>,
      ),
      SesionLocalRow,
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
  $$DietasTableTableManager get dietas =>
      $$DietasTableTableManager(_db, _db.dietas);
  $$DietaIngredientesTableTableManager get dietaIngredientes =>
      $$DietaIngredientesTableTableManager(_db, _db.dietaIngredientes);
  $$LoteDietasTableTableManager get loteDietas =>
      $$LoteDietasTableTableManager(_db, _db.loteDietas);
  $$MovimientosLoteTableTableManager get movimientosLote =>
      $$MovimientosLoteTableTableManager(_db, _db.movimientosLote);
  $$MedicamentosTableTableManager get medicamentos =>
      $$MedicamentosTableTableManager(_db, _db.medicamentos);
  $$EventosSanitariosTableTableManager get eventosSanitarios =>
      $$EventosSanitariosTableTableManager(_db, _db.eventosSanitarios);
  $$LotesVentaTableTableManager get lotesVenta =>
      $$LotesVentaTableTableManager(_db, _db.lotesVenta);
  $$VentasTableTableManager get ventas =>
      $$VentasTableTableManager(_db, _db.ventas);
  $$CostosOtrosTableTableManager get costosOtros =>
      $$CostosOtrosTableTableManager(_db, _db.costosOtros);
  $$FeatureFlagsTableTableManager get featureFlags =>
      $$FeatureFlagsTableTableManager(_db, _db.featureFlags);
  $$SyncCursoresTableTableManager get syncCursores =>
      $$SyncCursoresTableTableManager(_db, _db.syncCursores);
  $$SyncEstadosTableTableManager get syncEstados =>
      $$SyncEstadosTableTableManager(_db, _db.syncEstados);
  $$SesionesLocalesTableTableManager get sesionesLocales =>
      $$SesionesLocalesTableTableManager(_db, _db.sesionesLocales);
}
