import 'package:flutter/material.dart';

/// A placeholder page used for page navigation. Will not be used later.
///
/// [title] is used to set the appbar title.
class TestPage extends StatelessWidget {
  const TestPage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: const Center(child: Text("Ej implementerat.")),
    );
  }
}
