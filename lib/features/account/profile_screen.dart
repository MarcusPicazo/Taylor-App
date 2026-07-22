import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/theme/taylor_colors.dart';
import '../../core/theme/taylor_theme.dart';
import '../../core/widgets/taylor_phone_field.dart';
import '../../core/widgets/user_avatar.dart';
import '../../data/session_controller.dart';
import '../../l10n/app_localizations.dart';

/// Edición del perfil de la pasajera.
///
/// La foto es libre. La identidad ya quedó atada al documento durante el
/// onboarding, así que aquí la imagen es expresión personal, no un control de
/// seguridad — y el aviso de "identidad verificada" lo deja explícito para que
/// nadie crea que subir otra foto debilita algo.
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  late final TextEditingController _name;
  String? _localPhotoPath;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(
      text: ref.read(sessionControllerProvider).user?.fullName ?? '',
    );
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      // Se limita el tamaño en origen: las fotos de galería moderna pesan
      // decenas de MB y solo se muestran en un avatar de 120 px.
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 88,
    );
    if (picked == null) return;
    setState(() => _localPhotoPath = picked.path);
  }

  void _save() {
    ref.read(sessionControllerProvider.notifier).updateProfile(
          fullName: _name.text.trim(),
          photoUrl: _localPhotoPath,
        );

    final l10n = L10n.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.profileSaved)),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final theme = Theme.of(context);
    final user = ref.watch(sessionControllerProvider).user;

    if (user == null) return const SizedBox.shrink();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.profileTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(TaylorSpacing.lg),
          children: [
            Center(
              child: Column(
                children: [
                  Stack(
                    children: [
                      UserAvatar(
                        radius: 60,
                        initials: user.initials,
                        photoPath: _localPhotoPath ?? user.photoUrl,
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Material(
                          color: TaylorColors.raspberry,
                          shape: const CircleBorder(),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: _pickPhoto,
                            child: const Padding(
                              padding: EdgeInsets.all(9),
                              child: Icon(
                                Icons.photo_camera_rounded,
                                size: 19,
                                color: TaylorColors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: TaylorSpacing.sm),
                  TextButton(
                    onPressed: _pickPhoto,
                    child: Text(l10n.profileChangePhoto),
                  ),
                  Text(
                    l10n.profilePhotoBody,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),

            const SizedBox(height: TaylorSpacing.lg),

            TextField(
              controller: _name,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: l10n.profileFullName,
                prefixIcon: const Icon(Icons.person_outline_rounded),
              ),
            ),
            const SizedBox(height: TaylorSpacing.sm),

            TaylorPhoneField(
              label: l10n.phoneLabel,
              initialCountryCode: user.countryCode,
              onChanged: (phone) => ref
                  .read(sessionControllerProvider.notifier)
                  .updateProfile(
                    phoneNumber: phone.completeNumber,
                    countryCode: phone.countryISOCode,
                  ),
            ),

            const SizedBox(height: TaylorSpacing.md),

            Container(
              padding: const EdgeInsets.all(TaylorSpacing.sm),
              decoration: BoxDecoration(
                color: TaylorColors.verified.withValues(alpha: 0.09),
                borderRadius: BorderRadius.circular(TaylorRadius.md),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.verified_user_rounded,
                    size: 20,
                    color: TaylorColors.verified,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      l10n.profileVerifiedId,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: TaylorColors.verified,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: TaylorSpacing.xl),
            FilledButton(onPressed: _save, child: Text(l10n.save)),
          ],
        ),
      ),
    );
  }
}
