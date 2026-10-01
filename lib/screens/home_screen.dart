import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../logic/money.dart';
import '../logic/split_calculator.dart';

/// Pantalla única: monto, número de personas y propina -> cuánto paga cada uno.
/// El resultado se recalcula mientras se escribe.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _amount = TextEditingController();
  final _people = TextEditingController();
  final _tip = TextEditingController();

  @override
  void dispose() {
    _amount.dispose();
    _people.dispose();
    _tip.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Lee los tres campos. null = vacío o inválido.
    final billCents = parseCents(_amount.text);
    final people = int.tryParse(_people.text);
    final tipPercent = _tip.text.trim().isEmpty ? 0.0 : parsePercent(_tip.text);

    final amountError = _amount.text.trim().isNotEmpty && billCents == null
        ? 'Monto no válido'
        : null;
    final peopleError = people == 0 ? 'Debe ser al menos 1' : null;
    final tipError = tipPercent == null ? 'Entre 0 y 100' : null;

    final shareCents =
        billCents != null && people != null && people > 0 && tipPercent != null
        ? sharePerPerson(
            billCents: billCents,
            people: people,
            tipPercent: tipPercent,
          )
        : null;

    return Scaffold(
      appBar: AppBar(title: const Text('Divide la cuenta')),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // En pantallas anchas el contenido se centra con un ancho máximo.
            final side = math.max(16.0, (constraints.maxWidth - 480) / 2);
            return ListView(
              padding: EdgeInsets.fromLTRB(side, 16, side, 32),
              children: [
                TextField(
                  controller: _amount,
                  autofocus: true,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                  ],
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'Monto total',
                    prefixText: '\$ ',
                    hintText: '0.00',
                    errorText: amountError,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _people,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(3),
                  ],
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'Número de personas',
                    hintText: '2',
                    errorText: peopleError,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _tip,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                  ],
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    labelText: 'Propina',
                    suffixText: '%',
                    hintText: '0',
                    errorText: tipError,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 24),
                _ResultCard(shareCents: shareCents),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.shareCents});

  /// Lo que paga cada uno, o null si faltan datos.
  final int? shareCents;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final shareCents = this.shareCents;

    final List<Widget> content;
    if (shareCents == null) {
      content = [
        Text(
          'Escribe el monto y el número de personas.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colors.onSecondaryContainer,
          ),
        ),
      ];
    } else {
      content = [
        Text(
          'Cada uno paga',
          style: theme.textTheme.titleMedium?.copyWith(
            color: colors.onSecondaryContainer,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          formatCents(shareCents),
          style: theme.textTheme.displayMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colors.onSecondaryContainer,
          ),
        ),
      ];
    }

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: colors.secondaryContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(children: content),
      ),
    );
  }
}
