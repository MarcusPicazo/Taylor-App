import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_mode.dart';
import '../../app/router.dart';
import '../../core/theme/taylor_colors.dart';
import '../../core/theme/taylor_theme.dart';
import '../../data/demo_data.dart';
import '../../data/session_controller.dart';
import '../../l10n/app_localizations.dart';
import '../business/business_controller.dart';

/// Entrada B2B: o ya tienes código, o solicitas acceso.
class BusinessScreen extends ConsumerStatefulWidget {
  const BusinessScreen({super.key});

  @override
  ConsumerState<BusinessScreen> createState() => _BusinessScreenState();
}

class _BusinessScreenState extends ConsumerState<BusinessScreen> {
  final _code = TextEditingController();

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final ok = await ref
        .read(sessionControllerProvider.notifier)
        .signInWithBusinessCode(_code.text);

    if (!ok) return;

    // Cargar la empresa y los traslados de la noche antes de que el router
    // navegue, para que el panel no aparezca vacío durante un frame.
    ref.read(businessAccountProvider.notifier).load(
          TaylorDemo.businessAccount(),
        );
    ref.read(tonightRidesProvider.notifier).load(TaylorDemo.tonightRides());
    ref.read(appModeProvider.notifier).state = AppMode.business;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final theme = Theme.of(context);
    final session = ref.watch(sessionControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.businessTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(TaylorSpacing.lg),
          children: [
            Container(
              padding: const EdgeInsets.all(TaylorSpacing.md),
              decoration: BoxDecoration(
                gradient: TaylorColors.brandGradient,
                borderRadius: BorderRadius.circular(TaylorRadius.lg),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.business_center_rounded,
                    color: TaylorColors.white,
                    size: 30,
                  ),
                  const SizedBox(height: TaylorSpacing.sm),
                  Text(
                    l10n.businessSubtitle,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: TaylorColors.white,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: TaylorSpacing.lg),

            Text(l10n.businessHaveCode, style: theme.textTheme.titleMedium),
            const SizedBox(height: TaylorSpacing.sm),

            TextField(
              controller: _code,
              textCapitalization: TextCapitalization.characters,
              autocorrect: false,
              // El código viene de un correo; espacios al copiar y pegar son
              // el error más común, así que se filtran al escribir.
              inputFormatters: [
                FilteringTextInputFormatter.deny(RegExp(r'\s')),
              ],
              decoration: InputDecoration(
                labelText: l10n.businessCodeLabel,
                helperText: l10n.businessCodeHelp,
                prefixIcon: const Icon(Icons.key_rounded),
              ),
            ),

            if (session.error == 'invalidBusinessCode') ...[
              const SizedBox(height: TaylorSpacing.sm),
              Row(
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    size: 18,
                    color: TaylorColors.emergency,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.invalidBusinessCode,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: TaylorColors.emergency,
                      ),
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: TaylorSpacing.md),

            FilledButton(
              onPressed: session.isLoading ? null : _submit,
              child: Text(l10n.signIn),
            ),

            const SizedBox(height: TaylorSpacing.lg),
            Row(
              children: [
                Expanded(child: Divider(color: theme.colorScheme.outline)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text('—', style: theme.textTheme.bodySmall),
                ),
                Expanded(child: Divider(color: theme.colorScheme.outline)),
              ],
            ),
            const SizedBox(height: TaylorSpacing.lg),

            OutlinedButton(
              onPressed: () => context.push(Routes.businessApplication),
              child: Text(l10n.businessRequestAccess),
            ),
          ],
        ),
      ),
    );
  }
}
