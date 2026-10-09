import 'package:flutter/material.dart';
import 'package:gamypad_controller/src/utils/app_theme.dart';

class LayoutCard extends StatelessWidget {
  const LayoutCard({
    super.key,
    required this.name,
    required this.active,
    required this.onTap,
    this.onEdit,
    this.onDelete,
  });

  final String name;
  final bool active;
  final VoidCallback onTap;

  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: ColorPalette.analogTrack,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: active ? ColorPalette.accent : ColorPalette.border,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 4, 8),
          child: Row(
            children: [
              Icon(
                active
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                size: 20,
                color: active ? ColorPalette.accent : ColorPalette.muted,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  name,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: active ? ColorPalette.text : ColorPalette.muted,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              PopupMenuButton<_LayoutCardAction>(
                tooltip: 'Layout actions',
                icon: const Icon(
                  Icons.more_vert,
                  size: 20,
                  color: ColorPalette.muted,
                ),
                color: ColorPalette.analogTrack,
                onSelected: (action) => switch (action) {
                  _LayoutCardAction.edit => onEdit?.call(),
                  _LayoutCardAction.delete => onDelete?.call(),
                },
                itemBuilder: (context) => [
                  if (onEdit != null)
                    const PopupMenuItem(
                      value: _LayoutCardAction.edit,
                      child: Text('EDIT', style: _menuLabel),
                    ),
                  if (onDelete != null)
                    const PopupMenuItem(
                      value: _LayoutCardAction.delete,
                      child: Text('DELETE', style: _menuLabelDanger),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _LayoutCardAction { edit, delete }

const _menuLabel = TextStyle(
  color: ColorPalette.text,
  fontSize: 12,
  fontWeight: FontWeight.w700,
  letterSpacing: 2,
);

const _menuLabelDanger = TextStyle(
  color: ColorPalette.invalid,
  fontSize: 12,
  fontWeight: FontWeight.w700,
  letterSpacing: 2,
);
