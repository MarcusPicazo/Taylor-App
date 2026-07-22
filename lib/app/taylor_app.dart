import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/locale/locale_controller.dart';
import '../core/notifications/notification_router.dart';
import '../core/theme/taylor_theme.dart';
import '../l10n/app_localizations.dart';
import 'router.dart';

class TaylorApp extends ConsumerWidget {
  const TaylorApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final locale = ref.watch(localeControllerProvider);

    // Mantiene vivo el listener que reacciona a cambios de sesión. Sin este
    // `watch` el provider nunca se instancia y cerrar sesión dejaría a la
    // usuaria en la pantalla anterior.
    ref.watch(sessionRedirectProvider);

    // Igual para el enrutado de notificaciones: sin watch, tocar un aviso no
    // haría nada.
    ref.watch(notificationRouterProvider);

    return MaterialApp.router(
      title: 'Taylor',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: TaylorTheme.light(),
      darkTheme: TaylorTheme.dark(),
      themeMode: ThemeMode.system,

      // `locale: null` deja que Flutter resuelva el idioma del dispositivo.
      // En cuanto la usuaria elige uno en Configuración, este valor lo fija.
      locale: locale,
      supportedLocales: TaylorLocale.locales,
      localizationsDelegates: const [
        L10n.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
