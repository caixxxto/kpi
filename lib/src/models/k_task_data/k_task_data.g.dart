// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'k_task_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

KTasksData _$KTasksDataFromJson(Map<String, dynamic> json) => KTasksData(
  page: (json['page'] as num?)?.toInt(),
  pagesCount: (json['pages_count'] as num?)?.toInt(),
  rowsCount: (json['rows_count'] as num?)?.toInt(),
  rowsTotalCount: (json['rows_total_count'] as num?)?.toInt(),
  rows: (json['rows'] as List<dynamic>?)
      ?.map((e) => KTask.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$KTasksDataToJson(KTasksData instance) =>
    <String, dynamic>{
      'page': instance.page,
      'pages_count': instance.pagesCount,
      'rows_count': instance.rowsCount,
      'rows_total_count': instance.rowsTotalCount,
      'rows': instance.rows,
    };
