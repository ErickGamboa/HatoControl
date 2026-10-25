import 'package:flutter/material.dart';

import '../app/widgets/boton_sincronizar.dart';
import 'package:flutter/services.dart';

import '../data/local/database.dart';
import '../data/repositories/lotes_repository.dart';
import '../services.dart';
import 'lote_animales_screen.dart';

/// Lista y creación de lotes de una finca.
class LotesScreen extends StatelessWidget {
  const LotesScreen({super.key, required this.finca, this.usuarioId});

  final FincaRow finca;
  final String? usuarioId;

  /// Diálogo para crear o editar un lote. Si [lote] es null, crea uno nuevo.
  Future<void> _loteDialog(BuildContext context, {LoteRow? lote}) async {
    final datos = await showDialog<_DatosLote>(
      context: context,
      builder: (ctx) => _LoteDialog(lote: lote),
    );
    if (datos == null) return;

    if (lote != null && datos.eliminar) {
      if (!context.mounted) return;
      await _eliminarLote(context, lote);
      return;
    }
    if (lote != null) {
      await lotesRepo.editarLote(
        loteId: lote.id,
        nombre: datos.nombre,
        numero: datos.numero,
        area: datos.area,
        areaUnidad: datos.areaUnidad,
      );
    } else {
      await lotesRepo.crearLote(
        fincaId: finca.id,
        nombre: datos.nombre,
        numero: datos.numero,
        area: datos.area,
        areaUnidad: datos.areaUnidad,
      );
    }
    sincronizarSiSePuede();
  }

  /// Elimina el lote con todo lo que tiene, después de advertir qué se pierde
  /// y de que el ganadero confirme que lo hace bajo su responsabilidad.
  Future<void> _eliminarLote(BuildContext context, LoteRow lote) async {
    final resumen = await lotesRepo.resumenParaBorrar(lote.id);
    if (!context.mounted) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => _ConfirmarEliminarLote(lote: lote, resumen: resumen),
    );
    if (ok != true) return;
    await lotesRepo.eliminarLoteConTodo(lote.id);
    sincronizarSiSePuede();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lote "${lote.nombre}" eliminado.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final soloLectura = permisosFinca.esSoloLectura;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lotes'),
        actions: const [BotonSincronizar()],
      ),
      floatingActionButton: soloLectura
          ? null
          : FloatingActionButton.extended(
              key: const ValueKey('lotes.create'),
              onPressed: () => _loteDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Lote'),
            ),
      body: StreamBuilder<List<LoteRow>>(
        stream: lotesRepo.observarLotes(finca.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final lotes = snapshot.data ?? const [];
          if (lotes.isEmpty) {
            return _VacioLotes(soloLectura: soloLectura);
          }
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: lotes.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final l = lotes[i];
              return Card(
                margin: EdgeInsets.zero,
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(l.numero?.toString() ?? '–'),
                  ),
                  title: Text(l.nombre),
                  subtitle: _subtituloLote(l),
                  trailing: soloLectura
                      ? null
                      : IconButton(
                          tooltip: 'Editar lote',
                          icon: const Icon(Icons.edit, size: 20),
                          onPressed: () => _loteDialog(context, lote: l),
                        ),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          LoteAnimalesScreen(lote: l, usuarioId: usuarioId),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

/// "Pendiente de sincronizar" y/o el terreno, que es lo que el ganadero
/// quiere ver de un vistazo junto al nombre del lote.
Widget? _subtituloLote(LoteRow l) {
  final partes = <String>[
    if (l.areaM2 != null) UnidadArea.formatear(l.areaM2!, l.areaUnidad ?? ''),
    if (l.pendiente) 'Pendiente de sincronizar',
  ];
  return partes.isEmpty ? null : Text(partes.join(' · '));
}

/// Lo que devuelve el formulario del lote.
class _DatosLote {
  const _DatosLote({
    required this.nombre,
    this.numero,
    this.area,
    this.areaUnidad,
  }) : eliminar = false;

  /// El ganadero tocó "Eliminar lote" en vez de guardar.
  const _DatosLote.eliminar()
    : nombre = '',
      numero = null,
      area = null,
      areaUnidad = null,
      eliminar = true;

  final bool eliminar;
  final String nombre;
  final int? numero;

  /// Terreno como lo digitó el ganadero, en [areaUnidad]. null = sin terreno.
  final double? area;
  final String? areaUnidad;
}

/// Formulario de lote: nombre, número y el terreno en el que se maneja.
///
/// El terreno se digita en la unidad que usa cada quien (hectáreas, manzanas
/// o metros); el repositorio lo guarda en m² para poder sumarlo después.
class _LoteDialog extends StatefulWidget {
  const _LoteDialog({this.lote});

  final LoteRow? lote;

  @override
  State<_LoteDialog> createState() => _LoteDialogState();
}

class _LoteDialogState extends State<_LoteDialog> {
  late final _nombre = TextEditingController(text: widget.lote?.nombre ?? '');
  late final _numero = TextEditingController(
    text: widget.lote?.numero?.toString() ?? '',
  );
  late final _area = TextEditingController(text: _areaInicial());
  late String _unidad = UnidadArea.normalizar(widget.lote?.areaUnidad);

  String _areaInicial() {
    final m2 = widget.lote?.areaM2;
    if (m2 == null) return '';
    final valor = UnidadArea.desdeM2(
      m2,
      UnidadArea.normalizar(widget.lote?.areaUnidad),
    );
    return valor == valor.roundToDouble()
        ? valor.round().toString()
        : valor.toStringAsFixed(2);
  }

  @override
  void dispose() {
    _nombre.dispose();
    _numero.dispose();
    _area.dispose();
    super.dispose();
  }

  void _guardar() {
    final nombre = _nombre.text.trim();
    if (nombre.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Escribí el nombre del lote.')),
      );
      return;
    }
    final area = double.tryParse(_area.text.trim().replaceAll(',', '.'));
    Navigator.pop(
      context,
      _DatosLote(
        nombre: nombre,
        numero: int.tryParse(_numero.text.trim()),
        area: area == null || area <= 0 ? null : area,
        areaUnidad: _unidad,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final esEdicion = widget.lote != null;
    return AlertDialog(
      title: Text(esEdicion ? 'Editar lote' : 'Nuevo lote'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              key: const ValueKey('lotes.name'),
              controller: _nombre,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Nombre del lote',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              key: const ValueKey('lotes.number'),
              controller: _numero,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'Número (opcional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 4,
                  child: TextField(
                    key: const ValueKey('lotes.area'),
                    controller: _area,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                    ],
                    // Etiqueta corta a propósito: el campo es angosto (al
                    // lado va la unidad) y "Terreno (opcional)" salía
                    // cortado como "Terreno (o…".
                    decoration: const InputDecoration(
                      labelText: 'Terreno',
                      hintText: 'opcional',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 5,
                  child: DropdownButtonFormField<String>(
                    key: const ValueKey('lotes.areaUnidad'),
                    initialValue: _unidad,
                    decoration: const InputDecoration(
                      labelText: 'Unidad',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      for (final u in UnidadArea.todas)
                        DropdownMenuItem(
                          value: u,
                          child: Text(UnidadArea.etiqueta(u)),
                        ),
                    ],
                    onChanged: (v) =>
                        setState(() => _unidad = UnidadArea.normalizar(v)),
                  ),
                ),
              ],
            ),
            if (esEdicion) ...[
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  key: const ValueKey('lotes.eliminar'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  onPressed: () =>
                      Navigator.pop(context, const _DatosLote.eliminar()),
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Eliminar lote'),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          key: const ValueKey('lotes.save'),
          onPressed: _guardar,
          child: Text(esEdicion ? 'Guardar' : 'Crear'),
        ),
      ],
    );
  }
}

/// Advertencia antes de eliminar un lote: dice todo lo que se pierde y pide
/// marcar que el ganadero lo hace bajo su propia responsabilidad.
class _ConfirmarEliminarLote extends StatefulWidget {
  const _ConfirmarEliminarLote({required this.lote, required this.resumen});

  final LoteRow lote;
  final ResumenBorradoLote resumen;

  @override
  State<_ConfirmarEliminarLote> createState() => _ConfirmarEliminarLoteState();
}

class _ConfirmarEliminarLoteState extends State<_ConfirmarEliminarLote> {
  bool _acepto = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final r = widget.resumen;
    final perdidas = <String>[
      if (r.animales > 0)
        '${r.animales} animal(es)'
            '${r.vendidos > 0 ? ', ${r.vendidos} ya vendido(s) con su venta' : ''}',
      if (r.pesajes > 0) '${r.pesajes} pesaje(s)',
      if (r.sanidad > 0) '${r.sanidad} aplicación(es) de sanidad',
    ];
    return AlertDialog(
      icon: Icon(Icons.warning_amber_rounded, color: theme.colorScheme.error),
      title: Text('¿Eliminar "${widget.lote.nombre}"?'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              perdidas.isEmpty
                  ? 'El lote no tiene animales. Se elimina el lote.'
                  : 'Se borra el lote y TODA su información:',
              style: theme.textTheme.bodyLarge,
            ),
            for (final p in perdidas)
              Padding(
                padding: const EdgeInsets.only(top: 6, left: 8),
                child: Text('• $p', style: theme.textTheme.bodyLarge),
              ),
            if (perdidas.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'También sus costos, ventas e historial. Esos animales salen '
                'del inventario, de los análisis y de la utilidad de la '
                'finca.',
                style: theme.textTheme.bodyMedium,
              ),
            ],
            const SizedBox(height: 12),
            Text(
              'Se borra también en la nube y en los otros teléfonos. '
              'No se puede deshacer.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            CheckboxListTile(
              key: const ValueKey('lotes.eliminar.acepto'),
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              value: _acepto,
              onChanged: (v) => setState(() => _acepto = v ?? false),
              title: const Text(
                'Entiendo y lo elimino bajo mi propia responsabilidad',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          key: const ValueKey('lotes.eliminar.confirmar'),
          style: FilledButton.styleFrom(
            backgroundColor: theme.colorScheme.error,
            foregroundColor: theme.colorScheme.onError,
          ),
          onPressed: _acepto ? () => Navigator.pop(context, true) : null,
          child: const Text('Eliminar todo'),
        ),
      ],
    );
  }
}

class _VacioLotes extends StatelessWidget {
  const _VacioLotes({required this.soloLectura});

  final bool soloLectura;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/iconos/lotes.png',
              width: 72,
              height: 72,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'Esta finca no tiene lotes',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              soloLectura
                  ? 'Cuando el dueño cree lotes, los vas a ver acá.'
                  : 'Creá el primer lote con el botón de abajo.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
