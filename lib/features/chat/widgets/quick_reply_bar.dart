import 'package:flutter/material.dart';

import '../../../core/theme/taylor_colors.dart';
import '../../../core/theme/taylor_theme.dart';
import '../../../l10n/app_localizations.dart';

/// Fila de respuestas de un toque.
///
/// Va **encima** del campo de texto, no oculta tras un botón: para la
/// conductora es el mecanismo principal, no un atajo. Enterrarla en un menú
/// la volvería inútil justo cuando más falta hace.
class QuickReplyBar extends StatelessWidget {
  const QuickReplyBar({
    super.key,
    required this.messageKeys,
    required this.onSelected,
  });

  /// Claves de traducción de los mensajes disponibles.
  final List<String> messageKeys;

  final ValueChanged<String> onSelected;

  /// Resuelve la clave a texto traducido.
  ///
  /// Se hace con un switch explícito y no por reflexión porque las cadenas
  /// generadas por gen_l10n son campos, no un mapa: no hay forma de
  /// consultarlas dinámicamente sin perder la verificación en compilación.
  String _resolve(L10n l10n, String key) => switch (key) {
        'chatQuickOnMyWay' => l10n.chatQuickOnMyWay,
        'chatQuickArrived' => l10n.chatQuickArrived,
        'chatQuickWaitingOutside' => l10n.chatQuickWaitingOutside,
        'chatQuickCantFind' => l10n.chatQuickCantFind,
        'chatQuickTraffic' => l10n.chatQuickTraffic,
        'chatQuickComingOut' => l10n.chatQuickComingOut,
        'chatQuickTwoMinutes' => l10n.chatQuickTwoMinutes,
        'chatQuickWhereAreYou' => l10n.chatQuickWhereAreYou,
        _ => l10n.chatQuickThanks,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final theme = Theme.of(context);

    return SizedBox(
      height: 56,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: TaylorSpacing.md,
          vertical: 6,
        ),
        itemCount: messageKeys.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final text = _resolve(l10n, messageKeys[i]);

          return ActionChip(
            label: Text(text),
            onPressed: () => onSelected(text),
            labelStyle: theme.textTheme.labelLarge?.copyWith(
              color: TaylorColors.brandText,
            ),
            backgroundColor: TaylorColors.raspberry.withValues(alpha: 0.08),
            side: BorderSide(
              color: TaylorColors.raspberry.withValues(alpha: 0.3),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(TaylorRadius.pill),
            ),
            // Área de toque generosa: se usa en movimiento, a veces con el
            // teléfono en un soporte.
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          );
        },
      ),
    );
  }
}
