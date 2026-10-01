import 'package:divisor_cuenta/logic/split_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('divide el total más la propina en partes iguales', () {
    // $30 + 10 % = $33 entre 3
    expect(sharePerPerson(billCents: 3000, people: 3, tipPercent: 10), 1100);
  });

  test('sin propina', () {
    expect(sharePerPerson(billCents: 2500, people: 2, tipPercent: 0), 1250);
  });

  test('si no divide exacto, redondea hacia arriba para cubrir la cuenta', () {
    // $47.80 + 10 % = $52.58 entre 3 = $17.5266... -> $17.53
    expect(sharePerPerson(billCents: 4780, people: 3, tipPercent: 10), 1753);
    // $10.00 entre 3 -> $3.34
    expect(sharePerPerson(billCents: 1000, people: 3, tipPercent: 0), 334);
  });

  test('la propina se redondea al centavo más cercano', () {
    // 12.5 % de $10.01 = $1.25125 -> $1.25; total $11.26
    expect(sharePerPerson(billCents: 1001, people: 1, tipPercent: 12.5), 1126);
  });
}
