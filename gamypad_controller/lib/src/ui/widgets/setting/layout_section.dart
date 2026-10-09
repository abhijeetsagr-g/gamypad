import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gamypad_controller/src/ui/state/layout_controller.dart';
import 'package:gamypad_controller/src/ui/view/controller_editor_view.dart';
import 'package:gamypad_controller/src/ui/widgets/setting/layout_card.dart';
import 'package:gamypad_controller/src/utils/app_theme.dart';

class LayoutSection extends ConsumerWidget {
  const LayoutSection({super.key});

  Future<void> _edit(BuildContext context, WidgetRef ref, String name) async {
    await ref.read(layoutControllerProvider.notifier).load(name);
    if (!context.mounted) return;

    await Navigator.of(context).push<void>(
      MaterialPageRoute(builder: (_) => const ControllerEditorView()),
    );
  }

  Future<void> _newLayout(BuildContext context, WidgetRef ref) async {
    await ref.read(layoutControllerProvider.notifier).startNew();
    if (!context.mounted) return;

    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => const ControllerEditorView(isNew: true),
      ),
    );
  }

  Future<void> _delete(WidgetRef ref, String name) async {
    await ref.read(layoutControllerProvider.notifier).delete(name);
    ref.invalidate(layoutNamesProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final names = ref.watch(layoutNamesProvider);
    final active = ref.watch(layoutControllerProvider).value?.name;
    final controller = ref.read(layoutControllerProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'LAYOUT',
          style: TextStyle(
            color: ColorPalette.muted,
            fontSize: 10,
            letterSpacing: 3,
          ),
        ),
        const SizedBox(height: 12),

        names.when(
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: ColorPalette.accent,
                ),
              ),
            ),
          ),
          error: (_, _) => const Text(
            'Could not load layouts.',
            style: TextStyle(color: ColorPalette.muted, fontSize: 13),
          ),
          data: (presets) => Column(
            children: [
              for (final preset in presets) ...[
                LayoutCard(
                  name: preset,
                  active: preset == active,
                  onTap: () => controller.load(preset),
                  onEdit: preset == reservedLayoutName
                      ? null
                      : () => _edit(context, ref, preset),
                  onDelete: preset == reservedLayoutName || presets.length <= 1
                      ? null
                      : () => _delete(ref, preset),
                ),
                const SizedBox(height: 8),
              ],
              const SizedBox(height: 4),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: OutlinedButton.icon(
                  onPressed: () => _newLayout(context, ref),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('NEW LAYOUT'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: ColorPalette.accent,
                    side: const BorderSide(color: ColorPalette.accent),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
