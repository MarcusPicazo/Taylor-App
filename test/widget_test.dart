import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taylor/app/taylor_app.dart';

void main() {
  testWidgets('la app arranca en el splash y muestra el wordmark',
      (tester) async {
    await tester.pumpWidget(const ProviderScope(child: TaylorApp()));

    // El splash anima durante ~2.1 s antes de navegar. Se avanza el reloj a
    // mano en lugar de usar pumpAndSettle: mientras la animación corre, la
    // app nunca queda en reposo y pumpAndSettle expiraría.
    await tester.pump(const Duration(milliseconds: 1200));

    expect(find.text('taylor'), findsOneWidget);
  });

  testWidgets('al terminar el splash sin sesión, muestra el login',
      (tester) async {
    await tester.pumpWidget(const ProviderScope(child: TaylorApp()));

    await tester.pump(const Duration(milliseconds: 2200));
    await tester.pumpAndSettle();

    // La pantalla de login repite el wordmark y ofrece el acceso B2B.
    expect(find.text('taylor'), findsWidgets);
    expect(find.text('Business'), findsOneWidget);
  });
}
