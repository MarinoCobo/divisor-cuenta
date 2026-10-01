import 'package:flutter/material.dart';

import '../models/bill.dart';
import '../state/bill_controller.dart';
import 'common.dart';

/// Lista de personas: agregar, renombrar (tocando el nombre) y quitar.
class PeopleSection extends StatefulWidget {
  const PeopleSection({super.key, required this.bill});

  final BillController bill;

  @override
  State<PeopleSection> createState() => _PeopleSectionState();
}

class _PeopleSectionState extends State<PeopleSection> {
  final _name = TextEditingController();
  final _focus = FocusNode();

  @override
  void dispose() {
    _name.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _add() {
    widget.bill.addPerson(_name.text);
    _name.clear();
    _focus.requestFocus();
  }

  Future<void> _rename(Person person) async {
    final name = await showTextInputDialog(
      context,
      title: 'Cambiar nombre',
      label: 'Nombre',
      initialValue: person.name,
      validator: (v) => v.trim().isEmpty ? 'Escribe un nombre' : null,
    );
    if (name != null) widget.bill.renamePerson(person.id, name);
  }

  @override
  Widget build(BuildContext context) {
    final people = widget.bill.people;
    return SectionCard(
      title: 'Personas',
      icon: Icons.group_outlined,
      trailing: people.isEmpty ? null : Text('${people.length}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (people.isEmpty)
            const HintText('Agrega a quienes van a pagar.')
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final person in people)
                  InputChip(
                    avatar: PersonAvatar(person.name),
                    label: Text(person.name),
                    tooltip: 'Tocar para cambiar el nombre',
                    onPressed: () => _rename(person),
                    onDeleted: () => widget.bill.removePerson(person.id),
                    deleteButtonTooltipMessage: 'Quitar',
                  ),
              ],
            ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextField(
                  controller: _name,
                  focusNode: _focus,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    labelText: 'Nombre',
                    hintText: 'Ej. Ana',
                    helperText: 'Vacío = "Persona N"',
                  ),
                  onSubmitted: (_) => _add(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: _add,
                tooltip: 'Agregar persona',
                icon: const Icon(Icons.person_add_alt_1),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
