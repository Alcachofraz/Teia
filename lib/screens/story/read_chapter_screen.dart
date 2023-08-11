import 'package:flutter/material.dart';

class ReadChapterScreen extends StatefulWidget {
  const ReadChapterScreen({super.key});

  @override
  State<ReadChapterScreen> createState() => _ReadChapterScreenState();
}

class _ReadChapterScreenState extends State<ReadChapterScreen> {
  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Text('Read Chapter Screen'),
        SizedBox(height: 20),
      ],
    );
  }
}
