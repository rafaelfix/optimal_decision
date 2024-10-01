import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../screens/addition_vis_page.dart';
import '../screens/multi_vis_page.dart';
import '../screens/division_vis_page.dart';
import '../screens/subtraction_vis_page.dart';
import '../models/addition_strategy.dart';

class VisualisationPage extends StatefulWidget {
  const VisualisationPage({Key? key}) : super(key: key);

  @override
  State<VisualisationPage> createState() => _VisualisationPageState();
}

class _VisualisationPageState extends State<VisualisationPage> {
  int x = 10;
  int y = 10;
  int divX = 10;
  int divY = 10;
  int divZ = 10;

  //Debug parameters: choose strategy and input numbers
  AdditionStrategy additionStrategy = AdditionStrategy.raknaUpp;
  int additionStartX = 1;
  int additionStartY = 1;
  int subtractionStartX = 2;
  int subtractionStartY = 1;

  List<DropdownMenuItem<int>> numberItems = List.generate(10, (index) {
    return index;
  }).map<DropdownMenuItem<int>>((int value) {
    return DropdownMenuItem<int>(
      value: value,
      child: Text(value.toString()),
    );
  }).toList();

  List<DropdownMenuItem<int>> numberItemsLarge = List.generate(18, (index) {
    return index + 1;
  }).map<DropdownMenuItem<int>>((int value) {
    return DropdownMenuItem<int>(
      value: value,
      child: Text(value.toString()),
    );
  }).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(8),
            children: <Widget>[
              Container(
                height: 50,
                width: double.infinity,
                margin: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black,
                  ),
                  color: Colors.pink,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    DropdownButton<int>(
                      value: additionStartX,
                      items: numberItems,
                      onChanged: (int? value) {
                        setState(
                          () {
                            additionStartX = value!;
                          },
                        );
                      },
                    ),
                    const Icon(Icons.add, color: Colors.black),
                    DropdownButton<int>(
                      value: additionStartY,
                      items: numberItems,
                      onChanged: (int? value) {
                        setState(
                          () {
                            additionStartY = value!;
                          },
                        );
                      },
                    ),
                    DropdownButton<AdditionStrategy>(
                      value: additionStrategy,
                      items: AdditionStrategy.values
                          .map<DropdownMenuItem<AdditionStrategy>>(
                              (AdditionStrategy value) {
                        return DropdownMenuItem<AdditionStrategy>(
                          child: Text(
                            setText(value),
                          ),
                          value: value,
                        );
                      }).toList(),
                      onChanged: (AdditionStrategy? value) {
                        setState(
                          () {
                            additionStrategy = value!;
                          },
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 30,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AdditionVisPage(
                              startX: additionStartX,
                              startY: additionStartY,
                              strategy: additionStrategy,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              Container(
                height: 50,
                margin: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black,
                  ),
                  color: Colors.pink,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    DropdownButton(
                      value: x,
                      items: List<DropdownMenuItem<int>>.generate(
                        10,
                        (int index) {
                          return DropdownMenuItem<int>(
                            value: index + 1,
                            child: Text('${index + 1}'),
                          );
                        },
                      ),
                      onChanged: (value) {
                        setState(
                          () {
                            x = value as int;
                          },
                        );
                      },
                    ),
                    const Icon(CupertinoIcons.multiply, color: Colors.black),
                    DropdownButton(
                      value: y,
                      items: List<DropdownMenuItem<int>>.generate(
                        10,
                        (int index) {
                          return DropdownMenuItem<int>(
                            value: index + 1,
                            child: Text('${index + 1}'),
                          );
                        },
                      ),
                      onChanged: (value) {
                        setState(
                          () {
                            y = value as int;
                          },
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 30,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MultiVisPage(
                              x: x,
                              y: y,
                              isUnknown: true,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              Container(
                height: 50,
                margin: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black,
                  ),
                  color: Colors.pink,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    DropdownButton<int>(
                      value: subtractionStartX,
                      items: numberItemsLarge,
                      onChanged: (int? value) {
                        setState(
                          () {
                            subtractionStartX = value!;
                          },
                        );
                      },
                    ),
                    const Icon(Icons.remove, color: Colors.black),
                    DropdownButton<int>(
                      value: subtractionStartY,
                      items: numberItems,
                      onChanged: (int? value) {
                        setState(
                          () {
                            subtractionStartY = value!;
                          },
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 30,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SubtractionVisPage(
                              startX: subtractionStartX,
                              startY: subtractionStartY,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              Container(
                height: 50,
                margin: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black,
                  ),
                  color: Colors.pink,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    SizedBox(
                      height: 30,
                      width: 80,
                      child: TextField(
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          icon: Icon(CupertinoIcons.up_arrow,
                              color: Colors.black),
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged: (newValue) {
                          var val = double.tryParse(newValue);
                          if (val == null) return;
                          setState(
                            () {
                              divX = val.toInt();
                            },
                          );
                        },
                      ),
                    ),
                    const Icon(CupertinoIcons.divide, color: Colors.black),
                    SizedBox(
                      height: 30,
                      width: 100,
                      child: TextField(
                        decoration: const InputDecoration(
                          icon: Icon(CupertinoIcons.down_arrow,
                              color: Colors.black),
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged: (newValue) {
                          var val = double.tryParse(newValue);
                          if (val == null) return;
                          setState(
                            () {
                              divY = val.toInt();
                            },
                          );
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 30,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DivisionVisPage(
                              // TODO: Use real values!!!
                              x: divX,
                              y: divY,
                              z: divX ~/ divY,
                              dividerPos: 1,
                              horizontalDivider: true,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

// Return the strategy as a string (for debug only)
  String setText(AdditionStrategy value) {
    String itemText;
    switch (value) {
      case AdditionStrategy.raknaUpp:
        itemText = "Räkna upp";
        break;
      case AdditionStrategy.tiokompisar:
        itemText = "Tiokompisar";
        break;
      case AdditionStrategy.dubblar:
        itemText = "Dubblar";
        break;
      case AdditionStrategy.nastanDubblar1:
        itemText = "Nästan dubblar 1";
        break;
      case AdditionStrategy.nastanDubblar2:
        itemText = "Nästan dubblar 2";
        break;
      case AdditionStrategy.okand:
        itemText = "Okänd variabel";
      default:
        itemText = "Sandbox";
    }
    return itemText;
  }
}
