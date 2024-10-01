import 'package:flutter/cupertino.dart';

const scalar = 0.8;
const doubleIconScalar = 0.6;

/// This file is creating all the icons for the different math operators
/// The reason for this is becouse of the operators with unknown variables
/// These "icons" consists of two symbols resulting in a more complex structure

class AddIcon extends StatelessWidget {
  const AddIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraint) {
      return Icon(CupertinoIcons.add, size: constraint.maxWidth * scalar);
    });
  }
}

class AddyIcon extends StatelessWidget {
  const AddyIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraint) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(CupertinoIcons.add,
              size: constraint.maxWidth * doubleIconScalar),
          Icon(CupertinoIcons.multiply,
              size: constraint.maxWidth * (1 - doubleIconScalar))
        ],
      );
    });
  }
}

class SubIcon extends StatelessWidget {
  const SubIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraint) {
      return Icon(CupertinoIcons.minus, size: constraint.maxWidth * scalar);
    });
  }
}

class MulIcon extends StatelessWidget {
  const MulIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraint) {
      return Icon(CupertinoIcons.multiply, size: constraint.maxWidth * scalar);
    });
  }
}

class MulyIcon extends StatelessWidget {
  const MulyIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraint) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Icon(CupertinoIcons.multiply,
              size: constraint.maxWidth * doubleIconScalar),
          Icon(CupertinoIcons.multiply,
              size: constraint.maxWidth * (1 - doubleIconScalar))
        ],
      );
    });
  }
}

class DivIcon extends StatelessWidget {
  const DivIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraint) {
      return Icon(CupertinoIcons.divide, size: constraint.maxWidth * scalar);
    });
  }
}
