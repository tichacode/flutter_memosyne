import 'package:flutter/material.dart';
import 'package:memosyne/core/database/app_database.dart';
import 'package:memosyne/core/theme/app_theme.dart';
import 'package:memosyne/l10n/app_localizations.dart';

/// Note card: paper preview on top, yellow title label at the bottom.
class NoteCard extends StatelessWidget {
  const NoteCard({
    super.key,
    required this.note,
    required this.selecting,
    required this.selected,
    required this.onTap,
    required this.onLongPress,
  });

  final Note note;
  final bool selecting;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final title = note.title.trim().isEmpty ? l10n.untitled : note.title.trim();
    var preview = note.contentText.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (preview.length > 200) preview = preview.substring(0, 200);

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Stack(
        children: [
          Container(
            foregroundDecoration: selected
                ? BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.green, width: 2.5),
                  )
                : null,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x33000000),
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Column(
                children: [
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      color: AppColors.paper,
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        preview,
                        maxLines: 8,
                        overflow: TextOverflow.fade,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.maroonSoft,
                            ),
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    color: AppColors.yellow,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    child: Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (selecting)
            Positioned(
              top: 8,
              left: 8,
              child: _SelectDot(selected: selected),
            ),
        ],
      ),
    );
  }
}

class _SelectDot extends StatelessWidget {
  const _SelectDot({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? AppColors.green : AppColors.paper,
        border: Border.all(color: AppColors.maroon, width: 2),
      ),
      child: selected
          ? const Icon(Icons.check, size: 16, color: AppColors.paper)
          : null,
    );
  }
}
