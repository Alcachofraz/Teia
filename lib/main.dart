import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:teia/firebase_options.dart';
import 'package:teia/utils/swatch.dart';

import 'package:teia/utils/utils.dart';
import 'package:teia/views/auth/auth_gate.dart';
import 'package:teia/views/text_editor/page_edititing_controller.dart';
import 'package:teia/views/text_editor/text_part_style_definition.dart';

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
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    final TextEditingController textEditingController = PageEditingController(
      styles: TextPartStyleDefinitions(
        definitionList: <TextPartStyleDefinition>[
          TextPartStyleDefinition(
            style: const TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
            pattern: '[.,?!]',
          ),
          TextPartStyleDefinition(
            style: const TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
            pattern: '(?:(the|a|an) +)',
          ),
        ],
      ),
    );

    return Scaffold(
      body: Center(
        child: TextField(
          controller: textEditingController,
          autocorrect: false,
          enableSuggestions: false,
          textCapitalization: TextCapitalization.none,
        ),
      ),
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
