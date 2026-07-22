import 'dart:convert';

/// Qué debe hacer la app cuando se toca una notificación.
///
/// Se serializa a JSON en el payload porque es lo único que Android e iOS
/// garantizan que sobrevive a que el proceso muera: cuando la usuaria toca la
/// notificación con la app cerrada, esto es todo lo que llega.
enum NotificationAction {
  /// Abrir el modo conductora con la solicitud entrante.
  openRideRequest,

  /// Aceptar el viaje directamente desde la notificación.
  acceptRide,

  /// Rechazarlo sin abrir la app.
  declineRide,

  /// Abrir el viaje en curso de la pasajera.
  openTrip,

  /// Abrir la pestaña de Seguridad.
  openSafety,

  /// Abrir el panel de la noche en modo empresa.
  openBusinessTonight,
}

class NotificationPayload {
  const NotificationPayload({required this.action, this.referenceId});

  final NotificationAction action;

  /// Identificador del viaje, traslado o solicitud asociada.
  final String? referenceId;

  String encode() => jsonEncode({
        'action': action.name,
        if (referenceId != null) 'ref': referenceId,
      });

  /// Devuelve `null` si el payload es ilegible.
  ///
  /// No lanza: una notificación con formato inesperado —de una versión vieja
  /// de la app, o de un envío mal formado desde el servidor— no debe tumbar
  /// el arranque.
  static NotificationPayload? decode(String? raw) {
    if (raw == null || raw.isEmpty) return null;

    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final name = map['action'] as String?;

      for (final action in NotificationAction.values) {
        if (action.name == name) {
          return NotificationPayload(
            action: action,
            referenceId: map['ref'] as String?,
          );
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
