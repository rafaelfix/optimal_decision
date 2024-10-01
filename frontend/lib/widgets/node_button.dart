import 'package:flutter/material.dart';
import 'package:olle_app/functions/map_data.dart';
import 'package:olle_app/functions/operator_information.dart';
import 'package:olle_app/screens/practice.dart';
import 'package:olle_app/widgets/navigate_button.dart';

/// A Widget that decides what slot a [NodeButton] should be in.
/// These [NodeButton] can navigate to the [PracticePage]
/// * [Node] Represent all information about the node
/// * [currentLevelMap] Represent the level of the current user
/// * [totalSlots] Represent how many slots are available in a row
class NodeSlot extends StatelessWidget {
  const NodeSlot({
    Key? key,
    required this.node,
    required this.currentLevelMap,
    required this.totalSlots,
    required this.widgetSize,
  }) : super(key: key);

  final Node node;
  final Map<String, int> currentLevelMap;
  final int totalSlots;
  final double widgetSize;

  double get scale => 1 / totalSlots;
  int get screenSlot => node.screenSlot.clamp(0, totalSlots - 1);
  String get operator => node.operator;
  Map<String, int> get lockLevel => node.lockLevelMap;
  int get maxLevel => node.maxLevel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: widgetSize * scale * screenSlot,
        ),
        SizedBox(
          width: widgetSize * scale,
          height: widgetSize * scale,
          child: NodeButton(
            currentLevelMap: currentLevelMap,
            node: node,
          ),
        ),
        SizedBox(
          width: widgetSize * scale * (totalSlots - 1 - screenSlot),
        )
      ],
    );
  }
}

/// [NodeButton] Navigates the user to the correct [PracticePage] depending on
/// the entered [Node].
/// [currentLevelMap] decides if the button is locked or not.
/// Uses [NavigateButton].
/// Is used both in [NodeSlot] and [TrainingPage].
class NodeButton extends StatelessWidget {
  const NodeButton(
      {super.key, required this.node, required this.currentLevelMap});

  final Node node;
  final Map<String, int> currentLevelMap;
  final double scale = 1;

  String get operator => node.operator;
  Map<String, int> get lockLevel => node.lockLevelMap;
  int get maxLevel => node.maxLevel;

  /// Calculates the progress from [lockLevel] to [maxLevel].
  double _calculateProgress() {
    return ((currentLevelMap[operator]! - lockLevel[operator]!) /
            (maxLevel - lockLevel[operator]!))
        .clamp(0.0, 1.0);
  }

  /// Calculates if a button should be locked or not
  ///
  /// Makes sure that every level is in between the correct span
  bool _isLocked() {
    for (String lockOperator in lockLevel.keys) {
      if (!currentLevelMap.containsKey(lockOperator)) continue;

      /// If one of the levels are lower than the lock => Return True
      if (currentLevelMap[lockOperator]! < lockLevel[lockOperator]!) {
        return true;
      }
    }

    /// If the current level for the operator are bigger than the max => True
    /// else False
    return _isCompleted();
  }

  bool _isCompleted() {
    if (!currentLevelMap.containsKey(operator)) return false;

    return currentLevelMap[operator]! >= maxLevel;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double widgetSize = constraints.maxWidth;
        return Stack(
          children: [
            (!_isLocked() || _isCompleted())
                ? Positioned.fill(
                    child: CircularProgressIndicator(
                      value: _calculateProgress(),
                      backgroundColor:
                          OperatorHandler.toColor[operator]!.withAlpha(120),
                      color: Color.alphaBlend(
                          Colors.black26, OperatorHandler.toColor[operator]!),
                      strokeWidth: widgetSize * scale * 0.15,
                    ),
                  )
                : Container(),
            NavigateButton(
              title: OperatorHandler.toUnicode[operator]!,
              page: PracticePage(title: operator),
              locked: _isLocked(),
              icon: OperatorHandler.toIcon[operator],
              color: OperatorHandler.toColor[operator],
              completed: _isCompleted(),
            ),
            Visibility(
              visible: !_isCompleted() && !_isLocked(),
              child: Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 1.0, 1.0, 0),
                  child: Transform.rotate(
                    angle: -2.3,
                    child: Transform.scale(
                      scale: 1.8,
                      child: const Icon(Icons.touch_app_outlined),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
