import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme/taylor_colors.dart';
import '../../core/theme/taylor_theme.dart';
import '../../data/models/chat_message.dart';
import '../../l10n/app_localizations.dart';
import 'chat_controller.dart';
import 'widgets/quick_reply_bar.dart';

/// Chat del viaje.
///
/// El diseño parte de que las dos partes están en situaciones muy distintas:
/// la pasajera espera de pie con el teléfono en la mano; la conductora va al
/// volante. Por eso las respuestas rápidas son el mecanismo principal y el
/// teclado se bloquea para la conductora mientras el coche está en ruta.
///
/// Tampoco hay adjuntos ni compartir ubicación desde aquí: cada superficie
/// nueva es superficie de abuso, y la ubicación ya tiene su propio flujo
/// controlado en la pestaña de Seguridad.
class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({
    super.key,
    required this.tripId,
    required this.role,
    required this.otherPartyName,
    this.keyboardLocked = false,
  });

  final String tripId;

  /// Quién está escribiendo en esta pantalla.
  final ChatSender role;

  final String otherPartyName;

  /// Bloquea el teclado y deja solo respuestas rápidas.
  ///
  /// Se activa para la conductora mientras el viaje está en curso.
  final bool keyboardLocked;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _input = TextEditingController();
  final _scroll = ScrollController();

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _send(String text, {bool quick = false}) {
    ref.read(chatControllerProvider.notifier).send(
          tripId: widget.tripId,
          sender: widget.role,
          text: text,
          isQuickReply: quick,
        );
    _input.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    // Se aplaza al siguiente frame: en este momento la lista todavía no ha
    // reconstruido con el mensaje nuevo y el desplazamiento se quedaría corto.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: TaylorMotion.normal,
        curve: TaylorMotion.emphasized,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final theme = Theme.of(context);
    final messages = ref.watch(tripMessagesProvider(widget.tripId));

    final quickKeys = widget.role == ChatSender.driver
        ? QuickReplies.forDriver
        : QuickReplies.forPassenger;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.otherPartyName, style: theme.textTheme.titleMedium),
            Row(
              children: [
                const Icon(
                  Icons.verified_rounded,
                  size: 13,
                  color: TaylorColors.verified,
                ),
                const SizedBox(width: 4),
                Text(
                  l10n.chatTripOnly,
                  style: theme.textTheme.labelSmall,
                ),
              ],
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: messages.isEmpty
                  ? _EmptyChat(l10n: l10n)
                  : ListView.builder(
                      controller: _scroll,
                      padding: const EdgeInsets.all(TaylorSpacing.md),
                      itemCount: messages.length,
                      itemBuilder: (context, i) => _Bubble(
                        message: messages[i],
                        isMine: messages[i].sender == widget.role,
                      ),
                    ),
            ),

            QuickReplyBar(
              messageKeys: quickKeys,
              onSelected: (text) => _send(text, quick: true),
            ),

            if (widget.keyboardLocked)
              _KeyboardLockedNotice(l10n: l10n)
            else
              _Composer(
                controller: _input,
                hint: l10n.chatHint,
                onSend: () => _send(_input.text),
              ),
          ],
        ),
      ),
    );
  }
}

/// Aviso de teclado bloqueado para la conductora en ruta.
///
/// Explica el motivo en lugar de limitarse a desactivar el campo: una
/// restricción sin explicación se lee como un fallo de la app.
class _KeyboardLockedNotice extends StatelessWidget {
  const _KeyboardLockedNotice({required this.l10n});

  final L10n l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(TaylorSpacing.md),
      padding: const EdgeInsets.all(TaylorSpacing.sm),
      decoration: BoxDecoration(
        color: TaylorColors.caution.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(TaylorRadius.md),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.drive_eta_rounded,
            size: 19,
            color: TaylorColors.caution,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              l10n.chatKeyboardLocked,
              style: theme.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.hint,
    required this.onSend,
  });

  final TextEditingController controller;
  final String hint;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        TaylorSpacing.md,
        0,
        TaylorSpacing.md,
        TaylorSpacing.md,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.send,
              minLines: 1,
              maxLines: 4,
              decoration: InputDecoration(hintText: hint),
              onSubmitted: (_) => onSend(),
            ),
          ),
          const SizedBox(width: TaylorSpacing.sm),
          SizedBox(
            width: 56,
            height: 56,
            child: FilledButton(
              onPressed: onSend,
              style: FilledButton.styleFrom(
                padding: EdgeInsets.zero,
                shape: const CircleBorder(),
                minimumSize: const Size(56, 56),
              ),
              child: const Icon(Icons.arrow_upward_rounded, size: 22),
            ),
          ),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.message, required this.isMine});

  final ChatMessage message;
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.72,
        ),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isMine
              ? TaylorColors.raspberry
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(TaylorRadius.md),
            topRight: const Radius.circular(TaylorRadius.md),
            bottomLeft: Radius.circular(isMine ? TaylorRadius.md : 4),
            bottomRight: Radius.circular(isMine ? 4 : TaylorRadius.md),
          ),
          border: isMine
              ? null
              : Border.all(color: theme.colorScheme.outline),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              message.text,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: isMine ? TaylorColors.white : null,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              DateFormat.jm(locale).format(message.sentAt),
              style: theme.textTheme.labelSmall?.copyWith(
                fontSize: 10,
                color: isMine
                    ? TaylorColors.white.withValues(alpha: 0.75)
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyChat extends StatelessWidget {
  const _EmptyChat({required this.l10n});

  final L10n l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(TaylorSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline_rounded,
              size: 42,
              color: TaylorColors.inkFaint.withValues(alpha: 0.5),
            ),
            const SizedBox(height: TaylorSpacing.sm),
            Text(
              l10n.chatEmpty,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
