import 'dart:math';

import 'package:flutter/material.dart';

import '../models/animated_child_widget.dart';

/// Animates moving a child by giving offets from the left and top side of the screen.
/// Child is given in a function call rather than as a constructor parameter to
/// make it possible to use animate different childs without cluttering the Widget tree.
/// TODO: Investigate to remove this linter error below
// ignore: must_be_immutable
class AnimatedChildPositioned extends StatefulWidget {
  final VoidCallback onCompleted;
  final Duration duration;
  late Offset _startOffset;
  late Offset _endOffset;
  late AnimatedChildWidget _child;

  late AnimationController controller;

  bool controllerInitialized = false;

  AnimatedChildPositioned({
    required this.onCompleted,
    this.duration = const Duration(milliseconds: 500),
    Key? key,
  }) : super(key: key);

  void startAnimateChild({
    required AnimatedChildWidget child,
    required Offset startOffset,
    required Offset endOffset,
  }) {
    _startOffset = startOffset;
    _endOffset = endOffset;
    _child = child;
    controller.forward();
  }

  bool get isAnimating {
    if (!controllerInitialized) return false;
    return controller.isAnimating;
  }

  @override
  State<AnimatedChildPositioned> createState() =>
      _AnimatedChildPositionedState();
}

class _AnimatedChildPositionedState extends State<AnimatedChildPositioned>
    with TickerProviderStateMixin {
  // Controlling Animations
  late final Animation<double> scaleAnimation;

  double animationLeftOffset = 0;
  double animationTopOffset = 0;

  @override
  void initState() {
    super.initState();
    widget.controller = AnimationController(
      vsync: this,
      duration: widget.duration,
      lowerBound: 0,
      upperBound: 1,
    );
    widget.controllerInitialized = true;
    scaleAnimation = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: widget.controller,
        curve: Curves.bounceInOut,
      ),
    );

    widget.controller.addListener(() {
      setState(() {
        animationLeftOffset =
            widget._startOffset.dx * (1 - widget.controller.value) +
                widget._endOffset.dx * widget.controller.value;
        animationTopOffset =
            widget._startOffset.dy * (1 - widget.controller.value) +
                widget._endOffset.dy * widget.controller.value;
      });
    });

    widget.controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.controller.reset();
        widget.onCompleted();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: animationLeftOffset,
      top: animationTopOffset,
      child: Opacity(
        opacity: widget.controller.isAnimating ? 1 : 0,
        child: Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black,
                blurRadius: 10,
              ),
            ],
          ),
          child: SizedBox(
            child:
                widget.controller.isAnimating ? widget._child : const Center(),
            height: widget.controller.isAnimating
                ? widget._child.height +
                    widget._child.height *
                        0.5 *
                        sin(1 * pi * widget.controller.value)
                : 0,
            width: widget.controller.isAnimating
                ? widget._child.width +
                    widget._child.width *
                        0.5 *
                        sin(1 * pi * widget.controller.value)
                : 0,
          ),
        ),
      ),
    );
  }
}
