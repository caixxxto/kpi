// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'k_messages.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

KTasksMessages _$KTasksMessagesFromJson(Map<String, dynamic> json) =>
    KTasksMessages(
      error: json['error'] as String?,
      warning: json['warning'] as String?,
      info: json['info'] as String?,
    );

Map<String, dynamic> _$KTasksMessagesToJson(KTasksMessages instance) =>
    <String, dynamic>{
      'error': instance.error,
      'warning': instance.warning,
      'info': instance.info,
    };
