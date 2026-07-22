import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/taylor_colors.dart';
import '../../core/theme/taylor_theme.dart';
import '../../data/models/business_account.dart';
import '../../l10n/app_localizations.dart';
import 'business_controller.dart';
import 'widgets/series_editor_sheet.dart';

/// Programaciones recurrentes de la empresa.
///
/// Se modelan como series ("de lunes a viernes a las 22:00") y no como viajes
/// sueltos, porque el patrón real de una empresa es estable durante meses.
/// Obligar a agendar noche por noche sería el error de diseño que hace que
/// nadie use la herramienta.
class BusinessScheduleScreen extends ConsumerWidget {
  const BusinessScheduleScreen({super.key});

  void _openEditor(BuildContext context, {RideSeries? series}) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => SeriesEditorSheet(series: series),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = L10n.of(context);
    final theme = Theme.of(context);
    final account = ref.watch(businessAccountProvider);

    if (account == null) return const SizedBox.shrink();

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(context),
        backgroundColor: TaylorColors.raspberry,
        foregroundColor: TaylorColors.white,
        icon: const Icon(Icons.add_rounded),
        label: Text(l10n.bizNewSeries),
      ),
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            TaylorSpacing.md,
            TaylorSpacing.md,
            TaylorSpacing.md,
            TaylorSpacing.navBarClearance + 60,
          ),
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.bizScheduleTitle,
                    style: theme.textTheme.displayMedium,
                  ),
                  Text(
                    l10n.bizScheduleSubtitle,
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: TaylorSpacing.md),

            if (account.series.isEmpty)
              Container(
                padding: const EdgeInsets.all(TaylorSpacing.lg),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(TaylorRadius.lg),
                  border: Border.all(color: theme.colorScheme.outline),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.event_note_outlined,
                      size: 42,
                      color: TaylorColors.inkFaint.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: TaylorSpacing.sm),
                    Text(
                      l10n.bizNoSeries,
                      style: theme.textTheme.titleMedium,
                    ),
                  ],
                ),
              )
            else
              for (final series in account.series)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _SeriesCard(
                    series: series,
                    account: account,
                    onEdit: () => _openEditor(context, series: series),
                    onToggle: () => ref
                        .read(businessAccountProvider.notifier)
                        .toggleSeriesActive(series.id),
                    onDelete: () => ref
                        .read(businessAccountProvider.notifier)
                        .deleteSeries(series.id),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

class _SeriesCard extends StatelessWidget {
  const _SeriesCard({
    required this.series,
    required this.account,
    required this.onEdit,
    required this.onToggle,
    required this.onDelete,
  });

  final RideSeries series;
  final BusinessAccount account;
  final VoidCallback onEdit;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  static const List<String> _daysEs = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
  static const List<String> _daysEn = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final theme = Theme.of(context);
    final isSpanish =
        Localizations.localeOf(context).languageCode == 'es';
    final labels = isSpanish ? _daysEs : _daysEn;

    return Opacity(
      // Una serie pausada sigue visible pero atenuada: sigue existiendo y hay
      // que poder reactivarla, pero no debe leerse como activa.
      opacity: series.isActive ? 1 : 0.55,
      child: Container(
        padding: const EdgeInsets.all(TaylorSpacing.md),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(TaylorRadius.lg),
          border: Border.all(color: theme.colorScheme.outline),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    series.label,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                Switch(
                  value: series.isActive,
                  onChanged: (_) => onToggle(),
                  activeThumbColor: TaylorColors.verified,
                ),
              ],
            ),
            const SizedBox(height: 4),

            Row(
              children: [
                const Icon(
                  Icons.access_time_rounded,
                  size: 16,
                  color: TaylorColors.inkMuted,
                ),
                const SizedBox(width: 6),
                Text(
                  series.pickupTime.format(context),
                  style: theme.textTheme.labelLarge,
                ),
                const SizedBox(width: 14),
                const Icon(
                  Icons.groups_outlined,
                  size: 16,
                  color: TaylorColors.inkMuted,
                ),
                const SizedBox(width: 6),
                Text(
                  l10n.bizEmployeeCount(series.employeeIds.length),
                  style: theme.textTheme.labelLarge,
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              series.originAddress,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall,
            ),

            const SizedBox(height: TaylorSpacing.sm),

            Row(
              children: [
                for (var day = 1; day <= 7; day++)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: _DayDot(
                      label: labels[day - 1],
                      active: series.days.contains(day),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: TaylorSpacing.sm),
            Divider(color: theme.colorScheme.outline),

            Row(
              children: [
                TextButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 17),
                  label: Text(l10n.bizEdit),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline_rounded, size: 17),
                  label: Text(l10n.bizDelete),
                  style: TextButton.styleFrom(
                    foregroundColor: TaylorColors.inkMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DayDot extends StatelessWidget {
  const _DayDot({required this.label, required this.active});

  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 28,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: active ? TaylorColors.brandGradient : null,
        shape: BoxShape.circle,
        border: active
            ? null
            : Border.all(color: theme.colorScheme.outline),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: active
              ? TaylorColors.white
              : theme.colorScheme.onSurface.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}
