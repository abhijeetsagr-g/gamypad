import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gamypad_controller/src/layout/controller_layout.dart';
import 'package:gamypad_controller/src/layout/default_layout.dart';
import 'package:gamypad_controller/src/layout/layout_repository.dart';

final layoutRepositoryProvider = Provider<LayoutRepository>(
  (ref) => const SharedPreferencesLayoutRepository(),
);

class LayoutController extends AsyncNotifier<ControllerLayout> {
  LayoutRepository get _repository => ref.read(layoutRepositoryProvider);

  @override
  Future<ControllerLayout> build() async {
    final saved = await ref.watch(layoutRepositoryProvider).load();
    return saved ?? DefaultLayout.layout;
  }

  Future<List<String>> list() => _repository.list();

  Future<void> load(String name) async {
    try {
      final layout = await _repository.load(name);
      if (layout == null) return;
      state = AsyncData(layout);
      await _repository.save(layout);
    } catch (_) {}
  }

  Future<void> saveAs(String name) async {
    final layout = state.value;
    if (layout == null) return;

    state = AsyncData(layout.withName(name));
    try {
      await _repository.saveAs(layout, name);
    } catch (_) {}
  }

  Future<void> delete(String name) async {
    try {
      await _repository.delete(name);
      if (state.value?.name != name) return;

      final saved = await _repository.load();
      state = AsyncData(saved ?? DefaultLayout.layout);
    } catch (_) {}
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
