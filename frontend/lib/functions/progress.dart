import 'package:flutter/foundation.dart';
import 'package:olle_app/functions/practice_session.dart';

/// [ProgressModel] is a [ChangeNotifier] that holds information on how much
/// progress an user has done in a session.
///
/// Progress is a combination of
/// * Gametime elapsed
/// * Questions answered correctly
///
/// ProgressModel is simply boiled down to the member [_progress] where
/// it can be a double ranging from 0.0 to 1.0
class ProgressModel extends ChangeNotifier {
  /// A double between 0 and 1 where 0 is no progress and 1 is full
  double _progress = 0.0;

  static const int sessionGoalTime = kDebugMode ? 30 : 300;
  static const int sessionGoalAnswers = kDebugMode ? 10 : 40;

  ProgressModel();

  double get progress => _progress.clamp(0.0, 1.0);

  /// Sets the [_progress] from the current session. Note that this sets not
  /// adds to the progress
  void setProgress({required PracticeSession session}) {
    double normalizedCorrectAnswers =
        session.correctCounter / sessionGoalAnswers;
    double normalizedTimePassed =
        (session.timer.toInt() / 1000) / sessionGoalTime;
    _progress = normalizedCorrectAnswers * 0.5 + normalizedTimePassed * 0.5;
    notifyListeners();
  }

  /// Reset [_progress] down to 0
  void resetProgress() {
    _progress = 0.0;
  }
}
