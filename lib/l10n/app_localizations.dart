import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of L10n
/// returned by `L10n.of(context)`.
///
/// Applications need to include `L10n.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: L10n.localizationsDelegates,
///   supportedLocales: L10n.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the L10n.supportedLocales
/// property.
abstract class L10n {
  L10n(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static L10n of(BuildContext context) {
    return Localizations.of<L10n>(context, L10n)!;
  }

  static const LocalizationsDelegate<L10n> delegate = _L10nDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es')
  ];

  /// No description provided for @appTagline.
  ///
  /// In es, this message translates to:
  /// **'Tu viaje, en tus términos.'**
  String get appTagline;

  /// No description provided for @continueLabel.
  ///
  /// In es, this message translates to:
  /// **'Continuar'**
  String get continueLabel;

  /// No description provided for @cancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get save;

  /// No description provided for @close.
  ///
  /// In es, this message translates to:
  /// **'Cerrar'**
  String get close;

  /// No description provided for @back.
  ///
  /// In es, this message translates to:
  /// **'Atrás'**
  String get back;

  /// No description provided for @next.
  ///
  /// In es, this message translates to:
  /// **'Siguiente'**
  String get next;

  /// No description provided for @done.
  ///
  /// In es, this message translates to:
  /// **'Listo'**
  String get done;

  /// No description provided for @retry.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get retry;

  /// No description provided for @navHome.
  ///
  /// In es, this message translates to:
  /// **'Inicio'**
  String get navHome;

  /// No description provided for @navTrips.
  ///
  /// In es, this message translates to:
  /// **'Viajes'**
  String get navTrips;

  /// No description provided for @navSafety.
  ///
  /// In es, this message translates to:
  /// **'Seguridad'**
  String get navSafety;

  /// No description provided for @navAccount.
  ///
  /// In es, this message translates to:
  /// **'Cuenta'**
  String get navAccount;

  /// No description provided for @loginTitle.
  ///
  /// In es, this message translates to:
  /// **'Bienvenida a Taylor'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In es, this message translates to:
  /// **'La primera plataforma de movilidad hecha por mujeres, para mujeres.'**
  String get loginSubtitle;

  /// No description provided for @loginWithGoogle.
  ///
  /// In es, this message translates to:
  /// **'Continuar con Google'**
  String get loginWithGoogle;

  /// No description provided for @loginWithApple.
  ///
  /// In es, this message translates to:
  /// **'Continuar con Apple'**
  String get loginWithApple;

  /// No description provided for @loginBusiness.
  ///
  /// In es, this message translates to:
  /// **'Business'**
  String get loginBusiness;

  /// No description provided for @loginBusinessHint.
  ///
  /// In es, this message translates to:
  /// **'¿Tu empresa usa Taylor?'**
  String get loginBusinessHint;

  /// No description provided for @loginDemoAccess.
  ///
  /// In es, this message translates to:
  /// **'Acceso de demostración'**
  String get loginDemoAccess;

  /// No description provided for @loginPassengersOnly.
  ///
  /// In es, this message translates to:
  /// **'El acceso es exclusivo para pasajeras. Cada cuenta pasa por verificación de identidad.'**
  String get loginPassengersOnly;

  /// No description provided for @loginTerms.
  ///
  /// In es, this message translates to:
  /// **'Al continuar aceptas nuestros Términos y el Aviso de Privacidad.'**
  String get loginTerms;

  /// No description provided for @demoTitle.
  ///
  /// In es, this message translates to:
  /// **'Cuenta de demostración'**
  String get demoTitle;

  /// No description provided for @demoSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Ingresa con la cuenta de exhibición para recorrer la app.'**
  String get demoSubtitle;

  /// No description provided for @emailLabel.
  ///
  /// In es, this message translates to:
  /// **'Correo electrónico'**
  String get emailLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In es, this message translates to:
  /// **'Contraseña'**
  String get passwordLabel;

  /// No description provided for @signIn.
  ///
  /// In es, this message translates to:
  /// **'Iniciar sesión'**
  String get signIn;

  /// No description provided for @invalidCredentials.
  ///
  /// In es, this message translates to:
  /// **'Correo o contraseña incorrectos.'**
  String get invalidCredentials;

  /// No description provided for @businessTitle.
  ///
  /// In es, this message translates to:
  /// **'Taylor para empresas'**
  String get businessTitle;

  /// No description provided for @businessSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Traslados seguros y programados para tu equipo.'**
  String get businessSubtitle;

  /// No description provided for @businessHaveCode.
  ///
  /// In es, this message translates to:
  /// **'Ya tengo un código'**
  String get businessHaveCode;

  /// No description provided for @businessRequestAccess.
  ///
  /// In es, this message translates to:
  /// **'Solicitar acceso'**
  String get businessRequestAccess;

  /// No description provided for @businessCodeLabel.
  ///
  /// In es, this message translates to:
  /// **'Código de empresa'**
  String get businessCodeLabel;

  /// No description provided for @businessCodeHelp.
  ///
  /// In es, this message translates to:
  /// **'Es el código que te envió el equipo de Taylor.'**
  String get businessCodeHelp;

  /// No description provided for @invalidBusinessCode.
  ///
  /// In es, this message translates to:
  /// **'Ese código no es válido o expiró.'**
  String get invalidBusinessCode;

  /// No description provided for @businessFormCompany.
  ///
  /// In es, this message translates to:
  /// **'Nombre de la empresa'**
  String get businessFormCompany;

  /// No description provided for @businessFormContact.
  ///
  /// In es, this message translates to:
  /// **'Persona de contacto'**
  String get businessFormContact;

  /// No description provided for @businessFormRole.
  ///
  /// In es, this message translates to:
  /// **'Puesto'**
  String get businessFormRole;

  /// No description provided for @businessFormEmail.
  ///
  /// In es, this message translates to:
  /// **'Correo corporativo'**
  String get businessFormEmail;

  /// No description provided for @businessFormEmployees.
  ///
  /// In es, this message translates to:
  /// **'Empleadas a transportar'**
  String get businessFormEmployees;

  /// No description provided for @businessFormCity.
  ///
  /// In es, this message translates to:
  /// **'Ciudad de operación'**
  String get businessFormCity;

  /// No description provided for @businessFormSubmit.
  ///
  /// In es, this message translates to:
  /// **'Enviar solicitud'**
  String get businessFormSubmit;

  /// No description provided for @businessSubmittedTitle.
  ///
  /// In es, this message translates to:
  /// **'Solicitud enviada'**
  String get businessSubmittedTitle;

  /// No description provided for @businessSubmittedBody.
  ///
  /// In es, this message translates to:
  /// **'El equipo de Taylor revisará tu solicitud y te dará una respuesta en un plazo de 3 a 5 días hábiles. Si se aprueba, recibirás un código de acceso por correo.'**
  String get businessSubmittedBody;

  /// No description provided for @scheduleTitle.
  ///
  /// In es, this message translates to:
  /// **'Viajes programados'**
  String get scheduleTitle;

  /// No description provided for @scheduleSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Agenda los traslados de tu equipo por semana.'**
  String get scheduleSubtitle;

  /// No description provided for @scheduleDays.
  ///
  /// In es, this message translates to:
  /// **'Días de la semana'**
  String get scheduleDays;

  /// No description provided for @schedulePickup.
  ///
  /// In es, this message translates to:
  /// **'Hora de salida'**
  String get schedulePickup;

  /// No description provided for @scheduleEmployees.
  ///
  /// In es, this message translates to:
  /// **'Número de empleadas'**
  String get scheduleEmployees;

  /// No description provided for @scheduleSave.
  ///
  /// In es, this message translates to:
  /// **'Guardar programación'**
  String get scheduleSave;

  /// No description provided for @scheduleSaved.
  ///
  /// In es, this message translates to:
  /// **'Programación guardada'**
  String get scheduleSaved;

  /// No description provided for @onboardingTitle.
  ///
  /// In es, this message translates to:
  /// **'Verificación de seguridad'**
  String get onboardingTitle;

  /// No description provided for @onboardingSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Nos toma un par de minutos. Es lo que hace que Taylor sea Taylor.'**
  String get onboardingSubtitle;

  /// No description provided for @onboardingWhy.
  ///
  /// In es, this message translates to:
  /// **'¿Por qué pedimos esto?'**
  String get onboardingWhy;

  /// No description provided for @onboardingWhyBody.
  ///
  /// In es, this message translates to:
  /// **'Cada persona dentro de Taylor está verificada. Validamos identidad con documento oficial, comparamos tu rostro en vivo con ese documento y revisamos antecedentes. Nadie viaja con alguien sin verificar.'**
  String get onboardingWhyBody;

  /// No description provided for @stepPhone.
  ///
  /// In es, this message translates to:
  /// **'Confirma tu teléfono'**
  String get stepPhone;

  /// No description provided for @stepPhoneBody.
  ///
  /// In es, this message translates to:
  /// **'Te enviaremos un código de 6 dígitos.'**
  String get stepPhoneBody;

  /// No description provided for @phoneLabel.
  ///
  /// In es, this message translates to:
  /// **'Número telefónico'**
  String get phoneLabel;

  /// No description provided for @sendCode.
  ///
  /// In es, this message translates to:
  /// **'Enviar código'**
  String get sendCode;

  /// No description provided for @codeSentTo.
  ///
  /// In es, this message translates to:
  /// **'Código enviado a {phone}'**
  String codeSentTo(String phone);

  /// No description provided for @verifyCode.
  ///
  /// In es, this message translates to:
  /// **'Verificar'**
  String get verifyCode;

  /// No description provided for @stepDocument.
  ///
  /// In es, this message translates to:
  /// **'Escanea tu identificación'**
  String get stepDocument;

  /// No description provided for @stepDocumentBody.
  ///
  /// In es, this message translates to:
  /// **'Coloca tu INE o pasaporte dentro del marco. Leemos los datos automáticamente.'**
  String get stepDocumentBody;

  /// No description provided for @documentFront.
  ///
  /// In es, this message translates to:
  /// **'Frente del documento'**
  String get documentFront;

  /// No description provided for @documentBack.
  ///
  /// In es, this message translates to:
  /// **'Reverso del documento'**
  String get documentBack;

  /// No description provided for @documentCapture.
  ///
  /// In es, this message translates to:
  /// **'Capturar'**
  String get documentCapture;

  /// No description provided for @documentReading.
  ///
  /// In es, this message translates to:
  /// **'Leyendo documento…'**
  String get documentReading;

  /// No description provided for @documentOk.
  ///
  /// In es, this message translates to:
  /// **'Documento válido'**
  String get documentOk;

  /// No description provided for @stepFace.
  ///
  /// In es, this message translates to:
  /// **'Reconocimiento facial'**
  String get stepFace;

  /// No description provided for @stepFaceBody.
  ///
  /// In es, this message translates to:
  /// **'Mira a la cámara y gira la cabeza lentamente. Comprobamos que eres tú y que estás en vivo.'**
  String get stepFaceBody;

  /// No description provided for @faceCentering.
  ///
  /// In es, this message translates to:
  /// **'Centra tu rostro'**
  String get faceCentering;

  /// No description provided for @faceTurn.
  ///
  /// In es, this message translates to:
  /// **'Gira despacio a la derecha'**
  String get faceTurn;

  /// No description provided for @faceHold.
  ///
  /// In es, this message translates to:
  /// **'No te muevas…'**
  String get faceHold;

  /// No description provided for @faceMatching.
  ///
  /// In es, this message translates to:
  /// **'Comparando con tu documento…'**
  String get faceMatching;

  /// No description provided for @faceMatched.
  ///
  /// In es, this message translates to:
  /// **'Identidad confirmada'**
  String get faceMatched;

  /// No description provided for @stepBackground.
  ///
  /// In es, this message translates to:
  /// **'Revisión de antecedentes'**
  String get stepBackground;

  /// No description provided for @stepBackgroundBody.
  ///
  /// In es, this message translates to:
  /// **'Consultamos bases de datos públicas y listas de seguridad. Es automático.'**
  String get stepBackgroundBody;

  /// No description provided for @backgroundRunning.
  ///
  /// In es, this message translates to:
  /// **'Verificando…'**
  String get backgroundRunning;

  /// No description provided for @backgroundClear.
  ///
  /// In es, this message translates to:
  /// **'Sin coincidencias'**
  String get backgroundClear;

  /// No description provided for @verifiedTitle.
  ///
  /// In es, this message translates to:
  /// **'Todo listo, {name}'**
  String verifiedTitle(String name);

  /// No description provided for @verifiedBody.
  ///
  /// In es, this message translates to:
  /// **'Tu identidad quedó confirmada. Ya puedes viajar con Taylor.'**
  String get verifiedBody;

  /// No description provided for @startRiding.
  ///
  /// In es, this message translates to:
  /// **'Empezar a viajar'**
  String get startRiding;

  /// No description provided for @homeGreeting.
  ///
  /// In es, this message translates to:
  /// **'Hola, {name}'**
  String homeGreeting(String name);

  /// No description provided for @homeWhereTo.
  ///
  /// In es, this message translates to:
  /// **'¿A dónde vamos?'**
  String get homeWhereTo;

  /// No description provided for @homeOrigin.
  ///
  /// In es, this message translates to:
  /// **'Origen'**
  String get homeOrigin;

  /// No description provided for @homeDestination.
  ///
  /// In es, this message translates to:
  /// **'Destino'**
  String get homeDestination;

  /// No description provided for @homeSavedHome.
  ///
  /// In es, this message translates to:
  /// **'Casa'**
  String get homeSavedHome;

  /// No description provided for @homeSavedWork.
  ///
  /// In es, this message translates to:
  /// **'Oficina'**
  String get homeSavedWork;

  /// No description provided for @homeRequestRide.
  ///
  /// In es, this message translates to:
  /// **'Pedir Taylor'**
  String get homeRequestRide;

  /// No description provided for @homeConfirmPickup.
  ///
  /// In es, this message translates to:
  /// **'Confirmar punto de encuentro'**
  String get homeConfirmPickup;

  /// No description provided for @searchingTitle.
  ///
  /// In es, this message translates to:
  /// **'Buscando conductora'**
  String get searchingTitle;

  /// No description provided for @searchingBody.
  ///
  /// In es, this message translates to:
  /// **'Estamos conectándote con una conductora verificada cerca de ti.'**
  String get searchingBody;

  /// No description provided for @searchingCancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar búsqueda'**
  String get searchingCancel;

  /// No description provided for @driverFound.
  ///
  /// In es, this message translates to:
  /// **'Conductora asignada'**
  String get driverFound;

  /// No description provided for @driverArrivingIn.
  ///
  /// In es, this message translates to:
  /// **'Llega en {minutes} min'**
  String driverArrivingIn(int minutes);

  /// No description provided for @driverTrips.
  ///
  /// In es, this message translates to:
  /// **'{count} viajes'**
  String driverTrips(int count);

  /// No description provided for @driverYears.
  ///
  /// In es, this message translates to:
  /// **'{years} años en Taylor'**
  String driverYears(int years);

  /// No description provided for @driverVerified.
  ///
  /// In es, this message translates to:
  /// **'Verificada por Taylor'**
  String get driverVerified;

  /// No description provided for @shareTrip.
  ///
  /// In es, this message translates to:
  /// **'Compartir viaje'**
  String get shareTrip;

  /// No description provided for @callDriver.
  ///
  /// In es, this message translates to:
  /// **'Llamar'**
  String get callDriver;

  /// No description provided for @messageDriver.
  ///
  /// In es, this message translates to:
  /// **'Mensaje'**
  String get messageDriver;

  /// No description provided for @cancelTrip.
  ///
  /// In es, this message translates to:
  /// **'Cancelar viaje'**
  String get cancelTrip;

  /// No description provided for @tripsTitle.
  ///
  /// In es, this message translates to:
  /// **'Tus viajes'**
  String get tripsTitle;

  /// No description provided for @tripsEmpty.
  ///
  /// In es, this message translates to:
  /// **'Todavía no tienes viajes'**
  String get tripsEmpty;

  /// No description provided for @tripsEmptyBody.
  ///
  /// In es, this message translates to:
  /// **'Cuando viajes con Taylor, tu historial aparecerá aquí.'**
  String get tripsEmptyBody;

  /// No description provided for @tripsUpcoming.
  ///
  /// In es, this message translates to:
  /// **'Programados'**
  String get tripsUpcoming;

  /// No description provided for @tripsPast.
  ///
  /// In es, this message translates to:
  /// **'Anteriores'**
  String get tripsPast;

  /// No description provided for @tripReceipt.
  ///
  /// In es, this message translates to:
  /// **'Ver recibo'**
  String get tripReceipt;

  /// No description provided for @tripHelp.
  ///
  /// In es, this message translates to:
  /// **'Necesito ayuda con este viaje'**
  String get tripHelp;

  /// No description provided for @safetyTitle.
  ///
  /// In es, this message translates to:
  /// **'Seguridad'**
  String get safetyTitle;

  /// No description provided for @safetySubtitle.
  ///
  /// In es, this message translates to:
  /// **'Todo lo que necesitas, en un solo lugar.'**
  String get safetySubtitle;

  /// No description provided for @safetySos.
  ///
  /// In es, this message translates to:
  /// **'SOS'**
  String get safetySos;

  /// No description provided for @safetySosHold.
  ///
  /// In es, this message translates to:
  /// **'Mantén presionado para llamar a emergencias'**
  String get safetySosHold;

  /// No description provided for @safetySosCalling.
  ///
  /// In es, this message translates to:
  /// **'Llamando a emergencias…'**
  String get safetySosCalling;

  /// No description provided for @safetyCallPolice.
  ///
  /// In es, this message translates to:
  /// **'Llamar a la policía'**
  String get safetyCallPolice;

  /// No description provided for @safetyShareLive.
  ///
  /// In es, this message translates to:
  /// **'Compartir mi ubicación en vivo'**
  String get safetyShareLive;

  /// No description provided for @safetyShareLiveOn.
  ///
  /// In es, this message translates to:
  /// **'Compartiendo ubicación en vivo'**
  String get safetyShareLiveOn;

  /// No description provided for @safetyShareLiveBody.
  ///
  /// In es, this message translates to:
  /// **'Tus contactos de confianza pueden ver dónde estás en tiempo real.'**
  String get safetyShareLiveBody;

  /// No description provided for @safetyFriends.
  ///
  /// In es, this message translates to:
  /// **'Amigas'**
  String get safetyFriends;

  /// No description provided for @safetyFriendsBody.
  ///
  /// In es, this message translates to:
  /// **'Avisa a tus contactos de confianza dónde estás.'**
  String get safetyFriendsBody;

  /// No description provided for @safetyNotifyFriends.
  ///
  /// In es, this message translates to:
  /// **'Avisar a mis amigas'**
  String get safetyNotifyFriends;

  /// No description provided for @safetyNotified.
  ///
  /// In es, this message translates to:
  /// **'Tus amigas fueron notificadas'**
  String get safetyNotified;

  /// No description provided for @safetyContacts.
  ///
  /// In es, this message translates to:
  /// **'Contactos de emergencia'**
  String get safetyContacts;

  /// No description provided for @safetyAddContact.
  ///
  /// In es, this message translates to:
  /// **'Agregar contacto'**
  String get safetyAddContact;

  /// No description provided for @safetyNoContacts.
  ///
  /// In es, this message translates to:
  /// **'Aún no agregas contactos de confianza'**
  String get safetyNoContacts;

  /// No description provided for @safetyContactName.
  ///
  /// In es, this message translates to:
  /// **'Nombre'**
  String get safetyContactName;

  /// No description provided for @safetyContactPhone.
  ///
  /// In es, this message translates to:
  /// **'Teléfono'**
  String get safetyContactPhone;

  /// No description provided for @safetyContactRelation.
  ///
  /// In es, this message translates to:
  /// **'Parentesco o relación'**
  String get safetyContactRelation;

  /// No description provided for @accountTitle.
  ///
  /// In es, this message translates to:
  /// **'Cuenta'**
  String get accountTitle;

  /// No description provided for @accountProfile.
  ///
  /// In es, this message translates to:
  /// **'Perfil'**
  String get accountProfile;

  /// No description provided for @accountProfileBody.
  ///
  /// In es, this message translates to:
  /// **'Nombre, foto y datos personales'**
  String get accountProfileBody;

  /// No description provided for @accountWallet.
  ///
  /// In es, this message translates to:
  /// **'Wallet'**
  String get accountWallet;

  /// No description provided for @accountWalletBody.
  ///
  /// In es, this message translates to:
  /// **'Métodos de pago y recibos'**
  String get accountWalletBody;

  /// No description provided for @accountHelp.
  ///
  /// In es, this message translates to:
  /// **'Ayuda'**
  String get accountHelp;

  /// No description provided for @accountHelpBody.
  ///
  /// In es, this message translates to:
  /// **'Soporte y ayuda con tus viajes'**
  String get accountHelpBody;

  /// No description provided for @accountSettings.
  ///
  /// In es, this message translates to:
  /// **'Configuración'**
  String get accountSettings;

  /// No description provided for @accountSettingsBody.
  ///
  /// In es, this message translates to:
  /// **'Idioma, notificaciones y privacidad'**
  String get accountSettingsBody;

  /// No description provided for @accountBecomeDriver.
  ///
  /// In es, this message translates to:
  /// **'Conviértete en conductora'**
  String get accountBecomeDriver;

  /// No description provided for @accountBecomeDriverBody.
  ///
  /// In es, this message translates to:
  /// **'Maneja con Taylor y genera ingresos'**
  String get accountBecomeDriverBody;

  /// No description provided for @accountSignOut.
  ///
  /// In es, this message translates to:
  /// **'Cerrar sesión'**
  String get accountSignOut;

  /// No description provided for @profileTitle.
  ///
  /// In es, this message translates to:
  /// **'Perfil'**
  String get profileTitle;

  /// No description provided for @profilePhoto.
  ///
  /// In es, this message translates to:
  /// **'Foto de perfil'**
  String get profilePhoto;

  /// No description provided for @profilePhotoBody.
  ///
  /// In es, this message translates to:
  /// **'Elige la foto que quieras. Tu identidad ya está verificada con tu documento.'**
  String get profilePhotoBody;

  /// No description provided for @profileChangePhoto.
  ///
  /// In es, this message translates to:
  /// **'Cambiar foto'**
  String get profileChangePhoto;

  /// No description provided for @profileFullName.
  ///
  /// In es, this message translates to:
  /// **'Nombre completo'**
  String get profileFullName;

  /// No description provided for @profileVerifiedId.
  ///
  /// In es, this message translates to:
  /// **'Identidad verificada'**
  String get profileVerifiedId;

  /// No description provided for @profileSaved.
  ///
  /// In es, this message translates to:
  /// **'Perfil actualizado'**
  String get profileSaved;

  /// No description provided for @walletTitle.
  ///
  /// In es, this message translates to:
  /// **'Wallet'**
  String get walletTitle;

  /// No description provided for @walletMethods.
  ///
  /// In es, this message translates to:
  /// **'Métodos de pago'**
  String get walletMethods;

  /// No description provided for @walletAddCard.
  ///
  /// In es, this message translates to:
  /// **'Agregar tarjeta'**
  String get walletAddCard;

  /// No description provided for @walletDefault.
  ///
  /// In es, this message translates to:
  /// **'Predeterminado'**
  String get walletDefault;

  /// No description provided for @walletSetDefault.
  ///
  /// In es, this message translates to:
  /// **'Usar por defecto'**
  String get walletSetDefault;

  /// No description provided for @walletRemove.
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get walletRemove;

  /// No description provided for @walletCash.
  ///
  /// In es, this message translates to:
  /// **'Efectivo'**
  String get walletCash;

  /// No description provided for @helpTitle.
  ///
  /// In es, this message translates to:
  /// **'Ayuda'**
  String get helpTitle;

  /// No description provided for @helpTripQuestion.
  ///
  /// In es, this message translates to:
  /// **'¿Con qué viaje necesitas ayuda?'**
  String get helpTripQuestion;

  /// No description provided for @helpGeneral.
  ///
  /// In es, this message translates to:
  /// **'No es sobre un viaje'**
  String get helpGeneral;

  /// No description provided for @helpContactSupport.
  ///
  /// In es, this message translates to:
  /// **'Contactar a soporte'**
  String get helpContactSupport;

  /// No description provided for @helpEmail.
  ///
  /// In es, this message translates to:
  /// **'Escribir un correo'**
  String get helpEmail;

  /// No description provided for @helpChat.
  ///
  /// In es, this message translates to:
  /// **'Enviar un mensaje'**
  String get helpChat;

  /// No description provided for @helpMessageLabel.
  ///
  /// In es, this message translates to:
  /// **'Cuéntanos qué pasó'**
  String get helpMessageLabel;

  /// No description provided for @helpSend.
  ///
  /// In es, this message translates to:
  /// **'Enviar'**
  String get helpSend;

  /// No description provided for @helpSent.
  ///
  /// In es, this message translates to:
  /// **'Mensaje enviado. Te responderemos pronto.'**
  String get helpSent;

  /// No description provided for @settingsTitle.
  ///
  /// In es, this message translates to:
  /// **'Configuración'**
  String get settingsTitle;

  /// No description provided for @settingsLanguage.
  ///
  /// In es, this message translates to:
  /// **'Idioma'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageSystem.
  ///
  /// In es, this message translates to:
  /// **'Idioma del dispositivo'**
  String get settingsLanguageSystem;

  /// No description provided for @settingsNotifications.
  ///
  /// In es, this message translates to:
  /// **'Notificaciones'**
  String get settingsNotifications;

  /// No description provided for @settingsPrivacy.
  ///
  /// In es, this message translates to:
  /// **'Privacidad'**
  String get settingsPrivacy;

  /// No description provided for @driverApplyTitle.
  ///
  /// In es, this message translates to:
  /// **'Conduce con Taylor'**
  String get driverApplyTitle;

  /// No description provided for @driverApplySubtitle.
  ///
  /// In es, this message translates to:
  /// **'Únete a la red de conductoras verificadas.'**
  String get driverApplySubtitle;

  /// No description provided for @driverApplyIntro.
  ///
  /// In es, this message translates to:
  /// **'Ser conductora de Taylor implica una verificación más estricta que la de pasajera. Es lo que nos permite prometer seguridad de verdad.'**
  String get driverApplyIntro;

  /// No description provided for @driverReqIdentity.
  ///
  /// In es, this message translates to:
  /// **'Identidad oficial y CURP'**
  String get driverReqIdentity;

  /// No description provided for @driverReqLicense.
  ///
  /// In es, this message translates to:
  /// **'Licencia de conducir vigente'**
  String get driverReqLicense;

  /// No description provided for @driverReqRecord.
  ///
  /// In es, this message translates to:
  /// **'Carta de antecedentes no penales'**
  String get driverReqRecord;

  /// No description provided for @driverReqVehicle.
  ///
  /// In es, this message translates to:
  /// **'Tarjeta de circulación y seguro'**
  String get driverReqVehicle;

  /// No description provided for @driverReqPhoto.
  ///
  /// In es, this message translates to:
  /// **'Fotografía profesional de frente'**
  String get driverReqPhoto;

  /// No description provided for @driverReqBiometric.
  ///
  /// In es, this message translates to:
  /// **'Validación biométrica con IA'**
  String get driverReqBiometric;

  /// No description provided for @driverPhotoNote.
  ///
  /// In es, this message translates to:
  /// **'A diferencia de las pasajeras, tu foto de perfil debe ser una fotografía profesional de frente, sin filtros ni accesorios que cubran el rostro.'**
  String get driverPhotoNote;

  /// No description provided for @driverApplySubmit.
  ///
  /// In es, this message translates to:
  /// **'Enviar solicitud'**
  String get driverApplySubmit;

  /// No description provided for @driverSubmittedTitle.
  ///
  /// In es, this message translates to:
  /// **'Solicitud recibida'**
  String get driverSubmittedTitle;

  /// No description provided for @driverSubmittedBody.
  ///
  /// In es, this message translates to:
  /// **'Vamos a revisar tus documentos y validar tus antecedentes. Te daremos una respuesta en un plazo de 3 a 5 días hábiles.'**
  String get driverSubmittedBody;

  /// No description provided for @safetyBadgeVerified.
  ///
  /// In es, this message translates to:
  /// **'Verificada'**
  String get safetyBadgeVerified;

  /// No description provided for @requiredField.
  ///
  /// In es, this message translates to:
  /// **'Este campo es obligatorio'**
  String get requiredField;

  /// No description provided for @invalidEmail.
  ///
  /// In es, this message translates to:
  /// **'Ingresa un correo válido'**
  String get invalidEmail;

  /// No description provided for @driveNavDrive.
  ///
  /// In es, this message translates to:
  /// **'Conducir'**
  String get driveNavDrive;

  /// No description provided for @driveNavEarnings.
  ///
  /// In es, this message translates to:
  /// **'Ganancias'**
  String get driveNavEarnings;

  /// No description provided for @driveOnline.
  ///
  /// In es, this message translates to:
  /// **'En línea'**
  String get driveOnline;

  /// No description provided for @driveOnlineBody.
  ///
  /// In es, this message translates to:
  /// **'Puedes recibir solicitudes'**
  String get driveOnlineBody;

  /// No description provided for @driveOffline.
  ///
  /// In es, this message translates to:
  /// **'Desconectada'**
  String get driveOffline;

  /// No description provided for @driveOfflineBody.
  ///
  /// In es, this message translates to:
  /// **'No recibirás solicitudes'**
  String get driveOfflineBody;

  /// No description provided for @driveNewRequest.
  ///
  /// In es, this message translates to:
  /// **'Nueva solicitud'**
  String get driveNewRequest;

  /// No description provided for @driveAccept.
  ///
  /// In es, this message translates to:
  /// **'Aceptar'**
  String get driveAccept;

  /// No description provided for @driveDecline.
  ///
  /// In es, this message translates to:
  /// **'Rechazar'**
  String get driveDecline;

  /// No description provided for @driveMinutesAway.
  ///
  /// In es, this message translates to:
  /// **'A {minutes} min de distancia'**
  String driveMinutesAway(int minutes);

  /// No description provided for @driveTripLength.
  ///
  /// In es, this message translates to:
  /// **'{km} km · {minutes} min de viaje'**
  String driveTripLength(String km, int minutes);

  /// No description provided for @driveHeadingToPickup.
  ///
  /// In es, this message translates to:
  /// **'Vas al punto de encuentro'**
  String get driveHeadingToPickup;

  /// No description provided for @driveWaiting.
  ///
  /// In es, this message translates to:
  /// **'Esperando a la pasajera'**
  String get driveWaiting;

  /// No description provided for @driveInTransit.
  ///
  /// In es, this message translates to:
  /// **'Viaje en curso'**
  String get driveInTransit;

  /// No description provided for @driveCompleted.
  ///
  /// In es, this message translates to:
  /// **'Viaje terminado'**
  String get driveCompleted;

  /// No description provided for @driveNavigate.
  ///
  /// In es, this message translates to:
  /// **'Navegar'**
  String get driveNavigate;

  /// No description provided for @driveSlideArrived.
  ///
  /// In es, this message translates to:
  /// **'Desliza: ya llegué'**
  String get driveSlideArrived;

  /// No description provided for @driveSlideStart.
  ///
  /// In es, this message translates to:
  /// **'Desliza para iniciar el viaje'**
  String get driveSlideStart;

  /// No description provided for @driveSlideComplete.
  ///
  /// In es, this message translates to:
  /// **'Desliza para terminar'**
  String get driveSlideComplete;

  /// No description provided for @driveTripComplete.
  ///
  /// In es, this message translates to:
  /// **'Viaje completado'**
  String get driveTripComplete;

  /// No description provided for @driveFare.
  ///
  /// In es, this message translates to:
  /// **'Tarifa del viaje'**
  String get driveFare;

  /// No description provided for @driveCommission.
  ///
  /// In es, this message translates to:
  /// **'Comisión Taylor'**
  String get driveCommission;

  /// No description provided for @driveYouEarned.
  ///
  /// In es, this message translates to:
  /// **'Ganaste'**
  String get driveYouEarned;

  /// No description provided for @driveEarningsTitle.
  ///
  /// In es, this message translates to:
  /// **'Ganancias'**
  String get driveEarningsTitle;

  /// No description provided for @driveToday.
  ///
  /// In es, this message translates to:
  /// **'Hoy'**
  String get driveToday;

  /// No description provided for @driveThisWeek.
  ///
  /// In es, this message translates to:
  /// **'Esta semana'**
  String get driveThisWeek;

  /// No description provided for @driveRating.
  ///
  /// In es, this message translates to:
  /// **'Calificación'**
  String get driveRating;

  /// No description provided for @driveAcceptance.
  ///
  /// In es, this message translates to:
  /// **'Aceptación'**
  String get driveAcceptance;

  /// No description provided for @driveRecentTrips.
  ///
  /// In es, this message translates to:
  /// **'Viajes recientes'**
  String get driveRecentTrips;

  /// No description provided for @driveNoEarnings.
  ///
  /// In es, this message translates to:
  /// **'Aún no tienes viajes completados'**
  String get driveNoEarnings;

  /// No description provided for @driveTripsCount.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =0{Sin viajes} =1{1 viaje} other{{count} viajes}}'**
  String driveTripsCount(int count);

  /// No description provided for @driveIncludesTip.
  ///
  /// In es, this message translates to:
  /// **'Incluye {amount} de propina'**
  String driveIncludesTip(String amount);

  /// No description provided for @driveSwitchToDriver.
  ///
  /// In es, this message translates to:
  /// **'Modo conductora'**
  String get driveSwitchToDriver;

  /// No description provided for @driveSwitchToDriverBody.
  ///
  /// In es, this message translates to:
  /// **'Ponte en línea y recibe viajes'**
  String get driveSwitchToDriverBody;

  /// No description provided for @driveSwitchToPassenger.
  ///
  /// In es, this message translates to:
  /// **'Modo pasajera'**
  String get driveSwitchToPassenger;

  /// No description provided for @driveSwitchToPassengerBody.
  ///
  /// In es, this message translates to:
  /// **'Vuelve a pedir viajes'**
  String get driveSwitchToPassengerBody;

  /// No description provided for @driveUnderReview.
  ///
  /// In es, this message translates to:
  /// **'Solicitud en revisión'**
  String get driveUnderReview;

  /// No description provided for @driveUnderReviewBody.
  ///
  /// In es, this message translates to:
  /// **'Te daremos una respuesta antes del {date}.'**
  String driveUnderReviewBody(String date);

  /// No description provided for @bizNavTonight.
  ///
  /// In es, this message translates to:
  /// **'Hoy'**
  String get bizNavTonight;

  /// No description provided for @bizNavSchedule.
  ///
  /// In es, this message translates to:
  /// **'Agenda'**
  String get bizNavSchedule;

  /// No description provided for @bizNavTeam.
  ///
  /// In es, this message translates to:
  /// **'Equipo'**
  String get bizNavTeam;

  /// No description provided for @bizTonight.
  ///
  /// In es, this message translates to:
  /// **'Esta noche'**
  String get bizTonight;

  /// No description provided for @bizRidesTonight.
  ///
  /// In es, this message translates to:
  /// **'Traslados'**
  String get bizRidesTonight;

  /// No description provided for @bizArrivedOf.
  ///
  /// In es, this message translates to:
  /// **'{arrived} de {total} en casa'**
  String bizArrivedOf(int arrived, int total);

  /// No description provided for @bizNoRidesTonight.
  ///
  /// In es, this message translates to:
  /// **'Sin traslados hoy'**
  String get bizNoRidesTonight;

  /// No description provided for @bizNoRidesTonightBody.
  ///
  /// In es, this message translates to:
  /// **'No hay ninguna programación activa para hoy.'**
  String get bizNoRidesTonightBody;

  /// No description provided for @bizEveryoneHome.
  ///
  /// In es, this message translates to:
  /// **'Todas en casa'**
  String get bizEveryoneHome;

  /// No description provided for @bizEveryoneHomeBody.
  ///
  /// In es, this message translates to:
  /// **'Todos los traslados de esta noche terminaron bien.'**
  String get bizEveryoneHomeBody;

  /// No description provided for @bizStillTravelling.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 en camino} other{{count} en camino}}'**
  String bizStillTravelling(int count);

  /// No description provided for @bizStillTravellingBody.
  ///
  /// In es, this message translates to:
  /// **'Te avisaremos cuando todas hayan llegado.'**
  String get bizStillTravellingBody;

  /// No description provided for @bizNeedsAttention.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 requiere atención} other{{count} requieren atención}}'**
  String bizNeedsAttention(int count);

  /// No description provided for @bizNeedsAttentionBody.
  ///
  /// In es, this message translates to:
  /// **'Alguien no se presentó al punto de encuentro.'**
  String get bizNeedsAttentionBody;

  /// No description provided for @bizStatusScheduled.
  ///
  /// In es, this message translates to:
  /// **'Programado'**
  String get bizStatusScheduled;

  /// No description provided for @bizStatusAssigning.
  ///
  /// In es, this message translates to:
  /// **'Buscando conductora'**
  String get bizStatusAssigning;

  /// No description provided for @bizStatusDriverAssigned.
  ///
  /// In es, this message translates to:
  /// **'Conductora llega en {minutes} min'**
  String bizStatusDriverAssigned(int minutes);

  /// No description provided for @bizStatusInTransit.
  ///
  /// In es, this message translates to:
  /// **'En camino a casa · {minutes} min'**
  String bizStatusInTransit(int minutes);

  /// No description provided for @bizStatusArrived.
  ///
  /// In es, this message translates to:
  /// **'Llegó a casa'**
  String get bizStatusArrived;

  /// No description provided for @bizStatusArrivedAt.
  ///
  /// In es, this message translates to:
  /// **'Llegó a casa · {time}'**
  String bizStatusArrivedAt(String time);

  /// No description provided for @bizStatusNoShow.
  ///
  /// In es, this message translates to:
  /// **'No se presentó'**
  String get bizStatusNoShow;

  /// No description provided for @bizStatusCancelled.
  ///
  /// In es, this message translates to:
  /// **'Cancelado'**
  String get bizStatusCancelled;

  /// No description provided for @bizDriverName.
  ///
  /// In es, this message translates to:
  /// **'Conductora: {name}'**
  String bizDriverName(String name);

  /// No description provided for @bizCallEmployee.
  ///
  /// In es, this message translates to:
  /// **'Llamar'**
  String get bizCallEmployee;

  /// No description provided for @bizMonthSpend.
  ///
  /// In es, this message translates to:
  /// **'Gasto del mes'**
  String get bizMonthSpend;

  /// No description provided for @bizMonthRides.
  ///
  /// In es, this message translates to:
  /// **'Viajes del mes'**
  String get bizMonthRides;

  /// No description provided for @bizAvgPerRide.
  ///
  /// In es, this message translates to:
  /// **'Promedio por viaje'**
  String get bizAvgPerRide;

  /// No description provided for @bizScheduleTitle.
  ///
  /// In es, this message translates to:
  /// **'Agenda'**
  String get bizScheduleTitle;

  /// No description provided for @bizScheduleSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Programaciones recurrentes de tu equipo.'**
  String get bizScheduleSubtitle;

  /// No description provided for @bizNewSeries.
  ///
  /// In es, this message translates to:
  /// **'Nueva programación'**
  String get bizNewSeries;

  /// No description provided for @bizEditSeries.
  ///
  /// In es, this message translates to:
  /// **'Editar programación'**
  String get bizEditSeries;

  /// No description provided for @bizNoSeries.
  ///
  /// In es, this message translates to:
  /// **'Aún no tienes programaciones'**
  String get bizNoSeries;

  /// No description provided for @bizSeriesLabel.
  ///
  /// In es, this message translates to:
  /// **'Nombre de la programación'**
  String get bizSeriesLabel;

  /// No description provided for @bizSeriesOrigin.
  ///
  /// In es, this message translates to:
  /// **'Punto de salida'**
  String get bizSeriesOrigin;

  /// No description provided for @bizSeriesEmployees.
  ///
  /// In es, this message translates to:
  /// **'Empleadas incluidas'**
  String get bizSeriesEmployees;

  /// No description provided for @bizEmployeeCount.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =0{Sin empleadas} =1{1 empleada} other{{count} empleadas}}'**
  String bizEmployeeCount(int count);

  /// No description provided for @bizEdit.
  ///
  /// In es, this message translates to:
  /// **'Editar'**
  String get bizEdit;

  /// No description provided for @bizDelete.
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get bizDelete;

  /// No description provided for @bizTeamTitle.
  ///
  /// In es, this message translates to:
  /// **'Equipo'**
  String get bizTeamTitle;

  /// No description provided for @bizAddEmployee.
  ///
  /// In es, this message translates to:
  /// **'Agregar empleada'**
  String get bizAddEmployee;

  /// No description provided for @bizInactive.
  ///
  /// In es, this message translates to:
  /// **'Inactivas'**
  String get bizInactive;

  /// No description provided for @bizDeactivate.
  ///
  /// In es, this message translates to:
  /// **'Desactivar'**
  String get bizDeactivate;

  /// No description provided for @bizReactivate.
  ///
  /// In es, this message translates to:
  /// **'Reactivar'**
  String get bizReactivate;

  /// No description provided for @bizEmployeeName.
  ///
  /// In es, this message translates to:
  /// **'Nombre completo'**
  String get bizEmployeeName;

  /// No description provided for @bizEmployeeDepartment.
  ///
  /// In es, this message translates to:
  /// **'Área o departamento'**
  String get bizEmployeeDepartment;

  /// No description provided for @bizEmployeeArea.
  ///
  /// In es, this message translates to:
  /// **'Zona de destino'**
  String get bizEmployeeArea;

  /// No description provided for @bizEmployeeAreaHelp.
  ///
  /// In es, this message translates to:
  /// **'Solo la zona. La dirección exacta la registra ella y no es visible para la empresa.'**
  String get bizEmployeeAreaHelp;

  /// No description provided for @bizBilling.
  ///
  /// In es, this message translates to:
  /// **'Facturación'**
  String get bizBilling;

  /// No description provided for @bizInvoices.
  ///
  /// In es, this message translates to:
  /// **'Facturas'**
  String get bizInvoices;

  /// No description provided for @bizInvoicesBody.
  ///
  /// In es, this message translates to:
  /// **'Descarga tus comprobantes mensuales'**
  String get bizInvoicesBody;

  /// No description provided for @chatTitle.
  ///
  /// In es, this message translates to:
  /// **'Mensajes'**
  String get chatTitle;

  /// No description provided for @chatTripOnly.
  ///
  /// In es, this message translates to:
  /// **'Chat del viaje'**
  String get chatTripOnly;

  /// No description provided for @chatHint.
  ///
  /// In es, this message translates to:
  /// **'Escribe un mensaje'**
  String get chatHint;

  /// No description provided for @chatEmpty.
  ///
  /// In es, this message translates to:
  /// **'Todavía no hay mensajes.\nUsa una respuesta rápida para empezar.'**
  String get chatEmpty;

  /// No description provided for @chatKeyboardLocked.
  ///
  /// In es, this message translates to:
  /// **'El teclado está bloqueado mientras conduces. Usa las respuestas rápidas o detente para escribir.'**
  String get chatKeyboardLocked;

  /// No description provided for @chatQuickOnMyWay.
  ///
  /// In es, this message translates to:
  /// **'Voy en camino'**
  String get chatQuickOnMyWay;

  /// No description provided for @chatQuickArrived.
  ///
  /// In es, this message translates to:
  /// **'Ya llegué'**
  String get chatQuickArrived;

  /// No description provided for @chatQuickWaitingOutside.
  ///
  /// In es, this message translates to:
  /// **'Te espero afuera'**
  String get chatQuickWaitingOutside;

  /// No description provided for @chatQuickCantFind.
  ///
  /// In es, this message translates to:
  /// **'No encuentro el lugar'**
  String get chatQuickCantFind;

  /// No description provided for @chatQuickTraffic.
  ///
  /// In es, this message translates to:
  /// **'Hay tráfico, tardo un poco'**
  String get chatQuickTraffic;

  /// No description provided for @chatQuickComingOut.
  ///
  /// In es, this message translates to:
  /// **'Ya salgo'**
  String get chatQuickComingOut;

  /// No description provided for @chatQuickTwoMinutes.
  ///
  /// In es, this message translates to:
  /// **'Dame 2 minutos'**
  String get chatQuickTwoMinutes;

  /// No description provided for @chatQuickWhereAreYou.
  ///
  /// In es, this message translates to:
  /// **'¿Dónde estás?'**
  String get chatQuickWhereAreYou;

  /// No description provided for @chatQuickThanks.
  ///
  /// In es, this message translates to:
  /// **'¡Gracias!'**
  String get chatQuickThanks;

  /// No description provided for @tripCompleted.
  ///
  /// In es, this message translates to:
  /// **'Llegaste a tu destino'**
  String get tripCompleted;

  /// No description provided for @rateTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Cómo estuvo tu viaje?'**
  String get rateTitle;

  /// No description provided for @rateWith.
  ///
  /// In es, this message translates to:
  /// **'con {name}'**
  String rateWith(String name);

  /// No description provided for @rateCommentHint.
  ///
  /// In es, this message translates to:
  /// **'Cuéntanos más (opcional)'**
  String get rateCommentHint;

  /// No description provided for @rateSubmit.
  ///
  /// In es, this message translates to:
  /// **'Enviar calificación'**
  String get rateSubmit;

  /// No description provided for @rateSkip.
  ///
  /// In es, this message translates to:
  /// **'Ahora no'**
  String get rateSkip;

  /// No description provided for @rateThanks.
  ///
  /// In es, this message translates to:
  /// **'Gracias por calificar'**
  String get rateThanks;

  /// No description provided for @rateTagPunctual.
  ///
  /// In es, this message translates to:
  /// **'Puntual'**
  String get rateTagPunctual;

  /// No description provided for @rateTagFriendly.
  ///
  /// In es, this message translates to:
  /// **'Amable'**
  String get rateTagFriendly;

  /// No description provided for @rateTagSafeDriving.
  ///
  /// In es, this message translates to:
  /// **'Manejo seguro'**
  String get rateTagSafeDriving;

  /// No description provided for @rateTagCleanCar.
  ///
  /// In es, this message translates to:
  /// **'Auto limpio'**
  String get rateTagCleanCar;

  /// No description provided for @rateTagComfortable.
  ///
  /// In es, this message translates to:
  /// **'Me sentí cómoda'**
  String get rateTagComfortable;

  /// No description provided for @rateSafetyTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Pasó algo que debamos saber?'**
  String get rateSafetyTitle;

  /// No description provided for @rateSafetyBody.
  ///
  /// In es, this message translates to:
  /// **'Si te sentiste insegura en cualquier momento, cuéntanos. Lo revisa nuestro equipo de seguridad, no un algoritmo.'**
  String get rateSafetyBody;

  /// No description provided for @rateSafetyReport.
  ///
  /// In es, this message translates to:
  /// **'Reportar a seguridad'**
  String get rateSafetyReport;

  /// No description provided for @rateSafetySent.
  ///
  /// In es, this message translates to:
  /// **'Recibido. Nuestro equipo lo revisará y te contactará.'**
  String get rateSafetySent;

  /// No description provided for @receiptTitle.
  ///
  /// In es, this message translates to:
  /// **'Recibo'**
  String get receiptTitle;

  /// No description provided for @receiptBase.
  ///
  /// In es, this message translates to:
  /// **'Tarifa base'**
  String get receiptBase;

  /// No description provided for @receiptDistance.
  ///
  /// In es, this message translates to:
  /// **'Distancia ({km} km)'**
  String receiptDistance(String km);

  /// No description provided for @receiptTime.
  ///
  /// In es, this message translates to:
  /// **'Tiempo ({minutes} min)'**
  String receiptTime(int minutes);

  /// No description provided for @receiptTotal.
  ///
  /// In es, this message translates to:
  /// **'Total'**
  String get receiptTotal;

  /// No description provided for @receiptPaidWith.
  ///
  /// In es, this message translates to:
  /// **'Pagado con'**
  String get receiptPaidWith;

  /// No description provided for @receiptViewReceipt.
  ///
  /// In es, this message translates to:
  /// **'Ver recibo'**
  String get receiptViewReceipt;

  /// No description provided for @receiptShare.
  ///
  /// In es, this message translates to:
  /// **'Compartir recibo'**
  String get receiptShare;

  /// No description provided for @driveRatePassenger.
  ///
  /// In es, this message translates to:
  /// **'¿Cómo estuvo la pasajera?'**
  String get driveRatePassenger;
}

class _L10nDelegate extends LocalizationsDelegate<L10n> {
  const _L10nDelegate();

  @override
  Future<L10n> load(Locale locale) {
    return SynchronousFuture<L10n>(lookupL10n(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_L10nDelegate old) => false;
}

L10n lookupL10n(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return L10nEn();
    case 'es':
      return L10nEs();
  }

  throw FlutterError(
      'L10n.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
