/// Buscador de animales por arete o por alias.
///
/// Sin lector, digitar un arete de 15 dígitos en la manga es lento y se
/// equivoca uno. Con unos pocos dígitos del final, o con el alias, el
/// buscador ofrece los animales que calzan y el ganadero escoge.
library;

/// Lo mínimo de un animal para ofrecerlo en el buscador.
class AnimalBuscable {
  const AnimalBuscable({
    required this.id,
    required this.identificador,
    required this.alias,
    required this.loteNombre,
  });

  final String id;
  final String identificador;

  /// null = no tiene alias.
  final String? alias;
  final String loteNombre;
}

/// El alias tal como se guarda: sin espacios de más; vacío cuenta como sin
/// alias.
String? limpiarAlias(String? alias) {
  final a = alias?.trim().replaceAll(RegExp(r'\s+'), ' ');
  return (a == null || a.isEmpty) ? null : a;
}

/// Para comparar sin que importen mayúsculas, tildes ni espacios.
String normalizarBusqueda(String texto) {
  const conTilde = 'áàäâéèëêíìïîóòöôúùüûñ';
  const sinTilde = 'aaaaeeeeiiiioooouuuun';
  final b = StringBuffer();
  for (final c in texto.trim().toLowerCase().split('')) {
    final i = conTilde.indexOf(c);
    if (c == ' ') continue;
    b.write(i == -1 ? c : sinTilde[i]);
  }
  return b.toString();
}

/// Si un animal calza con lo que se digitó. Calza si el arete o el alias
/// contienen el texto (sin importar mayúsculas ni tildes).
bool calzaConBusqueda(String texto, String identificador, String? alias) {
  final q = normalizarBusqueda(texto);
  if (q.isEmpty) return true;
  if (normalizarBusqueda(identificador).contains(q)) return true;
  final a = limpiarAlias(alias);
  return a != null && normalizarBusqueda(a).contains(q);
}

/// Los animales que calzan con [texto], los más probables primero:
/// 1. arete o alias exactos;
/// 2. arete que termina en lo digitado (lo normal: los últimos dígitos) o
///    alias que empieza con eso;
/// 3. arete o alias que lo contienen.
///
/// Con menos de [minimo] caracteres no se sugiere nada: un solo dígito calza
/// con media finca.
List<AnimalBuscable> sugerencias(
  Iterable<AnimalBuscable> animales,
  String texto, {
  int limite = 8,
  int minimo = 2,
}) {
  final q = normalizarBusqueda(texto);
  if (q.length < minimo) return const [];
  final conPuntaje = <(int, AnimalBuscable)>[];
  for (final a in animales) {
    final ident = normalizarBusqueda(a.identificador);
    final alias = limpiarAlias(a.alias);
    final al = alias == null ? null : normalizarBusqueda(alias);
    final int? puntaje;
    if (ident == q || al == q) {
      puntaje = 0;
    } else if (ident.endsWith(q) || (al != null && al.startsWith(q))) {
      puntaje = 1;
    } else if (ident.contains(q) || (al != null && al.contains(q))) {
      puntaje = 2;
    } else {
      puntaje = null;
    }
    if (puntaje != null) conPuntaje.add((puntaje, a));
  }
  conPuntaje.sort((x, y) {
    final p = x.$1.compareTo(y.$1);
    return p != 0 ? p : x.$2.identificador.compareTo(y.$2.identificador);
  });
  return [for (final c in conPuntaje.take(limite)) c.$2];
}

/// El alias ya lo usa otro animal activo de la finca (o es el arete de otro).
class AliasEnUsoException implements Exception {
  AliasEnUsoException(this.alias, this.identificadorDelOtro);
  final String alias;
  final String identificadorDelOtro;

  String get mensaje =>
      'El alias "$alias" ya lo tiene el animal $identificadorDelOtro.';

  @override
  String toString() => mensaje;
}
