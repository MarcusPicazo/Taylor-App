import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../core/theme/taylor_colors.dart';
import '../../core/theme/taylor_theme.dart';
import '../../data/models/payment_card.dart';
import '../../data/wallet_controller.dart';
import '../../l10n/app_localizations.dart';

/// Métodos de pago.
///
/// El efectivo va siempre al final y no se puede borrar: es el método que
/// nunca falla, y en México sigue siendo mayoritario. Una wallet que solo
/// admite tarjeta excluye a buena parte del mercado.
class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = L10n.of(context);
    final theme = Theme.of(context);
    final cards = ref.watch(walletControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.walletTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(TaylorSpacing.lg),
          children: [
            Text(l10n.walletMethods, style: theme.textTheme.titleMedium),
            const SizedBox(height: TaylorSpacing.sm),

            for (final card in cards)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _CardTile(
                  card: card,
                  onSetDefault: () => ref
                      .read(walletControllerProvider.notifier)
                      .setDefault(card.id),
                  onRemove: () => _confirmRemove(context, ref, card),
                ),
              ),

            // Efectivo: siempre disponible, sin acciones.
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.all(TaylorSpacing.sm),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(TaylorRadius.lg),
                  border: Border.all(color: theme.colorScheme.outline),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.payments_outlined,
                      size: 24,
                      color: TaylorColors.raspberry,
                    ),
                    const SizedBox(width: TaylorSpacing.sm),
                    Expanded(
                      child: Text(
                        l10n.walletCash,
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: TaylorSpacing.md),
            OutlinedButton.icon(
              onPressed: () => context.push(Routes.addCard),
              icon: const Icon(Icons.add_rounded),
              label: Text(l10n.walletAddCard),
            ),
          ],
        ),
      ),
    );
  }

  /// Borrar un método de pago se confirma.
  ///
  /// No es destructivo de datos, pero quedarse sin método antes de un viaje sí
  /// es un problema real, y el gesto es fácil de hacer sin querer.
  Future<void> _confirmRemove(
    BuildContext context,
    WidgetRef ref,
    PaymentCard card,
  ) async {
    final l10n = L10n.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.walletRemove),
        content: Text(card.displayNumber),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: TaylorColors.emergency,
            ),
            child: Text(l10n.walletRemove),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      ref.read(walletControllerProvider.notifier).remove(card.id);
    }
  }
}

class _CardTile extends StatelessWidget {
  const _CardTile({
    required this.card,
    required this.onSetDefault,
    required this.onRemove,
  });

  final PaymentCard card;
  final VoidCallback onSetDefault;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final theme = Theme.of(context);
    final expired = card.isExpired;

    return AnimatedContainer(
      duration: TaylorMotion.fast,
      padding: const EdgeInsets.all(TaylorSpacing.sm),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(TaylorRadius.lg),
        border: Border.all(
          color: card.isDefault
              ? TaylorColors.raspberry
              : theme.colorScheme.outline,
          width: card.isDefault ? 1.6 : 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.credit_card_rounded,
            size: 24,
            color: expired ? TaylorColors.inkFaint : TaylorColors.raspberry,
          ),
          const SizedBox(width: TaylorSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  card.displayNumber,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: expired ? TaylorColors.inkMuted : null,
                  ),
                ),
                Text(
                  expired
                      ? l10n.cardExpired
                      : '${l10n.cardExpiry} ${card.displayExpiry}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: expired ? TaylorColors.emergency : null,
                  ),
                ),
              ],
            ),
          ),

          if (card.isDefault)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: TaylorColors.raspberry.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(TaylorRadius.pill),
              ),
              child: Text(
                l10n.walletDefault,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: TaylorColors.brandText,
                ),
              ),
            )
          else if (!expired)
            TextButton(
              onPressed: onSetDefault,
              child: Text(l10n.walletSetDefault),
            ),

          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            color: TaylorColors.inkMuted,
            tooltip: l10n.walletRemove,
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }
}
