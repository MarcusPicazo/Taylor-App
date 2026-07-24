import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/taylor_colors.dart';
import '../../../core/theme/taylor_theme.dart';
import '../../../core/widgets/glass_surface.dart';
import '../../../data/models/ride_tier.dart';
import '../../../data/places_repository.dart';
import '../../../l10n/app_localizations.dart';
import 'ride_tier_selector.dart';

/// Panel de confirmación: destino elegido, categorías y precio.
///
/// Aparece cuando ya hay ruta dibujada en el mapa. Muestra las tres categorías
/// a la vez porque la decisión es comparativa —precio contra plazas contra
/// espera— y esconderlas obligaría a memorizar cifras.
class RideConfirmSheet extends StatelessWidget {
  const RideConfirmSheet({
    super.key,
    required this.destination,
    required this.selectedTier,
    required this.onTierSelected,
    required this.onConfirm,
    required this.onClear,
  });

  final PlaceSuggestion destination;
  final RideTier selectedTier;
  final ValueChanged<RideTier> onTierSelected;
  final VoidCallback onConfirm;
  final VoidCallback onClear;

  /// Distancia aproximada origen–destino, en kilómetros.
  ///
  /// Se calcula sobre la recta con un factor de 1.35 para aproximar el
  /// rodeo real de las calles. La distancia exacta viene de la Directions API
  /// cuando se integre; mientras tanto esto da estimaciones plausibles en vez
  /// de cifras inventadas.
  double get _distanceKm {
    const home = 19.4110;
    const homeLng = -99.1710;

    // Grados a km en la latitud de Ciudad de México.
    const kmPerLat = 111.0;
    const kmPerLng = 105.0;

    final dLat = (destination.position.latitude - home) * kmPerLat;
    final dLng = (destination.position.longitude - homeLng) * kmPerLng;

    return math.sqrt(dLat * dLat + dLng * dLng) * 1.35;
  }

  /// Duración estimada: velocidad media urbana de ~22 km/h en CDMX.
  int get _minutes => math.max(5, (_distanceKm / 22 * 60).round());

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: TaylorSpacing.md),
      child: GlassSurface(
        padding: const EdgeInsets.all(TaylorSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: TaylorColors.raspberry,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        destination.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium,
                      ),
                      Text(
                        destination.address,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  tooltip: l10n.cancel,
                  onPressed: onClear,
                ),
              ],
            ),

            const SizedBox(height: 4),
            Text(
              l10n.tripEstimate(
                _distanceKm.toStringAsFixed(1),
                _minutes,
              ),
              style: theme.textTheme.labelSmall,
            ),

            const SizedBox(height: TaylorSpacing.md),

            RideTierSelector(
              selected: selectedTier,
              onSelected: onTierSelected,
              distanceKm: _distanceKm,
              minutes: _minutes,
              pickupMinutes: 4,
            ),

            const SizedBox(height: TaylorSpacing.sm),
            FilledButton(
              onPressed: onConfirm,
              child: Text(l10n.confirmRide(selectedTier.displayName)),
            ),
          ],
        ),
      ),
    );
  }
}
