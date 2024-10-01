import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:olle_app/screens/main_page.dart';
import 'package:olle_app/screens/new_profile.dart';
import 'package:olle_app/functions/profiles.dart';

/// Widget for displaying the profile view
class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  ///Deletes the profile if the user conmfirms
  void deleteProfilePrompt({
    required BuildContext context,
    required ProfileModel profileModel,
    required Profile profile,
  }) {
    final String name = profile.name;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm deletion"),
          content: Text("Are you sure you want to continue? \"$name\"?"),
          actions: [
            MaterialButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            MaterialButton(
              child: const Text("Delete"),
              onPressed: () {
                Navigator.pop(context);
                profileModel.removeProfile(profile: profile);
              },
            ),
          ],
        );
      },
    );
  }

  void _onNewProfilePressed(context) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const NewProfilePage()));
  }

  static const List<int> colorCodes = <int>[200];

  @override
  Widget build(BuildContext context) {
    final ProfileModel profileModel = Provider.of<ProfileModel>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 80,
            ),
            Image.asset(
              "assets/icons/olle_icon.png",
              width: 175,
            ),
            ListView.builder(
              itemCount: profileModel.profiles
                  .length, // prevents all state from being in ProfileRowWidget :/
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (BuildContext context, int index) {
                final Profile profile =
                    profileModel.profiles.values.elementAt(index);
                return ProfileRowWidget(
                  profile: profile,
                  remove: () => deleteProfilePrompt(
                      context: context,
                      profileModel: profileModel,
                      profile: profile),
                );
              },
            ),
            IconButton(
              onPressed: () {
                _onNewProfilePressed(context);
              },
              icon: Icon(
                Icons.add_circle_outline_rounded,
                color: Theme.of(context).colorScheme.primary,
              ),
              iconSize: 54,
            )
          ],
        ),
      ),
    );
  }
}

/// A single row representing a user
///
/// [name] is the name of the user
class ProfileRowWidget extends StatelessWidget {
  const ProfileRowWidget({
    Key? key,
    required this.profile,
    required this.remove,
  }) : super(key: key);

  final Profile profile;
  final Function remove;

  @override
  Widget build(BuildContext context) {
    final ProfileModel profileModel = Provider.of<ProfileModel>(context);

    return Container(
      margin: const EdgeInsets.only(left: 30, right: 30, bottom: 20),
      height: 60,
      alignment: Alignment.center,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: Theme.of(context).colorScheme.primaryContainer,
          boxShadow: [
            BoxShadow(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                blurRadius: 0.1,
                spreadRadius: 0,
                offset: const Offset(0, 4))
          ]),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        title: Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Text(
            profile.name,
            textAlign: TextAlign.left,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        trailing: IconButton(
          icon: Icon(
            Icons.delete_outline,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
          onPressed: () => remove(),
        ),
        onTap: () async {
          profileModel.setProfile(profile: profile);

          Navigator.push(
            context,
            MaterialPageRoute(
              settings: const RouteSettings(name: "/home"),
              builder: (context) => const MainPage(),
            ),
          );
        },
      ),
    );
  }
}
