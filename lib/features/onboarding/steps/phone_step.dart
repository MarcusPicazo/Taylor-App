import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/taylor_phone_field.dart';
import '../../../data/session_controller.dart';
import '../../../l10n/app_localizations.dart';
import 'step_scaffold.dart';

class PhoneStep extends ConsumerStatefulWidget {
  const PhoneStep({super.key, required this.onDone});

  final VoidCallback onDone;

  @override
  ConsumerState<PhoneStep> createState() => _PhoneStepState();
}

class _PhoneStepState extends ConsumerState<PhoneStep> {
  String _completeNumber = '';
  String _countryCode = 'MX';
  bool _codeSent = false;
  final _code = TextEditingController();

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);

    return StepScaffold(
      icon: Icons.smartphone_rounded,
      title: l10n.stepPhone,
      body: _codeSent ? l10n.codeSentTo(_completeNumber) : l10n.stepPhoneBody,
      actionLabel: _codeSent ? l10n.verifyCode : l10n.sendCode,
      actionEnabled:
          _codeSent ? _code.text.length == 6 : _completeNumber.length > 8,
      onAction: () {
        if (!_codeSent) {
          setState(() => _codeSent = true);
          return;
        }
        ref.read(sessionControllerProvider.notifier).updateProfile(
              phoneNumber: _completeNumber,
              countryCode: _countryCode,
            );
        widget.onDone();
      },
      child: _codeSent
          ? TextField(
              controller: _code,
              autofocus: true,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    letterSpacing: 12,
                  ),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(counterText: ''),
              onChanged: (_) => setState(() {}),
            )
          : TaylorPhoneField(
              label: l10n.phoneLabel,
              onChanged: (phone) => setState(() {
                _completeNumber = phone.completeNumber;
                _countryCode = phone.countryISOCode;
              }),
            ),
    );
  }
}
