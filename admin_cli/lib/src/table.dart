/// Renders rows as a simple fixed-width, pipe-separated table for terminal
/// output (no external table-formatting dependency needed for this small
/// CLI).
String renderTable(List<String> headers, List<List<String>> rows) {
  final widths = List<int>.generate(headers.length, (i) {
    var width = headers[i].length;
    for (final row in rows) {
      if (row[i].length > width) width = row[i].length;
    }
    return width;
  });

  String formatRow(List<String> cells) {
    return cells
        .asMap()
        .entries
        .map((e) => e.value.padRight(widths[e.key]))
        .join(' | ');
  }

  final buffer = StringBuffer()..writeln(formatRow(headers));
  buffer.writeln(widths.map((w) => '-' * w).join('-|-'));
  for (final row in rows) {
    buffer.writeln(formatRow(row));
  }
  return buffer.toString().trimRight();
}
