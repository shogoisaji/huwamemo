// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'memo_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MemoModelImpl _$$MemoModelImplFromJson(Map<String, dynamic> json) =>
    _$MemoModelImpl(
      id: json['id'] as String,
      content: json['content'] as String,
      description: json['description'] as String?,
      color: json['color'] as String,
      finishDate: DateTime.parse(json['finish_date'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$$MemoModelImplToJson(_$MemoModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'content': instance.content,
      'description': instance.description,
      'color': instance.color,
      'finish_date': instance.finishDate.toIso8601String(),
      'created_at': instance.createdAt.toIso8601String(),
    };
