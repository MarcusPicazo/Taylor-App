import 'package:flutter_test/flutter_test.dart';
import 'package:taylor/data/demo_data.dart';
import 'package:taylor/data/models/taylor_user.dart';
import 'package:taylor/data/session_controller.dart';

/// Sesión y embudo de verificación.
///
/// Es el único sitio que decide si alguien puede pedir un viaje, y el router
/// lee de aquí para bloquear rutas. Un fallo en estas reglas no se manifiesta
/// como un error visible: se manifiesta como alguien sin verificar circulando
/// por la app.
void main() {
  SessionController controller() => SessionController();

  group('cuenta de demostración', () {
    test('las credenciales correctas inician sesión ya verificada', () async {
      final c = controller();

      final ok = await c.signInWithDemoAccount(
        TaylorDemo.email,
        TaylorDemo.password,
      );

      expect(ok, isTrue);
      expect(c.state.isSignedIn, isTrue);
      expect(c.state.user!.stage, VerificationStage.verified);
      expect(c.state.needsOnboarding, isFalse);
      expect(c.state.user!.isDemoAccount, isTrue);
    });

    test('la contraseña incorrecta no inicia sesión', () async {
      final c = controller();

      final ok = await c.signInWithDemoAccount(TaylorDemo.email, 'incorrecta');

      expect(ok, isFalse);
      expect(c.state.isSignedIn, isFalse);
      expect(c.state.error, 'invalidCredentials');
    });

    test('el correo no distingue mayúsculas ni espacios', () async {
      final c = controller();

      final ok = await c.signInWithDemoAccount(
        '  TEST@TAYLOR.COM  ',
        TaylorDemo.password,
      );

      expect(ok, isTrue);
    });
  });

  group('acceso empresarial', () {
    test('el código correcto entra como cuenta de empresa', () async {
      final c = controller();

      final ok = await c.signInWithBusinessCode(TaylorDemo.businessCode);

      expect(ok, isTrue);
      expect(c.state.user!.accountType, AccountType.business);
      expect(c.state.user!.businessName, isNotNull);
    });

    test('un código inválido no entra', () async {
      final c = controller();

      final ok = await c.signInWithBusinessCode('NOPE');

      expect(ok, isFalse);
      expect(c.state.isSignedIn, isFalse);
      expect(c.state.error, 'invalidBusinessCode');
    });
  });

  group('alta con proveedor social', () {
    test('autenticarse NO equivale a estar verificada', () async {
      final c = controller();

      await c.signInWithProvider(
        provider: 'google',
        displayName: 'Nueva Usuaria',
        email: 'nueva@gmail.com',
      );

      // Entrar con Google solo prueba que controla un correo. La identidad
      // se verifica después, y hasta entonces no puede pedir viajes.
      expect(c.state.isSignedIn, isTrue);
      expect(c.state.user!.stage, VerificationStage.registered);
      expect(c.state.needsOnboarding, isTrue);
      expect(c.state.user!.stage.canRequestRides, isFalse);
    });

    test('avanzar por el embudo termina en verificada', () async {
      final c = controller();
      await c.signInWithProvider(
        provider: 'google',
        displayName: 'Nueva Usuaria',
        email: 'nueva@gmail.com',
      );

      for (final stage in [
        VerificationStage.phoneConfirmed,
        VerificationStage.documentCaptured,
        VerificationStage.biometricMatched,
        VerificationStage.backgroundCheckPending,
        VerificationStage.safetyNetworkReady,
        VerificationStage.verified,
      ]) {
        c.advanceStage(stage);
      }

      expect(c.state.user!.stage, VerificationStage.verified);
      expect(c.state.needsOnboarding, isFalse);
    });
  });

  group('perfil y contactos', () {
    test('actualizar el perfil conserva el resto de datos', () async {
      final c = controller();
      await c.signInWithDemoAccount(TaylorDemo.email, TaylorDemo.password);

      c.updateProfile(fullName: 'Nombre Nuevo');

      expect(c.state.user!.fullName, 'Nombre Nuevo');
      expect(c.state.user!.email, TaylorDemo.email);
      expect(c.state.user!.stage, VerificationStage.verified);
    });

    test('los contactos de emergencia se pueden reemplazar', () async {
      final c = controller();
      await c.signInWithDemoAccount(TaylorDemo.email, TaylorDemo.password);

      c.setEmergencyContacts(const [
        EmergencyContact(id: 'x', name: 'Sofía', phone: '+52 9'),
      ]);

      expect(c.state.user!.emergencyContacts.length, 1);
      expect(c.state.user!.emergencyContacts.single.name, 'Sofía');
    });

    test('actualizar sin sesión no explota', () {
      final c = controller();

      c.updateProfile(fullName: 'Nadie');
      c.setEmergencyContacts(const []);
      c.advanceStage(VerificationStage.verified);

      expect(c.state.isSignedIn, isFalse);
    });
  });

  test('cerrar sesión limpia el estado', () async {
    final c = controller();
    await c.signInWithDemoAccount(TaylorDemo.email, TaylorDemo.password);

    c.signOut();

    expect(c.state.isSignedIn, isFalse);
    expect(c.state.user, isNull);
    expect(c.state.error, isNull);
  });
}
