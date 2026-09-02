import 'package:flutter/material.dart';

import '../data/repositories/fincas_repository.dart';
import '../services.dart';
import 'foto_picker.dart';

/// Crear una finca es igual en el teléfono y en la computadora: mismo diálogo,
/// mismo límite de plan y mismos mensajes. Vive aparte de `FincasScreen` para
/// que la versión web lo reutilice tal cual, en vez de reimplementarlo.
///
/// Devuelve el mensaje que hay que mostrarle al usuario, o null si la finca se
/// creó bien o si canceló el diálogo.
Future<String?> flujoCrearFinca(
  BuildContext context, {
  required String usuarioId,
  EstadoLicencia? estado,
  FincasRepository? repositorio,
}) async {
  final repo = repositorio ?? fincasRepo;

  // Aviso temprano si ya alcanzó el límite (mejor experiencia).
  if (estado != null && estado.alcanzoLimite) {
    return 'Tu plan ${estado.planNombre} permite ${estado.limiteTexto} '
        'finca(s). Cambiá a un plan superior para agregar más.';
  }

  final resultado = await showDialog<(String, String?)>(
    context: context,
    builder: (_) => const DialogoNuevaFinca(),
  );
  if (resultado == null) return null;
  final (nombre, fotoLocalPath) = resultado;
  if (nombre.isEmpty) return null;

  try {
    await repo.crearFinca(
      nombre: nombre,
      creadaPor: usuarioId,
      fotoLocalPath: fotoLocalPath,
    );
    sincronizarSiSePuede();
    return null;
  } on LimiteFincasException catch (e) {
    return 'Tu plan ${e.planNombre} permite '
        '${EstadoLicencia.textoLimite(e.limite)} finca(s). '
        'Cambiá a un plan superior para agregar más.';
  } on LicenciaNoDisponibleException {
    return 'Conectate a internet una vez para activar tu cuenta.';
  }
}

/// Diálogo para crear una finca: nombre + foto opcional.
class DialogoNuevaFinca extends StatefulWidget {
  const DialogoNuevaFinca({super.key});

  @override
  State<DialogoNuevaFinca> createState() => _DialogoNuevaFincaState();
}

class _DialogoNuevaFincaState extends State<DialogoNuevaFinca> {
  final _ctrl = TextEditingController();
  String? _fotoPath;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _elegirFoto() async {
    final path = await elegirFotoFinca(context);
    if (path != null && mounted) setState(() => _fotoPath = path);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: const Text('Nueva finca'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Foto opcional (toca para elegir). En web no hay archivos locales,
          // asi que el selector no se muestra (D-09).
          if (soportaFotoLocal)
            GestureDetector(
              onTap: _elegirFoto,
              child: Container(
                height: 140,
                width: double.infinity,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.colorScheme.outlineVariant),
                ),
                child: _fotoPath == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_a_photo_outlined,
                            size: 36,
                            color: theme.colorScheme.outline,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Agregar foto (opcional)',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                          ),
                        ],
                      )
                    : imagenFotoLocal(_fotoPath!),
              ),
            ),
          if (_fotoPath != null)
            TextButton.icon(
              onPressed: () => setState(() => _fotoPath = null),
              icon: const Icon(Icons.delete_outline),
              label: const Text('Quitar foto'),
            ),
          const SizedBox(height: 12),
          TextField(
            key: const ValueKey('fincas.name'),
            controller: _ctrl,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Nombre de la finca',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          key: const ValueKey('fincas.save'),
          onPressed: () =>
              Navigator.pop(context, (_ctrl.text.trim(), _fotoPath)),
          child: const Text('Crear'),
        ),
      ],
    );
  }
}
