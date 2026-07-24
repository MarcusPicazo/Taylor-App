import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

/// Formato de dinero de Taylor.
///
/// Existe porque `NumberFormat.simpleCurrency(locale: 'es')` devuelve **euros**.
/// El locale del dispositivo dice en qué idioma leer, no en qué país se cobra:
/// un teléfono en español genérico se resuelve a España. La app llegó a mostrar
/// "128,50 €" en un producto que opera en México.
///
/// La moneda es una propiedad del **mercado**, no del idioma. Una usuaria en
/// México con la interfaz en inglés debe seguir viendo pesos, y por eso se fija
/// explícitamente en lugar de derivarla del locale.
///
/// Cuando Taylor opere en más de un país, esto pasa a leerse de la cuenta o de
/// la ciudad de operación — pero seguirá sin derivarse del idioma.
abstract final class Money {
  /// Mercado actual de Taylor.
  static const String currencyCode = 'MXN';
  static const String currencySymbol = r'$';

  /// Locale de formato monetario.
  ///
  /// Fijo, y por la misma razón que la divisa: **la posición del símbolo
  /// también es del mercado**. Un locale de "español genérico" coloca el
  /// símbolo detrás —"221 $", convención europea— cuando en México va delante,
  /// "$221". Formatear con `es_MX` produce la convención correcta sin importar
  /// en qué idioma esté la interfaz.
  static const String _marketLocale = 'es_MX';

  /// Importe con dos decimales: "$128.50".
  static String format(BuildContext context, num amount) {
    return NumberFormat.currency(
      locale: _marketLocale,
      symbol: currencySymbol,
      decimalDigits: 2,
    ).format(amount);
  }

  /// Sin centavos, para estimaciones y cifras grandes: "$221".
  ///
  /// En una tarifa estimada los centavos sugieren una precisión que no existe,
  /// y al volante una cifra corta se lee de un vistazo.
  static String formatCompact(BuildContext context, num amount) {
    return NumberFormat.currency(
      locale: _marketLocale,
      symbol: currencySymbol,
      decimalDigits: 0,
    ).format(amount);
  }
}
