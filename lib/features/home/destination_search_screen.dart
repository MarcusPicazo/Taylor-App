import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../core/config/api_keys.dart';
import '../../core/theme/taylor_colors.dart';
import '../../core/theme/taylor_theme.dart';
import '../../data/places_repository.dart';
import '../../l10n/app_localizations.dart';

/// Búsqueda de destino con sugerencias en vivo.
///
/// Pantalla completa y no un desplegable: al teclear un destino, esa es la
/// única tarea, y el teclado ocupa media pantalla de todas formas. Uber, Lyft
/// y Cabify hacen lo mismo por la misma razón.
class DestinationSearchScreen extends ConsumerStatefulWidget {
  const DestinationSearchScreen({super.key});

  @override
  ConsumerState<DestinationSearchScreen> createState() =>
      _DestinationSearchScreenState();
}

class _DestinationSearchScreenState
    extends ConsumerState<DestinationSearchScreen> {
  final _controller = TextEditingController();
  final _focus = FocusNode();

  /// Se conserva entre pulsaciones porque guarda el token de sesión: crear uno
  /// nuevo por búsqueda multiplicaría el costo de Places.
  final _repository = PlacesRepository(apiKey: ApiKeys.maps);

  Timer? _debounce;
  List<PlaceSuggestion> _results = const [];
  bool _searching = false;
  bool _resolving = false;

  @override
  void initState() {
    super.initState();
    // El teclado se abre solo: quien llega aquí ya decidió que va a escribir.
    WidgetsBinding.instance.addPostFrameCallback((_) => _focus.requestFocus());
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();

    if (value.trim().isEmpty) {
      setState(() {
        _results = const [];
        _searching = false;
      });
      return;
    }

    setState(() => _searching = true);

    // 220 ms: por debajo se lanza una búsqueda por tecla —caro cuando esto
    // pase a Places, que cobra por petición— y por encima se nota el retraso.
    _debounce = Timer(const Duration(milliseconds: 220), () async {
      final results = await _repository.search(value);
      if (!mounted) return;

      // La consulta pudo cambiar mientras esta estaba en vuelo; descartarla
      // evita que una respuesta lenta pise a una más reciente.
      if (_controller.text != value) return;

      setState(() {
        _results = results;
        _searching = false;
      });
    });
  }

  /// Elige una sugerencia y devuelve el lugar ya con coordenadas.
  ///
  /// Un resultado de Places llega sin posición: hay que pedirla aparte. Se
  /// hace aquí, al elegir, y no para las ocho sugerencias, porque pedir
  /// coordenadas de resultados que nadie va a usar multiplicaría el costo.
  Future<void> _choose(PlaceSuggestion suggestion) async {
    if (!suggestion.needsResolution) {
      Navigator.of(context).pop(suggestion);
      return;
    }

    setState(() => _resolving = true);
    final resolved = await _repository.resolve(suggestion);
    if (!mounted) return;

    setState(() => _resolving = false);

    if (resolved == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(L10n.of(context).searchResolveFailed)),
      );
      return;
    }

    Navigator.of(context).pop(resolved);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.homeDestination)),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                TaylorSpacing.md,
                0,
                TaylorSpacing.md,
                TaylorSpacing.sm,
              ),
              child: TextField(
                controller: _controller,
                focusNode: _focus,
                textInputAction: TextInputAction.search,
                autocorrect: false,
                onChanged: _onChanged,
                decoration: InputDecoration(
                  hintText: l10n.searchHint,
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: TaylorColors.raspberry,
                  ),
                  suffixIcon: _controller.text.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () {
                            _controller.clear();
                            _onChanged('');
                          },
                        ),
                ),
              ),
            ),

            if (_searching || _resolving) const _SearchingBar(),

            // Marcar el punto en el mapa: para direcciones sin nombre, una
            // entrada de callejón o un punto de encuentro acordado, escribir
            // no sirve. El pin es la salida.
            Padding(
              padding: const EdgeInsets.fromLTRB(
                TaylorSpacing.md,
                4,
                TaylorSpacing.md,
                8,
              ),
              child: OutlinedButton.icon(
                onPressed: () => Navigator.of(context).pop(_pinRequest),
                icon: const Icon(Icons.push_pin_outlined, size: 19),
                label: Text(l10n.searchDropPin),
              ),
            ),

            Expanded(
              child: _results.isEmpty
                  ? _EmptyHint(
                      hasQuery: _controller.text.trim().isNotEmpty,
                      searching: _searching,
                      l10n: l10n,
                    )
                  : ListView.separated(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: const EdgeInsets.symmetric(
                        horizontal: TaylorSpacing.md,
                      ),
                      itemCount: _results.length,
                      separatorBuilder: (_, __) => Divider(
                        height: 1,
                        color: theme.colorScheme.outline,
                      ),
                      itemBuilder: (context, i) => _SuggestionTile(
                        suggestion: _results[i],
                        query: _controller.text.trim(),
                        onTap: () => _choose(_results[i]),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Sentinela que pide abrir el modo de marcar punto en el mapa.
///
/// Se devuelve por el mismo canal que una sugerencia real para que quien abre
/// el buscador no tenga que distinguir dos tipos de resultado; la pantalla de
/// Inicio lo reconoce por su `placeId`.
const PlaceSuggestion _pinRequest = PlaceSuggestion(
  name: '',
  address: '',
  position: LatLng(0, 0),
  placeId: kDropPinRequest,
);

/// Identificador reservado para la petición de marcar en el mapa.
const String kDropPinRequest = '__drop_pin__';

/// Barra de progreso finísima mientras se consulta.
///
/// Reemplazar la lista por un spinner haría parpadear los resultados
/// anteriores en cada tecla; esto indica actividad sin destruir el contexto.
class _SearchingBar extends StatelessWidget {
  const _SearchingBar();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 2,
      child: LinearProgressIndicator(
        minHeight: 2,
        backgroundColor: Colors.transparent,
        valueColor: AlwaysStoppedAnimation(TaylorColors.raspberry),
      ),
    );
  }
}

class _SuggestionTile extends StatelessWidget {
  const _SuggestionTile({
    required this.suggestion,
    required this.query,
    required this.onTap,
  });

  final PlaceSuggestion suggestion;
  final String query;
  final VoidCallback onTap;

  /// Resalta en el nombre la parte que coincide con lo escrito, para que se
  /// vea por qué aparece cada resultado.
  Widget _highlighted(BuildContext context) {
    final theme = Theme.of(context);
    final base = theme.textTheme.titleMedium;
    final name = suggestion.name;

    final index = name.toLowerCase().indexOf(query.toLowerCase());
    if (query.isEmpty || index < 0) return Text(name, style: base);

    return RichText(
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        style: base,
        children: [
          TextSpan(text: name.substring(0, index)),
          TextSpan(
            text: name.substring(index, index + query.length),
            style: base?.copyWith(color: TaylorColors.brandText),
          ),
          TextSpan(text: name.substring(index + query.length)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: TaylorColors.raspberry.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(
                suggestion.isSaved
                    ? Icons.star_rounded
                    : Icons.place_outlined,
                size: 20,
                color: TaylorColors.raspberry,
              ),
            ),
            const SizedBox(width: TaylorSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _highlighted(context),
                  Text(
                    suggestion.address,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.north_east_rounded,
              size: 18,
              color: TaylorColors.inkFaint,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint({
    required this.hasQuery,
    required this.searching,
    required this.l10n,
  });

  final bool hasQuery;
  final bool searching;
  final L10n l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Mientras busca no se dice "sin resultados": sería mentira durante unos
    // milisegundos y provocaría un parpadeo desconcertante.
    if (searching) return const SizedBox.shrink();

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(TaylorSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              hasQuery
                  ? Icons.search_off_rounded
                  : Icons.explore_outlined,
              size: 44,
              color: TaylorColors.inkFaint.withValues(alpha: 0.5),
            ),
            const SizedBox(height: TaylorSpacing.sm),
            Text(
              hasQuery ? l10n.searchNoResults : l10n.searchPrompt,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
