import 'package:flutter/material.dart';

import '../../../core/theme/taylor_colors.dart';
import '../../../core/theme/taylor_theme.dart';

/// Botón de proveedor social (Google / Apple).
///
/// Neutro a propósito: el rosa de marca se reserva para la acción principal de
/// cada pantalla, y en el login esa acción es continuar, no un proveedor
/// concreto. Poner ambos en rosa competiría entre sí.
class ProviderButton extends StatelessWidget {
  const ProviderButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.busy = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SizedBox(
      height: 56,
      width: double.infinity,
      child: Material(
        color: isDark ? const Color(0x14FFFFFF) : TaylorColors.white,
        borderRadius: BorderRadius.circular(TaylorRadius.md),
        child: InkWell(
          onTap: busy ? null : onTap,
          borderRadius: BorderRadius.circular(TaylorRadius.md),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(TaylorRadius.md),
              border: Border.all(color: theme.colorScheme.outline),
            ),
            alignment: Alignment.center,
            child: busy
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: TaylorColors.raspberry,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, size: 26, color: theme.colorScheme.onSurface),
                      const SizedBox(width: 10),
                      Text(label, style: theme.textTheme.labelLarge),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
