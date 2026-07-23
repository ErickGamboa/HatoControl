import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app/theme.dart';
import '../data/estadisticas/estadisticas_sanidad.dart';
import '../data/local/database.dart';
import '../data/repositories/medicamentos_repository.dart';
import '../services.dart';

/// Catálogo de medicamentos de la finca (documento oro, Módulo 2).
class SanidadScreen extends StatelessWidget {
  SanidadScreen({
    super.key,
    required this.finca,
    MedicamentosRepository? medicamentosRepository,
  }) : medicamentosRepository = medicamentosRepository ?? medicamentosRepo;

  final FincaRow finca;
  final MedicamentosRepository medicamentosRepository;

  Future<void> _formulario(
    BuildContext context, {
    MedicamentoRow? existente,
  }) async {
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => _MedicamentoFormSheet(
        existente: existente,
        onGuardar: (datos) async {
          if (existente == null) {
            await medicamentosRepository.crearMedicamento(
              fincaId: finca.id,
              nombre: datos.nombre,
              costoEnvase: datos.costoEnvase,
              tipoAplicacion: datos.tipo,
              mlEnvase: datos.mlEnvase,
              aplicacionesPorEnvase: datos.aplicacionesPorEnvase,
              dosisCantidad: datos.dosisCantidad,
              dosisPorCadaKg: datos.dosisPorCadaKg,
              diasRetiro: datos.diasRetiro,
            );
          } else {
            await medicamentosRepository.editarMedicamento(
              medicamentoId: existente.id,
              nombre: datos.nombre,
              costoEnvase: datos.costoEnvase,
              tipoAplicacion: datos.tipo,
              mlEnvase: datos.mlEnvase,
              aplicacionesPorEnvase: datos.aplicacionesPorEnvase,
              dosisCantidad: datos.dosisCantidad,
              dosisPorCadaKg: datos.dosisPorCadaKg,
              diasRetiro: datos.diasRetiro,
            );
          }
          sincronizarSiSePuede();
        },
      ),
    );
    if (ok == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            existente == null
                ? 'Medicamento creado'
                : 'Medicamento actualizado',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Sanidad')),
      floatingActionButton: FloatingActionButton.extended(
        key: const ValueKey('sanidad.agregar'),
        onPressed: () => _formulario(context),
        icon: const Icon(Icons.add),
        label: const Text('Medicamento'),
      ),
      body: StreamBuilder<List<MedicamentoRow>>(
        stream: medicamentosRepository.observarMedicamentos(finca.id),
        builder: (context, snap) {
          final lista = snap.data ?? const [];
          if (snap.connectionState == ConnectionState.waiting &&
              lista.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (lista.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(HatoSpacing.xl),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.medical_services_outlined,
                      size: 56,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: HatoSpacing.lg),
                    Text(
                      'Medicamentos de la finca',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: HatoSpacing.sm),
                    Text(
                      'Registralos una vez. En Trabajo, después de pesar, '
                      'tocás los que aplicás y la dosis/costo se calculan solos.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(
              HatoSpacing.lg,
              HatoSpacing.lg,
              HatoSpacing.lg,
              88,
            ),
            itemCount: lista.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final m = lista[i];
              return Card(
                margin: EdgeInsets.zero,
                child: ListTile(
                  onTap: () => _formulario(context, existente: m),
                  leading: Icon(
                    Icons.vaccines_outlined,
                    color: theme.colorScheme.primary,
                  ),
                  title: Text(
                    m.nombre,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(
                    '${TipoAplicacionMedicamento.etiqueta(m.tipoAplicacion)}'
                    ' · retiro ${m.diasRetiro} d'
                    ' · ₡${m.costoEnvase.toStringAsFixed(0)} envase',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _DatosMedicamento {
  const _DatosMedicamento({
    required this.nombre,
    required this.costoEnvase,
    required this.tipo,
    required this.diasRetiro,
    this.mlEnvase,
    this.aplicacionesPorEnvase,
    this.dosisCantidad,
    this.dosisPorCadaKg,
  });

  final String nombre;
  final double costoEnvase;
  final String tipo;
  final int diasRetiro;
  final double? mlEnvase;
  final double? aplicacionesPorEnvase;
  final double? dosisCantidad;
  final double? dosisPorCadaKg;
}

class _MedicamentoFormSheet extends StatefulWidget {
  const _MedicamentoFormSheet({required this.onGuardar, this.existente});

  final MedicamentoRow? existente;
  final Future<void> Function(_DatosMedicamento datos) onGuardar;

  @override
  State<_MedicamentoFormSheet> createState() => _MedicamentoFormSheetState();
}

class _MedicamentoFormSheetState extends State<_MedicamentoFormSheet> {
  late final _nombre = TextEditingController(text: widget.existente?.nombre);
  late final _costo = TextEditingController(
    text: widget.existente?.costoEnvase.toString() ?? '',
  );
  late final _mlEnvase = TextEditingController(
    text: widget.existente?.mlEnvase?.toString() ?? '',
  );
  late final _apps = TextEditingController(
    text: widget.existente?.aplicacionesPorEnvase?.toString() ?? '',
  );
  late final _dosisCant = TextEditingController(
    text: widget.existente?.dosisCantidad?.toString() ?? '',
  );
  late final _cadaKg = TextEditingController(
    text: widget.existente?.dosisPorCadaKg?.toString() ?? '',
  );
  late final _retiro = TextEditingController(
    text: (widget.existente?.diasRetiro ?? 0).toString(),
  );
  late String _tipo =
      widget.existente?.tipoAplicacion ?? TipoAplicacionMedicamento.porPeso;
  bool _guardando = false;

  @override
  void dispose() {
    _nombre.dispose();
    _costo.dispose();
    _mlEnvase.dispose();
    _apps.dispose();
    _dosisCant.dispose();
    _cadaKg.dispose();
    _retiro.dispose();
    super.dispose();
  }

  double? _num(TextEditingController c) =>
      double.tryParse(c.text.trim().replaceAll(',', '.'));

  Future<void> _guardar() async {
    final nombre = _nombre.text.trim();
    final costo = _num(_costo);
    if (nombre.isEmpty || costo == null || costo < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nombre y costo del envase son obligatorios'),
        ),
      );
      return;
    }
    final retiro = int.tryParse(_retiro.text.trim()) ?? 0;
    setState(() => _guardando = true);
    try {
      await widget.onGuardar(
        _DatosMedicamento(
          nombre: nombre,
          costoEnvase: costo,
          tipo: _tipo,
          diasRetiro: retiro < 0 ? 0 : retiro,
          mlEnvase: _tipo == TipoAplicacionMedicamento.porAplicacion
              ? null
              : _num(_mlEnvase),
          aplicacionesPorEnvase:
              _tipo == TipoAplicacionMedicamento.porAplicacion
              ? _num(_apps)
              : null,
          dosisCantidad: _tipo == TipoAplicacionMedicamento.porAplicacion
              ? null
              : _num(_dosisCant),
          dosisPorCadaKg: _tipo == TipoAplicacionMedicamento.porPeso
              ? _num(_cadaKg)
              : null,
        ),
      );
      if (mounted) Navigator.pop(context, true);
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + bottom),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.existente == null ? 'Nuevo medicamento' : 'Editar',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: HatoSpacing.lg),
            TextField(
              controller: _nombre,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Nombre',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: HatoSpacing.md),
            TextField(
              controller: _costo,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
              ],
              decoration: const InputDecoration(
                labelText: 'Costo del envase',
                suffixText: '₡',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: HatoSpacing.md),
            Text('Tipo de aplicación', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                for (final t in TipoAplicacionMedicamento.todos)
                  ChoiceChip(
                    label: Text(TipoAplicacionMedicamento.etiqueta(t)),
                    selected: _tipo == t,
                    onSelected: (_) => setState(() => _tipo = t),
                  ),
              ],
            ),
            const SizedBox(height: HatoSpacing.md),
            if (_tipo != TipoAplicacionMedicamento.porAplicacion) ...[
              TextField(
                controller: _mlEnvase,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Rendimiento del envase (ml)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: HatoSpacing.md),
              TextField(
                controller: _dosisCant,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: _tipo == TipoAplicacionMedicamento.porPeso
                      ? 'Cantidad (ml) por cada X kg'
                      : 'Dosis fija (ml)',
                  border: const OutlineInputBorder(),
                ),
              ),
              if (_tipo == TipoAplicacionMedicamento.porPeso) ...[
                const SizedBox(height: HatoSpacing.md),
                TextField(
                  controller: _cadaKg,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Cada cuántos kg',
                    suffixText: 'kg',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ] else
              TextField(
                controller: _apps,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Aplicaciones que rinde el envase',
                  border: OutlineInputBorder(),
                ),
              ),
            const SizedBox(height: HatoSpacing.md),
            TextField(
              controller: _retiro,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Días de retiro',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: HatoSpacing.xl),
            FilledButton(
              onPressed: _guardando ? null : _guardar,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(_guardando ? 'Guardando…' : 'Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}
