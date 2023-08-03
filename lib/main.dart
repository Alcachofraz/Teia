import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart' hide Page;
import 'package:teia/firebase_options.dart';
import 'package:teia/screens/chapter_editor_screen/chapter_editor_screen.dart';
import 'package:teia/utils/swatch.dart';

import 'package:teia/utils/utils.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
      home: const ChapterEditorScreen(
        storyId: '1',
        chapterId: '1',
      ),
    );
  }
}
