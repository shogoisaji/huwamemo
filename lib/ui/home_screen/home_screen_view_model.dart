import 'package:flutter/material.dart';
import 'package:huwamemo/models/memo_model.dart';
import 'package:huwamemo/repository/sqflite/sqflite_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_screen_view_model.g.dart';

@Riverpod(keepAlive: false)
class HomeScreenViewModel extends _$HomeScreenViewModel {
  @override
  void build() {}

  Future<List<MemoModel>> loadAllMemos() async {
    try {
      final memos = await ref.read(sqfliteRepositoryProvider).loadAllMemos();
      print('memos: $memos');
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

  Future<void> deleteMemo(String id) async {
    try {
      await ref.read(sqfliteRepositoryProvider).deleteMemoById(id);
    } catch (e) {
      throw Exception('Failed to delete memo');
    }
  }
}
