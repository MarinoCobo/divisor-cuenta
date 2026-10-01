// Utilidades de dinero.
//
// Todo el dinero de la app se guarda como centavos enteros (int) para evitar
// los errores de redondeo de los double (0.1 + 0.2 != 0.3).

/// Convierte lo que escribe el usuario ("12,5", "$ 12.50", "1.234,56") a
/// centavos. Devuelve null si el texto está vacío o no es un monto válido.
int? parseCents(String input) {
  var text = input.replaceAll(RegExp(r'[\s$]'), '');
  if (text.isEmpty) return null;

  // Se acepta coma o punto como separador decimal. Si aparecen los dos, el
  // último es el decimal y los demás son separadores de miles.
  final lastSeparator = text.lastIndexOf(RegExp(r'[.,]'));
  if (lastSeparator != -1) {
    final integerPart = text
        .substring(0, lastSeparator)
        .replaceAll(RegExp(r'[.,]'), '');
    final decimalPart = text.substring(lastSeparator + 1);
    text = '$integerPart.$decimalPart';
  }

  final match = RegExp(r'^(\d*)(?:\.(\d{0,2}))?$').firstMatch(text);
  if (match == null) return null;
  final units = match.group(1)!;
  final decimals = match.group(2) ?? '';
  if (units.isEmpty && decimals.isEmpty) return null;

  return int.parse(units.isEmpty ? '0' : units) * 100 +
      int.parse(decimals.padRight(2, '0'));
}

/// Formatea centavos como dólares: 123456 -> "$1,234.56".
String formatCents(int cents) {
  final sign = cents < 0 ? '-' : '';
  final abs = cents.abs();
  final units = (abs ~/ 100).toString();
  final decimals = (abs % 100).toString().padLeft(2, '0');

  final grouped = StringBuffer();
  for (var i = 0; i < units.length; i++) {
    if (i > 0 && (units.length - i) % 3 == 0) grouped.write(',');
    grouped.write(units[i]);
  }
  return '$sign\$$grouped.$decimals';
}

/// Versión para rellenar un campo de texto editable: 1250 -> "12.50".
String centsToInput(int cents) =>
    '${cents ~/ 100}.${(cents % 100).toString().padLeft(2, '0')}';

/// Porcentaje legible: 10.0 -> "10 %", 12.5 -> "12.5 %".
String formatPercent(double percent) {
  final text = percent == percent.roundToDouble()
      ? percent.toStringAsFixed(0)
      : percent.toString();
  return '$text %';
}

/// Lee un porcentaje escrito por el usuario ("12,5" o "12.5"). Devuelve null
/// si no es un número entre 0 y 100.
double? parsePercent(String input) {
  final value = double.tryParse(
    input.trim().replaceAll(',', '.').replaceAll('%', ''),
  );
  if (value == null || value < 0 || value > 100) return null;
  return value;
}
