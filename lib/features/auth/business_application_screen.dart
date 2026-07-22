import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/taylor_colors.dart';
import '../../core/theme/taylor_theme.dart';
import '../../core/widgets/review_pending_view.dart';
import '../../l10n/app_localizations.dart';
import 'widgets/weekly_schedule_picker.dart';

/// Solicitud de cuenta empresarial.
///
/// Incluye la programación semanal desde el propio formulario: para el caso de
/// uso central de Taylor B2B —una empresa que manda a su personal a casa en
/// jornada nocturna— los horarios no son un ajuste posterior, son la razón por
/// la que la empresa solicita la cuenta.
class BusinessApplicationScreen extends StatefulWidget {
  const BusinessApplicationScreen({super.key});

  @override
  State<BusinessApplicationScreen> createState() =>
      _BusinessApplicationScreenState();
}

class _BusinessApplicationScreenState
    extends State<BusinessApplicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _company = TextEditingController();
  final _contact = TextEditingController();
  final _role = TextEditingController();
  final _email = TextEditingController();
  final _employees = TextEditingController();
  final _city = TextEditingController();

  Set<int> _days = {1, 2, 3, 4, 5};
  TimeOfDay _pickupTime = const TimeOfDay(hour: 22, minute: 0);

  bool _submitted = false;

  @override
  void dispose() {
    for (final c in [_company, _contact, _role, _email, _employees, _city]) {
      c.dispose();
    }
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _submitted = true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final theme = Theme.of(context);

    if (_submitted) {
      return Scaffold(
        appBar: AppBar(),
        body: SafeArea(
          child: ReviewPendingView(
            title: l10n.businessSubmittedTitle,
            body: l10n.businessSubmittedBody,
            actionLabel: l10n.done,
            // Se vuelve al login, no a la pantalla anterior: la solicitud ya
            // está enviada y no hay nada que editar.
            onAction: () => context.go('/login'),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.businessRequestAccess)),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(TaylorSpacing.lg),
            children: [
              _field(
                controller: _company,
                label: l10n.businessFormCompany,
                icon: Icons.apartment_rounded,
                l10n: l10n,
              ),
              _field(
                controller: _contact,
                label: l10n.businessFormContact,
                icon: Icons.person_outline_rounded,
                l10n: l10n,
              ),
              _field(
                controller: _role,
                label: l10n.businessFormRole,
                icon: Icons.badge_outlined,
                l10n: l10n,
              ),
              _field(
                controller: _email,
                label: l10n.businessFormEmail,
                icon: Icons.mail_outline_rounded,
                keyboardType: TextInputType.emailAddress,
                l10n: l10n,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.requiredField;
                  }
                  if (!value.contains('@') || !value.contains('.')) {
                    return l10n.invalidEmail;
                  }
                  return null;
                },
              ),
              _field(
                controller: _employees,
                label: l10n.businessFormEmployees,
                icon: Icons.groups_outlined,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                l10n: l10n,
              ),
              _field(
                controller: _city,
                label: l10n.businessFormCity,
                icon: Icons.location_city_rounded,
                l10n: l10n,
              ),

              const SizedBox(height: TaylorSpacing.md),
              Text(l10n.scheduleTitle, style: theme.textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(l10n.scheduleSubtitle, style: theme.textTheme.bodySmall),
              const SizedBox(height: TaylorSpacing.sm),

              WeeklySchedulePicker(
                selectedDays: _days,
                pickupTime: _pickupTime,
                onDaysChanged: (days) => setState(() => _days = days),
                onTimeChanged: (time) => setState(() => _pickupTime = time),
              ),

              const SizedBox(height: TaylorSpacing.lg),
              FilledButton(
                onPressed: _submit,
                child: Text(l10n.businessFormSubmit),
              ),
              const SizedBox(height: TaylorSpacing.sm),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.schedule_rounded,
                    size: 16,
                    color: TaylorColors.inkFaint,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.businessSubmittedBody,
                      style: theme.textTheme.labelSmall,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required L10n l10n,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: TaylorSpacing.sm),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
        ),
        validator: validator ??
            (value) => (value == null || value.trim().isEmpty)
                ? l10n.requiredField
                : null,
      ),
    );
  }
}
