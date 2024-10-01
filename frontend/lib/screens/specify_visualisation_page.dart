import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:olle_app/functions/profiles.dart';
import 'package:olle_app/models/addition_strategy.dart';
import 'package:olle_app/screens/addition_vis_page.dart';
import 'package:olle_app/screens/division_vis_page.dart';
import 'package:olle_app/screens/multi_vis_page.dart';
import 'package:olle_app/screens/subtraction_vis_page.dart';
import 'package:olle_app/widgets/olle_app_bar.dart';
import 'package:provider/provider.dart';

//TODO Implement so numbers dissappear when changing page
//TODO implement multiplication

//Highest allowed number, Addition: 9+9, subtraction: 18-9, Divison: numerator less than 100 and has to be divided
//by int and result must be int, Multiplication: 10x10

class SpecifyVisualisationPage extends StatefulWidget {
  const SpecifyVisualisationPage({Key? key, required this.operator})
      : super(key: key);
  final String operator;

  @override
  State<SpecifyVisualisationPage> createState() => _SpecifyVisualisationPage();
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

final TextEditingController firstNumberController = TextEditingController();
final TextEditingController secondNumberController = TextEditingController();

AdditionStrategy additionStrategy = AdditionStrategy.raknaUpp;
int additionStartX = 1;
int additionStartY = 1;
int subtractionStartX = 2;
int subtractionStartY = 1;

//Checks if input only contains ints
bool containsOnlyIntegers(String input) {
  final RegExp integerRegex = RegExp(r'^[0-9]+$');
  return integerRegex.hasMatch(input);
}

//checks so division only has 1/3 numbers larger than 10
bool lessThanTen(int numerator, int denominator) {
  int result = numerator ~/ denominator; // Calculate the result
  int count = 0;
  if (denominator < 10) count++;
  if (numerator < 10) count++;
  if (result < 10) count++;
  return count >= 2;
}

//Checks valid input for visualizations
//Checks >0 mighr be unneccesary since it can only contain ints
bool checkValidInput(
    {required int firstInput,
    required int secondInput,
    required String operator}) {
  if (operator == '+') {
    if (firstInput >= 0 &&
        firstInput <= 9 &&
        secondInput >= 0 &&
        secondInput <= 9 &&
        firstInput + secondInput > 0) {
      return true;
    }
  }
  if (operator == '-') {
    if (firstInput <= 18 &&
        firstInput >= 0 &&
        secondInput >= 0 &&
        secondInput <= 9 &&
        firstInput >= secondInput) {
      return true;
    }
  }
  if (operator == '/') {
    if (firstInput % secondInput == 0 && lessThanTen(firstInput, secondInput)) {
      return true;
    }
  }
  if (operator == 'x') {
    if (firstInput > 0 &&
        firstInput <= 10 &&
        secondInput > 0 &&
        secondInput <= 10) {
      return true;
    }
  }
  if (operator == '+x') {
    if (firstInput >= 0 &&
        firstInput < 10 &&
        secondInput >= 0 &&
        secondInput <= 18 &&
        firstInput <= secondInput) {
      return true;
    }
  }
  //First and second input are the other way around because of how multivis works
  if (operator == 'xx') {
    if (firstInput > 0 &&
        firstInput <= 100 &&
        secondInput > 0 &&
        secondInput <= 10 &&
        firstInput % secondInput == 0) {
      return true;
    }
  }
  return false;
}

navigateToPages({
  required String operator,
  required int x,
  required int y,
  required BuildContext context,
  required AdditionStrategy strategy,
}) {
  if (operator == '+') {
    if (checkValidInput(firstInput: x, secondInput: y, operator: '+')) {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) =>
              AdditionVisPage(strategy: strategy, startX: x, startY: y)));
    }
  }
  if (operator == '-') {
    if (checkValidInput(firstInput: x, secondInput: y, operator: '-')) {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => SubtractionVisPage(
                startX: x,
                startY: y,
              )));
    }
  }
  if (operator == '/') {
    if (checkValidInput(firstInput: x, secondInput: y, operator: '/')) {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => DivisionVisPage(
                x: x,
                y: y,
                z: x ~/ y,
                dividerPos: 1,
                horizontalDivider: true,
              )));
    }
  }
  if (operator == 'x') {
    if (checkValidInput(firstInput: x, secondInput: y, operator: 'x')) {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => MultiVisPage(
                x: x,
                y: y,
                isUnknown: false,
              )));
    }
  }
  if (operator == '+x') {
    if (checkValidInput(firstInput: x, secondInput: y, operator: '+x')) {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) =>
              AdditionVisPage(strategy: strategy, startX: x, startY: y)));
    }
  }
  if (operator == 'xx') {
    if (checkValidInput(firstInput: x, secondInput: y, operator: 'xx')) {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => MultiVisPage(
                x: x,
                y: y,
                isUnknown: true,
              )));
    }
  }
}

class _SpecifyVisualisationPage extends State<SpecifyVisualisationPage> {
  @override
  Widget build(BuildContext context) {
    String operator = widget.operator;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: OlleAppBar(
        selectedProfile:
            Provider.of<ProfileModel>(context).selectedProfile.name,
      ),
      body: Stack(
        //Menubook at top of page
        children: [
          Positioned.fill(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: Center(
                      child: Icon(
                        Icons.menu_book,
                        size: 100,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(height: 60),
                  //This is rendered for addittion with unknown
                  if (operator == '+x' || operator == 'xx')
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          //First box
                          SizedBox(
                              width: 90,
                              height: 90,
                              child: Container(
                                decoration: BoxDecoration(
                                  color:
                                      const Color.fromARGB(255, 255, 255, 255),
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      spreadRadius: 1,
                                      blurRadius: 3,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Align(
                                  alignment: Alignment.center,
                                  child: TextField(
                                    controller: firstNumberController,
                                    style: const TextStyle(
                                        fontSize: 40, color: Colors.black),
                                    textAlign: TextAlign.center,
                                    decoration: const InputDecoration(
                                        hintText: '0',
                                        hintStyle: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 45,
                                        ),
                                        border: InputBorder.none),
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                              )),
                          //Everything between the boxes
                          const SizedBox(width: 15),
                          (operator == '+x')
                              ? const Text("+", style: TextStyle(fontSize: 40))
                              : const Text("x", style: TextStyle(fontSize: 40)),
                          const SizedBox(width: 15),
                          const Text("?", style: TextStyle(fontSize: 70)),
                          const SizedBox(width: 15),
                          const Text("=", style: TextStyle(fontSize: 40)),
                          const SizedBox(width: 15),
                          //Second box
                          SizedBox(
                              width: 90,
                              height: 90,
                              child: Container(
                                decoration: BoxDecoration(
                                  color:
                                      const Color.fromARGB(255, 255, 255, 255),
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      spreadRadius: 1,
                                      blurRadius: 3,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Align(
                                  alignment: Alignment.center,
                                  child: TextField(
                                    controller: secondNumberController,
                                    style: const TextStyle(
                                        fontSize: 40, color: Colors.black),
                                    textAlign: TextAlign.center,
                                    decoration: const InputDecoration(
                                        hintText: '0',
                                        hintStyle: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 45,
                                        ),
                                        border: InputBorder.none),
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                              )),
                        ],
                      ),
                    )
                  else
                    //This is rendered for everything with known variable
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          //First box
                          SizedBox(
                            width: 110,
                            height: 110,
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 255, 255, 255),
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    spreadRadius: 1,
                                    blurRadius: 3,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Align(
                                alignment: Alignment.center,
                                child: TextField(
                                  controller: firstNumberController,
                                  style: const TextStyle(
                                      fontSize: 40, color: Colors.black),
                                  textAlign: TextAlign.center,
                                  decoration: const InputDecoration(
                                      hintText: '0',
                                      hintStyle: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 45,
                                      ),
                                      border: InputBorder.none),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 25),
                          (operator != '/')
                              ? Text(operator,
                                  style: const TextStyle(fontSize: 40))
                              : const Icon(
                                  CupertinoIcons.divide,
                                  size: 40,
                                ),
                          const SizedBox(width: 25),
                          //Second box
                          SizedBox(
                            width: 110,
                            height: 110,
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 255, 255, 255),
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    spreadRadius: 1,
                                    blurRadius: 3,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Align(
                                alignment: Alignment.center,
                                child: TextField(
                                  controller: secondNumberController,
                                  style: const TextStyle(
                                      fontSize: 40, color: Colors.black),
                                  textAlign: TextAlign.center,
                                  decoration: const InputDecoration(
                                      hintText: '0',
                                      hintStyle: TextStyle(
                                          color: Colors.grey, fontSize: 45),
                                      border: InputBorder.none),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 50),
                  //Dropdownmenu that only renders for addition
                  if (operator == '+')
                    Container(
                      height: 40,
                      width: MediaQuery.of(context).size.width * 0.9,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Colors.grey.withOpacity(0.2),
                        ),
                      ),
                      child: SingleChildScrollView(
                        child: DropdownButton<AdditionStrategy>(
                          value: additionStrategy,
                          itemHeight: 50,
                          items: AdditionStrategy.values
                              .where((strategy) =>
                                  strategy != AdditionStrategy.okand)
                              .map<DropdownMenuItem<AdditionStrategy>>(
                            (AdditionStrategy value) {
                              return DropdownMenuItem<AdditionStrategy>(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 8.0,
                                      horizontal:
                                          MediaQuery.of(context).size.width *
                                              0.17),
                                  child: Text(
                                    setText(value),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                value: value,
                              );
                            },
                          ).toList(),
                          onChanged: (AdditionStrategy? value) {
                            setState(() {
                              additionStrategy = value!;
                            });
                          },
                        ),
                      ),
                    ),
                  const SizedBox(height: 15),
                  //Button that renders for all operators and handles navigation to visualization
                  IconButton(
                    icon: Icon(
                      Icons.arrow_circle_right_outlined,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    iconSize: 154,
                    onPressed: () {
                      if (firstNumberController.text != "" &&
                          secondNumberController.text != "") {
                        if (firstNumberController.text != "" &&
                            secondNumberController.text != "" &&
                            containsOnlyIntegers(firstNumberController.text) &&
                            containsOnlyIntegers(secondNumberController.text)) {
                          int x = int.parse(firstNumberController.text);
                          int y = int.parse(secondNumberController.text);
                          navigateToPages(
                              x: (operator == 'xx') ? y : x,
                              y: (operator == 'xx') ? x : y,
                              operator: operator,
                              strategy: (operator == '+x')
                                  ? AdditionStrategy.okand
                                  : additionStrategy,
                              context: context);
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
