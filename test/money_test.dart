import 'package:divisor_cuenta/logic/money.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('parseCents', () {
    test('acepta punto o coma como separador decimal', () {
      expect(parseCents('12.50'), 1250);
      expect(parseCents('12,5'), 1250);
      expect(parseCents('12'), 1200);
      expect(parseCents('0.05'), 5);
      expect(parseCents(',99'), 99);
    });

    test('ignora el signo de dólar, espacios y separadores de miles', () {
      expect(parseCents(r'$ 1,234.56'), 123456);
      expect(parseCents('1.234,56'), 123456);
    });

    test('rechaza textos vacíos o inválidos', () {
      expect(parseCents(''), isNull);
      expect(parseCents('  '), isNull);
      expect(parseCents('.'), isNull);
      expect(parseCents('12.345'), isNull);
      expect(parseCents('abc'), isNull);
    });
  });

  test('formatCents', () {
    expect(formatCents(0), r'$0.00');
    expect(formatCents(5), r'$0.05');
    expect(formatCents(123456), r'$1,234.56');
    expect(formatCents(100000000), r'$1,000,000.00');
  });

  test('parsePercent', () {
    expect(parsePercent('10'), 10);
    expect(parsePercent('12,5'), 12.5);
    expect(parsePercent('101'), isNull);
    expect(parsePercent('-1'), isNull);
    expect(parsePercent('abc'), isNull);
  });
}
