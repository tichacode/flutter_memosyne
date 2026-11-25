import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_th.dart';

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
    Locale('en'),
    Locale('th'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Memosyne'**
  String get appTitle;

  /// No description provided for @tabBot.
  ///
  /// In en, this message translates to:
  /// **'Bot'**
  String get tabBot;

  /// No description provided for @tabCalendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get tabCalendar;

  /// No description provided for @tabNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get tabNotes;

  /// No description provided for @allNotes.
  ///
  /// In en, this message translates to:
  /// **'All notes'**
  String get allNotes;

  /// No description provided for @untitled.
  ///
  /// In en, this message translates to:
  /// **'Untitled'**
  String get untitled;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchHint;

  /// No description provided for @emptyNotes.
  ///
  /// In en, this message translates to:
  /// **'No notes yet. Tap + to add one.'**
  String get emptyNotes;

  /// No description provided for @addNote.
  ///
  /// In en, this message translates to:
  /// **'New note'**
  String get addNote;

  /// No description provided for @openFolders.
  ///
  /// In en, this message translates to:
  /// **'Folders'**
  String get openFolders;

  /// No description provided for @addFolder.
  ///
  /// In en, this message translates to:
  /// **'Add folder'**
  String get addFolder;

  /// No description provided for @folderNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Folder name'**
  String get folderNameLabel;

  /// No description provided for @renameFolder.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get renameFolder;

  /// No description provided for @folderNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a folder name'**
  String get folderNameRequired;

  /// No description provided for @folderExists.
  ///
  /// In en, this message translates to:
  /// **'A folder with this name already exists'**
  String get folderExists;

  /// No description provided for @deleteFolderTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete folder \"{name}\"?'**
  String deleteFolderTitle(String name);

  /// No description provided for @deleteFolderMessage.
  ///
  /// In en, this message translates to:
  /// **'The notes inside will not be deleted. They stay in All notes.'**
  String get deleteFolderMessage;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

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

  /// No description provided for @selectedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String selectedCount(int count);

  /// No description provided for @deleteNotesTitle.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Delete this note?} other{Delete {count} notes?}}'**
  String deleteNotesTitle(int count);

  /// No description provided for @deleteNotesMessage.
  ///
  /// In en, this message translates to:
  /// **'This cannot be undone.'**
  String get deleteNotesMessage;

  /// No description provided for @noteTitleHint.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get noteTitleHint;

  /// No description provided for @noteBodyHint.
  ///
  /// In en, this message translates to:
  /// **'Start writing...'**
  String get noteBodyHint;

  /// No description provided for @editMode.
  ///
  /// In en, this message translates to:
  /// **'Edit mode'**
  String get editMode;

  /// No description provided for @readMode.
  ///
  /// In en, this message translates to:
  /// **'Read mode'**
  String get readMode;

  /// No description provided for @addImage.
  ///
  /// In en, this message translates to:
  /// **'Add picture'**
  String get addImage;

  /// No description provided for @imageSmall.
  ///
  /// In en, this message translates to:
  /// **'Small'**
  String get imageSmall;

  /// No description provided for @imageMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get imageMedium;

  /// No description provided for @imageLarge.
  ///
  /// In en, this message translates to:
  /// **'Large (fit width)'**
  String get imageLarge;

  /// No description provided for @deleteImage.
  ///
  /// In en, this message translates to:
  /// **'Delete picture'**
  String get deleteImage;

  /// No description provided for @moveToFolder.
  ///
  /// In en, this message translates to:
  /// **'Move to folder'**
  String get moveToFolder;

  /// No description provided for @noFolder.
  ///
  /// In en, this message translates to:
  /// **'No folder'**
  String get noFolder;

  /// No description provided for @noFoldersYet.
  ///
  /// In en, this message translates to:
  /// **'No folders yet. Create one from the folder menu.'**
  String get noFoldersYet;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'th'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'th':
      return AppLocalizationsTh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
