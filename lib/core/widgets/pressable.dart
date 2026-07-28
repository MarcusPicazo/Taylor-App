import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/taylor_theme.dart';

/// Envuelve cualquier cosa tocable y le da respuesta física al dedo: se hunde
/// levemente al presionar y vuelve al soltar.
///
/// Es el detalle que más separa una app que se siente "viva" de una que se
/// siente estática. Un `InkWell` da el destello de Material, pero no la
/// sensación de que el elemento tiene masa y responde. Esto se aplica a las
/// tarjetas y filas grandes donde el destello solo no basta.
///
/// La escala es sutil a propósito —0.97—: por debajo se siente que el botón
/// "se cae", por encima no se percibe. Y se acompaña de un háptico ligero,
/// porque el tacto refuerza la respuesta visual sin que haga falta mirar.
class Pressable extends StatefulWidget {
  const Pressable({
    super.key,
    required this.child,
    required this.onTap,
    this.scale = 0.97,
    this.haptic = true,
    this.borderRadius,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double scale;
  final bool haptic;

  /// Si se indica, el destello de toque se recorta a este radio.
  final BorderRadius? borderRadius;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 110),
    reverseDuration: const Duration(milliseconds: 240),
    value: 1,
    lowerBound: 0,
    upperBound: 1,
  );

  // Al soltar, la vuelta lleva un rebote mínimo: da la sensación de que el
  // elemento "recupera" su forma, en lugar de solo dejar de estar hundido.
  late final Animation<double> _scale = Tween<double>(
    begin: widget.scale,
    end: 1,
  ).animate(CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOut,
    reverseCurve: Curves.easeOutBack,
  ));

  bool get _enabled => widget.onTap != null;

  void _down(_) {
    if (!_enabled) return;
    _controller.reverse(); // hacia `scale` (hundido)
  }

  void _up() {
    if (!_enabled) return;
    _controller.forward(); // de vuelta a 1
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _down,
      onTapUp: (_) => _up(),
      onTapCancel: _up,
      onTap: _enabled
          ? () {
              if (widget.haptic) HapticFeedback.lightImpact();
              widget.onTap!();
            }
          : null,
      behavior: HitTestBehavior.opaque,
      child: ScaleTransition(scale: _scale, child: widget.child),
    );
  }
}

/// Entrada escalonada para los hijos de una lista.
///
/// Cada elemento aparece desvaneciéndose y subiendo unos píxeles, con un
/// pequeño desfase respecto al anterior. Es lo que hace que una pantalla
/// "se arme" al abrirse en lugar de aparecer de golpe.
///
/// Corre **una sola vez** al montar: envolver hijos de una lista con
/// animaciones de entrada es un error clásico que las hace re-animarse en cada
/// scroll o reconstrucción. Aquí el controlador dispara en `initState` y no
/// vuelve a hacerlo, pase lo que pase con el padre.
class EntranceList extends StatefulWidget {
  const EntranceList({
    super.key,
    required this.children,
    this.stagger = const Duration(milliseconds: 45),
    this.itemDuration = const Duration(milliseconds: 340),
  });

  final List<Widget> children;

  /// Desfase entre un elemento y el siguiente.
  final Duration stagger;

  final Duration itemDuration;

  @override
  State<EntranceList> createState() => _EntranceListState();
}

class _EntranceListState extends State<EntranceList>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    // Un solo controlador para toda la lista, con duración suficiente para el
    // último elemento (su desfase + su propia animación). Más barato que un
    // controlador por hijo, que en una lista larga sería un derroche.
    final total = widget.itemDuration +
        widget.stagger * (widget.children.length - 1).clamp(0, 999);

    _controller = AnimationController(vsync: this, duration: total)..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalMs = _controller.duration!.inMilliseconds;
    final itemMs = widget.itemDuration.inMilliseconds;
    final staggerMs = widget.stagger.inMilliseconds;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < widget.children.length; i++)
          _EntranceItem(
            controller: _controller,
            // Ventana [inicio, fin] de este elemento dentro del recorrido total.
            begin: (staggerMs * i) / totalMs,
            end: (staggerMs * i + itemMs) / totalMs,
            child: widget.children[i],
          ),
      ],
    );
  }
}

class _EntranceItem extends StatelessWidget {
  const _EntranceItem({
    required this.controller,
    required this.begin,
    required this.end,
    required this.child,
  });

  final AnimationController controller;
  final double begin;
  final double end;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final curve = CurvedAnimation(
      parent: controller,
      curve: Interval(begin, end.clamp(0.0, 1.0), curve: TaylorMotion.emphasized),
    );

    return AnimatedBuilder(
      animation: curve,
      builder: (context, child) {
        return Opacity(
          opacity: curve.value,
          child: Transform.translate(
            // Sube 14 px hasta su sitio. Distancia corta: una entrada larga se
            // siente lenta, y aquí lo que se busca es que "asiente", no viajar.
            offset: Offset(0, 14 * (1 - curve.value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
