import 'package:flutter/material.dart';

import '../../../core/theme/taylor_colors.dart';
import '../../../core/theme/taylor_theme.dart';
import '../../../l10n/app_localizations.dart';
import 'step_scaffold.dart';

/// Captura del documento oficial (INE o pasaporte).
///
/// El marco guía es lo único que se le pide a la usuaria: encuadrar. La lectura
/// del documento ocurre después y de forma automática, para que el paso no se
/// sienta un trámite.
class DocumentScanStep extends StatefulWidget {
  const DocumentScanStep({super.key, required this.onDone});

  final VoidCallback onDone;

  @override
  State<DocumentScanStep> createState() => _DocumentScanStepState();
}

class _DocumentScanStepState extends State<DocumentScanStep> {
  bool _frontCaptured = false;
  bool _backCaptured = false;
  bool _reading = false;

  bool get _bothCaptured => _frontCaptured && _backCaptured;

  Future<void> _capture({required bool front}) async {
    // Aquí va la captura real con `camera` + OCR del documento.
    // Ver README.md → "Integrar verificación de identidad".
    setState(() => _reading = true);
    await Future<void>.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;

    setState(() {
      _reading = false;
      if (front) {
        _frontCaptured = true;
      } else {
        _backCaptured = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);

    return StepScaffold(
      icon: Icons.badge_outlined,
      title: l10n.stepDocument,
      body: l10n.stepDocumentBody,
      actionLabel: l10n.continueLabel,
      actionEnabled: _bothCaptured && !_reading,
      onAction: widget.onDone,
      child: Column(
        children: [
          _DocumentFrame(
            label: l10n.documentFront,
            captured: _frontCaptured,
            busy: _reading && !_frontCaptured,
            busyLabel: l10n.documentReading,
            okLabel: l10n.documentOk,
            captureLabel: l10n.documentCapture,
            onCapture: () => _capture(front: true),
          ),
          const SizedBox(height: TaylorSpacing.md),
          _DocumentFrame(
            label: l10n.documentBack,
            captured: _backCaptured,
            busy: _reading && _frontCaptured && !_backCaptured,
            busyLabel: l10n.documentReading,
            okLabel: l10n.documentOk,
            captureLabel: l10n.documentCapture,
            onCapture: () => _capture(front: false),
          ),
        ],
      ),
    );
  }
}

class _DocumentFrame extends StatelessWidget {
  const _DocumentFrame({
    required this.label,
    required this.captured,
    required this.busy,
    required this.busyLabel,
    required this.okLabel,
    required this.captureLabel,
    required this.onCapture,
  });

  final String label;
  final bool captured;
  final bool busy;
  final String busyLabel;
  final String okLabel;
  final String captureLabel;
  final VoidCallback onCapture;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.bodySmall),
        const SizedBox(height: 8),
        AspectRatio(
          // Proporción de una tarjeta ID-1 (85.6 × 54 mm), la de una INE o
          // licencia. Encuadrar con la forma real reduce recortes.
          aspectRatio: 1.585,
          child: GestureDetector(
            onTap: captured || busy ? null : onCapture,
            child: AnimatedContainer(
              duration: TaylorMotion.normal,
              curve: TaylorMotion.standard,
              decoration: BoxDecoration(
                color: captured
                    ? TaylorColors.verified.withValues(alpha: 0.08)
                    : theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(TaylorRadius.md),
                border: Border.all(
                  color: captured
                      ? TaylorColors.verified
                      : theme.colorScheme.outline,
                  width: captured ? 1.6 : 1,
                ),
              ),
              child: Center(
                child: busy
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              color: TaylorColors.raspberry,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(busyLabel, style: theme.textTheme.bodySmall),
                        ],
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            captured
                                ? Icons.check_circle_rounded
                                : Icons.photo_camera_outlined,
                            size: 30,
                            color: captured
                                ? TaylorColors.verified
                                : TaylorColors.inkFaint,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            captured ? okLabel : captureLabel,
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: captured
                                  ? TaylorColors.verified
                                  : theme.colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
