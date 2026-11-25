import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

/// flutter_quill has its own translations (toolbar tooltips, dialogs).
/// If it does not support the current app language, its widgets could fail
/// to find their texts, so in that case this guard gives them English.
class QuillLocalizationGuard extends StatelessWidget {
  const QuillLocalizationGuard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final supported = FlutterQuillLocalizations.supportedLocales
        .any((l) => l.languageCode == locale.languageCode);
    if (supported) return child;
    return Localizations.override(
      context: context,
      locale: const Locale('en'),
      delegates: [FlutterQuillLocalizations.delegate],
      child: child,
    );
  }
}
