import 'package:flutter/material.dart';

import '../../../core/theme/taylor_colors.dart';
import '../../../core/theme/taylor_theme.dart';
import '../../../l10n/app_localizations.dart';

/// Selector de días y hora para los traslados recurrentes de una empresa.
///
/// Los días se etiquetan con las iniciales del locale activo en lugar de una
/// lista fija, para que en inglés diga L·M·X… en español y M·T·W… en inglés
/// sin duplicar cadenas.
class WeeklySchedulePicker extends StatelessWidget {
  const WeeklySchedulePicker({
    super.key,
    required this.selectedDays,
    required this.pickupTime,
    required this.onDaysChanged,
    required this.onTimeChanged,
  });

  /// Días seleccionados, con la convención de DateTime: 1 = lunes … 7 = domingo.
  final Set<int> selectedDays;
  final TimeOfDay pickupTime;
  final ValueChanged<Set<int>> onDaysChanged;
  final ValueChanged<TimeOfDay> onTimeChanged;

  /// Inicial del día en el idioma activo.
  ///
  /// Se mantiene como tabla explícita en lugar de derivarla de `intl`: las
  /// iniciales de una sola letra son convención tipográfica, no formato de
  /// fecha, y en español la del miércoles es X para no chocar con martes.
  String _dayInitial(BuildContext context, int weekday) {
    const es = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
    const en = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final isSpanish = Localizations.localeOf(context).languageCode == 'es';
    return (isSpanish ? es : en)[weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.scheduleDays, style: theme.textTheme.bodySmall),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (var day = 1; day <= 7; day++)
              _DayChip(
                label: _dayInitial(context, day),
                selected: selectedDays.contains(day),
                onTap: () {
                  final next = Set<int>.from(selectedDays);
                  if (!next.remove(day)) next.add(day);
                  onDaysChanged(next);
                },
              ),
          ],
        ),
        const SizedBox(height: TaylorSpacing.md),
        Text(l10n.schedulePickup, style: theme.textTheme.bodySmall),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () async {
            final picked = await showTimePicker(
              context: context,
              initialTime: pickupTime,
            );
            if (picked != null) onTimeChanged(picked);
          },
          icon: const Icon(Icons.access_time_rounded),
          label: Text(pickupTime.format(context)),
        ),
      ],
    );
  }
}

class _DayChip extends StatelessWidget {
  const _DayChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: TaylorMotion.fast,
        curve: TaylorMotion.standard,
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: selected ? TaylorColors.brandGradient : null,
          color: selected ? null : Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(
            color: selected
                ? Colors.transparent
                : theme.colorScheme.outline,
          ),
        ),
        child: Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            color: selected
                ? TaylorColors.white
                : theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ),
    );
  }
}
