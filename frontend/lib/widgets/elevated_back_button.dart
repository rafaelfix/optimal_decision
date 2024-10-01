import 'package:flutter/material.dart';

class ElevatedBackButton extends StatelessWidget {
  final double buttonSize;

  const ElevatedBackButton({
    required this.buttonSize,
    Key? key,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      color: Colors.amber,
      shape: const RoundedRectangleBorder(
        side: BorderSide(
          style: BorderStyle.solid,
          width: 2,
        ),
      ),
      child: IconButton(
        color: Colors.black,
        icon: const Icon(Icons.arrow_back),
        iconSize: buttonSize,
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }
}
