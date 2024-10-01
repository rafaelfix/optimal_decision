import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:nativelib/nativelib.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _question = "No question";
  String _level = "No level";

  @override
  void initState() {
    super.initState();
    initQuestion();
  }

  Future<void> initQuestion() async {
    await Nativelib.call("newQuestion", ["+"]); // create question
    String question = await Nativelib.call("getQuestion");
    int l = await Nativelib.call("getLevel", ["+"]);
    if (kDebugMode) {
      print(l);
    }
    double level = await Nativelib.call("statusTime", ["+"]);
    setState(() {
      _question = question; // get question
      _level = level.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            children: [
              Text('Running on: $_question\n'),
              MaterialButton(
                  onPressed: () async {
                    String answer = (await Nativelib.call("getZ")).toString();
                    for (int i = 0; i < answer.length; i++) {
                      await Nativelib.call("addKey", [answer[i]]);
                    }
                    await Nativelib.call("addKey", ["="]);
                    await Nativelib.call("determineAnswer");
                    await initQuestion();
                  },
                  child: const Text("Answer question")),
              Text('Level $_level'),
            ],
          ),
        ),
      ),
    );
  }
}
