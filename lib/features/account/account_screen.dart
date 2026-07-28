import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../app/app_mode.dart';
import '../../app/router.dart';
import '../../core/theme/taylor_colors.dart';
import '../../core/theme/taylor_theme.dart';
import '../../core/widgets/pressable.dart';
import '../../core/widgets/user_avatar.dart';
import '../../data/models/driver_profile.dart';
import '../../data/session_controller.dart';
import '../../l10n/app_localizations.dart';
import '../driver/driver_controller.dart';
import 'widgets/account_row.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = L10n.of(context);
    final theme = Theme.of(context);
    final user = ref.watch(sessionControllerProvider).user;
    final driverProfile = ref.watch(driverProfileProvider);

    if (user == null) return const SizedBox.shrink();

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

            // Cabecera de identidad. El distintivo de verificación va aquí, en
            // el sitio más visible de la cuenta: es el activo principal que
            // Taylor le da a la usuaria.
            Container(
              padding: const EdgeInsets.all(TaylorSpacing.md),
              decoration: BoxDecoration(
                gradient: TaylorColors.brandGradient,
                borderRadius: BorderRadius.circular(TaylorRadius.lg),
              ),
              child: Row(
                children: [
                  UserAvatar(
                    initials: user.initials,
                    photoPath: user.photoUrl,
                    backgroundColor:
                        TaylorColors.white.withValues(alpha: 0.24),
                    foregroundColor: TaylorColors.white,
                  ),
                  const SizedBox(width: TaylorSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.fullName,
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: TaylorColors.white,
                          ),
                        ),
                        Text(
                          user.businessName ?? user.email,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: TaylorColors.white.withValues(alpha: 0.85),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color:
                                TaylorColors.white.withValues(alpha: 0.22),
                            borderRadius:
                                BorderRadius.circular(TaylorRadius.pill),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.verified_rounded,
                                size: 14,
                                color: TaylorColors.white,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                l10n.safetyBadgeVerified,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: TaylorColors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: TaylorSpacing.lg),

            // Entrada escalonada: al abrir la pestaña, las filas se asientan
            // una tras otra en lugar de aparecer de golpe. Corre una sola vez.
            EntranceList(
              children: [
                AccountRow(
                  icon: Icons.person_outline_rounded,
                  title: l10n.accountProfile,
                  subtitle: l10n.accountProfileBody,
                  onTap: () => context.push(Routes.profile),
                ),
                AccountRow(
                  icon: Icons.account_balance_wallet_outlined,
                  title: l10n.accountWallet,
                  subtitle: l10n.accountWalletBody,
                  onTap: () => context.push(Routes.wallet),
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
              ],
            ),

            const SizedBox(height: TaylorSpacing.lg),

            // Puerta de entrada al lado de conductora. Vive dentro de la app
            // de pasajera a propósito: la mayoría de conductoras de Taylor
            // llegan siendo usuarias antes que aspirantes.
            //
            // Qué se ofrece depende de dónde esté en el proceso: entrar a
            // conducir si ya está aprobada, ver el estado si está en revisión,
            // o solicitar si nunca lo hizo.
            switch (driverProfile.status) {
              DriverApplicationStatus.approved => AccountRow(
                  icon: Icons.directions_car_filled_rounded,
                  title: l10n.driveSwitchToDriver,
                  subtitle: l10n.driveSwitchToDriverBody,
                  highlighted: true,
                  onTap: () {
                    ref.read(appModeProvider.notifier).state = AppMode.driver;
                    context.go(Routes.driveHome);
                  },
                ),
              DriverApplicationStatus.underReview => AccountRow(
                  icon: Icons.hourglass_top_rounded,
                  title: l10n.driveUnderReview,
                  subtitle: driverProfile.estimatedResponseBy == null
                      ? l10n.accountBecomeDriverBody
                      : l10n.driveUnderReviewBody(
                          DateFormat.yMMMd(
                            Localizations.localeOf(context).toLanguageTag(),
                          ).format(driverProfile.estimatedResponseBy!),
                        ),
                  onTap: () {},
                ),
              _ => AccountRow(
                  icon: Icons.directions_car_filled_outlined,
                  title: l10n.accountBecomeDriver,
                  subtitle: l10n.accountBecomeDriverBody,
                  highlighted: true,
                  onTap: () => context.push(Routes.driverApplication),
                ),
            },

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
