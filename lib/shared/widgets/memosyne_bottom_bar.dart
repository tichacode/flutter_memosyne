import 'package:flutter/material.dart';
import 'package:memosyne/core/theme/app_theme.dart';
import 'package:memosyne/l10n/app_localizations.dart';

/// Maroon bar with the selected tab raised as a cream circle (like the prototype).
class MemosyneBottomBar extends StatelessWidget {
  const MemosyneBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const _icons = <IconData>[
    Icons.smart_toy_outlined, // Bot
    Icons.calendar_today_outlined, // Calendar
    Icons.edit_note_outlined, // Notes
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final labels = <String>[l10n.tabBot, l10n.tabCalendar, l10n.tabNotes];

    return ColoredBox(
      color: AppColors.cream,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
          child: SizedBox(
            height: 76,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: 0,
                  right: 0,
                  top: 12,
                  bottom: 12,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.maroon,
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                ),
                Row(
                  children: [
                    for (var i = 0; i < _icons.length; i++)
                      Expanded(
                        child: _BarItem(
                          icon: _icons[i],
                          label: labels[i],
                          selected: i == currentIndex,
                          onTap: () => onTap(i),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BarItem extends StatelessWidget {
  const _BarItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Center(
          child: selected
              ? Container(
                  width: 62,
                  height: 62,
                  decoration: BoxDecoration(
                    color: AppColors.cream,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.maroon, width: 3),
                  ),
                  child: Icon(icon, color: AppColors.maroon, size: 30),
                )
              : Icon(icon, color: AppColors.cream, size: 28),
        ),
      ),
    );
  }
}
