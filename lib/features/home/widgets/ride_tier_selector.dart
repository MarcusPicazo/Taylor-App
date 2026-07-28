import 'package:flutter/material.dart';

import '../../../core/format/money.dart';
import '../../../core/theme/taylor_colors.dart';
import '../../../core/theme/taylor_theme.dart';
import '../../../core/widgets/car_icon.dart';
import '../../../core/widgets/pressable.dart';
import '../../../data/models/ride_tier.dart';
import '../../../l10n/app_localizations.dart';

/// Elección de categoría de viaje.
///
/// Las tres opciones se muestran a la vez, no en un desplegable: la decisión
/// es comparativa —precio contra capacidad contra espera— y esconderlas
/// obligaría a memorizar cifras entre pantallas.
class RideTierSelector extends StatelessWidget {
  const RideTierSelector({
    super.key,
    required this.selected,
    required this.onSelected,
    required this.distanceKm,
    required this.minutes,
    required this.pickupMinutes,
  });

  final RideTier selected;
  final ValueChanged<RideTier> onSelected;
  final double distanceKm;
  final int minutes;
  final int pickupMinutes;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final tier in RideTier.values)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _TierRow(
              tier: tier,
              isSelected: tier == selected,
              fare: tier.estimateFare(
                distanceKm: distanceKm,
                minutes: minutes,
              ),
              pickupMinutes: tier.pickupMinutes(pickupMinutes),
              // El háptico lo da Pressable; aquí solo la selección.
              onTap: () => onSelected(tier),
            ),
          ),
      ],
    );
  }
}

class _TierRow extends StatelessWidget {
  const _TierRow({
    required this.tier,
    required this.isSelected,
    required this.fare,
    required this.pickupMinutes,
    required this.onTap,
  });

  final RideTier tier;
  final bool isSelected;
  final double fare;
  final int pickupMinutes;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final theme = Theme.of(context);

    return Pressable(
      onTap: onTap,
      borderRadius: BorderRadius.circular(TaylorRadius.md),
      child: AnimatedContainer(
        duration: TaylorMotion.fast,
        curve: TaylorMotion.emphasized,
        padding: const EdgeInsets.symmetric(
          horizontal: TaylorSpacing.sm,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? TaylorColors.raspberry.withValues(alpha: 0.09)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(TaylorRadius.md),
          border: Border.all(
            color: isSelected
                ? TaylorColors.raspberry
                : theme.colorScheme.outline,
            width: isSelected ? 1.6 : 1,
          ),
        ),
        child: Row(
          children: [
            // El coche crece un poco al seleccionarse: refuerza la elección
            // sin necesidad de una marca de verificación extra.
            AnimatedScale(
              duration: TaylorMotion.fast,
              curve: Curves.easeOutBack,
              scale: isSelected ? 1.08 : 0.95,
              child: CarIcon(
                tier: tier,
                size: 62,
                color: isSelected
                    ? TaylorColors.raspberry
                    : TaylorColors.inkMuted,
                muted: !isSelected,
              ),
            ),
            const SizedBox(width: TaylorSpacing.sm),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          tier.displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.person_rounded,
                        size: 13,
                        color: TaylorColors.inkFaint,
                      ),
                      Text(
                        '${tier.seats}',
                        style: theme.textTheme.labelSmall,
                      ),
                    ],
                  ),
                  Text(
                    l10n.tierArrivesIn(pickupMinutes),
                    style: theme.textTheme.labelSmall,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),
            Text(
              Money.formatCompact(context, fare),
              style: theme.textTheme.titleLarge?.copyWith(
                color: isSelected ? TaylorColors.brandText : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
