import 'package:flutter/material.dart';

import '../logic/money.dart';
import '../models/bill.dart';
import '../state/bill_controller.dart';
import 'common.dart';

/// Modo "por consumo": lista de platos/bebidas y quién los compartió.
class ItemsSection extends StatelessWidget {
  const ItemsSection({super.key, required this.bill});

  final BillController bill;

  void _openEditor(BuildContext context, [BillItem? item]) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      builder: (_) => ItemEditorSheet(bill: bill, item: item),
    );
  }

  String _sharedByLabel(BillItem item) {
    final names = [
      for (final p in bill.people)
        if (item.sharedBy.contains(p.id)) p.name,
    ];
    if (names.isEmpty) return 'Sin asignar';
    if (names.length > 1 && names.length == bill.people.length) {
      return 'Todos (${names.length})';
    }
    return names.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = bill.items;
    final noPeople = bill.people.isEmpty;

    return SectionCard(
      title: 'Consumos',
      icon: Icons.receipt_long_outlined,
      trailing: items.isEmpty
          ? null
          : Text(
              formatCents(bill.itemsTotalCents),
              style: theme.textTheme.titleMedium,
            ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (noPeople)
            const HintText(
              'Primero agrega a las personas para poder asignarles consumos.',
            )
          else if (items.isEmpty)
            const HintText(
              'Agrega cada plato o bebida y marca quiénes lo compartieron.',
            ),
          for (final item in items)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(item.description),
              subtitle: Text(
                _sharedByLabel(item),
                style: item.sharedBy.isEmpty
                    ? TextStyle(color: theme.colorScheme.error)
                    : null,
              ),
              trailing: Text(
                formatCents(item.priceCents),
                style: theme.textTheme.bodyLarge,
              ),
              onTap: () => _openEditor(context, item),
            ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton.tonalIcon(
              onPressed: noPeople ? null : () => _openEditor(context),
              icon: const Icon(Icons.add),
              label: const Text('Agregar consumo'),
            ),
          ),
        ],
      ),
    );
  }
}

/// Hoja inferior para crear o editar un consumo.
class ItemEditorSheet extends StatefulWidget {
  const ItemEditorSheet({super.key, required this.bill, this.item});

  final BillController bill;

  /// Null cuando se está creando un consumo nuevo.
  final BillItem? item;

  @override
  State<ItemEditorSheet> createState() => _ItemEditorSheetState();
}

class _ItemEditorSheetState extends State<ItemEditorSheet> {
  late final _description = TextEditingController(
    text: widget.item?.description ?? '',
  );
  late final _price = TextEditingController(
    text: widget.item == null ? '' : centsToInput(widget.item!.priceCents),
  );
  late final Set<int> _selected = {...?widget.item?.sharedBy};
  bool _showErrors = false;

  bool get _isNew => widget.item == null;
  int? get _priceCents => parseCents(_price.text);

  @override
  void dispose() {
    _description.dispose();
    _price.dispose();
    super.dispose();
  }

  void _save() {
    final price = _priceCents;
    if (price == null || price <= 0 || _selected.isEmpty) {
      setState(() => _showErrors = true);
      return;
    }
    if (_isNew) {
      widget.bill.addItem(
        description: _description.text,
        priceCents: price,
        sharedBy: _selected,
      );
    } else {
      widget.bill.updateItem(
        widget.item!.id,
        description: _description.text,
        priceCents: price,
        sharedBy: _selected,
      );
    }
    Navigator.of(context).pop();
  }

  void _delete() {
    widget.bill.removeItem(widget.item!.id);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final people = widget.bill.people;
    final allSelected = _selected.length == people.length;
    final price = _priceCents;
    final priceError = !_showErrors || (price != null && price > 0)
        ? null
        : 'Escribe un precio válido';

    return Padding(
      // Sube la hoja cuando aparece el teclado.
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _isNew ? 'Nuevo consumo' : 'Editar consumo',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _description,
              autofocus: _isNew,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Descripción',
                hintText: 'Ej. Pizza grande',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _price,
              keyboardType: moneyKeyboard,
              inputFormatters: moneyInputFormatters,
              decoration: InputDecoration(
                labelText: 'Precio',
                prefixText: '\$ ',
                hintText: '0.00',
                errorText: priceError,
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '¿Quiénes lo compartieron?',
                    style: theme.textTheme.titleSmall,
                  ),
                ),
                TextButton(
                  onPressed: () => setState(() {
                    if (allSelected) {
                      _selected.clear();
                    } else {
                      _selected.addAll(people.map((p) => p.id));
                    }
                  }),
                  child: Text(allSelected ? 'Ninguno' : 'Todos'),
                ),
              ],
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final person in people)
                  FilterChip(
                    label: Text(person.name),
                    selected: _selected.contains(person.id),
                    onSelected: (on) => setState(() {
                      if (on) {
                        _selected.add(person.id);
                      } else {
                        _selected.remove(person.id);
                      }
                    }),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (_showErrors && _selected.isEmpty)
              Text(
                'Elige al menos una persona',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              )
            else if (_selected.length > 1 && price != null && price > 0)
              HintText(
                'Se divide entre ${_selected.length}: '
                '${formatCents((price / _selected.length).round())} c/u'
                '${price % _selected.length == 0 ? '' : ' aprox.'}',
              ),
            const SizedBox(height: 24),
            Row(
              children: [
                if (!_isNew)
                  TextButton.icon(
                    onPressed: _delete,
                    style: TextButton.styleFrom(
                      foregroundColor: theme.colorScheme.error,
                    ),
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Eliminar'),
                  ),
                const Spacer(),
                FilledButton(
                  onPressed: _save,
                  child: Text(_isNew ? 'Agregar' : 'Guardar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
