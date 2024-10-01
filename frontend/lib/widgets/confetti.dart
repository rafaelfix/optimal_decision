import 'package:flutter/material.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:confetti/confetti.dart';

class Confetti extends StatelessWidget {
  final String toastMessage;
  final bool doToast;
  Confetti({
    this.toastMessage = "",
    this.doToast = true,
    Key? key,
  }) : super(key: key);
  final confettiController = ConfettiController();

  void playConfetti() {
    confettiController.play();
    if (doToast) Fluttertoast.showToast(msg: toastMessage);
  }

  void stopConfetti() {
    confettiController.stop();
  }

  @override
  Widget build(BuildContext context) {
    return ConfettiWidget(
      confettiController: confettiController,
      blastDirectionality: BlastDirectionality.explosive,
    );
  }
}
