import 'package:divisor_cuenta/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> addPerson(WidgetTester tester, String name) async {
  await tester.enterText(find.widgetWithText(TextField, 'Nombre'), name);
  await tester.tap(find.byTooltip('Agregar persona'));
  await tester.pump();
}

void main() {
  // Pantalla alta para que todas las secciones de la lista se construyan.
  Future<void> pumpApp(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 4000);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const DivisorCuentaApp());
  }

  testWidgets('partes iguales: divide el total más la propina', (tester) async {
    await pumpApp(tester);
    expect(find.text('Agrega personas para ver el reparto.'), findsOneWidget);

    await addPerson(tester, 'Ana');
    await addPerson(tester, 'Luis');
    await addPerson(tester, ''); // nombre automático
    expect(find.text('Persona 3'), findsWidgets);

    await tester.enterText(
      find.widgetWithText(TextField, 'Total sin propina'),
      '30',
    );
    await tester.pump();

    // 30 + 10 % = 33 -> 11 c/u
    expect(find.text(r'$11.00'), findsNWidgets(3));
    expect(find.text(r'$33.00'), findsOneWidget);

    await tester.tap(find.text('0 %'));
    await tester.pump();
    expect(find.text(r'$10.00'), findsNWidgets(3));
  });

  testWidgets('por consumo: asigna un consumo a una persona', (tester) async {
    await pumpApp(tester);
    await addPerson(tester, 'Ana');
    await addPerson(tester, 'Luis');

    await tester.tap(find.text('Por consumo'));
    await tester.pump();
    await tester.tap(find.text('Agregar consumo'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextField, 'Descripción'),
      'Pizza',
    );
    await tester.enterText(find.widgetWithText(TextField, 'Precio'), '20');
    // Sin elegir personas no deja guardar.
    await tester.tap(find.widgetWithText(FilledButton, 'Agregar'));
    await tester.pump();
    expect(find.text('Elige al menos una persona'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilterChip, 'Ana'));
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Agregar'));
    await tester.pumpAndSettle();

    expect(find.text('Pizza'), findsOneWidget);
    // Ana: 20 + 10 % = 22; Luis: 0
    expect(find.text(r'$22.00'), findsNWidgets(2)); // Ana y total
    expect(find.text(r'$0.00'), findsOneWidget);

    // Quitar a Ana deja el consumo sin asignar y muestra el aviso.
    await tester.tap(find.byTooltip('Quitar').first);
    await tester.pump();
    expect(find.textContaining('sin asignar'), findsOneWidget);
    expect(find.text('Sin asignar'), findsOneWidget);
  });

  testWidgets('empezar de nuevo borra todo', (tester) async {
    await pumpApp(tester);
    await addPerson(tester, 'Ana');
    await tester.enterText(
      find.widgetWithText(TextField, 'Total sin propina'),
      '15',
    );
    await tester.pump();

    await tester.tap(find.byTooltip('Empezar de nuevo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Borrar todo'));
    await tester.pumpAndSettle();

    expect(find.text('Ana'), findsNothing);
    expect(find.text('Agrega a quienes van a pagar.'), findsOneWidget);
    final total = tester.widget<TextField>(
      find.widgetWithText(TextField, 'Total sin propina'),
    );
    expect(total.controller!.text, isEmpty);
  });
}
