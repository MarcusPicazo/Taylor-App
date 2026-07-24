// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class L10nEs extends L10n {
  L10nEs([String locale = 'es']) : super(locale);

  @override
  String get appTagline => 'Tu viaje, en tus términos.';

  @override
  String get continueLabel => 'Continuar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get save => 'Guardar';

  @override
  String get close => 'Cerrar';

  @override
  String get back => 'Atrás';

  @override
  String get next => 'Siguiente';

  @override
  String get done => 'Listo';

  @override
  String get retry => 'Reintentar';

  @override
  String get navHome => 'Inicio';

  @override
  String get navTrips => 'Viajes';

  @override
  String get navSafety => 'Seguridad';

  @override
  String get navAccount => 'Cuenta';

  @override
  String get loginTitle => 'Bienvenida a Taylor';

  @override
  String get loginSubtitle =>
      'La primera plataforma de movilidad hecha por mujeres, para mujeres.';

  @override
  String get loginWithGoogle => 'Continuar con Google';

  @override
  String get loginWithApple => 'Continuar con Apple';

  @override
  String get loginBusiness => 'Business';

  @override
  String get loginBusinessHint => '¿Tu empresa usa Taylor?';

  @override
  String get loginDemoAccess => 'Acceso de demostración';

  @override
  String get loginPassengersOnly =>
      'El acceso es exclusivo para pasajeras. Cada cuenta pasa por verificación de identidad.';

  @override
  String get loginTerms =>
      'Al continuar aceptas nuestros Términos y el Aviso de Privacidad.';

  @override
  String get demoTitle => 'Cuenta de demostración';

  @override
  String get demoSubtitle =>
      'Ingresa con la cuenta de exhibición para recorrer la app.';

  @override
  String get emailLabel => 'Correo electrónico';

  @override
  String get passwordLabel => 'Contraseña';

  @override
  String get signIn => 'Iniciar sesión';

  @override
  String get invalidCredentials => 'Correo o contraseña incorrectos.';

  @override
  String get businessTitle => 'Taylor para empresas';

  @override
  String get businessSubtitle =>
      'Traslados seguros y programados para tu equipo.';

  @override
  String get businessHaveCode => 'Ya tengo un código';

  @override
  String get businessRequestAccess => 'Solicitar acceso';

  @override
  String get businessCodeLabel => 'Código de empresa';

  @override
  String get businessCodeHelp =>
      'Es el código que te envió el equipo de Taylor.';

  @override
  String get invalidBusinessCode => 'Ese código no es válido o expiró.';

  @override
  String get businessFormCompany => 'Nombre de la empresa';

  @override
  String get businessFormContact => 'Persona de contacto';

  @override
  String get businessFormRole => 'Puesto';

  @override
  String get businessFormEmail => 'Correo corporativo';

  @override
  String get businessFormEmployees => 'Empleadas a transportar';

  @override
  String get businessFormCity => 'Ciudad de operación';

  @override
  String get businessFormSubmit => 'Enviar solicitud';

  @override
  String get businessSubmittedTitle => 'Solicitud enviada';

  @override
  String get businessSubmittedBody =>
      'El equipo de Taylor revisará tu solicitud y te dará una respuesta en un plazo de 3 a 5 días hábiles. Si se aprueba, recibirás un código de acceso por correo.';

  @override
  String get scheduleTitle => 'Viajes programados';

  @override
  String get scheduleSubtitle =>
      'Agenda los traslados de tu equipo por semana.';

  @override
  String get scheduleDays => 'Días de la semana';

  @override
  String get schedulePickup => 'Hora de salida';

  @override
  String get scheduleEmployees => 'Número de empleadas';

  @override
  String get scheduleSave => 'Guardar programación';

  @override
  String get scheduleSaved => 'Programación guardada';

  @override
  String get onboardingTitle => 'Verificación de seguridad';

  @override
  String get onboardingSubtitle =>
      'Nos toma un par de minutos. Es lo que hace que Taylor sea Taylor.';

  @override
  String get onboardingWhy => '¿Por qué pedimos esto?';

  @override
  String get onboardingWhyBody =>
      'Cada persona dentro de Taylor está verificada. Validamos identidad con documento oficial, comparamos tu rostro en vivo con ese documento y revisamos antecedentes. Nadie viaja con alguien sin verificar.';

  @override
  String get stepPhone => 'Confirma tu teléfono';

  @override
  String get stepPhoneBody => 'Te enviaremos un código de 6 dígitos.';

  @override
  String get phoneLabel => 'Número telefónico';

  @override
  String get sendCode => 'Enviar código';

  @override
  String codeSentTo(String phone) {
    return 'Código enviado a $phone';
  }

  @override
  String get verifyCode => 'Verificar';

  @override
  String get stepDocument => 'Escanea tu identificación';

  @override
  String get stepDocumentBody =>
      'Coloca tu INE o pasaporte dentro del marco. Leemos los datos automáticamente.';

  @override
  String get documentFront => 'Frente del documento';

  @override
  String get documentBack => 'Reverso del documento';

  @override
  String get documentCapture => 'Capturar';

  @override
  String get documentReading => 'Leyendo documento…';

  @override
  String get documentOk => 'Documento válido';

  @override
  String get stepFace => 'Reconocimiento facial';

  @override
  String get stepFaceBody =>
      'Mira a la cámara y gira la cabeza lentamente. Comprobamos que eres tú y que estás en vivo.';

  @override
  String get faceCentering => 'Centra tu rostro';

  @override
  String get faceTurn => 'Gira despacio a la derecha';

  @override
  String get faceHold => 'No te muevas…';

  @override
  String get faceMatching => 'Comparando con tu documento…';

  @override
  String get faceMatched => 'Identidad confirmada';

  @override
  String get stepBackground => 'Revisión de antecedentes';

  @override
  String get stepBackgroundBody =>
      'Consultamos bases de datos públicas y listas de seguridad. Es automático.';

  @override
  String get backgroundRunning => 'Verificando…';

  @override
  String get backgroundClear => 'Sin coincidencias';

  @override
  String verifiedTitle(String name) {
    return 'Todo listo, $name';
  }

  @override
  String get verifiedBody =>
      'Tu identidad quedó confirmada. Ya puedes viajar con Taylor.';

  @override
  String get startRiding => 'Empezar a viajar';

  @override
  String homeGreeting(String name) {
    return 'Hola, $name';
  }

  @override
  String get homeWhereTo => '¿A dónde vamos?';

  @override
  String get homeOrigin => 'Origen';

  @override
  String get homeDestination => 'Destino';

  @override
  String get homeSavedHome => 'Casa';

  @override
  String get homeSavedWork => 'Oficina';

  @override
  String get homeRequestRide => 'Pedir Taylor';

  @override
  String get homeConfirmPickup => 'Confirmar punto de encuentro';

  @override
  String get searchingTitle => 'Buscando conductora';

  @override
  String get searchingBody =>
      'Estamos conectándote con una conductora verificada cerca de ti.';

  @override
  String get searchingCancel => 'Cancelar búsqueda';

  @override
  String get driverFound => 'Conductora asignada';

  @override
  String driverArrivingIn(int minutes) {
    return 'Llega en $minutes min';
  }

  @override
  String driverTrips(int count) {
    return '$count viajes';
  }

  @override
  String driverYears(int years) {
    return '$years años en Taylor';
  }

  @override
  String get driverVerified => 'Verificada por Taylor';

  @override
  String get shareTrip => 'Compartir viaje';

  @override
  String get callDriver => 'Llamar';

  @override
  String get messageDriver => 'Mensaje';

  @override
  String get cancelTrip => 'Cancelar viaje';

  @override
  String get tripsTitle => 'Tus viajes';

  @override
  String get tripsEmpty => 'Todavía no tienes viajes';

  @override
  String get tripsEmptyBody =>
      'Cuando viajes con Taylor, tu historial aparecerá aquí.';

  @override
  String get tripsUpcoming => 'Programados';

  @override
  String get tripsPast => 'Anteriores';

  @override
  String get tripReceipt => 'Ver recibo';

  @override
  String get tripHelp => 'Necesito ayuda con este viaje';

  @override
  String get safetyTitle => 'Seguridad';

  @override
  String get safetySubtitle => 'Todo lo que necesitas, en un solo lugar.';

  @override
  String get safetySos => 'SOS';

  @override
  String get safetySosHold => 'Mantén presionado para llamar a emergencias';

  @override
  String get safetySosCalling => 'Llamando a emergencias…';

  @override
  String get safetyCallPolice => 'Llamar a la policía';

  @override
  String get safetyShareLive => 'Compartir mi ubicación en vivo';

  @override
  String get safetyShareLiveOn => 'Compartiendo ubicación en vivo';

  @override
  String get safetyShareLiveBody =>
      'Tus contactos de confianza pueden ver dónde estás en tiempo real.';

  @override
  String get safetyFriends => 'Amigas';

  @override
  String get safetyFriendsBody =>
      'Avisa a tus contactos de confianza dónde estás.';

  @override
  String get safetyNotifyFriends => 'Avisar a mis amigas';

  @override
  String get safetyNotified => 'Tus amigas fueron notificadas';

  @override
  String get safetyContacts => 'Contactos de emergencia';

  @override
  String get safetyAddContact => 'Agregar contacto';

  @override
  String get safetyNoContacts => 'Aún no agregas contactos de confianza';

  @override
  String get safetyContactName => 'Nombre';

  @override
  String get safetyContactPhone => 'Teléfono';

  @override
  String get safetyContactRelation => 'Parentesco o relación';

  @override
  String get accountTitle => 'Cuenta';

  @override
  String get accountProfile => 'Perfil';

  @override
  String get accountProfileBody => 'Nombre, foto y datos personales';

  @override
  String get accountWallet => 'Wallet';

  @override
  String get accountWalletBody => 'Métodos de pago y recibos';

  @override
  String get accountHelp => 'Ayuda';

  @override
  String get accountHelpBody => 'Soporte y ayuda con tus viajes';

  @override
  String get accountSettings => 'Configuración';

  @override
  String get accountSettingsBody => 'Idioma, notificaciones y privacidad';

  @override
  String get accountBecomeDriver => 'Conviértete en conductora';

  @override
  String get accountBecomeDriverBody => 'Maneja con Taylor y genera ingresos';

  @override
  String get accountSignOut => 'Cerrar sesión';

  @override
  String get profileTitle => 'Perfil';

  @override
  String get profilePhoto => 'Foto de perfil';

  @override
  String get profilePhotoBody =>
      'Elige la foto que quieras. Tu identidad ya está verificada con tu documento.';

  @override
  String get profileChangePhoto => 'Cambiar foto';

  @override
  String get profileFullName => 'Nombre completo';

  @override
  String get profileVerifiedId => 'Identidad verificada';

  @override
  String get profileSaved => 'Perfil actualizado';

  @override
  String get walletTitle => 'Wallet';

  @override
  String get walletMethods => 'Métodos de pago';

  @override
  String get walletAddCard => 'Agregar tarjeta';

  @override
  String get walletDefault => 'Predeterminado';

  @override
  String get walletSetDefault => 'Usar por defecto';

  @override
  String get walletRemove => 'Eliminar';

  @override
  String get walletCash => 'Efectivo';

  @override
  String get helpTitle => 'Ayuda';

  @override
  String get helpTripQuestion => '¿Con qué viaje necesitas ayuda?';

  @override
  String get helpGeneral => 'No es sobre un viaje';

  @override
  String get helpContactSupport => 'Contactar a soporte';

  @override
  String get helpEmail => 'Escribir un correo';

  @override
  String get helpChat => 'Enviar un mensaje';

  @override
  String get helpMessageLabel => 'Cuéntanos qué pasó';

  @override
  String get helpSend => 'Enviar';

  @override
  String get helpSent => 'Mensaje enviado. Te responderemos pronto.';

  @override
  String get settingsTitle => 'Configuración';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsLanguageSystem => 'Idioma del dispositivo';

  @override
  String get settingsNotifications => 'Notificaciones';

  @override
  String get settingsPrivacy => 'Privacidad';

  @override
  String get driverApplyTitle => 'Conduce con Taylor';

  @override
  String get driverApplySubtitle =>
      'Únete a la red de conductoras verificadas.';

  @override
  String get driverApplyIntro =>
      'Ser conductora de Taylor implica una verificación más estricta que la de pasajera. Es lo que nos permite prometer seguridad de verdad.';

  @override
  String get driverReqIdentity => 'Identidad oficial y CURP';

  @override
  String get driverReqLicense => 'Licencia de conducir vigente';

  @override
  String get driverReqRecord => 'Carta de antecedentes no penales';

  @override
  String get driverReqVehicle => 'Tarjeta de circulación y seguro';

  @override
  String get driverReqPhoto => 'Fotografía profesional de frente';

  @override
  String get driverReqBiometric => 'Validación biométrica con IA';

  @override
  String get driverPhotoNote =>
      'A diferencia de las pasajeras, tu foto de perfil debe ser una fotografía profesional de frente, sin filtros ni accesorios que cubran el rostro.';

  @override
  String get driverApplySubmit => 'Enviar solicitud';

  @override
  String get driverSubmittedTitle => 'Solicitud recibida';

  @override
  String get driverSubmittedBody =>
      'Vamos a revisar tus documentos y validar tus antecedentes. Te daremos una respuesta en un plazo de 3 a 5 días hábiles.';

  @override
  String get safetyBadgeVerified => 'Verificada';

  @override
  String get requiredField => 'Este campo es obligatorio';

  @override
  String get invalidEmail => 'Ingresa un correo válido';

  @override
  String get driveNavDrive => 'Conducir';

  @override
  String get driveNavEarnings => 'Ganancias';

  @override
  String get driveOnline => 'En línea';

  @override
  String get driveOnlineBody => 'Puedes recibir solicitudes';

  @override
  String get driveOffline => 'Desconectada';

  @override
  String get driveOfflineBody => 'No recibirás solicitudes';

  @override
  String get driveNewRequest => 'Nueva solicitud';

  @override
  String get driveAccept => 'Aceptar';

  @override
  String get driveDecline => 'Rechazar';

  @override
  String driveMinutesAway(int minutes) {
    return 'A $minutes min de distancia';
  }

  @override
  String driveTripLength(String km, int minutes) {
    return '$km km · $minutes min de viaje';
  }

  @override
  String get driveHeadingToPickup => 'Vas al punto de encuentro';

  @override
  String get driveWaiting => 'Esperando a la pasajera';

  @override
  String get driveInTransit => 'Viaje en curso';

  @override
  String get driveCompleted => 'Viaje terminado';

  @override
  String get driveNavigate => 'Navegar';

  @override
  String get driveSlideArrived => 'Desliza: ya llegué';

  @override
  String get driveSlideStart => 'Desliza para iniciar el viaje';

  @override
  String get driveSlideComplete => 'Desliza para terminar';

  @override
  String get driveTripComplete => 'Viaje completado';

  @override
  String get driveFare => 'Tarifa del viaje';

  @override
  String get driveCommission => 'Comisión Taylor';

  @override
  String get driveYouEarned => 'Ganaste';

  @override
  String get driveEarningsTitle => 'Ganancias';

  @override
  String get driveToday => 'Hoy';

  @override
  String get driveThisWeek => 'Esta semana';

  @override
  String get driveRating => 'Calificación';

  @override
  String get driveAcceptance => 'Aceptación';

  @override
  String get driveRecentTrips => 'Viajes recientes';

  @override
  String get driveNoEarnings => 'Aún no tienes viajes completados';

  @override
  String driveTripsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count viajes',
      one: '1 viaje',
      zero: 'Sin viajes',
    );
    return '$_temp0';
  }

  @override
  String driveIncludesTip(String amount) {
    return 'Incluye $amount de propina';
  }

  @override
  String get driveSwitchToDriver => 'Modo conductora';

  @override
  String get driveSwitchToDriverBody => 'Ponte en línea y recibe viajes';

  @override
  String get driveSwitchToPassenger => 'Modo pasajera';

  @override
  String get driveSwitchToPassengerBody => 'Vuelve a pedir viajes';

  @override
  String get driveUnderReview => 'Solicitud en revisión';

  @override
  String driveUnderReviewBody(String date) {
    return 'Te daremos una respuesta antes del $date.';
  }

  @override
  String get bizNavTonight => 'Hoy';

  @override
  String get bizNavSchedule => 'Agenda';

  @override
  String get bizNavTeam => 'Equipo';

  @override
  String get bizTonight => 'Esta noche';

  @override
  String get bizRidesTonight => 'Traslados';

  @override
  String bizArrivedOf(int arrived, int total) {
    return '$arrived de $total en casa';
  }

  @override
  String get bizNoRidesTonight => 'Sin traslados hoy';

  @override
  String get bizNoRidesTonightBody =>
      'No hay ninguna programación activa para hoy.';

  @override
  String get bizEveryoneHome => 'Todas en casa';

  @override
  String get bizEveryoneHomeBody =>
      'Todos los traslados de esta noche terminaron bien.';

  @override
  String bizStillTravelling(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count en camino',
      one: '1 en camino',
    );
    return '$_temp0';
  }

  @override
  String get bizStillTravellingBody =>
      'Te avisaremos cuando todas hayan llegado.';

  @override
  String bizNeedsAttention(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count requieren atención',
      one: '1 requiere atención',
    );
    return '$_temp0';
  }

  @override
  String get bizNeedsAttentionBody =>
      'Alguien no se presentó al punto de encuentro.';

  @override
  String get bizStatusScheduled => 'Programado';

  @override
  String get bizStatusAssigning => 'Buscando conductora';

  @override
  String bizStatusDriverAssigned(int minutes) {
    return 'Conductora llega en $minutes min';
  }

  @override
  String bizStatusInTransit(int minutes) {
    return 'En camino a casa · $minutes min';
  }

  @override
  String get bizStatusArrived => 'Llegó a casa';

  @override
  String bizStatusArrivedAt(String time) {
    return 'Llegó a casa · $time';
  }

  @override
  String get bizStatusNoShow => 'No se presentó';

  @override
  String get bizStatusCancelled => 'Cancelado';

  @override
  String bizDriverName(String name) {
    return 'Conductora: $name';
  }

  @override
  String get bizCallEmployee => 'Llamar';

  @override
  String get bizMonthSpend => 'Gasto del mes';

  @override
  String get bizMonthRides => 'Viajes del mes';

  @override
  String get bizAvgPerRide => 'Promedio por viaje';

  @override
  String get bizScheduleTitle => 'Agenda';

  @override
  String get bizScheduleSubtitle => 'Programaciones recurrentes de tu equipo.';

  @override
  String get bizNewSeries => 'Nueva programación';

  @override
  String get bizEditSeries => 'Editar programación';

  @override
  String get bizNoSeries => 'Aún no tienes programaciones';

  @override
  String get bizSeriesLabel => 'Nombre de la programación';

  @override
  String get bizSeriesOrigin => 'Punto de salida';

  @override
  String get bizSeriesEmployees => 'Empleadas incluidas';

  @override
  String bizEmployeeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count empleadas',
      one: '1 empleada',
      zero: 'Sin empleadas',
    );
    return '$_temp0';
  }

  @override
  String get bizEdit => 'Editar';

  @override
  String get bizDelete => 'Eliminar';

  @override
  String get bizTeamTitle => 'Equipo';

  @override
  String get bizAddEmployee => 'Agregar empleada';

  @override
  String get bizInactive => 'Inactivas';

  @override
  String get bizDeactivate => 'Desactivar';

  @override
  String get bizReactivate => 'Reactivar';

  @override
  String get bizEmployeeName => 'Nombre completo';

  @override
  String get bizEmployeeDepartment => 'Área o departamento';

  @override
  String get bizEmployeeArea => 'Zona de destino';

  @override
  String get bizEmployeeAreaHelp =>
      'Solo la zona. La dirección exacta la registra ella y no es visible para la empresa.';

  @override
  String get bizBilling => 'Facturación';

  @override
  String get bizInvoices => 'Facturas';

  @override
  String get bizInvoicesBody => 'Descarga tus comprobantes mensuales';

  @override
  String get chatTitle => 'Mensajes';

  @override
  String get chatTripOnly => 'Chat del viaje';

  @override
  String get chatHint => 'Escribe un mensaje';

  @override
  String get chatEmpty =>
      'Todavía no hay mensajes.\nUsa una respuesta rápida para empezar.';

  @override
  String get chatKeyboardLocked =>
      'El teclado está bloqueado mientras conduces. Usa las respuestas rápidas o detente para escribir.';

  @override
  String get chatQuickOnMyWay => 'Voy en camino';

  @override
  String get chatQuickArrived => 'Ya llegué';

  @override
  String get chatQuickWaitingOutside => 'Te espero afuera';

  @override
  String get chatQuickCantFind => 'No encuentro el lugar';

  @override
  String get chatQuickTraffic => 'Hay tráfico, tardo un poco';

  @override
  String get chatQuickComingOut => 'Ya salgo';

  @override
  String get chatQuickTwoMinutes => 'Dame 2 minutos';

  @override
  String get chatQuickWhereAreYou => '¿Dónde estás?';

  @override
  String get chatQuickThanks => '¡Gracias!';

  @override
  String get tripCompleted => 'Llegaste a tu destino';

  @override
  String get rateTitle => '¿Cómo estuvo tu viaje?';

  @override
  String rateWith(String name) {
    return 'con $name';
  }

  @override
  String get rateCommentHint => 'Cuéntanos más (opcional)';

  @override
  String get rateSubmit => 'Enviar calificación';

  @override
  String get rateSkip => 'Ahora no';

  @override
  String get rateThanks => 'Gracias por calificar';

  @override
  String get rateTagPunctual => 'Puntual';

  @override
  String get rateTagFriendly => 'Amable';

  @override
  String get rateTagSafeDriving => 'Manejo seguro';

  @override
  String get rateTagCleanCar => 'Auto limpio';

  @override
  String get rateTagComfortable => 'Me sentí cómoda';

  @override
  String get rateSafetyTitle => '¿Pasó algo que debamos saber?';

  @override
  String get rateSafetyBody =>
      'Si te sentiste insegura en cualquier momento, cuéntanos. Lo revisa nuestro equipo de seguridad, no un algoritmo.';

  @override
  String get rateSafetyReport => 'Reportar a seguridad';

  @override
  String get rateSafetySent =>
      'Recibido. Nuestro equipo lo revisará y te contactará.';

  @override
  String get receiptTitle => 'Recibo';

  @override
  String get receiptBase => 'Tarifa base';

  @override
  String receiptDistance(String km) {
    return 'Distancia ($km km)';
  }

  @override
  String receiptTime(int minutes) {
    return 'Tiempo ($minutes min)';
  }

  @override
  String get receiptTotal => 'Total';

  @override
  String get receiptPaidWith => 'Pagado con';

  @override
  String get receiptViewReceipt => 'Ver recibo';

  @override
  String get receiptShare => 'Compartir recibo';

  @override
  String get driveRatePassenger => '¿Cómo estuvo la pasajera?';

  @override
  String get searchHint => '¿A dónde quieres ir?';

  @override
  String get searchPrompt => 'Escribe una zona, calle o lugar';

  @override
  String get searchNoResults =>
      'No encontramos ese lugar.\nIntenta con otro nombre.';

  @override
  String tierArrivesIn(int minutes) {
    return 'Llega en $minutes min';
  }

  @override
  String tripEstimate(String km, int minutes) {
    return '$km km · $minutes min aprox.';
  }

  @override
  String confirmRide(String tier) {
    return 'Confirmar $tier';
  }

  @override
  String get locationDenied =>
      'Sin ubicación no podemos centrarte en el mapa, pero puedes escribir tu destino igual.';

  @override
  String get locationOpenSettings => 'Abrir ajustes';

  @override
  String get homeRecent => 'Recientes';

  @override
  String get searchDropPin => 'Marcar punto en el mapa';

  @override
  String get searchResolveFailed =>
      'No pudimos ubicar ese lugar. Intenta con otro.';

  @override
  String get pinPickupTitle => '¿Dónde te recogemos?';

  @override
  String get pinDropoffTitle => '¿A dónde vas?';

  @override
  String get pinPickupLabel => 'Punto marcado';

  @override
  String get pinDropoffLabel => 'Destino marcado';

  @override
  String get pinConfirm => 'Confirmar este punto';

  @override
  String pinCoordinates(String lat, String lng) {
    return '$lat, $lng';
  }

  @override
  String get pinCurrentLocation => 'Tu ubicación actual';

  @override
  String get pinChange => 'Cambiar';

  @override
  String get cancelTripTitle => '¿Cancelar el viaje?';

  @override
  String get cancelTripBody =>
      'Tu conductora ya fue notificada. Si cancelas, tendrás que pedir otro viaje.';

  @override
  String get cancelTripKeep => 'No, seguir';

  @override
  String get cancelTripConfirm => 'Sí, cancelar';

  @override
  String get cardNumber => 'Número de tarjeta';

  @override
  String get cardExpiry => 'Vence';

  @override
  String get cardCvv => 'CVV';

  @override
  String get cardHolder => 'Nombre en la tarjeta';

  @override
  String get cardSave => 'Guardar tarjeta';

  @override
  String get cardInvalidNumber => 'Ese número no es válido';

  @override
  String get cardInvalidExpiry => 'Fecha de vencimiento no válida';

  @override
  String get cardExpired => 'Tarjeta vencida';

  @override
  String get cardSecurityNote =>
      'Solo guardamos la marca y los últimos 4 dígitos. Nunca almacenamos el número completo.';

  @override
  String get stepContacts => 'Tu red de confianza';

  @override
  String get stepContactsBody =>
      'Agrega a alguien de confianza. Con un toque podrá ver dónde estás durante un viaje, y recibirá un aviso si pides ayuda.';

  @override
  String get stepContactsAdd => 'Agregar contacto';

  @override
  String stepContactsAdded(String name) {
    return '$name está en tu red';
  }

  @override
  String get stepContactsSkip => 'No tengo a nadie ahora';

  @override
  String get stepContactsSkipNote =>
      'Puedes agregarla después desde Seguridad. El botón de emergencia y la llamada a la policía funcionan igual sin contactos.';

  @override
  String get safetyNoContactsOnboarding =>
      'Agrega un contacto de confianza para poder avisar a alguien durante un viaje.';
}
