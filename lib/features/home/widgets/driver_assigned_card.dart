import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../app/router.dart';
import '../../../core/theme/taylor_colors.dart';
import '../../../core/theme/taylor_theme.dart';
import '../../../core/widgets/glass_surface.dart';
import '../../../data/models/trip.dart';
import '../../../l10n/app_localizations.dart';

/// Tarjeta de la conductora asignada.
///
/// Lo primero que se ve es quién es ella y su verificación; la placa y el coche
/// vienen después. El orden está pensado para el momento real de uso: la
/// pasajera está en la banqueta comprobando que la persona del coche es la
/// misma que la de la pantalla.
class DriverAssignedCard extends StatelessWidget {
  const DriverAssignedCard({
    super.key,
    required this.trip,
    required this.onCancel,
  });

  final Trip trip;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final theme = Theme.of(context);
    final driver = trip.driver;

    if (driver == null) return const SizedBox.shrink();

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
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: TaylorColors.brandGradient,
                    borderRadius: BorderRadius.circular(TaylorRadius.md),
                    image: driver.photoUrl != null
                        ? DecorationImage(
                            image: NetworkImage(driver.photoUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: driver.photoUrl == null
                      ? Text(
                          driver.name[0],
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: TaylorColors.white,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: TaylorSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(driver.name, style: theme.textTheme.titleMedium),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(
                            Icons.verified_rounded,
                            size: 15,
                            color: TaylorColors.verified,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              l10n.driverVerified,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: TaylorColors.verified,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 17,
                          color: TaylorColors.caution,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          driver.rating.toStringAsFixed(2),
                          style: theme.textTheme.labelLarge,
                        ),
                      ],
                    ),
                    Text(
                      l10n.driverTrips(driver.tripCount),
                      style: theme.textTheme.labelSmall,
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: TaylorSpacing.sm),
            Divider(color: theme.colorScheme.outline),
            const SizedBox(height: TaylorSpacing.sm),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(driver.carModel, style: theme.textTheme.bodyLarge),
                      Text(
                        driver.plate,
                        style: theme.textTheme.labelSmall,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: TaylorColors.raspberry.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(TaylorRadius.pill),
                  ),
                  child: Text(
                    l10n.driverArrivingIn(trip.durationMinutes ?? 4),
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: TaylorColors.brandText,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: TaylorSpacing.md),

            Row(
              children: [
                Expanded(
                  child: _ActionChip(
                    icon: Icons.call_rounded,
                    label: l10n.callDriver,
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _ActionChip(
                    icon: Icons.chat_bubble_outline_rounded,
                    label: l10n.messageDriver,
                    onTap: () => context.push(Routes.chat),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _ActionChip(
                    icon: Icons.ios_share_rounded,
                    label: l10n.shareTrip,
                    highlighted: true,
                    onTap: () => Share.share(
                      '${driver.name} · ${driver.plate}\n'
                      '${trip.origin.address} → ${trip.destination.address}',
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: TaylorSpacing.sm),
            TextButton(
              onPressed: onCancel,
              child: Text(
                l10n.cancelTrip,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: TaylorColors.inkMuted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
    this.highlighted = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color =
        highlighted ? TaylorColors.raspberry : theme.colorScheme.onSurface;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(TaylorRadius.md),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(TaylorRadius.md),
          color: highlighted
              ? TaylorColors.raspberry.withValues(alpha: 0.1)
              : null,
          border: Border.all(
            color: highlighted
                ? Colors.transparent
                : theme.colorScheme.outline,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}
