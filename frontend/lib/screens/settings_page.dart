import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:olle_app/screens/setup_account_page.dart';
import 'package:provider/provider.dart';
import 'package:settings_ui/settings_ui.dart';

import '../functions/profiles.dart';
//import 'package:dropdown_button2/dropdown_button2.dart';

/// TODO: Connect setting output to where they should go (profile?)
/// TODO: Maybe add icon to popup (row widget?) Maybe add timer setting tile.
/// TODO: ADD BORDER DEC?
/// TODO: Add onPressed to "Språk"
/// TODO: Add max limit for timer? After x minutes, kick user out of practise page if no answer is given
/// TODO: FIX INPUT VALIDATION ON TIMER
///
/// This class is responsible for creating the Settings page of the app, where the user
/// can change certain settings pertaining to the app. This class calls the SettingsPageState
/// class in order to actually build and handle the page.
class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

/// This class is responsible for actually building the settings page, and consists of a SettingsList
/// which contains two different [SettingsSection}s with different settings. The settings are represented
/// by different types of [SettingsTile]s. Most [SettingTile]s call upon a [textBoxPopup], which displays
/// some information and a [TextField], when the user clicks on it.
///
/// [soundSwitch] is a boolean variable, which is used to set the value of the
/// switch button controlling the sound of the app.
class _SettingsPageState extends State<SettingsPage> {
  var soundSwitch = false;

  void setupAccount(bool isSyncronized) {
    if (!isSyncronized) {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => SetupAccountPage(
          profile:
              Provider.of<ProfileModel>(context, listen: false).selectedProfile,
        ),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final ProfileModel profileModel = Provider.of<ProfileModel>(context);
    final isSynchronized = profileModel.selectedProfile.linkedAccount != null;
    return Scaffold(
      body: Column(children: [
        Container(
            padding: const EdgeInsets.only(bottom: 30.0, top: 16.0),
            color: Theme.of(context).colorScheme.primaryContainer.withAlpha(50),
            child: Center(
                child: ElevatedButton.icon(
                    icon: isSynchronized
                        ? const Icon(Icons.cloud_done_outlined,
                            color: Colors.black)
                        : const Icon(Icons.cloud_off_outlined,
                            color: Colors.black),
                    onPressed: () => setupAccount(isSynchronized),
                    label: isSynchronized
                        ? const Text("Synchronized!")
                        : const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text("Not synchronized"),
                              Icon(Icons.chevron_right),
                            ],
                          ),
                    style: isSynchronized
                        ? ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 214, 255, 218),
                            foregroundColor: Colors.black,
                          )
                        : ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.errorContainer,
                            foregroundColor: Colors.black,
                          )))),
        Expanded(
          child: SettingsList(
            platform: DevicePlatform.iOS, //passar figma desigen mer
            lightTheme: _settingsThemeData(),
            sections: [
              SettingsSection(
                tiles: <SettingsTile>[
                  SettingsTile.navigation(
                    leading: const Icon(Icons.language),
                    title: const Text('Language'),
                    value: const Text('English'),
                    onPressed: (BuildContext context) {
                      languageSelectPopup(context);
                    },
                  ),
                  SettingsTile.switchTile(
                    onToggle: (bool value) {
                      value = soundSwitch; //Toggle value, on or off
                      setState(() {
                        value = !value; //Reverse the toggle val
                        soundSwitch = value; //Update the var
                      });
                    },
                    initialValue: soundSwitch,
                    leading: const Icon(Icons.volume_up_outlined),
                    title: const Text('Audio'),
                  ),
                ],
              ),
              SettingsSection(
                tiles: <SettingsTile>[
                  SettingsTile(
                    title: const Text('Account email'),
                    leading: const Icon(Icons.email_outlined),
                    value: Text(
                      profileModel.selectedProfile.linkedAccount == null
                          ? 'No email'
                          : profileModel.selectedProfile.linkedAccount!.email,
                    ),
                    onPressed: (context) => setupAccount(isSynchronized),
                  ),
                  SettingsTile(
                    title: const Text('Teacher email'),
                    leading: const Icon(Icons.escalator_warning),
                    // const Column(children: [
                    //   Icon(Icons.school_outlined),
                    //   Icon(Icons.mail_outline)
                    // ]),
                    value: Text(profileModel.selectedProfile.teacherEmail ??
                        'No email'),
                    onPressed: (BuildContext context) {
                      textBoxPopup(
                        context,
                        const Text("Change teacher email"),
                        const Text("Please enter new teacher email"),
                        onSubmitted: (newEmail) async {
                          try {
                            await profileModel.changeTeacherEmail(
                                profileModel.selectedProfile, newEmail);
                          } catch (e) {
                            if (kDebugMode) {
                              print("Unable to change teacher email");
                              print(e);
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        "Unable to change teacher email. Please check your internet connection and try again.")));
                          }
                        },
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ]),
    );
  }

  ///A Widget for the popup that should appear when changing a setting. Consists of an AlertDialog, with a description and a text entry box.
  ///
  /// The current [contex] is needed to feed information, such as the theme, to the AlertDialog and build it.
  /// [title] is the title of the popup
  /// [description] is the Text Widget that contains the text that should be displayed
  textBoxPopup(context, Widget title, Widget description,
      {void Function(String)? onSubmitted}) {
    TextEditingController textEditingController =
        TextEditingController(); // Controller for text field
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: title,
            content: SingleChildScrollView(
              //TODO: Find more effective solution, throws error if ListBody is content
              child: ListBody(
                children: <Widget>[
                  description,
                  TextField(
                    controller:
                        textEditingController, //Use the controller here,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Press to write",
                    ),
                    onSubmitted: (value) {
                      if (onSubmitted != null) {
                        onSubmitted(value);
                      }
                      Navigator.of(context).pop(); //close the dialog
                    },
                  )
                ],
              ),
            ),
          );
        });
  }

  ///A Widget for the popup that should appear when changing the language. Consists of an AlertDialog,
  /// with a title and a [SettingsList] with various preset languages listed.
  ///
  /// The current [contex] is needed to feed information, such as the theme, to the AlertDialog and build it.
  languageSelectPopup(context) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Välj språk"),
            content: SingleChildScrollView(
              //TODO: Apply Language Localization
              child: SettingsList(shrinkWrap: true, sections: [
                SettingsSection(tiles: [
                  SettingsTile(
                    title: const Text("English"),
                    onPressed: (BuildContext context) {},
                  ),
                  SettingsTile(
                    title: const Text("Español"),
                    onPressed: (BuildContext context) {},
                  ),
                  SettingsTile(
                    title: const Text("Deutsch"),
                    onPressed: (BuildContext context) {},
                  ),
                ]),
              ]),
            ),
          );
        });
  }

  _settingsThemeData() {
    return SettingsThemeData(
      titleTextColor: Theme.of(context).colorScheme.onPrimaryContainer,
      leadingIconsColor: Theme.of(context).colorScheme.onPrimaryContainer,
      trailingTextColor: Theme.of(context).colorScheme.onPrimaryContainer,
      settingsTileTextColor: Theme.of(context).colorScheme.onPrimaryContainer,
      settingsListBackground:
          Theme.of(context).colorScheme.primaryContainer.withAlpha(50),
      settingsSectionBackground: Colors.white,
      tileDescriptionTextColor: Theme.of(context).colorScheme.primaryContainer,
      //dividerColor: Theme.of(context).colorScheme.onPrimaryContainer,
    );
  }
}
