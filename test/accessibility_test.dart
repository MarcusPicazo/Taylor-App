import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taylor/core/locale/locale_controller.dart';
import 'package:taylor/core/theme/taylor_theme.dart';
import 'package:taylor/features/account/account_screen.dart';
import 'package:taylor/features/auth/login_screen.dart';
import 'package:taylor/features/safety/safety_screen.dart';
import 'package:taylor/l10n/app_localizations.dart';

/// Comprobaciones de accesibilidad sobre las pantallas principales.
///
/// Flutter puede verificar de verdad —sin dispositivo— tres cosas que suelen
/// romperse en silencio: que todo lo pulsable tenga etiqueta para lectores de
/// pantalla, que las áreas táctiles alcancen el mínimo de cada plataforma, y
/// que el texto tenga contraste suficiente.
///
/// En una app cuyo argumento es la seguridad esto pesa más de lo habitual: una
/// usuaria con baja visión, o usando el teléfono de noche y en movimiento,
/// tiene que poder encontrar el botón de emergencia.
void main() {
  /// Envuelve una pantalla con lo mínimo para poder montarla en test.
  Widget harness(Widget child) {
    return ProviderScope(
      child: MaterialApp(
        theme: TaylorTheme.light(),
        locale: const Locale('es'),
        supportedLocales: TaylorLocale.locales,
        localizationsDelegates: const [
          L10n.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: child,
      ),
    );
  }

  group('pantalla de inicio de sesión', () {
    testWidgets('cumple el tamaño mínimo de área táctil en Android',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(harness(const LoginScreen()));
      await tester.pumpAndSettle();

      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      handle.dispose();
    });

    testWidgets('cumple el tamaño mínimo de área táctil en iOS',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(harness(const LoginScreen()));
      await tester.pumpAndSettle();

      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
      handle.dispose();
    });

    testWidgets('todo lo pulsable tiene etiqueta', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(harness(const LoginScreen()));
      await tester.pumpAndSettle();

      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      handle.dispose();
    });

    testWidgets('el texto tiene contraste suficiente', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(harness(const LoginScreen()));
      await tester.pumpAndSettle();

      await expectLater(tester, meetsGuideline(textContrastGuideline));
      handle.dispose();
    });
  });

  group('pestaña de seguridad', () {
    testWidgets('cumple el tamaño mínimo de área táctil', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(harness(const SafetyScreen()));
      await tester.pumpAndSettle();

      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      handle.dispose();
    });

    testWidgets('todo lo pulsable tiene etiqueta', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(harness(const SafetyScreen()));
      await tester.pumpAndSettle();

      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      handle.dispose();
    });

    testWidgets('el texto tiene contraste suficiente', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(harness(const SafetyScreen()));
      await tester.pumpAndSettle();

      await expectLater(tester, meetsGuideline(textContrastGuideline));
      handle.dispose();
    });
  });

  group('pestaña de cuenta', () {
    testWidgets('cumple el tamaño mínimo de área táctil', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(harness(const AccountScreen()));
      await tester.pumpAndSettle();

      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      handle.dispose();
    });

    testWidgets('el texto tiene contraste suficiente', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(harness(const AccountScreen()));
      await tester.pumpAndSettle();

      await expectLater(tester, meetsGuideline(textContrastGuideline));
      handle.dispose();
    });
  });
}
