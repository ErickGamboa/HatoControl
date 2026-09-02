import 'package:drift/drift.dart';

import '../local/database.dart';
import '../repositories/ventas_repository.dart' show EstadoAnimal;

/// Conteos de cabecera de una finca. Los usan el home de finca del teléfono y
/// el panel de escritorio de la web: la definición de "animal activo" tiene
/// que ser exactamente la misma en los dos.
Stream<int> observarAnimalesActivos(AppDatabase db, String fincaId) {
  final conteo = db.animales.id.count();
  final consulta = db.selectOnly(db.animales)
    ..addColumns([conteo])
    ..where(
      db.animales.fincaId.equals(fincaId) &
          db.animales.deletedAt.isNull() &
          db.animales.estado.equals(EstadoAnimal.activo),
    );
  return consulta.watchSingle().map((fila) => fila.read(conteo) ?? 0);
}
