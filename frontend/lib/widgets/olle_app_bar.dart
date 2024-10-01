import 'package:flutter/material.dart';

/// Widget for displaying the apps custom toolbar.
class OlleAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// Creates an [OlleAppBar] with [key]? and [selectedProfile].
  const OlleAppBar({
    super.key,
    required this.selectedProfile,
  });

  final String selectedProfile;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
      shadowColor: Theme.of(context).colorScheme.shadow,
      actions: [
        Row(
          children: [
            const Icon(Icons.account_circle_outlined),
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: Text(
                selectedProfile,
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size(double.maxFinite, 40);
}
