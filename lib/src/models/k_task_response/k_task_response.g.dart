// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'k_task_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

KTasksResponse _$KTasksResponseFromJson(Map<String, dynamic> json) =>
    KTasksResponse(
      messages: json['MESSAGES'] == null
          ? null
          : KTasksMessages.fromJson(json['MESSAGES'] as Map<String, dynamic>),
      data: json['DATA'] == null
          ? null
          : KTasksData.fromJson(json['DATA'] as Map<String, dynamic>),
      status: json['STATUS'] as String?,
    );

Map<String, dynamic> _$KTasksResponseToJson(KTasksResponse instance) =>
    <String, dynamic>{
      'MESSAGES': instance.messages,
      'DATA': instance.data,
      'STATUS': instance.status,
    };
