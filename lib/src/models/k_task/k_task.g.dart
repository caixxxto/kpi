// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'k_task.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

KTask _$KTaskFromJson(Map<String, dynamic> json) => KTask(
  name: json['name'] as String?,
  indicatorToMoId: (json['indicator_to_mo_id'] as num?)?.toInt(),
  parentId: (json['parent_id'] as num?)?.toInt(),
  order: (json['order'] as num?)?.toInt(),
);

Map<String, dynamic> _$KTaskToJson(KTask instance) => <String, dynamic>{
  'name': instance.name,
  'indicator_to_mo_id': instance.indicatorToMoId,
  'parent_id': instance.parentId,
  'order': instance.order,
};
