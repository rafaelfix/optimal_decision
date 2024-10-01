import 'package:flutter/material.dart';
import 'package:olle_app/screens/choose_visualisation_page.dart';
import 'package:olle_app/screens/map_page.dart';
import 'package:olle_app/screens/settings_page.dart';
import 'package:olle_app/screens/statistics_page.dart';
import 'package:olle_app/widgets/olle_app_bar.dart';
import 'package:provider/provider.dart';

import '../functions/profiles.dart';

/// The main page for the app once the user is "logged in".
/// Contains buttons which lead to the Practise, Statistics, Settings and Tools pages.
///
/// Practice is the page where the user can practise their skills.
/// Statistics is the page where the user can see their progress.
/// Settings is the page where the user can change their settings.
/// Tools is the page where the user can find help with their skills.
class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int currentPageIndex = 0;

  List<Widget> pages = [
    const MapPage(),
    const ChooseVisualisationPage(),
    const StatisticsPage(),
    const SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final ProfileModel profileModel = Provider.of<ProfileModel>(context);
    return Scaffold(
      appBar: OlleAppBar(
        selectedProfile: profileModel.selectedProfile.name,
      ),
      bottomNavigationBar: olleNavBar(context),
      body: pages[currentPageIndex],
    );
  }

  NavigationBar olleNavBar(BuildContext context) {
    return NavigationBar(
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
      indicatorShape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      destinations: [
        NavigationDestination(
            icon: Icon(
              Icons.home_rounded,
              fill: 1,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
              size: 36,
            ),
            label: ""),
        NavigationDestination(
            icon: Icon(
              Icons.menu_book_rounded,
              fill: 1,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
              size: 36,
            ),
            label: ""),
        NavigationDestination(
            icon: Icon(
              Icons.show_chart_rounded,
              fill: 0,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
              size: 36,
            ),
            label: ""),
        NavigationDestination(
            icon: Icon(
              Icons.settings_rounded,
              fill: 1,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
              size: 36,
            ),
            label: "")
      ],
      selectedIndex: currentPageIndex,
      onDestinationSelected: (int index) {
        setState(() {
          currentPageIndex = index;
        });
      },
    );
  }
}
