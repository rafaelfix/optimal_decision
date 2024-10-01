import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:olle_app/functions/profiles.dart';
import 'package:olle_app/functions/operator_information.dart';
import 'package:provider/provider.dart';

class LevelBarGraph extends StatelessWidget {
  const LevelBarGraph({super.key});

  static const Map<int, String> operatorMap = {
    0: "+",
    1: "p",
    2: "-",
    3: "*",
    4: "m",
    5: "/",
  };

  @override
  Widget build(BuildContext context) {
    BarData barData = BarData(profileModel: Provider.of<ProfileModel>(context));
    barData.initializeBarData();

    return Padding(
      padding: const EdgeInsets.only(right: 35),
      child: BarChart(BarChartData(
        maxY: 110,
        minY: 0,
        barTouchData: BarTouchData(
          enabled: false,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (group) {
              return Colors.transparent;
            },
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                rod.toY.round().toString(),
                TextStyle(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.background,
        alignment: BarChartAlignment.spaceAround,
        gridData: const FlGridData(
            show: true,
            drawVerticalLine: false,
            drawHorizontalLine: true,
            horizontalInterval: 20),
        borderData: FlBorderData(show: false),
        titlesData: const FlTitlesData(
          show: true,
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
              sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: getSideTitles,
                  reservedSize: 35)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
              sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: getBottomTitles,
          )),
        ),
        barGroups: barData.dataPoints
            .map((data) => BarChartGroupData(
                  x: data.x,
                  barRods: [
                    BarChartRodData(
                      toY: data.y.toDouble(),
                      color: OperatorHandler.toColor[operatorMap[data.x]],
                      width: 20,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8),
                      ),
                      backDrawRodData: BackgroundBarChartRodData(
                        show: true,
                        color: Theme.of(context).colorScheme.primaryContainer,
                        toY: 100,
                      ),
                    )
                  ],
                  showingTooltipIndicators: [0],
                ))
            .toList(),
      )),
    );
  }
}

class IndividualBar {
  final int x;
  final int y;

  IndividualBar({
    required this.x,
    required this.y,
  });
}

class BarData {
  final ProfileModel profileModel;

  BarData({required this.profileModel});

  List<IndividualBar> dataPoints = [];

  void initializeBarData() {
    dataPoints = [
      IndividualBar(x: 0, y: profileModel.selectedProfile.levels["+"] ?? 2),
      IndividualBar(x: 1, y: profileModel.selectedProfile.levels["p"] ?? 2),
      IndividualBar(x: 2, y: profileModel.selectedProfile.levels["-"] ?? 2),
      IndividualBar(x: 3, y: profileModel.selectedProfile.levels["*"] ?? 2),
      IndividualBar(x: 4, y: profileModel.selectedProfile.levels["m"] ?? 2),
      IndividualBar(x: 5, y: profileModel.selectedProfile.levels["/"] ?? 2),
    ];
  }
}

Widget getBottomTitles(double xValue, TitleMeta meta) {
  Widget icon;

  icon = OperatorHandler.toIcon[LevelBarGraph.operatorMap[xValue.toInt()]]!;

  return SizedBox(
      height: 28,
      width: 28,
      child: SideTitleWidget(
          child: Center(child: icon), axisSide: meta.axisSide, space: 0));
}

Widget getSideTitles(double value, TitleMeta meta) {
  Widget widget;

  List<int> values = [20, 40, 60, 80, 100];

  if (values.contains(value)) {
    widget = Text(
      value.round().toString(),
      style: const TextStyle(
        color: Colors.black,
        fontSize: 12,
      ),
    );
  } else {
    widget = const SizedBox.shrink();
  }

  return SideTitleWidget(
    child: widget,
    axisSide: meta.axisSide,
  );
}
