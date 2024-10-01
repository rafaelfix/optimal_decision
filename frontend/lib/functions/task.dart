import 'package:flutter/material.dart';
import 'package:nativelib/nativelib.dart';
import 'package:olle_app/functions/practice_session.dart';

/// Types of tasks
enum TaskType { add, addY, sub, mul, mulY, div }

Map<String, TaskType> taskTypeMap = {
  "+": TaskType.add,
  "p": TaskType.addY,
  "-": TaskType.sub,
  "*": TaskType.mul,
  "m": TaskType.mulY,
  "/": TaskType.div,
};

/// Representation of a task.
///
/// [date] is when the task was done.
/// [type] is the type of the task.
/// [completionTime] is the time it took to complete the task.
class Task {
  const Task({
    required this.date,
    required this.type,
    required this.completionTime,
  });
  final DateTime date;
  final TaskType type;
  final Duration completionTime;
}

/// A model that holds the tasks.
///
/// [_taskTypeFilter] is a map of [TaskType]s to booleans. Each boolean indicates
/// whether the corresponding [TaskType] is selected.
class TasksModel with ChangeNotifier {
  final Map<TaskType, bool> _taskTypeFilter = Map.fromIterables(
      TaskType.values, List.generate(TaskType.values.length, (_) => true));

  Map<TaskType, bool> get taskTypeFilter => Map.from(_taskTypeFilter);

  /// Toggles the selection of the given [TaskType].
  void toggleTaskType(TaskType taskType) {
    if (_taskTypeFilter.containsKey(taskType)) {
      _taskTypeFilter[taskType] = !_taskTypeFilter[taskType]!;
      notifyListeners();
    }
  }

  /// Toggles the selection of a [TaskType] by the given [index].
  void toggleTaskTypeByIndex(int index) {
    toggleTaskType(TaskType.values[index]);
  }
}

/// Retrieves all tasks from the native library
///
/// returns a list of [Task]s
Future<List<Task>> get allTasks async {
  String timesString = await Nativelib.call("getDataTimesStart", [0]);
  String inputsString = await Nativelib.call("getDataInputsStart", [0]);

  if (timesString.isEmpty || inputsString.isEmpty) {
    return [];
  }

  List<Task> tasks = [];

  try {
    List<int> times = timesString.split(" ").map((e) => int.parse(e)).toList();
    // Ugly workaround for new question format: Filter out empty strings,
    // because the ' ' character is now not only used as a delimiter, but also
    // as an "enum" value for the visualHelp field, so spaces are ambiguous.
    List<String> inputs =
        inputsString.split(" ").where((s) => s.isNotEmpty).toList();

    RegExp isQuestion = RegExp(r'^\d+[^\d]+\d+.?$');

    for (int i = 0; i < times.length; i++) {
      if (isQuestion.hasMatch(inputs[i])) {
        // find index of next "="
        int firstEqualIndex = inputs.indexOf("=", i);
        if (firstEqualIndex != -1) {
          final question = Question.fromXyString(inputs[i]);
          tasks.add(
            Task(
              date: DateTime.fromMillisecondsSinceEpoch(times[i]),
              type: taskTypeMap[question.questionType]!,
              completionTime:
                  Duration(milliseconds: times[firstEqualIndex] - times[i]),
            ),
          );
        }
      }
    }
  } catch (e) {
    return Future.error(e);
  }

  return tasks;
}
