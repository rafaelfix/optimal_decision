import 'package:flutter/material.dart';
import 'package:avatar_glow/avatar_glow.dart';

class GlowingIconButton extends StatelessWidget {
  final IconData icon;
  final double iconSize;
  final VoidCallback playAnimationHandle;
  final bool animate;
  final double addedGlowEndRadius;

  const GlowingIconButton(
    this.icon, {
    required this.iconSize,
    required this.playAnimationHandle,
    required this.animate,
    this.addedGlowEndRadius = 30.0,
    //this.addedGlowRadius = 30.0,
    Key? key,
  }) : super(key: key);

  // Used to only show the pulsating animation before clicking the button for the
  @override
  Widget build(BuildContext context) {
    return AvatarGlow(
      glowColor: Colors.black,
      //endRadius: addedGlowEndRadius + iconSize / 2,
      //radius: addedGlowEndRadius + iconSize / 2,
      //showTwoGlows: false,
      animate: animate,
      child: Card(
        elevation: 5,
        shape: const CircleBorder(
          side: BorderSide(
            style: BorderStyle.solid,
            width: 2,
          ),
        ),
        color: Colors.amber.withOpacity(0.85),
        child: IconButton(
          onPressed: playAnimationHandle,
          icon: Icon(
            icon,
            color: Colors.black,
          ),
          iconSize: iconSize,
          alignment: Alignment.center,
        ),
      ),
    );
  }
}
