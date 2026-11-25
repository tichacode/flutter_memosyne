import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memosyne/core/database/app_database.dart';
import 'package:memosyne/core/theme/app_theme.dart';
import 'package:memosyne/features/notes/data/notes_repository.dart';
import 'package:memosyne/features/notes/presentation/widgets/folder_dialogs.dart';
import 'package:memosyne/features/notes/providers.dart';
import 'package:memosyne/l10n/app_localizations.dart';

/// Folder list drawer: "Add folder" button, All notes, then every folder.
/// Tap = show that folder. Long-press a folder = rename / delete.
class FolderDrawer extends ConsumerWidget {
  const FolderDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final folders = ref.watch(foldersProvider).value ?? const <Folder>[];
    final counts =
        ref.watch(folderCountsProvider).value ?? const FolderCounts();
    final selectedId = ref.watch(selectedFolderIdProvider);
    final repo = ref.read(notesRepositoryProvider);

    void select(int? id) {
      ref.read(selectedFolderIdProvider.notifier).select(id);
      Navigator.of(context).pop(); // close drawer
    }

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.yellow,
                  foregroundColor: AppColors.maroon,
                  side: const BorderSide(color: AppColors.maroon, width: 1.5),
                ),
                onPressed: () => showFolderNameDialog(
                  context,
                  title: l10n.addFolder,
                  onSubmit: repo.addFolder,
                ),
                icon: const Icon(Icons.create_new_folder_outlined),
                label: Text(l10n.addFolder),
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  _FolderTile(
                    label: l10n.allNotes,
                    count: counts.total,
                    selected: selectedId == null,
                    onTap: () => select(null),
                  ),
                  for (final folder in folders)
                    _FolderTile(
                      label: folder.name,
                      count: counts.byFolder[folder.id] ?? 0,
                      selected: selectedId == folder.id,
                      onTap: () => select(folder.id),
                      onLongPress: () =>
                          _showFolderMenu(context, ref, repo, folder),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showFolderMenu(
    BuildContext context,
    WidgetRef ref,
    NotesRepository repo,
    Folder folder,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: Text(l10n.renameFolder),
              onTap: () {
                Navigator.of(sheetContext).pop();
                showFolderNameDialog(
                  context,
                  title: l10n.renameFolder,
                  initialName: folder.name,
                  onSubmit: (name) => repo.renameFolder(folder.id, name),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: Text(l10n.delete),
              onTap: () {
                Navigator.of(sheetContext).pop();
                _confirmDelete(context, ref, repo, folder);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    NotesRepository repo,
    Folder folder,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deleteFolderTitle(folder.name)),
        content: Text(l10n.deleteFolderMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    await repo.deleteFolder(folder.id);
    if (!context.mounted) return;
    if (ref.read(selectedFolderIdProvider) == folder.id) {
      ref.read(selectedFolderIdProvider.notifier).select(null);
    }
  }
}

class _FolderTile extends StatelessWidget {
  const _FolderTile({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
    this.onLongPress,
  });

  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.cream : AppColors.maroon;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: selected ? AppColors.maroon : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          onLongPress: onLongPress,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: color,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
                Text('$count', style: TextStyle(color: color)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
