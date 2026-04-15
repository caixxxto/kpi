import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'k_messages.g.dart';

@JsonSerializable()
class KTasksMessages extends Equatable {
  final String? error;
  final String? warning;
  final String? info;

  const KTasksMessages({this.error, this.warning, this.info});

  @override
  List<Object?> get props => [error, warning, info];

  factory KTasksMessages.fromJson(Map<String, dynamic> json) =>
      _$KTasksMessagesFromJson(json);

  Map<String, dynamic> toJson() => _$KTasksMessagesToJson(this);
}
