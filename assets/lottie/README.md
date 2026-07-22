# Animaciones Lottie

Coloca aquí los archivos JSON exportados desde After Effects (Bodymovin) o
descargados de [LottieFiles](https://lottiefiles.com).

## Archivos que la app busca

| Archivo | Dónde se usa | Si falta |
|---|---|---|
| `searching_driver.json` | Tarjeta "Buscando conductora" en Inicio | Cae en un radar pintado a mano, sin error |

La app está construida para no romperse si un Lottie no existe: cada uso pasa
por `errorBuilder`. Aun así, conviene añadirlos — el fallback es funcional, no
equivalente.

## Recomendaciones

- Exporta a 60 fps y recorta la animación al bucle exacto.
- Manténlas por debajo de ~200 KB: los JSON de Lottie se parsean en el hilo de
  UI y uno pesado provoca un tirón justo al aparecer la tarjeta.
- Usa el rosa de marca `#FF3E81` para que combinen con la paleta.
