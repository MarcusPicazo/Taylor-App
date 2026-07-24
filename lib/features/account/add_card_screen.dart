import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/theme/taylor_colors.dart';
import '../../core/theme/taylor_theme.dart';
import '../../data/models/payment_card.dart';
import '../../data/wallet_controller.dart';
import '../../l10n/app_localizations.dart';

/// Alta de tarjeta.
///
/// **Advertencia para producción:** este formulario captura el número en la
/// app, y eso solo es aceptable mientras sea una demostración. Antes de
/// procesar dinero real hay que sustituirlo por el widget del procesador
/// (Stripe `CardField`, Conekta, etc.), que captura y tokeniza sin que el
/// número pase por nuestro código.
///
/// La diferencia no es estética: capturar el PAN nos mete en el alcance de
/// PCI-DSS, con auditorías y responsabilidad legal. Aquí el número se valida y
/// se descarta —solo se guardan marca y últimos cuatro— pero aun así no debe
/// llegar a producción tal cual. Ver README → "Pagos".
class AddCardScreen extends ConsumerStatefulWidget {
  const AddCardScreen({super.key});

  @override
  ConsumerState<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends ConsumerState<AddCardScreen> {
  final _number = TextEditingController();
  final _expiry = TextEditingController();
  final _cvv = TextEditingController();
  final _holder = TextEditingController();

  CardBrand _brand = CardBrand.unknown;
  String? _numberError;
  String? _expiryError;

  @override
  void dispose() {
    _number.dispose();
    _expiry.dispose();
    _cvv.dispose();
    _holder.dispose();
    super.dispose();
  }

  String get _digits => _number.text.replaceAll(RegExp(r'\D'), '');

  void _onNumberChanged(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    final brand = CardBrand.fromNumber(digits);
    final formatted = CardValidator.formatNumber(digits, brand);

    // Reescribir el campo mueve el cursor al principio; se devuelve al final,
    // que es donde estaba escribiendo.
    if (formatted != _number.text) {
      _number.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }

    setState(() {
      _brand = brand;
      // Solo se avisa del error cuando el número ya está completo: marcarlo
      // en rojo mientras aún se teclea es agresivo y siempre falso al inicio.
      _numberError = digits.length >= brand.expectedLength &&
              !CardValidator.isValidNumber(digits)
          ? L10n.of(context).cardInvalidNumber
          : null;
    });
  }

  void _onExpiryChanged(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    final formatted = digits.length >= 3
        ? '${digits.substring(0, 2)}/${digits.substring(2)}'
        : digits;

    if (formatted != _expiry.text) {
      _expiry.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }

    setState(() {
      _expiryError = digits.length == 6 && !_parseExpiry(digits).isValid
          ? L10n.of(context).cardInvalidExpiry
          : null;
    });
  }

  /// Interpreta la caducidad como MM/AAAA: dos dígitos de mes y cuatro de año.
  ///
  /// El año completo evita la ambigüedad del formato de dos dígitos, donde
  /// "29" podría ser 2029 o 1929 y hay que asumir el siglo. Con cuatro no hay
  /// nada que asumir.
  ({bool isValid, int month, int year}) _parseExpiry(String digits) {
    if (digits.length != 6) return (isValid: false, month: 0, year: 0);

    final month = int.tryParse(digits.substring(0, 2)) ?? 0;
    final year = int.tryParse(digits.substring(2)) ?? 0;

    return (
      isValid: CardValidator.isValidExpiry(month, year),
      month: month,
      year: year,
    );
  }

  bool get _canSave {
    final expiry = _parseExpiry(_expiry.text.replaceAll(RegExp(r'\D'), ''));
    return CardValidator.isValidNumber(_digits) &&
        expiry.isValid &&
        CardValidator.isValidCvv(_cvv.text, _brand) &&
        _holder.text.trim().isNotEmpty;
  }

  void _save() {
    final expiry = _parseExpiry(_expiry.text.replaceAll(RegExp(r'\D'), ''));

    ref.read(walletControllerProvider.notifier).addCard(
          PaymentCard(
            id: const Uuid().v4(),
            brand: _brand,
            // Aquí es donde se descarta el número: solo sobreviven cuatro
            // dígitos. El resto no se guarda en ningún sitio.
            last4: _digits.substring(_digits.length - 4),
            expiryMonth: expiry.month,
            expiryYear: expiry.year,
          ),
        );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.walletAddCard)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(TaylorSpacing.lg),
          children: [
            _CardPreview(
              brand: _brand,
              digits: _digits,
              holder: _holder.text,
              expiry: _expiry.text,
            ),

            const SizedBox(height: TaylorSpacing.lg),

            TextField(
              controller: _number,
              keyboardType: TextInputType.number,
              autofillHints: const [AutofillHints.creditCardNumber],
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                // 19 = 16 dígitos + 3 espacios.
                LengthLimitingTextInputFormatter(19),
              ],
              onChanged: _onNumberChanged,
              decoration: InputDecoration(
                labelText: l10n.cardNumber,
                hintText: '4242 4242 4242 4242',
                errorText: _numberError,
                prefixIcon: const Icon(Icons.credit_card_rounded),
                suffixIcon: _brand == CardBrand.unknown
                    ? null
                    : Padding(
                        padding: const EdgeInsets.only(right: 14),
                        child: Center(
                          widthFactor: 1,
                          child: Text(
                            _brand.label,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: TaylorColors.brandText,
                            ),
                          ),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: TaylorSpacing.sm),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _expiry,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      // 7 = 2 de mes + 4 de año + la barra.
                      LengthLimitingTextInputFormatter(7),
                    ],
                    onChanged: _onExpiryChanged,
                    decoration: InputDecoration(
                      labelText: l10n.cardExpiry,
                      hintText: 'MM/AAAA',
                      errorText: _expiryError,
                    ),
                  ),
                ),
                const SizedBox(width: TaylorSpacing.sm),
                Expanded(
                  child: TextField(
                    controller: _cvv,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(_brand.cvvLength),
                    ],
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      labelText: l10n.cardCvv,
                      hintText: '•' * _brand.cvvLength,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: TaylorSpacing.sm),

            TextField(
              controller: _holder,
              textCapitalization: TextCapitalization.characters,
              autofillHints: const [AutofillHints.creditCardName],
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: l10n.cardHolder,
                prefixIcon: const Icon(Icons.person_outline_rounded),
              ),
            ),

            const SizedBox(height: TaylorSpacing.md),

            Container(
              padding: const EdgeInsets.all(TaylorSpacing.sm),
              decoration: BoxDecoration(
                color: TaylorColors.verified.withValues(alpha: 0.09),
                borderRadius: BorderRadius.circular(TaylorRadius.md),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.lock_rounded,
                    size: 19,
                    color: TaylorColors.verified,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      l10n.cardSecurityNote,
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: TaylorSpacing.lg),
            FilledButton(
              onPressed: _canSave ? _save : null,
              child: Text(l10n.cardSave),
            ),
          ],
        ),
      ),
    );
  }
}

/// Vista previa de la tarjeta que se está tecleando.
///
/// No es decoración: ver los dígitos aparecer sobre una tarjeta ayuda a
/// detectar un error de tecleo comparando con la tarjeta física que se tiene
/// en la mano.
class _CardPreview extends StatelessWidget {
  const _CardPreview({
    required this.brand,
    required this.digits,
    required this.holder,
    required this.expiry,
  });

  final CardBrand brand;
  final String digits;
  final String holder;
  final String expiry;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final theme = Theme.of(context);

    // Se rellenan los huecos con puntos para que la tarjeta mantenga su forma
    // desde el primer dígito en vez de crecer a saltos.
    final shown = CardValidator.formatNumber(
      digits.padRight(brand.expectedLength, '•'),
      brand,
    );

    return AspectRatio(
      // Proporción ISO/IEC 7810 ID-1, la de una tarjeta real.
      aspectRatio: 1.586,
      child: AnimatedContainer(
        duration: TaylorMotion.normal,
        padding: const EdgeInsets.all(TaylorSpacing.md),
        decoration: BoxDecoration(
          gradient: TaylorColors.brandGradient,
          borderRadius: BorderRadius.circular(TaylorRadius.lg),
          boxShadow: [
            BoxShadow(
              color: TaylorColors.raspberry.withValues(alpha: 0.32),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  Icons.contactless_rounded,
                  color: TaylorColors.white.withValues(alpha: 0.85),
                ),
                Text(
                  brand == CardBrand.unknown ? '' : brand.label,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: TaylorColors.white,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              shown,
              style: theme.textTheme.titleLarge?.copyWith(
                color: TaylorColors.white,
                letterSpacing: 1.5,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            const Spacer(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Text(
                    holder.isEmpty ? l10n.cardHolder.toUpperCase() : holder,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: TaylorColors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ),
                Text(
                  expiry.isEmpty ? 'MM/AAAA' : expiry,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: TaylorColors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
