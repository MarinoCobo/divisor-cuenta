import 'package:divisor_cuenta/logic/split_calculator.dart';
import 'package:divisor_cuenta/models/bill.dart';
import 'package:flutter_test/flutter_test.dart';

const ana = Person(id: 1, name: 'Ana');
const luis = Person(id: 2, name: 'Luis');
const sofia = Person(id: 3, name: 'Sofía');

BillItem item(int id, int cents, Set<int> sharedBy) => BillItem(
  id: id,
  description: 'Item $id',
  priceCents: cents,
  sharedBy: sharedBy,
);

int sum(Iterable<int> xs) => xs.fold(0, (a, b) => a + b);

void main() {
  group('apportion', () {
    test('la suma siempre es exacta y nadie se aleja más de un centavo', () {
      final parts = apportion(1000, [1, 1, 1]);
      expect(parts, [334, 333, 333]);
      expect(sum(parts), 1000);
    });

    test('reparte en proporción a los pesos', () {
      expect(apportion(100, [3, 1]), [75, 25]);
    });

    test('con pesos en cero reparte en partes iguales', () {
      expect(apportion(10, [0, 0]), [5, 5]);
    });

    test('lista vacía', () {
      expect(apportion(100, []), isEmpty);
    });
  });

  group('splitEqually', () {
    test('divide total y propina entre todos', () {
      final r = splitEqually(
        people: [ana, luis, sofia],
        subtotalCents: 3000,
        tipPercent: 10,
      );
      expect(r.tipCents, 300);
      expect(r.totalCents, 3300);
      expect(r.shares.map((s) => s.totalCents), [1100, 1100, 1100]);
      expect(r.shares.map((s) => s.consumptionCents), [1000, 1000, 1000]);
    });

    test('los totales por persona difieren como mucho en un centavo', () {
      final r = splitEqually(
        people: [ana, luis, sofia],
        subtotalCents: 1000,
        tipPercent: 10,
      );
      final totals = r.shares.map((s) => s.totalCents).toList();
      expect(sum(totals), 1100);
      expect(
        totals.reduce((a, b) => a > b ? a : b) -
            totals.reduce((a, b) => a < b ? a : b),
        lessThanOrEqualTo(1),
      );
      expect(r.shares.every((s) => s.tipCents >= 0), isTrue);
    });

    test('sin personas no hay reparto', () {
      final r = splitEqually(people: [], subtotalCents: 1000, tipPercent: 10);
      expect(r.shares, isEmpty);
      expect(r.totalCents, 0);
    });
  });

  group('splitByItems', () {
    test('cada quien paga lo suyo y lo compartido se divide', () {
      final r = splitByItems(
        people: [ana, luis, sofia],
        items: [
          item(10, 1200, {1}), // Ana: 12.00
          item(11, 800, {2}), // Luis: 8.00
          item(12, 900, {1, 2, 3}), // Entrada compartida: 3.00 c/u
        ],
        tipPercent: 10,
      );
      expect(r.subtotalCents, 2900);
      expect(r.tipCents, 290);
      expect(r.shares.map((s) => s.consumptionCents), [1500, 1100, 300]);
      expect(r.shares.map((s) => s.tipCents), [150, 110, 30]);
      expect(r.shares.map((s) => s.totalCents), [1650, 1210, 330]);
    });

    test('los centavos sobrantes no le caen siempre a la misma persona', () {
      // Tres consumos de $1.00 compartidos por tres: cada uno paga $1.00.
      final r = splitByItems(
        people: [ana, luis, sofia],
        items: [
          for (var i = 0; i < 3; i++) item(10 + i, 100, {1, 2, 3}),
        ],
        tipPercent: 0,
      );
      expect(r.shares.map((s) => s.totalCents), [100, 100, 100]);
    });

    test('los consumos sin asignar quedan aparte', () {
      final r = splitByItems(
        people: [ana, luis],
        items: [
          item(10, 1000, {1}),
          item(11, 500, {}),
          item(12, 700, {99}), // persona que ya no existe
        ],
        tipPercent: 10,
      );
      expect(r.unassignedCents, 1200);
      expect(r.subtotalCents, 1000);
      expect(r.shares.map((s) => s.totalCents), [1100, 0]);
    });

    test('la suma de lo que paga cada uno siempre cuadra con el total', () {
      for (var price = 1; price < 400; price += 7) {
        for (final tip in <double>[0, 10, 12.5, 15]) {
          final r = splitByItems(
            people: [ana, luis, sofia],
            items: [
              item(10, price, {1, 2, 3}),
              item(11, price * 2 + 1, {1, 3}),
              item(12, price + 3, {2}),
            ],
            tipPercent: tip,
          );
          expect(sum(r.shares.map((s) => s.totalCents)), r.totalCents);
          expect(sum(r.shares.map((s) => s.tipCents)), r.tipCents);
          expect(
            r.shares.every((s) => s.tipCents >= 0 && s.consumptionCents >= 0),
            isTrue,
          );
        }
      }
    });
  });
}
