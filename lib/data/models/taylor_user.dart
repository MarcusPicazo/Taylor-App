/// En qué punto del embudo de verificación está la cuenta.
///
/// Taylor no permite pedir un viaje hasta llegar a [verified]: la seguridad es
/// una precondición del producto, no un ajuste opcional.
enum VerificationStage {
  /// Cuenta creada con Google/Apple, sin datos de identidad todavía.
  registered,

  /// Teléfono confirmado por SMS.
  phoneConfirmed,

  /// Documento oficial capturado y leído.
  documentCaptured,

  /// El rostro en vivo coincide con la foto del documento.
  biometricMatched,

  /// Verificación de antecedentes en curso (asíncrona).
  backgroundCheckPending,

  /// Red de confianza configurada (o rechazada explícitamente).
  ///
  /// Va al final del embudo a propósito. Para entonces la identidad ya está
  /// confirmada y la usuaria está invertida en el proceso, así que el paso se
  /// lee como "una última cosa, y es para ti" en lugar de como más trámite.
  safetyNetworkReady,

  /// Puede usar la app.
  verified,

  /// Rechazada por el equipo de confianza y seguridad.
  rejected,
}

extension VerificationStageX on VerificationStage {
  bool get canRequestRides => this == VerificationStage.verified;

  /// Progreso 0..1 para las barras de onboarding.
  double get progress => switch (this) {
        VerificationStage.registered => 0.12,
        VerificationStage.phoneConfirmed => 0.28,
        VerificationStage.documentCaptured => 0.45,
        VerificationStage.biometricMatched => 0.66,
        VerificationStage.backgroundCheckPending => 0.84,
        VerificationStage.safetyNetworkReady => 0.95,
        VerificationStage.verified => 1.0,
        VerificationStage.rejected => 1.0,
      };
}

/// Tipo de cuenta. Taylor prioriza B2B, así que las cuentas de empresa son un
/// ciudadano de primera clase y no un añadido.
enum AccountType { passenger, business, driver }

class EmergencyContact {
  const EmergencyContact({
    required this.id,
    required this.name,
    required this.phone,
    this.relationship,
  });

  final String id;
  final String name;
  final String phone;
  final String? relationship;

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'phone': phone,
        'relationship': relationship,
      };

  factory EmergencyContact.fromMap(Map<String, dynamic> map) {
    return EmergencyContact(
      id: map['id'] as String,
      name: map['name'] as String,
      phone: map['phone'] as String,
      relationship: map['relationship'] as String?,
    );
  }
}

class TaylorUser {
  const TaylorUser({
    required this.id,
    required this.fullName,
    required this.email,
    this.photoUrl,
    this.phoneNumber,
    this.countryCode = 'MX',
    this.accountType = AccountType.passenger,
    this.stage = VerificationStage.registered,
    this.emergencyContacts = const [],
    this.businessName,
    this.isDemoAccount = false,
  });

  final String id;
  final String fullName;
  final String email;

  /// Foto elegida por la pasajera. Puede ser distinta de la foto biométrica:
  /// la app ya validó su identidad contra el documento, así que en el perfil
  /// puede mostrar la imagen que ella prefiera.
  final String? photoUrl;

  final String? phoneNumber;
  final String countryCode;
  final AccountType accountType;
  final VerificationStage stage;
  final List<EmergencyContact> emergencyContacts;
  final String? businessName;

  /// Marca la cuenta de demostración para clientes. Nunca toca datos reales.
  final bool isDemoAccount;

  String get firstName => fullName.split(' ').first;

  String get initials {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return 'T';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts.first[0]}${parts[1][0]}'.toUpperCase();
  }

  TaylorUser copyWith({
    String? fullName,
    String? photoUrl,
    String? phoneNumber,
    String? countryCode,
    AccountType? accountType,
    VerificationStage? stage,
    List<EmergencyContact>? emergencyContacts,
    String? businessName,
  }) {
    return TaylorUser(
      id: id,
      fullName: fullName ?? this.fullName,
      email: email,
      photoUrl: photoUrl ?? this.photoUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      countryCode: countryCode ?? this.countryCode,
      accountType: accountType ?? this.accountType,
      stage: stage ?? this.stage,
      emergencyContacts: emergencyContacts ?? this.emergencyContacts,
      businessName: businessName ?? this.businessName,
      isDemoAccount: isDemoAccount,
    );
  }

  Map<String, dynamic> toMap() => {
        'fullName': fullName,
        'email': email,
        'photoUrl': photoUrl,
        'phoneNumber': phoneNumber,
        'countryCode': countryCode,
        'accountType': accountType.name,
        'stage': stage.name,
        'emergencyContacts':
            emergencyContacts.map((c) => c.toMap()).toList(growable: false),
        'businessName': businessName,
      };

  factory TaylorUser.fromMap(String id, Map<String, dynamic> map) {
    return TaylorUser(
      id: id,
      fullName: (map['fullName'] as String?) ?? '',
      email: (map['email'] as String?) ?? '',
      photoUrl: map['photoUrl'] as String?,
      phoneNumber: map['phoneNumber'] as String?,
      countryCode: (map['countryCode'] as String?) ?? 'MX',
      accountType: AccountType.values.firstWhere(
        (t) => t.name == map['accountType'],
        orElse: () => AccountType.passenger,
      ),
      stage: VerificationStage.values.firstWhere(
        (s) => s.name == map['stage'],
        orElse: () => VerificationStage.registered,
      ),
      emergencyContacts: ((map['emergencyContacts'] as List<dynamic>?) ?? [])
          .map((e) => EmergencyContact.fromMap(
              Map<String, dynamic>.from(e as Map)))
          .toList(growable: false),
      businessName: map['businessName'] as String?,
    );
  }
}
