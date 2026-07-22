import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/locale/locale_controller.dart';
import '../../core/theme/taylor_colors.dart';
import '../../core/theme/taylor_theme.dart';
import '../../l10n/app_localizations.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = L10n.of(context);
    final theme = Theme.of(context);
    final selected = ref.watch(localeControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(TaylorSpacing.lg),
          children: [
            Text(l10n.settingsLanguage, style: theme.textTheme.titleMedium),
            const SizedBox(height: TaylorSpacing.sm),

            // "Idioma del dispositivo" es la primera opción y el valor por
            // defecto: la app debe seguir al teléfono salvo que se le diga
            // explícitamente lo contrario.
            _LanguageRow(
              label: l10n.settingsLanguageSystem,
              selected: selected == null,
              onTap: () => ref
                  .read(localeControllerProvider.notifier)
                  .setLocale(null),
              leading: const Icon(
                Icons.smartphone_rounded,
                size: 22,
                color: TaylorColors.inkMuted,
              ),
            ),

            for (final option in TaylorLocale.supported)
              _LanguageRow(
                label: option.nativeName,
                selected: selected?.languageCode == option.locale.languageCode,
                onTap: () => ref
                    .read(localeControllerProvider.notifier)
                    .setLocale(option.locale),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: CountryFlag.fromCountryCode(
                    option.flagCountry,
                    height: 22,
                    width: 30,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _LanguageRow extends StatelessWidget {
  const _LanguageRow({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.leading,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Widget leading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(TaylorRadius.md),
        child: AnimatedContainer(
          duration: TaylorMotion.fast,
          padding: const EdgeInsets.all(TaylorSpacing.sm),
          decoration: BoxDecoration(
            color: selected
                ? TaylorColors.raspberry.withValues(alpha: 0.08)
                : null,
            borderRadius: BorderRadius.circular(TaylorRadius.md),
            border: Border.all(
              color: selected
                  ? TaylorColors.raspberry
                  : theme.colorScheme.outline,
            ),
          ),
          child: Row(
            children: [
              SizedBox(width: 30, child: Center(child: leading)),
              const SizedBox(width: TaylorSpacing.sm),
              Expanded(
                child: Text(label, style: theme.textTheme.titleMedium),
              ),
              if (selected)
                const Icon(
                  Icons.check_circle_rounded,
                  color: TaylorColors.raspberry,
                  size: 22,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
