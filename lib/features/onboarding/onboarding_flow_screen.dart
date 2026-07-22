import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/taylor_colors.dart';
import '../../core/theme/taylor_theme.dart';
import '../../data/models/taylor_user.dart';
import '../../data/session_controller.dart';
import '../../l10n/app_localizations.dart';
import 'steps/background_check_step.dart';
import 'steps/document_scan_step.dart';
import 'steps/emergency_contact_step.dart';
import 'steps/face_match_step.dart';
import 'steps/phone_step.dart';
import 'steps/verified_step.dart';

/// Embudo de verificación obligatorio antes de poder usar Taylor.
///
/// Los pasos son secuenciales y no se pueden saltar. El orden importa: el
/// documento se captura ANTES del rostro, porque la comparación biométrica
/// necesita una foto de referencia contra la cual medir. Invertirlos
/// convertiría el escaneo facial en un gesto decorativo.
class OnboardingFlowScreen extends ConsumerStatefulWidget {
  const OnboardingFlowScreen({super.key});

  @override
  ConsumerState<OnboardingFlowScreen> createState() =>
      _OnboardingFlowScreenState();
}

class _OnboardingFlowScreenState extends ConsumerState<OnboardingFlowScreen> {
  final _pageController = PageController();
  int _index = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _advance(VerificationStage stage) {
    ref.read(sessionControllerProvider.notifier).advanceStage(stage);

    if (stage == VerificationStage.verified) return;

    setState(() => _index++);
    _pageController.animateToPage(
      _index,
      duration: TaylorMotion.normal,
      curve: TaylorMotion.emphasized,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final theme = Theme.of(context);
    final user = ref.watch(sessionControllerProvider).user;

    if (user == null) return const SizedBox.shrink();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                TaylorSpacing.lg,
                TaylorSpacing.md,
                TaylorSpacing.lg,
                0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.onboardingTitle,
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.onboardingSubtitle,
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: TaylorSpacing.sm),

                  // Barra de progreso continua en lugar de "paso 2 de 5":
                  // avanzar debe sentirse como movimiento, no como burocracia.
                  ClipRRect(
                    borderRadius: BorderRadius.circular(TaylorRadius.pill),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: user.stage.progress),
                      duration: TaylorMotion.slow,
                      curve: TaylorMotion.emphasized,
                      builder: (context, value, _) => LinearProgressIndicator(
                        value: value,
                        minHeight: 6,
                        backgroundColor: theme.colorScheme.outline,
                        valueColor: const AlwaysStoppedAnimation(
                          TaylorColors.raspberry,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: PageView(
                controller: _pageController,
                // Sin swipe manual: los pasos avanzan al completarse, nunca
                // por gesto, para que no se pueda ojear el final del flujo.
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  PhoneStep(
                    onDone: () => _advance(VerificationStage.phoneConfirmed),
                  ),
                  DocumentScanStep(
                    onDone: () =>
                        _advance(VerificationStage.documentCaptured),
                  ),
                  FaceMatchStep(
                    onDone: () =>
                        _advance(VerificationStage.biometricMatched),
                  ),
                  BackgroundCheckStep(
                    onDone: () =>
                        _advance(VerificationStage.backgroundCheckPending),
                  ),
                  EmergencyContactStep(
                    onDone: () =>
                        _advance(VerificationStage.safetyNetworkReady),
                  ),
                  VerifiedStep(
                    name: user.firstName,
                    onDone: () => _advance(VerificationStage.verified),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
