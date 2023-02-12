import 'package:flutter/material.dart';
import 'package:teia/screens/graph_screen.dart';
import 'package:teia/services/amplify_service.dart';

import 'package:teia/utils/swatch.dart';
import 'package:teia/utils/utils.dart';

import 'package:amplify_authenticator/amplify_authenticator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Utils.init();
  await AmplifyService.configure();
  runApp(
    Authenticator(
      child: const Teia(),
    ),
  );
}

class Teia extends StatelessWidget {
  const Teia({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Teia',
      theme: ThemeData(
        primarySwatch: swatch(Colors.red[300]!),
      ),
      builder: Authenticator.builder(),
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
