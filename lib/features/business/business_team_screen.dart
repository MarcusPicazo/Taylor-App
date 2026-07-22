import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/taylor_colors.dart';
import '../../core/theme/taylor_theme.dart';
import '../../core/widgets/taylor_phone_field.dart';
import '../../data/models/business_account.dart';
import '../../l10n/app_localizations.dart';
import 'business_controller.dart';

/// Padrón de empleadas de la empresa.
class BusinessTeamScreen extends ConsumerWidget {
  const BusinessTeamScreen({super.key});

  void _addEmployee(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _AddEmployeeSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = L10n.of(context);
    final theme = Theme.of(context);
    final account = ref.watch(businessAccountProvider);

    if (account == null) return const SizedBox.shrink();

    final active = account.employees.where((e) => e.isActive).toList();
    final inactive = account.employees.where((e) => !e.isActive).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addEmployee(context),
        backgroundColor: TaylorColors.raspberry,
        foregroundColor: TaylorColors.white,
        icon: const Icon(Icons.person_add_alt_rounded),
        label: Text(l10n.bizAddEmployee),
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
                    l10n.bizTeamTitle,
                    style: theme.textTheme.displayMedium,
                  ),
                  Text(
                    l10n.bizEmployeeCount(active.length),
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: TaylorSpacing.md),

            for (final employee in active)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _EmployeeTile(
                  employee: employee,
                  onToggle: () => ref
                      .read(businessAccountProvider.notifier)
                      .setEmployeeActive(employee.id, false),
                ),
              ),

            if (inactive.isNotEmpty) ...[
              const SizedBox(height: TaylorSpacing.md),
              Text(l10n.bizInactive, style: theme.textTheme.titleMedium),
              const SizedBox(height: TaylorSpacing.sm),
              for (final employee in inactive)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _EmployeeTile(
                    employee: employee,
                    onToggle: () => ref
                        .read(businessAccountProvider.notifier)
                        .setEmployeeActive(employee.id, true),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EmployeeTile extends StatelessWidget {
  const _EmployeeTile({required this.employee, required this.onToggle});

  final Employee employee;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final theme = Theme.of(context);

    return Opacity(
      opacity: employee.isActive ? 1 : 0.55,
      child: Container(
        padding: const EdgeInsets.all(TaylorSpacing.sm),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(TaylorRadius.lg),
          border: Border.all(color: theme.colorScheme.outline),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor:
                  TaylorColors.raspberry.withValues(alpha: 0.14),
              child: Text(
                employee.initials,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: TaylorColors.raspberry,
                ),
              ),
            ),
            const SizedBox(width: TaylorSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    employee.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium,
                  ),
                  Text(
                    [employee.department, employee.homeArea]
                        .whereType<String>()
                        .join(' · '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: onToggle,
              style: TextButton.styleFrom(
                foregroundColor: employee.isActive
                    ? TaylorColors.inkMuted
                    : TaylorColors.raspberry,
              ),
              child: Text(
                employee.isActive ? l10n.bizDeactivate : l10n.bizReactivate,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddEmployeeSheet extends ConsumerStatefulWidget {
  const _AddEmployeeSheet();

  @override
  ConsumerState<_AddEmployeeSheet> createState() => _AddEmployeeSheetState();
}

class _AddEmployeeSheetState extends ConsumerState<_AddEmployeeSheet> {
  final _name = TextEditingController();
  final _department = TextEditingController();
  final _homeArea = TextEditingController();
  String _phone = '';

  bool get _canSave => _name.text.trim().isNotEmpty && _phone.length > 8;

  @override
  void dispose() {
    _name.dispose();
    _department.dispose();
    _homeArea.dispose();
    super.dispose();
  }

  void _save() {
    ref.read(businessAccountProvider.notifier).addEmployee(
          name: _name.text.trim(),
          phone: _phone,
          department: _department.text.trim().isEmpty
              ? null
              : _department.text.trim(),
          homeArea:
              _homeArea.text.trim().isEmpty ? null : _homeArea.text.trim(),
        );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Padding(
        padding: const EdgeInsets.all(TaylorSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.bizAddEmployee, style: theme.textTheme.titleLarge),
            const SizedBox(height: TaylorSpacing.md),

            TextField(
              controller: _name,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: l10n.bizEmployeeName,
                prefixIcon: const Icon(Icons.person_outline_rounded),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: TaylorSpacing.sm),

            TaylorPhoneField(
              label: l10n.phoneLabel,
              onChanged: (phone) =>
                  setState(() => _phone = phone.completeNumber),
            ),
            const SizedBox(height: TaylorSpacing.sm),

            TextField(
              controller: _department,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: l10n.bizEmployeeDepartment,
                prefixIcon: const Icon(Icons.badge_outlined),
              ),
            ),
            const SizedBox(height: TaylorSpacing.sm),

            TextField(
              controller: _homeArea,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: l10n.bizEmployeeArea,
                // La zona basta para planificar; la dirección exacta la captura
                // la empleada en su propia app y la empresa no la ve.
                helperText: l10n.bizEmployeeAreaHelp,
                prefixIcon: const Icon(Icons.map_outlined),
              ),
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
