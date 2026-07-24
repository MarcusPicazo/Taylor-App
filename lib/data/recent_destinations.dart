import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'places_repository.dart';

/// Destinos usados recientemente.
///
/// Es lo que hace que valga la pena desplegar el panel: sin esto, expandirlo
/// solo revelaba un saludo y dos accesos fijos, y no compensaba el gesto.
/// Con historial, desplegar responde a "¿a dónde suelo ir?", que es la
/// pregunta real de quien abre una app de movilidad.
class RecentDestinationsController
    extends StateNotifier<List<PlaceSuggestion>> {
  RecentDestinationsController() : super(_seed);

  /// Cuántos se conservan. Más de cinco convierte la lista en un archivo que
  /// hay que leer, y deja de ser un atajo.
  static const int _maxEntries = 5;

  /// Historial inicial de la cuenta de demostración.
  static const List<PlaceSuggestion> _seed = [
    PlaceSuggestion(
      name: 'Oficina',
      address: 'Torre Reforma, Paseo de la Reforma 483',
      position: LatLng(19.4260, -99.1677),
      isSaved: true,
    ),
    PlaceSuggestion(
      name: 'Parque México',
      address: 'Av. México, Hipódromo Condesa',
      position: LatLng(19.4115, -99.1710),
    ),
    PlaceSuggestion(
      name: 'Aeropuerto Internacional AICM',
      address: 'Terminal 2, Venustiano Carranza',
      position: LatLng(19.4210, -99.0836),
    ),
  ];

  /// Registra un destino recién usado.
  ///
  /// Si ya estaba, sube al principio en vez de duplicarse: el historial
  /// refleja *cuándo* fue la última vez, no cuántas veces.
  void remember(PlaceSuggestion place) {
    final without = state
        .where((p) => p.address != place.address)
        .toList(growable: false);

    state = [place, ...without].take(_maxEntries).toList(growable: false);
  }

  void clear() => state = const [];
}

final recentDestinationsProvider = StateNotifierProvider<
    RecentDestinationsController, List<PlaceSuggestion>>(
  (ref) => RecentDestinationsController(),
);
