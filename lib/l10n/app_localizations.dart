import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_id.dart';
import 'app_localizations_kk.dart';
import 'app_localizations_so.dart';
import 'app_localizations_tr.dart';
import 'app_localizations_ur.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
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
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
    Locale('ar'),
    Locale('en'),
    Locale('fr'),
    Locale('id'),
    Locale('kk'),
    Locale('so'),
    Locale('tr'),
    Locale('ur'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'UniGuide'**
  String get appTitle;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to UniGuide'**
  String get welcome;

  /// No description provided for @chooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose your language'**
  String get chooseLanguage;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @videoUrl.
  ///
  /// In en, this message translates to:
  /// **'https://youtu.be/UU73GwGwOUM?si=f9VZtttBwnkSmKOe'**
  String get videoUrl;

  /// No description provided for @themeModeTitle.
  ///
  /// In en, this message translates to:
  /// **'Theme mode'**
  String get themeModeTitle;

  /// No description provided for @themeModeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeModeSystem;

  /// No description provided for @themeModeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeModeLight;

  /// No description provided for @themeModeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeModeDark;

  /// No description provided for @tasks.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get tasks;

  /// No description provided for @services.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get services;

  /// No description provided for @nextStep.
  ///
  /// In en, this message translates to:
  /// **'Start university registration'**
  String get nextStep;

  /// No description provided for @housing.
  ///
  /// In en, this message translates to:
  /// **'Housing'**
  String get housing;

  /// No description provided for @residence.
  ///
  /// In en, this message translates to:
  /// **'Residence'**
  String get residence;

  /// No description provided for @university.
  ///
  /// In en, this message translates to:
  /// **'University'**
  String get university;

  /// No description provided for @transport.
  ///
  /// In en, this message translates to:
  /// **'Transport'**
  String get transport;

  /// No description provided for @kimlik_randevu.
  ///
  /// In en, this message translates to:
  /// **'Residence appointment booking'**
  String get kimlik_randevu;

  /// No description provided for @hesap_acma.
  ///
  /// In en, this message translates to:
  /// **'Opening a bank account'**
  String get hesap_acma;

  /// No description provided for @ogr_kart.
  ///
  /// In en, this message translates to:
  /// **'Student card issuance'**
  String get ogr_kart;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @guides.
  ///
  /// In en, this message translates to:
  /// **'Guides'**
  String get guides;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @selectProvince.
  ///
  /// In en, this message translates to:
  /// **'Select your province'**
  String get selectProvince;

  /// No description provided for @provinceKutahya.
  ///
  /// In en, this message translates to:
  /// **'Kütahya'**
  String get provinceKutahya;

  /// No description provided for @provinceIstanbul.
  ///
  /// In en, this message translates to:
  /// **'Istanbul'**
  String get provinceIstanbul;

  /// No description provided for @provinceAnkara.
  ///
  /// In en, this message translates to:
  /// **'Ankara'**
  String get provinceAnkara;

  /// No description provided for @provinceIzmir.
  ///
  /// In en, this message translates to:
  /// **'İzmir'**
  String get provinceIzmir;

  /// No description provided for @provinceEskisehir.
  ///
  /// In en, this message translates to:
  /// **'Eskişehir'**
  String get provinceEskisehir;

  /// No description provided for @provinceBursa.
  ///
  /// In en, this message translates to:
  /// **'Bursa'**
  String get provinceBursa;

  /// No description provided for @provinceKonya.
  ///
  /// In en, this message translates to:
  /// **'Konya'**
  String get provinceKonya;

  /// No description provided for @provinceAntalya.
  ///
  /// In en, this message translates to:
  /// **'Antalya'**
  String get provinceAntalya;

  /// No description provided for @provinceTrabzon.
  ///
  /// In en, this message translates to:
  /// **'Trabzon'**
  String get provinceTrabzon;

  /// No description provided for @provinceGaziantep.
  ///
  /// In en, this message translates to:
  /// **'Gaziantep'**
  String get provinceGaziantep;

  /// No description provided for @studentGuideTitle.
  ///
  /// In en, this message translates to:
  /// **'Student guide'**
  String get studentGuideTitle;

  /// No description provided for @searchGuideLabel.
  ///
  /// In en, this message translates to:
  /// **'Search guide content'**
  String get searchGuideLabel;

  /// No description provided for @searchGuideHint.
  ///
  /// In en, this message translates to:
  /// **'Search residence, bank, housing...'**
  String get searchGuideHint;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @noMatchingResults.
  ///
  /// In en, this message translates to:
  /// **'No matching results.'**
  String get noMatchingResults;

  /// No description provided for @settlementPlan.
  ///
  /// In en, this message translates to:
  /// **'Settlement plan'**
  String get settlementPlan;

  /// No description provided for @yourProgress.
  ///
  /// In en, this message translates to:
  /// **'Your progress'**
  String get yourProgress;

  /// No description provided for @completedSteps.
  ///
  /// In en, this message translates to:
  /// **'Completed {completed} of {total} steps'**
  String completedSteps(Object completed, Object total);

  /// No description provided for @suggestedNextStep.
  ///
  /// In en, this message translates to:
  /// **'Suggested next step'**
  String get suggestedNextStep;

  /// No description provided for @suggestedPlaces.
  ///
  /// In en, this message translates to:
  /// **'Suggested places'**
  String get suggestedPlaces;

  /// No description provided for @documents.
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get documents;

  /// No description provided for @warnings.
  ///
  /// In en, this message translates to:
  /// **'Warnings'**
  String get warnings;

  /// No description provided for @smartAssistantTitle.
  ///
  /// In en, this message translates to:
  /// **'Smart assistant'**
  String get smartAssistantTitle;

  /// No description provided for @smartAssistantIntro.
  ///
  /// In en, this message translates to:
  /// **'Ask about residence, housing, banking, university, or transport.'**
  String get smartAssistantIntro;

  /// No description provided for @smartAssistantDescription.
  ///
  /// In en, this message translates to:
  /// **'This is an on-device guidance assistant based on app content. Connect it later to a backend AI service with privacy controls and verified sources.'**
  String get smartAssistantDescription;

  /// No description provided for @smartAssistantQuestionLabel.
  ///
  /// In en, this message translates to:
  /// **'What is your question?'**
  String get smartAssistantQuestionLabel;

  /// No description provided for @searchTooltip.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchTooltip;

  /// No description provided for @quickSuggestions.
  ///
  /// In en, this message translates to:
  /// **'Quick suggestions'**
  String get quickSuggestions;

  /// No description provided for @suggestedAnswers.
  ///
  /// In en, this message translates to:
  /// **'Suggested answers'**
  String get suggestedAnswers;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @providerLabel.
  ///
  /// In en, this message translates to:
  /// **'Provider'**
  String get providerLabel;

  /// No description provided for @ageLabel.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get ageLabel;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccount;

  /// No description provided for @verified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get verified;

  /// No description provided for @needsOtp.
  ///
  /// In en, this message translates to:
  /// **'Needs OTP'**
  String get needsOtp;

  /// No description provided for @categoryPreArrival.
  ///
  /// In en, this message translates to:
  /// **'Pre-arrival'**
  String get categoryPreArrival;

  /// No description provided for @categoryAfterArrival.
  ///
  /// In en, this message translates to:
  /// **'After arrival'**
  String get categoryAfterArrival;

  /// No description provided for @categoryBanking.
  ///
  /// In en, this message translates to:
  /// **'Banking'**
  String get categoryBanking;

  /// No description provided for @categoryHousing.
  ///
  /// In en, this message translates to:
  /// **'Housing'**
  String get categoryHousing;

  /// No description provided for @categoryUniversityLife.
  ///
  /// In en, this message translates to:
  /// **'University life'**
  String get categoryUniversityLife;

  /// No description provided for @categoryTransport.
  ///
  /// In en, this message translates to:
  /// **'Transport'**
  String get categoryTransport;

  /// No description provided for @categoryStudentTips.
  ///
  /// In en, this message translates to:
  /// **'Student tips'**
  String get categoryStudentTips;

  /// No description provided for @categoryMaps.
  ///
  /// In en, this message translates to:
  /// **'Maps & places'**
  String get categoryMaps;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @sendCode.
  ///
  /// In en, this message translates to:
  /// **'Send code'**
  String get sendCode;

  /// No description provided for @changeEmail.
  ///
  /// In en, this message translates to:
  /// **'Change email'**
  String get changeEmail;

  /// No description provided for @resend.
  ///
  /// In en, this message translates to:
  /// **'Resend'**
  String get resend;

  /// No description provided for @verifyCode.
  ///
  /// In en, this message translates to:
  /// **'Verify code'**
  String get verifyCode;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @allDevices.
  ///
  /// In en, this message translates to:
  /// **'All devices'**
  String get allDevices;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get resetPassword;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @google.
  ///
  /// In en, this message translates to:
  /// **'Google'**
  String get google;

  /// No description provided for @apple.
  ///
  /// In en, this message translates to:
  /// **'Apple'**
  String get apple;

  /// No description provided for @unableToOpenExternalUrl.
  ///
  /// In en, this message translates to:
  /// **'Unable to open external URL'**
  String get unableToOpenExternalUrl;

  /// No description provided for @openInYouTube.
  ///
  /// In en, this message translates to:
  /// **'Open in YouTube'**
  String get openInYouTube;

  /// No description provided for @openSourceUrl.
  ///
  /// In en, this message translates to:
  /// **'Open source URL'**
  String get openSourceUrl;

  /// No description provided for @webViewErrorLabel.
  ///
  /// In en, this message translates to:
  /// **'WebView error:'**
  String get webViewErrorLabel;

  /// No description provided for @invalidYouTubeUrl.
  ///
  /// In en, this message translates to:
  /// **'Invalid YouTube URL.\nPlease check the link.'**
  String get invalidYouTubeUrl;

  /// No description provided for @birthYearLabel.
  ///
  /// In en, this message translates to:
  /// **'Birth year: {year}'**
  String birthYearLabel(Object year);

  /// No description provided for @chooseEmoji.
  ///
  /// In en, this message translates to:
  /// **'Choose your emoji'**
  String get chooseEmoji;

  /// No description provided for @selectEmoji.
  ///
  /// In en, this message translates to:
  /// **'Select {emoji}'**
  String selectEmoji(Object emoji);

  /// No description provided for @otpLabel.
  ///
  /// In en, this message translates to:
  /// **'OTP'**
  String get otpLabel;

  /// No description provided for @profileStepLabel.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileStepLabel;

  /// No description provided for @authWelcomeBackTitle.
  ///
  /// In en, this message translates to:
  /// **'Your UniGuide account'**
  String get authWelcomeBackTitle;

  /// No description provided for @authWelcomeBackSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A calmer profile space for your university journey.'**
  String get authWelcomeBackSubtitle;

  /// No description provided for @authJoinTitle.
  ///
  /// In en, this message translates to:
  /// **'Join UniGuide'**
  String get authJoinTitle;

  /// No description provided for @authJoinSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start with email verification, then shape your profile.'**
  String get authJoinSubtitle;

  /// No description provided for @authVerifyEmailTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify your email'**
  String get authVerifyEmailTitle;

  /// No description provided for @authVerifyEmailSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We will send a 6-digit code before creating the account.'**
  String get authVerifyEmailSubtitle;

  /// No description provided for @authEnterCodeTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the code'**
  String get authEnterCodeTitle;

  /// No description provided for @authEnterCodeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Check your inbox and type the code here.'**
  String get authEnterCodeSubtitle;

  /// No description provided for @authCompleteProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Complete your profile'**
  String get authCompleteProfileTitle;

  /// No description provided for @authCompleteProfileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add your name, password, and a personal emoji.'**
  String get authCompleteProfileSubtitle;

  /// No description provided for @firstNameLabel.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get firstNameLabel;

  /// No description provided for @lastNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get lastNameLabel;

  /// No description provided for @genderLabel.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get genderLabel;

  /// No description provided for @genderMale.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get genderMale;

  /// No description provided for @genderFemale.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get genderFemale;

  /// No description provided for @genderOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get genderOther;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @orContinueWith.
  ///
  /// In en, this message translates to:
  /// **'or continue with'**
  String get orContinueWith;

  /// No description provided for @emailStepLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailStepLabel;

  /// No description provided for @otpStepLabel.
  ///
  /// In en, this message translates to:
  /// **'OTP'**
  String get otpStepLabel;

  /// No description provided for @sixDigitCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'6-digit code'**
  String get sixDigitCodeLabel;

  /// No description provided for @verifyEmailFirst.
  ///
  /// In en, this message translates to:
  /// **'Verify your email first.'**
  String get verifyEmailFirst;

  /// No description provided for @accountControls.
  ///
  /// In en, this message translates to:
  /// **'Account controls'**
  String get accountControls;

  /// No description provided for @accountControlsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Keep your session and profile fresh.'**
  String get accountControlsSubtitle;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'en',
    'fr',
    'id',
    'kk',
    'so',
    'tr',
    'ur',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
    case 'id':
      return AppLocalizationsId();
    case 'kk':
      return AppLocalizationsKk();
    case 'so':
      return AppLocalizationsSo();
    case 'tr':
      return AppLocalizationsTr();
    case 'ur':
      return AppLocalizationsUr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
