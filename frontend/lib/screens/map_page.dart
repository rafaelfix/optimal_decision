import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:olle_app/functions/map_data.dart';
import 'package:olle_app/functions/profiles.dart';
import 'package:olle_app/screens/training_page.dart';

import 'package:olle_app/widgets/node_button.dart';
import 'package:provider/provider.dart';

/// A widget that is used to select what to practice.
///
/// The widget is dependant on [NodeHandler] having a predetermined set of
/// [Node]'s to challange. Using the [NodeHandler], [MapPage] Draws
/// a number of [Node]'s that have locks to simulate difficulty more
/// The destination is the same but the visual feedback of progressing
/// is mean to help boost excitement
class MapPage extends StatelessWidget {
  const MapPage({Key? key}) : super(key: key);

  final double _spacer = 20;

  double _calcHeight(double pos, BuildContext context) {
    return ((MediaQuery.of(context).size.width - (2 * 20)) / 5 * pos);
  }

  void _onTrainingPressed(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        settings: const RouteSettings(name: "/training"),
        builder: (context) => const TrainingPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.school_rounded),
          onPressed: () {
            _onTrainingPressed(context);
          }),
      body: SingleChildScrollView(
        physics:
            const ClampingScrollPhysics(), // Prevent scrolling past the boundaries
        child: Stack(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: const AssetImage('assets/icons/grass.png'),
                  repeat: ImageRepeat.repeatY,
                  fit: BoxFit.fitWidth,
                  colorFilter: ColorFilter.mode(
                    Colors.grey.withOpacity(0.5),
                    BlendMode.lighten,
                  ),
                ),
              ),
              child: Stack(
                children: [
                  //image
                  Positioned(
                    top: 20,
                    right: MediaQuery.of(context).size.width * 0.05,
                    child: Transform.rotate(
                      angle: 10 * 3.141592653589793 / 180,
                      child: Image.asset('assets/icons/Tree.png',
                          width: 100, height: 100),
                    ),
                  ),
                  Positioned(
                    top: _calcHeight(2.5, context),
                    left: MediaQuery.of(context).size.width * 0.05,
                    child: Transform.rotate(
                      angle: -7 * 3.141592653589793 / 180,
                      child: Image.asset('assets/icons/Tree.png',
                          width: 90, height: 90),
                    ),
                  ),
                  Positioned(
                    top: _calcHeight(4, context),
                    right: MediaQuery.of(context).size.width * 0.05,
                    child: Transform.rotate(
                      angle: 7 * 3.141592653589793 / 180,
                      child: Image.asset('assets/icons/Tree2.png',
                          width: 90, height: 90),
                    ),
                  ),
                  Positioned(
                    top: _calcHeight(6.5, context),
                    right: MediaQuery.of(context).size.width * 0.05,
                    child: Transform.rotate(
                      angle: 10 * 3.141592653589793 / 180,
                      child: Image.asset('assets/icons/Tree3.png',
                          width: 60, height: 60),
                    ),
                  ),
                  Positioned(
                    top: _calcHeight(8, context),
                    left: MediaQuery.of(context).size.width * 0.25,
                    child: Transform.rotate(
                      angle: -20 * 3.141592653589793 / 180,
                      child: Image.asset('assets/icons/Tree1.png',
                          width: 60, height: 60),
                    ),
                  ),
                  Positioned(
                    top: _calcHeight(12.5, context),
                    left: MediaQuery.of(context).size.width * 0.75,
                    child: Transform.rotate(
                      angle: 10 * 3.141592653589793 / 180,
                      child: Image.asset('assets/icons/Tree1.png',
                          width: 60, height: 60),
                    ),
                  ),
                  Positioned(
                    top: _calcHeight(15, context),
                    left: MediaQuery.of(context).size.width * 0.1,
                    child: Transform.rotate(
                      angle: -10 * 3.141592653589793 / 180,
                      child: Image.asset('assets/icons/Tree.png',
                          width: 100, height: 100),
                    ),
                  ),
                  Positioned(
                    top: _calcHeight(17.5, context),
                    right: MediaQuery.of(context).size.width * 0.05,
                    child: Transform.rotate(
                      angle: 7 * 3.141592653589793 / 180,
                      child: Image.asset('assets/icons/Tree2.png',
                          width: 90, height: 90),
                    ),
                  ),
                  Positioned(
                    top: _calcHeight(19, context),
                    left: MediaQuery.of(context).size.width * 0.05,
                    child: Transform.rotate(
                      angle: 5 * 3.141592653589793 / 180,
                      child: Image.asset('assets/icons/Tree.png',
                          width: 60, height: 60),
                    ),
                  ),
                  Positioned(
                    top: _calcHeight(22, context),
                    right: MediaQuery.of(context).size.width * 0.01,
                    child: Transform.rotate(
                      angle: 5 * 3.141592653589793 / 180,
                      child: Image.asset('assets/icons/Water.png',
                          width: 140, height: 140),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: _spacer,
                      ),
                      const NodeMap(),
                      SizedBox(
                        height: _spacer,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A widget that displays a map of [NodeSlot]'s
/// Uses a set amount of [totalSlots] to spread [NodeSlot]'s according to
/// the [NodeHandler]'s [Node]'s.
/// * [totalSlots] Determine how many "slots" aswell as the size each button have
class NodeMap extends StatelessWidget {
  const NodeMap({
    Key? key,
    this.totalSlots = 5,
  }) : super(key: key);

  final int totalSlots;
  final double paddingSize = 20;

  Size _calculateSize(double width) {
    final double totalHeight = (width / totalSlots) * NodeHandler().length;

    return Size(width, totalHeight);
  }

  @override
  Widget build(BuildContext context) {
    ProfileModel profileModel = Provider.of<ProfileModel>(context);
    double width = MediaQuery.of(context).size.width - (2 * paddingSize);

    Map<String, int> levelMap = kDebugMode
        ? const {"+": 43, "p": 19, "-": 20, "*": 32, "m": 32, "/": 32}
        : profileModel.selectedProfile.levels;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: paddingSize),
      child: Stack(
        children: [
          CustomPaint(
            size: _calculateSize(width),
            painter: LinePainter(
              totalSlots: totalSlots,
              profileLevelMap: levelMap,
            ),
          ),
          Column(
            children: [
              for (Node node in NodeHandler().nodes)
                NodeSlot(
                  node: node,
                  currentLevelMap: levelMap,
                  totalSlots: totalSlots,
                  widgetSize: width,
                ),
            ],
          )
        ],
      ),
    );
  }
}

/// A widget that paints a line between two [Node]'s
/// * [totalSlots] Represent how many slots are in an row
class LinePainter extends CustomPainter {
  const LinePainter({required this.totalSlots, required this.profileLevelMap})
      : super();
  final Map<String, int> profileLevelMap;
  final int totalSlots;

  Offset _calculateOffset(screenSlot, nodeIndex, chunkSize) {
    return Offset(((screenSlot + 1) * chunkSize) - (chunkSize / 2),
        ((nodeIndex + 1) * chunkSize) - (chunkSize / 2));
  }

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final double chunkSize = size.width / totalSlots;
    final List<Node> nodes = NodeHandler().nodes;

    for (int i = 0; i < nodes.length - 1; i++) {
      final Offset start = _calculateOffset(nodes[i].screenSlot, i, chunkSize);
      final Offset end =
          _calculateOffset(nodes[i + 1].screenSlot, i + 1, chunkSize);

      const double controlPointYOffset = 110.0;
      final double startY = start.dy;
      final double endY = end.dy;

      final Offset controlPoint1 = Offset(
          start.dx + (end.dx - start.dx) / 2, startY + controlPointYOffset);
      final Offset controlPoint2 = Offset(
          start.dx + (end.dx - start.dx) / 2, endY - controlPointYOffset);

      final Path path = Path()
        ..moveTo(start.dx, startY)
        ..cubicTo(controlPoint1.dx, controlPoint1.dy, controlPoint2.dx,
            controlPoint2.dy, end.dx, endY);

      canvas.drawPath(
        path,
        Paint()
          ..color = nodes[i].maxLevel > profileLevelMap[nodes[i].operator]!
              ? Colors.black38
              : Colors.black
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
