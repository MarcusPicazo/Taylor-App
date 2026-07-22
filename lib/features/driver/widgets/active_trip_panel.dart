import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/taylor_colors.dart';
import '../../../core/theme/taylor_theme.dart';
import '../../../core/widgets/glass_surface.dart';
import '../../../data/models/trip.dart';
import '../../../l10n/app_localizations.dart';
import '../driver_controller.dart';
import 'slide_to_confirm.dart';

/// Panel del viaje en curso.
///
/// Muestra **una sola** acción a la vez, la que corresponde a la fase actual.
/// Un panel con "llegué", "iniciar" y "terminar" simultáneos obligaría a la
/// conductora a decidir cuál toca mientras conduce; aquí no hay que elegir.
class ActiveTripPanel extends StatelessWidget {
  const ActiveTripPanel({
    super.key,
    required this.trip,
    required this.phase,
    required this.onArrived,
    required this.onStart,
    required this.onComplete,
  });

  final Trip trip;
  final DriverTripPhase phase;
  final VoidCallback onArrived;
  final VoidCallback onStart;
  final VoidCallback onComplete;

  /// A dónde hay que ir ahora: al punto de encuentro o al destino.
  TripLocation get _target => phase == DriverTripPhase.inTransit
      ? trip.destination
      : trip.origin;

  Future<void> _openNavigation() async {
    final position = _target.position;
    // `geo:` deja que el sistema elija la app de navegación instalada, en vez
    // de forzar Google Maps.
    final uri = Uri.parse(
      'geo:${position.latitude},${position.longitude}'
      '?q=${position.latitude},${position.longitude}',
    );
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: TaylorSpacing.md),
      child: GlassSurface(
        padding: const EdgeInsets.all(TaylorSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              switch (phase) {
                DriverTripPhase.headingToPickup => l10n.driveHeadingToPickup,
                DriverTripPhase.waitingForPassenger => l10n.driveWaiting,
                DriverTripPhase.inTransit => l10n.driveInTransit,
                DriverTripPhase.completed => l10n.driveCompleted,
              },
              style: theme.textTheme.labelSmall,
            ),
            const SizedBox(height: 2),
            Text(_target.address, style: theme.textTheme.titleLarge),

            const SizedBox(height: TaylorSpacing.md),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _openNavigation,
                    icon: const Icon(Icons.navigation_rounded, size: 20),
                    label: Text(l10n.driveNavigate),
                  ),
                ),
                const SizedBox(width: TaylorSpacing.sm),
                SizedBox(
                  width: 60,
                  height: 56,
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.zero,
                    ),
                    child: const Icon(Icons.call_rounded, size: 21),
                  ),
                ),
              ],
            ),

            const SizedBox(height: TaylorSpacing.md),

            // La clave por fase es imprescindible: sin ella Flutter reutiliza
            // el mismo State al cambiar de fase y el control aparecería ya
            // confirmado, saltándose el gesto de la acción siguiente.
            switch (phase) {
              DriverTripPhase.headingToPickup => SlideToConfirm(
                  key: const ValueKey('arrived'),
                  label: l10n.driveSlideArrived,
                  onConfirmed: onArrived,
                ),
              DriverTripPhase.waitingForPassenger => SlideToConfirm(
                  key: const ValueKey('start'),
                  label: l10n.driveSlideStart,
                  onConfirmed: onStart,
                  color: TaylorColors.verified,
                ),
              DriverTripPhase.inTransit => SlideToConfirm(
                  key: const ValueKey('complete'),
                  label: l10n.driveSlideComplete,
                  onConfirmed: onComplete,
                  color: TaylorColors.verified,
                ),
              DriverTripPhase.completed => const SizedBox.shrink(),
            },
          ],
        ),
      ),
    );
  }
}
