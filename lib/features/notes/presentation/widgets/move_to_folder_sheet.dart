import 'package:flutter/material.dart';
import 'package:memosyne/core/database/app_database.dart';
import 'package:memosyne/l10n/app_localizations.dart';

/// Result of the "Move to folder" sheet.
/// The sheet returns null when the user dismisses it (= do nothing),
/// and FolderChoice(null) when the user picks "No folder".
class FolderChoice {
  const FolderChoice(this.folderId);

  final int? folderId;
}

/// Bottom sheet listing "No folder" and every folder.
/// [markCurrent] + [currentFolderId] show a check mark on the current choice
/// (used by the note editor; the Notes page leaves it off).
Future<FolderChoice?> showMoveToFolderSheet(
  BuildContext context, {
  required List<Folder> folders,
  int? currentFolderId,
  bool markCurrent = false,
}) {
  final l10n = AppLocalizations.of(context)!;

  return showModalBottomSheet<FolderChoice>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) {
      final maxHeight = MediaQuery.sizeOf(sheetContext).height * 0.6;
      const check = Icon(Icons.check);

      return SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxHeight),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    l10n.moveToFolder,
                    style: Theme.of(sheetContext)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.folder_off_outlined),
                      title: Text(l10n.noFolder),
                      trailing:
                          markCurrent && currentFolderId == null ? check : null,
                      onTap: () =>
                          Navigator.of(sheetContext).pop(const FolderChoice(null)),
                    ),
                    for (final folder in folders)
                      ListTile(
                        leading: const Icon(Icons.folder_outlined),
                        title: Text(
                          folder.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: markCurrent && currentFolderId == folder.id
                            ? check
                            : null,
                        onTap: () => Navigator.of(sheetContext)
                            .pop(FolderChoice(folder.id)),
                      ),
                    if (folders.isEmpty)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                        child: Text(l10n.noFoldersYet),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
