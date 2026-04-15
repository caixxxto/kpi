import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'k_task.g.dart';

@JsonSerializable()
class KTask extends Equatable {
  @JsonKey(name: 'name')
  final String? name;
  @JsonKey(name: 'indicator_to_mo_id')
  final int? indicatorToMoId;
  @JsonKey(name: 'parent_id')
  final int? parentId;
  @JsonKey(name: 'order')
  final int? order;

  const KTask({this.name, this.indicatorToMoId, this.parentId, this.order});

  KTask copyWith({
    String? name,
    int? indicatorToMoId,
    int? parentId,
    int? order,
  }) {
    return KTask(
      name: name ?? this.name,
      indicatorToMoId: indicatorToMoId ?? this.indicatorToMoId,
      parentId: parentId ?? this.parentId,
      order: order ?? this.order,
    );
  }

  @override
  List<Object?> get props => [name, indicatorToMoId, parentId, order];

  factory KTask.fromJson(Map<String, dynamic> json) => _$KTaskFromJson(json);

  Map<String, dynamic> toJson() => _$KTaskToJson(this);
}
