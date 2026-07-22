import 'package:flutter/material.dart';

import '../theme/taylor_colors.dart';
import '../theme/taylor_theme.dart';
import 'glass_surface.dart';

class TaylorNavDestination {
  const TaylorNavDestination({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
}

/// Barra de navegación inferior flotante, en glassmorphism.
///
/// Flota sobre el contenido en lugar de anclarse al borde, de modo que el mapa
/// se ve a través de ella. Un indicador con gradiente de marca se desliza entre
/// pestañas en lugar de aparecer y desaparecer: el movimiento continuo es lo
/// que hace que la barra se sienta "líquida".
class FloatingGlassNavBar extends StatelessWidget {
  const FloatingGlassNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.destinations,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<TaylorNavDestination> destinations;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        TaylorSpacing.md,
        0,
        TaylorSpacing.md,
        // En dispositivos con home indicator ya hay separación física; sin él
        // hace falta un margen propio para que la barra no toque el borde.
        bottomInset > 0 ? bottomInset * 0.5 : TaylorSpacing.md,
      ),
      child: GlassSurface(
        borderRadius: BorderRadius.circular(TaylorRadius.xl),
        blur: 30,
        child: SizedBox(
          height: 68,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final itemWidth = constraints.maxWidth / destinations.length;

              return Stack(
                children: [
                  // Indicador deslizante.
                  AnimatedPositioned(
                    duration: TaylorMotion.normal,
                    curve: TaylorMotion.emphasized,
                    left: itemWidth * currentIndex,
                    top: 0,
                    bottom: 0,
                    width: itemWidth,
                    child: Center(
                      child: AnimatedContainer(
                        duration: TaylorMotion.normal,
                        curve: TaylorMotion.emphasized,
                        width: itemWidth - 14,
                        height: 52,
                        decoration: BoxDecoration(
                          gradient: TaylorColors.brandGradient,
                          borderRadius:
                              BorderRadius.circular(TaylorRadius.md),
                          boxShadow: [
                            BoxShadow(
                              color: TaylorColors.raspberry
                                  .withValues(alpha: 0.38),
                              blurRadius: 18,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      for (var i = 0; i < destinations.length; i++)
                        Expanded(
                          child: _NavItem(
                            destination: destinations[i],
                            selected: i == currentIndex,
                            onTap: () => onTap(i),
                          ),
                        ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  final TaylorNavDestination destination;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inactive = isDark
        ? TaylorColors.white.withValues(alpha: 0.66)
        : TaylorColors.inkMuted;
    final color = selected ? TaylorColors.white : inactive;

    return Semantics(
      button: true,
      selected: selected,
      label: destination.label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(TaylorRadius.md),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedSwitcher(
              duration: TaylorMotion.fast,
              child: Icon(
                selected ? destination.activeIcon : destination.icon,
                key: ValueKey(selected),
                size: 23,
                color: color,
              ),
            ),
            const SizedBox(height: 3),
            AnimatedDefaultTextStyle(
              duration: TaylorMotion.fast,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 11,
                height: 1.1,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                color: color,
              ),
              child: Text(
                destination.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
