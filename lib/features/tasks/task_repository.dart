import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:uniguide/core/content/content_repository.dart';
import 'package:uniguide/core/content/student_guide_content.dart';

const _customTasksKey = 'uniguide_custom_tasks_v1';
const _taskStatusOverridesKey = 'uniguide_task_status_overrides_v1';

enum TaskStatus { pending, inProgress, done }

extension TaskStatusX on TaskStatus {
  String get storageValue => name;

  static TaskStatus fromStorage(String? value) {
    switch (value) {
      case 'inProgress':
        return TaskStatus.inProgress;
      case 'done':
        return TaskStatus.done;
      default:
        return TaskStatus.pending;
    }
  }
}

class TaskRecord {
  const TaskRecord({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
    required this.status,
    required this.createdAt,
    this.dueDate,
    this.notes,
    this.pinned = false,
    this.isCustom = false,
  });

  factory TaskRecord.fromBuiltIn(
    StudentTask task, {
    TaskStatus status = TaskStatus.pending,
  }) {
    return TaskRecord(
      id: task.id,
      title: task.title,
      description: task.description,
      category: task.category,
      priority: task.priority,
      status: status,
      createdAt: DateTime.now(),
    );
  }

  factory TaskRecord.fromJson(Map<String, dynamic> json) {
    return TaskRecord(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      category: _categoryFromString(json['category'] as String?),
      priority: (json['priority'] as num?)?.toInt() ?? 1,
      status: TaskStatusX.fromStorage(json['status'] as String?),
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      dueDate: DateTime.tryParse(json['dueDate'] as String? ?? ''),
      notes: json['notes'] as String?,
      pinned: json['pinned'] as bool? ?? false,
      isCustom: json['isCustom'] as bool? ?? true,
    );
  }

  factory TaskRecord.fromTemplate(
    Map<String, dynamic> json, {
    TaskStatus status = TaskStatus.pending,
  }) {
    return TaskRecord(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      category: _categoryFromString(json['category']?.toString()),
      priority: int.tryParse(json['priority']?.toString() ?? '') ?? 1,
      status: status,
      createdAt: DateTime.now(),
      isCustom: false,
    );
  }

  final String id;
  final String title;
  final String description;
  final GuideCategory category;
  final int priority;
  final TaskStatus status;
  final DateTime createdAt;
  final DateTime? dueDate;
  final String? notes;
  final bool pinned;
  final bool isCustom;

  bool get isDone => status == TaskStatus.done;

  bool get isOverdue {
    final dueDateValue = dueDate;
    if (dueDateValue == null || isDone) return false;
    final today = DateUtils.dateOnly(DateTime.now());
    return DateUtils.dateOnly(dueDateValue).isBefore(today);
  }

  bool get isDueSoon {
    final dueDateValue = dueDate;
    if (dueDateValue == null || isDone) return false;
    final today = DateUtils.dateOnly(DateTime.now());
    final due = DateUtils.dateOnly(dueDateValue);
    return !due.isBefore(today) && due.difference(today).inDays <= 3;
  }

  TaskRecord copyWith({
    String? title,
    String? description,
    GuideCategory? category,
    int? priority,
    TaskStatus? status,
    DateTime? createdAt,
    DateTime? dueDate,
    String? notes,
    bool? pinned,
    bool? isCustom,
  }) {
    return TaskRecord(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
      notes: notes ?? this.notes,
      pinned: pinned ?? this.pinned,
      isCustom: isCustom ?? this.isCustom,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'description': description,
      'category': category.name,
      'priority': priority,
      'status': status.storageValue,
      'createdAt': createdAt.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'notes': notes,
      'pinned': pinned,
      'isCustom': isCustom,
    };
  }
}

class TaskDashboard {
  const TaskDashboard({required this.tasks});

  final List<TaskRecord> tasks;

  int get totalCount => tasks.length;
  int get completedCount => tasks.where((task) => task.isDone).length;
  int get pendingCount => tasks.where((task) => task.status == TaskStatus.pending).length;
  int get inProgressCount =>
      tasks.where((task) => task.status == TaskStatus.inProgress).length;
  int get customCount => tasks.where((task) => task.isCustom).length;
  int get overdueCount => tasks.where((task) => task.isOverdue).length;
  int get dueSoonCount => tasks.where((task) => task.isDueSoon).length;

  double get progress => totalCount == 0 ? 0 : completedCount / totalCount;

  TaskRecord? get nextAction {
    for (final task in tasks) {
      if (!task.isDone) {
        return task;
      }
    }
    return null;
  }
}

class TaskRepository {
  TaskRepository._();

  static final TaskRepository instance = TaskRepository._();

  Future<TaskDashboard> load(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    final overrides = _readStatusOverrides(prefs);
    final remoteTasks = ContentRepository.instance.tasks(locale.languageCode);
    final builtInTasks = remoteTasks != null && remoteTasks.isNotEmpty
        ? remoteTasks
            .map(
              (task) => TaskRecord.fromTemplate(
                task,
                status: TaskStatusX.fromStorage(overrides[task['id']?.toString() ?? '']),
              ),
            )
            .toList()
        : StudentGuideContent.tasks(locale)
            .map(
              (task) => TaskRecord.fromBuiltIn(
                task,
                status: TaskStatusX.fromStorage(overrides[task.id]),
              ),
            )
            .toList();
    final customTasks = _readCustomTasks(prefs);
    final merged = [...builtInTasks, ...customTasks]..sort(_sortTasks);
    return TaskDashboard(tasks: merged);
  }

  Future<void> setStatus(String taskId, TaskStatus status) async {
    final prefs = await SharedPreferences.getInstance();
    final customTasks = _readCustomTasks(prefs);
    final customIndex = customTasks.indexWhere((task) => task.id == taskId);
    if (customIndex != -1) {
      customTasks[customIndex] = customTasks[customIndex].copyWith(status: status);
      await _writeCustomTasks(prefs, customTasks);
      return;
    }
    final overrides = _readStatusOverrides(prefs);
    overrides[taskId] = status.storageValue;
    await prefs.setString(_taskStatusOverridesKey, jsonEncode(overrides));
  }

  Future<void> saveCustomTask(TaskRecord task) async {
    final prefs = await SharedPreferences.getInstance();
    final customTasks = _readCustomTasks(prefs);
    final index = customTasks.indexWhere((item) => item.id == task.id);
    final updatedTask = task.copyWith(isCustom: true);
    if (index == -1) {
      customTasks.insert(0, updatedTask);
    } else {
      customTasks[index] = updatedTask;
    }
    await _writeCustomTasks(prefs, customTasks);
  }

  Future<void> deleteCustomTask(String taskId) async {
    final prefs = await SharedPreferences.getInstance();
    final customTasks = _readCustomTasks(prefs)
      ..removeWhere((task) => task.id == taskId);
    await _writeCustomTasks(prefs, customTasks);
  }

  Future<void> setPinned(String taskId, bool pinned) async {
    final prefs = await SharedPreferences.getInstance();
    final customTasks = _readCustomTasks(prefs);
    final customIndex = customTasks.indexWhere((task) => task.id == taskId);
    if (customIndex != -1) {
      customTasks[customIndex] = customTasks[customIndex].copyWith(pinned: pinned);
      await _writeCustomTasks(prefs, customTasks);
    }
  }

  Future<void> resetProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_taskStatusOverridesKey);
    final customTasks = _readCustomTasks(prefs);
    final cleared = customTasks.map((task) => task.copyWith(status: TaskStatus.pending)).toList();
    await _writeCustomTasks(prefs, cleared);
  }

  List<TaskRecord> _readCustomTasks(SharedPreferences prefs) {
    final rawItems = prefs.getStringList(_customTasksKey) ?? const <String>[];
    return rawItems
        .map((item) => TaskRecord.fromJson(jsonDecode(item) as Map<String, dynamic>))
        .toList();
  }

  Map<String, String> _readStatusOverrides(SharedPreferences prefs) {
    final raw = prefs.getString(_taskStatusOverridesKey);
    if (raw == null || raw.isEmpty) {
      return <String, String>{};
    }
    final decoded = jsonDecode(raw);
    if (decoded is Map<String, dynamic>) {
      return decoded.map((key, value) => MapEntry(key, value.toString()));
    }
    return <String, String>{};
  }

  Future<void> _writeCustomTasks(
    SharedPreferences prefs,
    List<TaskRecord> tasks,
  ) async {
    await prefs.setStringList(
      _customTasksKey,
      tasks.map((task) => jsonEncode(task.toJson())).toList(),
    );
  }

  int _sortTasks(TaskRecord a, TaskRecord b) {
    if (a.pinned != b.pinned) {
      return a.pinned ? -1 : 1;
    }
    if (a.isDone != b.isDone) {
      return a.isDone ? 1 : -1;
    }
    if (a.isOverdue != b.isOverdue) {
      return a.isOverdue ? -1 : 1;
    }
    final dueA = a.dueDate;
    final dueB = b.dueDate;
    if (dueA != null && dueB != null) {
      final dueComparison = dueA.compareTo(dueB);
      if (dueComparison != 0) return dueComparison;
    } else if (dueA != null) {
      return -1;
    } else if (dueB != null) {
      return 1;
    }
    final priorityComparison = a.priority.compareTo(b.priority);
    if (priorityComparison != 0) return priorityComparison;
    return b.createdAt.compareTo(a.createdAt);
  }
}

GuideCategory _categoryFromString(String? value) {
  switch (value) {
    case 'preArrival':
      return GuideCategory.preArrival;
    case 'afterArrival':
      return GuideCategory.afterArrival;
    case 'banking':
      return GuideCategory.banking;
    case 'housing':
      return GuideCategory.housing;
    case 'universityLife':
      return GuideCategory.universityLife;
    case 'transport':
      return GuideCategory.transport;
    case 'studentTips':
      return GuideCategory.studentTips;
    case 'maps':
      return GuideCategory.maps;
    default:
      return GuideCategory.afterArrival;
  }
}
