import 'package:flutter/material.dart';

import '../data/local/database.dart';
import '../data/repositories/pesajes_repository.dart';
import '../services.dart';

/// Historial de pesajes de un animal: fecha, peso, aumento vs. el pesaje
/// anterior y aumento por día. Arriba muestra el aumento total del animal.
class AnimalHistorialScreen extends StatelessWidget {
  const AnimalHistorialScreen({super.key, required this.animal});

  final AnimalRow animal;

  static const _verde = Color(0xFF2E7D32);
  static const _rojo = Color(0xFFC62828);

  String _fmt(double p) {
    final abs = p.abs();
    return abs == abs.roundToDouble()
        ? abs.toInt().toString()
        : abs.toStringAsFixed(1);
  }

  String _fecha(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text('Animal ${animal.identificador}')),
      body: StreamBuilder<List<PesajeHistorial>>(
        stream: pesajesRepo.observarHistorial(animal.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final historial = snapshot.data ?? const [];
          if (historial.isEmpty) {
            return Center(
              child: Text('Este animal no tiene pesajes.',
                  style: theme.textTheme.bodyLarge
                      ?.copyWith(color: theme.colorScheme.outline)),
            );
          }

          // Aumento total = último peso - primer peso.
          final total = historial.last.peso - historial.first.peso;
          // Mostrar el más reciente arriba.
          final filas = historial.reversed.toList();

          return Column(
            children: [
              // Resumen: aumento total
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Aumento total desde que llegó',
                        style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer)),
                    const SizedBox(height: 4),
                    Text(
                      '${total >= 0 ? '+' : '-'}${_fmt(total)} kg',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: total >= 0 ? _verde : _rojo,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Peso actual: ${_fmt(historial.last.peso)} kg · '
                      '${historial.length} pesaje(s)',
                      style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer),
                    ),
                  ],
                ),
              ),
              // Encabezado de la tabla
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                color: theme.colorScheme.surfaceContainerHighest,
                child: Row(
                  children: [
                    Expanded(
                        flex: 4,
                        child: Text('Fecha',
                            style: theme.textTheme.labelLarge
                                ?.copyWith(fontWeight: FontWeight.bold))),
                    Expanded(
                        flex: 3,
                        child: Text('Peso',
                            textAlign: TextAlign.end,
                            style: theme.textTheme.labelLarge
                                ?.copyWith(fontWeight: FontWeight.bold))),
                    Expanded(
                        flex: 3,
                        child: Text('Aumento',
                            textAlign: TextAlign.end,
                            style: theme.textTheme.labelLarge
                                ?.copyWith(fontWeight: FontWeight.bold))),
                    Expanded(
                        flex: 3,
                        child: Text('kg/día',
                            textAlign: TextAlign.end,
                            style: theme.textTheme.labelLarge
                                ?.copyWith(fontWeight: FontWeight.bold))),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  itemCount: filas.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final p = filas[i];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 4,
                            child: Text(_fecha(p.fecha),
                                style: const TextStyle(fontSize: 15)),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text('${_fmt(p.peso)} kg',
                                textAlign: TextAlign.end,
                                style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600)),
                          ),
                          Expanded(
                              flex: 3,
                              child: _Valor(valor: p.ganancia, entrada: true)),
                          Expanded(
                              flex: 3,
                              child: _Valor(
                                  valor: p.gananciaDiaria, entrada: false)),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Valor coloreado: verde si sube, rojo si baja, "Entrada"/"—" si no aplica.
class _Valor extends StatelessWidget {
  const _Valor({required this.valor, required this.entrada});

  final double? valor;
  final bool entrada; // si true y valor null → "Entrada"; si no → "—"

  String _fmt(double p) {
    final abs = p.abs();
    return abs == abs.roundToDouble()
        ? abs.toInt().toString()
        : abs.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (valor == null) {
      return Text(entrada ? 'Entrada' : '—',
          textAlign: TextAlign.end,
          style: TextStyle(fontSize: 14, color: theme.colorScheme.outline));
    }
    const verde = Color(0xFF2E7D32);
    const rojo = Color(0xFFC62828);
    final v = valor!;
    final color = v > 0
        ? verde
        : v < 0
            ? rojo
            : theme.colorScheme.outline;
    final signo = v > 0 ? '+' : v < 0 ? '-' : '';
    return Text(
      '$signo${_fmt(v)} kg',
      textAlign: TextAlign.end,
      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: color),
    );
  }
}
