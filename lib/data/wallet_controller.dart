import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'models/payment_card.dart';

/// Métodos de pago de la usuaria.
///
/// Guarda solo marca, últimos cuatro dígitos y caducidad. El número completo
/// nunca llega aquí — ver `PaymentCard` para el porqué.
class WalletController extends StateNotifier<List<PaymentCard>> {
  WalletController() : super(_seed);

  /// Tarjeta de la cuenta de demostración, para que Wallet no empiece vacío
  /// al enseñarlo.
  static final List<PaymentCard> _seed = [
    PaymentCard(
      id: 'demo-visa',
      brand: CardBrand.visa,
      last4: '4821',
      expiryMonth: 9,
      expiryYear: DateTime.now().year + 3,
      isDefault: true,
    ),
  ];

  void addCard(PaymentCard card) {
    // La primera tarjeta es la predeterminada por definición: no tendría
    // sentido dejar una wallet con un único método y ninguno seleccionado.
    final isFirst = state.isEmpty;
    state = [...state, card.copyWith(isDefault: isFirst)];
  }

  void setDefault(String cardId) {
    state = [
      for (final card in state) card.copyWith(isDefault: card.id == cardId),
    ];
  }

  void remove(String cardId) {
    final removed = state.where((c) => c.id == cardId).firstOrNull;
    final remaining =
        state.where((c) => c.id != cardId).toList(growable: false);

    // Si se borró la predeterminada, la primera que queda toma el relevo:
    // quedarse sin método por defecto rompería el pago del siguiente viaje.
    if (removed?.isDefault == true && remaining.isNotEmpty) {
      state = [
        remaining.first.copyWith(isDefault: true),
        ...remaining.skip(1),
      ];
      return;
    }

    state = remaining;
  }

  PaymentCard? get defaultCard {
    for (final card in state) {
      if (card.isDefault) return card;
    }
    return state.isEmpty ? null : state.first;
  }
}

final walletControllerProvider =
    StateNotifierProvider<WalletController, List<PaymentCard>>(
  (ref) => WalletController(),
);
