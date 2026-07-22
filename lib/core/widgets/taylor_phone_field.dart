import 'package:flutter/material.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';

import '../theme/taylor_theme.dart';

/// Campo de teléfono con la bandera del país al que pertenece el número.
///
/// El país inicial se toma del locale del dispositivo, así que en un teléfono
/// configurado en México arranca en +52 sin que nadie tenga que buscarlo en la
/// lista. Cambiarlo actualiza la bandera al instante.
class TaylorPhoneField extends StatelessWidget {
  const TaylorPhoneField({
    super.key,
    required this.label,
    required this.onChanged,
    this.initialCountryCode,
  });

  final String label;
  final ValueChanged<PhoneNumber> onChanged;
  final String? initialCountryCode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final countryCode = initialCountryCode ??
        Localizations.localeOf(context).countryCode ??
        'MX';

    return IntlPhoneField(
      initialCountryCode: countryCode,
      onChanged: onChanged,
      showCountryFlag: true,
      dropdownIconPosition: IconPosition.trailing,
      flagsButtonPadding: const EdgeInsets.only(left: 12, right: 4),
      dropdownTextStyle: theme.textTheme.bodyLarge,
      style: theme.textTheme.bodyLarge,
      decoration: InputDecoration(
        labelText: label,
        counterText: '',
      ),
      // El selector de país hereda el radio de la app para que no se sienta
      // un componente de terceros incrustado.
      pickerDialogStyle: PickerDialogStyle(
        backgroundColor: theme.colorScheme.surface,
        searchFieldInputDecoration: InputDecoration(
          hintText: MaterialLocalizations.of(context).searchFieldLabel,
          prefixIcon: const Icon(Icons.search_rounded),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(TaylorRadius.md),
          ),
        ),
      ),
    );
  }
}
