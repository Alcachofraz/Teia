import 'package:flutter/material.dart';
import 'package:teia/views/misc/screen_wrapper.dart';
import 'package:teia/views/misc/tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return ScreenWrapper(
      body: Row(
        children: const [Tile()],
      ),
    );
  }
}
