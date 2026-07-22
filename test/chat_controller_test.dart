import 'package:flutter_test/flutter_test.dart';
import 'package:taylor/data/models/chat_message.dart';
import 'package:taylor/features/chat/chat_controller.dart';

/// Chat del viaje.
///
/// El aislamiento por viaje no es un detalle de implementación: el chat de
/// Taylor muere con el trayecto a propósito, para no convertirse en un canal
/// de contacto permanente entre desconocidas. Estos tests fijan ese contrato.
void main() {
  setUp(TestWidgetsFlutterBinding.ensureInitialized);

  ChatController controller() {
    final c = ChatController();
    addTearDown(c.dispose);
    return c;
  }

  test('enviar añade el mensaje al viaje', () {
    final c = controller();

    c.send(
      tripId: 't1',
      sender: ChatSender.passenger,
      text: 'Ya salgo',
    );

    expect(c.messagesFor('t1').length, 1);
    expect(c.messagesFor('t1').single.text, 'Ya salgo');
    expect(c.messagesFor('t1').single.isFromPassenger, isTrue);
  });

  test('un mensaje vacío o en blanco se ignora', () {
    final c = controller();

    c.send(tripId: 't1', sender: ChatSender.passenger, text: '');
    c.send(tripId: 't1', sender: ChatSender.passenger, text: '   ');
    c.send(tripId: 't1', sender: ChatSender.passenger, text: '\n\t');

    expect(c.messagesFor('t1'), isEmpty);
  });

  test('el texto se recorta al enviar', () {
    final c = controller();

    c.send(tripId: 't1', sender: ChatSender.driver, text: '  Voy en camino  ');

    expect(c.messagesFor('t1').single.text, 'Voy en camino');
  });

  test('se distingue una respuesta rápida de una escrita', () {
    final c = controller();

    c.send(
      tripId: 't1',
      sender: ChatSender.driver,
      text: 'Ya llegué',
      isQuickReply: true,
    );

    // Importa para moderación: mensajes escritos a mano en un viaje
    // conflictivo se revisan distinto que respuestas predefinidas.
    expect(c.messagesFor('t1').single.isQuickReply, isTrue);
  });

  test('los mensajes de un viaje no se filtran a otro', () {
    final c = controller();

    c.send(tripId: 't1', sender: ChatSender.driver, text: 'Uno');
    c.send(tripId: 't2', sender: ChatSender.driver, text: 'Dos');

    expect(c.messagesFor('t1').length, 1);
    expect(c.messagesFor('t2').length, 1);
    expect(c.messagesFor('t1').single.text, 'Uno');
  });

  test('cerrar un viaje borra solo su conversación', () {
    final c = controller();
    c.send(tripId: 't1', sender: ChatSender.driver, text: 'Uno');
    c.send(tripId: 't2', sender: ChatSender.driver, text: 'Dos');

    c.clearTrip('t1');

    expect(c.messagesFor('t1'), isEmpty);
    expect(c.messagesFor('t2').length, 1);
  });

  test('un viaje sin mensajes devuelve lista vacía, no null', () {
    final c = controller();

    expect(c.messagesFor('inexistente'), isEmpty);
  });
}
