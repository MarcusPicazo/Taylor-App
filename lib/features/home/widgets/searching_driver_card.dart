import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../../core/theme/taylor_colors.dart';
import '../../../core/theme/taylor_theme.dart';
import '../../../core/widgets/glass_surface.dart';
import '../../../l10n/app_localizations.dart';

/// Estado "buscando conductora".
///
/// Usa la animación Lottie de `assets/lottie/searching_driver.json` si está
/// presente y, si no, cae en un radar pintado a mano. El fallback no es un
/// parche: garantiza que la app nunca se quede sin feedback en el momento
/// exacto en que la usuaria está esperando, que es cuando más lo necesita.
class SearchingDriverCard extends StatelessWidget {
  const SearchingDriverCard({super.key, required this.onCancel});

  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: TaylorSpacing.md),
      child: GlassSurface(
        padding: const EdgeInsets.all(TaylorSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 130,
              child: Lottie.asset(
                'assets/lottie/searching_driver.json',
                repeat: true,
                errorBuilder: (context, error, stack) => const _RadarPulse(),
              ),
            ),
            const SizedBox(height: TaylorSpacing.sm),
            Text(l10n.searchingTitle, style: theme.textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              l10n.searchingBody,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: TaylorSpacing.md),
            OutlinedButton(
              onPressed: onCancel,
              child: Text(l10n.searchingCancel),
            ),
          ],
        ),
      ),
    );
  }
}

/// Radar de respaldo: tres ondas concéntricas que se expanden y desvanecen.
class _RadarPulse extends StatefulWidget {
  const _RadarPulse();

  @override
  State<_RadarPulse> createState() => _RadarPulseState();
}

class _RadarPulseState extends State<_RadarPulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => CustomPaint(
        painter: _RadarPainter(progress: _controller.value),
        child: child,
      ),
      child: const Center(
        child: Icon(
          Icons.directions_car_rounded,
          size: 34,
          color: TaylorColors.raspberry,
        ),
      ),
    );
  }
}

class _RadarPainter extends CustomPainter {
  _RadarPainter({required this.progress});

  final double progress;

  /// Número de ondas simultáneas. Tres es suficiente para leerse como un pulso
  /// continuo; más satura el espacio de la tarjeta.
  static const int _waves = 3;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = math.min(size.width, size.height) / 2;

    for (var i = 0; i < _waves; i++) {
      // Desfase uniforme entre ondas para que nazcan a intervalos regulares.
      final t = (progress + i / _waves) % 1.0;

      canvas.drawCircle(
        center,
        maxRadius * t,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          // Se desvanecen conforme crecen: sugiere una señal que se propaga.
          ..color = TaylorColors.raspberry.withValues(alpha: (1 - t) * 0.55),
      );
    }
  }

  @override
  bool shouldRepaint(_RadarPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
