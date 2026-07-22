import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/widgets/floating_glass_nav_bar.dart';
import '../l10n/app_localizations.dart';
import 'router.dart';

/// Contenedor de las cuatro secciones principales.
///
/// El contenido se extiende por debajo de la barra (`extendBody: true`) para
/// que el mapa y las listas se vean a través del cristal. Cada pantalla
/// reserva `TaylorSpacing.navBarClearance` al final de su scroll.
class ShellScaffold extends StatelessWidget {
  const ShellScaffold({super.key, required this.child});

  final Widget child;

  static const List<String> _routes = [
    Routes.home,
    Routes.trips,
    Routes.safety,
    Routes.account,
  ];

  int _indexFor(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final index = _routes.indexWhere(location.startsWith);
    return index < 0 ? 0 : index;
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
            icon: Icons.near_me_outlined,
            activeIcon: Icons.near_me_rounded,
            label: l10n.navHome,
          ),
          TaylorNavDestination(
            icon: Icons.receipt_long_outlined,
            activeIcon: Icons.receipt_long_rounded,
            label: l10n.navTrips,
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
