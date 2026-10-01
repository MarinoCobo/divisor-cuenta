import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../logic/money.dart';
import '../state/bill_controller.dart';
import 'common.dart';

/// Lo que paga cada persona, los totales y el botón para copiar el resumen.
class ResultsSection extends StatelessWidget {
  const ResultsSection({super.key, required this.bill});

  final BillController bill;

  Future<void> _copySummary(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: bill.summaryText()));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Resumen copiado. Pégalo en el chat del grupo.'),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final result = bill.result;

    return SectionCard(
      title: 'Cuánto paga cada uno',
      icon: Icons.payments_outlined,
      child: result.shares.isEmpty
          ? const HintText('Agrega personas para ver el reparto.')
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (result.unassignedCents > 0)
                  _Warning(
                    'Hay ${formatCents(result.unassignedCents)} en consumos sin '
                    'asignar. Tócalos en la lista para elegir quién los pagó.',
                  ),
                for (final share in result.shares)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: PersonAvatar(share.person.name),
                    title: Text(share.person.name),
                    subtitle: share.tipCents == 0
                        ? null
                        : Text(
                            '${formatCents(share.consumptionCents)} + '
                            '${formatCents(share.tipCents)} de propina',
                          ),
                    trailing: Text(
                      formatCents(share.totalCents),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                const Divider(height: 24),
                _TotalRow('Subtotal', result.subtotalCents),
                _TotalRow(
                  'Propina (${formatPercent(bill.tipPercent)})',
                  result.tipCents,
                ),
                _TotalRow('Total', result.totalCents, emphasized: true),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () => _copySummary(context),
                  icon: const Icon(Icons.copy_outlined),
                  label: const Text('Copiar resumen'),
                ),
              ],
            ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  const _TotalRow(this.label, this.cents, {this.emphasized = false});

  final String label;
  final int cents;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final style = emphasized
        ? textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)
        : textTheme.bodyMedium;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(child: Text(label, style: style)),
          Text(formatCents(cents), style: style),
        ],
      ),
    );
  }
}

class _Warning extends StatelessWidget {
  const _Warning(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded, color: colors.onErrorContainer),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: colors.onErrorContainer),
            ),
          ),
        ],
      ),
    );
  }
}
