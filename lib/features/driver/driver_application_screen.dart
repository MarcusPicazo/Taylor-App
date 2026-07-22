import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/taylor_colors.dart';
import '../../core/theme/taylor_theme.dart';
import '../../core/widgets/review_pending_view.dart';
import '../../l10n/app_localizations.dart';
import 'driver_controller.dart';

/// Alta de conductora.
///
/// A diferencia del onboarding de pasajera, aquí no se promete acceso
/// inmediato: los documentos pasan por revisión humana. La pantalla lo dice
/// desde el principio para que nadie termine el formulario esperando entrar
/// esa misma noche.
class DriverApplicationScreen extends ConsumerStatefulWidget {
  const DriverApplicationScreen({super.key});

  @override
  ConsumerState<DriverApplicationScreen> createState() =>
      _DriverApplicationScreenState();
}

class _DriverApplicationScreenState
    extends ConsumerState<DriverApplicationScreen> {
  final Set<String> _uploaded = {};
  bool _submitted = false;

  /// Requisitos documentales. Se listan todos antes de pedir nada: la
  /// aspirante decide si puede reunirlos antes de invertir tiempo.
  static const List<({String key, IconData icon})> _requirements = [
    (key: 'identity', icon: Icons.badge_outlined),
    (key: 'license', icon: Icons.drive_eta_outlined),
    (key: 'record', icon: Icons.gavel_rounded),
    (key: 'vehicle', icon: Icons.article_outlined),
    (key: 'photo', icon: Icons.portrait_rounded),
    (key: 'biometric', icon: Icons.face_retouching_natural_rounded),
  ];

  String _label(L10n l10n, String key) => switch (key) {
        'identity' => l10n.driverReqIdentity,
        'license' => l10n.driverReqLicense,
        'record' => l10n.driverReqRecord,
        'vehicle' => l10n.driverReqVehicle,
        'photo' => l10n.driverReqPhoto,
        _ => l10n.driverReqBiometric,
      };

  bool get _allUploaded => _uploaded.length == _requirements.length;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final theme = Theme.of(context);

    if (_submitted) {
      return Scaffold(
        appBar: AppBar(),
        body: SafeArea(
          child: ReviewPendingView(
            title: l10n.driverSubmittedTitle,
            body: l10n.driverSubmittedBody,
            actionLabel: l10n.done,
            onAction: () => Navigator.of(context).pop(),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.driverApplyTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(TaylorSpacing.lg),
          children: [
            Text(
              l10n.driverApplySubtitle,
              style: theme.textTheme.headlineMedium,
            ),
            const SizedBox(height: TaylorSpacing.sm),
            Text(l10n.driverApplyIntro, style: theme.textTheme.bodyMedium),

            const SizedBox(height: TaylorSpacing.lg),

            for (final requirement in _requirements)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _RequirementRow(
                  icon: requirement.icon,
                  label: _label(l10n, requirement.key),
                  uploaded: _uploaded.contains(requirement.key),
                  onTap: () => setState(
                    () => _uploaded.add(requirement.key),
                  ),
                ),
              ),

            const SizedBox(height: TaylorSpacing.md),

            // Aviso sobre la foto profesional. Es la diferencia más visible
            // frente al perfil de pasajera y conviene explicarla, no imponerla.
            Container(
              padding: const EdgeInsets.all(TaylorSpacing.sm),
              decoration: BoxDecoration(
                color: TaylorColors.caution.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(TaylorRadius.md),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    size: 19,
                    color: TaylorColors.caution,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      l10n.driverPhotoNote,
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: TaylorSpacing.lg),

            FilledButton(
              onPressed: _allUploaded
                  ? () {
                      // Registrar la solicitud antes de cambiar de pantalla:
                      // así la pestaña de Cuenta ya refleja "en revisión" al
                      // volver, sin depender de que esta pantalla siga viva.
                      ref
                          .read(driverProfileProvider.notifier)
                          .submitApplication();
                      setState(() => _submitted = true);
                    }
                  : null,
              child: Text(l10n.driverApplySubmit),
            ),
          ],
        ),
      ),
    );
  }
}

class _RequirementRow extends StatelessWidget {
  const _RequirementRow({
    required this.icon,
    required this.label,
    required this.uploaded,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool uploaded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: uploaded ? null : onTap,
      borderRadius: BorderRadius.circular(TaylorRadius.md),
      child: AnimatedContainer(
        duration: TaylorMotion.fast,
        padding: const EdgeInsets.all(TaylorSpacing.sm),
        decoration: BoxDecoration(
          color: uploaded
              ? TaylorColors.verified.withValues(alpha: 0.08)
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(TaylorRadius.md),
          border: Border.all(
            color:
                uploaded ? TaylorColors.verified : theme.colorScheme.outline,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 22,
              color: uploaded ? TaylorColors.verified : TaylorColors.inkFaint,
            ),
            const SizedBox(width: TaylorSpacing.sm),
            Expanded(
              child: Text(label, style: theme.textTheme.labelLarge),
            ),
            Icon(
              uploaded
                  ? Icons.check_circle_rounded
                  : Icons.file_upload_outlined,
              size: 21,
              color: uploaded
                  ? TaylorColors.verified
                  : TaylorColors.raspberry,
            ),
          ],
        ),
      ),
    );
  }
}
