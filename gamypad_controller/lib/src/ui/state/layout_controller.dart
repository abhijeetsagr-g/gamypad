import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gamypad_controller/src/layout/controller_layout.dart';
import 'package:gamypad_controller/src/layout/default_layout.dart';
import 'package:gamypad_controller/src/layout/layout_repository.dart';

final layoutRepositoryProvider = Provider<LayoutRepository>(
  (ref) => const SharedPreferencesLayoutRepository(),
);

class LayoutController extends AsyncNotifier<ControllerLayout> {
  @override
  Future<ControllerLayout> build() async {
    final saved = await ref.watch(layoutRepositoryProvider).load();
    return saved ?? DefaultLayout.layout;
  }

  Future<void> commit(ControllerLayout layout) async {
    if (layout == state.value) return;

    state = AsyncData(layout);

    try {
      await ref.read(layoutRepositoryProvider).save(layout);
    } catch (_) {}
  }

  Future<void> reset() => commit(DefaultLayout.layout);
}

final layoutControllerProvider =
    AsyncNotifierProvider<LayoutController, ControllerLayout>(
      LayoutController.new,
    );
