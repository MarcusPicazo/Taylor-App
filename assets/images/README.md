# Imágenes

Coloca aquí los recursos de mapa de bits y SVG de la app.

## App icon

El icono se genera desde `assets/images/app_icon.png` (1024×1024, sin
transparencia, sin esquinas redondeadas — iOS y Android las aplican ellos).

Siguiendo la identidad de marca, el icono es la letra **t** en blanco sobre el
rosa frambuesa `#FF3E81`, centrada, con el mismo trazo geométrico del wordmark.
Deja alrededor de un 20 % de margen: Android recorta el icono adaptativo en un
círculo y una **t** pegada al borde se corta.

Una vez colocado el PNG, genera los iconos de ambas plataformas con:

```bash
dart run flutter_launcher_icons
```

(requiere añadir `flutter_launcher_icons` a `dev_dependencies` y su bloque de
configuración en `pubspec.yaml`).
