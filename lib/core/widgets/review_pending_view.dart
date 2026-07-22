import 'package:flutter/material.dart';

import '../theme/taylor_colors.dart';
import '../theme/taylor_theme.dart';

/// Confirmación de "solicitud enviada, respuesta en 3 a 5 días hábiles".
///
/// La comparten la solicitud de empresa y la de conductora porque ambas
/// terminan en revisión manual del equipo de Taylor. El tono es tranquilo y
/// concreto: se dice exactamente qué sigue y cuándo, sin celebración vacía.
class ReviewPendingView extends StatelessWidget {
  const ReviewPendingView({
    super.key,
    required this.title,
    required this.body,
    required this.actionLabel,
    required this.onAction,
  });

  final String title;
  final String body;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(TaylorSpacing.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: TaylorColors.raspberry.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(TaylorRadius.lg),
            ),
            child: const Icon(
              Icons.hourglass_top_rounded,
              size: 34,
              color: TaylorColors.raspberry,
            ),
          ),
          const SizedBox(height: TaylorSpacing.lg),
          Text(title, style: theme.textTheme.displayMedium),
          const SizedBox(height: TaylorSpacing.sm),
          Text(body, style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          )),
          const SizedBox(height: TaylorSpacing.xl),
          FilledButton(onPressed: onAction, child: Text(actionLabel)),
        ],
      ),
    );
  }
}
