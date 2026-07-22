import 'package:flutter_riverpod/flutter_riverpod.dart';

/// En qué lado del producto está la usuaria ahora mismo.
///
/// Taylor mantiene pasajera y conductora en una sola app, no en dos. Uber las
/// separa, pero la tesis de Taylor es una comunidad cerrada de mujeres
/// verificadas: obligar a una segunda descarga rompería esa continuidad y
/// duplicaría la superficie de verificación. Además, casi todas las
/// conductoras de Taylor llegan siendo usuarias antes que aspirantes.
enum AppMode { passenger, driver, business }

/// Modo activo. Cambiarlo reencamina toda la navegación.
final appModeProvider = StateProvider<AppMode>((ref) => AppMode.passenger);
