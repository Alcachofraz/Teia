import 'package:flutter/material.dart';
import 'package:teia/screens/graph_screen.dart';

import 'package:teia/utils/swatch.dart';
import 'package:teia/utils/utils.dart';

void main() {
  Utils.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Teia',
      theme: ThemeData(
        primarySwatch: swatch(Colors.red[300]!),
      ),
      home: const LandingPage(),
    );
  }
}

class LandingPage extends StatefulWidget {
  const LandingPage({Key? key}) : super(key: key);

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  @override
  Widget build(BuildContext context) {
    return const GraphScreen();
  }
}
