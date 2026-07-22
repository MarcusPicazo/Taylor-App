import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_mode.dart';
import '../../app/router.dart';
import '../../core/theme/taylor_colors.dart';
import '../../core/theme/taylor_theme.dart';
import '../../core/widgets/user_avatar.dart';
import '../../data/session_controller.dart';
import '../../l10n/app_localizations.dart';
import '../account/widgets/account_row.dart';
import 'driver_controller.dart';

/// Cuenta en modo conductora.
///
/// Repite deliberadamente algunas filas del modo pasajera (ayuda, ajustes) en
/// vez de mandar de vuelta al otro modo: cambiar de contexto para ajustar el
/// idioma sería absurdo. Lo que sí es exclusivo aquí es el vehículo y el
/// retorno a modo pasajera.
class DriverAccountScreen extends ConsumerWidget {
  const DriverAccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = L10n.of(context);
    final theme = Theme.of(context);
    final user = ref.watch(sessionControllerProvider).user;
    final profile = ref.watch(driverProfileProvider);

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

            Container(
              padding: const EdgeInsets.all(TaylorSpacing.md),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(TaylorRadius.lg),
                border: Border.all(color: theme.colorScheme.outline),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      UserAvatar(
                        initials: user.initials,
                        photoPath: profile.professionalPhotoUrl,
                      ),
                      const SizedBox(width: TaylorSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.fullName,
                              style: theme.textTheme.titleLarge,
                            ),
                            Text(
                              l10n.driveTripsCount(profile.totalTrips),
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: TaylorSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: _Metric(
                          label: l10n.driveRating,
                          value: profile.rating.toStringAsFixed(2),
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 34,
                        color: theme.colorScheme.outline,
                      ),
                      Expanded(
                        child: _Metric(
                          label: l10n.driveAcceptance,
                          value:
                              '${(profile.acceptanceRate * 100).round()}%',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: TaylorSpacing.lg),

            if (profile.vehicle != null)
              AccountRow(
                icon: Icons.directions_car_filled_outlined,
                title: profile.vehicle!.displayName,
                subtitle: profile.vehicle!.plate,
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

            // Vuelta a modo pasajera.
            AccountRow(
              icon: Icons.swap_horiz_rounded,
              title: l10n.driveSwitchToPassenger,
              subtitle: l10n.driveSwitchToPassengerBody,
              highlighted: true,
              onTap: () {
                // Desconectarse antes de salir evita quedar recibiendo
                // solicitudes desde el otro modo.
                ref.read(driverControllerProvider.notifier).goOffline();
                ref.read(appModeProvider.notifier).state = AppMode.passenger;
                context.go(Routes.home);
              },
            ),

            const SizedBox(height: TaylorSpacing.lg),

            TextButton.icon(
              onPressed: () {
                ref.read(driverControllerProvider.notifier).goOffline();
                ref.read(sessionControllerProvider.notifier).signOut();
              },
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

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Text(value, style: theme.textTheme.titleLarge),
        Text(label, style: theme.textTheme.labelSmall),
      ],
    );
  }
}
