// Estado de la app. Un ChangeNotifier guarda los datos de la cuenta y avisa a
// la interfaz (notifyListeners) cada vez que algo cambia; los widgets que lo
// escuchan con ListenableBuilder se vuelven a dibujar solos.

import 'package:flutter/foundation.dart';

import '../logic/money.dart';
import '../logic/split_calculator.dart';
import '../models/bill.dart';

class BillController extends ChangeNotifier {
  static const tipPresets = <double>[0, 10, 15, 20];

  final List<Person> _people = [];
  final List<BillItem> _items = [];
  SplitMode _mode = SplitMode.equal;
  int _equalSubtotalCents = 0;
  double _tipPercent = 10;
  int _nextId = 1;
  int _resetCount = 0;

  List<Person> get people => List.unmodifiable(_people);
  List<BillItem> get items => List.unmodifiable(_items);
  SplitMode get mode => _mode;
  int get equalSubtotalCents => _equalSubtotalCents;
  double get tipPercent => _tipPercent;

  /// Cambia cada vez que se reinicia la cuenta. La interfaz lo usa como key
  /// para descartar lo que el usuario tenía escrito en los campos de texto.
  int get resetCount => _resetCount;

  int get itemsTotalCents => _items.fold(0, (sum, i) => sum + i.priceCents);

  SplitResult get result => switch (_mode) {
    SplitMode.equal => splitEqually(
      people: _people,
      subtotalCents: _equalSubtotalCents,
      tipPercent: _tipPercent,
    ),
    SplitMode.itemized => splitByItems(
      people: _people,
      items: _items,
      tipPercent: _tipPercent,
    ),
  };

  Person? personById(int id) {
    for (final p in _people) {
      if (p.id == id) return p;
    }
    return null;
  }

  // ---- Personas ----

  /// Agrega una persona. Si no se da nombre, se usa "Persona N".
  void addPerson([String name = '']) {
    final trimmed = name.trim();
    _people.add(
      Person(
        id: _nextId++,
        name: trimmed.isEmpty ? _defaultPersonName() : trimmed,
      ),
    );
    notifyListeners();
  }

  void renamePerson(int id, String name) {
    final trimmed = name.trim();
    final index = _people.indexWhere((p) => p.id == id);
    if (index == -1 || trimmed.isEmpty) return;
    _people[index] = _people[index].copyWith(name: trimmed);
    notifyListeners();
  }

  void removePerson(int id) {
    _people.removeWhere((p) => p.id == id);
    // Quien se va deja de compartir sus consumos.
    for (var i = 0; i < _items.length; i++) {
      final sharedBy = _items[i].sharedBy;
      if (sharedBy.contains(id)) {
        _items[i] = _items[i].copyWith(sharedBy: {...sharedBy}..remove(id));
      }
    }
    notifyListeners();
  }

  String _defaultPersonName() {
    var n = _people.length + 1;
    while (_people.any((p) => p.name == 'Persona $n')) {
      n++;
    }
    return 'Persona $n';
  }

  // ---- Cuenta ----

  void setMode(SplitMode mode) {
    _mode = mode;
    notifyListeners();
  }

  void setEqualSubtotal(int cents) {
    if (cents == _equalSubtotalCents) return;
    _equalSubtotalCents = cents;
    notifyListeners();
  }

  void setTipPercent(double percent) {
    _tipPercent = percent.clamp(0, 100).toDouble();
    notifyListeners();
  }

  void addItem({
    required String description,
    required int priceCents,
    required Set<int> sharedBy,
  }) {
    _items.add(
      BillItem(
        id: _nextId++,
        description: description.trim().isEmpty
            ? 'Consumo ${_items.length + 1}'
            : description.trim(),
        priceCents: priceCents,
        sharedBy: Set.unmodifiable(sharedBy),
      ),
    );
    notifyListeners();
  }

  void updateItem(
    int id, {
    required String description,
    required int priceCents,
    required Set<int> sharedBy,
  }) {
    final index = _items.indexWhere((i) => i.id == id);
    if (index == -1) return;
    _items[index] = _items[index].copyWith(
      description: description.trim().isEmpty
          ? _items[index].description
          : description.trim(),
      priceCents: priceCents,
      sharedBy: Set.unmodifiable(sharedBy),
    );
    notifyListeners();
  }

  void removeItem(int id) {
    _items.removeWhere((i) => i.id == id);
    notifyListeners();
  }

  /// Borra todo y vuelve al estado inicial.
  void reset() {
    _people.clear();
    _items.clear();
    _mode = SplitMode.equal;
    _equalSubtotalCents = 0;
    _tipPercent = 10;
    _resetCount++;
    notifyListeners();
  }

  // ---- Resumen para compartir ----

  /// Texto listo para pegar en un chat con lo que paga cada persona.
  String summaryText() {
    final r = result;
    final buffer = StringBuffer('Cuenta dividida\n');
    for (final share in r.shares) {
      buffer.writeln(
        '- ${share.person.name}: ${formatCents(share.totalCents)}',
      );
    }
    buffer
      ..writeln()
      ..writeln('Subtotal: ${formatCents(r.subtotalCents)}')
      ..writeln(
        'Propina (${formatPercent(_tipPercent)}): ${formatCents(r.tipCents)}',
      )
      ..write('Total: ${formatCents(r.totalCents)}');
    if (r.unassignedCents > 0) {
      buffer.write('\nSin asignar: ${formatCents(r.unassignedCents)}');
    }
    return buffer.toString();
  }
}
