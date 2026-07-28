import 'package:flutter/material.dart';

import '../../../core/theme/taylor_colors.dart';
import '../../../core/theme/taylor_theme.dart';
import '../../../core/widgets/pressable.dart';

/// Fila de navegación de la sección Cuenta.
///
/// [highlighted] tiñe la fila con el rosa de marca y se reserva para una sola
/// acción por pantalla —hoy, hacerse conductora—. Si se usara en varias, dejaría
/// de destacar nada.
class AccountRow extends StatelessWidget {
  const AccountRow({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.highlighted = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // El hundido de Pressable reemplaza al destello de Material: una sola
    // fuente de respuesta al toque, sin dos gestos compitiendo por el mismo
    // tap ni el onTap disparándose dos veces.
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Pressable(
        onTap: onTap,
        borderRadius: BorderRadius.circular(TaylorRadius.lg),
        child: Container(
          padding: const EdgeInsets.all(TaylorSpacing.sm),
          decoration: BoxDecoration(
            color: highlighted
                ? TaylorColors.raspberry.withValues(alpha: 0.08)
                : theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(TaylorRadius.lg),
            border: Border.all(
              color: highlighted
                  ? TaylorColors.raspberry.withValues(alpha: 0.35)
                  : theme.colorScheme.outline,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: TaylorColors.raspberry.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(TaylorRadius.sm),
                ),
                child: Icon(icon, size: 22, color: TaylorColors.raspberry),
              ),
              const SizedBox(width: TaylorSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.titleMedium),
                    Text(subtitle, style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: TaylorColors.inkFaint,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
