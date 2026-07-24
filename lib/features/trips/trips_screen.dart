import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../app/router.dart';
import '../../core/format/money.dart';
import '../../core/theme/taylor_colors.dart';
import '../../core/theme/taylor_theme.dart';
import '../../data/demo_data.dart';
import '../../data/models/trip.dart';
import '../../l10n/app_localizations.dart';

class TripsScreen extends ConsumerWidget {
  const TripsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = L10n.of(context);
    final theme = Theme.of(context);
    final trips = TaylorDemo.trips();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: trips.isEmpty
            ? _EmptyState(title: l10n.tripsEmpty, body: l10n.tripsEmptyBody)
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(
                  TaylorSpacing.md,
                  TaylorSpacing.md,
                  TaylorSpacing.md,
                  // Deja pasar la barra flotante sin tapar el último viaje.
                  TaylorSpacing.navBarClearance,
                ),
                itemCount: trips.length + 1,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: TaylorSpacing.sm),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(
                        bottom: TaylorSpacing.sm,
                        left: 4,
                      ),
                      child: Text(
                        l10n.tripsTitle,
                        style: theme.textTheme.displayMedium,
                      ),
                    );
                  }
                  return _TripCard(trip: trips[index - 1]);
                },
              ),
      ),
    );
  }
}

class _TripCard extends StatelessWidget {
  const _TripCard({required this.trip});

  final Trip trip;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(TaylorSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  DateFormat.MMMEd(locale).add_jm().format(trip.requestedAt),
                  style: theme.textTheme.labelSmall,
                ),
                const Spacer(),
                if (trip.fare != null)
                  Text(
                    Money.format(context, trip.fare!),
                    style: theme.textTheme.titleMedium,
                  ),
              ],
            ),
            const SizedBox(height: TaylorSpacing.sm),

            _RoutePoint(
              color: TaylorColors.raspberry,
              label: trip.origin.label,
              address: trip.origin.address,
            ),
            // Conector vertical entre origen y destino.
            Padding(
              padding: const EdgeInsets.only(left: 5),
              child: SizedBox(
                height: 18,
                child: VerticalDivider(
                  color: theme.colorScheme.outline,
                  thickness: 2,
                  width: 2,
                ),
              ),
            ),
            _RoutePoint(
              color: theme.colorScheme.onSurface,
              label: trip.destination.label,
              address: trip.destination.address,
            ),

            const SizedBox(height: TaylorSpacing.sm),
            Divider(color: theme.colorScheme.outline),
            const SizedBox(height: 4),

            if (trip.driver != null)
              Row(
                children: [
                  const Icon(
                    Icons.verified_rounded,
                    size: 15,
                    color: TaylorColors.verified,
                  ),
                  const SizedBox(width: 5),
                  Flexible(
                    child: Text(
                      trip.driver!.name,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),

            // Los botones van en su propia fila, no junto al nombre de la
            // conductora. "Necesito ayuda con este viaje" es una etiqueta larga
            // y en español crece aún más: en una pantalla de 720 px desbordaba
            // por 47 px. Wrap deja que caigan a la línea siguiente en lugar de
            // recortarse.
            Wrap(
              spacing: 4,
              children: [
                TextButton(
                  onPressed: () => context.push(Routes.receipt, extra: trip),
                  child: Text(l10n.receiptViewReceipt),
                ),
                TextButton(
                  onPressed: () => context.push(Routes.help),
                  child: Text(l10n.tripHelp),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RoutePoint extends StatelessWidget {
  const _RoutePoint({
    required this.color,
    required this.label,
    required this.address,
  });

  final Color color;
  final String label;
  final String address;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Container(
            width: 11,
            height: 11,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
        ),
        const SizedBox(width: TaylorSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: theme.textTheme.labelLarge),
              Text(
                address,
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

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(TaylorSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 54,
              color: TaylorColors.inkFaint.withValues(alpha: 0.5),
            ),
            const SizedBox(height: TaylorSpacing.md),
            Text(title, style: theme.textTheme.titleLarge),
            const SizedBox(height: 6),
            Text(
              body,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
