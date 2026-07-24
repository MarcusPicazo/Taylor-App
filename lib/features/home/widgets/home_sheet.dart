import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/taylor_colors.dart';
import '../../../core/theme/taylor_theme.dart';
import '../../../core/widgets/glass_surface.dart';
import '../../../data/places_repository.dart';
import '../../../l10n/app_localizations.dart';

/// Panel inferior de Inicio, plegable con el dedo.
///
/// Plegado muestra solo el campo de destino, que es cuanto necesita quien ya
/// sabe a dónde va, y deja ver casi todo el mapa. Desplegado responde a otra
/// pregunta —"¿a dónde suelo ir?"— con el historial reciente y los lugares
/// guardados.
///
/// Esa distinción es lo que justifica el gesto. Un panel que al desplegarse
/// solo añadiera un saludo no merecería arrastrarse.
///
/// El arrastre sigue al dedo en tiempo real y al soltar se asienta con un
/// rebote elástico. Animar solo al soltar haría que el panel se sintiera
/// desconectado de la mano.
class HomeSheet extends StatefulWidget {
  const HomeSheet({
    super.key,
    required this.userName,
    required this.recents,
    required this.onDestinationTap,
    required this.onSavedPlaceTap,
    required this.onRecentTap,
  });

  final String userName;
  final List<PlaceSuggestion> recents;
  final VoidCallback onDestinationTap;

  /// `true` para Casa, `false` para Oficina.
  final ValueChanged<bool> onSavedPlaceTap;

  final ValueChanged<PlaceSuggestion> onRecentTap;

  @override
  State<HomeSheet> createState() => _HomeSheetState();
}

class _HomeSheetState extends State<HomeSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  /// Fracción del recorrido a partir de la cual soltar despliega.
  ///
  /// Por debajo de la mitad para que abrir cueste menos que cerrar: abrir es
  /// lo que la usuaria suele estar buscando.
  static const double _settleThreshold = 0.4;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 460),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Alto de la zona plegable, que depende de cuántos recientes haya.
  double get _extraHeight => 128 + widget.recents.length * 52;

  void _onDragUpdate(DragUpdateDetails details) {
    // Arrastrar hacia arriba (dy negativo) despliega.
    _controller.value -= details.primaryDelta! / _extraHeight;
  }

  void _onDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;

    // Un gesto rápido manda sobre la posición: quien lanza el panel hacia
    // arriba quiere abrirlo aunque haya soltado a media altura.
    final shouldExpand = velocity.abs() > 400
        ? velocity < 0
        : _controller.value > _settleThreshold;

    HapticFeedback.lightImpact();
    _settle(shouldExpand);
  }

  void _settle(bool expand) {
    // La curva elástica es lo que da el carácter juguetón: el panel se pasa
    // ligeramente y vuelve, como si tuviera masa.
    _controller.animateTo(
      expand ? 1 : 0,
      duration: const Duration(milliseconds: 460),
      curve: expand ? Curves.easeOutBack : Curves.easeOutCubic,
    );
  }

  void _toggle() {
    HapticFeedback.lightImpact();
    _settle(_controller.value < 0.5);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        // easeOutBack se pasa de 1, así que el factor de alto se limita para
        // que el recorte no intente dibujar más de lo que hay.
        final t = _controller.value.clamp(0.0, 1.0);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: TaylorSpacing.md),
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
                // El arrastre vive SOLO en el asa, no en todo el panel.
                //
                // Envolviendo el panel entero, un toque en una fila que se
                // desviaba un par de píxeles se interpretaba como arrastre y
                // plegaba el panel en lugar de elegir el destino. Es la misma
                // razón por la que iOS y Android limitan el gesto al agarre.
                GestureDetector(
                  onVerticalDragUpdate: _onDragUpdate,
                  onVerticalDragEnd: _onDragEnd,
                  onTap: _toggle,
                  behavior: HitTestBehavior.opaque,
                  child: _Handle(expansion: t),
                ),

                // Zona que solo existe desplegada. Se animan alto y opacidad a
                // la vez: solo opacidad dejaría un hueco, solo alto haría un
                // recorte brusco.
                ClipRect(
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    heightFactor: t,
                    child: Opacity(
                      // Aparece más rápido de lo que crece, para que no se vea
                      // texto cortado a media altura.
                      opacity: (t * 1.7).clamp(0.0, 1.0),
                      // Sin interacción mientras está plegándose: si no, se
                      // podría tocar una fila a medio desaparecer.
                      child: IgnorePointer(
                        ignoring: t < 0.85,
                        child: _ExpandedContent(
                          userName: widget.userName,
                          recents: widget.recents,
                          onSavedPlaceTap: widget.onSavedPlaceTap,
                          onRecentTap: widget.onRecentTap,
                        ),
                      ),
                    ),
                  ),
                ),

                // Campo de destino: siempre visible. Es la acción principal de
                // la pantalla, plegado o no.
                _DestinationField(
                  label: l10n.homeDestination,
                  onTap: widget.onDestinationTap,
                  theme: theme,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Asa de arrastre.
///
/// Se ensancha al desplegar —un detalle pequeño que hace que el panel se
/// sienta elástico— y reserva una franja de 32 px de alto: la barra visible
/// mide 4 px, que sería un objetivo imposible de agarrar.
class _Handle extends StatelessWidget {
  const _Handle({required this.expansion});

  final double expansion;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      width: double.infinity,
      child: Center(
        child: AnimatedContainer(
          duration: TaylorMotion.fast,
          width: 34 + expansion * 14,
          height: 4,
          decoration: BoxDecoration(
            color: TaylorColors.inkFaint.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}

class _ExpandedContent extends StatelessWidget {
  const _ExpandedContent({
    required this.userName,
    required this.recents,
    required this.onSavedPlaceTap,
    required this.onRecentTap,
  });

  final String userName;
  final List<PlaceSuggestion> recents;
  final ValueChanged<bool> onSavedPlaceTap;
  final ValueChanged<PlaceSuggestion> onRecentTap;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (userName.isNotEmpty)
          Text(
            l10n.homeGreeting(userName),
            style: theme.textTheme.bodySmall,
          ),
        Text(l10n.homeWhereTo, style: theme.textTheme.headlineMedium),

        const SizedBox(height: TaylorSpacing.sm),

        Row(
          children: [
            Expanded(
              child: _SavedPlace(
                icon: Icons.home_rounded,
                label: l10n.homeSavedHome,
                onTap: () => onSavedPlaceTap(true),
              ),
            ),
            const SizedBox(width: TaylorSpacing.sm),
            Expanded(
              child: _SavedPlace(
                icon: Icons.work_outline_rounded,
                label: l10n.homeSavedWork,
                onTap: () => onSavedPlaceTap(false),
              ),
            ),
          ],
        ),

        if (recents.isNotEmpty) ...[
          const SizedBox(height: TaylorSpacing.md),
          Text(l10n.homeRecent, style: theme.textTheme.labelSmall),
          const SizedBox(height: 4),
          for (final place in recents)
            _RecentRow(place: place, onTap: () => onRecentTap(place)),
        ],

        const SizedBox(height: TaylorSpacing.sm),
      ],
    );
  }
}

class _RecentRow extends StatelessWidget {
  const _RecentRow({required this.place, required this.onTap});

  final PlaceSuggestion place;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(TaylorRadius.sm),
      child: SizedBox(
        height: 52,
        child: Row(
          children: [
            Icon(
              place.isSaved ? Icons.star_rounded : Icons.history_rounded,
              size: 19,
              color: TaylorColors.inkFaint,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    place.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelLarge,
                  ),
                  Text(
                    place.address,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DestinationField extends StatelessWidget {
  const _DestinationField({
    required this.label,
    required this.onTap,
    required this.theme,
  });

  final String label;
  final VoidCallback onTap;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(TaylorRadius.md),
          border: Border.all(color: theme.colorScheme.outline),
        ),
        child: Row(
          children: [
            const Icon(Icons.search_rounded, color: TaylorColors.raspberry),
            const SizedBox(width: 12),
            Text(
              label,
              style: theme.textTheme.bodyLarge
                  ?.copyWith(color: TaylorColors.inkFaint),
            ),
          ],
        ),
      ),
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
