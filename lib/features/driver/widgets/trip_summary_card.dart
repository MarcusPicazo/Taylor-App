import 'package:flutter/material.dart';

import '../../../core/format/money.dart';
import '../../../core/theme/taylor_colors.dart';
import '../../../core/theme/taylor_theme.dart';
import '../../../core/widgets/glass_surface.dart';
import '../../../data/models/trip.dart';
import '../../../l10n/app_localizations.dart';
import '../../trips/widgets/star_rating.dart';

/// Resumen al terminar un viaje.
///
/// Muestra el desglose completo —bruto, comisión, neto— en lugar de solo el
/// total. Que la conductora vea exactamente qué se retuvo es parte de la
/// propuesta de Taylor: la opacidad en las ganancias es una de las quejas
/// centrales contra las plataformas existentes.
class TripSummaryCard extends StatefulWidget {
  const TripSummaryCard({
    super.key,
    required this.trip,
    required this.onDismiss,
  });

  final Trip trip;
  final VoidCallback onDismiss;

  @override
  State<TripSummaryCard> createState() => _TripSummaryCardState();
}

class _TripSummaryCardState extends State<TripSummaryCard> {
  /// Comisión de Taylor.
  static const double _commissionRate = 0.18;

  int _passengerStars = 0;

  @override
  Widget build(BuildContext context) {
    final trip = widget.trip;
    final l10n = L10n.of(context);
    final theme = Theme.of(context);
    String money(num amount) => Money.format(context, amount);

    final gross = trip.fare ?? 0;
    final commission = gross * _commissionRate;
    final net = gross - commission;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: TaylorSpacing.md),
      child: GlassSurface(
        padding: const EdgeInsets.all(TaylorSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: TaylorColors.verified.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(TaylorRadius.sm),
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: TaylorColors.verified,
                    size: 24,
                  ),
                ),
                const SizedBox(width: TaylorSpacing.sm),
                Expanded(
                  child: Text(
                    l10n.driveTripComplete,
                    style: theme.textTheme.titleLarge,
                  ),
                ),
              ],
            ),

            const SizedBox(height: TaylorSpacing.md),

            _Line(label: l10n.driveFare, value: money(gross)),
            _Line(
              label: l10n.driveCommission,
              value: '−${money(commission)}',
              muted: true,
            ),
            const SizedBox(height: 6),
            Divider(color: theme.colorScheme.outline),
            const SizedBox(height: 6),
            _Line(
              label: l10n.driveYouEarned,
              value: money(net),
              emphasized: true,
            ),

            const SizedBox(height: TaylorSpacing.md),
            Divider(color: theme.colorScheme.outline),
            const SizedBox(height: TaylorSpacing.sm),

            // Calificación mutua: la conductora también evalúa el viaje. En
            // una red cerrada de mujeres verificadas la reputación va en los
            // dos sentidos, y una pasajera problemática es tan relevante para
            // la seguridad como una conductora problemática.
            Text(
              l10n.driveRatePassenger,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: TaylorSpacing.sm),
            StarRating(
              value: _passengerStars,
              size: 38,
              onChanged: (v) => setState(() => _passengerStars = v),
            ),

            const SizedBox(height: TaylorSpacing.md),
            FilledButton(
              onPressed: widget.onDismiss,
              child: Text(l10n.done),
            ),
          ],
        ),
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({
    required this.label,
    required this.value,
    this.muted = false,
    this.emphasized = false,
  });

  final String label;
  final String value;
  final bool muted;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = emphasized
        ? theme.textTheme.titleLarge
        : theme.textTheme.bodyLarge?.copyWith(
            color: muted
                ? theme.colorScheme.onSurface.withValues(alpha: 0.6)
                : null,
          );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(
            value,
            style: emphasized
                ? style?.copyWith(color: TaylorColors.verified)
                : style,
          ),
        ],
      ),
    );
  }
}
