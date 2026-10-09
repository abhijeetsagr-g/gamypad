import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gamypad_controller/src/layout/controller_layout.dart';
import 'package:gamypad_controller/src/layout/default_layout.dart';
import 'package:gamypad_controller/src/layout/layout_repository.dart';

final layoutRepositoryProvider = Provider<LayoutRepository>(
  (ref) => const SharedPreferencesLayoutRepository(),
);

const String reservedLayoutName = 'Default';

class LayoutController extends AsyncNotifier<ControllerLayout> {
  LayoutRepository get _repository => ref.read(layoutRepositoryProvider);

  @override
  Future<ControllerLayout> build() async {
    await _repository.delete(reservedLayoutName);
    final saved = await ref.watch(layoutRepositoryProvider).load();
    return saved ?? DefaultLayout.layout;
  }

  Future<List<String>> list() => _repository.list();

  Future<void> load(String name) async {
    try {
      if (name == reservedLayoutName) {
        await _repository.delete(reservedLayoutName);
        state = AsyncData(DefaultLayout.layout);
        return;
      }

      final layout = await _repository.load(name);
      if (layout == null) return;
      state = AsyncData(layout);
      await _repository.save(layout);
    } catch (_) {}
  }

  Future<void> saveAs(String name) async {
    if (name == reservedLayoutName) return;

    final layout = state.value;
    if (layout == null) return;

    state = AsyncData(layout.withName(name));
    try {
      await _repository.saveAs(layout, name);
    } catch (_) {}
  }

  /// Saves the current layout under [name] and drops the previous preset name.
  Future<void> rename(String name) async {
    if (name == reservedLayoutName) return;

    final layout = state.value;
    if (layout == null || layout.name == reservedLayoutName) return;

    final previous = layout.name;
    final renamed = layout.withName(name);
    state = AsyncData(renamed);

    try {
      await _repository.save(renamed);
      if (previous != name) await _repository.delete(previous);
    } catch (_) {}
  }

  Future<String> startNew() async {
    final names = await _repository.list();
    var name = 'New Layout';
    var suffix = 2;
    while (names.contains(name)) {
      name = 'New Layout $suffix';
      suffix++;
    }

    final draft = DefaultLayout.layout.withName(name);
    state = AsyncData(draft);
    try {
      await _repository.save(draft);
    } catch (_) {}
    return name;
  }

  Future<void> delete(String name) async {
    if (name == reservedLayoutName) return;

    try {
      await _repository.delete(name);
      if (state.value?.name != name) return;

      final saved = await _repository.load();
      state = AsyncData(saved ?? DefaultLayout.layout);
    } catch (_) {}
  }

  Future<void> commit(ControllerLayout layout) async {
    if (layout.name == reservedLayoutName) return;
    if (layout == state.value) return;

    state = AsyncData(layout);

    try {
      await ref.read(layoutRepositoryProvider).save(layout);
    } catch (_) {}
  }

  /// Hides or reveals [id] in the active layout.
  Future<void> setHidden(String id, bool hidden) async {
    final layout = state.value;
    if (layout == null || layout.name == reservedLayoutName) return;
    if (layout.isHidden(id) == hidden) return;

    final updated = hidden
        ? layout.withHidden({...layout.hidden, id})
        : layout.withHidden({...layout.hidden}..remove(id));
    state = AsyncData(updated);

    try {
      await _repository.save(updated);
    } catch (_) {}
  }
}

final layoutControllerProvider =
    AsyncNotifierProvider<LayoutController, ControllerLayout>(
      LayoutController.new,
    );

final layoutNamesProvider = FutureProvider<List<String>>((ref) async {
  final active = await ref.watch(layoutControllerProvider.future);
  final names = await ref.read(layoutControllerProvider.notifier).list();
  if (!names.contains(reservedLayoutName)) names.add(reservedLayoutName);
  if (!names.contains(active.name)) names.add(active.name);
  names.sort();
  return names;
});
