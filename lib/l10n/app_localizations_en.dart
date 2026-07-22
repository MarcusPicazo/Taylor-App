// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class L10nEn extends L10n {
  L10nEn([String locale = 'en']) : super(locale);

  @override
  String get appTagline => 'Your ride, on your terms.';

  @override
  String get continueLabel => 'Continue';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get close => 'Close';

  @override
  String get back => 'Back';

  @override
  String get next => 'Next';

  @override
  String get done => 'Done';

  @override
  String get retry => 'Try again';

  @override
  String get navHome => 'Home';

  @override
  String get navTrips => 'Trips';

  @override
  String get navSafety => 'Safety';

  @override
  String get navAccount => 'Account';

  @override
  String get loginTitle => 'Welcome to Taylor';

  @override
  String get loginSubtitle =>
      'The first mobility platform built by women, for women.';

  @override
  String get loginWithGoogle => 'Continue with Google';

  @override
  String get loginWithApple => 'Continue with Apple';

  @override
  String get loginBusiness => 'Business';

  @override
  String get loginBusinessHint => 'Does your company use Taylor?';

  @override
  String get loginDemoAccess => 'Demo access';

  @override
  String get loginPassengersOnly =>
      'Access is exclusive to passengers. Every account goes through identity verification.';

  @override
  String get loginTerms =>
      'By continuing you accept our Terms and Privacy Notice.';

  @override
  String get demoTitle => 'Demo account';

  @override
  String get demoSubtitle =>
      'Sign in with the showcase account to walk through the app.';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get signIn => 'Sign in';

  @override
  String get invalidCredentials => 'Incorrect email or password.';

  @override
  String get businessTitle => 'Taylor for business';

  @override
  String get businessSubtitle => 'Safe, scheduled rides for your team.';

  @override
  String get businessHaveCode => 'I already have a code';

  @override
  String get businessRequestAccess => 'Request access';

  @override
  String get businessCodeLabel => 'Company code';

  @override
  String get businessCodeHelp => 'This is the code the Taylor team sent you.';

  @override
  String get invalidBusinessCode => 'That code isn\'t valid or has expired.';

  @override
  String get businessFormCompany => 'Company name';

  @override
  String get businessFormContact => 'Contact person';

  @override
  String get businessFormRole => 'Role';

  @override
  String get businessFormEmail => 'Work email';

  @override
  String get businessFormEmployees => 'Employees to transport';

  @override
  String get businessFormCity => 'City of operation';

  @override
  String get businessFormSubmit => 'Submit request';

  @override
  String get businessSubmittedTitle => 'Request submitted';

  @override
  String get businessSubmittedBody =>
      'The Taylor team will review your request and respond within 3 to 5 business days. If approved, you\'ll receive an access code by email.';

  @override
  String get scheduleTitle => 'Scheduled rides';

  @override
  String get scheduleSubtitle => 'Plan your team\'s rides week by week.';

  @override
  String get scheduleDays => 'Days of the week';

  @override
  String get schedulePickup => 'Pickup time';

  @override
  String get scheduleEmployees => 'Number of employees';

  @override
  String get scheduleSave => 'Save schedule';

  @override
  String get scheduleSaved => 'Schedule saved';

  @override
  String get onboardingTitle => 'Safety verification';

  @override
  String get onboardingSubtitle =>
      'It takes a couple of minutes. It\'s what makes Taylor, Taylor.';

  @override
  String get onboardingWhy => 'Why do we ask for this?';

  @override
  String get onboardingWhyBody =>
      'Everyone inside Taylor is verified. We validate identity with an official document, match your live face against it, and run a background check. No one rides with someone unverified.';

  @override
  String get stepPhone => 'Confirm your phone';

  @override
  String get stepPhoneBody => 'We\'ll send you a 6-digit code.';

  @override
  String get phoneLabel => 'Phone number';

  @override
  String get sendCode => 'Send code';

  @override
  String codeSentTo(String phone) {
    return 'Code sent to $phone';
  }

  @override
  String get verifyCode => 'Verify';

  @override
  String get stepDocument => 'Scan your ID';

  @override
  String get stepDocumentBody =>
      'Place your ID or passport inside the frame. We read the data automatically.';

  @override
  String get documentFront => 'Front of document';

  @override
  String get documentBack => 'Back of document';

  @override
  String get documentCapture => 'Capture';

  @override
  String get documentReading => 'Reading document…';

  @override
  String get documentOk => 'Valid document';

  @override
  String get stepFace => 'Face recognition';

  @override
  String get stepFaceBody =>
      'Look at the camera and slowly turn your head. We confirm it\'s you and that you\'re live.';

  @override
  String get faceCentering => 'Center your face';

  @override
  String get faceTurn => 'Slowly turn right';

  @override
  String get faceHold => 'Hold still…';

  @override
  String get faceMatching => 'Matching against your document…';

  @override
  String get faceMatched => 'Identity confirmed';

  @override
  String get stepBackground => 'Background check';

  @override
  String get stepBackgroundBody =>
      'We check public databases and safety lists. It\'s automatic.';

  @override
  String get backgroundRunning => 'Checking…';

  @override
  String get backgroundClear => 'No matches found';

  @override
  String verifiedTitle(String name) {
    return 'You\'re all set, $name';
  }

  @override
  String get verifiedBody =>
      'Your identity is confirmed. You can now ride with Taylor.';

  @override
  String get startRiding => 'Start riding';

  @override
  String homeGreeting(String name) {
    return 'Hi, $name';
  }

  @override
  String get homeWhereTo => 'Where to?';

  @override
  String get homeOrigin => 'Pickup';

  @override
  String get homeDestination => 'Destination';

  @override
  String get homeSavedHome => 'Home';

  @override
  String get homeSavedWork => 'Work';

  @override
  String get homeRequestRide => 'Request Taylor';

  @override
  String get homeConfirmPickup => 'Confirm pickup point';

  @override
  String get searchingTitle => 'Finding your driver';

  @override
  String get searchingBody =>
      'We\'re connecting you with a verified driver near you.';

  @override
  String get searchingCancel => 'Cancel search';

  @override
  String get driverFound => 'Driver assigned';

  @override
  String driverArrivingIn(int minutes) {
    return 'Arrives in $minutes min';
  }

  @override
  String driverTrips(int count) {
    return '$count trips';
  }

  @override
  String driverYears(int years) {
    return '$years years with Taylor';
  }

  @override
  String get driverVerified => 'Verified by Taylor';

  @override
  String get shareTrip => 'Share trip';

  @override
  String get callDriver => 'Call';

  @override
  String get messageDriver => 'Message';

  @override
  String get cancelTrip => 'Cancel ride';

  @override
  String get tripsTitle => 'Your trips';

  @override
  String get tripsEmpty => 'No trips yet';

  @override
  String get tripsEmptyBody =>
      'Once you ride with Taylor, your history will show up here.';

  @override
  String get tripsUpcoming => 'Scheduled';

  @override
  String get tripsPast => 'Past';

  @override
  String get tripReceipt => 'View receipt';

  @override
  String get tripHelp => 'I need help with this trip';

  @override
  String get safetyTitle => 'Safety';

  @override
  String get safetySubtitle => 'Everything you need, in one place.';

  @override
  String get safetySos => 'SOS';

  @override
  String get safetySosHold => 'Press and hold to call emergency services';

  @override
  String get safetySosCalling => 'Calling emergency services…';

  @override
  String get safetyCallPolice => 'Call the police';

  @override
  String get safetyShareLive => 'Share my live location';

  @override
  String get safetyShareLiveOn => 'Sharing live location';

  @override
  String get safetyShareLiveBody =>
      'Your trusted contacts can see where you are in real time.';

  @override
  String get safetyFriends => 'Friends';

  @override
  String get safetyFriendsBody =>
      'Let your trusted contacts know where you are.';

  @override
  String get safetyNotifyFriends => 'Alert my friends';

  @override
  String get safetyNotified => 'Your friends have been notified';

  @override
  String get safetyContacts => 'Emergency contacts';

  @override
  String get safetyAddContact => 'Add contact';

  @override
  String get safetyNoContacts => 'You haven\'t added trusted contacts yet';

  @override
  String get safetyContactName => 'Name';

  @override
  String get safetyContactPhone => 'Phone';

  @override
  String get safetyContactRelation => 'Relationship';

  @override
  String get accountTitle => 'Account';

  @override
  String get accountProfile => 'Profile';

  @override
  String get accountProfileBody => 'Name, photo and personal details';

  @override
  String get accountWallet => 'Wallet';

  @override
  String get accountWalletBody => 'Payment methods and receipts';

  @override
  String get accountHelp => 'Help';

  @override
  String get accountHelpBody => 'Support and help with your trips';

  @override
  String get accountSettings => 'Settings';

  @override
  String get accountSettingsBody => 'Language, notifications and privacy';

  @override
  String get accountBecomeDriver => 'Become a driver';

  @override
  String get accountBecomeDriverBody => 'Drive with Taylor and earn income';

  @override
  String get accountSignOut => 'Sign out';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profilePhoto => 'Profile photo';

  @override
  String get profilePhotoBody =>
      'Pick any photo you like. Your identity is already verified against your ID.';

  @override
  String get profileChangePhoto => 'Change photo';

  @override
  String get profileFullName => 'Full name';

  @override
  String get profileVerifiedId => 'Identity verified';

  @override
  String get profileSaved => 'Profile updated';

  @override
  String get walletTitle => 'Wallet';

  @override
  String get walletMethods => 'Payment methods';

  @override
  String get walletAddCard => 'Add card';

  @override
  String get walletDefault => 'Default';

  @override
  String get walletSetDefault => 'Set as default';

  @override
  String get walletRemove => 'Remove';

  @override
  String get walletCash => 'Cash';

  @override
  String get helpTitle => 'Help';

  @override
  String get helpTripQuestion => 'Which trip do you need help with?';

  @override
  String get helpGeneral => 'It\'s not about a trip';

  @override
  String get helpContactSupport => 'Contact support';

  @override
  String get helpEmail => 'Send an email';

  @override
  String get helpChat => 'Send a message';

  @override
  String get helpMessageLabel => 'Tell us what happened';

  @override
  String get helpSend => 'Send';

  @override
  String get helpSent => 'Message sent. We\'ll get back to you soon.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageSystem => 'Device language';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsPrivacy => 'Privacy';

  @override
  String get driverApplyTitle => 'Drive with Taylor';

  @override
  String get driverApplySubtitle => 'Join the network of verified drivers.';

  @override
  String get driverApplyIntro =>
      'Becoming a Taylor driver involves stricter verification than riding. That\'s what lets us promise real safety.';

  @override
  String get driverReqIdentity => 'Official ID and tax number';

  @override
  String get driverReqLicense => 'Valid driver\'s license';

  @override
  String get driverReqRecord => 'Criminal background certificate';

  @override
  String get driverReqVehicle => 'Vehicle registration and insurance';

  @override
  String get driverReqPhoto => 'Professional front-facing photo';

  @override
  String get driverReqBiometric => 'AI biometric validation';

  @override
  String get driverPhotoNote =>
      'Unlike passengers, your profile photo must be a professional front-facing photograph, with no filters or accessories covering your face.';

  @override
  String get driverApplySubmit => 'Submit application';

  @override
  String get driverSubmittedTitle => 'Application received';

  @override
  String get driverSubmittedBody =>
      'We\'ll review your documents and validate your background. You\'ll get a response within 3 to 5 business days.';

  @override
  String get safetyBadgeVerified => 'Verified';

  @override
  String get requiredField => 'This field is required';

  @override
  String get invalidEmail => 'Enter a valid email';

  @override
  String get driveNavDrive => 'Drive';

  @override
  String get driveNavEarnings => 'Earnings';

  @override
  String get driveOnline => 'Online';

  @override
  String get driveOnlineBody => 'You can receive requests';

  @override
  String get driveOffline => 'Offline';

  @override
  String get driveOfflineBody => 'You won\'t receive requests';

  @override
  String get driveNewRequest => 'New request';

  @override
  String get driveAccept => 'Accept';

  @override
  String get driveDecline => 'Decline';

  @override
  String driveMinutesAway(int minutes) {
    return '$minutes min away';
  }

  @override
  String driveTripLength(String km, int minutes) {
    return '$km km · $minutes min trip';
  }

  @override
  String get driveHeadingToPickup => 'Heading to pickup';

  @override
  String get driveWaiting => 'Waiting for passenger';

  @override
  String get driveInTransit => 'Trip in progress';

  @override
  String get driveCompleted => 'Trip finished';

  @override
  String get driveNavigate => 'Navigate';

  @override
  String get driveSlideArrived => 'Slide: I\'ve arrived';

  @override
  String get driveSlideStart => 'Slide to start the trip';

  @override
  String get driveSlideComplete => 'Slide to finish';

  @override
  String get driveTripComplete => 'Trip completed';

  @override
  String get driveFare => 'Trip fare';

  @override
  String get driveCommission => 'Taylor commission';

  @override
  String get driveYouEarned => 'You earned';

  @override
  String get driveEarningsTitle => 'Earnings';

  @override
  String get driveToday => 'Today';

  @override
  String get driveThisWeek => 'This week';

  @override
  String get driveRating => 'Rating';

  @override
  String get driveAcceptance => 'Acceptance';

  @override
  String get driveRecentTrips => 'Recent trips';

  @override
  String get driveNoEarnings => 'No completed trips yet';

  @override
  String driveTripsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count trips',
      one: '1 trip',
      zero: 'No trips',
    );
    return '$_temp0';
  }

  @override
  String driveIncludesTip(String amount) {
    return 'Includes $amount tip';
  }

  @override
  String get driveSwitchToDriver => 'Driver mode';

  @override
  String get driveSwitchToDriverBody => 'Go online and take rides';

  @override
  String get driveSwitchToPassenger => 'Passenger mode';

  @override
  String get driveSwitchToPassengerBody => 'Go back to requesting rides';

  @override
  String get driveUnderReview => 'Application under review';

  @override
  String driveUnderReviewBody(String date) {
    return 'We\'ll get back to you before $date.';
  }

  @override
  String get bizNavTonight => 'Today';

  @override
  String get bizNavSchedule => 'Schedule';

  @override
  String get bizNavTeam => 'Team';

  @override
  String get bizTonight => 'Tonight';

  @override
  String get bizRidesTonight => 'Rides';

  @override
  String bizArrivedOf(int arrived, int total) {
    return '$arrived of $total home';
  }

  @override
  String get bizNoRidesTonight => 'No rides today';

  @override
  String get bizNoRidesTonightBody => 'There\'s no active schedule for today.';

  @override
  String get bizEveryoneHome => 'Everyone\'s home';

  @override
  String get bizEveryoneHomeBody => 'All of tonight\'s rides ended safely.';

  @override
  String bizStillTravelling(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count still travelling',
      one: '1 still travelling',
    );
    return '$_temp0';
  }

  @override
  String get bizStillTravellingBody =>
      'We\'ll let you know when everyone has arrived.';

  @override
  String bizNeedsAttention(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count need attention',
      one: '1 needs attention',
    );
    return '$_temp0';
  }

  @override
  String get bizNeedsAttentionBody =>
      'Someone didn\'t show up at the pickup point.';

  @override
  String get bizStatusScheduled => 'Scheduled';

  @override
  String get bizStatusAssigning => 'Finding a driver';

  @override
  String bizStatusDriverAssigned(int minutes) {
    return 'Driver arrives in $minutes min';
  }

  @override
  String bizStatusInTransit(int minutes) {
    return 'On the way home · $minutes min';
  }

  @override
  String get bizStatusArrived => 'Arrived home';

  @override
  String bizStatusArrivedAt(String time) {
    return 'Arrived home · $time';
  }

  @override
  String get bizStatusNoShow => 'No-show';

  @override
  String get bizStatusCancelled => 'Cancelled';

  @override
  String bizDriverName(String name) {
    return 'Driver: $name';
  }

  @override
  String get bizCallEmployee => 'Call';

  @override
  String get bizMonthSpend => 'Spend this month';

  @override
  String get bizMonthRides => 'Rides this month';

  @override
  String get bizAvgPerRide => 'Average per ride';

  @override
  String get bizScheduleTitle => 'Schedule';

  @override
  String get bizScheduleSubtitle => 'Recurring schedules for your team.';

  @override
  String get bizNewSeries => 'New schedule';

  @override
  String get bizEditSeries => 'Edit schedule';

  @override
  String get bizNoSeries => 'No schedules yet';

  @override
  String get bizSeriesLabel => 'Schedule name';

  @override
  String get bizSeriesOrigin => 'Pickup point';

  @override
  String get bizSeriesEmployees => 'Employees included';

  @override
  String bizEmployeeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count employees',
      one: '1 employee',
      zero: 'No employees',
    );
    return '$_temp0';
  }

  @override
  String get bizEdit => 'Edit';

  @override
  String get bizDelete => 'Delete';

  @override
  String get bizTeamTitle => 'Team';

  @override
  String get bizAddEmployee => 'Add employee';

  @override
  String get bizInactive => 'Inactive';

  @override
  String get bizDeactivate => 'Deactivate';

  @override
  String get bizReactivate => 'Reactivate';

  @override
  String get bizEmployeeName => 'Full name';

  @override
  String get bizEmployeeDepartment => 'Department';

  @override
  String get bizEmployeeArea => 'Destination area';

  @override
  String get bizEmployeeAreaHelp =>
      'Area only. She registers her exact address herself, and it isn\'t visible to the company.';

  @override
  String get bizBilling => 'Billing';

  @override
  String get bizInvoices => 'Invoices';

  @override
  String get bizInvoicesBody => 'Download your monthly statements';
}
