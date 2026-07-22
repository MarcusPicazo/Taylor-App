import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../core/theme/taylor_colors.dart';
import '../../core/theme/taylor_theme.dart';
import '../../core/widgets/glass_surface.dart';
import '../../data/models/trip.dart';
import '../../l10n/app_localizations.dart';
import '../home/ride_controller.dart';
import 'widgets/star_rating.dart';

/// Calificación al terminar el viaje.
///
/// En Taylor una calificación baja **no es solo un número**: es la única señal
/// estructurada que tenemos de que algo pudo salir mal. Por eso, a partir de
/// 3 estrellas o menos, la tarjeta ofrece explícitamente escalar a seguridad
/// en lugar de limitarse a bajar un promedio.
///
/// El texto de esa escalada dice que lo revisa un equipo humano, no un
/// algoritmo, porque es verdad y porque es exactamente la diferencia que la
/// marca promete.
class RatingCard extends ConsumerStatefulWidget {
  const RatingCard({super.key, required this.trip});

  final Trip trip;

  @override
  ConsumerState<RatingCard> createState() => _RatingCardState();
}

class _RatingCardState extends ConsumerState<RatingCard> {
  int _stars = 0;
  final Set<String> _tags = {};
  bool _submitted = false;

  /// Umbral a partir del cual se ofrece escalar a seguridad.
  static const int _concernThreshold = 3;

  bool get _showsSafetyPath => _stars > 0 && _stars <= _concernThreshold;

  void _submit() {
    ref.read(rideControllerProvider.notifier).rate(_stars.toDouble());
    setState(() => _submitted = true);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(L10n.of(context).rateThanks)),
    );
    ref.read(rideControllerProvider.notifier).dismiss();
  }

  void _reportSafety() {
    final l10n = L10n.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.rateSafetySent),
        backgroundColor: TaylorColors.emergency,
      ),
    );
    ref.read(rideControllerProvider.notifier).rate(_stars.toDouble());
    ref.read(rideControllerProvider.notifier).dismiss();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final theme = Theme.of(context);
    final driver = widget.trip.driver;

    final tagLabels = <String, String>{
      'punctual': l10n.rateTagPunctual,
      'friendly': l10n.rateTagFriendly,
      'safe': l10n.rateTagSafeDriving,
      'clean': l10n.rateTagCleanCar,
      'comfortable': l10n.rateTagComfortable,
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: TaylorSpacing.md),
      child: GlassSurface(
        padding: const EdgeInsets.all(TaylorSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.tripCompleted,
              textAlign: TextAlign.center,
              style: theme.textTheme.labelSmall,
            ),
            Text(
              l10n.rateTitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge,
            ),
            if (driver != null)
              Text(
                l10n.rateWith(driver.name),
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall,
              ),

            const SizedBox(height: TaylorSpacing.md),
            StarRating(
              value: _stars,
              onChanged: (v) => setState(() {
                _stars = v;
                // Las etiquetas positivas dejan de aplicar si la experiencia
                // fue mala; limpiarlas evita enviar señales contradictorias.
                if (v <= _concernThreshold) _tags.clear();
              }),
            ),
            const SizedBox(height: TaylorSpacing.md),

            // Camino de seguridad, solo con calificación baja.
            if (_showsSafetyPath) ...[
              Container(
                padding: const EdgeInsets.all(TaylorSpacing.sm),
                decoration: BoxDecoration(
                  color: TaylorColors.emergency.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(TaylorRadius.md),
                  border: Border.all(
                    color: TaylorColors.emergency.withValues(alpha: 0.35),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.rateSafetyTitle,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: TaylorColors.emergency,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.rateSafetyBody,
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: TaylorSpacing.sm),
                    OutlinedButton.icon(
                      onPressed: _reportSafety,
                      icon: const Icon(Icons.shield_outlined, size: 18),
                      label: Text(l10n.rateSafetyReport),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: TaylorColors.emergency,
                        side: const BorderSide(
                          color: TaylorColors.emergency,
                        ),
                        minimumSize: const Size.fromHeight(48),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: TaylorSpacing.sm),
            ]
            // Etiquetas positivas, solo con buena calificación.
            else if (_stars > _concernThreshold) ...[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  for (final entry in tagLabels.entries)
                    FilterChip(
                      label: Text(entry.value),
                      selected: _tags.contains(entry.key),
                      onSelected: (on) => setState(() {
                        if (on) {
                          _tags.add(entry.key);
                        } else {
                          _tags.remove(entry.key);
                        }
                      }),
                      selectedColor:
                          TaylorColors.raspberry.withValues(alpha: 0.14),
                      checkmarkColor: TaylorColors.raspberry,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(TaylorRadius.pill),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: TaylorSpacing.md),
            ],

            FilledButton(
              onPressed: _stars == 0 || _submitted ? null : _submit,
              child: Text(l10n.rateSubmit),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () =>
                      ref.read(rideControllerProvider.notifier).dismiss(),
                  child: Text(
                    l10n.rateSkip,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: TaylorColors.inkMuted,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => context.push(
                    Routes.receipt,
                    extra: widget.trip,
                  ),
                  icon: const Icon(Icons.receipt_long_outlined, size: 17),
                  label: Text(l10n.receiptViewReceipt),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
