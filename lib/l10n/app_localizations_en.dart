// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Memosyne';

  @override
  String get tabBot => 'Bot';

  @override
  String get tabCalendar => 'Calendar';

  @override
  String get tabNotes => 'Notes';

  @override
  String get allNotes => 'All notes';

  @override
  String get untitled => 'Untitled';

  @override
  String get searchHint => 'Search';

  @override
  String get emptyNotes => 'No notes yet. Tap + to add one.';

  @override
  String get addNote => 'New note';

  @override
  String get openFolders => 'Folders';

  @override
  String get addFolder => 'Add folder';

  @override
  String get folderNameLabel => 'Folder name';

  @override
  String get renameFolder => 'Rename';

  @override
  String get folderNameRequired => 'Please enter a folder name';

  @override
  String get folderExists => 'A folder with this name already exists';

  @override
  String deleteFolderTitle(String name) {
    return 'Delete folder \"$name\"?';
  }

  @override
  String get deleteFolderMessage =>
      'The notes inside will not be deleted. They stay in All notes.';

  @override
  String get delete => 'Delete';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String selectedCount(int count) {
    return '$count selected';
  }

  @override
  String deleteNotesTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Delete $count notes?',
      one: 'Delete this note?',
    );
    return '$_temp0';
  }

  @override
  String get deleteNotesMessage => 'This cannot be undone.';

  @override
  String get noteTitleHint => 'Title';

  @override
  String get noteBodyHint => 'Start writing...';

  @override
  String get editMode => 'Edit mode';

  @override
  String get readMode => 'Read mode';

  @override
  String get addImage => 'Add picture';

  @override
  String get imageSmall => 'Small';

  @override
  String get imageMedium => 'Medium';

  @override
  String get imageLarge => 'Large (fit width)';

  @override
  String get deleteImage => 'Delete picture';

  @override
  String get moveToFolder => 'Move to folder';

  @override
  String get noFolder => 'No folder';

  @override
  String get noFoldersYet => 'No folders yet. Create one from the folder menu.';
}
