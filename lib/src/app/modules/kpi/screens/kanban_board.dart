import 'package:flutter/material.dart';
import 'package:kpi/src/models/k_task/k_task.dart';

final Map<String, GlobalKey> _taskKeys = {};
final Map<String, double> _taskHeights = {};

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
  }

  void _deleteTask(int parentId, int taskIndex, KTask task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить карточку?'),
        content: Text('Вы уверены, что хотите удалить "${task.name}"?'),
        backgroundColor: const Color(0xFF1C1C1C),
        titleTextStyle: const TextStyle(
          color: Color(0xFFEDEDED),
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        contentTextStyle: const TextStyle(color: Color(0xFF9A9A9A)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Отмена',
              style: TextStyle(color: Color(0xFF9A9A9A)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              setState(() {
                groupedTasks[parentId]?.removeAt(taskIndex);
                _updateOrders(parentId);
              });
              Navigator.of(context).pop();
            },
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
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

                final list = tasks.where((t) {
                  return _draggingTask == null || t.name != _draggingTask!.name;
                }).toList();

                double currentY = 0;
                int newIndex = 0;

                final draggingHeight = _taskHeights[_draggingTask?.name] ?? 50;

                final adjustedOffsetY = offset.dy - draggingHeight * 1.2;

                for (int i = 0; i < list.length; i++) {
                  final task = list[i];
                  final height = _taskHeights[task.name] ?? 50;
                  final middle = currentY + height / 2;

                  if (adjustedOffsetY < middle) {
                    newIndex = i;
                    break;
                  }

                  currentY += height;
                  newIndex = i + 1;
                }

                if (_lastCalculatedIndex == newIndex &&
                    _lastCalculatedParent == parentId) {
                  return;
                }

                _lastCalculatedIndex = newIndex;
                _lastCalculatedParent = parentId;

                setState(() {
                  _currentHoverParent = parentId;
                  _currentHoverIndex = newIndex;
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

                      if (index < display.length) {
                        final task = display[index];

                        final isDragging =
                            _draggingTask != null &&
                            task.name == _draggingTask!.name;

                        final isPlaceholder =
                            _draggingTask != null &&
                            task.name == _draggingTask!.name &&
                            _currentHoverParent == parentId &&
                            index == _currentHoverIndex;

                        return AnimatedSize(
                          key: ValueKey(task.name),
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                          child: () {
                            if (isPlaceholder) {
                              return Container(
                                height: _taskHeights[task.name] ?? 50,
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              );
                            }

                            if (isDragging) {
                              return const SizedBox.shrink();
                            }

                            return _buildDraggableTaskCard(
                              parentId: parentId,
                              taskIndex: index,
                              task: task,
                            );
                          }(),
                        );
                      }
                    } else {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: GestureDetector(
                          onTap: () async {
                            final taskName = await showDialog<String>(
                              context: context,
                              builder: (context) {
                                String input = '';
                                return AlertDialog(
                                  title: const Text('Название новой карточки'),
                                  content: TextField(
                                    style: const TextStyle(color: Colors.white),
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
                                  backgroundColor: const Color(0xFF1C1C1C),
                                  titleTextStyle: const TextStyle(
                                    color: Color(0xFFEDEDED),
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                      child: const Text(
                                        'Отмена',
                                        style: TextStyle(
                                          color: Color(0xFF9A9A9A),
                                        ),
                                      ),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFF222126,
                                        ),
                                        foregroundColor: const Color(
                                          0xFFEDEDED,
                                        ),
                                      ),
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
                          child: Container(
                            margin: const EdgeInsets.only(top: 8),
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 12,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0d0d0d),
                              border: Border.all(
                                color: const Color(0xFF242424),
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(0),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add,
                                  color: Color(0xFF9A9A9A),
                                  size: 18,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Добавить карточку',
                                  style: TextStyle(
                                    color: Color(0xFF9A9A9A),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
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
        child: SizedBox(
          width: 320,
          child: _buildTaskCard(task, parentId, taskIndex),
        ),
      ),
      childWhenDragging: const SizedBox.shrink(),
      child: _buildTaskCard(task, parentId, taskIndex),
    );
  }

  Widget _buildTaskCard(KTask task, int parentId, int taskIndex) {
    final key = _taskKeys.putIfAbsent(task.name!, () => GlobalKey());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = key.currentContext;
      if (ctx != null) {
        final box = ctx.findRenderObject() as RenderBox;
        _taskHeights[task.name!] = box.size.height;
      }
    });

    return Container(
      key: key,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFF0d0d0d)),
      child: Row(
        children: [
          Expanded(
            child: Text(
              task.name ?? 'Без названия',
              style: const TextStyle(color: Color(0xFFEDEDED)),
            ),
          ),
        ],
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
