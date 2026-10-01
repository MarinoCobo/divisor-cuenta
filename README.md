# Divide la cuenta

App en Flutter para dividir la cuenta del restaurante entre varias personas.

- **Partes iguales:** escribes el total y todos pagan lo mismo.
- **Por consumo:** agregas cada plato o bebida y marcas quiénes lo compartieron; lo compartido se divide entre ellos y la propina se reparte en proporción a lo que consumió cada uno.
- Propina de 0, 10, 15, 20 % u otro porcentaje.
- Los montos cuadran al centavo: el dinero se maneja en centavos enteros y los centavos sobrantes se reparten con el método del mayor residuo.
- Botón para copiar un resumen y pegarlo en el chat del grupo.

## Cómo correrla

```sh
flutter run            # en el emulador o dispositivo conectado
flutter run -d chrome  # en el navegador
flutter test           # pruebas
```

## Estructura

```
lib/
  main.dart                    tema y arranque
  models/bill.dart             Person, BillItem, SplitResult
  logic/money.dart             leer y formatear montos (centavos)
  logic/split_calculator.dart  cálculo del reparto (Dart puro, con tests)
  state/bill_controller.dart   estado de la cuenta (ChangeNotifier)
  screens/home_screen.dart     pantalla principal
  widgets/                     una sección de la pantalla por archivo
```
