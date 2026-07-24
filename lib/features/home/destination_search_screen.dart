import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  final _repository = const PlacesRepository();

  Timer? _debounce;
  List<PlaceSuggestion> _results = const [];
  bool _searching = false;

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

            if (_searching) const _SearchingBar(),

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
                        onTap: () => Navigator.of(context).pop(_results[i]),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

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
