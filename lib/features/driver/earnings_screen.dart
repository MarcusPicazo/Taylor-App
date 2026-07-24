import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/format/money.dart';
import '../../core/theme/taylor_colors.dart';
import '../../core/theme/taylor_theme.dart';
import '../../data/models/driver_profile.dart';
import '../../l10n/app_localizations.dart';
import 'driver_controller.dart';

/// Ganancias de la conductora.
///
/// Todo lo que se muestra es **neto** —lo que efectivamente le queda— salvo
/// donde se etiqueta lo contrario. Encabezar con el bruto infla la cifra y
/// obliga a hacer cuentas mentales; la marca no puede permitirse eso si dice
/// que su modelo económico es distinto.
class EarningsScreen extends ConsumerWidget {
  const EarningsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = L10n.of(context);
    final theme = Theme.of(context);
    final profile = ref.watch(driverProfileProvider);
    String money(num amount) => Money.format(context, amount);

    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    final startOfWeek = startOfToday.subtract(
      Duration(days: now.weekday - 1),
    );

    final today = profile.earningsSince(startOfToday);
    final week = profile.earningsSince(startOfWeek);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            TaylorSpacing.md,
            TaylorSpacing.md,
            TaylorSpacing.md,
            TaylorSpacing.navBarClearance,
          ),
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Text(
                l10n.driveEarningsTitle,
                style: theme.textTheme.displayMedium,
              ),
            ),
            const SizedBox(height: TaylorSpacing.md),

            // Tarjeta principal: hoy.
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(TaylorSpacing.lg),
              decoration: BoxDecoration(
                gradient: TaylorColors.brandGradient,
                borderRadius: BorderRadius.circular(TaylorRadius.lg),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.driveToday,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: TaylorColors.white.withValues(alpha: 0.86),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    money(today),
                    style: theme.textTheme.displayLarge?.copyWith(
                      color: TaylorColors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.driveTripsCount(
                      profile.tripsSince(startOfToday),
                    ),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: TaylorColors.white.withValues(alpha: 0.86),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: TaylorSpacing.sm),

            Row(
              children: [
                Expanded(
                  child: _StatTile(
                    label: l10n.driveThisWeek,
                    value: money(week),
                  ),
                ),
                const SizedBox(width: TaylorSpacing.sm),
                Expanded(
                  child: _StatTile(
                    label: l10n.driveRating,
                    value: profile.rating.toStringAsFixed(2),
                    icon: Icons.star_rounded,
                  ),
                ),
              ],
            ),

            const SizedBox(height: TaylorSpacing.lg),

            Text(l10n.driveRecentTrips, style: theme.textTheme.titleMedium),
            const SizedBox(height: TaylorSpacing.sm),

            if (profile.earnings.isEmpty)
              Container(
                padding: const EdgeInsets.all(TaylorSpacing.md),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(TaylorRadius.lg),
                  border: Border.all(color: theme.colorScheme.outline),
                ),
                child: Text(
                  l10n.driveNoEarnings,
                  style: theme.textTheme.bodyMedium,
                ),
              )
            else
              for (final entry in profile.earnings)
                _EarningRow(entry: entry),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    this.icon,
  });

  final String label;
  final String value;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(TaylorSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(TaylorRadius.lg),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.labelSmall),
          const SizedBox(height: 4),
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20, color: TaylorColors.caution),
                const SizedBox(width: 4),
              ],
              Text(value, style: theme.textTheme.headlineMedium),
            ],
          ),
        ],
      ),
    );
  }
}

class _EarningRow extends StatelessWidget {
  const _EarningRow({required this.entry});

  final EarningEntry entry;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final theme = Theme.of(context);
    String money(num amount) => Money.format(context, amount);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(TaylorSpacing.sm),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(TaylorRadius.md),
          border: Border.all(color: theme.colorScheme.outline),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat.MMMEd(
                      Localizations.localeOf(context).toLanguageTag(),
                    ).add_jm().format(entry.completedAt),
                    style: theme.textTheme.labelLarge,
                  ),
                  Text(
                    '${entry.distanceKm.toStringAsFixed(1)} km',
                    style: theme.textTheme.labelSmall,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  money(entry.net),
                  style: theme.textTheme.titleMedium,
                ),
                if (entry.tip > 0)
                  Text(
                    l10n.driveIncludesTip(money(entry.tip)),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: TaylorColors.verified,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
