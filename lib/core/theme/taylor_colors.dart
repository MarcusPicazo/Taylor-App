import 'package:flutter/material.dart';

/// Paleta oficial de Taylor, tomada del brand book.
///
/// La marca se apoya en un rosa frambuesa vibrante sobre superficies muy
/// limpias. El negro obsidiana nunca es negro puro: mantiene la calidez.
abstract final class TaylorColors {
  /// Raspberry Pink — color primario de marca.
  static const Color raspberry = Color(0xFFFF3E81);

  /// Razzmatazz Red — acento profundo, para estados presionados y gradientes.
  static const Color razzmatazz = Color(0xFFD81B60);

  /// Obsidian Black — texto principal y superficies oscuras.
  static const Color obsidian = Color(0xFF1A1A1A);

  /// Pure White.
  static const Color white = Color(0xFFFFFFFF);

  // --- Neutros derivados -------------------------------------------------
  static const Color ink = Color(0xFF1A1A1A);
  static const Color inkMuted = Color(0xFF6B6B6F);
  static const Color inkFaint = Color(0xFF9A9AA0);
  static const Color hairline = Color(0x141A1A1A);
  static const Color canvas = Color(0xFFFAFAFB);
  static const Color canvasDark = Color(0xFF0E0E10);
  static const Color surfaceDark = Color(0xFF1A1A1D);

  // --- Semánticos --------------------------------------------------------
  /// Verde sereno para "verificado". Deliberadamente calmado, no alarmista:
  /// la marca comunica seguridad sin activar el miedo.
  static const Color verified = Color(0xFF17B26A);
  static const Color caution = Color(0xFFF79009);

  /// Rojo de emergencia. Se reserva ÚNICAMENTE para el botón SOS real;
  /// usarlo en cualquier otro sitio diluye su significado.
  static const Color emergency = Color(0xFFE5484D);

  // --- Gradientes --------------------------------------------------------
  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [raspberry, razzmatazz],
  );

  /// Velo usado detrás del glassmorphism en modo claro.
  static const LinearGradient glassSheenLight = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x99FFFFFF), Color(0x40FFFFFF)],
  );

  static const LinearGradient glassSheenDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x2EFFFFFF), Color(0x0FFFFFFF)],
  );
}
