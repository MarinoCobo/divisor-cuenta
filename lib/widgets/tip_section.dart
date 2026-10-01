import 'package:flutter/material.dart';

import '../logic/money.dart';
import '../state/bill_controller.dart';
import 'common.dart';

/// Porcentaje de propina: atajos de 0/10/15/20 % u otro valor.
class TipSection extends StatelessWidget {
  const TipSection({super.key, required this.bill});

  final BillController bill;

  Future<void> _askCustom(BuildContext context) async {
    final text = await showTextInputDialog(
      context,
      title: 'Otra propina',
      label: 'Porcentaje',
      suffixText: '%',
      initialValue: formatPercent(bill.tipPercent).replaceAll(' %', ''),
      keyboardType: moneyKeyboard,
      inputFormatters: moneyInputFormatters,
      validator: (v) => parsePercent(v) == null ? 'Entre 0 y 100' : null,
    );
    final percent = text == null ? null : parsePercent(text);
    if (percent != null) bill.setTipPercent(percent);
  }

  @override
  Widget build(BuildContext context) {
    final tip = bill.tipPercent;
    final isCustom = !BillController.tipPresets.contains(tip);

    return SectionCard(
      title: 'Propina / servicio',
      icon: Icons.volunteer_activism_outlined,
      trailing: Text(
        formatCents(bill.result.tipCents),
        style: Theme.of(context).textTheme.titleMedium,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final preset in BillController.tipPresets)
                ChoiceChip(
                  label: Text(formatPercent(preset)),
                  selected: tip == preset,
                  onSelected: (_) => bill.setTipPercent(preset),
                ),
              ChoiceChip(
                label: Text(isCustom ? 'Otro: ${formatPercent(tip)}' : 'Otro'),
                selected: isCustom,
                onSelected: (_) => _askCustom(context),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const HintText(
            'Si la cuenta ya trae el 10 % de servicio incluido, elige 0 %.',
          ),
        ],
      ),
    );
  }
}
