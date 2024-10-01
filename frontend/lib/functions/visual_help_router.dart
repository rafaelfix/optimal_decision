import 'package:flutter/material.dart';
import 'package:olle_app/models/addition_strategy.dart';
import 'package:olle_app/screens/addition_vis_page.dart';
import 'package:olle_app/screens/division_vis_page.dart';
import 'package:olle_app/screens/multi_vis_page.dart';
import 'package:olle_app/screens/subtraction_vis_page.dart';
import 'package:olle_app/widgets/visual_help_wrapper.dart';

/// [AddRoute] is a [MaterialPageRoute] for the [AdditionVisPage]
/// This is only meant to be called during a session
class AddRoute extends MaterialPageRoute {
  AddRoute({required session})
      : super(
          builder: (context) => VisualHelpWrapper(
            session: session,
            child: AdditionVisPage(
              startX: session.question.firstNumber,
              startY: session.question.secondNumber,
              strategy: session.question.additionStrategy!,
            ),
          ),
        );
}

/// [AddyRoute] is a [MaterialPageRoute] for the [AdditionVisPage] with
/// * the addition strategy set to [AdditionStrategy.okand]
///
/// This is only meant to be called during a session
class AddyRoute extends MaterialPageRoute {
  AddyRoute({required session})
      : super(
          builder: (context) => VisualHelpWrapper(
            session: session,
            child: AdditionVisPage(
              startX: session.question.firstNumber,
              startY: session.question.secondNumber,
              strategy: AdditionStrategy.okand,
            ),
          ),
        );
}

/// [SubRoute] is a [MaterialPageRoute] for the [SubtractionVisPage]
/// This is only meant to be called during a session
class SubRoute extends MaterialPageRoute {
  SubRoute({required session})
      : super(
          builder: (context) => VisualHelpWrapper(
            session: session,
            child: SubtractionVisPage(
              startX: session.question.firstNumber,
              startY: session.question.secondNumber,
            ),
          ),
        );
}

/// [MulRoute] is a [MaterialPageRoute] for the [MultiVisPage] with
/// * unknown set to false
///
/// This is only meant to be called during a session
class MulRoute extends MaterialPageRoute {
  MulRoute({required session})
      : super(
          builder: (context) => VisualHelpWrapper(
            session: session,
            child: MultiVisPage(
              x: session.question.firstNumber,
              y: session.question.secondNumber,
              isUnknown: false,
            ),
          ),
        );
}

/// [MulyRoute] is a [MaterialPageRoute] for the [MultiVisPage] with
/// * unknown set to true
///
/// This is only meant to be called during a session
class MulyRoute extends MaterialPageRoute {
  MulyRoute({required session})
      : super(
          builder: (context) => VisualHelpWrapper(
            session: session,
            child: MultiVisPage(
              x: session.question.secondNumber,
              y: session.question.firstNumber,
              isUnknown: true,
            ),
          ),
        );
}

/// [DivRoute] is a [MaterialPageRoute] for the [DivisionVisPage] with
/// * [horizontalDivider] set to true
/// * [dividerPos] set to 1
///
/// This is only meant to be called during a session
class DivRoute extends MaterialPageRoute {
  DivRoute({required session})
      : super(
          builder: (context) => VisualHelpWrapper(
            session: session,
            child: DivisionVisPage(
              x: session.question.firstNumber,
              y: session.question.secondNumber,
              z: session.question.firstNumber ~/ session.question.secondNumber,
              horizontalDivider: true,
              dividerPos: 1,
            ),
          ),
        );
}
