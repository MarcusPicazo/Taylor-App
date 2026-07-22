import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../core/theme/taylor_colors.dart';
import '../../core/theme/taylor_theme.dart';
import '../../core/widgets/taylor_logo.dart';
import '../../data/session_controller.dart';
import '../../l10n/app_localizations.dart';
import 'widgets/provider_button.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  /// El botón de Apple solo aparece en iOS. Mostrarlo en Android confundiría
  /// y, además, App Store solo lo exige donde hay otros proveedores sociales.
  bool get _showAppleSignIn => !kIsWeb && Platform.isIOS;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = L10n.of(context);
    final theme = Theme.of(context);
    final session = ref.watch(sessionControllerProvider);

    return Scaffold(
      body: Stack(
        children: [
          // Un lavado de color de marca en la parte superior que se funde con
          // el lienzo, para que la pantalla no se sienta un formulario vacío.
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.sizeOf(context).height * 0.44,
            child: const DecoratedBox(
              decoration: BoxDecoration(gradient: TaylorColors.brandGradient),
            ),
          ),
          // El degradado debe terminar ANTES de donde empieza el texto oscuro.
          // Antes se solapaban y "Bienvenida a Taylor" quedaba en 2.8:1 sobre
          // el rosa residual, por debajo del 3.0 que exige el texto grande.
          Positioned(
            top: MediaQuery.sizeOf(context).height * 0.24,
            left: 0,
            right: 0,
            height: MediaQuery.sizeOf(context).height * 0.20,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    theme.scaffoldBackgroundColor.withValues(alpha: 0),
                    theme.scaffoldBackgroundColor,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: TaylorSpacing.lg,
              ),
              child: Column(
                children: [
                  const Spacer(flex: 3),

                  const TaylorLogo(size: 64, color: TaylorColors.white),
                  const SizedBox(height: TaylorSpacing.sm),
                  // Blanco puro y a tamaño de titular: sobre el rosa de marca,
                  // el blanco da 3.4:1, que cumple para texto grande (3.0) pero
                  // no para texto normal (4.5). Subir el tamaño es lo correcto
                  // aquí — es un eslogan, no un párrafo.
                  Text(
                    l10n.appTagline,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: TaylorColors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const Spacer(flex: 4),

                  Text(
                    l10n.loginTitle,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.displayMedium,
                  ),
                  const SizedBox(height: TaylorSpacing.xs),
                  Text(
                    l10n.loginSubtitle,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium,
                  ),

                  const SizedBox(height: TaylorSpacing.lg),

                  ProviderButton(
                    icon: Icons.g_mobiledata_rounded,
                    label: l10n.loginWithGoogle,
                    busy: session.isLoading,
                    onTap: () => ref
                        .read(sessionControllerProvider.notifier)
                        .signInWithProvider(
                          provider: 'google',
                          displayName: 'Nueva usuaria',
                          email: 'usuaria@gmail.com',
                        ),
                  ),

                  if (_showAppleSignIn) ...[
                    const SizedBox(height: TaylorSpacing.sm),
                    ProviderButton(
                      icon: Icons.apple_rounded,
                      label: l10n.loginWithApple,
                      busy: session.isLoading,
                      onTap: () => ref
                          .read(sessionControllerProvider.notifier)
                          .signInWithProvider(
                            provider: 'apple',
                            displayName: 'Nueva usuaria',
                            email: 'usuaria@icloud.com',
                          ),
                    ),
                  ],

                  const SizedBox(height: TaylorSpacing.md),

                  // Acceso B2B. Taylor prioriza empresas, así que este camino
                  // es visible desde el primer momento y no está escondido.
                  _BusinessEntry(
                    hint: l10n.loginBusinessHint,
                    label: l10n.loginBusiness,
                    onTap: () => context.push(Routes.business),
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
                          Icons.verified_user_rounded,
                          size: 19,
                          color: TaylorColors.verified,
                        ),
                        const SizedBox(width: TaylorSpacing.xs),
                        Expanded(
                          child: Text(
                            l10n.loginPassengersOnly,
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(flex: 2),

                  TextButton(
                    onPressed: () => context.push(Routes.demoLogin),
                    child: Text(l10n.loginDemoAccess),
                  ),
                  Text(
                    l10n.loginTerms,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.labelSmall,
                  ),
                  const SizedBox(height: TaylorSpacing.sm),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BusinessEntry extends StatelessWidget {
  const _BusinessEntry({
    required this.hint,
    required this.label,
    required this.onTap,
  });

  final String hint;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(TaylorRadius.md),
      child: Container(
        // 48 dp es el mínimo de área táctil de Android; iOS pide 44. El
        // padding vertical anterior dejaba esta fila en 23 dp.
        constraints: const BoxConstraints(minHeight: 48),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.business_center_outlined,
              size: 18,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            const SizedBox(width: 8),
            Text(hint, style: theme.textTheme.bodySmall),
            const SizedBox(width: 6),
            Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                color: TaylorColors.brandText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
