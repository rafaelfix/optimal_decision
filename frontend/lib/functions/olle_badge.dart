import 'package:olle_app/functions/progress.dart';
import 'package:olle_app/screens/progress_screen.dart';

/// [OlleBadge] is a simple class made only to calculate the correct badge path
/// for an [ProgressScreen].
///
/// To use it:
/// * Construct [OlleBadge] with the [ProgressScreen] you want to use
/// * Call [getBadgePath] => Path to badge
class OlleBadge {
  const OlleBadge({
    required this.progressScreenWidget,
  });
  final ProgressScreen progressScreenWidget;

  /// Get the path for a badge
  String getBadgePath() {
    double correctAnswerRatio = progressScreenWidget.correctAnswersCount /
        (progressScreenWidget.correctAnswersCount +
            progressScreenWidget.wrongAnswersCount);
    if (progressScreenWidget.secondsPlayed <
        (ProgressModel.sessionGoalTime * 3 / 4)) {
      // very fast
      if (correctAnswerRatio >= 1) {
        return 'assets/badges/badge1_red_gold.png';
      }

      if (correctAnswerRatio >= 0.9) {
        return 'assets/badges/badge2_red_gold.png';
      }

      if (correctAnswerRatio >= 0.8) {
        return 'assets/badges/badge1_blue_gold.png';
      }
    }

    if (correctAnswerRatio >= 1) {
      return 'assets/badges/badge2_blue_gold.png'; // perfect ratio
    }

    if (progressScreenWidget.currentLevel >
        progressScreenWidget.previousLevel) {
      return 'assets/badges/badge1_blue_silver.png'; // level up
    }

    if (progressScreenWidget.highestHotstreak >= 10) {
      return 'assets/badges/badge2_blue_silver.png'; // hotstreak
    }

    if (correctAnswerRatio >= 0.75) {
      return 'assets/badges/badge1_red_silver.png'; // good ratio
    }

    // default badge
    return 'assets/badges/badge2_red_silver.png';
  }
}
