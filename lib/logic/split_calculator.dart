// Cálculo de la división de la cuenta. No depende de Flutter, así que se
// prueba con tests unitarios simples (ver test/split_calculator_test.dart).

/// Cuánto paga cada persona, en centavos, al dividir [billCents] más un
/// [tipPercent] % de propina entre [people] personas.
///
/// La propina se redondea al centavo más cercano. Si el total no se divide
/// exacto, cada parte se redondea hacia arriba para que entre todos se cubra
/// la cuenta (p. ej. $10.00 entre 3 -> $3.34 cada uno).
int sharePerPerson({
  required int billCents,
  required int people,
  required double tipPercent,
}) {
  assert(people > 0);
  final totalCents = billCents + (billCents * tipPercent / 100).round();
  return (totalCents + people - 1) ~/ people;
}
