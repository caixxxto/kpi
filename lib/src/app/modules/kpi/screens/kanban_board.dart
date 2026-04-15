import 'package:flutter/material.dart';
import 'package:kpi/src/models/k_task/k_task.dart';

class KanbanBoard extends StatefulWidget {
  final List<KTask> tasks;
  final Function(KTask task, int newParentId, int newOrder)? onTaskMoved;

  const KanbanBoard({super.key, required this.tasks, this.onTaskMoved});

  @override
  State<KanbanBoard> createState() => _KanbanBoardState();
}

class _KanbanBoardState extends State<KanbanBoard> {
  late Map<int, List<KTask>> groupedTasks;
  late List<int> columnIds;

  KTask? _draggingTask;
  int? _draggingFromParent;
  int? _draggingFromIndex;

  int? _currentHoverParent;
  int? _currentHoverIndex;

  int? _lastCalculatedIndex;
  int? _lastCalculatedParent;

  @override
  void initState() {
    super.initState();
    _groupTasks();
  }

  @override
  void didUpdateWidget(KanbanBoard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tasks != widget.tasks) {
      _groupTasks();
    }
  }

  void _groupTasks() {
    groupedTasks = {};

    for (final task in widget.tasks) {
      final parentId = task.parentId ?? 0;
      groupedTasks.putIfAbsent(parentId, () => []).add(task);
    }

    for (final entry in groupedTasks.entries) {
      entry.value.sort((a, b) => (a.order ?? 0).compareTo(b.order ?? 0));
    }

    columnIds = groupedTasks.keys.toList()..sort();
  }

  List<KTask> _buildPreviewList(int parentId, List<KTask> tasks) {
    if (_draggingTask == null || _currentHoverParent != parentId) {
      return tasks;
    }

    final list = List<KTask>.from(tasks);

    if (_draggingFromParent == parentId && _draggingFromIndex != null) {
      list.removeAt(_draggingFromIndex!);
    }

    final insertIndex = (_currentHoverIndex ?? list.length).clamp(
      0,
      list.length,
    );

    list.insert(insertIndex, _draggingTask!);

    return list;
  }

  void _moveTask({
    required int oldParentId,
    required int oldTaskIndex,
    required int newParentId,
    required int newTaskIndex,
    required List<KTask> tasks,
  }) {
    setState(() {
      final task = groupedTasks[oldParentId]!.removeAt(oldTaskIndex);
      final updated = task.copyWith(parentId: newParentId);

      final safeIndex = newTaskIndex.clamp(
        0,
        groupedTasks[newParentId]!.length,
      );

      groupedTasks[newParentId]!.insert(safeIndex, updated);

      _updateOrders(oldParentId);
      _updateOrders(newParentId);

      _draggingTask = null;
      _draggingFromParent = null;
      _draggingFromIndex = null;
      _currentHoverIndex = null;
      _currentHoverParent = null;
    });

    //context.read<KpiController>().saveOrder(newParentId, tasks[newTaskIndex].name ?? '');
  }

  void _updateOrders(int parentId) {
    final list = groupedTasks[parentId];
    if (list == null) return;

    for (int i = 0; i < list.length; i++) {
      list[i] = list[i].copyWith(order: i);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: columnIds.map((id) {
            return _buildColumn(id, groupedTasks[id]!);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildColumn(int parentId, List<KTask> tasks) {
    return Container(
      width: 320,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1C1C1C), width: 0),
      ),
      child: Column(
        children: [
          _buildHeader(parentId, tasks),
          Expanded(
            child: DragTarget<TaskDragData>(
              onMove: (details) {
                final box = context.findRenderObject() as RenderBox;
                final offset = box.globalToLocal(details.offset);

                const itemHeight = 53.0;

                final index = (offset.dy / itemHeight).floor().clamp(
                  0,
                  tasks.length,
                );

                if (_lastCalculatedIndex == index &&
                    _lastCalculatedParent == parentId) {
                  return;
                }

                _lastCalculatedIndex = index;
                _lastCalculatedParent = parentId;

                setState(() {
                  _currentHoverParent = parentId;
                  _currentHoverIndex = index;
                });
              },
              onAccept: (data) {
                _moveTask(
                  oldParentId: data.parentId,
                  oldTaskIndex: data.taskIndex,
                  newParentId: parentId,
                  newTaskIndex: _currentHoverIndex ?? tasks.length,
                  tasks: tasks,
                );
              },
              builder: (context, _, __) {
                final display = _buildPreviewList(parentId, tasks);

                return ListView.builder(
                  padding: const EdgeInsets.all(0),
                  itemCount: display.length + 1,
                  itemBuilder: (context, index) {
                    if (index < display.length) {
                      final task = display[index];

                      final isDragging =
                          _draggingTask != null &&
                          task.name == _draggingTask!.name;

                      return AnimatedSize(
                        key: ValueKey(task.name),
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                        child: isDragging
                            ? Opacity(
                                opacity: 0.35,
                                child: SizedBox(height: 30),
                              )
                            : _buildDraggableTaskCard(
                                parentId: parentId,
                                taskIndex: index,
                                task: task,
                              ),
                      );
                    } else {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF222126),
                          ),
                          onPressed: () async {
                            final taskName = await showDialog<String>(
                              context: context,
                              builder: (context) {
                                String input = '';
                                return AlertDialog(
                                  title: const Text('Название новой карточки'),
                                  content: TextField(
                                    autofocus: true,
                                    decoration: const InputDecoration(
                                      hintText: 'Введите название',
                                    ),
                                    onChanged: (value) {
                                      input = value;
                                    },
                                    onSubmitted: (value) {
                                      Navigator.of(context).pop(value);
                                    },
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                      child: const Text('Отмена'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(input),
                                      child: const Text('Добавить'),
                                    ),
                                  ],
                                );
                              },
                            );

                            if (taskName != null &&
                                taskName.trim().isNotEmpty) {
                              setState(() {
                                final newTask = KTask(
                                  name: taskName.trim(),
                                  parentId: parentId,
                                  order: groupedTasks[parentId]?.length ?? 0,
                                );
                                groupedTasks[parentId]?.add(newTask);
                                _updateOrders(parentId);
                              });
                            }
                          },
                          child: const Text('Добавить карточку'),
                        ),
                      );
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(int parentId, List<KTask> tasks) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(color: Color(0xFF222126)),
      child: Row(
        children: [
          Expanded(
            child: Text(
              _getColumnName(parentId),
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFFE6E6E6),
                fontSize: 14,
              ),
            ),
          ),
          Text(
            '${tasks.length}',
            style: const TextStyle(color: Color(0xFF9A9A9A)),
          ),
        ],
      ),
    );
  }

  String _getColumnName(int parentId) {
    switch (parentId) {
      case 4255:
        return '📌 Входящие';

      case 4257:
        return '📁 Задачи';

      case 317651:
        return '⚙️ В работе';

      case 318139:
        return '🔍 На проверке';

      case 318200:
        return '⏳ В ожидании';

      case 318192:
        return '🚀 В приоритете';

      case 318019:
        return '✅ Готово';

      case 317719:
        return '🧊 Архив';

      default:
        return '📁 Без категории';
    }
  }

  Widget _buildDraggableTaskCard({
    required int parentId,
    required int taskIndex,
    required KTask task,
  }) {
    return Draggable<TaskDragData>(
      data: TaskDragData(parentId: parentId, taskIndex: taskIndex, task: task),
      onDragStarted: () {
        setState(() {
          _draggingTask = task;
          _draggingFromParent = parentId;
          _draggingFromIndex = taskIndex;
        });
      },
      onDragEnd: (_) {
        setState(() {
          _draggingTask = null;
          _currentHoverIndex = null;
          _currentHoverParent = null;
        });
      },
      feedback: Material(
        color: Colors.transparent,
        child: SizedBox(width: 320, child: _buildTaskCard(task)),
      ),
      childWhenDragging: const SizedBox.shrink(),
      child: _buildTaskCard(task),
    );
  }

  Widget _buildTaskCard(KTask task) {
    return Container(
      margin: const EdgeInsets.only(bottom: 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0d0d0d),
        border: Border.all(color: const Color(0xFF242424), width: 0),
      ),
      child: Text(
        task.name ?? 'Без названия',
        style: const TextStyle(color: Color(0xFFEDEDED), fontSize: 14),
      ),
    );
  }
}

class TaskDragData {
  final int parentId;
  final int taskIndex;
  final KTask task;

  TaskDragData({
    required this.parentId,
    required this.taskIndex,
    required this.task,
  });
}
