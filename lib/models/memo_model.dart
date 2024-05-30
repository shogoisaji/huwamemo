import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';

part 'memo_model.freezed.dart';
part 'memo_model.g.dart';

@freezed
class MemoModel with _$MemoModel {
  const factory MemoModel({
    required String id,
    required String content,
    String? description,
    required String color,
    @JsonKey(name: 'finish_date') required DateTime finishDate,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _MemoModel;

  factory MemoModel.fromJson(Map<String, dynamic> json) =>
      _$MemoModelFromJson(json);

  factory MemoModel.create(String content,
      {String? description, String? decoration}) {
    const dateRange = 7;
    return MemoModel(
      id: const Uuid().v4(),
      content: content,
      description: description ?? '',
      color: Colors.white.toString(),
      finishDate: DateTime.now().add(const Duration(days: dateRange)),
      createdAt: DateTime.now(),
    );
  }
}
