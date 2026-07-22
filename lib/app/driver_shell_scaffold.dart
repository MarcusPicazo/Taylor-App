import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/widgets/floating_glass_nav_bar.dart';
import '../l10n/app_localizations.dart';
import 'router.dart';

/// Shell de navegación del modo conductora.
///
/// Comparte la barra flotante de cristal con el modo pasajera para que la app
/// se sienta una sola, pero las secciones son distintas: quien conduce no
/// necesita "pedir un viaje", necesita saber cuánto lleva ganado.
class DriverShellScaffold extends StatelessWidget {
  const DriverShellScaffold({super.key, required this.child});

  final Widget child;

  static const List<String> _routes = [
    Routes.driveHome,
    Routes.driveEarnings,
    Routes.driveSafety,
    Routes.driveAccount,
  ];

  /// Índice de la pestaña activa.
  ///
  /// A diferencia del shell de pasajera, aquí las rutas anidan: `/drive` es
  /// prefijo de `/drive/earnings`. Un `startsWith` simple marcaría siempre la
  /// primera pestaña, así que se compara por coincidencia exacta y solo se
  /// recurre al prefijo para subrutas más profundas.
  int _indexFor(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;

    final exact = _routes.indexOf(location);
    if (exact >= 0) return exact;

    // Subruta: gana la coincidencia más larga (`/drive/earnings/x` → Ganancias,
    // no Conducir).
    var best = 0;
    var bestLength = 0;
    for (var i = 0; i < _routes.length; i++) {
      final route = _routes[i];
      if (location.startsWith('$route/') && route.length > bestLength) {
        best = i;
        bestLength = route.length;
      }
    }
    return best;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final index = _indexFor(context);

    return Scaffold(
      extendBody: true,
      body: child,
      bottomNavigationBar: FloatingGlassNavBar(
        currentIndex: index,
        onTap: (i) {
          if (i == index) return;
          context.go(_routes[i]);
        },
        destinations: [
          TaylorNavDestination(
            icon: Icons.drive_eta_outlined,
            activeIcon: Icons.drive_eta_rounded,
            label: l10n.driveNavDrive,
          ),
          TaylorNavDestination(
            icon: Icons.payments_outlined,
            activeIcon: Icons.payments_rounded,
            label: l10n.driveNavEarnings,
          ),
          TaylorNavDestination(
            icon: Icons.shield_outlined,
            activeIcon: Icons.shield_rounded,
            label: l10n.navSafety,
          ),
          TaylorNavDestination(
            icon: Icons.person_outline_rounded,
            activeIcon: Icons.person_rounded,
            label: l10n.navAccount,
          ),
        ],
      ),
    );
  }
}
