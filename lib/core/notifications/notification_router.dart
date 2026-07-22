import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app_mode.dart';
import '../../app/router.dart';
import '../../features/business/business_controller.dart';
import '../../features/driver/driver_controller.dart';
import 'notification_payload.dart';
import 'taylor_notifications.dart';

/// Traduce un toque en una notificación a una acción dentro de la app.
///
/// Vive aparte del router para que la lógica de "qué hace este aviso" no se
/// mezcle con la de "qué rutas existen", y para que la fuente de la
/// notificación —local hoy, FCM mañana— sea irrelevante aquí.
final notificationRouterProvider = Provider<void>((ref) {
  StreamSubscription<NotificationPayload>? subscription;

  void handle(NotificationPayload payload) {
    final router = ref.read(routerProvider);

    switch (payload.action) {
      case NotificationAction.acceptRide:
        // Aceptar desde la notificación: se acepta y se lleva directo al
        // viaje, sin pasar por la tarjeta de solicitud que ya no aplica.
        ref.read(driverControllerProvider.notifier).acceptRequest();
        ref.read(appModeProvider.notifier).state = AppMode.driver;
        router.go(Routes.driveHome);

      case NotificationAction.declineRide:
        // No se navega: rechazar desde la bandeja no debería traer la app al
        // frente. La conductora sigue en lo suyo.
        ref.read(driverControllerProvider.notifier).declineRequest();

      case NotificationAction.openRideRequest:
        ref.read(appModeProvider.notifier).state = AppMode.driver;
        router.go(Routes.driveHome);

      case NotificationAction.openTrip:
        ref.read(appModeProvider.notifier).state = AppMode.passenger;
        router.go(Routes.home);

      case NotificationAction.openSafety:
        // La pestaña de Seguridad existe en los modos pasajera y conductora;
        // se respeta en cuál está para no sacarla de contexto.
        final mode = ref.read(appModeProvider);
        router.go(
          mode == AppMode.driver ? Routes.driveSafety : Routes.safety,
        );

      case NotificationAction.openBusinessTonight:
        if (ref.read(businessAccountProvider) == null) return;
        ref.read(appModeProvider.notifier).state = AppMode.business;
        router.go(Routes.businessHome);
    }
  }

  subscription = TaylorNotifications.instance.onTap.listen(handle);

  // Notificación que abrió la app desde estado terminado. Llega antes de que
  // el stream tenga oyentes, así que se consume explícitamente aquí.
  final launch = TaylorNotifications.instance.consumeLaunchPayload();
  if (launch != null) {
    // Se aplaza un frame: el router todavía no ha construido su primera ruta
    // y navegar ahora se perdería.
    scheduleMicrotask(() => handle(launch));
  }

  ref.onDispose(() => subscription?.cancel());
});
