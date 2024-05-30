import 'package:huwamemo/models/memo_model.dart';
import 'package:huwamemo/repository/sqflite/sqflite_repository.dart';
import 'package:huwamemo/ui/state/home_screen_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_screen_view_model.g.dart';

@riverpod
class HomeScreenViewModel extends _$HomeScreenViewModel {
  @override
  HomeScreenState build() => HomeScreenState(homeMemos: []);

  Future<void> initialize() async {
    final list = <HomeMemo>[];
    try {
      final memos = await loadAllMemos();
      for (final memo in memos) {
        final duration = memo.finishDate.difference(DateTime.now());
        if (duration.inDays < 0) continue;
        final double height =
            (150 * duration.inHours / const Duration(days: 7).inHours)
                .clamp(50, 150);
        list.add(HomeMemo(memo: memo, height: height, remainingDays: duration));
      }
      state = HomeScreenState(homeMemos: list);
    } catch (e) {
      throw Exception('Failed to initialize');
    }
  }

  Future<List<MemoModel>> loadAllMemos() async {
    try {
      final memos = await ref.read(sqfliteRepositoryProvider).loadAllMemos();
      return memos;
    } catch (e) {
      // throw Exception('Failed to load memos');
      return [];
    }
  }

  Future<void> insertMemo(String content, {String? description}) async {
    final memo = MemoModel.create(content, description: description);
    try {
      await ref.read(sqfliteRepositoryProvider).insertMemo(memo);
    } catch (e) {
      throw Exception('Failed to insert memo');
    }
  }

  Future<List<HomeMemo>> checkUpdatedMemos(MemoModel updateMemo) async {
    final duration = updateMemo.finishDate.difference(DateTime.now());
    final double height =
        (150 * duration.inHours / const Duration(days: 7).inHours)
            .clamp(50, 150);
    final homeMemo =
        HomeMemo(memo: updateMemo, height: height, remainingDays: duration);
    final memos = state.homeMemos.map((e) {
      if (e.memo.memoId == homeMemo.memo.memoId) {
        e = homeMemo;
      }
      return e;
    }).toList();
    return memos;
  }

  Future<void> updateMemo(MemoModel memo) async {
    try {
      await ref.read(sqfliteRepositoryProvider).updateMemo(memo);
      await initialize();
    } catch (e) {
      throw Exception('Failed to update memo');
    }
  }

  Future<void> deleteMemo(String id) async {
    try {
      await ref.read(sqfliteRepositoryProvider).deleteMemoById(id);
    } catch (e) {
      throw Exception('Failed to delete memo');
    }
  }
}
