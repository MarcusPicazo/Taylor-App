import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'demo_data.dart';
import 'models/taylor_user.dart';

/// Estado de sesión de la app.
///
/// Es deliberadamente el único sitio que decide si alguien puede pedir un
/// viaje. El router lee de aquí para bloquear rutas, así que ninguna pantalla
/// puede saltarse la verificación por su cuenta.
@immutable
class SessionState {
  const SessionState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  final TaylorUser? user;
  final bool isLoading;
  final String? error;

  bool get isSignedIn => user != null;

  /// Onboarding pendiente: tiene cuenta pero aún no pasó los filtros.
  bool get needsOnboarding =>
      user != null && user!.stage != VerificationStage.verified;

  SessionState copyWith({
    TaylorUser? user,
    bool? isLoading,
    String? error,
    bool clearError = false,
    bool signOut = false,
  }) {
    return SessionState(
      user: signOut ? null : (user ?? this.user),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class SessionController extends StateNotifier<SessionState> {
  SessionController() : super(const SessionState());

  /// Inicio de sesión con la cuenta de exhibición.
  ///
  /// Se resuelve antes de tocar Firebase para que la demo funcione aunque el
  /// proyecto Firebase no esté configurado todavía.
  Future<bool> signInWithDemoAccount(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    await Future<void>.delayed(const Duration(milliseconds: 700));

    if (!TaylorDemo.matches(email, password)) {
      state = state.copyWith(
        isLoading: false,
        error: 'invalidCredentials',
      );
      return false;
    }

    state = const SessionState(user: TaylorDemo.user);
    return true;
  }

  /// Alta con Google/Apple. Devuelve una usuaria en estado [registered]:
  /// autenticarse NO equivale a estar verificada, y el router la enviará al
  /// onboarding de seguridad.
  Future<void> signInWithProvider({
    required String provider,
    required String displayName,
    required String email,
    String? photoUrl,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    await Future<void>.delayed(const Duration(milliseconds: 900));

    state = SessionState(
      user: TaylorUser(
        id: 'user-${DateTime.now().millisecondsSinceEpoch}',
        fullName: displayName,
        email: email,
        photoUrl: photoUrl,
      ),
    );
  }

  /// Acceso con código de empresa aprobado por el equipo de Taylor.
  Future<bool> signInWithBusinessCode(String code) async {
    state = state.copyWith(isLoading: true, clearError: true);
    await Future<void>.delayed(const Duration(milliseconds: 700));

    if (code.trim() != TaylorDemo.businessCode) {
      state = state.copyWith(isLoading: false, error: 'invalidBusinessCode');
      return false;
    }

    state = SessionState(
      user: TaylorDemo.user.copyWith(
        accountType: AccountType.business,
        businessName: 'Grupo Monreal',
      ),
    );
    return true;
  }

  void advanceStage(VerificationStage stage) {
    final user = state.user;
    if (user == null) return;
    state = state.copyWith(user: user.copyWith(stage: stage));
  }

  void updateProfile({
    String? fullName,
    String? photoUrl,
    String? phoneNumber,
    String? countryCode,
  }) {
    final user = state.user;
    if (user == null) return;
    state = state.copyWith(
      user: user.copyWith(
        fullName: fullName,
        photoUrl: photoUrl,
        phoneNumber: phoneNumber,
        countryCode: countryCode,
      ),
    );
  }

  void setEmergencyContacts(List<EmergencyContact> contacts) {
    final user = state.user;
    if (user == null) return;
    state = state.copyWith(user: user.copyWith(emergencyContacts: contacts));
  }

  void signOut() {
    state = const SessionState();
  }
}

final sessionControllerProvider =
    StateNotifierProvider<SessionController, SessionState>(
  (ref) => SessionController(),
);
