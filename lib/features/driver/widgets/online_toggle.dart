import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/taylor_colors.dart';
import '../../../core/theme/taylor_theme.dart';
import '../../../core/widgets/glass_surface.dart';
import '../../../l10n/app_localizations.dart';

/// Interruptor de disponibilidad.
///
/// Es el control más importante del modo conductora, así que ocupa el ancho
/// completo y cambia de color, no solo de posición: al volante hay que poder
/// confirmar el estado con una mirada periférica, sin leer.
class OnlineToggle extends StatelessWidget {
  const OnlineToggle({
    super.key,
    required this.isOnline,
    required this.onChanged,
    this.enabled = true,
  });

  final bool isOnline;
  final ValueChanged<bool> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final theme = Theme.of(context);

    return GlassSurface(
      borderRadius: BorderRadius.circular(TaylorRadius.xl),
      padding: const EdgeInsets.symmetric(
        horizontal: TaylorSpacing.md,
        vertical: 12,
      ),
      child: Row(
        children: [
          AnimatedContainer(
            duration: TaylorMotion.normal,
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isOnline ? TaylorColors.verified : TaylorColors.inkFaint,
              boxShadow: isOnline
                  ? [
                      BoxShadow(
                        color: TaylorColors.verified.withValues(alpha: 0.55),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
          ),
          const SizedBox(width: TaylorSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isOnline ? l10n.driveOnline : l10n.driveOffline,
                  style: theme.textTheme.titleMedium,
                ),
                Text(
                  isOnline ? l10n.driveOnlineBody : l10n.driveOfflineBody,
                  style: theme.textTheme.labelSmall,
                ),
              ],
            ),
          ),
          Switch(
            value: isOnline,
            onChanged: enabled
                ? (value) {
                    HapticFeedback.mediumImpact();
                    onChanged(value);
                  }
                : null,
            activeThumbColor: TaylorColors.verified,
          ),
        ],
      ),
    );
  }
}
