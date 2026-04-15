import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:kpi/src/models/k_messages/k_messages.dart';
import 'package:kpi/src/models/k_task_data/k_task_data.dart';

part 'k_task_response.g.dart';

@JsonSerializable()
class KTasksResponse extends Equatable {
  @JsonKey(name: 'MESSAGES')
  final KTasksMessages? messages;
  @JsonKey(name: 'DATA')
  final KTasksData? data;
  @JsonKey(name: 'STATUS')
  final String? status;

  const KTasksResponse({this.messages, this.data, this.status});

  static const empty = KTasksResponse();

  @override
  List<Object?> get props => [messages, data, status];

  factory KTasksResponse.fromJson(Map<String, dynamic> json) =>
      _$KTasksResponseFromJson(json);

  Map<String, dynamic> toJson() => _$KTasksResponseToJson(this);
}
