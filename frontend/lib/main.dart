import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';
import 'package:olle_app/functions/profiles.dart';
import 'package:olle_app/screens/main_page.dart';
import 'package:olle_app/screens/map_page.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/profile.dart';

/// Override required to make the app accept the server certificate
/// This fixes CERTIFICATE_VERIFY_FAILED on older systems.
///
/// A better way to solve this might be to load the certificate into the app
/// somehow.
class SSLHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
  HttpOverrides.global = SSLHttpOverrides();
  await GetStorage.init();
  // Prevent landscape mode: https://docs.flutter.dev/cookbook/design/orientation#locking-device-orientation
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const MyApp());
}

/// The main entry-point class for the app. Sets the global color theme and
/// displays the profile page
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ProfileModel(),
      child: MaterialApp(
        ///Routes till vissa statiska skärmar, för att kunna använda popUntil().
        routes: {
          '/home': (context) => const MainPage(),
          '/profile': (context) => const ProfilePage(),
          '/practiceMode': (context) => const MapPage(),
        },
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xff00538B),
            brightness: Brightness.light,
          ),
          textTheme: GoogleFonts.nunitoTextTheme(),
        ),
        // NOTE: Dark theme looks horrible (forcing light mode)
        // darkTheme: ThemeData(
        //   colorScheme: ColorScheme.fromSeed(
        //     seedColor: const Color(0xff00538B),
        //     brightness: Brightness.dark,
        //   ),
        //   textTheme: GoogleFonts.nunitoTextTheme(),
        // ),
        home: const ProfilePage(),
      ),
    );
  }
}
