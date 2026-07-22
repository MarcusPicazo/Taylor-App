import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/theme/taylor_colors.dart';
import '../../core/theme/taylor_theme.dart';
import '../../core/widgets/taylor_logo.dart';
import '../../data/models/trip.dart';
import '../../l10n/app_localizations.dart';

/// Recibo de un viaje.
///
/// Muestra el desglose completo, igual que el resumen de la conductora muestra
/// su comisión. Es la misma postura aplicada a los dos lados: si la marca dice
/// que su modelo económico es distinto, ninguna de las dos partes debería tener
/// que hacer cuentas mentales para saber qué pagó o qué ganó.
class ReceiptScreen extends StatelessWidget {
  const ReceiptScreen({super.key, required this.trip});

  final Trip trip;

  /// Reparto de la tarifa. En producción viene calculado del backend; aquí se
  /// deriva para que el desglose cuadre siempre con el total mostrado.
  static const double _baseShare = 0.28;
  static const double _distanceShare = 0.46;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final money = NumberFormat.simpleCurrency(locale: locale);

    final total = trip.fare ?? 0;
    final base = total * _baseShare;
    final distance = total * _distanceShare;
    final time = total - base - distance;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.receiptTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.ios_share_rounded),
            tooltip: l10n.receiptShare,
            onPressed: () => Share.share(
              '${l10n.receiptTitle} Taylor · ${money.format(total)}\n'
              '${trip.origin.address} → ${trip.destination.address}',
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(TaylorSpacing.lg),
          children: [
            Center(
              child: Column(
                children: [
                  const TaylorLogo(size: 30),
                  Text(
                    DateFormat.yMMMMEEEEd(locale)
                        .add_jm()
                        .format(trip.requestedAt),
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: TaylorSpacing.sm),
                  Text(
                    money.format(total),
                    style: theme.textTheme.displayLarge,
                  ),
                ],
              ),
            ),

            const SizedBox(height: TaylorSpacing.lg),

            _RouteBlock(trip: trip),

            const SizedBox(height: TaylorSpacing.lg),
            Divider(color: theme.colorScheme.outline),
            const SizedBox(height: TaylorSpacing.sm),

            _Line(label: l10n.receiptBase, value: money.format(base)),
            _Line(
              label: l10n.receiptDistance(
                trip.distanceKm?.toStringAsFixed(1) ?? '—',
              ),
              value: money.format(distance),
            ),
            _Line(
              label: l10n.receiptTime(trip.durationMinutes ?? 0),
              value: money.format(time),
            ),

            const SizedBox(height: TaylorSpacing.sm),
            Divider(color: theme.colorScheme.outline),
            const SizedBox(height: TaylorSpacing.sm),

            _Line(
              label: l10n.receiptTotal,
              value: money.format(total),
              emphasized: true,
            ),

            const SizedBox(height: TaylorSpacing.lg),

            Container(
              padding: const EdgeInsets.all(TaylorSpacing.sm),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(TaylorRadius.md),
                border: Border.all(color: theme.colorScheme.outline),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.credit_card_rounded,
                    size: 21,
                    color: TaylorColors.raspberry,
                  ),
                  const SizedBox(width: TaylorSpacing.sm),
                  Expanded(
                    child: Text(
                      l10n.receiptPaidWith,
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                  Text(
                    'Visa •••• 4821',
                    style: theme.textTheme.labelLarge,
                  ),
                ],
              ),
            ),

            if (trip.driver != null) ...[
              const SizedBox(height: TaylorSpacing.md),
              Row(
                children: [
                  const Icon(
                    Icons.verified_rounded,
                    size: 16,
                    color: TaylorColors.verified,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      trip.driver!.name,
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                  Text(
                    trip.driver!.plate,
                    style: theme.textTheme.labelSmall,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RouteBlock extends StatelessWidget {
  const _RouteBlock({required this.trip});

  final Trip trip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Point(
          color: TaylorColors.raspberry,
          label: trip.origin.label,
          address: trip.origin.address,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 5),
          child: SizedBox(
            height: 22,
            child: VerticalDivider(
              color: theme.colorScheme.outline,
              thickness: 2,
              width: 2,
            ),
          ),
        ),
        _Point(
          color: theme.colorScheme.onSurface,
          label: trip.destination.label,
          address: trip.destination.address,
        ),
      ],
    );
  }
}

class _Point extends StatelessWidget {
  const _Point({
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
              Text(address, style: theme.textTheme.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({
    required this.label,
    required this.value,
    this.emphasized = false,
  });

  final String label;
  final String value;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style =
        emphasized ? theme.textTheme.titleLarge : theme.textTheme.bodyLarge;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(value, style: style),
        ],
      ),
    );
  }
}
