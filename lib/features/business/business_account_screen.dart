import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_mode.dart';
import '../../app/router.dart';
import '../../core/format/money.dart';
import '../../core/theme/taylor_colors.dart';
import '../../core/theme/taylor_theme.dart';
import '../../data/session_controller.dart';
import '../../l10n/app_localizations.dart';
import '../account/widgets/account_row.dart';
import 'business_controller.dart';

/// Cuenta de la empresa: datos, facturación y accesos.
class BusinessAccountScreen extends ConsumerWidget {
  const BusinessAccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = L10n.of(context);
    final theme = Theme.of(context);
    final account = ref.watch(businessAccountProvider);

    if (account == null) return const SizedBox.shrink();

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
                l10n.accountTitle,
                style: theme.textTheme.displayMedium,
              ),
            ),
            const SizedBox(height: TaylorSpacing.md),

            Container(
              padding: const EdgeInsets.all(TaylorSpacing.md),
              decoration: BoxDecoration(
                gradient: TaylorColors.brandGradient,
                borderRadius: BorderRadius.circular(TaylorRadius.lg),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.business_rounded,
                    color: TaylorColors.white,
                    size: 28,
                  ),
                  const SizedBox(height: TaylorSpacing.sm),
                  Text(
                    account.companyName,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: TaylorColors.white,
                    ),
                  ),
                  Text(
                    '${account.contactName} · ${account.city}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: TaylorColors.white.withValues(alpha: 0.86),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: TaylorSpacing.lg),

            Text(l10n.bizBilling, style: theme.textTheme.titleMedium),
            const SizedBox(height: TaylorSpacing.sm),

            Container(
              padding: const EdgeInsets.all(TaylorSpacing.md),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(TaylorRadius.lg),
                border: Border.all(color: theme.colorScheme.outline),
              ),
              child: Column(
                children: [
                  _BillingLine(
                    label: l10n.bizMonthSpend,
                    value: Money.format(context, account.monthToDateSpend),
                  ),
                  const SizedBox(height: 6),
                  _BillingLine(
                    label: l10n.bizMonthRides,
                    value: '${account.monthToDateRides}',
                  ),
                  const SizedBox(height: 6),
                  _BillingLine(
                    label: l10n.bizAvgPerRide,
                    value: account.monthToDateRides == 0
                        ? '—'
                        : Money.format(
                            context,
                            account.monthToDateSpend /
                                account.monthToDateRides,
                          ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: TaylorSpacing.lg),

            AccountRow(
              icon: Icons.receipt_long_outlined,
              title: l10n.bizInvoices,
              subtitle: l10n.bizInvoicesBody,
              onTap: () {},
            ),
            AccountRow(
              icon: Icons.help_outline_rounded,
              title: l10n.accountHelp,
              subtitle: l10n.accountHelpBody,
              onTap: () => context.push(Routes.help),
            ),
            AccountRow(
              icon: Icons.settings_outlined,
              title: l10n.accountSettings,
              subtitle: l10n.accountSettingsBody,
              onTap: () => context.push(Routes.settings),
            ),

            const SizedBox(height: TaylorSpacing.lg),

            // La coordinadora también es una usuaria verificada y puede pedir
            // sus propios viajes. Cambiar de modo no cierra la sesión.
            AccountRow(
              icon: Icons.swap_horiz_rounded,
              title: l10n.driveSwitchToPassenger,
              subtitle: l10n.driveSwitchToPassengerBody,
              highlighted: true,
              onTap: () {
                ref.read(appModeProvider.notifier).state = AppMode.passenger;
                context.go(Routes.home);
              },
            ),

            const SizedBox(height: TaylorSpacing.lg),

            TextButton.icon(
              onPressed: () =>
                  ref.read(sessionControllerProvider.notifier).signOut(),
              icon: const Icon(Icons.logout_rounded, size: 19),
              label: Text(l10n.accountSignOut),
              style: TextButton.styleFrom(
                foregroundColor: TaylorColors.inkMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BillingLine extends StatelessWidget {
  const _BillingLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: theme.textTheme.bodyMedium),
        Text(value, style: theme.textTheme.titleMedium),
      ],
    );
  }
}
