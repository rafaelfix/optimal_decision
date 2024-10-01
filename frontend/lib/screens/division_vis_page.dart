import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../widgets/number_grid.dart';

class DivisionVisPage extends StatefulWidget {
  final int x;
  final int y;
  final int z;
  final int dividerPos;
  final bool horizontalDivider;

  const DivisionVisPage({
    Key? key,
    required this.x,
    required this.y,
    required this.z,
    required this.dividerPos,
    required this.horizontalDivider,
  }) : super(key: key);

  @override
  _DivisionVisPageState createState() => _DivisionVisPageState();
}

class _DivisionVisPageState extends State<DivisionVisPage> {
  // TODO: change to Theme.of(context)...
  Color primaryBallColor = Colors.green; // Colors.lightGreen[500] as Color;
  Color primaryBackgroundColor =
      Colors.green[200] as Color; //Colors.lightGreen[200] as Color;
  Color secondaryBallColor =
      Colors.green[100] as Color; //Colors.lightGreen[100] as Color;
  Color secondaryBackgroundColor = Colors.transparent;

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      print(widget.z.toString());
    }
    Widget gridSection = Padding(
      padding: const EdgeInsets.all(16.0),
      child: AspectRatio(
        aspectRatio: (widget.z + 1) / widget.y,
        child: Row(
          children: [
            Flexible(
              flex: 1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  for (int i = 0; i < widget.y; i++)
                    const Expanded(
                      child: FittedBox(
                        fit: BoxFit.fitWidth,
                        child: Icon(Icons.boy),
                      ),
                    )
                ],
              ),
            ),
            Flexible(
              flex: widget.z,
              child: DividedNumberGrid(
                x: widget.z,
                y: widget.y,
                dividerPos: widget.dividerPos,
                primaryBallColor: primaryBallColor,
                primaryBackgroundColor: primaryBackgroundColor,
                secondaryBallColor: secondaryBallColor,
                secondaryBackgroundColor: secondaryBackgroundColor,
              ),
            ),
          ],
        ),
      ),
    );

    double fontSize = 32;
    Widget equationSection = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // TODO: Replace with RichText for nice formatting.
        // TODO: Maybe latex package? Try RichText first though
        Text(
          widget.x.toString(),
          style: TextStyle(fontSize: fontSize),
        ),
        Text(
          ' / ',
          style: TextStyle(fontSize: fontSize),
        ),
        Text(
          widget.y.toString(),
          style: TextStyle(fontSize: fontSize),
        ),
        Text(
          ' = (',
          style: TextStyle(fontSize: fontSize),
        ),
        Text(
          widget.y.toString(),
          style: TextStyle(
              decoration: TextDecoration.lineThrough,
              decorationThickness: 2,
              fontSize: fontSize),
        ),
        Text(
          ' * ',
          style: TextStyle(fontSize: fontSize),
        ),
        Text(
          widget.z.toString(),
          style: TextStyle(fontSize: fontSize),
        ),
        Text(
          ') / ',
          style: TextStyle(fontSize: fontSize),
        ),
        Text(
          widget.y.toString(),
          style: TextStyle(
              decoration: TextDecoration.lineThrough,
              decorationThickness: 2,
              fontSize: fontSize),
        ),
        Text(
          ' = ',
          style: TextStyle(fontSize: fontSize),
        ),
        Text(
          widget.z.toString(),
          style: TextStyle(fontSize: fontSize),
        ),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "${widget.x} / ${widget.y}",
        ),
      ),
      body: Column(
        children: [
          Flexible(
            flex: 2,
            child: gridSection,
          ),
          Expanded(
            flex: 1,
            child: equationSection,
          ),
        ],
      ),
    );
  }
}
