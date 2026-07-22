import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'notification_channels.dart';
import 'notification_payload.dart';

/// Capa de presentación de notificaciones.
///
/// Deliberadamente **agnóstica del transporte**. Hoy la invocan los
/// controladores locales; mañana la invocará el handler de FCM con el mismo
/// método. Eso significa que activar push remoto no obliga a reescribir ni una
/// sola de estas llamadas — solo a añadir quien las dispara.
///
/// Ver README → "Activar push remoto".
class TaylorNotifications {
  TaylorNotifications._();

  static final TaylorNotifications instance = TaylorNotifications._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Emite el payload de la notificación que la usuaria tocó.
  ///
  /// Es un broadcast porque puede haber varios oyentes según el modo activo, y
  /// porque el router necesita suscribirse sin consumir el evento.
  final StreamController<NotificationPayload> _taps =
      StreamController<NotificationPayload>.broadcast();

  Stream<NotificationPayload> get onTap => _taps.stream;

  /// Payload que abrió la app desde estado terminado.
  ///
  /// Se guarda aparte del stream porque llega antes de que nadie haya podido
  /// suscribirse: si solo se emitiera por el stream, tocar una notificación
  /// con la app cerrada no haría nada.
  NotificationPayload? _launchPayload;

  NotificationPayload? consumeLaunchPayload() {
    final payload = _launchPayload;
    _launchPayload = null;
    return payload;
  }

  Future<void> initialize() async {
    if (_initialized) return;

    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        // Los permisos se piden más tarde, en contexto, no al arrancar.
        // Pedirlos en el primer segundo es la forma más rápida de que alguien
        // diga que no para siempre.
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _handleResponse,
    );

    // ¿La app se abrió tocando una notificación?
    final launch = await _plugin.getNotificationAppLaunchDetails();
    if (launch?.didNotificationLaunchApp ?? false) {
      _launchPayload =
          NotificationPayload.decode(launch!.notificationResponse?.payload);
    }

    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      for (final channel in TaylorChannels.all) {
        await android.createNotificationChannel(channel);
      }
    }

    _initialized = true;
  }

  void _handleResponse(NotificationResponse response) {
    // Las acciones (aceptar/rechazar) traen su propio actionId; el toque
    // normal no. Se resuelve el actionId primero para que pulsar "Aceptar"
    // no se confunda con abrir la notificación.
    final payload = switch (response.actionId) {
      'accept' => NotificationPayload(
          action: NotificationAction.acceptRide,
          referenceId: NotificationPayload.decode(response.payload)?.referenceId,
        ),
      'decline' => NotificationPayload(
          action: NotificationAction.declineRide,
          referenceId: NotificationPayload.decode(response.payload)?.referenceId,
        ),
      _ => NotificationPayload.decode(response.payload),
    };

    if (payload != null) _taps.add(payload);
  }

  /// Pide el permiso de notificaciones.
  ///
  /// Android 13+ (API 33) lo exige en tiempo de ejecución; antes bastaba con
  /// el manifiesto. Se llama en contexto —cuando la conductora se pone en
  /// línea, no al abrir la app— para que la petición tenga sentido y se
  /// acepte.
  Future<bool> requestPermission() async {
    await initialize();

    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      return await android.requestNotificationsPermission() ?? false;
    }

    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      return await ios.requestPermissions(alert: true, badge: true, sound: true) ??
          false;
    }

    return false;
  }

  // --- Notificaciones concretas -------------------------------------------

  /// Solicitud de viaje para la conductora.
  ///
  /// Lleva acciones de aceptar y rechazar para poder responder sin abrir la
  /// app, y `timeoutAfter` igual a la ventana de aceptación: si caduca, la
  /// notificación se retira sola. Dejarla colgada llevaría a aceptar un viaje
  /// que ya se reasignó a otra conductora.
  Future<void> showRideRequest({
    required String requestId,
    required String passengerName,
    required String fare,
    required String pickupAddress,
    Duration timeout = const Duration(seconds: 15),
  }) async {
    await initialize();

    final payload = NotificationPayload(
      action: NotificationAction.openRideRequest,
      referenceId: requestId,
    );

    await _plugin.show(
      _NotificationIds.rideRequest,
      'Viaje de $passengerName · $fare',
      pickupAddress,
      NotificationDetails(
        android: AndroidNotificationDetails(
          TaylorChannels.rideRequest.id,
          TaylorChannels.rideRequest.name,
          channelDescription: TaylorChannels.rideRequest.description,
          importance: Importance.max,
          priority: Priority.max,
          category: AndroidNotificationCategory.call,
          // Se muestra sobre la pantalla de bloqueo: la conductora puede tener
          // el teléfono bloqueado en el soporte.
          fullScreenIntent: true,
          timeoutAfter: timeout.inMilliseconds,
          // No se puede descartar deslizando: responder es la única salida,
          // y así no desaparece por accidente al manipular el teléfono.
          ongoing: true,
          autoCancel: false,
          actions: const [
            AndroidNotificationAction(
              'decline',
              'Rechazar',
              cancelNotification: true,
            ),
            AndroidNotificationAction(
              'accept',
              'Aceptar',
              showsUserInterface: true,
              cancelNotification: true,
            ),
          ],
        ),
        iOS: const DarwinNotificationDetails(
          interruptionLevel: InterruptionLevel.timeSensitive,
        ),
      ),
      payload: payload.encode(),
    );
  }

  Future<void> cancelRideRequest() async {
    await _plugin.cancel(_NotificationIds.rideRequest);
  }

  /// Cambio de estado del viaje, para la pasajera.
  Future<void> showTripStatus({
    required String tripId,
    required String title,
    required String body,
  }) async {
    await initialize();

    await _plugin.show(
      _NotificationIds.tripStatus,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          TaylorChannels.tripStatus.id,
          TaylorChannels.tripStatus.name,
          channelDescription: TaylorChannels.tripStatus.description,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(
          interruptionLevel: InterruptionLevel.timeSensitive,
        ),
      ),
      payload: NotificationPayload(
        action: NotificationAction.openTrip,
        referenceId: tripId,
      ).encode(),
    );
  }

  /// Aviso de seguridad: ubicación compartida, contactos notificados.
  Future<void> showSafetyAlert({
    required String title,
    required String body,
  }) async {
    await initialize();

    await _plugin.show(
      _NotificationIds.safety,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          TaylorChannels.safety.id,
          TaylorChannels.safety.name,
          channelDescription: TaylorChannels.safety.description,
          importance: Importance.max,
          priority: Priority.max,
          category: AndroidNotificationCategory.status,
          // Persistente mientras la ubicación esté compartiéndose: es un
          // estado activo, no un evento puntual.
          ongoing: true,
          autoCancel: false,
        ),
        iOS: const DarwinNotificationDetails(
          interruptionLevel: InterruptionLevel.critical,
        ),
      ),
      payload: const NotificationPayload(
        action: NotificationAction.openSafety,
      ).encode(),
    );
  }

  Future<void> cancelSafetyAlert() async {
    await _plugin.cancel(_NotificationIds.safety);
  }

  /// Aviso del panel empresarial.
  Future<void> showBusinessAlert({
    required String title,
    required String body,
    bool urgent = false,
  }) async {
    await initialize();

    await _plugin.show(
      _NotificationIds.business,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          TaylorChannels.business.id,
          TaylorChannels.business.name,
          channelDescription: TaylorChannels.business.description,
          importance: urgent ? Importance.max : Importance.high,
          priority: urgent ? Priority.max : Priority.high,
          styleInformation: BigTextStyleInformation(body),
        ),
        iOS: DarwinNotificationDetails(
          interruptionLevel: urgent
              ? InterruptionLevel.timeSensitive
              : InterruptionLevel.active,
        ),
      ),
      payload: const NotificationPayload(
        action: NotificationAction.openBusinessTonight,
      ).encode(),
    );
  }

  @visibleForTesting
  Future<void> cancelAll() => _plugin.cancelAll();
}

/// Identificadores fijos por tipo.
///
/// Fijos y no incrementales a propósito: una notificación nueva del mismo tipo
/// debe **reemplazar** a la anterior, no apilarse. Cinco avisos de "tu
/// conductora está llegando" en la bandeja son ruido, no información.
abstract final class _NotificationIds {
  static const int rideRequest = 1001;
  static const int tripStatus = 1002;
  static const int safety = 1003;
  static const int business = 1004;
}
