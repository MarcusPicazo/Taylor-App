import 'package:flutter/material.dart';

import '../../../core/theme/taylor_colors.dart';
import '../../../core/theme/taylor_theme.dart';

/// Estructura compartida por todos los pasos del onboarding.
///
/// Que los cinco pasos usen el mismo esqueleto —ícono, título, cuerpo, zona de
/// trabajo, un solo botón abajo— hace que el flujo se sienta corto: la usuaria
/// aprende el patrón en el primer paso y ya no tiene que releer la pantalla.
class StepScaffold extends StatelessWidget {
  const StepScaffold({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
    required this.child,
    required this.actionLabel,
    required this.onAction,
    this.actionEnabled = true,
  });

  final IconData icon;
  final String title;
  final String body;
  final Widget child;
  final String actionLabel;
  final VoidCallback onAction;
  final bool actionEnabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(TaylorSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: TaylorSpacing.md),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: TaylorColors.raspberry.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(TaylorRadius.md),
            ),
            child: Icon(icon, color: TaylorColors.raspberry, size: 27),
          ),
          const SizedBox(height: TaylorSpacing.md),
          Text(title, style: theme.textTheme.headlineMedium),
          const SizedBox(height: 6),
          Text(body, style: theme.textTheme.bodyMedium),
          const SizedBox(height: TaylorSpacing.lg),

          Expanded(child: SingleChildScrollView(child: child)),

          FilledButton(
            onPressed: actionEnabled ? onAction : null,
            child: Text(actionLabel),
          ),
        ],
      ),
    );
  }
}
