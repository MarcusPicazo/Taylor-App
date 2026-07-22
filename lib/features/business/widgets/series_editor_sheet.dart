import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/taylor_colors.dart';
import '../../../core/theme/taylor_theme.dart';
import '../../../data/models/business_account.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/widgets/weekly_schedule_picker.dart';
import '../business_controller.dart';

/// Alta y edición de una programación recurrente.
///
/// Reutiliza [WeeklySchedulePicker], el mismo control que usa la solicitud de
/// alta empresarial: quien llenó la solicitud reconoce el control cuando ya es
/// cliente, y no hay dos formas distintas de decir lo mismo en el producto.
class SeriesEditorSheet extends ConsumerStatefulWidget {
  const SeriesEditorSheet({super.key, this.series});

  /// `null` crea una serie nueva.
  final RideSeries? series;

  @override
  ConsumerState<SeriesEditorSheet> createState() => _SeriesEditorSheetState();
}

class _SeriesEditorSheetState extends ConsumerState<SeriesEditorSheet> {
  late final TextEditingController _label;
  late final TextEditingController _origin;
  late Set<int> _days;
  late TimeOfDay _pickupTime;
  late Set<String> _employeeIds;

  @override
  void initState() {
    super.initState();

    final series = widget.series;
    _label = TextEditingController(text: series?.label ?? '');
    _origin = TextEditingController(text: series?.originAddress ?? '');
    _days = {...?series?.days};
    _pickupTime = series?.pickupTime ?? const TimeOfDay(hour: 22, minute: 0);
    _employeeIds = {...?series?.employeeIds};

    // Por defecto, lunes a viernes: el patrón de la inmensa mayoría de turnos.
    if (widget.series == null) _days = {1, 2, 3, 4, 5};
  }

  @override
  void dispose() {
    _label.dispose();
    _origin.dispose();
    super.dispose();
  }

  bool get _canSave =>
      _label.text.trim().isNotEmpty &&
      _origin.text.trim().isNotEmpty &&
      _days.isNotEmpty &&
      _employeeIds.isNotEmpty;

  void _save() {
    final existing = widget.series;

    final series = existing == null
        ? newSeries(
            label: _label.text.trim(),
            days: _days,
            pickupTime: _pickupTime,
            originAddress: _origin.text.trim(),
            employeeIds: _employeeIds.toList(),
          )
        : existing.copyWith(
            label: _label.text.trim(),
            days: _days,
            pickupTime: _pickupTime,
            employeeIds: _employeeIds.toList(),
          );

    ref.read(businessAccountProvider.notifier).saveSeries(series);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final theme = Theme.of(context);
    final account = ref.watch(businessAccountProvider);

    if (account == null) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(TaylorSpacing.lg),
          children: [
            Text(
              widget.series == null ? l10n.bizNewSeries : l10n.bizEditSeries,
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: TaylorSpacing.md),

            TextField(
              controller: _label,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: l10n.bizSeriesLabel,
                prefixIcon: const Icon(Icons.label_outline_rounded),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: TaylorSpacing.sm),

            TextField(
              controller: _origin,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: l10n.bizSeriesOrigin,
                prefixIcon: const Icon(Icons.location_on_outlined),
              ),
              onChanged: (_) => setState(() {}),
            ),

            const SizedBox(height: TaylorSpacing.lg),

            WeeklySchedulePicker(
              selectedDays: _days,
              pickupTime: _pickupTime,
              onDaysChanged: (days) => setState(() => _days = days),
              onTimeChanged: (time) => setState(() => _pickupTime = time),
            ),

            const SizedBox(height: TaylorSpacing.lg),

            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.bizSeriesEmployees,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                Text(
                  l10n.bizEmployeeCount(_employeeIds.length),
                  style: theme.textTheme.labelSmall,
                ),
              ],
            ),
            const SizedBox(height: TaylorSpacing.sm),

            for (final employee in account.activeEmployees)
              _EmployeeCheck(
                employee: employee,
                selected: _employeeIds.contains(employee.id),
                onToggle: () => setState(() {
                  if (!_employeeIds.remove(employee.id)) {
                    _employeeIds.add(employee.id);
                  }
                }),
              ),

            const SizedBox(height: TaylorSpacing.lg),
            FilledButton(
              onPressed: _canSave ? _save : null,
              child: Text(l10n.save),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmployeeCheck extends StatelessWidget {
  const _EmployeeCheck({
    required this.employee,
    required this.selected,
    required this.onToggle,
  });

  final Employee employee;
  final bool selected;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onToggle,
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
              Icon(
                selected
                    ? Icons.check_circle_rounded
                    : Icons.circle_outlined,
                size: 21,
                color: selected
                    ? TaylorColors.raspberry
                    : TaylorColors.inkFaint,
              ),
              const SizedBox(width: TaylorSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(employee.name, style: theme.textTheme.labelLarge),
                    if (employee.homeArea != null)
                      Text(
                        employee.homeArea!,
                        style: theme.textTheme.labelSmall,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
