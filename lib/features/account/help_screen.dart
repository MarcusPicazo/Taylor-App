import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/taylor_colors.dart';
import '../../core/theme/taylor_theme.dart';
import '../../data/demo_data.dart';
import '../../data/models/trip.dart';
import '../../l10n/app_localizations.dart';

/// Soporte.
///
/// Empieza preguntando por cuál viaje, no por el texto libre: casi todos los
/// tickets de una app de movilidad son sobre un trayecto concreto, y adjuntarlo
/// desde el principio le ahorra a soporte la mitad del intercambio.
class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  Trip? _selectedTrip;
  bool _generalSelected = false;
  final _message = TextEditingController();

  @override
  void dispose() {
    _message.dispose();
    super.dispose();
  }

  bool get _canSend =>
      (_selectedTrip != null || _generalSelected) &&
      _message.text.trim().isNotEmpty;

  Future<void> _sendEmail() async {
    final subject = _selectedTrip != null
        ? 'Taylor · Viaje ${_selectedTrip!.id}'
        : 'Taylor · Soporte';

    final uri = Uri(
      scheme: 'mailto',
      path: 'soporte@taylor.app',
      queryParameters: {
        'subject': subject,
        'body': _message.text,
      },
    );

    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  void _send() {
    final l10n = L10n.of(context);
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.helpSent)),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final trips = TaylorDemo.trips();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.helpTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(TaylorSpacing.lg),
          children: [
            Text(l10n.helpTripQuestion, style: theme.textTheme.titleMedium),
            const SizedBox(height: TaylorSpacing.sm),

            for (final trip in trips)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _SelectableRow(
                  selected: _selectedTrip?.id == trip.id,
                  title:
                      '${trip.origin.label} → ${trip.destination.label}',
                  subtitle: DateFormat.yMMMEd(locale)
                      .add_jm()
                      .format(trip.requestedAt),
                  onTap: () => setState(() {
                    _selectedTrip = trip;
                    _generalSelected = false;
                  }),
                ),
              ),

            _SelectableRow(
              selected: _generalSelected,
              title: l10n.helpGeneral,
              subtitle: l10n.helpContactSupport,
              onTap: () => setState(() {
                _generalSelected = true;
                _selectedTrip = null;
              }),
            ),

            const SizedBox(height: TaylorSpacing.lg),

            TextField(
              controller: _message,
              maxLines: 5,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: l10n.helpMessageLabel,
                alignLabelWithHint: true,
              ),
              onChanged: (_) => setState(() {}),
            ),

            const SizedBox(height: TaylorSpacing.md),

            FilledButton(
              onPressed: _canSend ? _send : null,
              child: Text(l10n.helpSend),
            ),
            const SizedBox(height: TaylorSpacing.sm),
            OutlinedButton.icon(
              onPressed: _sendEmail,
              icon: const Icon(Icons.mail_outline_rounded),
              label: Text(l10n.helpEmail),
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectableRow extends StatelessWidget {
  const _SelectableRow({
    required this.selected,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final bool selected;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
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
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_unchecked_rounded,
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
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelLarge,
                  ),
                  Text(subtitle, style: theme.textTheme.labelSmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
