import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/theme/taylor_theme.dart';
import '../../../core/widgets/taylor_phone_field.dart';
import '../../../data/models/taylor_user.dart';
import '../../../data/session_controller.dart';
import '../../../l10n/app_localizations.dart';

/// Alta de un contacto de confianza.
///
/// Se pide en el registro y se puede ampliar después: una cuenta sin contactos
/// deja la mitad de la pestaña de Seguridad sin sentido, así que la app insiste
/// en tener al menos uno.
class EmergencyContactsSheet extends ConsumerStatefulWidget {
  const EmergencyContactsSheet({super.key});

  @override
  ConsumerState<EmergencyContactsSheet> createState() =>
      _EmergencyContactsSheetState();
}

class _EmergencyContactsSheetState
    extends ConsumerState<EmergencyContactsSheet> {
  final _name = TextEditingController();
  final _relationship = TextEditingController();
  String _phone = '';

  bool get _canSave => _name.text.trim().isNotEmpty && _phone.length > 8;

  @override
  void dispose() {
    _name.dispose();
    _relationship.dispose();
    super.dispose();
  }

  void _save() {
    final session = ref.read(sessionControllerProvider);
    final existing = session.user?.emergencyContacts ?? [];

    ref.read(sessionControllerProvider.notifier).setEmergencyContacts([
      ...existing,
      EmergencyContact(
        id: const Uuid().v4(),
        name: _name.text.trim(),
        phone: _phone,
        relationship: _relationship.text.trim().isEmpty
            ? null
            : _relationship.text.trim(),
      ),
    ]);

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final theme = Theme.of(context);

    return Padding(
      // Sube el contenido por encima del teclado.
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Padding(
        padding: const EdgeInsets.all(TaylorSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.safetyAddContact, style: theme.textTheme.titleLarge),
            const SizedBox(height: TaylorSpacing.md),

            TextField(
              controller: _name,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: l10n.safetyContactName,
                prefixIcon: const Icon(Icons.person_outline_rounded),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: TaylorSpacing.sm),

            TaylorPhoneField(
              label: l10n.safetyContactPhone,
              onChanged: (phone) =>
                  setState(() => _phone = phone.completeNumber),
            ),
            const SizedBox(height: TaylorSpacing.sm),

            TextField(
              controller: _relationship,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: l10n.safetyContactRelation,
                prefixIcon: const Icon(Icons.favorite_outline_rounded),
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
