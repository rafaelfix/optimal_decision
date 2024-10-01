import 'package:olle_app/functions/olle_badge.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:olle_app/functions/progress.dart';
import 'package:olle_app/screens/progress_screen.dart';

void main() {
  group("Test that correct badge is shown on progress screen", () {
    int sessionGoalTime = ProgressModel.sessionGoalTime;
    test("Test badge prio 1", () {
      ProgressScreen progressScreen = ProgressScreen(
        correctAnswersCount: 10,
        wrongAnswersCount: 0,
        highestHotstreak: 10,
        secondsPlayed: (sessionGoalTime ~/ 2),
        operand: "+",
        previousLevel: 2,
        currentLevel: 2,
      );

      OlleBadge badge = OlleBadge(progressScreenWidget: progressScreen);

      expect(badge.getBadgePath(), 'assets/badges/badge1_red_gold.png');
    });
    test("Test badge prio 2", () {
      ProgressScreen progressScreen = ProgressScreen(
        correctAnswersCount: 9,
        wrongAnswersCount: 1,
        highestHotstreak: 9,
        secondsPlayed: (sessionGoalTime ~/ 2),
        operand: "+",
        previousLevel: 2,
        currentLevel: 2,
      );

      OlleBadge badge = OlleBadge(progressScreenWidget: progressScreen);

      expect(badge.getBadgePath(), 'assets/badges/badge2_red_gold.png');
    });
    test("Test badge prio 3", () {
      ProgressScreen progressScreen = ProgressScreen(
        correctAnswersCount: 8,
        wrongAnswersCount: 2,
        highestHotstreak: 8,
        secondsPlayed: (sessionGoalTime ~/ 2),
        operand: "+",
        previousLevel: 2,
        currentLevel: 2,
      );

      OlleBadge badge = OlleBadge(progressScreenWidget: progressScreen);

      expect(badge.getBadgePath(), 'assets/badges/badge1_blue_gold.png');
    });
    test("Test badge prio 4", () {
      ProgressScreen progressScreen = ProgressScreen(
        correctAnswersCount: 10,
        wrongAnswersCount: 0,
        highestHotstreak: 10,
        secondsPlayed: sessionGoalTime + 1,
        operand: "+",
        previousLevel: 2,
        currentLevel: 2,
      );

      OlleBadge badge = OlleBadge(progressScreenWidget: progressScreen);

      expect(badge.getBadgePath(), 'assets/badges/badge2_blue_gold.png');
    });

    test("Test badge prio 5", () {
      ProgressScreen progressScreen = ProgressScreen(
        correctAnswersCount: 8,
        wrongAnswersCount: 2,
        highestHotstreak: 8,
        secondsPlayed: sessionGoalTime + 1,
        operand: "+",
        previousLevel: 2,
        currentLevel: 4,
      );

      OlleBadge badge = OlleBadge(progressScreenWidget: progressScreen);

      expect(badge.getBadgePath(), 'assets/badges/badge1_blue_silver.png');
    });

    test("Test badge prio 6", () {
      ProgressScreen progressScreen = ProgressScreen(
        correctAnswersCount: 20,
        wrongAnswersCount: 20,
        highestHotstreak: 15,
        secondsPlayed: sessionGoalTime + 1,
        operand: "+",
        previousLevel: 2,
        currentLevel: 2,
      );

      OlleBadge badge = OlleBadge(progressScreenWidget: progressScreen);

      expect(badge.getBadgePath(), 'assets/badges/badge2_blue_silver.png');
    });

    test("Test badge prio 7", () {
      ProgressScreen progressScreen = ProgressScreen(
        correctAnswersCount: 20,
        wrongAnswersCount: 5,
        highestHotstreak: 7,
        secondsPlayed: sessionGoalTime + 1,
        operand: "+",
        previousLevel: 2,
        currentLevel: 2,
      );

      OlleBadge badge = OlleBadge(progressScreenWidget: progressScreen);

      expect(badge.getBadgePath(), 'assets/badges/badge1_red_silver.png');
    });

    test("Test badge prio 8", () {
      ProgressScreen progressScreen = ProgressScreen(
        correctAnswersCount: 20,
        wrongAnswersCount: 20,
        highestHotstreak: 2,
        secondsPlayed: sessionGoalTime + 1,
        operand: "+",
        previousLevel: 2,
        currentLevel: 2,
      );

      OlleBadge badge = OlleBadge(progressScreenWidget: progressScreen);

      expect(badge.getBadgePath(), 'assets/badges/badge2_red_silver.png');
    });
  });
}
