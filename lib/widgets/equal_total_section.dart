import 'package:flutter/material.dart';

import '../logic/money.dart';
import '../state/bill_controller.dart';
import 'common.dart';

/// Modo "partes iguales": un solo campo con el total de la cuenta.
class EqualTotalSection extends StatefulWidget {
  const EqualTotalSection({super.key, required this.bill});

  final BillController bill;

  @override
  State<EqualTotalSection> createState() => _EqualTotalSectionState();
}

class _EqualTotalSectionState extends State<EqualTotalSection> {
  late final _total = TextEditingController(
    text: widget.bill.equalSubtotalCents > 0
        ? centsToInput(widget.bill.equalSubtotalCents)
        : '',
  );
  bool _invalid = false;

  @override
  void dispose() {
    _total.dispose();
    super.dispose();
  }

  void _onChanged(String text) {
    final cents = parseCents(text);
    setState(() => _invalid = text.trim().isNotEmpty && cents == null);
    widget.bill.setEqualSubtotal(cents ?? 0);
  }

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Total de la cuenta',
      icon: Icons.receipt_outlined,
      child: TextField(
        controller: _total,
        keyboardType: moneyKeyboard,
        inputFormatters: moneyInputFormatters,
        style: Theme.of(context).textTheme.titleLarge,
        decoration: InputDecoration(
          labelText: 'Total sin propina',
          prefixText: '\$ ',
          hintText: '0.00',
          errorText: _invalid ? 'Monto no válido' : null,
        ),
        onChanged: _onChanged,
      ),
    );
  }
}
