import 'package:divisor_cuenta/presentation/divisor_controller.dart';
import 'package:flutter/material.dart';

/// La única pantalla de la app: tres campos, el modo de redondeo, el botón
/// "Calcular" y el resultado.
///
/// Existe solo para dibujar. Toda decisión (qué calcular, qué mostrar) la toma
/// el [DivisorController] que recibe por el constructor.
class PantallaDivisor extends StatefulWidget {
  /// Crea la pantalla con su [controlador], que llega armado desde `main.dart`.
  const PantallaDivisor({super.key, required this.controlador});

  /// Controlador que guarda el estado y coordina el cálculo.
  final DivisorController controlador;

  @override
  State<PantallaDivisor> createState() => _PantallaDivisorState();
}

class _PantallaDivisorState extends State<PantallaDivisor> {
  final _monto = TextEditingController();
  final _personas = TextEditingController();
  final _propina = TextEditingController();

  DivisorController get _controlador => widget.controlador;

  @override
  void dispose() {
    _monto.dispose();
    _personas.dispose();
    _propina.dispose();
    super.dispose();
  }

  void _calcular() {
    setState(() {
      _controlador.calcular(
        monto: _monto.text,
        personas: _personas.text,
        propina: _propina.text,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final resultado = _controlador.resultado;

    return Scaffold(
      appBar: AppBar(title: const Text('Divisor de cuenta')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    key: const Key('campoMonto'),
                    controller: _monto,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Monto total',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    key: const Key('campoPersonas'),
                    controller: _personas,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Número de personas',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    key: const Key('campoPropina'),
                    controller: _propina,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Propina (%)',
                      hintText: '0',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Redondeo', style: tema.textTheme.labelLarge),
                  const SizedBox(height: 8),
                  SegmentedButton<String>(
                    key: const Key('selectorModo'),
                    segments: [
                      for (final modo in _controlador.modos)
                        ButtonSegment(value: modo, label: Text(modo)),
                    ],
                    selected: {_controlador.modoSeleccionado},
                    onSelectionChanged: (seleccion) {
                      setState(
                        () => _controlador.seleccionarModo(seleccion.first),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    key: const Key('botonCalcular'),
                    onPressed: _calcular,
                    child: const Text('Calcular'),
                  ),
                  const SizedBox(height: 24),
                  if (resultado != null) ...[
                    Text(
                      'Cada persona paga',
                      textAlign: TextAlign.center,
                      style: tema.textTheme.titleMedium,
                    ),
                    Text(
                      resultado,
                      key: const Key('resultado'),
                      textAlign: TextAlign.center,
                      style: tema.textTheme.displaySmall,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
