import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taylor/core/format/money.dart';
import 'package:taylor/core/locale/locale_controller.dart';
import 'package:taylor/l10n/app_localizations.dart';

/// Formato de dinero.
///
/// Este test existe por un bug encontrado en dispositivo físico: la app
/// mostraba **euros** en un producto que opera en México. `simpleCurrency`
/// resuelve la moneda a partir del locale, y un teléfono en español genérico
/// se resuelve a España.
///
/// La lección que fija este test: **la moneda es del mercado, no del idioma.**
void main() {
  /// Monta un widget con un locale concreto y devuelve el importe formateado.
  Future<String> formatIn(WidgetTester tester, Locale locale, num amount) async {
    late String result;

    await tester.pumpWidget(
      MaterialApp(
        locale: locale,
        supportedLocales: TaylorLocale.locales,
        localizationsDelegates: const [
          L10n.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: Builder(
          builder: (context) {
            result = Money.format(context, amount);
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    return result;
  }

  testWidgets('en español muestra pesos, no euros', (tester) async {
    final formatted = await formatIn(tester, const Locale('es'), 128.5);

    expect(formatted, contains(r'$'));
    expect(formatted, isNot(contains('€')));
    expect(formatted, contains('128'));
  });

  testWidgets('en inglés también muestra pesos', (tester) async {
    final formatted = await formatIn(tester, const Locale('en'), 128.5);

    // Una usuaria en México con la interfaz en inglés sigue pagando en pesos.
    // Si esto se rompe, alguien volvió a derivar la moneda del idioma.
    expect(formatted, contains(r'$'));
    expect(formatted, isNot(contains('€')));
  });

  testWidgets('el importe lleva dos decimales', (tester) async {
    final formatted = await formatIn(tester, const Locale('es'), 128.5);

    // 128.5 debe mostrarse como 128.50, no como 128.5: en dinero, un decimal
    // suelto se lee como un error de la app.
    expect(formatted, anyOf(contains('128.50'), contains('128,50')));
  });

  testWidgets('la variante compacta omite los centavos', (tester) async {
    late String result;

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('es'),
        supportedLocales: TaylorLocale.locales,
        localizationsDelegates: const [
          L10n.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: Builder(
          builder: (context) {
            result = Money.formatCompact(context, 154);
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(result, contains('154'));
    expect(result, isNot(contains('.00')));
    expect(result, isNot(contains(',00')));
  });

  test('el mercado está fijado explícitamente', () {
    // Si Taylor se expande, esto pasa a leerse de la cuenta o la ciudad —
    // pero nunca del idioma del dispositivo.
    expect(Money.currencyCode, 'MXN');
  });
}
