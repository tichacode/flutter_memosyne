import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:memosyne/core/database/app_database.dart';
import 'package:memosyne/core/storage/image_storage.dart';
import 'package:memosyne/core/theme/app_theme.dart';
import 'package:memosyne/features/notes/data/notes_repository.dart';
import 'package:memosyne/features/notes/presentation/editor/note_image_embed.dart';
import 'package:memosyne/features/notes/presentation/editor/quill_localization_guard.dart';
import 'package:memosyne/features/notes/providers.dart';
import 'package:memosyne/l10n/app_localizations.dart';

/// Route entry: [noteId] null = new note.
class NoteEditorPage extends ConsumerWidget {
  const NoteEditorPage({super.key, this.noteId, this.initialFolderId});

  final int? noteId;
  final int? initialFolderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = noteId;
    if (id == null) {
      return NoteEditorBody(initialFolderId: initialFolderId);
    }
    final noteAsync = ref.watch(noteByIdProvider(id));
    return noteAsync.when(
      data: (note) => NoteEditorBody(
        key: ValueKey('note-$id'),
        note: note,
        initialFolderId: initialFolderId,
      ),
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, _) =>
          Scaffold(appBar: AppBar(), body: Center(child: Text('$error'))),
    );
  }
}

class NoteEditorBody extends ConsumerStatefulWidget {
  const NoteEditorBody({super.key, this.note, this.initialFolderId});

  final Note? note;
  final int? initialFolderId;

  @override
  ConsumerState<NoteEditorBody> createState() => _NoteEditorBodyState();
}

class _NoteEditorBodyState extends ConsumerState<NoteEditorBody>
    with WidgetsBindingObserver {
  late final NotesRepository _repo;
  late final QuillController _controller;
  late final TextEditingController _titleController;
  final FocusNode _editorFocus = FocusNode();
  final ScrollController _scroll = ScrollController();
  StreamSubscription<DocChange>? _changesSub;
  Timer? _debounce;

  /// Saves run one after another so a new note is never inserted twice.
  Future<void> _saveQueue = Future<void>.value();

  int? _noteId;
  int? _folderId;
  late bool _editing;
  String _lastTitle = '';
  String _lastJson = '';

  /// Pictures copied in during this session (to clean up if never used).
  final Set<String> _pickedPaths = <String>{};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _repo = ref.read(notesRepositoryProvider);

    final note = widget.note;
    _noteId = note?.id;
    _folderId = note?.folderId ?? widget.initialFolderId;
    _titleController = TextEditingController(text: note?.title ?? '');
    _controller = QuillController(
      document: _documentFrom(note?.contentJson),
      selection: const TextSelection.collapsed(offset: 0),
    );

    // New note opens in edit mode, existing note opens in read mode
    // (tap the pencil to edit). Change this line if you prefer otherwise.
    _editing = note == null;
    _controller.readOnly = !_editing;

    _lastTitle = (note?.title ?? '').trim();
    _lastJson = _encode(_controller.document);

    _changesSub = _controller.document.changes.listen((_) => _scheduleSave());
    _titleController.addListener(_scheduleSave);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _debounce?.cancel();
      _queueSave();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _debounce?.cancel();
    _changesSub?.cancel();
    _queueSave(finalPass: true); // reads everything before the controllers die
    _titleController.dispose();
    _controller.dispose();
    _editorFocus.dispose();
    _scroll.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------- document

  static Document _documentFrom(String? json) {
    if (json == null || json.trim().isEmpty) return Document();
    try {
      final data = jsonDecode(json);
      if (data is List && data.isNotEmpty) return Document.fromJson(data);
    } catch (_) {
      // fall through to an empty document
    }
    return Document();
  }

  static String _encode(Document doc) => jsonEncode(doc.toDelta().toJson());

  /// Text only (pictures skipped), used for previews and search.
  static String _plainText(Document doc) {
    final buffer = StringBuffer();
    for (final op in doc.toDelta().toList()) {
      final data = op.data;
      if (data is String) buffer.write(data);
    }
    return buffer.toString().trim();
  }

  static Set<String> _imagePaths(Document doc) {
    final paths = <String>{};
    for (final op in doc.toDelta().toList()) {
      final data = op.data;
      if (data is Map && data[kNoteImageType] is String) {
        final parsed = NoteImageData.tryParse(data[kNoteImageType]);
        if (parsed != null) paths.add(parsed.path);
      }
    }
    return paths;
  }

  // ------------------------------------------------------------------ saving

  void _scheduleSave() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 700), _queueSave);
  }

  void _queueSave({bool finalPass = false}) {
    // Take a snapshot now; the actual saving happens later in the queue.
    final title = _titleController.text.trim();
    final json = _encode(_controller.document);
    final text = _plainText(_controller.document);
    final images = _imagePaths(_controller.document);
    final picked = Set<String>.of(_pickedPaths);
    _saveQueue = _saveQueue
        .then((_) => _persist(title, json, text, images, picked, finalPass))
        .catchError((Object _) {});
  }

  Future<void> _persist(
    String title,
    String json,
    String text,
    Set<String> images,
    Set<String> picked,
    bool finalPass,
  ) async {
    if (_noteId == null) {
      // Never save an empty new note.
      if (title.isEmpty && text.isEmpty && images.isEmpty) {
        if (finalPass) {
          for (final path in picked) {
            await ImageStorage.deleteFile(path);
          }
        }
        return;
      }
      _noteId = await _repo.createNote(
        folderId: _folderId,
        title: title,
        contentJson: json,
        contentText: text,
      );
      _lastTitle = title;
      _lastJson = json;
    } else if (title != _lastTitle || json != _lastJson) {
      await _repo.updateNote(
        _noteId!,
        title: title,
        contentJson: json,
        contentText: text,
      );
      _lastTitle = title;
      _lastJson = json;
    }

    final id = _noteId;
    if (id != null) {
      await _repo.syncImages(id, images);
      if (finalPass) await _repo.pruneImages(id, images);
    }
    if (finalPass) {
      for (final path in picked.difference(images)) {
        await ImageStorage.deleteFile(path);
      }
    }
  }

  // ----------------------------------------------------------------- actions

  void _toggleEditing() {
    setState(() {
      _editing = !_editing;
      _controller.readOnly = !_editing;
    });
    if (!_editing) FocusScope.of(context).unfocus();
  }

  Future<void> _addImage() async {
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
      imageQuality: 85,
    );
    if (file == null || !mounted) return;
    final relativePath = await ImageStorage.importFile(file.path);
    if (!mounted) return;
    _pickedPaths.add(relativePath);

    final selection = _controller.selection;
    final maxIndex = _controller.document.length - 1;
    var index = selection.isValid ? selection.baseOffset : maxIndex;
    if (index < 0 || index > maxIndex) index = maxIndex;

    _controller.replaceText(
      index,
      0,
      noteImageEmbed(NoteImageData(path: relativePath)),
      TextSelection.collapsed(offset: index + 1),
    );
  }

  // ------------------------------------------------------------------- build

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return QuillLocalizationGuard(
      child: Scaffold(
        appBar: AppBar(
          title: TextField(
            controller: _titleController,
            readOnly: !_editing,
            autofocus: widget.note == null,
            maxLines: 1,
            textInputAction: TextInputAction.next,
            onSubmitted: (_) => _editorFocus.requestFocus(),
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w700),
            decoration: InputDecoration.collapsed(hintText: l10n.noteTitleHint),
          ),
          actions: [
            IconButton(
              tooltip: _editing ? l10n.readMode : l10n.editMode,
              icon: Icon(
                _editing ? Icons.visibility_outlined : Icons.edit_outlined,
              ),
              onPressed: _toggleEditing,
            ),
          ],
        ),
        body: SafeArea(
          top: false,
          child: Column(
            children: [
              if (_editing)
                Container(
                  color: AppColors.paper,
                  child: Row(
                    children: [
                      Expanded(
                        child: QuillSimpleToolbar(
                          controller: _controller,
                          config: QuillSimpleToolbarConfig(
                            multiRowsDisplay: false,
                            showDividers: true,
                            showUndo: true,
                            showRedo: true,
                            showFontFamily: false,
                            showFontSize: false,
                            showSmallButton: false,
                            showBoldButton: true,
                            showItalicButton: true,
                            showUnderLineButton: true,
                            showStrikeThrough: true,
                            showInlineCode: false,
                            showSubscript: false,
                            showSuperscript: false,
                            showColorButton: true,
                            showBackgroundColorButton: true,
                            showClearFormat: false,
                            showAlignmentButtons: true,
                            showHeaderStyle: false,
                            showListNumbers: false,
                            showListBullets: true,
                            showListCheck: true,
                            showCodeBlock: false,
                            showQuote: false,
                            showIndent: false,
                            showLink: false,
                            showDirection: false,
                            showSearchButton: true, // in-note search
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: l10n.addImage,
                        icon: const Icon(Icons.add_photo_alternate_outlined),
                        onPressed: _addImage,
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: QuillEditor.basic(
                  controller: _controller,
                  focusNode: _editorFocus,
                  scrollController: _scroll,
                  config: QuillEditorConfig(
                    placeholder: l10n.noteBodyHint,
                    padding: const EdgeInsets.all(16),
                    embedBuilders: [NoteImageEmbedBuilder()],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
