import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/taylor_colors.dart';
import '../../core/theme/taylor_theme.dart';
import '../../data/demo_data.dart';
import '../../data/session_controller.dart';
import '../../l10n/app_localizations.dart';
import '../driver/driver_controller.dart';

/// Acceso a la cuenta de exhibición (test@taylor.com / Taylor123).
///
/// Existe para poder enseñar la app completa sin dar de alta a nadie ni
/// depender de que Firebase esté configurado.
class DemoLoginScreen extends ConsumerStatefulWidget {
  const DemoLoginScreen({super.key});

  @override
  ConsumerState<DemoLoginScreen> createState() => _DemoLoginScreenState();
}

class _DemoLoginScreenState extends ConsumerState<DemoLoginScreen> {
  // Precargadas: quien enseña la demo no debería teclear credenciales
  // delante del cliente.
  final _email = TextEditingController(text: TaylorDemo.email);
  final _password = TextEditingController(text: TaylorDemo.password);
  bool _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final ok = await ref
        .read(sessionControllerProvider.notifier)
        .signInWithDemoAccount(_email.text, _password.text);

    if (!ok) return;

    // La cuenta de exhibición viene con perfil de conductora aprobado, para
    // poder enseñar los dos lados del producto sin cerrar sesión.
    ref
        .read(driverProfileProvider.notifier)
        .loadDemoProfile(TaylorDemo.driverProfile());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final theme = Theme.of(context);
    final session = ref.watch(sessionControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.demoTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(TaylorSpacing.lg),
          children: [
            Text(l10n.demoSubtitle, style: theme.textTheme.bodyMedium),
            const SizedBox(height: TaylorSpacing.lg),

            TextField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              decoration: InputDecoration(
                labelText: l10n.emailLabel,
                prefixIcon: const Icon(Icons.mail_outline_rounded),
              ),
            ),
            const SizedBox(height: TaylorSpacing.sm),

            TextField(
              controller: _password,
              obscureText: _obscure,
              decoration: InputDecoration(
                labelText: l10n.passwordLabel,
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscure
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
            ),

            if (session.error == 'invalidCredentials') ...[
              const SizedBox(height: TaylorSpacing.sm),
              Row(
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    size: 18,
                    color: TaylorColors.emergency,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.invalidCredentials,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: TaylorColors.emergency,
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: TaylorSpacing.lg),

            FilledButton(
              onPressed: session.isLoading ? null : _submit,
              child: session.isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: TaylorColors.white,
                      ),
                    )
                  : Text(l10n.signIn),
            ),
          ],
        ),
      ),
    );
  }
}
