import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/notifications/taylor_notifications.dart';
import '../../core/theme/taylor_colors.dart';
import '../../core/theme/taylor_theme.dart';
import '../../data/session_controller.dart';
import '../../l10n/app_localizations.dart';
import 'widgets/emergency_contacts_sheet.dart';
import 'widgets/sos_button.dart';

/// Centro de seguridad.
///
/// El orden de la pantalla es el orden de urgencia: primero el SOS, luego
/// avisar a las amigas, luego compartir ubicación y al final administrar
/// contactos. Quien abre esta pestaña en una situación real no debería tener
/// que desplazarse para encontrar lo más urgente.
class SafetyScreen extends ConsumerStatefulWidget {
  const SafetyScreen({super.key});

  @override
  ConsumerState<SafetyScreen> createState() => _SafetyScreenState();
}

class _SafetyScreenState extends ConsumerState<SafetyScreen> {
  bool _sharingLive = false;

  Future<void> _callEmergencyServices() async {
    // 911 cubre México, EE. UU. y Canadá. Para otros países hay que mapear el
    // número al país del dispositivo antes de lanzar la llamada.
    final uri = Uri(scheme: 'tel', path: '911');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  /// Activa o desactiva el compartir ubicación en vivo.
  ///
  /// Mientras está activo se muestra una notificación persistente. No es
  /// decorativa: compartir la ubicación es un estado que consume batería y
  /// expone dónde estás, así que nunca debe poder quedarse encendido sin que
  /// se vea. Android además lo exige para servicios en primer plano.
  Future<void> _toggleLiveSharing(bool value) async {
    setState(() => _sharingLive = value);

    final l10n = L10n.of(context);
    if (value) {
      await TaylorNotifications.instance.requestPermission();
      await TaylorNotifications.instance.showSafetyAlert(
        title: l10n.safetyShareLiveOn,
        body: l10n.safetyShareLiveBody,
      );
    } else {
      await TaylorNotifications.instance.cancelSafetyAlert();
    }
  }

  Future<void> _notifyFriends() async {
    final l10n = L10n.of(context);
    final contacts =
        ref.read(sessionControllerProvider).user?.emergencyContacts ?? [];

    if (contacts.isEmpty) {
      _openContacts();
      return;
    }

    // La ubicación real se inyecta aquí desde `geolocator`.
    await Share.share(
      '${l10n.safetyShareLiveOn}: https://taylor.app/live/demo',
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.safetyNotified)),
    );
  }

  void _openContacts() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const EmergencyContactsSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final theme = Theme.of(context);
    final contacts =
        ref.watch(sessionControllerProvider).user?.emergencyContacts ?? [];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            TaylorSpacing.md,
            TaylorSpacing.md,
            TaylorSpacing.md,
            TaylorSpacing.navBarClearance,
          ),
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.safetyTitle,
                    style: theme.textTheme.displayMedium,
                  ),
                  Text(
                    l10n.safetySubtitle,
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: TaylorSpacing.lg),

            SosButton(
              label: l10n.safetySos,
              hint: l10n.safetySosHold,
              callingLabel: l10n.safetySosCalling,
              onTriggered: _callEmergencyServices,
            ),

            const SizedBox(height: TaylorSpacing.lg),

            _SafetyTile(
              icon: Icons.groups_rounded,
              title: l10n.safetyFriends,
              body: l10n.safetyFriendsBody,
              actionLabel: l10n.safetyNotifyFriends,
              onAction: _notifyFriends,
            ),
            const SizedBox(height: TaylorSpacing.sm),

            _SafetyTile(
              icon: Icons.share_location_rounded,
              title: _sharingLive
                  ? l10n.safetyShareLiveOn
                  : l10n.safetyShareLive,
              body: l10n.safetyShareLiveBody,
              active: _sharingLive,
              trailing: Switch(
                value: _sharingLive,
                onChanged: _toggleLiveSharing,
              ),
            ),
            const SizedBox(height: TaylorSpacing.sm),

            _SafetyTile(
              icon: Icons.local_police_rounded,
              title: l10n.safetyCallPolice,
              body: '911',
              actionLabel: l10n.safetyCallPolice,
              onAction: _callEmergencyServices,
            ),

            const SizedBox(height: TaylorSpacing.lg),

            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.safetyContacts,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                TextButton.icon(
                  onPressed: _openContacts,
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: Text(l10n.safetyAddContact),
                ),
              ],
            ),
            const SizedBox(height: 4),

            // Una cuenta puede llegar aquí sin contactos: el paso del
            // onboarding permite saltarse. El vacío no se presenta como un
            // estado neutro sino como algo pendiente, porque sin contactos
            // "Avisar a mis amigas" no hace nada.
            if (contacts.isEmpty)
              Container(
                padding: const EdgeInsets.all(TaylorSpacing.md),
                decoration: BoxDecoration(
                  color: TaylorColors.caution.withValues(alpha: 0.09),
                  borderRadius: BorderRadius.circular(TaylorRadius.lg),
                  border: Border.all(
                    color: TaylorColors.caution.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      size: 20,
                      color: TaylorColors.caution,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.safetyNoContacts,
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            l10n.safetyNoContactsOnboarding,
                            style: theme.textTheme.bodySmall,
                          ),
                          const SizedBox(height: TaylorSpacing.sm),
                          FilledButton(
                            onPressed: _openContacts,
                            child: Text(l10n.safetyAddContact),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            else
              for (final contact in contacts)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            TaylorColors.raspberry.withValues(alpha: 0.14),
                        child: Text(
                          contact.name[0],
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: TaylorColors.raspberry,
                          ),
                        ),
                      ),
                      title: Text(contact.name),
                      subtitle: Text(
                        contact.relationship == null
                            ? contact.phone
                            : '${contact.relationship} · ${contact.phone}',
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.call_rounded),
                        color: TaylorColors.raspberry,
                        onPressed: () => launchUrl(
                          Uri(scheme: 'tel', path: contact.phone),
                        ),
                      ),
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

class _SafetyTile extends StatelessWidget {
  const _SafetyTile({
    required this.icon,
    required this.title,
    required this.body,
    this.actionLabel,
    this.onAction,
    this.trailing,
    this.active = false,
  });

  final IconData icon;
  final String title;
  final String body;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Widget? trailing;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedContainer(
      duration: TaylorMotion.normal,
      curve: TaylorMotion.standard,
      padding: const EdgeInsets.all(TaylorSpacing.md),
      decoration: BoxDecoration(
        color: active
            ? TaylorColors.verified.withValues(alpha: 0.07)
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(TaylorRadius.lg),
        border: Border.all(
          color: active ? TaylorColors.verified : theme.colorScheme.outline,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: TaylorColors.raspberry.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(TaylorRadius.sm),
            ),
            child: Icon(icon, color: TaylorColors.raspberry, size: 22),
          ),
          const SizedBox(width: TaylorSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleMedium),
                Text(body, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          if (trailing != null)
            trailing!
          else if (actionLabel != null)
            TextButton(onPressed: onAction, child: Text(actionLabel!)),
        ],
      ),
    );
  }
}
