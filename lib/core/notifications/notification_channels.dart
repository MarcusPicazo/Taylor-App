import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Canales de notificación de Taylor.
///
/// Están separados por **motivo**, no por modo de la app, y eso es una decisión
/// de seguridad, no de organización: en Android la usuaria puede silenciar
/// cada canal por separado. Si todo viviera en un solo canal, alguien que
/// silencia los resúmenes de su empresa dejaría de recibir también un SOS.
///
/// Regla al añadir uno nuevo: si silenciarlo puede poner a alguien en riesgo,
/// va en su propio canal.
abstract final class TaylorChannels {
  /// Solicitud de viaje entrante para la conductora.
  ///
  /// Importancia máxima: llega mientras conduce y tiene 15 s para responder.
  /// Es el único canal con `fullScreenIntent`.
  static const AndroidNotificationChannel rideRequest =
      AndroidNotificationChannel(
    'taylor_ride_request',
    'Solicitudes de viaje',
    description: 'Viajes entrantes cuando estás en línea como conductora.',
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
  );

  /// Estado del viaje para la pasajera: conductora asignada, llegando, etc.
  static const AndroidNotificationChannel tripStatus =
      AndroidNotificationChannel(
    'taylor_trip_status',
    'Estado del viaje',
    description: 'Avisos sobre tu viaje en curso.',
    importance: Importance.high,
    playSound: true,
  );

  /// Seguridad: SOS, ubicación compartida, avisos a contactos de confianza.
  ///
  /// Importancia máxima y sin agrupar con nada más.
  static const AndroidNotificationChannel safety = AndroidNotificationChannel(
    'taylor_safety',
    'Seguridad',
    description: 'Alertas de seguridad y emergencias. No recomendamos '
        'silenciar este canal.',
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
  );

  /// Panel empresarial: alguien no se presentó, todas llegaron a casa.
  static const AndroidNotificationChannel business =
      AndroidNotificationChannel(
    'taylor_business',
    'Traslados de empresa',
    description: 'Estado de los traslados de tu equipo.',
    importance: Importance.high,
    playSound: true,
  );

  static const List<AndroidNotificationChannel> all = [
    rideRequest,
    tripStatus,
    safety,
    business,
  ];
}
