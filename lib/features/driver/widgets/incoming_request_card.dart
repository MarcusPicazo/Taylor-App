import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/format/money.dart';
import '../../../core/theme/taylor_colors.dart';
import '../../../core/theme/taylor_theme.dart';
import '../../../core/widgets/glass_surface.dart';
import '../../../l10n/app_localizations.dart';
import '../driver_controller.dart';

/// Solicitud entrante, con cuenta regresiva.
///
/// La barra de tiempo se agota visualmente en lugar de mostrar segundos: al
/// volante, una barra que se vacía se interpreta de un vistazo y un número hay
/// que leerlo. Aceptar y rechazar están bien separados y son grandes, porque
/// un error aquí afecta a alguien que está esperando en la calle.
class IncomingRequestCard extends StatefulWidget {
  const IncomingRequestCard({
    super.key,
    required this.request,
    required this.onAccept,
    required this.onDecline,
  });

  final IncomingRequest request;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  @override
  State<IncomingRequestCard> createState() => _IncomingRequestCardState();
}

class _IncomingRequestCardState extends State<IncomingRequestCard> {
  late Timer _ticker;
  double _fraction = 1;

  /// Duración total de la ventana, para calcular la fracción restante.
  late final Duration _total = widget.request.remaining;

  @override
  void initState() {
    super.initState();

    HapticFeedback.heavyImpact();

    // 60 ms mantiene la barra fluida sin reconstruir la tarjeta en exceso.
    _ticker = Timer.periodic(const Duration(milliseconds: 60), (_) {
      if (!mounted) return;
      final remaining = widget.request.remaining;
      final total = _total.inMilliseconds;
      setState(() {
        _fraction = total == 0
            ? 0
            : (remaining.inMilliseconds / total).clamp(0.0, 1.0);
      });
    });
  }

  @override
  void dispose() {
    _ticker.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final theme = Theme.of(context);
    final request = widget.request;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: TaylorSpacing.md),
      child: GlassSurface(
        padding: EdgeInsets.zero,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // La barra de tiempo va arriba del todo, pegada al borde: es lo
            // primero que entra por la visión periférica.
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(TaylorRadius.lg),
              ),
              child: LinearProgressIndicator(
                value: _fraction,
                minHeight: 6,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation(
                  // Se vuelve rojo en el último tercio: el cambio de color
                  // avisa sin necesidad de leer nada.
                  _fraction < 0.33
                      ? TaylorColors.emergency
                      : TaylorColors.raspberry,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(TaylorSpacing.md),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n.driveNewRequest,
                          style: theme.textTheme.labelSmall,
                        ),
                      ),
                      Text(
                        // Sin centavos: al volante, "$154" se lee de un
                        // vistazo y "$154.00" obliga a enfocar.
                        Money.formatCompact(context, request.estimatedFare),
                        style: theme.textTheme.displayMedium?.copyWith(
                          color: TaylorColors.raspberry,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: TaylorSpacing.sm),

                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor:
                            TaylorColors.raspberry.withValues(alpha: 0.14),
                        child: Text(
                          request.passengerName[0],
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: TaylorColors.raspberry,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              request.passengerName,
                              style: theme.textTheme.titleMedium,
                            ),
                            Row(
                              children: [
                                const Icon(
                                  Icons.star_rounded,
                                  size: 14,
                                  color: TaylorColors.caution,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  request.passengerRating.toStringAsFixed(2),
                                  style: theme.textTheme.labelSmall,
                                ),
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.verified_rounded,
                                  size: 14,
                                  color: TaylorColors.verified,
                                ),
                                const SizedBox(width: 2),
                                Flexible(
                                  child: Text(
                                    l10n.safetyBadgeVerified,
                                    style: theme.textTheme.labelSmall
                                        ?.copyWith(
                                      color: TaylorColors.verified,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: TaylorSpacing.sm),
                  Divider(color: theme.colorScheme.outline),
                  const SizedBox(height: TaylorSpacing.sm),

                  _Leg(
                    icon: Icons.trip_origin_rounded,
                    color: TaylorColors.raspberry,
                    title: l10n.driveMinutesAway(request.minutesToPickup),
                    subtitle: request.trip.origin.address,
                  ),
                  const SizedBox(height: 10),
                  _Leg(
                    icon: Icons.place_rounded,
                    color: theme.colorScheme.onSurface,
                    title: l10n.driveTripLength(
                      request.trip.distanceKm?.toStringAsFixed(1) ?? '—',
                      request.trip.durationMinutes ?? 0,
                    ),
                    subtitle: request.trip.destination.address,
                  ),

                  const SizedBox(height: TaylorSpacing.md),

                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: SizedBox(
                          height: 60,
                          child: OutlinedButton(
                            onPressed: widget.onDecline,
                            child: Text(l10n.driveDecline),
                          ),
                        ),
                      ),
                      const SizedBox(width: TaylorSpacing.sm),
                      Expanded(
                        flex: 3,
                        child: SizedBox(
                          height: 60,
                          child: FilledButton(
                            onPressed: widget.onAccept,
                            child: Text(l10n.driveAccept),
                          ),
                        ),
                      ),
                    ],
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

class _Leg extends StatelessWidget {
  const _Leg({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.textTheme.labelLarge),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
