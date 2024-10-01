import 'package:flutter/material.dart';
import 'package:olle_app/functions/profiles.dart';

//TODO Remove this file later if not needed?

class ProfileLevel extends StatelessWidget {
  const ProfileLevel({
    required this.profile,
    this.scale = 1,
    super.key,
  });

  final Profile profile;

  /// Decides what scale the icon should be
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40 * scale,
      width: 40 * scale,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.fromBorderSide(
          BorderSide(
            color: Theme.of(context).colorScheme.onPrimaryContainer,
            width: 3 * scale,
          ),
        ),
      ),
      child: Text(
        profile.levels.values.first.toString(),
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: (20 * scale),
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }
}
