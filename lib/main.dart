import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart' hide Page;
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:teia/firebase_options.dart';
import 'package:teia/screens/auth/login_screen.dart';
import 'package:teia/screens/auth/register_screen.dart';
import 'package:teia/screens/chapter_editor/chapter_editor_screen.dart';
import 'package:teia/screens/group/group_screen.dart';
import 'package:teia/screens/home/home_screen.dart';
import 'package:teia/screens/image_editor/image_editor_screen.dart';
import 'package:teia/services/authentication_service.dart';
import 'package:teia/utils/swatch.dart';
import 'package:teia/utils/utils.dart';
import 'package:url_strategy/url_strategy.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setPathUrlStrategy();
  Utils.init();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const Teia());
}

class Teia extends StatelessWidget {
  const Teia({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Teia',
      initialRoute: '/landing',
      getPages: [
        GetPage(
          name: '/home',
          page: () => const HomeScreen(),
        ),
        GetPage(
          name: '/group',
          page: () => const GroupScreen(),
        ),
        GetPage(
          name: '/landing',
          page: () => const LandingScreen(),
        ),
        GetPage(
          name: '/login',
          page: () => const LoginScreen(),
        ),
        GetPage(
          name: '/register',
          page: () => const RegisterScreen(),
        ),
        GetPage(
          name: '/chapter_editor',
          page: () => ChapterEditorScreen(),
          children: [
            GetPage(
              name: '/generate',
              page: () => const ImageEditorScreen(),
            ),
          ],
        ),
      ],
      theme: ThemeData(
        primarySwatch: swatch(Colors.red[300]!),
        textTheme: GoogleFonts.montserratTextTheme(textTheme),
      ),
      home: const LandingScreen(),
    );
  }
}

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: Get.put(AuthenticationService()).authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!) {
            return const HomeScreen();
          } else {
            return const LoginScreen();
          }
        } else {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }
}
