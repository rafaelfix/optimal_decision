import 'package:flutter/material.dart';
import 'package:olle_app/functions/map_data.dart';
import 'package:olle_app/functions/profiles.dart';
import 'package:olle_app/widgets/node_button.dart';
import 'package:olle_app/widgets/olle_app_bar.dart';
import 'package:provider/provider.dart';

/// [TrainingPage] is a page for freeplay meant to be used after the user is
/// done with the map
/// It is a simple grid with each of the different methods having a button each
/// leading to the counting page for that method.
///
/// It uses [TrainingGridFormat] to modify how the buttons are placed and their
/// size
class TrainingPage extends StatelessWidget {
  const TrainingPage({super.key});

  @override
  Widget build(BuildContext context) {
    ProfileModel profileModel = Provider.of<ProfileModel>(context);

    return Scaffold(
      backgroundColor: Color.alphaBlend(
          Theme.of(context).colorScheme.primaryContainer.withAlpha(50),
          Colors.white),
      appBar: OlleAppBar(selectedProfile: profileModel.selectedProfile.name),
      body: DecoratedBox(
        decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/icons/grass.png"),
                fit: BoxFit.cover)),
        child: GridView.count(
          physics: const ClampingScrollPhysics(),
          crossAxisCount: 2,
          children: [
            TrainingGridFormat(
              child: NodeButton(
                  node: Node.add(0, 0, 100),
                  currentLevelMap: profileModel.selectedProfile.levels),
            ),
            TrainingGridFormat(
              child: NodeButton(
                  node: Node.addy(0, 0, 100),
                  currentLevelMap: profileModel.selectedProfile.levels),
            ),
            TrainingGridFormat(
              child: NodeButton(
                  node: Node.sub(0, 0, 100),
                  currentLevelMap: profileModel.selectedProfile.levels),
            ),
            TrainingGridFormat(
              child: NodeButton(
                  node: Node.mult(0, 0, 100),
                  currentLevelMap: profileModel.selectedProfile.levels),
            ),
            TrainingGridFormat(
              child: NodeButton(
                  node: Node.multy(0, 0, 100),
                  currentLevelMap: profileModel.selectedProfile.levels),
            ),
            TrainingGridFormat(
              child: NodeButton(
                  node: Node.div(0, 0, 100),
                  currentLevelMap: profileModel.selectedProfile.levels),
            ),
          ],
        ),
      ),
    );
  }
}

/// [TrainingGridFormat] decides the size and position of each item in the grid
class TrainingGridFormat extends StatelessWidget {
  const TrainingGridFormat({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: 100,
        width: 100,
        child: child,
      ),
    );
  }
}
