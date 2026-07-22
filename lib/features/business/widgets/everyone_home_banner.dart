import 'package:flutter/material.dart';

import '../../../core/theme/taylor_colors.dart';
import '../../../core/theme/taylor_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../business_controller.dart';

/// Estado global de la noche.
///
/// Tiene tres formas, y la distinción importa: "alguien necesita atención" es
/// urgente y se pinta en rojo, "aún hay gente fuera" es normal y se pinta en
/// rosa de marca, y "todas llegaron" es el cierre y se pinta en verde. Un solo
/// color para los tres obligaría a leer el número para saber si hay problema.
class EveryoneHomeBanner extends StatelessWidget {
  const EveryoneHomeBanner({super.key, required this.summary});

  final TonightSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final theme = Theme.of(context);

    final (color, icon, title, body) = switch (summary) {
      _ when summary.needsAttention > 0 => (
          TaylorColors.emergency,
          Icons.error_outline_rounded,
          l10n.bizNeedsAttention(summary.needsAttention),
          l10n.bizNeedsAttentionBody,
        ),
      _ when summary.everyoneHome => (
          TaylorColors.verified,
          Icons.check_circle_rounded,
          l10n.bizEveryoneHome,
          l10n.bizEveryoneHomeBody,
        ),
      _ => (
          TaylorColors.raspberry,
          Icons.share_location_rounded,
          l10n.bizStillTravelling(summary.open),
          l10n.bizStillTravellingBody,
        ),
    };

    return AnimatedContainer(
      duration: TaylorMotion.normal,
      curve: TaylorMotion.standard,
      padding: const EdgeInsets.all(TaylorSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(TaylorRadius.lg),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: TaylorSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: color,
                      ),
                    ),
                    Text(body, style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: TaylorSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(TaylorRadius.pill),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: summary.progress),
              duration: TaylorMotion.slow,
              curve: TaylorMotion.emphasized,
              builder: (context, value, _) => LinearProgressIndicator(
                value: value,
                minHeight: 6,
                backgroundColor: color.withValues(alpha: 0.16),
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
