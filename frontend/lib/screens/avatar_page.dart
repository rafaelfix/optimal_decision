import 'package:flutter/material.dart';

class AvatarPage extends StatefulWidget {
  const AvatarPage({
    Key? key,
  }) : super(key: key);

  @override
  _AvatarPageState createState() => _AvatarPageState();
}

class _AvatarPageState extends State<AvatarPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Avatar'),
      ),
      body: const Center(child: Text("Ej implementerat.")),
    );
  }
}
