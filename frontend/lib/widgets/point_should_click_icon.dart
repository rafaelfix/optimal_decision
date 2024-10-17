import 'package:flutter/material.dart';
import 'package:avatar_glow/avatar_glow.dart';

class PointShouldClickIcon extends StatelessWidget {
  final double iconSize;
  const PointShouldClickIcon({
    required this.iconSize,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AvatarGlow(
      //endRadius: iconSize * (3 / 4),
      //radius: iconSize * (3 / 4),
      glowColor: Colors.black,
      //showTwoGlows: false,
      child: Image.asset(
        //'assets/icons/hand_pointing_click.png',
        'assets/icons/transparent.png',
        //color: Colors.yellow,
        //colorBlendMode: BlendMode.modulate,
      ),
    );
  }
}
