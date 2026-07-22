import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Un idioma que la app ofrece, junto con el país cuya bandera lo representa.
///
/// La bandera es del país, no del idioma — no existen banderas de idiomas — así
/// que se elige el país más reconocible para cada locale y se guarda explícito
/// en lugar de derivarlo del código de idioma.
class TaylorLocale {
  const TaylorLocale({
    required this.locale,
    required this.nativeName,
    required this.flagCountry,
  });

  final Locale locale;

  /// El idioma escrito en sí mismo: "Español", no "Spanish".
  final String nativeName;

  /// Código ISO-3166 alpha-2 para renderizar la bandera.
  final String flagCountry;

  static const List<TaylorLocale> supported = [
    TaylorLocale(
      locale: Locale('es'),
      nativeName: 'Español',
      flagCountry: 'MX',
    ),
    TaylorLocale(
      locale: Locale('en'),
      nativeName: 'English',
      flagCountry: 'US',
    ),
  ];

  static List<Locale> get locales =>
      supported.map((l) => l.locale).toList(growable: false);
}

/// Controla el idioma de la app.
///
/// `null` significa "seguir al dispositivo", que es el estado por defecto:
/// la app arranca en el idioma del teléfono y solo se fija si la usuaria elige
/// uno explícitamente en Configuración.
class LocaleController extends StateNotifier<Locale?> {
  LocaleController() : super(null) {
    _restore();
  }

  static const String _prefsKey = 'taylor.locale';

  Future<void> _restore() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_prefsKey);
    if (code != null && code.isNotEmpty) {
      state = Locale(code);
    }
  }

  Future<void> setLocale(Locale? locale) async {
    state = locale;
    final prefs = await SharedPreferences.getInstance();
    if (locale == null) {
      await prefs.remove(_prefsKey);
    } else {
      await prefs.setString(_prefsKey, locale.languageCode);
    }
  }
}

final localeControllerProvider =
    StateNotifierProvider<LocaleController, Locale?>(
  (ref) => LocaleController(),
);
