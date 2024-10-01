import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:olle_app/functions/database_connection.dart';
import 'package:olle_app/functions/profiles.dart';
import 'package:olle_app/screens/email_verification.dart';

/// The page where the user is asked for an email address to setup their account.
/// Shown after creating a new profile if the user was able to connect to the database.
class SetupAccountPage extends StatefulWidget {
  const SetupAccountPage({
    super.key,
    required this.profile,
  });

  final Profile profile;

  @override
  State<SetupAccountPage> createState() => _SetupAccountPageState();
}

class _SetupAccountPageState extends State<SetupAccountPage> {
  String email = "";

  bool validateEmail(String email) {
    // Taken from: https://html.spec.whatwg.org/multipage/input.html#valid-e-mail-address
    final RegExp emailRegExp = RegExp(
        r"^[a-zA-Z0-9.!#$%&'*+\/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$");
    return emailRegExp.hasMatch(email);
  }

  void setupAccount() async {
    try {
      await sendAccessCode(email: email);
    } catch (e) {
      if (kDebugMode) {
        print("Unable to send access code to email: $email");
        print(e);
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              "Unable to send the verification code to $email, please try again. Check your internet connection and make sure that you have entered the right email address.")));
      return; // Don't show the verification page
    }

    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) =>
          EmailVerificationPage(profile: widget.profile, email: email),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        leading: const CloseButton(),
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
                    labelText: 'Email',
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
                    email = value;
                  });
                },
                style: TextStyle(
                  fontSize: 18,
                  color: validateEmail(email)
                      ? Colors.black
                      : Theme.of(context).colorScheme.error,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.arrow_circle_right_outlined),
              color: Theme.of(context).colorScheme.primary,
              iconSize: 68,
              onPressed: validateEmail(email) ? () => setupAccount() : null,
            )
          ],
        ),
      ),
    );
  }
}
