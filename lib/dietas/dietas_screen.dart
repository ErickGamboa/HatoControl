import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/local/database.dart';
import '../data/repositories/dietas_repository.dart';
import '../services.dart';

/// Lee un número digitado por el ganadero (acepta coma decimal). Null si el
/// campo está vacío o no es un número válido ≥ 0.
double? _leerNumero(String texto) {
  final n = double.tryParse(texto.trim().replaceAll(',', '.'));
  if (n == null || n < 0) return null;
  return n;
}

/// Muestra un número en un campo de texto sin `.0` colgando.
String _fmtCampo(double n) =>
    n == n.roundToDouble() ? n.toInt().toString() : n.toString();

/// Redondea a colones enteros para mostrar montos.
String _fmtColones(double n) =>
    n == n.roundToDouble() ? n.toInt().toString() : n.toStringAsFixed(0);

/// Catálogo de dietas de una finca: crear, editar y ver el costo por animal.
class DietasScreen extends StatelessWidget {
  DietasScreen({super.key, required this.finca, DietasRepository? repo})
    : repo = repo ?? dietasRepo;

  final FincaRow finca;
  final DietasRepository repo;

  Future<void> _dietaDialog(BuildContext context, {DietaRow? dieta}) async {
    final esEdicion = dieta != null;
    final nombreCtrl = TextEditingController(text: dieta?.nombre ?? '');
    final descCtrl = TextEditingController(text: dieta?.descripcion ?? '');
    final costoKgCtrl = TextEditingController(
      text: dieta != null ? _fmtCampo(dieta.costoKg) : '',
    );
    final kgCtrl = TextEditingController(
      text: dieta != null ? _fmtCampo(dieta.kgAnimalDia) : '',
    );
    var ingredientesTexto = '';
    if (dieta != null) {
      final ings = await repo.listarIngredientes(dieta.id);
      ingredientesTexto = ings.map((i) => i.nombre).join('\n');
    }
    final ingredientesCtrl = TextEditingController(text: ingredientesTexto);

    if (!context.mounted) return;
    final guardar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(esEdicion ? 'Editar dieta' : 'Nueva dieta'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                key: const ValueKey('dietas.nombre'),
                controller: nombreCtrl,
                autofocus: true,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  hintText: 'Nombre de la dieta',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                key: const ValueKey('dietas.descripcion'),
                controller: descCtrl,
                textCapitalization: TextCapitalization.sentences,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Descripción (opcional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                key: const ValueKey('dietas.costoKg'),
                controller: costoKgCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
                ],
                decoration: const InputDecoration(
                  labelText: 'Costo por kilo',
                  hintText: '₡ por kilo de alimento',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                key: const ValueKey('dietas.kgAnimalDia'),
                controller: kgCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
                ],
                decoration: const InputDecoration(
                  labelText: 'Kilos por animal al día',
                  hintText: 'Kilos que recibe cada animal por día',
                  border: OutlineInputBorder(),
                ),
              ),
              _EquivalenteDieta(costoKgCtrl: costoKgCtrl, kgCtrl: kgCtrl),
              const SizedBox(height: 12),
              TextField(
                key: const ValueKey('dietas.ingredientes'),
                controller: ingredientesCtrl,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Ingredientes',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            key: const ValueKey('dietas.guardar'),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(esEdicion ? 'Guardar' : 'Crear'),
          ),
        ],
      ),
    );

    if (guardar != true) return;
    final nombre = nombreCtrl.text.trim();
    if (nombre.isEmpty) return;

    final ings = <String>[
      for (final line in ingredientesCtrl.text.split('\n'))
        if (line.trim().isNotEmpty) line.trim(),
    ];

    final costoKg = _leerNumero(costoKgCtrl.text);
    final kgAnimalDia = _leerNumero(kgCtrl.text);
    if (costoKg == null || kgAnimalDia == null) {
      // Con dos campos numéricos es fácil dejar uno vacío: avisar en vez de
      // no hacer nada, que se lee como que la app se quedó pegada.
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Faltan datos: digitá el costo por kilo y los kilos por animal '
              'al día.',
            ),
          ),
        );
      }
      return;
    }

    if (esEdicion) {
      await repo.editarDieta(
        dietaId: dieta.id,
        nombre: nombre,
        descripcion: descCtrl.text.trim().isEmpty ? null : descCtrl.text.trim(),
        costoKg: costoKg,
        kgAnimalDia: kgAnimalDia,
      );
      await repo.reemplazarIngredientes(dietaId: dieta.id, ingredientes: ings);
    } else {
      await repo.crearDieta(
        fincaId: finca.id,
        nombre: nombre,
        descripcion: descCtrl.text.trim().isEmpty ? null : descCtrl.text.trim(),
        costoKg: costoKg,
        kgAnimalDia: kgAnimalDia,
        ingredientes: ings,
      );
    }
    sincronizarSiSePuede();
  }

  String _fmtCosto(double c) =>
      c == c.roundToDouble() ? c.toInt().toString() : c.toStringAsFixed(2);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Dietas')),
      floatingActionButton: FloatingActionButton.extended(
        key: const ValueKey('dietas.crear'),
        onPressed: () => _dietaDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Dieta'),
      ),
      body: StreamBuilder<List<DietaRow>>(
        stream: repo.observarDietas(finca.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final dietas = snapshot.data ?? const [];
          if (dietas.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  'Esta finca no tiene dietas.\nCreá la primera con el botón de abajo.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: dietas.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final d = dietas[i];
              return Card(
                margin: EdgeInsets.zero,
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(
                      d.nombre.isNotEmpty ? d.nombre[0].toUpperCase() : '?',
                    ),
                  ),
                  title: Text(d.nombre),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (d.descripcion != null && d.descripcion!.isNotEmpty)
                        Text(d.descripcion!),
                      Text(
                        '₡${_fmtCosto(d.costoAnimalDia)} / animal / día',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      Text(
                        '₡${_fmtCosto(d.costoKg)} / kg × '
                        '${_fmtCampo(d.kgAnimalDia)} kg por animal al día',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                      Text(
                        '₡${_fmtCosto(d.costoAnimalSemana)} / animal / semana',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                      if (d.pendiente)
                        Text(
                          'Pendiente de sincronizar',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                    ],
                  ),
                  isThreeLine: true,
                  trailing: IconButton(
                    tooltip: 'Editar dieta',
                    icon: const Icon(Icons.edit, size: 20),
                    onPressed: () => _dietaDialog(context, dieta: d),
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

/// Muestra en vivo el cálculo ₡/kg × kg = ₡ por animal al día, para que el
/// ganadero vea el resultado antes de guardar.
class _EquivalenteDieta extends StatelessWidget {
  const _EquivalenteDieta({required this.costoKgCtrl, required this.kgCtrl});

  final TextEditingController costoKgCtrl;
  final TextEditingController kgCtrl;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: costoKgCtrl,
      builder: (context, _, _) => ValueListenableBuilder<TextEditingValue>(
        valueListenable: kgCtrl,
        builder: (context, _, _) {
          final costoKg = _leerNumero(costoKgCtrl.text);
          final kg = _leerNumero(kgCtrl.text);
          if (costoKg == null || kg == null) return const SizedBox.shrink();
          final dia = costoKg * kg;
          return Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              key: const ValueKey('dietas.equivalenteDia'),
              '₡${_fmtCampo(costoKg)} / kg × ${_fmtCampo(kg)} kg = '
              '₡${_fmtColones(dia)} / animal / día\n'
              '₡${_fmtColones(dia * 7)} / animal / semana',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          );
        },
      ),
    );
  }
}
