import 'package:flutter/material.dart';
import 'package:memosyne/features/notes/data/notes_repository.dart';
import 'package:memosyne/l10n/app_localizations.dart';

/// Dialog with one text field, used for "Add folder" and "Rename".
/// [onSubmit] may throw [DuplicateFolderException]; the dialog then shows an error.
Future<void> showFolderNameDialog(
  BuildContext context, {
  required String title,
  String? initialName,
  required Future<void> Function(String name) onSubmit,
}) {
  return showDialog<void>(
    context: context,
    builder: (_) => _FolderNameDialog(
      title: title,
      initialName: initialName,
      onSubmit: onSubmit,
    ),
  );
}

class _FolderNameDialog extends StatefulWidget {
  const _FolderNameDialog({
    required this.title,
    required this.onSubmit,
    this.initialName,
  });

  final String title;
  final String? initialName;
  final Future<void> Function(String name) onSubmit;

  @override
  State<_FolderNameDialog> createState() => _FolderNameDialogState();
}

class _FolderNameDialogState extends State<_FolderNameDialog> {
  late final TextEditingController _controller;
  String? _error;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    final name = _controller.text.trim();
    if (name.isEmpty) {
      setState(() => _error = l10n.folderNameRequired);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await widget.onSubmit(name);
      if (mounted) Navigator.of(context).pop();
    } on DuplicateFolderException {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = l10n.folderExists;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLength: 40,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _submit(),
        decoration: InputDecoration(
          labelText: l10n.folderNameLabel,
          errorText: _error,
        ),
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _busy ? null : _submit,
          child: Text(l10n.save),
        ),
      ],
    );
  }
}
