import 'package:flutter/material.dart';

import '../../core/theme/taylor_colors.dart';
import '../../core/theme/taylor_theme.dart';
import '../../l10n/app_localizations.dart';

/// Métodos de pago.
///
/// La captura de tarjetas NO se implementa aquí: los datos de tarjeta deben
/// entrar por el SDK del procesador (Stripe, Conekta, etc.), que los tokeniza
/// sin que la app llegue a tocarlos. Ver README.md → "Pagos".
class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _PaymentMethod {
  const _PaymentMethod({
    required this.id,
    required this.label,
    required this.icon,
    this.detail,
  });

  final String id;
  final String label;
  final IconData icon;
  final String? detail;
}

class _WalletScreenState extends State<WalletScreen> {
  static const List<_PaymentMethod> _methods = [
    _PaymentMethod(
      id: 'visa',
      label: 'Visa •••• 4821',
      icon: Icons.credit_card_rounded,
      detail: '09/29',
    ),
    _PaymentMethod(
      id: 'mc',
      label: 'Mastercard •••• 1190',
      icon: Icons.credit_card_rounded,
      detail: '02/28',
    ),
    _PaymentMethod(
      id: 'cash',
      label: 'cash',
      icon: Icons.payments_outlined,
    ),
  ];

  String _defaultId = 'visa';

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.walletTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(TaylorSpacing.lg),
          children: [
            Text(l10n.walletMethods, style: theme.textTheme.titleMedium),
            const SizedBox(height: TaylorSpacing.sm),

            for (final method in _methods)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _MethodTile(
                  icon: method.icon,
                  // "cash" es un identificador, no una etiqueta: se traduce.
                  label: method.id == 'cash'
                      ? l10n.walletCash
                      : method.label,
                  detail: method.detail,
                  isDefault: method.id == _defaultId,
                  defaultLabel: l10n.walletDefault,
                  setDefaultLabel: l10n.walletSetDefault,
                  onSetDefault: () => setState(() => _defaultId = method.id),
                ),
              ),

            const SizedBox(height: TaylorSpacing.md),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add_rounded),
              label: Text(l10n.walletAddCard),
            ),
          ],
        ),
      ),
    );
  }
}

class _MethodTile extends StatelessWidget {
  const _MethodTile({
    required this.icon,
    required this.label,
    required this.isDefault,
    required this.defaultLabel,
    required this.setDefaultLabel,
    required this.onSetDefault,
    this.detail,
  });

  final IconData icon;
  final String label;
  final String? detail;
  final bool isDefault;
  final String defaultLabel;
  final String setDefaultLabel;
  final VoidCallback onSetDefault;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedContainer(
      duration: TaylorMotion.fast,
      padding: const EdgeInsets.all(TaylorSpacing.sm),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(TaylorRadius.lg),
        border: Border.all(
          color:
              isDefault ? TaylorColors.raspberry : theme.colorScheme.outline,
          width: isDefault ? 1.6 : 1,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 24, color: TaylorColors.raspberry),
          const SizedBox(width: TaylorSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: theme.textTheme.titleMedium),
                if (detail != null)
                  Text(detail!, style: theme.textTheme.labelSmall),
              ],
            ),
          ),
          if (isDefault)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: TaylorColors.raspberry.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(TaylorRadius.pill),
              ),
              child: Text(
                defaultLabel,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: TaylorColors.raspberry,
                ),
              ),
            )
          else
            TextButton(
              onPressed: onSetDefault,
              child: Text(setDefaultLabel),
            ),
        ],
      ),
    );
  }
}
