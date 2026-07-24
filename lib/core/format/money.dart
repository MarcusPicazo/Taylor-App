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

  /// Formatea un importe con el símbolo del mercado, usando las convenciones
  /// de separadores del idioma activo.
  static String format(BuildContext context, num amount) {
    return NumberFormat.currency(
      locale: Localizations.localeOf(context).toLanguageTag(),
      symbol: currencySymbol,
      decimalDigits: 2,
    ).format(amount);
  }

  /// Variante sin decimales, para cifras grandes donde los centavos son ruido.
  static String formatCompact(BuildContext context, num amount) {
    return NumberFormat.currency(
      locale: Localizations.localeOf(context).toLanguageTag(),
      symbol: currencySymbol,
      decimalDigits: 0,
    ).format(amount);
  }
}
