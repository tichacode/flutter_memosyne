// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Thai (`th`).
class AppLocalizationsTh extends AppLocalizations {
  AppLocalizationsTh([String locale = 'th']) : super(locale);

  @override
  String get appTitle => 'Memosyne';

  @override
  String get tabBot => 'บอท';

  @override
  String get tabCalendar => 'ปฏิทิน';

  @override
  String get tabNotes => 'โน้ต';

  @override
  String get allNotes => 'โน้ตทั้งหมด';

  @override
  String get untitled => 'ไม่มีชื่อเรื่อง';

  @override
  String get searchHint => 'ค้นหา';

  @override
  String get emptyNotes => 'ยังไม่มีโน้ต กดปุ่ม + เพื่อเพิ่ม';

  @override
  String get addNote => 'สร้างโน้ตใหม่';

  @override
  String get openFolders => 'โฟลเดอร์';

  @override
  String get addFolder => 'เพิ่มโฟลเดอร์';

  @override
  String get folderNameLabel => 'ชื่อโฟลเดอร์';

  @override
  String get renameFolder => 'เปลี่ยนชื่อ';

  @override
  String get folderNameRequired => 'กรุณากรอกชื่อโฟลเดอร์';

  @override
  String get folderExists => 'มีโฟลเดอร์ชื่อนี้อยู่แล้ว';

  @override
  String deleteFolderTitle(String name) {
    return 'ลบโฟลเดอร์ \"$name\"?';
  }

  @override
  String get deleteFolderMessage =>
      'โน้ตในโฟลเดอร์จะไม่ถูกลบ และยังอยู่ใน \"โน้ตทั้งหมด\"';

  @override
  String get delete => 'ลบ';

  @override
  String get cancel => 'ยกเลิก';

  @override
  String get save => 'บันทึก';

  @override
  String selectedCount(int count) {
    return 'เลือกแล้ว $count';
  }

  @override
  String deleteNotesTitle(int count) {
    return 'ลบโน้ต $count รายการ?';
  }

  @override
  String get deleteNotesMessage => 'การลบนี้ไม่สามารถย้อนกลับได้';

  @override
  String get noteTitleHint => 'ชื่อเรื่อง';

  @override
  String get noteBodyHint => 'เริ่มเขียนที่นี่...';

  @override
  String get editMode => 'โหมดแก้ไข';

  @override
  String get readMode => 'โหมดอ่าน';

  @override
  String get addImage => 'เพิ่มรูปภาพ';

  @override
  String get imageSmall => 'เล็ก';

  @override
  String get imageMedium => 'กลาง';

  @override
  String get imageLarge => 'ใหญ่ (เต็มความกว้าง)';

  @override
  String get deleteImage => 'ลบรูปภาพ';

  @override
  String get moveToFolder => 'ย้ายไปโฟลเดอร์';

  @override
  String get noFolder => 'ไม่มีโฟลเดอร์';

  @override
  String get noFoldersYet => 'ยังไม่มีโฟลเดอร์ สร้างได้จากเมนูโฟลเดอร์';
}
