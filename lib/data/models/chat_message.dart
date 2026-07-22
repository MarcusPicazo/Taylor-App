/// Quién envió un mensaje del chat de viaje.
enum ChatSender { passenger, driver }

/// Un mensaje dentro del chat de un viaje.
///
/// El chat está atado a un viaje concreto y muere con él. No existe un
/// historial de conversación entre dos personas a lo largo del tiempo: eso
/// convertiría la app en un canal de contacto persistente entre desconocidas,
/// que es precisamente lo que Taylor no quiere ser.
class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.tripId,
    required this.sender,
    required this.text,
    required this.sentAt,
    this.isQuickReply = false,
  });

  final String id;
  final String tripId;
  final ChatSender sender;
  final String text;
  final DateTime sentAt;

  /// Si vino de un botón de respuesta rápida en vez del teclado.
  ///
  /// Se guarda porque importa para moderación: un patrón de mensajes escritos
  /// a mano en un viaje conflictivo se revisa distinto que respuestas
  /// predefinidas.
  final bool isQuickReply;

  bool get isFromPassenger => sender == ChatSender.passenger;
}

/// Respuestas de un toque.
///
/// Existen sobre todo para la conductora: escribir al volante es peligroso, y
/// una app que lo facilita es cómplice. Cubren el 90 % de lo que realmente se
/// dicen pasajera y conductora en un trayecto — el resto se resuelve con una
/// llamada.
abstract final class QuickReplies {
  /// Claves de traducción; el texto vive en los .arb.
  static const List<String> forDriver = [
    'chatQuickOnMyWay',
    'chatQuickArrived',
    'chatQuickWaitingOutside',
    'chatQuickCantFind',
    'chatQuickTraffic',
  ];

  static const List<String> forPassenger = [
    'chatQuickComingOut',
    'chatQuickTwoMinutes',
    'chatQuickWhereAreYou',
    'chatQuickThanks',
  ];
}
