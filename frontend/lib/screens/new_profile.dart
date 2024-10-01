import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:olle_app/screens/setup_account_page.dart';
import 'package:provider/provider.dart';

import 'package:olle_app/functions/profiles.dart';

/// A page from which a new user profile can be created.
class NewProfilePage extends StatefulWidget {
  const NewProfilePage({Key? key}) : super(key: key);

  @override
  State<NewProfilePage> createState() => _NewProfilePageState();
}

class _NewProfilePageState extends State<NewProfilePage> {
  String name = "";

  bool validateName(String name) {
    final RegExp nameRegExp = RegExp(r"^[A-Za-z1-9]+$");
    return nameRegExp.hasMatch(name);
  }

  bool validateInput(String name) {
    return validateName(name);
  }

  void createProfile(ProfileModel profileModel) async {
    try {
      final profile = await profileModel.addProfile(name: name);
      if (!profile.isOffline()) {
        // Show account setup page since the user is online.
        // Otherwise, we can't setup and account and the user will have to do it later via the settings.
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => SetupAccountPage(profile: profile),
        ));
      } else {
        Navigator.pop(context);
      }
    } catch (e, s) {
      if (kDebugMode) {
        print("Unable to create user");
        print(e);
        print(s);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ProfileModel profileModel = Provider.of<ProfileModel>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      body: Center(
        child: Column(
          children: [
            Image.asset(
              "assets/icons/olle_icon.png",
              width: 175,
            ),
            const SizedBox(height: 15),
            Container(
              margin: const EdgeInsets.only(
                  left: 30, right: 30, bottom: 10, top: 40),
              height: 60,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: Theme.of(context).colorScheme.primaryContainer,
                boxShadow: [
                  BoxShadow(
                      color: Theme.of(context).shadowColor.withOpacity(0.11),
                      blurRadius: 7,
                      spreadRadius: 0)
                ],
              ),
              child: TextField(
                decoration: InputDecoration(
                    labelText: 'Username',
                    labelStyle: TextStyle(
                      fontSize: 20,
                      color: Theme.of(context)
                          .colorScheme
                          .onPrimaryContainer
                          .withOpacity(0.4),
                    ),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Icon(
                        Icons.account_circle_outlined,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        weight: 500,
                        size: 35,
                      ),
                    ),
                    border: InputBorder.none),
                onChanged: (String value) {
                  setState(() {
                    name = value;
                  });
                },
                style: TextStyle(
                  fontSize: 18,
                  color: validateName(name)
                      ? Colors.black
                      : Theme.of(context).colorScheme.error,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.arrow_circle_right_outlined),
              color: Theme.of(context).colorScheme.primary,
              iconSize: 68,
              onPressed: validateInput(name)
                  ? () => createProfile(profileModel)
                  : null,
            )
          ],
        ),
      ),
    );
  }
}
