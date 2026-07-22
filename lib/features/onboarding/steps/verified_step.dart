import 'package:flutter/material.dart';

import '../../../core/theme/taylor_colors.dart';
import '../../../core/theme/taylor_theme.dart';
import '../../../l10n/app_localizations.dart';

/// Cierre del onboarding.
///
/// Es el único momento del flujo donde la app celebra. Todo lo anterior fue
/// deliberadamente sobrio para no trivializar la verificación; aquí sí toca
/// recibirla con calidez, que es el arquetipo de la marca.
class VerifiedStep extends StatelessWidget {
  const VerifiedStep({
    super.key,
    required this.name,
    required this.onDone,
  });

  final String name;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(TaylorSpacing.lg),
      child: Column(
        children: [
          const Spacer(),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.6, end: 1),
            duration: TaylorMotion.slow,
            curve: Curves.elasticOut,
            builder: (context, scale, child) =>
                Transform.scale(scale: scale, child: child),
            child: Container(
              width: 108,
              height: 108,
              decoration: const BoxDecoration(
                gradient: TaylorColors.brandGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.verified_user_rounded,
                size: 52,
                color: TaylorColors.white,
              ),
            ),
          ),
          const SizedBox(height: TaylorSpacing.lg),
          Text(
            l10n.verifiedTitle(name),
            textAlign: TextAlign.center,
            style: theme.textTheme.displayMedium,
          ),
          const SizedBox(height: TaylorSpacing.xs),
          Text(
            l10n.verifiedBody,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
          const Spacer(),
          FilledButton(onPressed: onDone, child: Text(l10n.startRiding)),
        ],
      ),
    );
  }
}
