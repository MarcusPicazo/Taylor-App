/// Claves de API que necesita el código Dart.
///
/// La clave de mapas se inyecta al compilar, no se escribe aquí:
///
/// ```bash
/// flutter run --dart-define=MAPS_API_KEY=tu_clave
/// flutter build apk --dart-define=MAPS_API_KEY=tu_clave
/// ```
///
/// El mapa nativo la lee aparte, desde `android/local.properties`, porque el
/// SDK de Android la necesita en el manifiesto antes de que Dart arranque.
/// Places, en cambio, se consulta desde Dart y necesita esta vía.
///
/// Que esté vacía es un estado válido y contemplado: el buscador cae en su
/// catálogo local y el resto de la app funciona igual. Ver README →
/// "Buscador de destinos".
abstract final class ApiKeys {
  static const String maps = String.fromEnvironment('MAPS_API_KEY');

  static bool get hasMaps => maps.isNotEmpty;
}
