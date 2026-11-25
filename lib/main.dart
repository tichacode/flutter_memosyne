import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memosyne/app.dart';
import 'package:memosyne/core/storage/image_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ImageStorage.init();
  runApp(const ProviderScope(child: MemosyneApp()));
}
