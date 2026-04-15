import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:kpi/src/models/k_task/k_task.dart';

part 'k_task_data.g.dart';

@JsonSerializable()
class KTasksData extends Equatable {
  @JsonKey(name: 'page')
  final int? page;
  @JsonKey(name: 'pages_count')
  final int? pagesCount;
  @JsonKey(name: 'rows_count')
  final int? rowsCount;
  @JsonKey(name: 'rows_total_count')
  final int? rowsTotalCount;
  @JsonKey(name: 'rows')
  final List<KTask>? rows;

  const KTasksData({
    this.page,
    this.pagesCount,
    this.rowsCount,
    this.rowsTotalCount,
    this.rows,
  });

  @override
  List<Object?> get props => [
    page,
    pagesCount,
    rowsCount,
    rowsTotalCount,
    rows,
  ];

  factory KTasksData.fromJson(Map<String, dynamic> json) =>
      _$KTasksDataFromJson(json);

  Map<String, dynamic> toJson() => _$KTasksDataToJson(this);
}
