import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/taylor_app.dart';
import 'core/notifications/taylor_notifications.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Taylor es exclusivamente vertical. El producto se usa en la calle, muchas
  // veces con una sola mano y en movimiento; el modo horizontal no aporta nada
  // y complicaría la barra flotante y el mapa.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
    ),
  );
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // Se inicializa antes de runApp para poder recuperar la notificación que
  // abrió la app: si la usuaria tocó un aviso con la app cerrada, ese dato
  // solo está disponible en el arranque y hay que capturarlo antes de que se
  // construya el primer widget.
  //
  // NO pide permisos aquí. Se piden en contexto — ver TaylorNotifications.
  await TaylorNotifications.instance.initialize();

  // NOTA: Firebase.initializeApp() va aquí, una vez que exista
  // lib/firebase_options.dart generado por `flutterfire configure`.
  // Ver README.md → "Configurar Firebase" y "Activar push remoto".

  runApp(const ProviderScope(child: TaylorApp()));
}
