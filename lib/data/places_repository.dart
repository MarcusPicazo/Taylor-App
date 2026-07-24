import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Un lugar que la usuaria puede elegir como destino.
class PlaceSuggestion {
  const PlaceSuggestion({
    required this.name,
    required this.address,
    required this.position,
    this.isSaved = false,
  });

  /// Nombre corto: "Torre Reforma", "Aeropuerto AICM".
  final String name;

  /// Dirección completa, para desambiguar entre lugares de nombre parecido.
  final String address;

  final LatLng position;

  /// Lugar guardado de la usuaria (casa, trabajo).
  final bool isSaved;

  /// Texto sobre el que se busca.
  String get searchable => '$name $address'.toLowerCase();
}

/// Búsqueda de destinos.
///
/// Hoy resuelve sobre un catálogo local de Ciudad de México. Es una decisión
/// deliberada, no una carencia: Google Places Autocomplete **cobra por
/// pulsación de tecla**, y una demo que se enseña repetidamente generaría
/// factura sin aportar nada. El catálogo local además funciona sin red, que en
/// una demo presencial no es poca cosa.
///
/// La interfaz ya es asíncrona y devuelve `PlaceSuggestion`, así que cambiar a
/// Places es sustituir el cuerpo de [search] — nadie más se entera. Ver
/// README → "Buscador de destinos".
class PlacesRepository {
  const PlacesRepository();

  /// Catálogo de referencia de CDMX: colonias, puntos de interés y transporte.
  static const List<PlaceSuggestion> _catalog = [
    PlaceSuggestion(
      name: 'Aeropuerto Internacional AICM',
      address: 'Terminal 1, Venustiano Carranza',
      position: LatLng(19.4361, -99.0719),
    ),
    PlaceSuggestion(
      name: 'Aeropuerto Internacional AICM',
      address: 'Terminal 2, Venustiano Carranza',
      position: LatLng(19.4210, -99.0836),
    ),
    PlaceSuggestion(
      name: 'Torre Reforma',
      address: 'Paseo de la Reforma 483, Cuauhtémoc',
      position: LatLng(19.4260, -99.1677),
    ),
    PlaceSuggestion(
      name: 'Ángel de la Independencia',
      address: 'Paseo de la Reforma, Juárez',
      position: LatLng(19.4270, -99.1677),
    ),
    PlaceSuggestion(
      name: 'Zócalo',
      address: 'Plaza de la Constitución, Centro Histórico',
      position: LatLng(19.4326, -99.1332),
    ),
    PlaceSuggestion(
      name: 'Parque México',
      address: 'Av. México, Hipódromo Condesa',
      position: LatLng(19.4115, -99.1710),
    ),
    PlaceSuggestion(
      name: 'Coyoacán Centro',
      address: 'Jardín Hidalgo, Coyoacán',
      position: LatLng(19.3500, -99.1620),
    ),
    PlaceSuggestion(
      name: 'Ciudad Universitaria',
      address: 'UNAM, Coyoacán',
      position: LatLng(19.3320, -99.1870),
    ),
    PlaceSuggestion(
      name: 'Antara Polanco',
      address: 'Av. Ejército Nacional 843, Polanco',
      position: LatLng(19.4400, -99.2050),
    ),
    PlaceSuggestion(
      name: 'Santa Fe',
      address: 'Centro Santa Fe, Álvaro Obregón',
      position: LatLng(19.3650, -99.2600),
    ),
    PlaceSuggestion(
      name: 'Roma Norte',
      address: 'Av. Álvaro Obregón, Cuauhtémoc',
      position: LatLng(19.4180, -99.1620),
    ),
    PlaceSuggestion(
      name: 'Condesa',
      address: 'Av. Amsterdam, Cuauhtémoc',
      position: LatLng(19.4110, -99.1710),
    ),
    PlaceSuggestion(
      name: 'Del Valle',
      address: 'Av. Insurgentes Sur, Benito Juárez',
      position: LatLng(19.3830, -99.1650),
    ),
    PlaceSuggestion(
      name: 'Xochimilco',
      address: 'Embarcadero Nuevo Nativitas',
      position: LatLng(19.2600, -99.1030),
    ),
    PlaceSuggestion(
      name: 'Basílica de Guadalupe',
      address: 'Fray Juan de Zumárraga, Gustavo A. Madero',
      position: LatLng(19.4845, -99.1176),
    ),
    PlaceSuggestion(
      name: 'Terminal Norte',
      address: 'Av. de los Cien Metros, Gustavo A. Madero',
      position: LatLng(19.4880, -99.1390),
    ),
    PlaceSuggestion(
      name: 'Terminal TAPO',
      address: 'Calzada Ignacio Zaragoza, Venustiano Carranza',
      position: LatLng(19.4290, -99.1150),
    ),
    PlaceSuggestion(
      name: 'Plaza Satélite',
      address: 'Circuito Centro Comercial, Naucalpan',
      position: LatLng(19.5100, -99.2350),
    ),
    PlaceSuggestion(
      name: 'Iztapalapa Centro',
      address: 'Av. Ermita Iztapalapa',
      position: LatLng(19.3570, -99.0640),
    ),
    PlaceSuggestion(
      name: 'Tlalpan Centro',
      address: 'Plaza de la Constitución, Tlalpan',
      position: LatLng(19.2900, -99.1670),
    ),
  ];

  /// Sugerencias para lo que se lleva escrito.
  ///
  /// El retardo simula la latencia de red para que la interfaz se pruebe en
  /// condiciones parecidas a las reales; sin él, el estado de carga nunca se
  /// vería y podría estar roto sin que nadie lo supiera.
  Future<List<PlaceSuggestion>> search(String query) async {
    final trimmed = query.trim().toLowerCase();
    if (trimmed.isEmpty) return const [];

    await Future<void>.delayed(const Duration(milliseconds: 180));

    // Se buscan todos los términos por separado: "aero t2" encuentra
    // "Aeropuerto ... Terminal 2", que con una subcadena literal fallaría.
    final terms = trimmed.split(RegExp(r'\s+'));

    final matches = _catalog
        .where((p) => terms.every((t) => p.searchable.contains(t)))
        .toList();

    // Los que empiezan por lo escrito van primero: es lo que la usuaria
    // esperaba al teclear.
    matches.sort((a, b) {
      final aStarts = a.name.toLowerCase().startsWith(terms.first);
      final bStarts = b.name.toLowerCase().startsWith(terms.first);
      if (aStarts != bStarts) return aStarts ? -1 : 1;
      return a.name.compareTo(b.name);
    });

    return matches.take(8).toList(growable: false);
  }
}
