import 'package:flutter/material.dart';

import '../../../core/theme/taylor_colors.dart';
import '../../../core/theme/taylor_theme.dart';
import '../../../l10n/app_localizations.dart';
import 'step_scaffold.dart';

/// Revisión de antecedentes.
///
/// Las comprobaciones se muestran una a una conforme terminan. Ver la lista
/// completarse comunica el rigor del proceso mucho mejor que un spinner
/// genérico, y es lo que justifica ante la usuaria el tiempo de espera.
class BackgroundCheckStep extends StatefulWidget {
  const BackgroundCheckStep({super.key, required this.onDone});

  final VoidCallback onDone;

  @override
  State<BackgroundCheckStep> createState() => _BackgroundCheckStepState();
}

class _BackgroundCheckStepState extends State<BackgroundCheckStep> {
  static const List<({IconData icon, String key})> _checks = [
    (icon: Icons.gavel_rounded, key: 'criminal'),
    (icon: Icons.directions_car_rounded, key: 'driving'),
    (icon: Icons.fingerprint_rounded, key: 'identity'),
    (icon: Icons.policy_rounded, key: 'watchlist'),
  ];

  int _completed = 0;
  bool _running = false;

  Future<void> _run() async {
    setState(() => _running = true);

    // Aquí va la llamada real al proveedor de background check.
    // Ver README.md → "Integrar verificación de identidad".
    for (var i = 0; i < _checks.length; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 850));
      if (!mounted) return;
      setState(() => _completed = i + 1);
    }

    if (mounted) setState(() => _running = false);
  }

  String _label(L10n l10n, String key) => switch (key) {
        'criminal' => l10n.driverReqRecord,
        'driving' => l10n.driverReqLicense,
        'identity' => l10n.driverReqIdentity,
        _ => l10n.stepBackground,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final theme = Theme.of(context);
    final allDone = _completed == _checks.length;

    return StepScaffold(
      icon: Icons.policy_rounded,
      title: l10n.stepBackground,
      body: l10n.stepBackgroundBody,
      actionLabel: allDone ? l10n.continueLabel : l10n.backgroundRunning,
      actionEnabled: allDone || !_running,
      onAction: allDone ? widget.onDone : _run,
      child: Column(
        children: [
          for (var i = 0; i < _checks.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: TaylorSpacing.sm),
              child: _CheckRow(
                icon: _checks[i].icon,
                label: _label(l10n, _checks[i].key),
                state: i < _completed
                    ? _CheckState.done
                    : (_running ? _CheckState.running : _CheckState.idle),
                doneLabel: l10n.backgroundClear,
                runningLabel: l10n.backgroundRunning,
              ),
            ),
          if (allDone) ...[
            const SizedBox(height: TaylorSpacing.sm),
            Container(
              padding: const EdgeInsets.all(TaylorSpacing.sm),
              decoration: BoxDecoration(
                color: TaylorColors.verified.withValues(alpha: 0.09),
                borderRadius: BorderRadius.circular(TaylorRadius.md),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.shield_rounded,
                    color: TaylorColors.verified,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      l10n.onboardingWhyBody,
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

enum _CheckState { idle, running, done }

class _CheckRow extends StatelessWidget {
  const _CheckRow({
    required this.icon,
    required this.label,
    required this.state,
    required this.doneLabel,
    required this.runningLabel,
  });

  final IconData icon;
  final String label;
  final _CheckState state;
  final String doneLabel;
  final String runningLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final done = state == _CheckState.done;

    return AnimatedContainer(
      duration: TaylorMotion.normal,
      curve: TaylorMotion.standard,
      padding: const EdgeInsets.all(TaylorSpacing.sm),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(TaylorRadius.md),
        border: Border.all(
          color: done ? TaylorColors.verified : theme.colorScheme.outline,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 21,
            color: done ? TaylorColors.verified : TaylorColors.inkFaint,
          ),
          const SizedBox(width: TaylorSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: theme.textTheme.labelLarge),
                if (state != _CheckState.idle)
                  Text(
                    done ? doneLabel : runningLabel,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: done ? TaylorColors.verified : null,
                    ),
                  ),
              ],
            ),
          ),
          if (state == _CheckState.running)
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: TaylorColors.raspberry,
              ),
            )
          else if (done)
            const Icon(
              Icons.check_circle_rounded,
              color: TaylorColors.verified,
              size: 21,
            ),
        ],
      ),
    );
  }
}
