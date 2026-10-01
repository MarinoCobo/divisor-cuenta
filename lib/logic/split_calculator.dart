// Lógica pura para dividir la cuenta. No depende de Flutter, así que se puede
// probar con tests unitarios simples (ver test/split_calculator_test.dart).

import '../models/bill.dart';

/// Propina en centavos para un subtotal y un porcentaje, redondeada al
/// centavo más cercano.
int tipFor(int subtotalCents, double tipPercent) =>
    (subtotalCents * tipPercent / 100).round();

/// Reparte [totalCents] en partes proporcionales a [weights] y garantiza que
/// la suma de las partes sea exactamente [totalCents].
///
/// Usa el método del "mayor residuo": cada parte se redondea hacia abajo y los
/// centavos sobrantes se entregan a quienes tenían la parte decimal más
/// grande. Así nunca se pierde ni aparece un centavo de la nada.
List<int> apportion(int totalCents, List<double> weights) {
  if (weights.isEmpty) return const [];

  final weightSum = weights.fold<double>(0, (a, b) => a + b);
  // Sin pesos (p. ej. nadie consumió nada) se reparte en partes iguales.
  final effective = weightSum > 0
      ? weights
      : List<double>.filled(weights.length, 1);
  final effectiveSum = weightSum > 0 ? weightSum : weights.length.toDouble();

  final ideal = [for (final w in effective) totalCents * w / effectiveSum];
  final shares = [for (final x in ideal) x.floor()];

  var leftover = totalCents - shares.fold<int>(0, (a, b) => a + b);
  // Índices ordenados por parte decimal descendente; en empate, por orden.
  final order = List<int>.generate(shares.length, (i) => i)
    ..sort((a, b) {
      final byRemainder = (ideal[b] - shares[b]).compareTo(
        ideal[a] - shares[a],
      );
      return byRemainder != 0 ? byRemainder : a.compareTo(b);
    });
  for (var i = 0; leftover > 0; i = (i + 1) % order.length, leftover--) {
    shares[order[i]]++;
  }
  return shares;
}

/// Modo "partes iguales": un total y todas las personas pagan lo mismo.
SplitResult splitEqually({
  required List<Person> people,
  required int subtotalCents,
  required double tipPercent,
}) {
  if (people.isEmpty) {
    return const SplitResult(shares: [], subtotalCents: 0, tipCents: 0);
  }
  final tipCents = tipFor(subtotalCents, tipPercent);
  return SplitResult(
    shares: _buildShares(
      people,
      subtotalCents,
      tipCents,
      List<double>.filled(people.length, 1),
    ),
    subtotalCents: subtotalCents,
    tipCents: tipCents,
  );
}

/// Modo "por consumo": cada consumo se divide entre quienes lo compartieron y
/// la propina se reparte en proporción a lo que consumió cada uno.
SplitResult splitByItems({
  required List<Person> people,
  required List<BillItem> items,
  required double tipPercent,
}) {
  final indexById = {for (var i = 0; i < people.length; i++) people[i].id: i};
  final exactConsumption = List<double>.filled(people.length, 0);
  var assignedCents = 0;
  var unassignedCents = 0;

  for (final item in items) {
    final sharers = item.sharedBy.where(indexById.containsKey).toList();
    if (sharers.isEmpty) {
      unassignedCents += item.priceCents;
      continue;
    }
    assignedCents += item.priceCents;
    for (final id in sharers) {
      exactConsumption[indexById[id]!] += item.priceCents / sharers.length;
    }
  }

  final tipCents = tipFor(assignedCents, tipPercent);
  return SplitResult(
    // Se redondea una sola vez al final (no ítem por ítem) para que los
    // centavos sobrantes no le caigan siempre a la misma persona.
    shares: _buildShares(people, assignedCents, tipCents, exactConsumption),
    subtotalCents: assignedCents,
    tipCents: tipCents,
    unassignedCents: unassignedCents,
  );
}

/// Arma lo que paga cada persona. Lo importante es el total de cada una, así
/// que se reparte primero el total (consumo + propina) y la propina de cada
/// persona es la diferencia con su consumo. De este modo nadie paga más de un
/// centavo por encima de lo exacto.
List<PersonShare> _buildShares(
  List<Person> people,
  int subtotalCents,
  int tipCents,
  List<double> weights,
) {
  final totals = apportion(subtotalCents + tipCents, weights);
  final consumption = apportion(subtotalCents, weights);
  final tips = [
    for (var i = 0; i < people.length; i++) totals[i] - consumption[i],
  ];

  // Con propinas de muy pocos centavos, los redondeos pueden dejar a alguien
  // con propina de -1. Se corrige moviendo un centavo de consumo a otra
  // persona que sí tenga propina; los totales no cambian.
  for (var i = 0; i < tips.length; i++) {
    while (tips[i] < 0) {
      final j = tips.indexWhere((t) => t > 0);
      consumption[i]--;
      tips[i]++;
      consumption[j]++;
      tips[j]--;
    }
  }

  return [
    for (var i = 0; i < people.length; i++)
      PersonShare(
        person: people[i],
        consumptionCents: consumption[i],
        tipCents: tips[i],
      ),
  ];
}
