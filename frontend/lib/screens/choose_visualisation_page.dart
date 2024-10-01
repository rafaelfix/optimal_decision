import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:olle_app/screens/specify_visualisation_page.dart';

class ChooseVisualisationPage extends StatefulWidget {
  const ChooseVisualisationPage({Key? key}) : super(key: key);

  @override
  State<ChooseVisualisationPage> createState() =>
      _ChooseVisualisationPageState();
}

class _ChooseVisualisationPageState extends State<ChooseVisualisationPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.85),
                            blurRadius: 3,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      //Addition button
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) =>
                                  const SpecifyVisualisationPage(
                                      operator: '+')));
                        },
                        child: const Icon(
                          CupertinoIcons.add,
                          size: 50,
                        ),
                        style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          minimumSize: const Size(100, 100),
                          backgroundColor:
                              Theme.of(context).colorScheme.primaryContainer,
                          foregroundColor: Colors.black,
                          side: const BorderSide(
                            color: Colors.black,
                            width: 5.0,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 45),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.85),
                            blurRadius: 3,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      //Subtraction button
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) =>
                                  const SpecifyVisualisationPage(
                                      operator: '-')));
                        },
                        child: const Icon(
                          CupertinoIcons.minus,
                          size: 50,
                        ),
                        style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          minimumSize: const Size(100, 100),
                          backgroundColor:
                              Theme.of(context).colorScheme.primaryContainer,
                          foregroundColor: Colors.black,
                          side: const BorderSide(
                            color: Colors.black,
                            width: 5.0,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 45),
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.85),
                            blurRadius: 3,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      //Multiply with unknonwn button
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) =>
                                  const SpecifyVisualisationPage(
                                      operator: 'xx')));
                        },
                        style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          minimumSize: const Size(100, 100),
                          backgroundColor:
                              Theme.of(context).colorScheme.primaryContainer,
                          foregroundColor: Colors.black,
                          side: const BorderSide(
                            color: Colors.black,
                            width: 5.0,
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(CupertinoIcons.multiply,
                                size: 45, color: Colors.black),
                            Icon(IconData(0x0079, fontFamily: 'CustomIcon'),
                                size: 40, color: Colors.black),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.85),
                            blurRadius: 3,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      //Addition with unknwon button
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) =>
                                  const SpecifyVisualisationPage(
                                      operator: '+x')));
                        },
                        style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          minimumSize: const Size(100, 100),
                          backgroundColor:
                              Theme.of(context).colorScheme.primaryContainer,
                          foregroundColor: Colors.black,
                          side: const BorderSide(
                            color: Colors.black,
                            width: 5.0,
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(CupertinoIcons.add,
                                size: 45, color: Colors.black),
                            Icon(IconData(0x0079, fontFamily: 'CustomIcon'),
                                size: 40, color: Colors.black),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 45),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.85),
                            blurRadius: 3,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      //Multiplication button
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) =>
                                  const SpecifyVisualisationPage(
                                      operator: 'x')));
                        },
                        child: const Icon(
                          CupertinoIcons.multiply,
                          size: 50,
                        ),
                        style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          minimumSize: const Size(100, 100),
                          backgroundColor:
                              Theme.of(context).colorScheme.primaryContainer,
                          foregroundColor: Colors.black,
                          side: const BorderSide(
                            color: Colors.black,
                            width: 5.0,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 45),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.85),
                            blurRadius: 3,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      //Division button
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) =>
                                  const SpecifyVisualisationPage(
                                      operator: '/')));
                        },
                        child: const Icon(
                          CupertinoIcons.divide,
                          size: 50,
                        ),
                        style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          minimumSize: const Size(100, 100),
                          backgroundColor:
                              Theme.of(context).colorScheme.primaryContainer,
                          foregroundColor: Colors.black,
                          side: const BorderSide(
                            color: Colors.black,
                            width: 5.0,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          //Menu book at top
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Center(
              child: Icon(Icons.menu_book,
                  size: 100,
                  color: Theme.of(context).colorScheme.onPrimaryContainer),
            ),
          ),
        ],
      ),
    );
  }
}
