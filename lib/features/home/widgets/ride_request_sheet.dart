import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/theme/taylor_colors.dart';
import '../../../core/theme/taylor_theme.dart';
import '../../../core/widgets/glass_surface.dart';
import '../../../data/models/trip.dart';
import '../../../l10n/app_localizations.dart';

/// Tarjeta de "¿a dónde vamos?".
///
/// Los destinos guardados están antes que el campo de búsqueda porque la
/// inmensa mayoría de viajes de una usuaria recurrente son casa ↔ oficina;
/// obligarla a teclear un destino que ya conocemos sería fricción gratuita.
class RideRequestSheet extends StatelessWidget {
  const RideRequestSheet({
    super.key,
    required this.userName,
    required this.onRequest,
  });

  final String userName;
  final void Function(TripLocation origin, TripLocation destination) onRequest;

  static const TripLocation _origin = TripLocation(
    label: 'Origen',
    address: 'Av. Amsterdam 240, Condesa',
    position: LatLng(19.4110, -99.1710),
  );

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (userName.isNotEmpty)
              Text(
                l10n.homeGreeting(userName),
                style: theme.textTheme.bodySmall,
              ),
            Text(l10n.homeWhereTo, style: theme.textTheme.headlineMedium),
            const SizedBox(height: TaylorSpacing.md),

            Row(
              children: [
                Expanded(
                  child: _SavedPlace(
                    icon: Icons.home_rounded,
                    label: l10n.homeSavedHome,
                    onTap: () => onRequest(
                      _origin,
                      const TripLocation(
                        label: 'Casa',
                        address: 'Av. Amsterdam 240, Condesa',
                        position: LatLng(19.4110, -99.1710),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: TaylorSpacing.sm),
                Expanded(
                  child: _SavedPlace(
                    icon: Icons.work_outline_rounded,
                    label: l10n.homeSavedWork,
                    onTap: () => onRequest(
                      _origin,
                      const TripLocation(
                        label: 'Oficina',
                        address: 'Torre Reforma, Paseo de la Reforma 483',
                        position: LatLng(19.4260, -99.1677),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: TaylorSpacing.sm),

            TextField(
              readOnly: true,
              onTap: () => onRequest(
                _origin,
                const TripLocation(
                  label: 'Destino',
                  address: 'Torre Reforma, Paseo de la Reforma 483',
                  position: LatLng(19.4260, -99.1677),
                ),
              ),
              decoration: InputDecoration(
                hintText: l10n.homeDestination,
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: TaylorColors.raspberry,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SavedPlace extends StatelessWidget {
  const _SavedPlace({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(TaylorRadius.md),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: TaylorSpacing.sm,
          vertical: 14,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(TaylorRadius.md),
          border: Border.all(color: theme.colorScheme.outline),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: TaylorColors.raspberry),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelLarge,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
