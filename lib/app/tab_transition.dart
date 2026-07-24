import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/theme/taylor_theme.dart';

/// Transición entre pestañas de la barra inferior.
///
/// Las pestañas no se apilan: no hay «atrás». Por eso no se usa la transición
/// de navegación normal —que sugiere profundidad— sino un desplazamiento
/// lateral corto en la **misma dirección en la que viaja el indicador** de la
/// barra. Ir de Inicio a Cuenta empuja el contenido hacia la izquierda; volver
/// lo empuja a la derecha.
///
/// Esa coherencia entre el indicador y el contenido es lo que hace que las
/// cuatro secciones se sientan como un plano horizontal y no como pantallas
/// sueltas.
class TabPage extends CustomTransitionPage<void> {
  const TabPage({
    required super.child,
    required LocalKey super.key,
  }) : super(
          transitionDuration: const Duration(milliseconds: 320),
          reverseTransitionDuration: const Duration(milliseconds: 320),
          transitionsBuilder: _build,
        );

  static Widget _build(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final enter = CurvedAnimation(
      parent: animation,
      curve: TaylorMotion.emphasized,
      reverseCurve: Curves.easeInCubic,
    );

    // Desplazamiento corto: 5 % del ancho. Suficiente para percibir dirección,
    // no tanto como para que cambiar de pestaña se sienta un viaje.
    return FadeTransition(
      opacity: enter,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.05, 0),
          end: Offset.zero,
        ).animate(enter),
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.985, end: 1).animate(enter),
          child: child,
        ),
      ),
    );
  }
}
