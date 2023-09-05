import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart' hide Page;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:teia/firebase_options.dart';
import 'package:teia/screens/auth_screen/login_screen.dart';
import 'package:teia/screens/chapter_editor_screen/chapter_editor_screen.dart';
import 'package:teia/screens/home_screen/home_screen.dart';
import 'package:teia/services/authentication_service.dart';
import 'package:teia/utils/swatch.dart';
import 'package:teia/utils/utils.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Utils.init();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const Teia());
}

class Teia extends StatelessWidget {
  const Teia({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Teia',
      theme: ThemeData(
        primarySwatch: swatch(Colors.red[300]!),
        textTheme: GoogleFonts.sourceSansProTextTheme(textTheme),
      ),
      home: const LandingScreen(),
    );
  }
}

class LandingScreen extends StatelessWidget {
  const LandingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: AuthenticationService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!) {
            return const ChapterEditorScreen(storyId: '1', chapterId: '1');
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
