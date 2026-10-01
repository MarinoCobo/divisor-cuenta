// Modelos de datos. Son inmutables: para cambiarlos se crea una copia con
// copyWith, así el controlador siempre sabe cuándo algo cambió.

class Person {
  const Person({required this.id, required this.name});

  final int id;
  final String name;

  Person copyWith({String? name}) => Person(id: id, name: name ?? this.name);
}

/// Un consumo de la cuenta (un plato, una bebida...) y quiénes lo comparten.
class BillItem {
  const BillItem({
    required this.id,
    required this.description,
    required this.priceCents,
    required this.sharedBy,
  });

  final int id;
  final String description;
  final int priceCents;

  /// Ids de las personas que comparten este consumo (se divide en partes
  /// iguales entre ellas). Si está vacío, el consumo queda sin asignar.
  final Set<int> sharedBy;

  BillItem copyWith({
    String? description,
    int? priceCents,
    Set<int>? sharedBy,
  }) => BillItem(
    id: id,
    description: description ?? this.description,
    priceCents: priceCents ?? this.priceCents,
    sharedBy: sharedBy ?? this.sharedBy,
  );
}

enum SplitMode { equal, itemized }

/// Lo que le toca pagar a una persona.
class PersonShare {
  const PersonShare({
    required this.person,
    required this.consumptionCents,
    required this.tipCents,
  });

  final Person person;
  final int consumptionCents;
  final int tipCents;

  int get totalCents => consumptionCents + tipCents;
}

/// Resultado completo de dividir la cuenta.
class SplitResult {
  const SplitResult({
    required this.shares,
    required this.subtotalCents,
    required this.tipCents,
    this.unassignedCents = 0,
  });

  final List<PersonShare> shares;

  /// Lo consumido que se reparte entre las personas (sin propina).
  final int subtotalCents;
  final int tipCents;

  /// Consumos que nadie tiene asignados (solo en el modo por consumo). No se
  /// incluyen en el reparto hasta que se asignen a alguien.
  final int unassignedCents;

  int get totalCents => subtotalCents + tipCents;
}
