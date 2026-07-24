import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/taylor_colors.dart';
import '../theme/taylor_theme.dart';

class TaylorNavDestination {
  const TaylorNavDestination({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
}

/// Barra de navegación flotante en vidrio líquido.
///
/// El indicador **viaja** físicamente entre pestañas en lugar de aparecer en
/// su destino. Durante el trayecto se estira en la dirección del movimiento y
/// se adelgaza —como una gota que se deforma al acelerar— y al llegar recupera
/// su forma.
///
/// Esa deformación es lo que distingue el "liquid glass" de un simple
/// desplazamiento: sin ella el indicador se lee como un rectángulo que se
/// mueve; con ella, como una masa que fluye.
class FloatingGlassNavBar extends StatefulWidget {
  const FloatingGlassNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.destinations,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<TaylorNavDestination> destinations;

  @override
  State<FloatingGlassNavBar> createState() => _FloatingGlassNavBarState();
}

class _FloatingGlassNavBarState extends State<FloatingGlassNavBar>
    with SingleTickerProviderStateMixin {
  static const double _barHeight = 68;

  late final AnimationController _controller;
  late double _from;
  late double _to;

  @override
  void initState() {
    super.initState();
    _from = widget.currentIndex.toDouble();
    _to = _from;

    _controller = AnimationController(
      vsync: this,
      // Suficientemente largo para percibir el viaje, suficientemente corto
      // para no estorbar. Por debajo de ~400 ms la deformación no se aprecia.
      duration: const Duration(milliseconds: 520),
      value: 1,
    );
  }

  @override
  void didUpdateWidget(FloatingGlassNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.currentIndex != widget.currentIndex) {
      // Se arranca desde donde está AHORA, no desde la pestaña anterior: si se
      // toca una tercera pestaña a mitad del trayecto, el indicador sigue
      // desde su posición real en lugar de saltar hacia atrás.
      _from = _position;
      _to = widget.currentIndex.toDouble();
      _controller.forward(from: 0);
    }
  }

  /// Posición interpolada del indicador, en unidades de pestaña.
  double get _position {
    final t = Curves.easeOutCubic.transform(_controller.value);
    return _from + (_to - _from) * t;
  }

  /// 0 en reposo, 1 en el punto más rápido del trayecto.
  ///
  /// Modula el estirado: una campana `sin(pi·t)` vale 0 en los extremos y 1 en
  /// el centro, que es exactamente cómo se deforma un fluido al acelerar y
  /// frenar.
  double get _velocity {
    if (_controller.isCompleted || _from == _to) return 0;
    return math.sin(math.pi * _controller.value) *
        (_to - _from).abs().clamp(0.0, 1.0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        TaylorSpacing.md,
        0,
        TaylorSpacing.md,
        bottomInset > 0 ? bottomInset * 0.5 : TaylorSpacing.md,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(TaylorRadius.xl),
        child: BackdropFilter(
          // Desenfoque alto: el vidrio de Apple difumina bastante y deja pasar
          // el color del fondo, no su detalle.
          filter: ImageFilter.blur(sigmaX: 32, sigmaY: 32),
          child: Container(
            height: _barHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(TaylorRadius.xl),
              color: (isDark ? TaylorColors.surfaceDark : TaylorColors.white)
                  .withValues(alpha: isDark ? 0.32 : 0.55),
              border: Border.all(
                color:
                    TaylorColors.white.withValues(alpha: isDark ? 0.18 : 0.75),
              ),
              boxShadow: [
                BoxShadow(
                  color: TaylorColors.obsidian
                      .withValues(alpha: isDark ? 0.5 : 0.13),
                  blurRadius: 28,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final itemWidth =
                    constraints.maxWidth / widget.destinations.length;

                return AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) {
                    final position = _position;

                    return Stack(
                      children: [
                        _LiquidIndicator(
                          position: position,
                          itemWidth: itemWidth,
                          barHeight: _barHeight,
                          velocity: _velocity,
                        ),
                        Row(
                          children: [
                            for (var i = 0;
                                i < widget.destinations.length;
                                i++)
                              Expanded(
                                child: _NavItem(
                                  destination: widget.destinations[i],
                                  // El color acompaña al indicador en vez de
                                  // cambiar de golpe: así el tinte «fluye».
                                  proximity: (1 - (position - i).abs())
                                      .clamp(0.0, 1.0),
                                  onTap: () {
                                    if (i == widget.currentIndex) return;
                                    HapticFeedback.lightImpact();
                                    widget.onTap(i);
                                  },
                                ),
                              ),
                          ],
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// La gota de marca que se desplaza bajo la pestaña activa.
class _LiquidIndicator extends StatelessWidget {
  const _LiquidIndicator({
    required this.position,
    required this.itemWidth,
    required this.barHeight,
    required this.velocity,
  });

  final double position;
  final double itemWidth;
  final double barHeight;
  final double velocity;

  @override
  Widget build(BuildContext context) {
    // Al viajar se alarga y se estrecha conservando aproximadamente el área.
    // Escalar en ambos ejes se leería como un zoom; deformar en sentidos
    // opuestos es lo que se lee como líquido.
    final width = (itemWidth - 14) * (1 + velocity * 0.34);
    final height = 52 * (1 - velocity * 0.16);

    return Positioned(
      left: itemWidth * position + (itemWidth - width) / 2,
      top: (barHeight - height) / 2,
      width: width,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: TaylorColors.brandGradient,
          borderRadius: BorderRadius.circular(TaylorRadius.md),
          boxShadow: [
            BoxShadow(
              color: TaylorColors.raspberry.withValues(alpha: 0.42),
              blurRadius: 20,
              // El halo se expande con la velocidad: sugiere una estela.
              spreadRadius: velocity * 2,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        // Reflejo especular en el borde superior: es lo que hace que la
        // superficie parezca curva y con volumen, no plana.
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(TaylorRadius.md),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                TaylorColors.white.withValues(alpha: 0.28),
                TaylorColors.white.withValues(alpha: 0),
              ],
              stops: const [0, 0.55],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.destination,
    required this.proximity,
    required this.onTap,
  });

  final TaylorNavDestination destination;

  /// 1 cuando el indicador está justo debajo, 0 a una pestaña o más.
  final double proximity;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inactive = isDark
        ? TaylorColors.white.withValues(alpha: 0.66)
        : TaylorColors.inkMuted;

    final color = Color.lerp(inactive, TaylorColors.white, proximity)!;
    final selected = proximity > 0.5;

    return Semantics(
      button: true,
      selected: selected,
      label: destination.label,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // El icono se eleva al activarse, como si el indicador lo
            // empujara al pasar por debajo.
            Transform.translate(
              offset: Offset(0, -proximity * 1.5),
              child: Icon(
                selected ? destination.activeIcon : destination.icon,
                size: 23 + proximity * 1.5,
                color: color,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              destination.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 11,
                height: 1.1,
                fontWeight: FontWeight.lerp(
                  FontWeight.w500,
                  FontWeight.w600,
                  proximity,
                ),
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
