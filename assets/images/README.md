# Imágenes

## App icon

`app_icon.png` (1024×1024) y `app_icon_foreground.png` son los originales desde
los que se generan los iconos de ambas plataformas.

Regenerar los iconos de plataforma tras cambiarlos:

```bash
dart run flutter_launcher_icons
```

### Por qué hay dos archivos

- **`app_icon.png`** — icono completo: la `t` blanca sobre el gradiente de
  marca. Lo usan iOS y los launchers antiguos de Android.
- **`app_icon_foreground.png`** — solo la `t`, sobre transparencia, y **más
  pequeña**. Android la compone sobre `#FF3E81` y recorta hasta un 66 % del
  lienzo según la forma del launcher (círculo, squircle, etc.). Si se usara la
  `t` del icono completo, el gancho inferior quedaría cortado en los launchers
  circulares.

### Por qué la `t` es geométrica y no la de Poppins

La marca usa Poppins, pero el glifo tipográfico real resulta demasiado fino a
tamaño de icono y se pierde en la pantalla de inicio. La `t` del icono se
construye con cápsulas y un arco de 90°: mismo ADN geométrico —terminaciones
redondeadas, gancho inferior a la derecha— con el grosor que un icono necesita
para leerse a 48 px.

Proporciones, sobre un lienzo de 1024: grosor de trazo 96, tallo de y=280 a
y=650, travesaño de x=368 a x=592 en y=400, gancho de radio 92. Los colores
están en `lib/core/theme/taylor_colors.dart`.

## Pantalla nativa de arranque

No vive aquí, pero está relacionada: `android/app/src/main/res/drawable*/
launch_background.xml` pinta el rosa de marca en lugar del blanco por defecto,
para que no haya parpadeo blanco antes del splash animado de Dart.

## Otros recursos

Coloca aquí el resto de mapas de bits y SVG de la app.
