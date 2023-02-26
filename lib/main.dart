import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart' hide Page;
import 'package:teia/firebase_options.dart';
import 'package:teia/screens/chapter_editor_screen.dart';
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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Teia',
      theme: ThemeData(
        primarySwatch: swatch(Colors.red[300]!),
      ),
      home: const ChapterEditorScreen(),
    );
  }
}

/*import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teia/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TODO Screen',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: const TODOScreen(),
    );
  }
}

class TODOScreen extends StatefulWidget {
  const TODOScreen({super.key});

  @override
  _TODOScreenState createState() => _TODOScreenState();
}

class _TODOScreenState extends State<TODOScreen> {
  final _ref = FirebaseFirestore.instance.collection('dummy').doc('0');
  final TextEditingController _todoController = TextEditingController();

  late StreamSubscription _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = _ref.snapshots().listen((data) {
      String value = data.get('dummy');
      updateOnChanged(value);
    });
  }

  saveOnChanged(String value) async {
    await _ref.set({'dummy': value});
  }

  updateOnChanged(String value) async {
    setState(() {
      _todoController.value = _todoController.value.copyWith(
        text: value,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TODO Screen'),
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(10.0),
          child: TextField(
            decoration: const InputDecoration(labelText: "TODO"),
            maxLines: 5,
            onChanged: saveOnChanged,
            controller: _todoController,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _todoController.dispose();

    _subscription.cancel();

    super.dispose();
  }
}*/
