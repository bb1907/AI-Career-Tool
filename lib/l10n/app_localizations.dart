import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_am.dart';
import 'app_localizations_ar.dart';
import 'app_localizations_bg.dart';
import 'app_localizations_bn.dart';
import 'app_localizations_ca.dart';
import 'app_localizations_cs.dart';
import 'app_localizations_da.dart';
import 'app_localizations_de.dart';
import 'app_localizations_el.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_et.dart';
import 'app_localizations_fa.dart';
import 'app_localizations_fi.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_he.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_hr.dart';
import 'app_localizations_hu.dart';
import 'app_localizations_id.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ka.dart';
import 'app_localizations_km.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_lo.dart';
import 'app_localizations_lt.dart';
import 'app_localizations_lv.dart';
import 'app_localizations_ms.dart';
import 'app_localizations_my.dart';
import 'app_localizations_nb.dart';
import 'app_localizations_ne.dart';
import 'app_localizations_nl.dart';
import 'app_localizations_pl.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ro.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_si.dart';
import 'app_localizations_sk.dart';
import 'app_localizations_sl.dart';
import 'app_localizations_sr.dart';
import 'app_localizations_sv.dart';
import 'app_localizations_sw.dart';
import 'app_localizations_th.dart';
import 'app_localizations_tl.dart';
import 'app_localizations_tr.dart';
import 'app_localizations_uk.dart';
import 'app_localizations_ur.dart';
import 'app_localizations_vi.dart';
import 'app_localizations_zh.dart';

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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
    Locale('am'),
    Locale('ar'),
    Locale('bg'),
    Locale('bn'),
    Locale('ca'),
    Locale('cs'),
    Locale('da'),
    Locale('de'),
    Locale('el'),
    Locale('en'),
    Locale('es'),
    Locale('et'),
    Locale('fa'),
    Locale('fi'),
    Locale('fr'),
    Locale('he'),
    Locale('hi'),
    Locale('hr'),
    Locale('hu'),
    Locale('id'),
    Locale('it'),
    Locale('ja'),
    Locale('ka'),
    Locale('km'),
    Locale('ko'),
    Locale('lo'),
    Locale('lt'),
    Locale('lv'),
    Locale('ms'),
    Locale('my'),
    Locale('nb'),
    Locale('ne'),
    Locale('nl'),
    Locale('pl'),
    Locale('pt'),
    Locale('ro'),
    Locale('ru'),
    Locale('si'),
    Locale('sk'),
    Locale('sl'),
    Locale('sr'),
    Locale('sv'),
    Locale('sw'),
    Locale('th'),
    Locale('tl'),
    Locale('tr'),
    Locale('uk'),
    Locale('ur'),
    Locale('vi'),
    Locale('zh'),
  ];

  /// Application title
  ///
  /// In en, this message translates to:
  /// **'AI Career Copilot'**
  String get appTitle;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get retry;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @copied.
  ///
  /// In en, this message translates to:
  /// **'Copied!'**
  String get copied;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @generate.
  ///
  /// In en, this message translates to:
  /// **'Generate'**
  String get generate;

  /// No description provided for @regenerate.
  ///
  /// In en, this message translates to:
  /// **'Regenerate'**
  String get regenerate;

  /// No description provided for @analyzing.
  ///
  /// In en, this message translates to:
  /// **'Analyzing...'**
  String get analyzing;

  /// No description provided for @generating.
  ///
  /// In en, this message translates to:
  /// **'Generating...'**
  String get generating;

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get saving;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Career Copilot'**
  String get homeTitle;

  /// No description provided for @listening.
  ///
  /// In en, this message translates to:
  /// **'Listening...'**
  String get listening;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @homeSuggestionUploadCV.
  ///
  /// In en, this message translates to:
  /// **'Upload your CV to get personalized recommendations'**
  String get homeSuggestionUploadCV;

  /// No description provided for @homeSuggestionJobMatch.
  ///
  /// In en, this message translates to:
  /// **'Paste a job description to see how well you match'**
  String get homeSuggestionJobMatch;

  /// No description provided for @chatFlowNone.
  ///
  /// In en, this message translates to:
  /// **'AI Career Assistant'**
  String get chatFlowNone;

  /// No description provided for @loginDemoHint.
  ///
  /// In en, this message translates to:
  /// **'No account needed — explore all features in demo mode'**
  String get loginDemoHint;

  /// No description provided for @onboardingEverythingYouNeed.
  ///
  /// In en, this message translates to:
  /// **'Everything you need to land your dream job'**
  String get onboardingEverythingYouNeed;

  /// No description provided for @onboardingTargetRole.
  ///
  /// In en, this message translates to:
  /// **'What\'s your target role?'**
  String get onboardingTargetRole;

  /// No description provided for @onboardingRoleHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Software Engineer, Product Manager'**
  String get onboardingRoleHint;

  /// No description provided for @onboardingExperienceLevel.
  ///
  /// In en, this message translates to:
  /// **'Experience Level'**
  String get onboardingExperienceLevel;

  /// No description provided for @onboardingSettingsTip.
  ///
  /// In en, this message translates to:
  /// **'You can always change your preferences in Settings'**
  String get onboardingSettingsTip;

  /// No description provided for @aiPhotoTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Photo Studio'**
  String get aiPhotoTitle;

  /// No description provided for @aiPhotoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Transform your photo into a professional headshot'**
  String get aiPhotoSubtitle;

  /// No description provided for @aiPhotoJobType.
  ///
  /// In en, this message translates to:
  /// **'Job Type'**
  String get aiPhotoJobType;

  /// No description provided for @aiPhotoGenerate.
  ///
  /// In en, this message translates to:
  /// **'Generate photo'**
  String get aiPhotoGenerate;

  /// No description provided for @aiPhotoTryStyle.
  ///
  /// In en, this message translates to:
  /// **'Try different style'**
  String get aiPhotoTryStyle;

  /// No description provided for @aiPhotoCustomize.
  ///
  /// In en, this message translates to:
  /// **'Customize'**
  String get aiPhotoCustomize;

  /// No description provided for @aiPhotoResultTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Professional Look'**
  String get aiPhotoResultTitle;

  /// No description provided for @aiPhotoSaveProfile.
  ///
  /// In en, this message translates to:
  /// **'Save to Profile'**
  String get aiPhotoSaveProfile;

  /// No description provided for @aiPhotoDownload.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get aiPhotoDownload;

  /// No description provided for @aiPhotoTryAnother.
  ///
  /// In en, this message translates to:
  /// **'Try Another Style'**
  String get aiPhotoTryAnother;

  /// No description provided for @aiPhotoWatermark.
  ///
  /// In en, this message translates to:
  /// **'AI Career Copilot • Upgrade to remove watermark'**
  String get aiPhotoWatermark;

  /// No description provided for @aiPhotoDragHint.
  ///
  /// In en, this message translates to:
  /// **'← Drag to compare →'**
  String get aiPhotoDragHint;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get navHistory;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @splashTagline.
  ///
  /// In en, this message translates to:
  /// **'Your AI Career Partner'**
  String get splashTagline;

  /// No description provided for @onboardingTitle1.
  ///
  /// In en, this message translates to:
  /// **'Land Your Dream Job'**
  String get onboardingTitle1;

  /// No description provided for @onboardingDesc1.
  ///
  /// In en, this message translates to:
  /// **'AI-powered tools to build the perfect resume, write cover letters, and ace your interviews.'**
  String get onboardingDesc1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In en, this message translates to:
  /// **'Stand Out from the Crowd'**
  String get onboardingTitle2;

  /// No description provided for @onboardingDesc2.
  ///
  /// In en, this message translates to:
  /// **'Tailor every application with AI that understands what employers are looking for.'**
  String get onboardingDesc2;

  /// No description provided for @onboardingTitle3.
  ///
  /// In en, this message translates to:
  /// **'Practice Makes Perfect'**
  String get onboardingTitle3;

  /// No description provided for @onboardingDesc3.
  ///
  /// In en, this message translates to:
  /// **'Simulate real interviews with AI feedback and build confidence before the big day.'**
  String get onboardingDesc3;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign in'**
  String get alreadyHaveAccount;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue your career journey'**
  String get loginSubtitle;

  /// No description provided for @loginEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get loginEmail;

  /// No description provided for @loginPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get loginPassword;

  /// No description provided for @loginSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get loginSignIn;

  /// No description provided for @loginSignUp.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get loginSignUp;

  /// No description provided for @loginForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get loginForgotPassword;

  /// No description provided for @loginContinueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get loginContinueWithGoogle;

  /// No description provided for @loginContinueWithApple.
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get loginContinueWithApple;

  /// No description provided for @loginNoAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get loginNoAccount;

  /// No description provided for @loginHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get loginHaveAccount;

  /// No description provided for @loginDemoMode.
  ///
  /// In en, this message translates to:
  /// **'Continue in Demo Mode'**
  String get loginDemoMode;

  /// No description provided for @homeGreetingMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get homeGreetingMorning;

  /// No description provided for @homeGreetingAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get homeGreetingAfternoon;

  /// No description provided for @homeGreetingEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get homeGreetingEvening;

  /// No description provided for @homeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'What would you like to work on today?'**
  String get homeSubtitle;

  /// No description provided for @homeInputHint.
  ///
  /// In en, this message translates to:
  /// **'Ask me anything about your career...'**
  String get homeInputHint;

  /// No description provided for @homeQuickActionsLabel.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get homeQuickActionsLabel;

  /// No description provided for @homeSuggestionsLabel.
  ///
  /// In en, this message translates to:
  /// **'Suggestions'**
  String get homeSuggestionsLabel;

  /// No description provided for @homeActionBuildResume.
  ///
  /// In en, this message translates to:
  /// **'Build my resume'**
  String get homeActionBuildResume;

  /// No description provided for @homeActionCoverLetter.
  ///
  /// In en, this message translates to:
  /// **'Write cover letter'**
  String get homeActionCoverLetter;

  /// No description provided for @homeActionInterviewPrep.
  ///
  /// In en, this message translates to:
  /// **'Prep for interview'**
  String get homeActionInterviewPrep;

  /// No description provided for @homeActionUploadCV.
  ///
  /// In en, this message translates to:
  /// **'Upload my CV'**
  String get homeActionUploadCV;

  /// No description provided for @homeActionJobMatch.
  ///
  /// In en, this message translates to:
  /// **'Find matching jobs'**
  String get homeActionJobMatch;

  /// No description provided for @homeActionVideoIntro.
  ///
  /// In en, this message translates to:
  /// **'Record video intro'**
  String get homeActionVideoIntro;

  /// No description provided for @homeActionSkillGap.
  ///
  /// In en, this message translates to:
  /// **'Analyze skill gap'**
  String get homeActionSkillGap;

  /// No description provided for @homeActionMockInterview.
  ///
  /// In en, this message translates to:
  /// **'Mock interview'**
  String get homeActionMockInterview;

  /// No description provided for @homeActionNetworking.
  ///
  /// In en, this message translates to:
  /// **'Write networking msg'**
  String get homeActionNetworking;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @profileName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get profileName;

  /// No description provided for @profileEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get profileEmail;

  /// No description provided for @profileRole.
  ///
  /// In en, this message translates to:
  /// **'Target Role'**
  String get profileRole;

  /// No description provided for @profileExperience.
  ///
  /// In en, this message translates to:
  /// **'Years of Experience'**
  String get profileExperience;

  /// No description provided for @profileSkills.
  ///
  /// In en, this message translates to:
  /// **'Skills'**
  String get profileSkills;

  /// No description provided for @profileEducation.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get profileEducation;

  /// No description provided for @profileSummary.
  ///
  /// In en, this message translates to:
  /// **'Professional Summary'**
  String get profileSummary;

  /// No description provided for @profileEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get profileEdit;

  /// No description provided for @profileSave.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get profileSave;

  /// No description provided for @profilePlan.
  ///
  /// In en, this message translates to:
  /// **'Current Plan'**
  String get profilePlan;

  /// No description provided for @profilePlanFree.
  ///
  /// In en, this message translates to:
  /// **'Free Plan'**
  String get profilePlanFree;

  /// No description provided for @profilePlanPremium.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get profilePlanPremium;

  /// No description provided for @profileUpgrade.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Premium'**
  String get profileUpgrade;

  /// No description provided for @profileSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get profileSignOut;

  /// No description provided for @profileSignOutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get profileSignOutConfirm;

  /// No description provided for @historyTitle.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get historyTitle;

  /// No description provided for @historyResumes.
  ///
  /// In en, this message translates to:
  /// **'Resumes'**
  String get historyResumes;

  /// No description provided for @historyCoverLetters.
  ///
  /// In en, this message translates to:
  /// **'Cover Letters'**
  String get historyCoverLetters;

  /// No description provided for @historyInterviews.
  ///
  /// In en, this message translates to:
  /// **'Interviews'**
  String get historyInterviews;

  /// No description provided for @historyScripts.
  ///
  /// In en, this message translates to:
  /// **'Scripts'**
  String get historyScripts;

  /// No description provided for @historyEmpty.
  ///
  /// In en, this message translates to:
  /// **'No items yet'**
  String get historyEmpty;

  /// No description provided for @historyEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your generated content will appear here'**
  String get historyEmptySubtitle;

  /// No description provided for @historyDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this item?'**
  String get historyDeleteConfirm;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearance;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// No description provided for @settingsThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeDark;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsThemeSystem;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get settingsLanguageTitle;

  /// No description provided for @settingsNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsNotifications;

  /// No description provided for @settingsAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get settingsAccount;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAbout;

  /// No description provided for @settingsVersion.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get settingsVersion;

  /// No description provided for @settingsPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get settingsPrivacy;

  /// No description provided for @settingsTerms.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get settingsTerms;

  /// No description provided for @settingsApiKeys.
  ///
  /// In en, this message translates to:
  /// **'AI Provider Status'**
  String get settingsApiKeys;

  /// No description provided for @settingsApiKeysSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Configure AI provider API keys'**
  String get settingsApiKeysSubtitle;

  /// No description provided for @resumeTitle.
  ///
  /// In en, this message translates to:
  /// **'My Resumes'**
  String get resumeTitle;

  /// No description provided for @resumeNew.
  ///
  /// In en, this message translates to:
  /// **'New Resume'**
  String get resumeNew;

  /// No description provided for @resumeEmpty.
  ///
  /// In en, this message translates to:
  /// **'No resumes yet'**
  String get resumeEmpty;

  /// No description provided for @resumeEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create your first AI-powered resume'**
  String get resumeEmptySubtitle;

  /// No description provided for @resumeCreate.
  ///
  /// In en, this message translates to:
  /// **'Create Resume'**
  String get resumeCreate;

  /// No description provided for @resumeEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit Resume'**
  String get resumeEdit;

  /// No description provided for @resumePreview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get resumePreview;

  /// No description provided for @resumeExport.
  ///
  /// In en, this message translates to:
  /// **'Export PDF'**
  String get resumeExport;

  /// No description provided for @resumeDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete Resume'**
  String get resumeDelete;

  /// No description provided for @resumeWizardTitle.
  ///
  /// In en, this message translates to:
  /// **'Resume Builder'**
  String get resumeWizardTitle;

  /// No description provided for @resumeStepBasicInfo.
  ///
  /// In en, this message translates to:
  /// **'Basic Info'**
  String get resumeStepBasicInfo;

  /// No description provided for @resumeStepSummary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get resumeStepSummary;

  /// No description provided for @resumeStepExperience.
  ///
  /// In en, this message translates to:
  /// **'Experience'**
  String get resumeStepExperience;

  /// No description provided for @resumeStepEducation.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get resumeStepEducation;

  /// No description provided for @resumeStepSkills.
  ///
  /// In en, this message translates to:
  /// **'Skills'**
  String get resumeStepSkills;

  /// No description provided for @resumeStepProjects.
  ///
  /// In en, this message translates to:
  /// **'Projects'**
  String get resumeStepProjects;

  /// No description provided for @resumeFullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get resumeFullName;

  /// No description provided for @resumeEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get resumeEmail;

  /// No description provided for @resumePhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get resumePhone;

  /// No description provided for @resumeLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get resumeLocation;

  /// No description provided for @resumeLinkedIn.
  ///
  /// In en, this message translates to:
  /// **'LinkedIn'**
  String get resumeLinkedIn;

  /// No description provided for @resumeWebsite.
  ///
  /// In en, this message translates to:
  /// **'Website / Portfolio'**
  String get resumeWebsite;

  /// No description provided for @resumeTargetRole.
  ///
  /// In en, this message translates to:
  /// **'Target Role'**
  String get resumeTargetRole;

  /// No description provided for @resumeYearsExp.
  ///
  /// In en, this message translates to:
  /// **'Years of Experience'**
  String get resumeYearsExp;

  /// No description provided for @resumeSummaryHint.
  ///
  /// In en, this message translates to:
  /// **'Brief professional summary...'**
  String get resumeSummaryHint;

  /// No description provided for @resumeGenerateSummary.
  ///
  /// In en, this message translates to:
  /// **'Generate with AI'**
  String get resumeGenerateSummary;

  /// No description provided for @resumeGeneratingSummary.
  ///
  /// In en, this message translates to:
  /// **'Generating summary...'**
  String get resumeGeneratingSummary;

  /// No description provided for @resumeAddExperience.
  ///
  /// In en, this message translates to:
  /// **'Add Experience'**
  String get resumeAddExperience;

  /// No description provided for @resumeJobTitle.
  ///
  /// In en, this message translates to:
  /// **'Job Title'**
  String get resumeJobTitle;

  /// No description provided for @resumeCompany.
  ///
  /// In en, this message translates to:
  /// **'Company'**
  String get resumeCompany;

  /// No description provided for @resumeStartDate.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get resumeStartDate;

  /// No description provided for @resumeEndDate.
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get resumeEndDate;

  /// No description provided for @resumePresent.
  ///
  /// In en, this message translates to:
  /// **'Present'**
  String get resumePresent;

  /// No description provided for @resumeDescription.
  ///
  /// In en, this message translates to:
  /// **'Key responsibilities and achievements'**
  String get resumeDescription;

  /// No description provided for @resumeAddEducation.
  ///
  /// In en, this message translates to:
  /// **'Add Education'**
  String get resumeAddEducation;

  /// No description provided for @resumeDegree.
  ///
  /// In en, this message translates to:
  /// **'Degree'**
  String get resumeDegree;

  /// No description provided for @resumeSchool.
  ///
  /// In en, this message translates to:
  /// **'School / University'**
  String get resumeSchool;

  /// No description provided for @resumeGradYear.
  ///
  /// In en, this message translates to:
  /// **'Graduation Year'**
  String get resumeGradYear;

  /// No description provided for @resumeAddSkill.
  ///
  /// In en, this message translates to:
  /// **'Add skill...'**
  String get resumeAddSkill;

  /// No description provided for @resumeSkillSuggestions.
  ///
  /// In en, this message translates to:
  /// **'AI Skill Suggestions'**
  String get resumeSkillSuggestions;

  /// No description provided for @resumeAddProject.
  ///
  /// In en, this message translates to:
  /// **'Add Project'**
  String get resumeAddProject;

  /// No description provided for @resumeProjectName.
  ///
  /// In en, this message translates to:
  /// **'Project Name'**
  String get resumeProjectName;

  /// No description provided for @resumeProjectDescription.
  ///
  /// In en, this message translates to:
  /// **'Project description'**
  String get resumeProjectDescription;

  /// No description provided for @resumePreviewSection.
  ///
  /// In en, this message translates to:
  /// **'Preview & Export'**
  String get resumePreviewSection;

  /// No description provided for @resumeSectionSummary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get resumeSectionSummary;

  /// No description provided for @resumeSectionExperience.
  ///
  /// In en, this message translates to:
  /// **'Experience'**
  String get resumeSectionExperience;

  /// No description provided for @resumeSectionEducation.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get resumeSectionEducation;

  /// No description provided for @resumeSectionSkills.
  ///
  /// In en, this message translates to:
  /// **'Skills'**
  String get resumeSectionSkills;

  /// No description provided for @resumeSectionProjects.
  ///
  /// In en, this message translates to:
  /// **'Projects'**
  String get resumeSectionProjects;

  /// No description provided for @coverLetterTitle.
  ///
  /// In en, this message translates to:
  /// **'Cover Letter'**
  String get coverLetterTitle;

  /// No description provided for @coverLetterNew.
  ///
  /// In en, this message translates to:
  /// **'New Cover Letter'**
  String get coverLetterNew;

  /// No description provided for @coverLetterTargetRole.
  ///
  /// In en, this message translates to:
  /// **'Target Role'**
  String get coverLetterTargetRole;

  /// No description provided for @coverLetterCompany.
  ///
  /// In en, this message translates to:
  /// **'Company Name'**
  String get coverLetterCompany;

  /// No description provided for @coverLetterJobDesc.
  ///
  /// In en, this message translates to:
  /// **'Job Description'**
  String get coverLetterJobDesc;

  /// No description provided for @coverLetterJobDescHint.
  ///
  /// In en, this message translates to:
  /// **'Paste the job description here...'**
  String get coverLetterJobDescHint;

  /// No description provided for @coverLetterTone.
  ///
  /// In en, this message translates to:
  /// **'Tone'**
  String get coverLetterTone;

  /// No description provided for @coverLetterToneProfessional.
  ///
  /// In en, this message translates to:
  /// **'Professional'**
  String get coverLetterToneProfessional;

  /// No description provided for @coverLetterToneEnthusiastic.
  ///
  /// In en, this message translates to:
  /// **'Enthusiastic'**
  String get coverLetterToneEnthusiastic;

  /// No description provided for @coverLetterToneCreative.
  ///
  /// In en, this message translates to:
  /// **'Creative'**
  String get coverLetterToneCreative;

  /// No description provided for @coverLetterToneConcise.
  ///
  /// In en, this message translates to:
  /// **'Concise'**
  String get coverLetterToneConcise;

  /// No description provided for @coverLetterGenerate.
  ///
  /// In en, this message translates to:
  /// **'Generate Cover Letter'**
  String get coverLetterGenerate;

  /// No description provided for @coverLetterResult.
  ///
  /// In en, this message translates to:
  /// **'Your Cover Letter'**
  String get coverLetterResult;

  /// No description provided for @coverLetterCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy Letter'**
  String get coverLetterCopy;

  /// No description provided for @coverLetterRegenerate.
  ///
  /// In en, this message translates to:
  /// **'Regenerate'**
  String get coverLetterRegenerate;

  /// No description provided for @coverLetterExport.
  ///
  /// In en, this message translates to:
  /// **'Export PDF'**
  String get coverLetterExport;

  /// No description provided for @coverLetterSmart.
  ///
  /// In en, this message translates to:
  /// **'Smart Cover Letter'**
  String get coverLetterSmart;

  /// No description provided for @coverLetterSmartSubtitle.
  ///
  /// In en, this message translates to:
  /// **'AI analyzes JD + your profile'**
  String get coverLetterSmartSubtitle;

  /// No description provided for @coverLetterContextLabel.
  ///
  /// In en, this message translates to:
  /// **'Your Context'**
  String get coverLetterContextLabel;

  /// No description provided for @coverLetterContextHint.
  ///
  /// In en, this message translates to:
  /// **'Any specific points you want to highlight...'**
  String get coverLetterContextHint;

  /// No description provided for @interviewPrepTitle.
  ///
  /// In en, this message translates to:
  /// **'Interview Prep'**
  String get interviewPrepTitle;

  /// No description provided for @interviewPrepSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get tailored technical and behavioral questions with sample answers.'**
  String get interviewPrepSubtitle;

  /// No description provided for @interviewPrepRole.
  ///
  /// In en, this message translates to:
  /// **'Role / Position'**
  String get interviewPrepRole;

  /// No description provided for @interviewPrepRoleHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Flutter Developer, Backend Engineer'**
  String get interviewPrepRoleHint;

  /// No description provided for @interviewPrepSeniority.
  ///
  /// In en, this message translates to:
  /// **'Seniority Level'**
  String get interviewPrepSeniority;

  /// No description provided for @interviewPrepSeniorityJunior.
  ///
  /// In en, this message translates to:
  /// **'Junior'**
  String get interviewPrepSeniorityJunior;

  /// No description provided for @interviewPrepSeniorityMid.
  ///
  /// In en, this message translates to:
  /// **'Mid-level'**
  String get interviewPrepSeniorityMid;

  /// No description provided for @interviewPrepSenioritySenior.
  ///
  /// In en, this message translates to:
  /// **'Senior'**
  String get interviewPrepSenioritySenior;

  /// No description provided for @interviewPrepSeniorityLead.
  ///
  /// In en, this message translates to:
  /// **'Lead'**
  String get interviewPrepSeniorityLead;

  /// No description provided for @interviewPrepGenerate.
  ///
  /// In en, this message translates to:
  /// **'Generate Questions'**
  String get interviewPrepGenerate;

  /// No description provided for @interviewPrepGenerating.
  ///
  /// In en, this message translates to:
  /// **'Generating...'**
  String get interviewPrepGenerating;

  /// No description provided for @interviewPrepPracticeMode.
  ///
  /// In en, this message translates to:
  /// **'Practice Mode'**
  String get interviewPrepPracticeMode;

  /// No description provided for @interviewPrepPracticeNew.
  ///
  /// In en, this message translates to:
  /// **'NEW'**
  String get interviewPrepPracticeNew;

  /// No description provided for @interviewPrepPracticeDesc.
  ///
  /// In en, this message translates to:
  /// **'Answer questions live and get instant AI feedback on each response.'**
  String get interviewPrepPracticeDesc;

  /// No description provided for @interviewPrepStartPractice.
  ///
  /// In en, this message translates to:
  /// **'Start Practice Session'**
  String get interviewPrepStartPractice;

  /// No description provided for @interviewPrepQuestionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Interview Questions'**
  String get interviewPrepQuestionsTitle;

  /// No description provided for @interviewPrepSampleAnswer.
  ///
  /// In en, this message translates to:
  /// **'Sample Answer'**
  String get interviewPrepSampleAnswer;

  /// No description provided for @interviewPrepShowAnswer.
  ///
  /// In en, this message translates to:
  /// **'Show Answer'**
  String get interviewPrepShowAnswer;

  /// No description provided for @interviewPrepHideAnswer.
  ///
  /// In en, this message translates to:
  /// **'Hide Answer'**
  String get interviewPrepHideAnswer;

  /// No description provided for @interviewPrepCategoryTechnical.
  ///
  /// In en, this message translates to:
  /// **'Technical'**
  String get interviewPrepCategoryTechnical;

  /// No description provided for @interviewPrepCategoryBehavioral.
  ///
  /// In en, this message translates to:
  /// **'Behavioral'**
  String get interviewPrepCategoryBehavioral;

  /// No description provided for @interviewPrepCategorySituational.
  ///
  /// In en, this message translates to:
  /// **'Situational'**
  String get interviewPrepCategorySituational;

  /// No description provided for @interviewPrepCategoryGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get interviewPrepCategoryGeneral;

  /// No description provided for @cvUploadTitle.
  ///
  /// In en, this message translates to:
  /// **'Import Your CV'**
  String get cvUploadTitle;

  /// No description provided for @cvUploadSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose how to import your professional profile'**
  String get cvUploadSubtitle;

  /// No description provided for @cvUploadMethodPdf.
  ///
  /// In en, this message translates to:
  /// **'PDF / DOC'**
  String get cvUploadMethodPdf;

  /// No description provided for @cvUploadMethodLinkedInPdf.
  ///
  /// In en, this message translates to:
  /// **'LinkedIn PDF'**
  String get cvUploadMethodLinkedInPdf;

  /// No description provided for @cvUploadMethodLinkedInUrl.
  ///
  /// In en, this message translates to:
  /// **'LinkedIn URL'**
  String get cvUploadMethodLinkedInUrl;

  /// No description provided for @cvUploadMethodPaste.
  ///
  /// In en, this message translates to:
  /// **'Copy & Paste'**
  String get cvUploadMethodPaste;

  /// No description provided for @cvUploadMethodVoice.
  ///
  /// In en, this message translates to:
  /// **'Voice'**
  String get cvUploadMethodVoice;

  /// No description provided for @cvUploadPdfTitle.
  ///
  /// In en, this message translates to:
  /// **'Upload PDF or Word Document'**
  String get cvUploadPdfTitle;

  /// No description provided for @cvUploadPdfSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We\'ll extract your experience, skills, and education'**
  String get cvUploadPdfSubtitle;

  /// No description provided for @cvUploadPdfButton.
  ///
  /// In en, this message translates to:
  /// **'Choose File'**
  String get cvUploadPdfButton;

  /// No description provided for @cvUploadLinkedInPdfTitle.
  ///
  /// In en, this message translates to:
  /// **'Export from LinkedIn'**
  String get cvUploadLinkedInPdfTitle;

  /// No description provided for @cvUploadLinkedInPdfStep1.
  ///
  /// In en, this message translates to:
  /// **'1. Go to your LinkedIn profile'**
  String get cvUploadLinkedInPdfStep1;

  /// No description provided for @cvUploadLinkedInPdfStep2.
  ///
  /// In en, this message translates to:
  /// **'2. Click \'More\' → \'Save to PDF\''**
  String get cvUploadLinkedInPdfStep2;

  /// No description provided for @cvUploadLinkedInPdfStep3.
  ///
  /// In en, this message translates to:
  /// **'3. Upload the downloaded PDF here'**
  String get cvUploadLinkedInPdfStep3;

  /// No description provided for @cvUploadLinkedInPdfButton.
  ///
  /// In en, this message translates to:
  /// **'Upload LinkedIn PDF'**
  String get cvUploadLinkedInPdfButton;

  /// No description provided for @cvUploadLinkedInUrlTitle.
  ///
  /// In en, this message translates to:
  /// **'Paste Your LinkedIn URL'**
  String get cvUploadLinkedInUrlTitle;

  /// No description provided for @cvUploadLinkedInUrlHint.
  ///
  /// In en, this message translates to:
  /// **'https://linkedin.com/in/yourname'**
  String get cvUploadLinkedInUrlHint;

  /// No description provided for @cvUploadLinkedInUrlButton.
  ///
  /// In en, this message translates to:
  /// **'Import Profile'**
  String get cvUploadLinkedInUrlButton;

  /// No description provided for @cvUploadPasteTitle.
  ///
  /// In en, this message translates to:
  /// **'Paste Your CV Text'**
  String get cvUploadPasteTitle;

  /// No description provided for @cvUploadPasteHint.
  ///
  /// In en, this message translates to:
  /// **'Paste the content of your CV or resume here...'**
  String get cvUploadPasteHint;

  /// No description provided for @cvUploadPasteButton.
  ///
  /// In en, this message translates to:
  /// **'Parse My CV'**
  String get cvUploadPasteButton;

  /// No description provided for @cvUploadVoiceTitle.
  ///
  /// In en, this message translates to:
  /// **'Describe Your Experience'**
  String get cvUploadVoiceTitle;

  /// No description provided for @cvUploadVoiceHint.
  ///
  /// In en, this message translates to:
  /// **'Tell us about your work experience, skills, and education. Speak naturally...'**
  String get cvUploadVoiceHint;

  /// No description provided for @cvUploadVoiceButton.
  ///
  /// In en, this message translates to:
  /// **'Tap to Speak'**
  String get cvUploadVoiceButton;

  /// No description provided for @cvUploadVoiceListening.
  ///
  /// In en, this message translates to:
  /// **'Listening...'**
  String get cvUploadVoiceListening;

  /// No description provided for @cvUploadVoiceStop.
  ///
  /// In en, this message translates to:
  /// **'Tap to Stop'**
  String get cvUploadVoiceStop;

  /// No description provided for @cvUploadParsingTitle.
  ///
  /// In en, this message translates to:
  /// **'Building Your Profile'**
  String get cvUploadParsingTitle;

  /// No description provided for @cvUploadSuccess.
  ///
  /// In en, this message translates to:
  /// **'Profile imported successfully!'**
  String get cvUploadSuccess;

  /// No description provided for @cvUploadReplace.
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get cvUploadReplace;

  /// No description provided for @cvUploadImported.
  ///
  /// In en, this message translates to:
  /// **'CV Imported'**
  String get cvUploadImported;

  /// No description provided for @cvUploadImportedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your profile is ready. You can re-import to update.'**
  String get cvUploadImportedSubtitle;

  /// No description provided for @jobMatchTitle.
  ///
  /// In en, this message translates to:
  /// **'Job Matching'**
  String get jobMatchTitle;

  /// No description provided for @jobMatchPasteJd.
  ///
  /// In en, this message translates to:
  /// **'Paste Job Description'**
  String get jobMatchPasteJd;

  /// No description provided for @jobMatchJdHint.
  ///
  /// In en, this message translates to:
  /// **'Paste the full job description here...'**
  String get jobMatchJdHint;

  /// No description provided for @jobMatchAnalyze.
  ///
  /// In en, this message translates to:
  /// **'Analyze Match'**
  String get jobMatchAnalyze;

  /// No description provided for @jobMatchScore.
  ///
  /// In en, this message translates to:
  /// **'Match Score'**
  String get jobMatchScore;

  /// No description provided for @jobMatchStrong.
  ///
  /// In en, this message translates to:
  /// **'Strong Match'**
  String get jobMatchStrong;

  /// No description provided for @jobMatchPartial.
  ///
  /// In en, this message translates to:
  /// **'Partial Match'**
  String get jobMatchPartial;

  /// No description provided for @jobMatchWeak.
  ///
  /// In en, this message translates to:
  /// **'Weak Match'**
  String get jobMatchWeak;

  /// No description provided for @jobMatchingSkills.
  ///
  /// In en, this message translates to:
  /// **'Matching Skills'**
  String get jobMatchingSkills;

  /// No description provided for @jobMissingSkills.
  ///
  /// In en, this message translates to:
  /// **'Skills to Develop'**
  String get jobMissingSkills;

  /// No description provided for @jobMatchRecommendations.
  ///
  /// In en, this message translates to:
  /// **'Recommendations'**
  String get jobMatchRecommendations;

  /// No description provided for @jobMatchAddSkillHint.
  ///
  /// In en, this message translates to:
  /// **'Tap + to add missing skills to your resume'**
  String get jobMatchAddSkillHint;

  /// No description provided for @jobMatchApply.
  ///
  /// In en, this message translates to:
  /// **'Apply with Cover Letter'**
  String get jobMatchApply;

  /// No description provided for @jobMatchPrep.
  ///
  /// In en, this message translates to:
  /// **'Prep'**
  String get jobMatchPrep;

  /// No description provided for @jobMatchSkillAdded.
  ///
  /// In en, this message translates to:
  /// **'\"{skill}\" added to your profile'**
  String jobMatchSkillAdded(String skill);

  /// No description provided for @skillGapTitle.
  ///
  /// In en, this message translates to:
  /// **'Skill Gap Analysis'**
  String get skillGapTitle;

  /// No description provided for @skillGapLoading.
  ///
  /// In en, this message translates to:
  /// **'Analyzing your profile\nagainst the job...'**
  String get skillGapLoading;

  /// No description provided for @skillGapFailed.
  ///
  /// In en, this message translates to:
  /// **'Analysis Failed'**
  String get skillGapFailed;

  /// No description provided for @skillGapAiSummary.
  ///
  /// In en, this message translates to:
  /// **'AI Summary'**
  String get skillGapAiSummary;

  /// No description provided for @skillGapMatchingSkills.
  ///
  /// In en, this message translates to:
  /// **'Matching Skills'**
  String get skillGapMatchingSkills;

  /// No description provided for @skillGapSkillsToDevelop.
  ///
  /// In en, this message translates to:
  /// **'Skills to Develop'**
  String get skillGapSkillsToDevelop;

  /// No description provided for @skillGapRecommendations.
  ///
  /// In en, this message translates to:
  /// **'Recommendations'**
  String get skillGapRecommendations;

  /// No description provided for @skillGapMatchScore.
  ///
  /// In en, this message translates to:
  /// **'Match'**
  String get skillGapMatchScore;

  /// No description provided for @skillGapStrong.
  ///
  /// In en, this message translates to:
  /// **'Strong match for this role'**
  String get skillGapStrong;

  /// No description provided for @skillGapModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderate match — some gaps to fill'**
  String get skillGapModerate;

  /// No description provided for @skillGapWeak.
  ///
  /// In en, this message translates to:
  /// **'Several skills need development'**
  String get skillGapWeak;

  /// No description provided for @skillGapWriteCoverLetter.
  ///
  /// In en, this message translates to:
  /// **'Write Cover Letter'**
  String get skillGapWriteCoverLetter;

  /// No description provided for @skillGapPracticeInterview.
  ///
  /// In en, this message translates to:
  /// **'Practice Interview'**
  String get skillGapPracticeInterview;

  /// No description provided for @skillGapAddToResume.
  ///
  /// In en, this message translates to:
  /// **'Add to resume'**
  String get skillGapAddToResume;

  /// No description provided for @skillGapAddedToProfile.
  ///
  /// In en, this message translates to:
  /// **'Added to profile!'**
  String get skillGapAddedToProfile;

  /// No description provided for @mockInterviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Mock Interview'**
  String get mockInterviewTitle;

  /// No description provided for @mockInterviewLoading.
  ///
  /// In en, this message translates to:
  /// **'Preparing your interview...'**
  String get mockInterviewLoading;

  /// No description provided for @mockInterviewReadyTitle.
  ///
  /// In en, this message translates to:
  /// **'Interview Ready'**
  String get mockInterviewReadyTitle;

  /// No description provided for @mockInterviewReadySubtitle.
  ///
  /// In en, this message translates to:
  /// **'AI will ask you {count} questions. Answer as you would in a real interview.'**
  String mockInterviewReadySubtitle(int count);

  /// No description provided for @mockInterviewStart.
  ///
  /// In en, this message translates to:
  /// **'Start Interview'**
  String get mockInterviewStart;

  /// No description provided for @mockInterviewTypeAnswer.
  ///
  /// In en, this message translates to:
  /// **'Type your answer...'**
  String get mockInterviewTypeAnswer;

  /// No description provided for @mockInterviewSend.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get mockInterviewSend;

  /// No description provided for @mockInterviewThinking.
  ///
  /// In en, this message translates to:
  /// **'Thinking...'**
  String get mockInterviewThinking;

  /// No description provided for @mockInterviewFinish.
  ///
  /// In en, this message translates to:
  /// **'Finish Interview'**
  String get mockInterviewFinish;

  /// No description provided for @mockInterviewSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Session Summary'**
  String get mockInterviewSummaryTitle;

  /// No description provided for @mockInterviewScore.
  ///
  /// In en, this message translates to:
  /// **'Overall Score'**
  String get mockInterviewScore;

  /// No description provided for @mockInterviewStrong.
  ///
  /// In en, this message translates to:
  /// **'Strong'**
  String get mockInterviewStrong;

  /// No description provided for @mockInterviewGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get mockInterviewGood;

  /// No description provided for @mockInterviewWeak.
  ///
  /// In en, this message translates to:
  /// **'Needs Work'**
  String get mockInterviewWeak;

  /// No description provided for @mockInterviewQuestionsAnswered.
  ///
  /// In en, this message translates to:
  /// **'Questions Answered'**
  String get mockInterviewQuestionsAnswered;

  /// No description provided for @mockInterviewAverageScore.
  ///
  /// In en, this message translates to:
  /// **'Average Score'**
  String get mockInterviewAverageScore;

  /// No description provided for @mockInterviewWeakAreas.
  ///
  /// In en, this message translates to:
  /// **'Areas to Improve'**
  String get mockInterviewWeakAreas;

  /// No description provided for @mockInterviewNewSession.
  ///
  /// In en, this message translates to:
  /// **'New Session'**
  String get mockInterviewNewSession;

  /// No description provided for @mockInterviewGoHome.
  ///
  /// In en, this message translates to:
  /// **'Go Home'**
  String get mockInterviewGoHome;

  /// No description provided for @mockInterviewFeedbackLabel.
  ///
  /// In en, this message translates to:
  /// **'AI Feedback'**
  String get mockInterviewFeedbackLabel;

  /// No description provided for @mockInterviewQuestion.
  ///
  /// In en, this message translates to:
  /// **'Question {number} of {total}'**
  String mockInterviewQuestion(int number, int total);

  /// No description provided for @networkingTitle.
  ///
  /// In en, this message translates to:
  /// **'Networking Message'**
  String get networkingTitle;

  /// No description provided for @networkingGenerating.
  ///
  /// In en, this message translates to:
  /// **'Crafting your message...'**
  String get networkingGenerating;

  /// No description provided for @networkingFailed.
  ///
  /// In en, this message translates to:
  /// **'Generation Failed'**
  String get networkingFailed;

  /// No description provided for @networkingMessage.
  ///
  /// In en, this message translates to:
  /// **'Your Message'**
  String get networkingMessage;

  /// No description provided for @networkingCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy Message'**
  String get networkingCopy;

  /// No description provided for @networkingRegenerate.
  ///
  /// In en, this message translates to:
  /// **'Regenerate'**
  String get networkingRegenerate;

  /// No description provided for @networkingShorter.
  ///
  /// In en, this message translates to:
  /// **'Make Shorter'**
  String get networkingShorter;

  /// No description provided for @networkingLonger.
  ///
  /// In en, this message translates to:
  /// **'Make Longer'**
  String get networkingLonger;

  /// No description provided for @networkingTone.
  ///
  /// In en, this message translates to:
  /// **'Tone:'**
  String get networkingTone;

  /// No description provided for @networkingCopied.
  ///
  /// In en, this message translates to:
  /// **'Copied!'**
  String get networkingCopied;

  /// No description provided for @videoScriptTitle.
  ///
  /// In en, this message translates to:
  /// **'Video Script'**
  String get videoScriptTitle;

  /// No description provided for @videoScriptDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get videoScriptDuration;

  /// No description provided for @videoScript30s.
  ///
  /// In en, this message translates to:
  /// **'30 seconds'**
  String get videoScript30s;

  /// No description provided for @videoScript60s.
  ///
  /// In en, this message translates to:
  /// **'60 seconds'**
  String get videoScript60s;

  /// No description provided for @videoScript90s.
  ///
  /// In en, this message translates to:
  /// **'90 seconds'**
  String get videoScript90s;

  /// No description provided for @videoScriptTone.
  ///
  /// In en, this message translates to:
  /// **'Tone'**
  String get videoScriptTone;

  /// No description provided for @videoScriptGenerate.
  ///
  /// In en, this message translates to:
  /// **'Generate Script'**
  String get videoScriptGenerate;

  /// No description provided for @videoScriptResult.
  ///
  /// In en, this message translates to:
  /// **'Your Script'**
  String get videoScriptResult;

  /// No description provided for @videoScriptStartRecording.
  ///
  /// In en, this message translates to:
  /// **'Start Recording'**
  String get videoScriptStartRecording;

  /// No description provided for @videoScriptTeleprompter.
  ///
  /// In en, this message translates to:
  /// **'Open Teleprompter'**
  String get videoScriptTeleprompter;

  /// No description provided for @teleprompterTitle.
  ///
  /// In en, this message translates to:
  /// **'Teleprompter'**
  String get teleprompterTitle;

  /// No description provided for @teleprompterPlay.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get teleprompterPlay;

  /// No description provided for @teleprompterPause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get teleprompterPause;

  /// No description provided for @teleprompterReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get teleprompterReset;

  /// No description provided for @teleprompterSpeed.
  ///
  /// In en, this message translates to:
  /// **'Speed'**
  String get teleprompterSpeed;

  /// No description provided for @teleprompterFontSize.
  ///
  /// In en, this message translates to:
  /// **'Font Size'**
  String get teleprompterFontSize;

  /// No description provided for @teleprompterMirror.
  ///
  /// In en, this message translates to:
  /// **'Mirror'**
  String get teleprompterMirror;

  /// No description provided for @paywallTitle.
  ///
  /// In en, this message translates to:
  /// **'Unlock Premium'**
  String get paywallTitle;

  /// No description provided for @paywallSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get unlimited access to all AI tools'**
  String get paywallSubtitle;

  /// No description provided for @paywallWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get paywallWeekly;

  /// No description provided for @paywallMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get paywallMonthly;

  /// No description provided for @paywallAnnual.
  ///
  /// In en, this message translates to:
  /// **'Annual'**
  String get paywallAnnual;

  /// No description provided for @paywallSave.
  ///
  /// In en, this message translates to:
  /// **'Save {percent}%'**
  String paywallSave(int percent);

  /// No description provided for @paywallSubscribe.
  ///
  /// In en, this message translates to:
  /// **'Start Free Trial'**
  String get paywallSubscribe;

  /// No description provided for @paywallRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore Purchases'**
  String get paywallRestore;

  /// No description provided for @paywallTerms.
  ///
  /// In en, this message translates to:
  /// **'Terms & Privacy'**
  String get paywallTerms;

  /// No description provided for @paywallFeatureUnlimited.
  ///
  /// In en, this message translates to:
  /// **'Unlimited AI generations'**
  String get paywallFeatureUnlimited;

  /// No description provided for @paywallFeatureHistory.
  ///
  /// In en, this message translates to:
  /// **'Full history & documents'**
  String get paywallFeatureHistory;

  /// No description provided for @paywallFeaturePdf.
  ///
  /// In en, this message translates to:
  /// **'PDF export'**
  String get paywallFeaturePdf;

  /// No description provided for @paywallFeatureEarlyAccess.
  ///
  /// In en, this message translates to:
  /// **'Early access to new tools'**
  String get paywallFeatureEarlyAccess;

  /// No description provided for @chatTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Career Assistant'**
  String get chatTitle;

  /// No description provided for @chatInputHint.
  ///
  /// In en, this message translates to:
  /// **'Type a message...'**
  String get chatInputHint;

  /// No description provided for @chatVoiceInput.
  ///
  /// In en, this message translates to:
  /// **'Voice input'**
  String get chatVoiceInput;

  /// No description provided for @chatFlowResume.
  ///
  /// In en, this message translates to:
  /// **'Resume Builder'**
  String get chatFlowResume;

  /// No description provided for @chatFlowCoverLetter.
  ///
  /// In en, this message translates to:
  /// **'Cover Letter'**
  String get chatFlowCoverLetter;

  /// No description provided for @chatFlowInterview.
  ///
  /// In en, this message translates to:
  /// **'Interview Prep'**
  String get chatFlowInterview;

  /// No description provided for @chatFlowCvUpload.
  ///
  /// In en, this message translates to:
  /// **'CV Import'**
  String get chatFlowCvUpload;

  /// No description provided for @chatFlowJobMatch.
  ///
  /// In en, this message translates to:
  /// **'Job Matching'**
  String get chatFlowJobMatch;

  /// No description provided for @chatFlowVideoIntro.
  ///
  /// In en, this message translates to:
  /// **'Video Introduction'**
  String get chatFlowVideoIntro;

  /// No description provided for @chatFlowSkillGap.
  ///
  /// In en, this message translates to:
  /// **'Skill Gap Analysis'**
  String get chatFlowSkillGap;

  /// No description provided for @chatFlowMockInterview.
  ///
  /// In en, this message translates to:
  /// **'Mock Interview'**
  String get chatFlowMockInterview;

  /// No description provided for @chatFlowNetworking.
  ///
  /// In en, this message translates to:
  /// **'Networking Message'**
  String get chatFlowNetworking;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorGeneric;

  /// No description provided for @errorNetwork.
  ///
  /// In en, this message translates to:
  /// **'Network error. Check your connection.'**
  String get errorNetwork;

  /// No description provided for @errorApiKey.
  ///
  /// In en, this message translates to:
  /// **'API key not configured.'**
  String get errorApiKey;

  /// No description provided for @errorNoCV.
  ///
  /// In en, this message translates to:
  /// **'No CV uploaded. Please import your profile first.'**
  String get errorNoCV;

  /// No description provided for @errorEmptyField.
  ///
  /// In en, this message translates to:
  /// **'This field cannot be empty.'**
  String get errorEmptyField;

  /// No description provided for @errorInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address.'**
  String get errorInvalidEmail;

  /// No description provided for @aiLoadingAnalyzingJob.
  ///
  /// In en, this message translates to:
  /// **'Analyzing job requirements...'**
  String get aiLoadingAnalyzingJob;

  /// No description provided for @aiLoadingComparingProfile.
  ///
  /// In en, this message translates to:
  /// **'Comparing with your profile...'**
  String get aiLoadingComparingProfile;

  /// No description provided for @aiLoadingCalculatingScore.
  ///
  /// In en, this message translates to:
  /// **'Calculating match score...'**
  String get aiLoadingCalculatingScore;

  /// No description provided for @aiLoadingAnalyzingRole.
  ///
  /// In en, this message translates to:
  /// **'Analyzing role requirements...'**
  String get aiLoadingAnalyzingRole;

  /// No description provided for @aiLoadingGeneratingTechnical.
  ///
  /// In en, this message translates to:
  /// **'Generating technical questions...'**
  String get aiLoadingGeneratingTechnical;

  /// No description provided for @aiLoadingCraftingBehavioral.
  ///
  /// In en, this message translates to:
  /// **'Crafting behavioral questions...'**
  String get aiLoadingCraftingBehavioral;

  /// No description provided for @aiLoadingAnalyzingJd.
  ///
  /// In en, this message translates to:
  /// **'Analyzing job description...'**
  String get aiLoadingAnalyzingJd;

  /// No description provided for @aiLoadingMatchingProfile.
  ///
  /// In en, this message translates to:
  /// **'Matching your profile...'**
  String get aiLoadingMatchingProfile;

  /// No description provided for @aiLoadingCraftingLetter.
  ///
  /// In en, this message translates to:
  /// **'Crafting your cover letter...'**
  String get aiLoadingCraftingLetter;

  /// No description provided for @aiLoadingReviewingExp.
  ///
  /// In en, this message translates to:
  /// **'Reviewing your experience...'**
  String get aiLoadingReviewingExp;

  /// No description provided for @aiLoadingIdentifyingSkills.
  ///
  /// In en, this message translates to:
  /// **'Identifying key skills...'**
  String get aiLoadingIdentifyingSkills;

  /// No description provided for @aiLoadingWritingSummary.
  ///
  /// In en, this message translates to:
  /// **'Writing your summary...'**
  String get aiLoadingWritingSummary;

  /// No description provided for @aiLoadingReadingCv.
  ///
  /// In en, this message translates to:
  /// **'Reading your CV...'**
  String get aiLoadingReadingCv;

  /// No description provided for @aiLoadingExtractingSkills.
  ///
  /// In en, this message translates to:
  /// **'Extracting skills...'**
  String get aiLoadingExtractingSkills;

  /// No description provided for @aiLoadingBuildingProfile.
  ///
  /// In en, this message translates to:
  /// **'Building your profile...'**
  String get aiLoadingBuildingProfile;

  /// No description provided for @aiLoadingAnalyzingProfile.
  ///
  /// In en, this message translates to:
  /// **'Analyzing your profile...'**
  String get aiLoadingAnalyzingProfile;

  /// No description provided for @aiLoadingCraftingIntro.
  ///
  /// In en, this message translates to:
  /// **'Crafting your intro...'**
  String get aiLoadingCraftingIntro;

  /// No description provided for @aiLoadingPolishingScript.
  ///
  /// In en, this message translates to:
  /// **'Polishing the script...'**
  String get aiLoadingPolishingScript;

  /// No description provided for @chatFlowAiPhoto.
  ///
  /// In en, this message translates to:
  /// **'AI Photo Studio'**
  String get chatFlowAiPhoto;

  /// No description provided for @chatFlowJobPlan.
  ///
  /// In en, this message translates to:
  /// **'Apply to Job'**
  String get chatFlowJobPlan;

  /// No description provided for @chatGreetingResume.
  ///
  /// In en, this message translates to:
  /// **'Hi! I\'m your AI Resume Coach. I\'ll build you an ATS-optimized resume step by step. Let\'s get started!'**
  String get chatGreetingResume;

  /// No description provided for @chatGreetingCoverLetter.
  ///
  /// In en, this message translates to:
  /// **'Let\'s write a cover letter that gets you noticed! I\'ll tailor it to the exact job posting.'**
  String get chatGreetingCoverLetter;

  /// No description provided for @chatGreetingInterview.
  ///
  /// In en, this message translates to:
  /// **'Time to ace your interview! I\'ll generate tailored questions with coaching tips so you feel confident.'**
  String get chatGreetingInterview;

  /// No description provided for @chatGreetingCvUpload.
  ///
  /// In en, this message translates to:
  /// **'I\'ll extract your experience, skills, and education from your CV and build your profile automatically.'**
  String get chatGreetingCvUpload;

  /// No description provided for @chatGreetingJobMatch.
  ///
  /// In en, this message translates to:
  /// **'Let\'s see how well you match this job! I\'ll highlight matching and missing skills in seconds.'**
  String get chatGreetingJobMatch;

  /// No description provided for @chatGreetingVideoIntro.
  ///
  /// In en, this message translates to:
  /// **'Let\'s create a script for your video cover letter! I\'ll write it to match your personality and the role.'**
  String get chatGreetingVideoIntro;

  /// No description provided for @chatGreetingSkillGap.
  ///
  /// In en, this message translates to:
  /// **'I\'ll analyze the job requirements and show you exactly what skills to focus on.'**
  String get chatGreetingSkillGap;

  /// No description provided for @chatGreetingMockInterview.
  ///
  /// In en, this message translates to:
  /// **'Practice makes perfect! I\'ll ask you real interview questions and give you instant AI feedback.'**
  String get chatGreetingMockInterview;

  /// No description provided for @chatGreetingNetworking.
  ///
  /// In en, this message translates to:
  /// **'Let\'s write a message that actually gets a reply! I\'ll tailor it to your specific situation.'**
  String get chatGreetingNetworking;

  /// No description provided for @chatGreetingAiPhoto.
  ///
  /// In en, this message translates to:
  /// **'Welcome to AI Photo Studio! Let me show you what\'s possible.'**
  String get chatGreetingAiPhoto;

  /// No description provided for @chatGreetingJobPlan.
  ///
  /// In en, this message translates to:
  /// **'Let me create your complete job application plan! Paste a job description and I\'ll analyze your fit, find skill gaps, and set up everything you need to land this role.'**
  String get chatGreetingJobPlan;

  /// No description provided for @chatGreetingNone.
  ///
  /// In en, this message translates to:
  /// **'Hi! I\'m your AI Career Assistant. What would you like to work on today?'**
  String get chatGreetingNone;

  /// No description provided for @chatResumeQ1.
  ///
  /// In en, this message translates to:
  /// **'Let\'s build your resume! Do you have an existing CV?'**
  String get chatResumeQ1;

  /// No description provided for @chatResumeChipFromScratch.
  ///
  /// In en, this message translates to:
  /// **'Start from scratch'**
  String get chatResumeChipFromScratch;

  /// No description provided for @chatResumeChipUploadPdf.
  ///
  /// In en, this message translates to:
  /// **'Upload PDF'**
  String get chatResumeChipUploadPdf;

  /// No description provided for @chatResumeChipPasteLinkedIn.
  ///
  /// In en, this message translates to:
  /// **'Paste LinkedIn URL'**
  String get chatResumeChipPasteLinkedIn;

  /// No description provided for @chatResumeQ2.
  ///
  /// In en, this message translates to:
  /// **'What\'s your target role? (e.g. Flutter Developer, Product Manager)'**
  String get chatResumeQ2;

  /// No description provided for @chatResumeQ3.
  ///
  /// In en, this message translates to:
  /// **'How many years of experience do you have?'**
  String get chatResumeQ3;

  /// No description provided for @chatResumeChipExp02.
  ///
  /// In en, this message translates to:
  /// **'0–2 years'**
  String get chatResumeChipExp02;

  /// No description provided for @chatResumeChipExp35.
  ///
  /// In en, this message translates to:
  /// **'3–5 years'**
  String get chatResumeChipExp35;

  /// No description provided for @chatResumeChipExp510.
  ///
  /// In en, this message translates to:
  /// **'5–10 years'**
  String get chatResumeChipExp510;

  /// No description provided for @chatResumeChipExp10Plus.
  ///
  /// In en, this message translates to:
  /// **'10+ years'**
  String get chatResumeChipExp10Plus;

  /// No description provided for @chatResumeQ4.
  ///
  /// In en, this message translates to:
  /// **'Tell me about your most recent job — company, title, and key achievements.'**
  String get chatResumeQ4;

  /// No description provided for @chatResumeQ5.
  ///
  /// In en, this message translates to:
  /// **'What are your top skills? (e.g. Flutter, Python, Leadership)'**
  String get chatResumeQ5;

  /// No description provided for @chatResumeChipManagement.
  ///
  /// In en, this message translates to:
  /// **'Management'**
  String get chatResumeChipManagement;

  /// No description provided for @chatResumeChipDataAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Data Analysis'**
  String get chatResumeChipDataAnalysis;

  /// No description provided for @chatResumeChipMarketing.
  ///
  /// In en, this message translates to:
  /// **'Marketing'**
  String get chatResumeChipMarketing;

  /// No description provided for @chatResumeQ6.
  ///
  /// In en, this message translates to:
  /// **'What\'s your educational background? (degree, field, school)'**
  String get chatResumeQ6;

  /// No description provided for @chatResumeComplete.
  ///
  /// In en, this message translates to:
  /// **'Perfect! I have everything I need to build your resume. Tap below to generate your ATS-optimized resume!'**
  String get chatResumeComplete;

  /// No description provided for @chatResumeCompleteChip.
  ///
  /// In en, this message translates to:
  /// **'[GO] Build My Resume'**
  String get chatResumeCompleteChip;

  /// No description provided for @chatResumeGenerate.
  ///
  /// In en, this message translates to:
  /// **'Opening Resume Builder with your info pre-filled...'**
  String get chatResumeGenerate;

  /// No description provided for @chatCoverLetterQ1.
  ///
  /// In en, this message translates to:
  /// **'Let\'s write your cover letter! What company are you applying to?'**
  String get chatCoverLetterQ1;

  /// No description provided for @chatCoverLetterQ2.
  ///
  /// In en, this message translates to:
  /// **'What\'s the role / position title?'**
  String get chatCoverLetterQ2;

  /// No description provided for @chatCoverLetterQ3.
  ///
  /// In en, this message translates to:
  /// **'Paste the job description — I\'ll tailor your letter to match it exactly:'**
  String get chatCoverLetterQ3;

  /// No description provided for @chatCoverLetterQ4.
  ///
  /// In en, this message translates to:
  /// **'What tone should your cover letter have?'**
  String get chatCoverLetterQ4;

  /// No description provided for @chatCoverLetterChipProfessional.
  ///
  /// In en, this message translates to:
  /// **'Professional'**
  String get chatCoverLetterChipProfessional;

  /// No description provided for @chatCoverLetterChipFriendly.
  ///
  /// In en, this message translates to:
  /// **'Friendly'**
  String get chatCoverLetterChipFriendly;

  /// No description provided for @chatCoverLetterChipConfident.
  ///
  /// In en, this message translates to:
  /// **'Confident'**
  String get chatCoverLetterChipConfident;

  /// No description provided for @chatCoverLetterComplete.
  ///
  /// In en, this message translates to:
  /// **'All set! I have your info. Tap below to generate your personalized cover letter.'**
  String get chatCoverLetterComplete;

  /// No description provided for @chatCoverLetterCompleteChip.
  ///
  /// In en, this message translates to:
  /// **'[GO] Generate Cover Letter'**
  String get chatCoverLetterCompleteChip;

  /// No description provided for @chatCoverLetterGenerate.
  ///
  /// In en, this message translates to:
  /// **'Generating your personalized cover letter...'**
  String get chatCoverLetterGenerate;

  /// No description provided for @chatInterviewQ1.
  ///
  /// In en, this message translates to:
  /// **'Let\'s prep you for your interview! What role are you interviewing for?'**
  String get chatInterviewQ1;

  /// No description provided for @chatInterviewQ2.
  ///
  /// In en, this message translates to:
  /// **'What seniority level is the position?'**
  String get chatInterviewQ2;

  /// No description provided for @chatInterviewChipJunior.
  ///
  /// In en, this message translates to:
  /// **'Junior'**
  String get chatInterviewChipJunior;

  /// No description provided for @chatInterviewChipMidLevel.
  ///
  /// In en, this message translates to:
  /// **'Mid-level'**
  String get chatInterviewChipMidLevel;

  /// No description provided for @chatInterviewChipSenior.
  ///
  /// In en, this message translates to:
  /// **'Senior'**
  String get chatInterviewChipSenior;

  /// No description provided for @chatInterviewChipLead.
  ///
  /// In en, this message translates to:
  /// **'Lead'**
  String get chatInterviewChipLead;

  /// No description provided for @chatInterviewQ3.
  ///
  /// In en, this message translates to:
  /// **'What type of questions do you want to focus on?'**
  String get chatInterviewQ3;

  /// No description provided for @chatInterviewChipTechnical.
  ///
  /// In en, this message translates to:
  /// **'Technical'**
  String get chatInterviewChipTechnical;

  /// No description provided for @chatInterviewChipBehavioral.
  ///
  /// In en, this message translates to:
  /// **'Behavioral'**
  String get chatInterviewChipBehavioral;

  /// No description provided for @chatInterviewChipSystemDesign.
  ///
  /// In en, this message translates to:
  /// **'System Design'**
  String get chatInterviewChipSystemDesign;

  /// No description provided for @chatInterviewChipAllAbove.
  ///
  /// In en, this message translates to:
  /// **'All of the above'**
  String get chatInterviewChipAllAbove;

  /// No description provided for @chatInterviewComplete.
  ///
  /// In en, this message translates to:
  /// **'Great! I\'m ready to generate your interview questions with expert coaching tips.'**
  String get chatInterviewComplete;

  /// No description provided for @chatInterviewCompleteChip.
  ///
  /// In en, this message translates to:
  /// **'[GO] Generate Questions'**
  String get chatInterviewCompleteChip;

  /// No description provided for @chatInterviewGenerate.
  ///
  /// In en, this message translates to:
  /// **'Generating your interview questions with coaching tips...'**
  String get chatInterviewGenerate;

  /// No description provided for @chatCvUploadQ1.
  ///
  /// In en, this message translates to:
  /// **'Let\'s import your career info! How would you like to share it?'**
  String get chatCvUploadQ1;

  /// No description provided for @chatCvUploadChipPdf.
  ///
  /// In en, this message translates to:
  /// **'Upload PDF / DOC'**
  String get chatCvUploadChipPdf;

  /// No description provided for @chatCvUploadChipLinkedIn.
  ///
  /// In en, this message translates to:
  /// **'Paste LinkedIn URL'**
  String get chatCvUploadChipLinkedIn;

  /// No description provided for @chatCvUploadChipPaste.
  ///
  /// In en, this message translates to:
  /// **'Copy-paste text'**
  String get chatCvUploadChipPaste;

  /// No description provided for @chatCvUploadChipVoice.
  ///
  /// In en, this message translates to:
  /// **'Tell me by voice'**
  String get chatCvUploadChipVoice;

  /// No description provided for @chatCvUploadComplete.
  ///
  /// In en, this message translates to:
  /// **'Your CV has been processed! Opening CV Import...'**
  String get chatCvUploadComplete;

  /// No description provided for @chatCvMethodPdf.
  ///
  /// In en, this message translates to:
  /// **'Tap the attachment icon below to pick your PDF or DOC file.'**
  String get chatCvMethodPdf;

  /// No description provided for @chatCvMethodFileChip.
  ///
  /// In en, this message translates to:
  /// **'Choose file'**
  String get chatCvMethodFileChip;

  /// No description provided for @chatCvMethodLinkedIn.
  ///
  /// In en, this message translates to:
  /// **'Paste your LinkedIn profile URL below:'**
  String get chatCvMethodLinkedIn;

  /// No description provided for @chatCvMethodPaste.
  ///
  /// In en, this message translates to:
  /// **'Paste your CV text below and I\'ll extract your information:'**
  String get chatCvMethodPaste;

  /// No description provided for @chatCvMethodVoice.
  ///
  /// In en, this message translates to:
  /// **'Tell me about yourself — your experience, skills, education, and what you\'re looking for:'**
  String get chatCvMethodVoice;

  /// No description provided for @chatCvParsedHeader.
  ///
  /// In en, this message translates to:
  /// **'I\'ve read your CV.'**
  String get chatCvParsedHeader;

  /// No description provided for @chatCvParsedExperiences.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 work experience} other{{count} work experiences}}'**
  String chatCvParsedExperiences(int count);

  /// No description provided for @chatCvParsedSkills.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 skill: {shown}} other{{count} skills: {shown}}}'**
  String chatCvParsedSkills(int count, String shown);

  /// No description provided for @chatCvParsedEducation.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 education entry} other{{count} education entries}}'**
  String chatCvParsedEducation(int count);

  /// No description provided for @chatCvParsedQuestion.
  ///
  /// In en, this message translates to:
  /// **'Shall we continue building your resume?'**
  String get chatCvParsedQuestion;

  /// No description provided for @chatCvParsedContinueChip.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get chatCvParsedContinueChip;

  /// No description provided for @chatLinkedInDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Paste LinkedIn URL'**
  String get chatLinkedInDialogTitle;

  /// No description provided for @chatLinkedInDialogHint.
  ///
  /// In en, this message translates to:
  /// **'https://linkedin.com/in/your-name'**
  String get chatLinkedInDialogHint;

  /// No description provided for @chatLinkedInDialogConfirm.
  ///
  /// In en, this message translates to:
  /// **'Use URL'**
  String get chatLinkedInDialogConfirm;

  /// No description provided for @chatLinkedInReceived.
  ///
  /// In en, this message translates to:
  /// **'Got it. I\'ve added your LinkedIn URL to your profile.'**
  String get chatLinkedInReceived;

  /// No description provided for @chatCvParseFailed.
  ///
  /// In en, this message translates to:
  /// **'I couldn\'t parse this file. Please try another one or start from scratch.'**
  String get chatCvParseFailed;

  /// No description provided for @chatJobMatchQ1.
  ///
  /// In en, this message translates to:
  /// **'Paste the job description you\'re interested in and I\'ll match it against your profile:'**
  String get chatJobMatchQ1;

  /// No description provided for @chatJobMatchComplete.
  ///
  /// In en, this message translates to:
  /// **'Analyzing the job description against your profile...'**
  String get chatJobMatchComplete;

  /// No description provided for @chatVideoQ1.
  ///
  /// In en, this message translates to:
  /// **'Let\'s create your video intro script! What role are you applying for?'**
  String get chatVideoQ1;

  /// No description provided for @chatVideoQ2.
  ///
  /// In en, this message translates to:
  /// **'How long should your video be?'**
  String get chatVideoQ2;

  /// No description provided for @chatVideoChip30s.
  ///
  /// In en, this message translates to:
  /// **'30 seconds'**
  String get chatVideoChip30s;

  /// No description provided for @chatVideoChip60s.
  ///
  /// In en, this message translates to:
  /// **'60 seconds'**
  String get chatVideoChip60s;

  /// No description provided for @chatVideoChip90s.
  ///
  /// In en, this message translates to:
  /// **'90 seconds'**
  String get chatVideoChip90s;

  /// No description provided for @chatVideoQ3.
  ///
  /// In en, this message translates to:
  /// **'What tone do you want?'**
  String get chatVideoQ3;

  /// No description provided for @chatVideoChipFormal.
  ///
  /// In en, this message translates to:
  /// **'Formal'**
  String get chatVideoChipFormal;

  /// No description provided for @chatVideoChipCasual.
  ///
  /// In en, this message translates to:
  /// **'Casual'**
  String get chatVideoChipCasual;

  /// No description provided for @chatVideoChipConfident.
  ///
  /// In en, this message translates to:
  /// **'Confident'**
  String get chatVideoChipConfident;

  /// No description provided for @chatVideoComplete.
  ///
  /// In en, this message translates to:
  /// **'Your script is almost ready! Tap to generate it.'**
  String get chatVideoComplete;

  /// No description provided for @chatVideoCompleteChip.
  ///
  /// In en, this message translates to:
  /// **'[GO] Generate Script'**
  String get chatVideoCompleteChip;

  /// No description provided for @chatVideoGenerate.
  ///
  /// In en, this message translates to:
  /// **'Generating your video script...'**
  String get chatVideoGenerate;

  /// No description provided for @chatSkillGapQ1.
  ///
  /// In en, this message translates to:
  /// **'Paste the job description you\'re targeting and I\'ll identify your skill gaps:'**
  String get chatSkillGapQ1;

  /// No description provided for @chatSkillGapComplete.
  ///
  /// In en, this message translates to:
  /// **'Analyzing the job requirements against your profile...'**
  String get chatSkillGapComplete;

  /// No description provided for @chatMockQ1.
  ///
  /// In en, this message translates to:
  /// **'Ready to practice? What role are you preparing for?'**
  String get chatMockQ1;

  /// No description provided for @chatMockQ2.
  ///
  /// In en, this message translates to:
  /// **'What seniority level?'**
  String get chatMockQ2;

  /// No description provided for @chatMockComplete.
  ///
  /// In en, this message translates to:
  /// **'Ready to start your practice session!'**
  String get chatMockComplete;

  /// No description provided for @chatMockCompleteChip.
  ///
  /// In en, this message translates to:
  /// **'[GO] Start Practice'**
  String get chatMockCompleteChip;

  /// No description provided for @chatMockGenerate.
  ///
  /// In en, this message translates to:
  /// **'Starting your practice session...'**
  String get chatMockGenerate;

  /// No description provided for @chatNetQ1.
  ///
  /// In en, this message translates to:
  /// **'I\'ll help you write a networking message! What type do you need?'**
  String get chatNetQ1;

  /// No description provided for @chatNetChipColdOutreach.
  ///
  /// In en, this message translates to:
  /// **'Cold outreach'**
  String get chatNetChipColdOutreach;

  /// No description provided for @chatNetChipThankYou.
  ///
  /// In en, this message translates to:
  /// **'Thank you note'**
  String get chatNetChipThankYou;

  /// No description provided for @chatNetChipFollowUp.
  ///
  /// In en, this message translates to:
  /// **'Follow-up'**
  String get chatNetChipFollowUp;

  /// No description provided for @chatNetChipReferral.
  ///
  /// In en, this message translates to:
  /// **'Referral request'**
  String get chatNetChipReferral;

  /// No description provided for @chatNetChipLinkedIn.
  ///
  /// In en, this message translates to:
  /// **'LinkedIn connection'**
  String get chatNetChipLinkedIn;

  /// No description provided for @chatNetQ2.
  ///
  /// In en, this message translates to:
  /// **'Who are you reaching out to? (Name, role, company — e.g. \'Sarah, Senior PM at Stripe\')'**
  String get chatNetQ2;

  /// No description provided for @chatNetQ3.
  ///
  /// In en, this message translates to:
  /// **'Any personal connection or context you\'d like me to include? (or type \'none\')'**
  String get chatNetQ3;

  /// No description provided for @chatNetQ4.
  ///
  /// In en, this message translates to:
  /// **'What tone would you prefer?'**
  String get chatNetQ4;

  /// No description provided for @chatNetChipProfessional.
  ///
  /// In en, this message translates to:
  /// **'Professional'**
  String get chatNetChipProfessional;

  /// No description provided for @chatNetChipFriendly.
  ///
  /// In en, this message translates to:
  /// **'Friendly'**
  String get chatNetChipFriendly;

  /// No description provided for @chatNetChipBrief.
  ///
  /// In en, this message translates to:
  /// **'Brief'**
  String get chatNetChipBrief;

  /// No description provided for @chatNetComplete.
  ///
  /// In en, this message translates to:
  /// **'I have everything I need! Let me write your message.'**
  String get chatNetComplete;

  /// No description provided for @chatNetCompleteChip.
  ///
  /// In en, this message translates to:
  /// **'[GO] Generate Message'**
  String get chatNetCompleteChip;

  /// No description provided for @chatNetGenerate.
  ///
  /// In en, this message translates to:
  /// **'Writing your networking message...'**
  String get chatNetGenerate;

  /// No description provided for @chatJobPlanQ1.
  ///
  /// In en, this message translates to:
  /// **'Paste the job description below and I\'ll create your complete application plan!'**
  String get chatJobPlanQ1;

  /// No description provided for @chatJobPlanComplete.
  ///
  /// In en, this message translates to:
  /// **'Got it! I have the job description. Tap below to create your complete application plan!'**
  String get chatJobPlanComplete;

  /// No description provided for @chatJobPlanCompleteChip.
  ///
  /// In en, this message translates to:
  /// **'[GO] Create My Application Plan'**
  String get chatJobPlanCompleteChip;

  /// No description provided for @chatJobPlanGenAnalyzing.
  ///
  /// In en, this message translates to:
  /// **'Analyzing job requirements...'**
  String get chatJobPlanGenAnalyzing;

  /// No description provided for @chatJobPlanGenMatching.
  ///
  /// In en, this message translates to:
  /// **'Matching your profile...'**
  String get chatJobPlanGenMatching;

  /// No description provided for @chatJobPlanGenCreating.
  ///
  /// In en, this message translates to:
  /// **'Creating your application plan...'**
  String get chatJobPlanGenCreating;

  /// No description provided for @chatNoneComplete.
  ///
  /// In en, this message translates to:
  /// **'How else can I help you?'**
  String get chatNoneComplete;

  /// No description provided for @chatPaywallPhotoPreview.
  ///
  /// In en, this message translates to:
  /// **'Here\'s a preview of what AI Photo Studio can do for your career:'**
  String get chatPaywallPhotoPreview;

  /// No description provided for @chatPaywallPhotoFeatures.
  ///
  /// In en, this message translates to:
  /// **'Transform any selfie into a professional headshot\n6 industry-specific styles (Corporate, Tech, Creative...)\nResults in under 30 seconds\n\nThis is a Pro feature. Start your 3-day free trial to unlock it!'**
  String get chatPaywallPhotoFeatures;

  /// No description provided for @chatPaywallPhotoChip.
  ///
  /// In en, this message translates to:
  /// **'[PRO] Unlock Photo Studio — Free Trial'**
  String get chatPaywallPhotoChip;

  /// No description provided for @chatPaywallPhotoOpening.
  ///
  /// In en, this message translates to:
  /// **'Opening AI Photo Studio...'**
  String get chatPaywallPhotoOpening;

  /// No description provided for @chatPaywallMockInterview.
  ///
  /// In en, this message translates to:
  /// **'Mock Interview lets you practice with an AI interviewer and get real-time feedback on every answer.\n\nThis is a Pro feature. Unlock it with a free 3-day trial!'**
  String get chatPaywallMockInterview;

  /// No description provided for @chatPaywallMockInterviewChip.
  ///
  /// In en, this message translates to:
  /// **'[PRO] Unlock Mock Interview — Free Trial'**
  String get chatPaywallMockInterviewChip;

  /// No description provided for @chatPaywallVideoIntro.
  ///
  /// In en, this message translates to:
  /// **'Video Cover Letter lets you create a 30-90 second professional video script with teleprompter.\n\nThis is a Pro feature. Unlock it with a free 3-day trial!'**
  String get chatPaywallVideoIntro;

  /// No description provided for @chatPaywallVideoIntroChip.
  ///
  /// In en, this message translates to:
  /// **'[PRO] Unlock Video Scripts — Free Trial'**
  String get chatPaywallVideoIntroChip;

  /// No description provided for @chatFallbackResume.
  ///
  /// In en, this message translates to:
  /// **'I can help you build a professional resume! Use the Resume tool to get started.'**
  String get chatFallbackResume;

  /// No description provided for @chatFallbackResumeChip.
  ///
  /// In en, this message translates to:
  /// **'Build My Resume'**
  String get chatFallbackResumeChip;

  /// No description provided for @chatFallbackCoverLetter.
  ///
  /// In en, this message translates to:
  /// **'I\'ll write a tailored cover letter for you!'**
  String get chatFallbackCoverLetter;

  /// No description provided for @chatFallbackCoverLetterChip.
  ///
  /// In en, this message translates to:
  /// **'Write Cover Letter'**
  String get chatFallbackCoverLetterChip;

  /// No description provided for @chatFallbackInterview.
  ///
  /// In en, this message translates to:
  /// **'I\'ll prepare you for your interview with targeted questions.'**
  String get chatFallbackInterview;

  /// No description provided for @chatFallbackInterviewChip.
  ///
  /// In en, this message translates to:
  /// **'Prep for Interview'**
  String get chatFallbackInterviewChip;

  /// No description provided for @chatFallbackGeneral.
  ///
  /// In en, this message translates to:
  /// **'I\'m your AI career assistant! What would you like to work on?'**
  String get chatFallbackGeneral;

  /// No description provided for @chatFallbackChipResume.
  ///
  /// In en, this message translates to:
  /// **'Build Resume'**
  String get chatFallbackChipResume;

  /// No description provided for @chatFallbackChipCoverLetter.
  ///
  /// In en, this message translates to:
  /// **'Write Cover Letter'**
  String get chatFallbackChipCoverLetter;

  /// No description provided for @chatFallbackChipInterview.
  ///
  /// In en, this message translates to:
  /// **'Prep for Interview'**
  String get chatFallbackChipInterview;

  /// No description provided for @chatFallbackChipNetworking.
  ///
  /// In en, this message translates to:
  /// **'Networking Message'**
  String get chatFallbackChipNetworking;

  /// No description provided for @videoScriptHeroTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Your Video Script'**
  String get videoScriptHeroTitle;

  /// No description provided for @videoScriptHeroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'AI-powered intro script for interviews'**
  String get videoScriptHeroSubtitle;

  /// No description provided for @videoScriptTargetRole.
  ///
  /// In en, this message translates to:
  /// **'Target Role'**
  String get videoScriptTargetRole;

  /// No description provided for @videoScriptTargetRoleHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Senior Flutter Developer'**
  String get videoScriptTargetRoleHint;

  /// No description provided for @videoScriptEnterRole.
  ///
  /// In en, this message translates to:
  /// **'Please enter a target role.'**
  String get videoScriptEnterRole;

  /// No description provided for @videoScriptKeyAchievement.
  ///
  /// In en, this message translates to:
  /// **'Key Achievement (optional)'**
  String get videoScriptKeyAchievement;

  /// No description provided for @videoScriptKeyAchievementHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Launched app with 500k+ downloads, led team of 8...'**
  String get videoScriptKeyAchievementHint;

  /// No description provided for @videoListTitle.
  ///
  /// In en, this message translates to:
  /// **'My Videos'**
  String get videoListTitle;

  /// No description provided for @videoListEmpty.
  ///
  /// In en, this message translates to:
  /// **'No recordings yet'**
  String get videoListEmpty;

  /// No description provided for @videoListGoToTeleprompter.
  ///
  /// In en, this message translates to:
  /// **'Go to Teleprompter'**
  String get videoListGoToTeleprompter;

  /// No description provided for @videoListDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Recording?'**
  String get videoListDeleteTitle;

  /// No description provided for @videoListDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get videoListDeleteMessage;

  /// No description provided for @videoListRecording.
  ///
  /// In en, this message translates to:
  /// **'Recording {date}'**
  String videoListRecording(String date);

  /// No description provided for @videoListPlaybackComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Video playback coming soon'**
  String get videoListPlaybackComingSoon;

  /// No description provided for @videoListPlay.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get videoListPlay;

  /// No description provided for @resumeError.
  ///
  /// In en, this message translates to:
  /// **'Error: {message}'**
  String resumeError(String message);

  /// No description provided for @resumeUpdated.
  ///
  /// In en, this message translates to:
  /// **'Updated {date}'**
  String resumeUpdated(String date);

  /// No description provided for @resumeWizardStepOf.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String resumeWizardStepOf(int current, int total);

  /// No description provided for @resumeWizardPrevious.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get resumeWizardPrevious;

  /// No description provided for @resumeWizardContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get resumeWizardContinue;

  /// No description provided for @resumeWizardSave.
  ///
  /// In en, this message translates to:
  /// **'Save Resume'**
  String get resumeWizardSave;

  /// No description provided for @speechNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Speech recognition not available'**
  String get speechNotAvailable;

  /// No description provided for @planProMax.
  ///
  /// In en, this message translates to:
  /// **'Pro Max'**
  String get planProMax;

  /// No description provided for @planPro.
  ///
  /// In en, this message translates to:
  /// **'Pro'**
  String get planPro;

  /// No description provided for @upgrade.
  ///
  /// In en, this message translates to:
  /// **'Upgrade'**
  String get upgrade;

  /// No description provided for @chipResume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get chipResume;

  /// No description provided for @chipCoverLetter.
  ///
  /// In en, this message translates to:
  /// **'Cover Letter'**
  String get chipCoverLetter;

  /// No description provided for @chipInterview.
  ///
  /// In en, this message translates to:
  /// **'Interview'**
  String get chipInterview;

  /// No description provided for @chipPhotoStudio.
  ///
  /// In en, this message translates to:
  /// **'Photo Studio'**
  String get chipPhotoStudio;

  /// No description provided for @chipNetworking.
  ///
  /// In en, this message translates to:
  /// **'Networking'**
  String get chipNetworking;

  /// No description provided for @chipUploadCv.
  ///
  /// In en, this message translates to:
  /// **'Upload CV'**
  String get chipUploadCv;

  /// No description provided for @cvUniversalImport.
  ///
  /// In en, this message translates to:
  /// **'Universal CV Import'**
  String get cvUniversalImport;

  /// No description provided for @cvImportMethod.
  ///
  /// In en, this message translates to:
  /// **'IMPORT METHOD'**
  String get cvImportMethod;

  /// No description provided for @cvLinkedInPdfExportTitle.
  ///
  /// In en, this message translates to:
  /// **'Upload LinkedIn PDF Export'**
  String get cvLinkedInPdfExportTitle;

  /// No description provided for @cvLinkedInPdfExportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Go to LinkedIn → More → Save to PDF'**
  String get cvLinkedInPdfExportSubtitle;

  /// No description provided for @cvLinkedInPdfExportButton.
  ///
  /// In en, this message translates to:
  /// **'Choose LinkedIn PDF'**
  String get cvLinkedInPdfExportButton;

  /// No description provided for @cvPasteLinkedInUrl.
  ///
  /// In en, this message translates to:
  /// **'Paste your LinkedIn URL'**
  String get cvPasteLinkedInUrl;

  /// No description provided for @cvLinkedInUrlExample.
  ///
  /// In en, this message translates to:
  /// **'e.g. linkedin.com/in/yourname'**
  String get cvLinkedInUrlExample;

  /// No description provided for @cvImportFromLinkedIn.
  ///
  /// In en, this message translates to:
  /// **'Import from LinkedIn'**
  String get cvImportFromLinkedIn;

  /// No description provided for @cvPasteYourText.
  ///
  /// In en, this message translates to:
  /// **'Paste your CV text'**
  String get cvPasteYourText;

  /// No description provided for @cvPasteYourTextSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Copy your CV content and paste it below'**
  String get cvPasteYourTextSubtitle;

  /// No description provided for @cvPasteHintLong.
  ///
  /// In en, this message translates to:
  /// **'Paste your CV text here...\n\nInclude your experience, skills, education and contact information for best results.'**
  String get cvPasteHintLong;

  /// No description provided for @cvPasteFromClipboard.
  ///
  /// In en, this message translates to:
  /// **'Paste from clipboard'**
  String get cvPasteFromClipboard;

  /// No description provided for @cvImport.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get cvImport;

  /// No description provided for @cvTellAiAboutCareer.
  ///
  /// In en, this message translates to:
  /// **'Tell AI about your career'**
  String get cvTellAiAboutCareer;

  /// No description provided for @cvSpeakNaturally.
  ///
  /// In en, this message translates to:
  /// **'Speak naturally about your experience, skills, and goals'**
  String get cvSpeakNaturally;

  /// No description provided for @cvBuildMyProfile.
  ///
  /// In en, this message translates to:
  /// **'Build my profile'**
  String get cvBuildMyProfile;

  /// No description provided for @cvProfileExtracted.
  ///
  /// In en, this message translates to:
  /// **'Profile extracted successfully'**
  String get cvProfileExtracted;

  /// No description provided for @cvImportDifferent.
  ///
  /// In en, this message translates to:
  /// **'Import different CV'**
  String get cvImportDifferent;

  /// No description provided for @cvExtractedProfile.
  ///
  /// In en, this message translates to:
  /// **'Extracted Profile'**
  String get cvExtractedProfile;

  /// No description provided for @cvSectionSkills.
  ///
  /// In en, this message translates to:
  /// **'SKILLS'**
  String get cvSectionSkills;

  /// No description provided for @cvSectionExperience.
  ///
  /// In en, this message translates to:
  /// **'EXPERIENCE'**
  String get cvSectionExperience;

  /// No description provided for @cvSectionEducation.
  ///
  /// In en, this message translates to:
  /// **'EDUCATION'**
  String get cvSectionEducation;

  /// No description provided for @cvUseThisProfile.
  ///
  /// In en, this message translates to:
  /// **'Use this profile'**
  String get cvUseThisProfile;

  /// No description provided for @deleteAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Account?'**
  String get deleteAccountTitle;

  /// No description provided for @deleteAccountContent.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete your account and all data. This action cannot be undone.'**
  String get deleteAccountContent;

  /// No description provided for @settingsAiOutputLanguage.
  ///
  /// In en, this message translates to:
  /// **'AI Output Language'**
  String get settingsAiOutputLanguage;

  /// No description provided for @settingsThemeSystemDefault.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get settingsThemeSystemDefault;

  /// No description provided for @settingsSubscription.
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
  String get settingsSubscription;

  /// No description provided for @settingsAboutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Powered by GPT, Gemini & Claude AI'**
  String get settingsAboutSubtitle;

  /// No description provided for @settingsAppVersion.
  ///
  /// In en, this message translates to:
  /// **'App Version'**
  String get settingsAppVersion;

  /// No description provided for @settingsDangerZone.
  ///
  /// In en, this message translates to:
  /// **'Danger Zone'**
  String get settingsDangerZone;

  /// No description provided for @settingsDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get settingsDeleteAccount;

  /// No description provided for @profileDemoUser.
  ///
  /// In en, this message translates to:
  /// **'Demo User'**
  String get profileDemoUser;

  /// No description provided for @profileProMaxPlan.
  ///
  /// In en, this message translates to:
  /// **'Pro Max Plan'**
  String get profileProMaxPlan;

  /// No description provided for @profileProPlan.
  ///
  /// In en, this message translates to:
  /// **'Pro Plan'**
  String get profileProPlan;

  /// No description provided for @profilePlanActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get profilePlanActive;

  /// No description provided for @profileUnlimitedPriority.
  ///
  /// In en, this message translates to:
  /// **'Unlimited AI + Priority Speed'**
  String get profileUnlimitedPriority;

  /// No description provided for @profileLimitedGenerations.
  ///
  /// In en, this message translates to:
  /// **'Limited generations remaining'**
  String get profileLimitedGenerations;

  /// No description provided for @profilePremiumMember.
  ///
  /// In en, this message translates to:
  /// **'Premium Member'**
  String get profilePremiumMember;

  /// No description provided for @profileManage.
  ///
  /// In en, this message translates to:
  /// **'Manage'**
  String get profileManage;

  /// No description provided for @profileAutoLanguage.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get profileAutoLanguage;

  /// No description provided for @profileLegal.
  ///
  /// In en, this message translates to:
  /// **'Legal'**
  String get profileLegal;

  /// No description provided for @profileEula.
  ///
  /// In en, this message translates to:
  /// **'EULA'**
  String get profileEula;

  /// No description provided for @profileTermsOfUse.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get profileTermsOfUse;

  /// No description provided for @profileHowToUse.
  ///
  /// In en, this message translates to:
  /// **'How do I use the app?'**
  String get profileHowToUse;

  /// No description provided for @profileRating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get profileRating;

  /// No description provided for @profileRateAppStore.
  ///
  /// In en, this message translates to:
  /// **'Rate us on App Store'**
  String get profileRateAppStore;

  /// No description provided for @profileFollowUs.
  ///
  /// In en, this message translates to:
  /// **'Follow Us'**
  String get profileFollowUs;

  /// No description provided for @profileFollowInstagram.
  ///
  /// In en, this message translates to:
  /// **'Follow us on Instagram'**
  String get profileFollowInstagram;

  /// No description provided for @profileFollowTikTok.
  ///
  /// In en, this message translates to:
  /// **'Follow us on TikTok'**
  String get profileFollowTikTok;

  /// No description provided for @profileFollowLinkedIn.
  ///
  /// In en, this message translates to:
  /// **'Follow us on LinkedIn'**
  String get profileFollowLinkedIn;

  /// No description provided for @profileFollowX.
  ///
  /// In en, this message translates to:
  /// **'Follow us on X'**
  String get profileFollowX;

  /// No description provided for @profileJoinDiscord.
  ///
  /// In en, this message translates to:
  /// **'Join our Discord'**
  String get profileJoinDiscord;

  /// No description provided for @profileAppVersionFull.
  ///
  /// In en, this message translates to:
  /// **'AI Career Copilot v1.0.0'**
  String get profileAppVersionFull;

  /// No description provided for @privacySectionTitle.
  ///
  /// In en, this message translates to:
  /// **'PRIVACY & AI'**
  String get privacySectionTitle;

  /// No description provided for @privacyAiDataProcessingTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Data Processing'**
  String get privacyAiDataProcessingTitle;

  /// No description provided for @privacyAiDataProcessingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Allow your inputs to be sent to AI providers'**
  String get privacyAiDataProcessingSubtitle;

  /// No description provided for @privacyPhotoProcessingTitle.
  ///
  /// In en, this message translates to:
  /// **'Photo AI Processing'**
  String get privacyPhotoProcessingTitle;

  /// No description provided for @privacyPhotoProcessingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Allow your photos to be processed by AI Photo Studio'**
  String get privacyPhotoProcessingSubtitle;

  /// No description provided for @privacyProviderDisclosureTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Provider Disclosure'**
  String get privacyProviderDisclosureTitle;

  /// No description provided for @privacyProviderDisclosureSubtitle.
  ///
  /// In en, this message translates to:
  /// **'View which AI services process your data'**
  String get privacyProviderDisclosureSubtitle;

  /// No description provided for @privacyProviderDisclosureHeader.
  ///
  /// In en, this message translates to:
  /// **'AI Providers'**
  String get privacyProviderDisclosureHeader;

  /// No description provided for @privacyProviderDisclosureBody.
  ///
  /// In en, this message translates to:
  /// **'Your data may be processed by the following AI providers when you use AI features. Each provider has its own privacy policy.'**
  String get privacyProviderDisclosureBody;

  /// No description provided for @consentAiDataTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Data Processing'**
  String get consentAiDataTitle;

  /// No description provided for @consentAiDataBody.
  ///
  /// In en, this message translates to:
  /// **'To generate your content, your input (role, experience, job description) will be sent to our AI providers for processing.\n\nWe do not store your data beyond what is necessary to provide the service. You can withdraw consent at any time in Settings → Privacy.'**
  String get consentAiDataBody;

  /// No description provided for @consentDecline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get consentDecline;

  /// No description provided for @consentAgree.
  ///
  /// In en, this message translates to:
  /// **'I Agree'**
  String get consentAgree;

  /// No description provided for @consentBiometricTitle.
  ///
  /// In en, this message translates to:
  /// **'Photo & AI Processing'**
  String get consentBiometricTitle;

  /// No description provided for @consentBiometricBody.
  ///
  /// In en, this message translates to:
  /// **'AI Photo Studio will process your photo to create a professional headshot.\n\n• Your photo is sent to an AI image provider.\n• The original photo is deleted from local storage after processing.\n• Generated headshots are NOT uploaded to our servers unless you explicitly save them to your profile.\n• We do not use your photo for training AI models.\n\nYou can withdraw consent at any time in Settings → Privacy.'**
  String get consentBiometricBody;

  /// No description provided for @navApplications.
  ///
  /// In en, this message translates to:
  /// **'Applications'**
  String get navApplications;

  /// No description provided for @applicationsTitle.
  ///
  /// In en, this message translates to:
  /// **'My Applications'**
  String get applicationsTitle;

  /// No description provided for @applicationsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No applications yet'**
  String get applicationsEmpty;

  /// No description provided for @applicationsEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Track your job applications in one place'**
  String get applicationsEmptySubtitle;

  /// No description provided for @applicationAddNew.
  ///
  /// In en, this message translates to:
  /// **'Track Application'**
  String get applicationAddNew;

  /// No description provided for @applicationStatusWishlist.
  ///
  /// In en, this message translates to:
  /// **'Wishlist'**
  String get applicationStatusWishlist;

  /// No description provided for @applicationStatusApplied.
  ///
  /// In en, this message translates to:
  /// **'Applied'**
  String get applicationStatusApplied;

  /// No description provided for @applicationStatusPhoneScreen.
  ///
  /// In en, this message translates to:
  /// **'Phone Screen'**
  String get applicationStatusPhoneScreen;

  /// No description provided for @applicationStatusInterview.
  ///
  /// In en, this message translates to:
  /// **'Interview'**
  String get applicationStatusInterview;

  /// No description provided for @applicationStatusOffer.
  ///
  /// In en, this message translates to:
  /// **'Offer'**
  String get applicationStatusOffer;

  /// No description provided for @applicationStatusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get applicationStatusRejected;

  /// No description provided for @applicationStatusWithdrawn.
  ///
  /// In en, this message translates to:
  /// **'Withdrawn'**
  String get applicationStatusWithdrawn;

  /// No description provided for @applicationFormTitle.
  ///
  /// In en, this message translates to:
  /// **'New Application'**
  String get applicationFormTitle;

  /// No description provided for @applicationFormEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Application'**
  String get applicationFormEditTitle;

  /// No description provided for @applicationFormCompany.
  ///
  /// In en, this message translates to:
  /// **'Company'**
  String get applicationFormCompany;

  /// No description provided for @applicationFormRole.
  ///
  /// In en, this message translates to:
  /// **'Role / Position'**
  String get applicationFormRole;

  /// No description provided for @applicationFormJobDescription.
  ///
  /// In en, this message translates to:
  /// **'Job Description (optional)'**
  String get applicationFormJobDescription;

  /// No description provided for @applicationFormNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get applicationFormNotes;

  /// No description provided for @applicationFormSource.
  ///
  /// In en, this message translates to:
  /// **'Source (LinkedIn, Referral…)'**
  String get applicationFormSource;

  /// No description provided for @applicationFormStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get applicationFormStatus;

  /// No description provided for @applicationFormFollowUp.
  ///
  /// In en, this message translates to:
  /// **'Follow-up Reminder'**
  String get applicationFormFollowUp;

  /// No description provided for @applicationFormFollowUpHint.
  ///
  /// In en, this message translates to:
  /// **'Set a follow-up reminder date'**
  String get applicationFormFollowUpHint;

  /// No description provided for @applicationFormSave.
  ///
  /// In en, this message translates to:
  /// **'Save Application'**
  String get applicationFormSave;

  /// No description provided for @applicationDetailStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get applicationDetailStatus;

  /// No description provided for @applicationDetailNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get applicationDetailNotes;

  /// No description provided for @applicationDetailTimeline.
  ///
  /// In en, this message translates to:
  /// **'Timeline'**
  String get applicationDetailTimeline;

  /// No description provided for @applicationDetailMatchScore.
  ///
  /// In en, this message translates to:
  /// **'Match Score'**
  String get applicationDetailMatchScore;

  /// No description provided for @applicationDetailFollowUp.
  ///
  /// In en, this message translates to:
  /// **'Follow-up'**
  String get applicationDetailFollowUp;

  /// No description provided for @applicationDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete Application'**
  String get applicationDeleteConfirm;

  /// No description provided for @applicationDeleteConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this application? This cannot be undone.'**
  String get applicationDeleteConfirmBody;

  /// No description provided for @applicationDeleteConfirmOk.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get applicationDeleteConfirmOk;

  /// No description provided for @applicationTrackFromPlan.
  ///
  /// In en, this message translates to:
  /// **'Track this Application'**
  String get applicationTrackFromPlan;

  /// No description provided for @applicationTrackFromPlanSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Save to your application tracker'**
  String get applicationTrackFromPlanSubtitle;

  /// No description provided for @applicationImportedFromPlan.
  ///
  /// In en, this message translates to:
  /// **'Imported from Job Plan'**
  String get applicationImportedFromPlan;
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
    'am',
    'ar',
    'bg',
    'bn',
    'ca',
    'cs',
    'da',
    'de',
    'el',
    'en',
    'es',
    'et',
    'fa',
    'fi',
    'fr',
    'he',
    'hi',
    'hr',
    'hu',
    'id',
    'it',
    'ja',
    'ka',
    'km',
    'ko',
    'lo',
    'lt',
    'lv',
    'ms',
    'my',
    'nb',
    'ne',
    'nl',
    'pl',
    'pt',
    'ro',
    'ru',
    'si',
    'sk',
    'sl',
    'sr',
    'sv',
    'sw',
    'th',
    'tl',
    'tr',
    'uk',
    'ur',
    'vi',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'am':
      return AppLocalizationsAm();
    case 'ar':
      return AppLocalizationsAr();
    case 'bg':
      return AppLocalizationsBg();
    case 'bn':
      return AppLocalizationsBn();
    case 'ca':
      return AppLocalizationsCa();
    case 'cs':
      return AppLocalizationsCs();
    case 'da':
      return AppLocalizationsDa();
    case 'de':
      return AppLocalizationsDe();
    case 'el':
      return AppLocalizationsEl();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'et':
      return AppLocalizationsEt();
    case 'fa':
      return AppLocalizationsFa();
    case 'fi':
      return AppLocalizationsFi();
    case 'fr':
      return AppLocalizationsFr();
    case 'he':
      return AppLocalizationsHe();
    case 'hi':
      return AppLocalizationsHi();
    case 'hr':
      return AppLocalizationsHr();
    case 'hu':
      return AppLocalizationsHu();
    case 'id':
      return AppLocalizationsId();
    case 'it':
      return AppLocalizationsIt();
    case 'ja':
      return AppLocalizationsJa();
    case 'ka':
      return AppLocalizationsKa();
    case 'km':
      return AppLocalizationsKm();
    case 'ko':
      return AppLocalizationsKo();
    case 'lo':
      return AppLocalizationsLo();
    case 'lt':
      return AppLocalizationsLt();
    case 'lv':
      return AppLocalizationsLv();
    case 'ms':
      return AppLocalizationsMs();
    case 'my':
      return AppLocalizationsMy();
    case 'nb':
      return AppLocalizationsNb();
    case 'ne':
      return AppLocalizationsNe();
    case 'nl':
      return AppLocalizationsNl();
    case 'pl':
      return AppLocalizationsPl();
    case 'pt':
      return AppLocalizationsPt();
    case 'ro':
      return AppLocalizationsRo();
    case 'ru':
      return AppLocalizationsRu();
    case 'si':
      return AppLocalizationsSi();
    case 'sk':
      return AppLocalizationsSk();
    case 'sl':
      return AppLocalizationsSl();
    case 'sr':
      return AppLocalizationsSr();
    case 'sv':
      return AppLocalizationsSv();
    case 'sw':
      return AppLocalizationsSw();
    case 'th':
      return AppLocalizationsTh();
    case 'tl':
      return AppLocalizationsTl();
    case 'tr':
      return AppLocalizationsTr();
    case 'uk':
      return AppLocalizationsUk();
    case 'ur':
      return AppLocalizationsUr();
    case 'vi':
      return AppLocalizationsVi();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
