import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Stores note pictures inside the app documents directory.
/// The database and the note content only keep RELATIVE paths
/// (e.g. 'images/1700000000000000.jpg') so a backup can be restored anywhere.
class ImageStorage {
  ImageStorage._();

  static late Directory _root;

  static Future<void> init() async {
    _root = await getApplicationDocumentsDirectory();
    await Directory(p.join(_root.path, 'images')).create(recursive: true);
  }

  static File fileFor(String relativePath) =>
      File(p.join(_root.path, relativePath));

  /// Copies a picked file into app storage and returns its relative path.
  static Future<String> importFile(String sourcePath) async {
    var ext = p.extension(sourcePath).toLowerCase();
    if (ext.isEmpty) ext = '.jpg';
    final name = '${DateTime.now().microsecondsSinceEpoch}$ext';
    final relative = 'images/$name';
    await File(sourcePath).copy(p.join(_root.path, 'images', name));
    return relative;
  }

  static Future<void> deleteFile(String relativePath) async {
    try {
      final file = fileFor(relativePath);
      if (await file.exists()) await file.delete();
    } catch (_) {
      // Ignore: a leftover file is harmless.
    }
  }
}
