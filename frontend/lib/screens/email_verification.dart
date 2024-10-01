import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:olle_app/functions/database_connection.dart';
import 'package:olle_app/functions/profiles.dart';
import 'package:olle_app/screens/sync_page.dart';

/// A page for verifying the email address of a user.
class EmailVerificationPage extends StatefulWidget {
  const EmailVerificationPage({
    super.key,
    required this.profile,
    required this.email,
  });

  final Profile profile;
  final String email;

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  String get email => widget.email;
  String code = "";

  checkCode(String code) async {
    if (!RegExp(r'^[0-9]*$').hasMatch(code)) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Only numbers allowed')));
    } else if (code.length != 6) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Code must be 6 digits')));
    } else {
      final List<String> synchronizations;
      try {
        synchronizations = await getUserSynchronizations(
          email: email,
          accessCode: int.parse(code),
        );
      } catch (e) {
        if (kDebugMode) {
          print("Unable to get synchronizations");
          print(e);
        }
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
                "Unable to verify your account, please try again. Check your internet connection and make sure that you have entered the right code.")));
        return; // Don't show the sync page
      }

      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => SyncPage(
          profile: widget.profile,
          email: email,
          accessCode: int.parse(code),
          synchronizations: synchronizations,
        ),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const CloseButton(),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: <Widget>[
              SizedBox(height: 20, width: MediaQuery.of(context).size.width),
              Icon(Icons.lock_outline,
                  size: 136,
                  color: Theme.of(context).colorScheme.onPrimaryContainer),
              const FittedBox(
                  fit: BoxFit.fitWidth,
                  child: Text(
                    'Enter your verification code',
                    style: TextStyle(fontSize: 40),
                  )),
              FittedBox(
                fit: BoxFit.fitWidth,
                child: Text.rich(TextSpan(
                    text: 'We sent a verification code to ',
                    children: <TextSpan>[
                      TextSpan(
                          text: email,
                          style: const TextStyle(color: Colors.blue))
                    ])),
              ),
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
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      hintText: '123456',
                      hintStyle: TextStyle(
                        fontSize: 20,
                        color: Theme.of(context)
                            .colorScheme
                            .onPrimaryContainer
                            .withOpacity(0.4),
                      ),
                      prefixIcon: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Icon(
                          Icons.key_outlined,
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                          weight: 500,
                          size: 35,
                        ),
                      ),
                      border: InputBorder.none),
                  style: const TextStyle(fontSize: 18, color: Colors.black),
                  onChanged: (String value) {
                    setState(() {
                      code = value;
                    });
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_circle_right_outlined),
                color: Theme.of(context).colorScheme.primary,
                iconSize: 68,
                onPressed: () {
                  checkCode(code);
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
