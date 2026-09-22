import 'package:flutter/material.dart';

/// "21/09/2026": la fecha como se escribe en el cuaderno.
String fmtFecha(DateTime d) =>
    '${_dos(d.day)}/${_dos(d.month)}/${d.year}';

String _dos(int n) => n.toString().padLeft(2, '0');

/// Campo para elegir una fecha con el calendario del sistema.
///
/// Se usa donde el ganadero mete datos de su cuaderno (un pesaje de la semana
/// pasada, la fecha en que adquirió una deuda): escribir la fecha a mano en la
/// manga es lento y se presta a equivocaciones, el calendario no.
class CampoFecha extends StatelessWidget {
  const CampoFecha({
    super.key,
    required this.etiqueta,
    required this.fecha,
    required this.alCambiar,
    this.primera,
    this.ultima,
    this.alLimpiar,
  });

  final String etiqueta;

  /// null = sin fecha (solo si [alLimpiar] no es null: un campo opcional).
  final DateTime? fecha;
  final ValueChanged<DateTime> alCambiar;

  /// Desde/hasta qué día se puede elegir. Por defecto, cinco años atrás y
  /// hasta hoy: los pesajes y las deudas son del pasado, no del futuro.
  final DateTime? primera;
  final DateTime? ultima;

  /// Si no es null, aparece una equis para dejar el campo vacío.
  final VoidCallback? alLimpiar;

  Future<void> _elegir(BuildContext context) async {
    final hoy = DateTime.now();
    final elegida = await showDatePicker(
      context: context,
      initialDate: fecha ?? hoy,
      firstDate: primera ?? DateTime(hoy.year - 5),
      lastDate: ultima ?? DateTime(hoy.year + 5, 12, 31),
      helpText: etiqueta,
    );
    if (elegida != null) alCambiar(elegida);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final texto = fecha == null ? 'Sin fecha' : fmtFecha(fecha!);
    return InkWell(
      onTap: () => _elegir(context),
      borderRadius: BorderRadius.circular(4),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: etiqueta,
          border: const OutlineInputBorder(),
          prefixIcon: const Icon(Icons.event_outlined),
          suffixIcon: alLimpiar == null || fecha == null
              ? null
              : IconButton(
                  tooltip: 'Quitar la fecha',
                  icon: const Icon(Icons.clear),
                  onPressed: alLimpiar,
                ),
        ),
        child: Text(
          texto,
          style: theme.textTheme.titleMedium?.copyWith(
            color: fecha == null ? theme.colorScheme.outline : null,
          ),
        ),
      ),
    );
  }
}
