import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/widgets/floating_glass_nav_bar.dart';
import '../l10n/app_localizations.dart';
import 'router.dart';

/// Shell de navegación del panel empresarial.
///
/// "Hoy" va primero, no la agenda: quien abre esta app a las 22:30 no quiere
/// configurar horarios, quiere saber si su gente ya llegó a casa. La
/// configuración es una tarea mensual; la vigilancia es diaria.
class BusinessShellScaffold extends StatelessWidget {
  const BusinessShellScaffold({super.key, required this.child});

  final Widget child;

  static const List<String> _routes = [
    Routes.businessHome,
    Routes.businessSchedule,
    Routes.businessTeam,
    Routes.businessAccount,
  ];

  int _indexFor(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;

    final exact = _routes.indexOf(location);
    if (exact >= 0) return exact;

    // Las rutas anidan bajo /business, así que gana la coincidencia más larga.
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
            icon: Icons.nightlight_outlined,
            activeIcon: Icons.nightlight_round,
            label: l10n.bizNavTonight,
          ),
          TaylorNavDestination(
            icon: Icons.event_note_outlined,
            activeIcon: Icons.event_note_rounded,
            label: l10n.bizNavSchedule,
          ),
          TaylorNavDestination(
            icon: Icons.groups_outlined,
            activeIcon: Icons.groups_rounded,
            label: l10n.bizNavTeam,
          ),
          TaylorNavDestination(
            icon: Icons.business_outlined,
            activeIcon: Icons.business_rounded,
            label: l10n.navAccount,
          ),
        ],
      ),
    );
  }
}
