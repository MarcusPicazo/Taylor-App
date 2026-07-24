import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/taylor_colors.dart';
import '../../../core/theme/taylor_theme.dart';
import '../../../core/widgets/glass_surface.dart';
import '../../../l10n/app_localizations.dart';

/// Panel inferior de Inicio, plegable con el dedo.
///
/// Plegado muestra solo el campo de destino; desplegado añade el saludo y los
/// lugares guardados. La razón es el mapa: plegado deja ver casi toda la
/// ciudad, y quien ya sabe a dónde va no necesita nada más.
///
/// El arrastre sigue al dedo en tiempo real en lugar de animar al soltar. Un
/// panel que "salta" al final del gesto se siente desconectado de la mano;
/// éste se mueve con ella y solo al soltar decide a qué extremo asentarse,
/// según posición y velocidad.
class HomeSheet extends StatefulWidget {
  const HomeSheet({
    super.key,
    required this.userName,
    required this.onDestinationTap,
    required this.onSavedPlaceTap,
  });

  final String userName;
  final VoidCallback onDestinationTap;

  /// `true` para Casa, `false` para Oficina.
  final ValueChanged<bool> onSavedPlaceTap;

  @override
  State<HomeSheet> createState() => _HomeSheetState();
}

class _HomeSheetState extends State<HomeSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  /// Alto de la parte que aparece solo al desplegar.
  static const double _expandedExtra = 132;

  /// Fracción del recorrido a partir de la cual soltar despliega en vez de
  /// plegar. Por debajo de la mitad para que desplegar cueste menos que
  /// plegar: es la acción que la usuaria suele buscar.
  static const double _settleThreshold = 0.4;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: TaylorMotion.normal,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    // Arrastrar hacia arriba (dy negativo) despliega.
    _controller.value -= details.primaryDelta! / _expandedExtra;
  }

  void _onDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;

    // Un gesto rápido manda por encima de la posición: si alguien lanza el
    // panel hacia arriba, quiere abrirlo aunque haya soltado abajo.
    final shouldExpand = velocity.abs() > 400
        ? velocity < 0
        : _controller.value > _settleThreshold;

    HapticFeedback.selectionClick();

    if (shouldExpand) {
      _controller.fling(velocity: 2);
    } else {
      _controller.fling(velocity: -2);
    }
  }

  void _toggle() {
    HapticFeedback.selectionClick();
    _controller.fling(velocity: _controller.value > 0.5 ? -2 : 2);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = Curves.easeOutCubic.transform(_controller.value);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: TaylorSpacing.md),
          child: GestureDetector(
            onVerticalDragUpdate: _onDragUpdate,
            onVerticalDragEnd: _onDragEnd,
            child: GlassSurface(
              padding: const EdgeInsets.fromLTRB(
                TaylorSpacing.md,
                8,
                TaylorSpacing.md,
                TaylorSpacing.md,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Asa de arrastre. Además de indicar que el panel se mueve,
                  // es un objetivo táctil para quien prefiera tocar a arrastrar.
                  GestureDetector(
                    onTap: _toggle,
                    behavior: HitTestBehavior.opaque,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Container(
                          width: 38,
                          height: 4,
                          decoration: BoxDecoration(
                            color: TaylorColors.inkFaint
                                .withValues(alpha: 0.45),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Zona que solo existe desplegada. Se anima el alto y la
                  // opacidad a la vez; animar solo la opacidad dejaría un
                  // hueco vacío, y solo el alto produciría un recorte brusco.
                  ClipRect(
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      heightFactor: t,
                      child: Opacity(
                        // Se desvanece más rápido de lo que se pliega, para
                        // que el texto no se vea cortado a media altura.
                        opacity: (t * 1.6).clamp(0.0, 1.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (widget.userName.isNotEmpty)
                              Text(
                                l10n.homeGreeting(widget.userName),
                                style: theme.textTheme.bodySmall,
                              ),
                            Text(
                              l10n.homeWhereTo,
                              style: theme.textTheme.headlineMedium,
                            ),
                            const SizedBox(height: TaylorSpacing.md),
                            Row(
                              children: [
                                Expanded(
                                  child: _SavedPlace(
                                    icon: Icons.home_rounded,
                                    label: l10n.homeSavedHome,
                                    onTap: () =>
                                        widget.onSavedPlaceTap(true),
                                  ),
                                ),
                                const SizedBox(width: TaylorSpacing.sm),
                                Expanded(
                                  child: _SavedPlace(
                                    icon: Icons.work_outline_rounded,
                                    label: l10n.homeSavedWork,
                                    onTap: () =>
                                        widget.onSavedPlaceTap(false),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: TaylorSpacing.sm),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Campo de destino: siempre visible, plegado o no. Es la
                  // acción principal de la pantalla.
                  GestureDetector(
                    onTap: widget.onDestinationTap,
                    child: Container(
                      height: 56,
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius:
                            BorderRadius.circular(TaylorRadius.md),
                        border:
                            Border.all(color: theme.colorScheme.outline),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.search_rounded,
                            color: TaylorColors.raspberry,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            l10n.homeDestination,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: TaylorColors.inkFaint,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SavedPlace extends StatelessWidget {
  const _SavedPlace({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(TaylorRadius.md),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: TaylorSpacing.sm,
          vertical: 14,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(TaylorRadius.md),
          border: Border.all(color: theme.colorScheme.outline),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: TaylorColors.raspberry),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelLarge,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
