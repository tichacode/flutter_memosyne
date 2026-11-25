import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:memosyne/core/database/app_database.dart';
import 'package:memosyne/core/theme/app_theme.dart';
import 'package:memosyne/features/notes/presentation/widgets/folder_drawer.dart';
import 'package:memosyne/features/notes/presentation/widgets/note_card.dart';
import 'package:memosyne/features/notes/providers.dart';
import 'package:memosyne/l10n/app_localizations.dart';
import 'package:memosyne/features/notes/presentation/widgets/move_to_folder_sheet.dart';

class NotesPage extends ConsumerStatefulWidget {
  const NotesPage({super.key});

  @override
  ConsumerState<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends ConsumerState<NotesPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final Set<int> _selected = <int>{};

  bool get _selecting => _selected.isNotEmpty;

  void _toggle(int id) {
    setState(() {
      if (!_selected.remove(id)) _selected.add(id);
    });
  }

  void _clearSelection() => setState(_selected.clear);

  void _addNote() {
    final folderId = ref.read(selectedFolderIdProvider);
    context.push(folderId == null ? '/note/new' : '/note/new?folder=$folderId');
  }

  Future<void> _deleteSelected() async {
    final l10n = AppLocalizations.of(context)!;
    final ids = _selected.toList();
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deleteNotesTitle(ids.length)),
        content: Text(l10n.deleteNotesMessage),
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
    if (ok != true) return;
    await ref.read(notesRepositoryProvider).deleteNotes(ids);
    if (mounted) setState(_selected.clear);
  }

  Future<void> _moveSelected() async {
    final folders = ref.read(foldersProvider).value ?? const <Folder>[];
    final choice = await showMoveToFolderSheet(context, folders: folders);
    if (choice == null || !mounted) return;
    await ref
        .read(notesRepositoryProvider)
        .moveNotes(_selected.toList(), choice.folderId);
    if (mounted) setState(_selected.clear);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final folderId = ref.watch(selectedFolderIdProvider);
    final folders = ref.watch(foldersProvider).value ?? const <Folder>[];
    final notesAsync = ref.watch(notesProvider(folderId));

    var folderTitle = l10n.allNotes;
    if (folderId != null) {
      for (final folder in folders) {
        if (folder.id == folderId) folderTitle = folder.name;
      }
    }

    return PopScope(
      canPop: !_selecting,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _selecting) _clearSelection();
      },
      child: Scaffold(
        key: _scaffoldKey,
        drawer: const FolderDrawer(),
        appBar: _selecting
            ? AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: _clearSelection,
                ),
                title: Text(l10n.selectedCount(_selected.length)),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.drive_file_move_outline),
                    tooltip: l10n.moveToFolder,
                    onPressed: _moveSelected,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    tooltip: l10n.delete,
                    onPressed: _deleteSelected,
                  ),
                ],
              )
            : AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.menu),
                  tooltip: l10n.openFolders,
                  onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                ),
                title: Text(
                  folderTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.add),
                    tooltip: l10n.addNote,
                    onPressed: _addNote,
                  ),
                ],
              ),
        body: Column(
          children: [
            _SearchBarButton(
              hint: l10n.searchHint,
              onTap: () => context.push('/search/notes'),
            ),
            Expanded(
              child: notesAsync.when(
                data: (notes) {
                  if (notes.isEmpty) {
                    return Center(child: Text(l10n.emptyNotes));
                  }
                  return GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.82,
                    ),
                    itemCount: notes.length,
                    itemBuilder: (context, index) {
                      final note = notes[index];
                      return NoteCard(
                        note: note,
                        selecting: _selecting,
                        selected: _selected.contains(note.id),
                        onTap: () {
                          if (_selecting) {
                            _toggle(note.id);
                          } else {
                            context.push('/note/${note.id}');
                          }
                        },
                        onLongPress: () => _toggle(note.id),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(child: Text('$error')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Looks like a search field, but tapping it opens the (blank) search page.
class _SearchBarButton extends StatelessWidget {
  const _SearchBarButton({required this.hint, required this.onTap});

  final String hint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.paper,
            borderRadius: BorderRadius.circular(22),
            boxShadow: const [
              BoxShadow(
                color: Color(0x26000000),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  hint,
                  style: const TextStyle(color: AppColors.maroonSoft),
                ),
              ),
              const Icon(Icons.search, color: AppColors.maroon),
            ],
          ),
        ),
      ),
    );
  }
}
