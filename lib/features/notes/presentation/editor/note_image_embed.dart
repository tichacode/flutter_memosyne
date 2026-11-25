import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:memosyne/core/storage/image_storage.dart';
import 'package:memosyne/core/theme/app_theme.dart';
import 'package:memosyne/l10n/app_localizations.dart';

/// Custom Quill block type for pictures. The Delta stores only a small JSON
/// string {"p": "images/123.jpg", "s": "medium"} with a RELATIVE path,
/// so notes survive backup/restore.
const String kNoteImageType = 'note_image';

enum NoteImageSize { small, medium, large }

class NoteImageData {
  const NoteImageData({required this.path, this.size = NoteImageSize.medium});

  final String path;
  final NoteImageSize size;

  String encode() => jsonEncode({'p': path, 's': size.name});

  static NoteImageData? tryParse(Object? raw) {
    if (raw is! String) return null;
    try {
      final map = jsonDecode(raw);
      if (map is! Map) return null;
      final path = map['p'];
      if (path is! String || path.isEmpty) return null;
      final sizeName = map['s'];
      final size = NoteImageSize.values.firstWhere(
        (s) => s.name == sizeName,
        orElse: () => NoteImageSize.medium,
      );
      return NoteImageData(path: path, size: size);
    } catch (_) {
      return null;
    }
  }
}

class NoteImageBlockEmbed extends CustomBlockEmbed {
  NoteImageBlockEmbed(NoteImageData data)
      : super(kNoteImageType, data.encode());
}

/// Inserts/replaces use this wrapper (CustomBlockEmbed must be inside BlockEmbed.custom).
BlockEmbed noteImageEmbed(NoteImageData data) =>
    BlockEmbed.custom(NoteImageBlockEmbed(data));

class NoteImageEmbedBuilder extends EmbedBuilder {
  NoteImageEmbedBuilder();

  @override
  String get key => kNoteImageType;

  @override
  Widget build(BuildContext context, EmbedContext embedContext) {
    final data = NoteImageData.tryParse(embedContext.node.value.data);
    if (data == null) return const SizedBox.shrink();
    return _NoteImageView(data: data, embedContext: embedContext);
  }
}

class _NoteImageView extends StatelessWidget {
  const _NoteImageView({required this.data, required this.embedContext});

  final NoteImageData data;
  final EmbedContext embedContext;

  double get _fraction {
    switch (data.size) {
      case NoteImageSize.small:
        return 0.35;
      case NoteImageSize.medium:
        return 0.65;
      case NoteImageSize.large:
        return 1.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final pixelRatio = MediaQuery.devicePixelRatioOf(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final available =
              constraints.maxWidth.isFinite ? constraints.maxWidth : 280.0;
          final width = available * _fraction;
          final image = ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              ImageStorage.fileFor(data.path),
              width: width,
              fit: BoxFit.fitWidth,
              cacheWidth: (width * pixelRatio).round(),
              errorBuilder: (context, error, stackTrace) => Container(
                width: width,
                height: 100,
                color: AppColors.paper,
                child: const Icon(
                  Icons.broken_image_outlined,
                  color: AppColors.maroonSoft,
                ),
              ),
            ),
          );
          final aligned = Align(alignment: Alignment.centerLeft, child: image);
          if (embedContext.readOnly) return aligned;
          return GestureDetector(
            onTap: () => _showOptions(context),
            child: aligned,
          );
        },
      ),
    );
  }

  String _label(AppLocalizations l10n, NoteImageSize size) {
    switch (size) {
      case NoteImageSize.small:
        return l10n.imageSmall;
      case NoteImageSize.medium:
        return l10n.imageMedium;
      case NoteImageSize.large:
        return l10n.imageLarge;
    }
  }

  void _setSize(NoteImageSize size) {
    final offset = embedContext.node.documentOffset;
    embedContext.controller.replaceText(
      offset,
      1,
      noteImageEmbed(NoteImageData(path: data.path, size: size)),
      null,
    );
  }

  void _delete() {
    final offset = embedContext.node.documentOffset;
    embedContext.controller.replaceText(offset, 1, '', null);
  }

  Future<void> _showOptions(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final size in NoteImageSize.values)
              ListTile(
                leading: Icon(
                  size == data.size
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                ),
                title: Text(_label(l10n, size)),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _setSize(size);
                },
              ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: Text(l10n.deleteImage),
              onTap: () {
                Navigator.of(sheetContext).pop();
                _delete();
              },
            ),
          ],
        ),
      ),
    );
  }
}
