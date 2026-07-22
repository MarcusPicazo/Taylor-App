import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/notifications/taylor_notifications.dart';
import '../../data/models/chat_message.dart';

/// Mensajes del viaje activo.
///
/// La conversación vive en memoria y se descarta al terminar el viaje. Cuando
/// exista backend, esto pasa a ser una suscripción a la subcolección de
/// mensajes del viaje en Firestore; la interfaz no cambia.
class ChatController extends StateNotifier<List<ChatMessage>> {
  ChatController() : super(const []);

  Timer? _replyTimer;

  List<ChatMessage> messagesFor(String tripId) =>
      state.where((m) => m.tripId == tripId).toList(growable: false);

  void send({
    required String tripId,
    required ChatSender sender,
    required String text,
    bool isQuickReply = false,
  }) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    state = [
      ...state,
      ChatMessage(
        id: const Uuid().v4(),
        tripId: tripId,
        sender: sender,
        text: trimmed,
        sentAt: DateTime.now(),
        isQuickReply: isQuickReply,
      ),
    ];

    // Simulación de la otra parte mientras no hay backend, para poder
    // demostrar la conversación completa. Se elimina al conectar Firestore.
    if (sender == ChatSender.passenger) {
      _scheduleDemoReply(tripId);
    }
  }

  void _scheduleDemoReply(String tripId) {
    _replyTimer?.cancel();
    _replyTimer = Timer(const Duration(seconds: 3), () {
      state = [
        ...state,
        ChatMessage(
          id: const Uuid().v4(),
          tripId: tripId,
          sender: ChatSender.driver,
          text: 'Voy en camino',
          sentAt: DateTime.now(),
          isQuickReply: true,
        ),
      ];

      // La pasajera puede tener la app en segundo plano esperando el coche.
      TaylorNotifications.instance.showTripStatus(
        tripId: tripId,
        title: 'Mensaje de tu conductora',
        body: 'Voy en camino',
      );
    });
  }

  /// Descarta la conversación al terminar o cancelar el viaje.
  void clearTrip(String tripId) {
    _replyTimer?.cancel();
    state = state.where((m) => m.tripId != tripId).toList(growable: false);
  }

  @override
  void dispose() {
    _replyTimer?.cancel();
    super.dispose();
  }
}

final chatControllerProvider =
    StateNotifierProvider<ChatController, List<ChatMessage>>(
  (ref) => ChatController(),
);

/// Mensajes de un viaje concreto, ya ordenados.
final tripMessagesProvider =
    Provider.family<List<ChatMessage>, String>((ref, tripId) {
  final all = ref.watch(chatControllerProvider);
  final messages = all.where((m) => m.tripId == tripId).toList()
    ..sort((a, b) => a.sentAt.compareTo(b.sentAt));
  return messages;
});

/// Cuántos mensajes de la conductora no ha visto la pasajera.
///
/// Se deriva en lugar de guardarse para que no pueda quedar desincronizado
/// con la lista real de mensajes.
final unreadFromDriverProvider = Provider.family<int, String>((ref, tripId) {
  final messages = ref.watch(tripMessagesProvider(tripId));
  return messages.where((m) => !m.isFromPassenger).length;
});
