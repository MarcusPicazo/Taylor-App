import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

/// Un lugar que la usuaria puede elegir como origen o destino.
class PlaceSuggestion {
  const PlaceSuggestion({
    required this.name,
    required this.address,
    required this.position,
    this.isSaved = false,
    this.placeId,
  });

  /// Nombre corto: "Torre Reforma", "Aeropuerto AICM".
  final String name;

  /// Dirección completa, para desambiguar entre lugares parecidos.
  final String address;

  final LatLng position;

  /// Lugar guardado de la usuaria (casa, trabajo).
  final bool isSaved;

  /// Identificador de Google Places. Nulo en resultados del catálogo local y
  /// en los puntos marcados a mano en el mapa.
  final String? placeId;

  /// Un resultado de Places llega sin coordenadas: hay que pedirlas aparte.
  bool get needsResolution => placeId != null && position == _unresolved;

  static const LatLng _unresolved = LatLng(0, 0);

  String get searchable => '$name $address'.toLowerCase();
}

/// Búsqueda de destinos.
///
/// Consulta **Google Places** y, si no está disponible, cae en un catálogo
/// local de Ciudad de México. Ese respaldo no es decorativo: sin él, una app
/// sin la Places API habilitada tendría un buscador que no encuentra nada, que
/// es peor que uno limitado.
///
/// ### Control de costo
///
/// Places cobra por petición, y un buscador ingenuo lanza una por tecla. Aquí
/// se usan dos mecanismos:
///
/// - **Token de sesión.** Todas las pulsaciones de una misma búsqueda, más la
///   consulta final de coordenadas, se facturan como *una* sesión en lugar de
///   como N peticiones sueltas. Reduce el costo en un orden de magnitud.
/// - **Debounce** en la pantalla de búsqueda, que evita disparar mientras la
///   usuaria sigue escribiendo.
///
/// Ver README → "Buscador de destinos" para habilitar la API.
class PlacesRepository {
  PlacesRepository({this.apiKey});

  /// Clave de Google. Sin ella se usa solo el catálogo local.
  final String? apiKey;

  static const _uuid = Uuid();

  /// Token de la búsqueda en curso. Se renueva al elegir un resultado, que es
  /// lo que cierra la sesión de facturación.
  String? _sessionToken;

  /// Sesga los resultados a Ciudad de México.
  ///
  /// Sin esto, "reforma" devuelve calles de media Latinoamérica. El sesgo por
  /// ubicación es lo que hace que un buscador se sienta local.
  static const LatLng _bias = LatLng(19.4326, -99.1332);
  static const int _biasRadiusMeters = 50000;

  bool get _canUseRemote => apiKey != null && apiKey!.isNotEmpty;

  /// Sugerencias para lo que se lleva escrito.
  Future<List<PlaceSuggestion>> search(String query) async {
    final trimmed = query.trim();
    if (trimmed.length < 2) return const [];

    if (_canUseRemote) {
      final remote = await _searchRemote(trimmed);
      // Si Places responde, se usa. Si falla —sin red, API no habilitada,
      // cuota agotada— se cae al catálogo en lugar de dejar la pantalla vacía.
      if (remote.isNotEmpty) return remote;
    }

    return _searchLocal(trimmed);
  }

  Future<List<PlaceSuggestion>> _searchRemote(String query) async {
    _sessionToken ??= _uuid.v4();

    final uri = Uri.https(
      'maps.googleapis.com',
      '/maps/api/place/autocomplete/json',
      {
        'input': query,
        'key': apiKey!,
        'sessiontoken': _sessionToken!,
        'location': '${_bias.latitude},${_bias.longitude}',
        'radius': '$_biasRadiusMeters',
        'language': 'es',
        'components': 'country:mx',
      },
    );

    try {
      final response = await http
          .get(uri)
          .timeout(const Duration(seconds: 6));

      if (response.statusCode != 200) return const [];

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final status = body['status'] as String?;

      if (status != 'OK') {
        // REQUEST_DENIED suele significar que la Places API no está habilitada
        // para la clave. Se registra en depuración para que no sea un misterio.
        assert(() {
          if (status != 'ZERO_RESULTS') {
            debugPrint('Places: $status ${body['error_message'] ?? ''}');
          }
          return true;
        }());
        return const [];
      }

      final predictions = (body['predictions'] as List<dynamic>? ?? []);

      return predictions.take(8).map((raw) {
        final p = raw as Map<String, dynamic>;
        final structured =
            p['structured_formatting'] as Map<String, dynamic>? ?? {};

        return PlaceSuggestion(
          name: (structured['main_text'] ?? p['description']) as String,
          address: (structured['secondary_text'] ?? '') as String,
          // Autocomplete no devuelve coordenadas; se piden al elegir.
          position: PlaceSuggestion._unresolved,
          placeId: p['place_id'] as String?,
        );
      }).toList(growable: false);
    } catch (_) {
      return const [];
    }
  }

  /// Obtiene las coordenadas de un resultado de Places.
  ///
  /// Se llama solo al elegir, no por cada sugerencia: pedir coordenadas de
  /// ocho resultados que la usuaria no va a usar multiplicaría el costo por
  /// ocho sin aportar nada.
  Future<PlaceSuggestion?> resolve(PlaceSuggestion suggestion) async {
    if (!suggestion.needsResolution) return suggestion;
    if (!_canUseRemote) return null;

    final uri = Uri.https(
      'maps.googleapis.com',
      '/maps/api/place/details/json',
      {
        'place_id': suggestion.placeId!,
        'key': apiKey!,
        'sessiontoken': _sessionToken ?? _uuid.v4(),
        'fields': 'geometry/location',
        'language': 'es',
      },
    );

    try {
      final response =
          await http.get(uri).timeout(const Duration(seconds: 6));
      if (response.statusCode != 200) return null;

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (body['status'] != 'OK') return null;

      final location = (body['result'] as Map<String, dynamic>)['geometry']
          ['location'] as Map<String, dynamic>;

      // Elegir cierra la sesión: la siguiente búsqueda empieza una nueva.
      _sessionToken = null;

      return PlaceSuggestion(
        name: suggestion.name,
        address: suggestion.address,
        position: LatLng(
          (location['lat'] as num).toDouble(),
          (location['lng'] as num).toDouble(),
        ),
        placeId: suggestion.placeId,
      );
    } catch (_) {
      return null;
    }
  }

  /// Búsqueda sobre el catálogo local.
  List<PlaceSuggestion> _searchLocal(String query) {
    final lower = query.toLowerCase();

    // Se buscan todos los términos por separado: "aero t2" encuentra
    // "Aeropuerto … Terminal 2", que con una subcadena literal fallaría.
    final terms = lower.split(RegExp(r'\s+'));

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

  /// Catálogo de respaldo: colonias, puntos de interés y transporte de CDMX.
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
}
