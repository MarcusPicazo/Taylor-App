import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/taylor_colors.dart';
import '../../../core/theme/taylor_theme.dart';
import '../../../data/models/business_account.dart';
import '../../../l10n/app_localizations.dart';

/// Una empleada y el estado de su traslado.
///
/// Muestra el nombre de la conductora asignada, pero **no** la dirección de
/// destino: la coordinadora necesita saber que su empleada está en camino y
/// que llegó, no dónde vive. Esa asimetría es intencional y es lo que hace que
/// el producto sea defendible ante las propias empleadas.
class EmployeeRideTile extends StatelessWidget {
  const EmployeeRideTile({super.key, required this.ride});

  final EmployeeRide ride;

  Color _statusColor(EmployeeRideStatus status) => switch (status) {
        EmployeeRideStatus.arrived => TaylorColors.verified,
        EmployeeRideStatus.noShow => TaylorColors.emergency,
        EmployeeRideStatus.cancelled => TaylorColors.inkFaint,
        _ => TaylorColors.raspberry,
      };

  IconData _statusIcon(EmployeeRideStatus status) => switch (status) {
        EmployeeRideStatus.scheduled => Icons.schedule_rounded,
        EmployeeRideStatus.assigning => Icons.search_rounded,
        EmployeeRideStatus.driverAssigned => Icons.directions_car_rounded,
        EmployeeRideStatus.inTransit => Icons.navigation_rounded,
        EmployeeRideStatus.arrived => Icons.home_rounded,
        EmployeeRideStatus.noShow => Icons.person_off_rounded,
        EmployeeRideStatus.cancelled => Icons.close_rounded,
      };

  String _statusLabel(L10n l10n, String locale) => switch (ride.status) {
        EmployeeRideStatus.scheduled => l10n.bizStatusScheduled,
        EmployeeRideStatus.assigning => l10n.bizStatusAssigning,
        EmployeeRideStatus.driverAssigned =>
          l10n.bizStatusDriverAssigned(ride.etaMinutes ?? 0),
        EmployeeRideStatus.inTransit =>
          l10n.bizStatusInTransit(ride.etaMinutes ?? 0),
        EmployeeRideStatus.arrived => ride.arrivedAt == null
            ? l10n.bizStatusArrived
            : l10n.bizStatusArrivedAt(
                DateFormat.jm(locale).format(ride.arrivedAt!),
              ),
        EmployeeRideStatus.noShow => l10n.bizStatusNoShow,
        EmployeeRideStatus.cancelled => l10n.bizStatusCancelled,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final color = _statusColor(ride.status);
    final needsAttention = ride.status.needsAttention;

    return Container(
      padding: const EdgeInsets.all(TaylorSpacing.sm),
      decoration: BoxDecoration(
        color: needsAttention
            ? TaylorColors.emergency.withValues(alpha: 0.06)
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(TaylorRadius.lg),
        border: Border.all(
          color: needsAttention
              ? TaylorColors.emergency.withValues(alpha: 0.45)
              : theme.colorScheme.outline,
        ),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: color.withValues(alpha: 0.14),
                child: Text(
                  ride.employee.initials,
                  style: theme.textTheme.labelLarge?.copyWith(color: color),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: theme.colorScheme.surface,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    _statusIcon(ride.status),
                    size: 10,
                    color: TaylorColors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: TaylorSpacing.sm),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ride.employee.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium,
                ),
                Text(
                  _statusLabel(l10n, locale),
                  style: theme.textTheme.bodySmall?.copyWith(color: color),
                ),
                if (ride.driverName != null)
                  Text(
                    l10n.bizDriverName(ride.driverName!),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall,
                  ),
              ],
            ),
          ),

          // Llamar a la empleada. Se ofrece siempre que siga fuera o no se
          // haya presentado — es justo cuando alguien necesitaría contactarla.
          if (ride.status.isOpen || needsAttention)
            IconButton(
              icon: const Icon(Icons.call_rounded),
              color: color,
              tooltip: l10n.bizCallEmployee,
              onPressed: () => launchUrl(
                Uri(scheme: 'tel', path: ride.employee.phone),
              ),
            ),
        ],
      ),
    );
  }
}
