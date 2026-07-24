/// Marca de la tarjeta, deducida del número.
enum CardBrand {
  visa('Visa'),
  mastercard('Mastercard'),
  amex('American Express'),
  unknown('Tarjeta');

  const CardBrand(this.label);
  final String label;

  /// Longitud esperada del número. Amex usa 15 dígitos, el resto 16.
  int get expectedLength => this == CardBrand.amex ? 15 : 16;

  /// Longitud del código de seguridad. Amex usa 4, el resto 3.
  int get cvvLength => this == CardBrand.amex ? 4 : 3;

  /// Deduce la marca de los primeros dígitos.
  ///
  /// Es un subconjunto de los rangos reales, suficiente para las marcas que
  /// operan en México. El procesador hace la detección definitiva; esto solo
  /// sirve para dar retroalimentación mientras se escribe.
  static CardBrand fromNumber(String digits) {
    if (digits.isEmpty) return CardBrand.unknown;
    if (digits.startsWith('4')) return CardBrand.visa;
    if (digits.startsWith('34') || digits.startsWith('37')) {
      return CardBrand.amex;
    }

    if (digits.length >= 2) {
      final prefix = int.tryParse(digits.substring(0, 2)) ?? 0;
      if (prefix >= 51 && prefix <= 55) return CardBrand.mastercard;
    }
    if (digits.length >= 4) {
      final prefix = int.tryParse(digits.substring(0, 4)) ?? 0;
      if (prefix >= 2221 && prefix <= 2720) return CardBrand.mastercard;
    }

    return CardBrand.unknown;
  }
}

/// Un método de pago guardado.
///
/// **Nunca contiene el número completo.** Solo los últimos cuatro dígitos y la
/// marca, que es lo justo para que la usuaria reconozca cuál es. El número
/// completo se usa para validar y se descarta; en producción ni siquiera llega
/// a la app, porque lo captura el SDK del procesador.
///
/// Guardar el PAN completo pondría a Taylor dentro del alcance de PCI-DSS, con
/// las obligaciones de auditoría y la responsabilidad legal que eso implica.
/// Ninguna app de movilidad lo hace, y esta tampoco.
class PaymentCard {
  const PaymentCard({
    required this.id,
    required this.brand,
    required this.last4,
    required this.expiryMonth,
    required this.expiryYear,
    this.isDefault = false,
  });

  final String id;
  final CardBrand brand;

  /// Últimos cuatro dígitos, lo único que se conserva del número.
  final String last4;

  final int expiryMonth;

  /// Año completo, cuatro dígitos.
  final int expiryYear;

  final bool isDefault;

  String get displayNumber => '${brand.label} •••• $last4';

  String get displayExpiry =>
      '${expiryMonth.toString().padLeft(2, '0')}/${expiryYear % 100}';

  /// Una tarjeta caducada no debería poder cobrarse.
  bool get isExpired {
    final now = DateTime.now();
    // Vale hasta el último día del mes indicado.
    final expiry = DateTime(expiryYear, expiryMonth + 1);
    return now.isAfter(expiry);
  }

  PaymentCard copyWith({bool? isDefault}) => PaymentCard(
        id: id,
        brand: brand,
        last4: last4,
        expiryMonth: expiryMonth,
        expiryYear: expiryYear,
        isDefault: isDefault ?? this.isDefault,
      );
}

/// Validación de datos de tarjeta.
///
/// Se valida en el cliente para dar respuesta inmediata, no para decidir: la
/// validación que cuenta la hace el procesador. Pero detectar aquí un dígito
/// mal tecleado evita una llamada de red y un mensaje de error genérico.
abstract final class CardValidator {
  /// Algoritmo de Luhn.
  ///
  /// Detecta la inmensa mayoría de errores de tecleo —un dígito cambiado, dos
  /// dígitos intercambiados— sin consultar nada. Es el mismo que usa cualquier
  /// pasarela como primer filtro.
  static bool isValidNumber(String digits) {
    if (digits.length < 13 || digits.length > 19) return false;

    var sum = 0;
    var alternate = false;

    for (var i = digits.length - 1; i >= 0; i--) {
      var n = int.tryParse(digits[i]);
      if (n == null) return false;

      if (alternate) {
        n *= 2;
        if (n > 9) n -= 9;
      }
      sum += n;
      alternate = !alternate;
    }

    return sum % 10 == 0;
  }

  /// Comprueba que la fecha sea futura y plausible.
  static bool isValidExpiry(int month, int year) {
    if (month < 1 || month > 12) return false;

    final now = DateTime.now();
    // Vale durante todo el mes indicado.
    final expiry = DateTime(year, month + 1);

    if (!expiry.isAfter(now)) return false;

    // Más de 20 años vista es casi con seguridad un año mal tecleado.
    return year <= now.year + 20;
  }

  static bool isValidCvv(String cvv, CardBrand brand) =>
      cvv.length == brand.cvvLength && int.tryParse(cvv) != null;

  /// Agrupa el número en bloques para que se pueda leer y revisar.
  ///
  /// Amex usa 4-6-5, el resto 4-4-4-4. Respetarlo importa: la usuaria compara
  /// contra la tarjeta física, que está impresa con ese agrupamiento.
  static String formatNumber(String digits, CardBrand brand) {
    final groups = brand == CardBrand.amex ? [4, 6, 5] : [4, 4, 4, 4];
    final buffer = StringBuffer();

    var index = 0;
    for (final size in groups) {
      if (index >= digits.length) break;
      if (index > 0) buffer.write(' ');
      final end = (index + size).clamp(0, digits.length);
      buffer.write(digits.substring(index, end));
      index = end;
    }

    return buffer.toString();
  }
}
