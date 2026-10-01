import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/bill.dart';
import '../state/bill_controller.dart';
import '../widgets/equal_total_section.dart';
import '../widgets/items_section.dart';
import '../widgets/people_section.dart';
import '../widgets/results_section.dart';
import '../widgets/tip_section.dart';

/// Pantalla única de la app. Crea el BillController y lo pasa a cada sección.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _bill = BillController();

  @override
  void dispose() {
    _bill.dispose();
    super.dispose();
  }

  Future<void> _confirmReset() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Empezar de nuevo?'),
        content: const Text(
          'Se borrarán las personas, los consumos y el total.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Borrar todo'),
          ),
        ],
      ),
    );
    if (confirmed == true) _bill.reset();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Divide la cuenta'),
        actions: [
          IconButton(
            onPressed: _confirmReset,
            tooltip: 'Empezar de nuevo',
            icon: const Icon(Icons.restart_alt),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // En pantallas anchas (tablet, web) el contenido se centra con un
            // ancho máximo para que no quede estirado.
            final sidePadding = math.max(
              16.0,
              (constraints.maxWidth - 640) / 2,
            );
            return ListenableBuilder(
              listenable: _bill,
              builder: (context, _) => ListView(
                padding: EdgeInsets.fromLTRB(sidePadding, 8, sidePadding, 32),
                children: [
                  _ModeSelector(bill: _bill),
                  const SizedBox(height: 16),
                  PeopleSection(
                    key: ValueKey('people-${_bill.resetCount}'),
                    bill: _bill,
                  ),
                  const SizedBox(height: 16),
                  if (_bill.mode == SplitMode.equal)
                    EqualTotalSection(
                      key: ValueKey('total-${_bill.resetCount}'),
                      bill: _bill,
                    )
                  else
                    ItemsSection(bill: _bill),
                  const SizedBox(height: 16),
                  TipSection(bill: _bill),
                  const SizedBox(height: 16),
                  ResultsSection(bill: _bill),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ModeSelector extends StatelessWidget {
  const _ModeSelector({required this.bill});

  final BillController bill;

  @override
  Widget build(BuildContext context) {
    final explanation = switch (bill.mode) {
      SplitMode.equal => 'Todos pagan lo mismo.',
      SplitMode.itemized =>
        'Cada quien paga lo que consumió. Lo compartido se divide entre '
            'quienes lo compartieron y la propina, en proporción al consumo.',
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SegmentedButton<SplitMode>(
          segments: const [
            ButtonSegment(
              value: SplitMode.equal,
              icon: Icon(Icons.balance),
              label: Text('Partes iguales'),
            ),
            ButtonSegment(
              value: SplitMode.itemized,
              icon: Icon(Icons.restaurant_menu),
              label: Text('Por consumo'),
            ),
          ],
          selected: {bill.mode},
          onSelectionChanged: (selection) => bill.setMode(selection.first),
        ),
        const SizedBox(height: 8),
        Text(
          explanation,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}
