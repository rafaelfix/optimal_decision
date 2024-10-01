import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nativelib/nativelib.dart';
import 'package:olle_app/functions/task.dart';
import 'package:olle_app/widgets/level_bar_graph.dart';
import 'package:provider/provider.dart';

/// Renders the statistics page.
///
/// The statistics page contains a chart with the data from the tasks.
class StatisticsPage extends StatefulWidget {
  const StatisticsPage({Key? key}) : super(key: key);

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TasksModel(),
      child: Scaffold(
        backgroundColor:
            Theme.of(context).colorScheme.primaryContainer.withAlpha(50),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const Flexible(child: LevelBarGraph()),
              kDebugMode ? Flexible(child: TextInfoField()) : Container(),
            ],
          ),
        ),
      ),
    );
  }
}

/// A toggle button that toggles the visibility of the different statistics.
///
/// Uses [Provider] to access the [TasksModel].
class StatisticsToggleButton extends StatelessWidget {
  const StatisticsToggleButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tasksModel = Provider.of<TasksModel>(context);
    return ToggleButtons(
      // TODO define icons in task.dart?
      children: taskTypeMap.keys.map((type) => Text(type)).toList(),
      isSelected:
          tasksModel.taskTypeFilter.values.toList(), //list of all buttons value
      onPressed: (int index) {
        tasksModel.toggleTaskTypeByIndex(index);
      },
    );
  }
}

/// Simple text field used for sharing styling of table items in [TextInfoField].
///
/// [text] is what to display.
///
/// [header] determines if it is to be used as a header or not.
///
/// headers are shown in bold.
///
/// TODO: replace this with theme?
class TextInfoItem extends StatelessWidget {
  const TextInfoItem({Key? key, required this.text, this.header = false})
      : super(key: key);
  final String text;
  final bool header;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style:
          TextStyle(fontWeight: header ? FontWeight.bold : FontWeight.normal),
    );
  }
}

/// Table showing info for each operand.
///
/// Info can be configured in [_getInfo] by adding a header and a function
/// that returns a printable value from a given task type.
///
/// first value of [_getInfo] are the column headers.
///
/// The task types from [taskTypeMap] are shown as row headers.
///
/// Each item uses [TextInfoItem]
class TextInfoField extends StatelessWidget {
  TextInfoField({Key? key}) : super(key: key);

  final Map<String, Function> _getInfo = {
    "Level": (taskType) async => await Nativelib.call("getLevel", [taskType]),
    // NOTE: It's easy to misinterpret the return value of optQ::statusTime as representing
    // some kind of time or duration, but in reality it is the maximum weight value
    // in the priority matrix, which does not seem to be related to time (at least, not directly).
    // Not very useful for the end user, but is provided as debug information nonetheless.
    "StatusTime": (taskType) async =>
        (await Nativelib.call("statusTime", [taskType]) as double)
            .toStringAsFixed(3),
    // NOTE: It's easy to misinterpret the return value of optQ::correctString as meaning
    // "Correct/(Total-Visualizations)", but in reality it means "Correct/Total".
    // That is to say, visualizations will look like incorrect answers, since a correct answer
    // cannot be given to visualHelp questions, but it still counts toward the total.
    // Not very useful for the end user, but is provided as debug information nonetheless.
    "CorrectString": (taskType) async =>
        await Nativelib.call("correctString", [taskType])
  };

  /// Creates data based on [_getInfo]
  ///
  /// Operand is added to the front of the list
  ///
  /// This function is async so that the data from [_getInfo] can be async
  ///
  /// returns the data of the complete table, but not the header, in the format
  /// Table[Row[Item...]...], Item is a dynamic type, but has to be printable.
  ///
  /// Note that this only returns the raw data, and not the Widget components
  /// needed to construct the table.
  Future<List<List<dynamic>>> _getData() async {
    var data = <List<dynamic>>[];

    for (var operand in taskTypeMap.keys) {
      // since getLevel and statusTime has no operand argument and only uses the current level
      var info = <dynamic>[];
      for (var key in _getInfo.keys) {
        info.add(await _getInfo[key]!(operand));
      }
      data.add([operand, ...info]);
    }

    return data;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getData(),
      builder: (BuildContext context,
          AsyncSnapshot<Iterable<List<dynamic>>> snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        final statistics = snapshot.requireData;
        // NOTE: "Operator" is a bit misleading since in reality, this shows
        // the task/question types. For example, both the "+" and "p" task/question types
        // have the same operator. But here we are showing the task/question type, not the operator.
        // Either way, optQuestions.h calls the task/question type "operator", and this is debug
        // information, so let's just use the same name, even if it is misleading.
        final title = ["Operator", ..._getInfo.keys]
            .map((key) => TextInfoItem(text: key, header: true))
            .toList();
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Table(
              border: TableBorder.all(
                color: Colors.black,
              ),
              children: [
                TableRow(
                  children: title,
                ),
                ...statistics.map(
                  (row) => TableRow(
                    children: [
                      TextInfoItem(
                        text: row.removeAt(0),
                        header: true,
                      ),
                      ...row
                          .map((e) => TextInfoItem(text: e.toString()))
                          .toList()
                    ],
                  ),
                ),
              ]),
        );
      },
    );
  }
}
