import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/models/driver_profile.dart';
import '../data/models/taylor_user.dart';
import '../data/models/trip.dart';
import '../data/session_controller.dart';
import '../features/account/account_screen.dart';
import '../features/account/help_screen.dart';
import '../features/account/profile_screen.dart';
import '../features/account/settings_screen.dart';
import '../features/account/wallet_screen.dart';
import '../features/auth/business_application_screen.dart';
import '../features/auth/business_screen.dart';
import '../features/business/business_account_screen.dart';
import '../features/business/business_controller.dart';
import '../features/chat/trip_chat_route.dart';
import '../features/business/business_home_screen.dart';
import '../features/business/business_schedule_screen.dart';
import '../features/business/business_team_screen.dart';
import '../features/auth/demo_login_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/driver/driver_account_screen.dart';
import '../features/driver/driver_application_screen.dart';
import '../features/driver/driver_controller.dart';
import '../features/driver/driver_home_screen.dart';
import '../features/driver/earnings_screen.dart';
import '../features/home/home_screen.dart';
import '../features/onboarding/onboarding_flow_screen.dart';
import '../features/safety/safety_screen.dart';
import '../features/splash/splash_screen.dart';
import '../features/trips/receipt_screen.dart';
import '../features/trips/trips_screen.dart';
import 'app_mode.dart';
import 'business_shell_scaffold.dart';
import 'driver_shell_scaffold.dart';
import 'shell_scaffold.dart';

abstract final class Routes {
  static const splash = '/';
  static const login = '/login';
  static const demoLogin = '/login/demo';
  static const business = '/login/business';
  static const businessApplication = '/login/business/apply';
  static const onboarding = '/onboarding';

  static const home = '/home';
  static const trips = '/trips';
  static const safety = '/safety';
  static const account = '/account';

  static const profile = '/account/profile';
  static const wallet = '/account/wallet';
  static const help = '/account/help';
  static const settings = '/account/settings';
  static const driverApplication = '/account/drive';

  // --- Modo conductora ---------------------------------------------------
  static const driveHome = '/drive';
  static const driveEarnings = '/drive/earnings';
  static const driveSafety = '/drive/safety';
  static const driveAccount = '/drive/account';

  // --- Panel empresarial -------------------------------------------------
  static const businessHome = '/business';
  static const businessSchedule = '/business/schedule';
  static const businessTeam = '/business/team';
  static const businessAccount = '/business/account';

  /// Chat del viaje activo. Se resuelve según el modo en curso.
  static const chat = '/chat';

  /// Recibo de un viaje. Recibe el [Trip] por `extra`.
  static const receipt = '/receipt';

  /// Rutas que solo existen en modo conductora.
  static bool isDriverRoute(String location) => location.startsWith('/drive');

  /// Rutas que solo existen en el panel empresarial.
  ///
  /// Ojo con el prefijo: `/login/business` NO es una ruta del panel, es la
  /// pantalla de acceso. Por eso se compara contra `/business` exacto.
  static bool isBusinessRoute(String location) =>
      location == businessHome || location.startsWith('$businessHome/');
}

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();
final _driverShellNavigatorKey = GlobalKey<NavigatorState>();
final _businessShellNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: Routes.splash,

    // El guard vive aquí y solo aquí. Ninguna pantalla puede saltarse la
    // verificación navegando directo: si la usuaria no llegó a `verified`,
    // cualquier ruta de la app la devuelve al onboarding.
    redirect: (context, state) {
      final session = ref.read(sessionControllerProvider);
      final location = state.matchedLocation;

      if (location == Routes.splash) return null;

      final isAuthRoute = location.startsWith('/login');
      final isOnboarding = location == Routes.onboarding;

      if (!session.isSignedIn) {
        return isAuthRoute ? null : Routes.login;
      }

      if (session.needsOnboarding) {
        return isOnboarding ? null : Routes.onboarding;
      }

      // Ya verificada: no tiene sentido volver a login u onboarding. Una
      // cuenta de empresa aterriza en su panel, no en el home de pasajera.
      if (isAuthRoute || isOnboarding) {
        return session.user!.accountType == AccountType.business
            ? Routes.businessHome
            : Routes.home;
      }

      // El panel empresarial es solo para cuentas de empresa.
      if (Routes.isBusinessRoute(location) &&
          session.user!.accountType != AccountType.business) {
        return Routes.home;
      }

      // Solo una conductora aprobada puede entrar al modo conductora. El
      // guard vive aquí y no en la pantalla para que no se pueda alcanzar
      // navegando directo a la URL.
      if (Routes.isDriverRoute(location)) {
        final canDrive = ref.read(driverProfileProvider).status.canDrive;
        if (!canDrive) return Routes.home;
      }

      return null;
    },

    routes: [
      GoRoute(
        path: Routes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: Routes.login,
        builder: (context, state) => const LoginScreen(),
        routes: [
          GoRoute(
            path: 'demo',
            builder: (context, state) => const DemoLoginScreen(),
          ),
          GoRoute(
            path: 'business',
            builder: (context, state) => const BusinessScreen(),
            routes: [
              GoRoute(
                path: 'apply',
                builder: (context, state) =>
                    const BusinessApplicationScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: Routes.onboarding,
        builder: (context, state) => const OnboardingFlowScreen(),
      ),

      // Las cuatro pestañas comparten un shell para que la barra flotante
      // permanezca montada y su indicador pueda animarse entre secciones.
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => ShellScaffold(child: child),
        routes: [
          GoRoute(
            path: Routes.home,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: HomeScreen()),
          ),
          GoRoute(
            path: Routes.trips,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: TripsScreen()),
          ),
          GoRoute(
            path: Routes.safety,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: SafetyScreen()),
          ),
          GoRoute(
            path: Routes.account,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: AccountScreen()),
          ),
        ],
      ),

      // Modo conductora: su propio shell, con su propia barra flotante.
      ShellRoute(
        navigatorKey: _driverShellNavigatorKey,
        builder: (context, state, child) => DriverShellScaffold(child: child),
        routes: [
          GoRoute(
            path: Routes.driveHome,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: DriverHomeScreen()),
          ),
          GoRoute(
            path: Routes.driveEarnings,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: EarningsScreen()),
          ),
          GoRoute(
            path: Routes.driveSafety,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: SafetyScreen()),
          ),
          GoRoute(
            path: Routes.driveAccount,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: DriverAccountScreen()),
          ),
        ],
      ),

      // Panel empresarial: su propio shell.
      ShellRoute(
        navigatorKey: _businessShellNavigatorKey,
        builder: (context, state, child) =>
            BusinessShellScaffold(child: child),
        routes: [
          GoRoute(
            path: Routes.businessHome,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: BusinessHomeScreen()),
          ),
          GoRoute(
            path: Routes.businessSchedule,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: BusinessScheduleScreen()),
          ),
          GoRoute(
            path: Routes.businessTeam,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: BusinessTeamScreen()),
          ),
          GoRoute(
            path: Routes.businessAccount,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: BusinessAccountScreen()),
          ),
        ],
      ),

      // Rutas de detalle: se presentan sobre el shell, cubriendo la barra.
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: Routes.profile,
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: Routes.wallet,
        builder: (context, state) => const WalletScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: Routes.help,
        builder: (context, state) => const HelpScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: Routes.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: Routes.driverApplication,
        builder: (context, state) => const DriverApplicationScreen(),
      ),

      // El chat resuelve por sí mismo a quién representa y con quién habla,
      // leyendo el modo activo y el viaje en curso. Así el mismo destino
      // sirve a pasajera y conductora sin duplicar rutas ni pasar argumentos
      // que podrían quedar desincronizados.
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: Routes.chat,
        builder: (context, state) => const TripChatRoute(),
      ),

      // El recibo recibe el viaje por `extra` en vez de por id: se abre tanto
      // desde el cierre del viaje activo como desde el historial, y en ambos
      // casos quien navega ya tiene el objeto completo. Buscarlo de nuevo por
      // id obligaría a mantener un repositorio solo para esto.
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: Routes.receipt,
        builder: (context, state) {
          final trip = state.extra;
          if (trip is! Trip) return const SizedBox.shrink();
          return ReceiptScreen(trip: trip);
        },
      ),
    ],
  );
});

/// Hace que el router reevalúe su `redirect` cuando cambia la sesión.
///
/// Sin esto, iniciar o cerrar sesión actualizaría el estado pero dejaría a la
/// usuaria parada en la pantalla anterior.
final sessionRedirectProvider = Provider<void>((ref) {
  ref.listen<SessionState>(sessionControllerProvider, (previous, next) {
    final wasSignedIn = previous?.isSignedIn ?? false;
    final stageChanged = previous?.user?.stage != next.user?.stage;

    if (wasSignedIn != next.isSignedIn || stageChanged) {
      final router = ref.read(routerProvider);
      if (!next.isSignedIn) {
        // Cerrar sesión debe limpiar también el lado de conductora; si no, la
        // siguiente usuaria en el mismo dispositivo heredaría su perfil.
        ref.read(driverProfileProvider.notifier).reset();
        ref.read(businessAccountProvider.notifier).clear();
        ref.read(tonightRidesProvider.notifier).clear();
        ref.read(appModeProvider.notifier).state = AppMode.passenger;
        router.go(Routes.login);
      } else if (next.user?.stage == VerificationStage.verified) {
        router.go(
          next.user!.accountType == AccountType.business
              ? Routes.businessHome
              : Routes.home,
        );
      } else {
        router.go(Routes.onboarding);
      }
    }
  });
});
