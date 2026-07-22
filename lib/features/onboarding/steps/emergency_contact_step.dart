import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/taylor_colors.dart';
import '../../../core/theme/taylor_theme.dart';
import '../../../data/session_controller.dart';
import '../../../l10n/app_localizations.dart';
import '../../safety/widgets/emergency_contacts_sheet.dart';
import 'step_scaffold.dart';

/// Alta del primer contacto de confianza.
///
/// Se pide con fuerza pero **no se impone**, y esa distinción es deliberada.
/// Una mujer sin red de apoyo cercana es exactamente el perfil para el que
/// Taylor existe; bloquearle el registro por no tener a quién nombrar sería
/// perverso. Además el SOS y la llamada a emergencias funcionan sin contactos:
/// lo que se pierde al saltar este paso es poder avisar a alguien, no la
/// seguridad entera.
///
/// De ahí la forma: el botón principal solo se activa al agregar a alguien, y
/// la salida existe pero es secundaria y dice exactamente qué se pierde.
class EmergencyContactStep extends ConsumerWidget {
  const EmergencyContactStep({super.key, required this.onDone});

  final VoidCallback onDone;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = L10n.of(context);
    final theme = Theme.of(context);
    final contacts =
        ref.watch(sessionControllerProvider).user?.emergencyContacts ?? [];

    return StepScaffold(
      icon: Icons.favorite_outline_rounded,
      title: l10n.stepContacts,
      body: l10n.stepContactsBody,
      actionLabel: l10n.continueLabel,
      actionEnabled: contacts.isNotEmpty,
      onAction: onDone,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final contact in contacts)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.all(TaylorSpacing.sm),
                decoration: BoxDecoration(
                  color: TaylorColors.verified.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(TaylorRadius.md),
                  border: Border.all(
                    color: TaylorColors.verified.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      color: TaylorColors.verified,
                      size: 21,
                    ),
                    const SizedBox(width: TaylorSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.stepContactsAdded(contact.name),
                            style: theme.textTheme.labelLarge,
                          ),
                          Text(
                            contact.relationship == null
                                ? contact.phone
                                : '${contact.relationship} · ${contact.phone}',
                            style: theme.textTheme.labelSmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

          OutlinedButton.icon(
            onPressed: () => showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              builder: (_) => const EmergencyContactsSheet(),
            ),
            icon: const Icon(Icons.person_add_alt_rounded, size: 19),
            label: Text(l10n.stepContactsAdd),
          ),

          // La salida solo tiene sentido mientras no haya agregado a nadie.
          if (contacts.isEmpty) ...[
            const SizedBox(height: TaylorSpacing.md),
            TextButton(
              onPressed: onDone,
              style: TextButton.styleFrom(
                foregroundColor: TaylorColors.inkMuted,
              ),
              child: Text(l10n.stepContactsSkip),
            ),
            Text(
              l10n.stepContactsSkipNote,
              textAlign: TextAlign.center,
              style: theme.textTheme.labelSmall,
            ),
          ],
        ],
      ),
    );
  }
}
