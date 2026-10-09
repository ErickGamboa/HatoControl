import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/repositories/buscador_de_animales.dart';
import '../teclado/teclado_del_app.dart';

/// Campo del arete con buscador: el ganadero digita unos pocos números del
/// final (o el alias) y escoge el animal de la lista que aparece debajo, sin
/// escribir el arete completo.
///
/// Con el lector no cambia nada: la lectura entra entera por la pantalla
/// (`LectorDeAretes`) sin que el campo tenga el foco, y la lista solo sale
/// mientras se escribe a mano en el campo.
///
/// Como [ScanField], no toma el foco solo y selecciona todo al tocarlo.
class CampoAnimal extends StatefulWidget {
  const CampoAnimal({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.animales,
    required this.labelText,
    this.prefixIcon,
    this.textInputAction = TextInputAction.next,
    this.onSubmitted,
    this.onSeleccionado,
  });

  final TextEditingController controller;
  final FocusNode focusNode;

  /// Los animales que se pueden escoger (los activos de la finca).
  final Stream<List<AnimalBuscable>> animales;
  final String labelText;
  final Widget? prefixIcon;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onSubmitted;

  /// Se escogió un animal de la lista: el campo ya quedó con su arete.
  final ValueChanged<AnimalBuscable>? onSeleccionado;

  @override
  State<CampoAnimal> createState() => _CampoAnimalState();
}

class _CampoAnimalState extends State<CampoAnimal> {
  List<AnimalBuscable> _animales = const [];
  StreamSubscription<List<AnimalBuscable>>? _sub;

  /// Teclado de letras para buscar por alias; el de números es el normal.
  bool _conLetras = false;

  /// Sube al escoger un animal: el buscador se arma de nuevo y olvida la
  /// lista vieja (si no, al volver al campo reaparece la de antes).
  int _generacion = 0;

  void _cambiarTeclado() {
    setState(() => _conLetras = !_conLetras);
    if (!widget.focusNode.hasFocus) widget.focusNode.requestFocus();
    // El teclado propio de la app se redibuja con el tipo nuevo cuando el
    // campo ya se reconstruyó.
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => TecladoDelApp.cambioElTipoDeTeclado(),
    );
  }

  @override
  void initState() {
    super.initState();
    _sub = widget.animales.listen((a) {
      if (mounted) setState(() => _animales = a);
    });
    widget.focusNode.addListener(_seleccionarTodo);
    widget.controller.addListener(_alCambiarTexto);
  }

  @override
  void dispose() {
    _sub?.cancel();
    widget.focusNode.removeListener(_seleccionarTodo);
    widget.controller.removeListener(_alCambiarTexto);
    super.dispose();
  }

  void _seleccionarTodo() {
    final texto = widget.controller.text;
    if (widget.focusNode.hasFocus && texto.isNotEmpty) {
      widget.controller.selection = TextSelection(
        baseOffset: 0,
        extentOffset: texto.length,
      );
    }
  }

  // La línea de ayuda (alias y lote) depende del texto, aunque lo escriba el
  // lector sin foco.
  void _alCambiarTexto() {
    if (mounted) setState(() {});
  }

  /// El animal que es exactamente lo que dice el campo (arete o alias).
  AnimalBuscable? get _exacto {
    final q = normalizarBusqueda(widget.controller.text);
    if (q.isEmpty) return null;
    for (final a in _animales) {
      if (normalizarBusqueda(a.identificador) == q) return a;
    }
    for (final a in _animales) {
      final alias = a.alias;
      if (alias != null && normalizarBusqueda(alias) == q) return a;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final exacto = _exacto;
    final ayuda = exacto == null
        ? null
        : [
            if (exacto.alias != null &&
                exacto.identificador != widget.controller.text.trim())
              exacto.identificador,
            if (exacto.alias != null &&
                exacto.identificador == widget.controller.text.trim())
              exacto.alias!,
            exacto.loteNombre,
          ].join(' · ');

    return LayoutBuilder(
      builder: (context, restricciones) => RawAutocomplete<AnimalBuscable>(
        key: ValueKey(_generacion),
        textEditingController: widget.controller,
        focusNode: widget.focusNode,
        displayStringForOption: (a) => a.identificador,
        optionsBuilder: (valor) {
          final lista = sugerencias(_animales, valor.text);
          // Si lo digitado ya es exactamente un animal, no hace falta lista.
          if (lista.length == 1 &&
              normalizarBusqueda(lista.single.identificador) ==
                  normalizarBusqueda(valor.text)) {
            return const [];
          }
          return lista;
        },
        onSelected: (a) {
          setState(() => _generacion++);
          widget.controller.selection = TextSelection.collapsed(
            offset: widget.controller.text.length,
          );
          widget.onSeleccionado?.call(a);
        },
        fieldViewBuilder: (context, controller, focusNode, alEnviar) =>
            TextField(
              controller: controller,
              focusNode: focusNode,
              keyboardType: _conLetras
                  ? TextInputType.text
                  : TextInputType.number,
              textCapitalization: TextCapitalization.words,
              inputFormatters: _conLetras
                  ? null
                  : [FilteringTextInputFormatter.digitsOnly],
              textInputAction: widget.textInputAction,
              onSubmitted: widget.onSubmitted,
              style: const TextStyle(fontSize: 20),
              decoration: InputDecoration(
                labelText: widget.labelText,
                prefixIcon: widget.prefixIcon,
                border: const OutlineInputBorder(),
                helperText: ayuda,
                helperStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
                suffixIcon: TextButton(
                  key: const ValueKey('campoAnimal.teclado'),
                  onPressed: _cambiarTeclado,
                  child: Text(_conLetras ? '123' : 'ABC'),
                ),
              ),
            ),
        optionsViewBuilder: (context, alEscoger, opciones) => Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 6,
            borderRadius: BorderRadius.circular(12),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: restricciones.maxWidth,
                maxHeight: 280,
              ),
              child: ListView.separated(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: opciones.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final a = opciones.elementAt(i);
                  return ListTile(
                    key: ValueKey('campoAnimal.opcion.${a.identificador}'),
                    title: Text(
                      a.identificador,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      [if (a.alias != null) a.alias!, a.loteNombre].join(' · '),
                    ),
                    onTap: () => alEscoger(a),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
