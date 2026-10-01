import 'package:divisor_cuenta/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Finder field(String label) => find.widgetWithText(TextField, label);

void main() {
  testWidgets('calcula cuánto paga cada uno mientras se escribe', (
    tester,
  ) async {
    await tester.pumpWidget(const DivisorCuentaApp());
    expect(
      find.text('Escribe el monto y el número de personas.'),
      findsOneWidget,
    );

    await tester.enterText(field('Monto total'), '30');
    await tester.enterText(field('Número de personas'), '3');
    await tester.pump();
    expect(find.text(r'$10.00'), findsOneWidget); // propina vacía = 0 %

    await tester.enterText(field('Propina'), '10');
    await tester.pump();
    expect(find.text('Cada uno paga'), findsOneWidget);
    expect(find.text(r'$11.00'), findsOneWidget);
  });

  testWidgets('redondea hacia arriba cuando no divide exacto', (tester) async {
    await tester.pumpWidget(const DivisorCuentaApp());
    await tester.enterText(field('Monto total'), '47,80');
    await tester.enterText(field('Número de personas'), '3');
    await tester.enterText(field('Propina'), '10');
    await tester.pump();

    expect(find.text(r'$17.53'), findsOneWidget);
  });

  testWidgets('muestra errores con datos inválidos', (tester) async {
    await tester.pumpWidget(const DivisorCuentaApp());
    await tester.enterText(field('Monto total'), '12.345');
    await tester.enterText(field('Número de personas'), '0');
    await tester.enterText(field('Propina'), '150');
    await tester.pump();

    expect(find.text('Monto no válido'), findsOneWidget);
    expect(find.text('Debe ser al menos 1'), findsOneWidget);
    expect(find.text('Entre 0 y 100'), findsOneWidget);
    expect(find.text('Cada uno paga'), findsNothing);
  });
}
