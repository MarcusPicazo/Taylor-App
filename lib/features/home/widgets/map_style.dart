/// Estilos JSON para Google Maps, en las dos variantes de la app.
///
/// Se apagan POIs, negocios y tránsito a propósito: en Taylor el mapa es un
/// instrumento de orientación, no un directorio. Dejar el mapa casi monocromo
/// hace que el rosa de la ruta sea el único acento y se lea de un vistazo.
abstract final class TaylorMapStyle {
  static const String light = '''
[
  {"elementType":"geometry","stylers":[{"color":"#f7f7f8"}]},
  {"elementType":"labels.icon","stylers":[{"visibility":"off"}]},
  {"elementType":"labels.text.fill","stylers":[{"color":"#6b6b6f"}]},
  {"elementType":"labels.text.stroke","stylers":[{"color":"#ffffff"}]},
  {"featureType":"administrative","elementType":"geometry","stylers":[{"visibility":"off"}]},
  {"featureType":"poi","stylers":[{"visibility":"off"}]},
  {"featureType":"transit","stylers":[{"visibility":"off"}]},
  {"featureType":"road","elementType":"geometry","stylers":[{"color":"#ffffff"}]},
  {"featureType":"road.arterial","elementType":"geometry","stylers":[{"color":"#ffffff"}]},
  {"featureType":"road.highway","elementType":"geometry","stylers":[{"color":"#f0f0f2"}]},
  {"featureType":"road.local","elementType":"labels","stylers":[{"visibility":"simplified"}]},
  {"featureType":"landscape.natural","elementType":"geometry","stylers":[{"color":"#eff1f0"}]},
  {"featureType":"water","elementType":"geometry","stylers":[{"color":"#dfe6ec"}]},
  {"featureType":"water","elementType":"labels.text.fill","stylers":[{"color":"#9aa0a6"}]}
]
''';

  static const String dark = '''
[
  {"elementType":"geometry","stylers":[{"color":"#151517"}]},
  {"elementType":"labels.icon","stylers":[{"visibility":"off"}]},
  {"elementType":"labels.text.fill","stylers":[{"color":"#8a8a90"}]},
  {"elementType":"labels.text.stroke","stylers":[{"color":"#151517"}]},
  {"featureType":"administrative","elementType":"geometry","stylers":[{"visibility":"off"}]},
  {"featureType":"poi","stylers":[{"visibility":"off"}]},
  {"featureType":"transit","stylers":[{"visibility":"off"}]},
  {"featureType":"road","elementType":"geometry","stylers":[{"color":"#242428"}]},
  {"featureType":"road.highway","elementType":"geometry","stylers":[{"color":"#2e2e33"}]},
  {"featureType":"road.local","elementType":"labels","stylers":[{"visibility":"simplified"}]},
  {"featureType":"landscape.natural","elementType":"geometry","stylers":[{"color":"#1a1a1d"}]},
  {"featureType":"water","elementType":"geometry","stylers":[{"color":"#0d1117"}]}
]
''';
}
