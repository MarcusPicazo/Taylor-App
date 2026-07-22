# Animaciones Lottie

## Archivos que la app usa

| Archivo | Dónde | Si falla |
|---|---|---|
| `searching_driver.json` | Tarjeta "Buscando conductora" en Inicio | Cae en un radar pintado a mano, sin error visible |

## searching_driver.json

Tres ondas concéntricas desfasadas 30 frames entre sí, que se expanden desde un
punto central y se desvanecen al crecer. Comunica "estamos buscando cerca de ti"
sin recurrir al reloj de arena, que sugeriría espera pasiva.

Está escrito a mano en el formato de Bodymovin (no exportado de After Effects),
así que se puede editar directamente. Dos detalles no obvios:

- **El desfase se logra con dos segmentos por onda**, no con `st` de capa. Cada
  onda anima de escala 8 % a 100 %, salta de vuelta a 8 % con un keyframe `h`
  (hold), y repite. El salto es invisible porque en ese instante la opacidad ya
  es 0.
- **Los keyframes con `t` negativo son intencionales.** Colocan a las ondas 2 y
  3 a mitad de su ciclo cuando la composición arranca en el frame 0; sin ellos,
  las tres saldrían juntas en el primer bucle.

Colores: rosa de marca `#FF3E81` como `[1, 0.2431, 0.5059, 1]` — Lottie usa
componentes normalizados de 0 a 1, no 0-255.

## Al añadir animaciones nuevas

`test/lottie_asset_test.dart` valida que los Lottie parsean. **Añade el archivo
nuevo a ese test.**

No es burocracia: la app usa `errorBuilder` en cada Lottie, así que un JSON roto
cae al fallback **sin mostrar ningún error**. Esa robustez es correcta en
producción, pero significa que sin test un archivo corrupto pasaría inadvertido
indefinidamente.

## Recomendaciones

- 60 fps, recortada al bucle exacto.
- Por debajo de ~200 KB: los JSON de Lottie se parsean en el hilo de UI y uno
  pesado provoca un tirón justo al aparecer la tarjeta.
- Usa la paleta de `lib/core/theme/taylor_colors.dart`.
