# Divide la cuenta

App en Flutter de una sola pantalla para dividir la cuenta en partes iguales:
escribes el monto total, el número de personas y el porcentaje de propina, y
te dice cuánto paga cada uno.

Si el total no se divide exacto, el monto por persona se redondea hacia arriba
al centavo para que entre todos se cubra la cuenta.

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
  screens/home_screen.dart     la pantalla
  logic/money.dart             leer y formatear montos (en centavos)
  logic/split_calculator.dart  cálculo de la división (Dart puro, con tests)
```
