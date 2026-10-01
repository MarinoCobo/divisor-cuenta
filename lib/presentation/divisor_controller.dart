import 'package:divisor_cuenta/domain/calcular_division.dart';
import 'package:divisor_cuenta/domain/cuenta.dart';
import 'package:divisor_cuenta/domain/estrategia_redondeo.dart';
import 'package:divisor_cuenta/presentation/formateador_moneda.dart';

/// Coordina la pantalla: lee lo que escribió el usuario, pide el cálculo y
/// guarda lo que hay que mostrar.
///
/// Existe para que la pantalla solo dibuje. Recibe todas sus dependencias por
/// el constructor (DIP): no crea ninguna estrategia concreta, solo conoce la
/// interfaz [EstrategiaRedondeo]. Es Dart puro, así que se puede probar sin
/// widgets.
class DivisorController {
  /// Recibe el caso de uso [calcularDivision], el [formateador] del resultado
  /// y las [estrategias] de redondeo con el nombre que ve el usuario. El
  /// primer modo del mapa es el modo inicial.
  ///
  /// Lanza [ArgumentError] si [estrategias] está vacío.
  ///
  /// Los parámetros `this._algo` son parámetros nombrados privados: quien
  /// llama escribe `calcularDivision:` y el valor se guarda directo en el
  /// campo privado `_calcularDivision`.
  DivisorController({
    required this._calcularDivision,
    required this._formateador,
    required Map<String, EstrategiaRedondeo> estrategias,
  }) : _estrategias = Map.unmodifiable(estrategias),
       _modoSeleccionado = _primerModo(estrategias);

  final CalcularDivision _calcularDivision;
  final FormateadorMoneda _formateador;
  final Map<String, EstrategiaRedondeo> _estrategias;
  String _modoSeleccionado;
  String? _resultado;

  /// Nombres de los modos de redondeo, en el orden en que se registraron.
  List<String> get modos => _estrategias.keys.toList();

  /// Nombre del modo de redondeo elegido.
  String get modoSeleccionado => _modoSeleccionado;

  /// Monto por persona ya formateado ("27.50"), o `null` si no hay nada que
  /// mostrar.
  String? get resultado => _resultado;

  /// Cambia el modo de redondeo a [modo] y borra el resultado anterior, que ya
  /// no corresponde al modo nuevo.
  ///
  /// Lanza [ArgumentError] si [modo] no es uno de [modos].
  void seleccionarModo(String modo) {
    if (!_estrategias.containsKey(modo)) {
      throw ArgumentError.value(modo, 'modo', 'Modo de redondeo desconocido');
    }
    _modoSeleccionado = modo;
    limpiar();
  }

  /// Recibe el texto de los tres campos ([monto], [personas] y [propina]),
  /// lo convierte a números y guarda en [resultado] cuánto paga cada persona.
  ///
  /// No lanza errores.
  void calcular({
    required String monto,
    required String personas,
    required String propina,
  }) {
    final cuenta = Cuenta(
      monto: _leerDecimal(monto, siEstaVacio: double.nan),
      personas: int.tryParse(personas.trim()) ?? 0,
      propina: _leerDecimal(propina, siEstaVacio: 0),
    );
    final estrategia = _estrategias[_modoSeleccionado]!;
    final calculado = _calcularDivision.calcular(cuenta, estrategia);
    _resultado = _formateador.formatear(calculado.montoPorPersona);
  }

  /// Borra lo que se esté mostrando. Se llama cuando el usuario cambia una
  /// entrada, para no dejar en pantalla un resultado que ya no corresponde.
  void limpiar() {
    _resultado = null;
  }

  /// Convierte el [texto] de un campo en número. Acepta coma o punto como
  /// separador decimal. Devuelve [siEstaVacio] si el campo está vacío y
  /// `double.nan` si el texto no es un número.
  static double _leerDecimal(String texto, {required double siEstaVacio}) {
    final normalizado = texto.trim().replaceAll(',', '.');
    if (normalizado.isEmpty) return siEstaVacio;
    return double.tryParse(normalizado) ?? double.nan;
  }

  /// Devuelve el primer modo de [estrategias]. Lanza [ArgumentError] si está
  /// vacío, porque la pantalla necesita al menos un modo.
  static String _primerModo(Map<String, EstrategiaRedondeo> estrategias) {
    if (estrategias.isEmpty) {
      throw ArgumentError.value(
        estrategias,
        'estrategias',
        'Debe registrarse al menos un modo de redondeo',
      );
    }
    return estrategias.keys.first;
  }
}
