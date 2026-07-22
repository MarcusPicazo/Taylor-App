import 'dart:io';

import 'package:flutter/material.dart';

import '../theme/taylor_colors.dart';

/// Avatar de una usuaria.
///
/// La foto puede venir de dos sitios y hay que distinguirlos: una URL de
/// Firebase Storage se carga con [NetworkImage], pero una imagen recién elegida
/// de la galería es una ruta local y necesita [FileImage]. Pasar una ruta local
/// a NetworkImage falla en silencio y deja el avatar vacío, así que la decisión
/// se centraliza aquí en lugar de repetirse en cada pantalla.
class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    required this.initials,
    this.photoPath,
    this.radius = 30,
    this.backgroundColor,
    this.foregroundColor,
  });

  final String initials;
  final String? photoPath;
  final double radius;
  final Color? backgroundColor;
  final Color? foregroundColor;

  ImageProvider? get _image {
    final path = photoPath;
    if (path == null || path.isEmpty) return null;
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return NetworkImage(path);
    }
    return FileImage(File(path));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final image = _image;

    return CircleAvatar(
      radius: radius,
      backgroundColor:
          backgroundColor ?? TaylorColors.raspberry.withValues(alpha: 0.14),
      backgroundImage: image,
      child: image == null
          ? Text(
              initials,
              style: theme.textTheme.titleLarge?.copyWith(
                fontSize: radius * 0.66,
                color: foregroundColor ?? TaylorColors.raspberry,
              ),
            )
          : null,
    );
  }
}
