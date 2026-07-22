import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme/taylor_colors.dart';
import '../../core/theme/taylor_theme.dart';
import '../../data/models/business_account.dart';
import '../../l10n/app_localizations.dart';
import 'business_controller.dart';
import 'widgets/employee_ride_tile.dart';
import 'widgets/everyone_home_banner.dart';

/// Vista "Hoy": el estado en vivo de los traslados de esta noche.
///
/// Es la razón de ser del panel. La responsabilidad de una empresa que manda a
/// su personal a casa de noche no termina cuando suben al coche, termina
/// cuando llegan. Esta pantalla existe para responder una sola pregunta a las
/// 23:40: **¿ya llegaron todas?**
///
/// Por eso el orden de la lista no es alfabético ni cronológico, sino por
/// urgencia: primero quien necesita atención, luego quien sigue fuera, y al
/// final quien ya llegó.
class BusinessHomeScreen extends ConsumerWidget {
  const BusinessHomeScreen({super.key});

  /// Prioridad de atención. Menor número = más arriba.
  int _priority(EmployeeRideStatus status) => switch (status) {
        EmployeeRideStatus.noShow => 0,
        EmployeeRideStatus.assigning => 1,
        EmployeeRideStatus.driverAssigned => 2,
        EmployeeRideStatus.inTransit => 3,
        EmployeeRideStatus.scheduled => 4,
        EmployeeRideStatus.arrived => 5,
        EmployeeRideStatus.cancelled => 6,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = L10n.of(context);
    final theme = Theme.of(context);
    final account = ref.watch(businessAccountProvider);
    final rides = ref.watch(tonightRidesProvider);
    final summary = ref.watch(tonightSummaryProvider);
    final locale = Localizations.localeOf(context).toLanguageTag();

    if (account == null) return const SizedBox.shrink();

    final sorted = [...rides]..sort(
        (a, b) => _priority(a.status).compareTo(_priority(b.status)),
      );

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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    account.companyName,
                    style: theme.textTheme.bodySmall,
                  ),
                  Text(
                    l10n.bizTonight,
                    style: theme.textTheme.displayMedium,
                  ),
                  Text(
                    DateFormat.MMMMEEEEd(locale).format(DateTime.now()),
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: TaylorSpacing.md),

            if (rides.isEmpty)
              _EmptyTonight(l10n: l10n)
            else ...[
              // El estado global va arriba del todo. Si todas llegaron, ese
              // es el único mensaje que importa y la lista pasa a segundo
              // plano.
              EveryoneHomeBanner(summary: summary),
              const SizedBox(height: TaylorSpacing.md),

              Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.bizRidesTonight,
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                  Text(
                    l10n.bizArrivedOf(summary.arrived, summary.total),
                    style: theme.textTheme.labelSmall,
                  ),
                ],
              ),
              const SizedBox(height: TaylorSpacing.sm),

              for (final ride in sorted)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: EmployeeRideTile(ride: ride),
                ),
            ],

            const SizedBox(height: TaylorSpacing.md),

            // Gasto del mes, discreto: es información de gestión, no de
            // vigilancia, y no debe competir con el estado de las personas.
            Container(
              padding: const EdgeInsets.all(TaylorSpacing.md),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(TaylorRadius.lg),
                border: Border.all(color: theme.colorScheme.outline),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.bizMonthSpend,
                          style: theme.textTheme.labelSmall,
                        ),
                        Text(
                          NumberFormat.simpleCurrency(locale: locale)
                              .format(account.monthToDateSpend),
                          style: theme.textTheme.headlineMedium,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        l10n.bizMonthRides,
                        style: theme.textTheme.labelSmall,
                      ),
                      Text(
                        '${account.monthToDateRides}',
                        style: theme.textTheme.headlineMedium,
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

class _EmptyTonight extends StatelessWidget {
  const _EmptyTonight({required this.l10n});

  final L10n l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(TaylorSpacing.lg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(TaylorRadius.lg),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Column(
        children: [
          Icon(
            Icons.nightlight_round,
            size: 42,
            color: TaylorColors.inkFaint.withValues(alpha: 0.5),
          ),
          const SizedBox(height: TaylorSpacing.sm),
          Text(l10n.bizNoRidesTonight, style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            l10n.bizNoRidesTonightBody,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
