import 'package:flutter/material.dart';
import 'package:teia/screens/home_screen/popups/create_adventure/create_adventure.dart';
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
      body: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Tile(
              color: Colors.black,
              onTap: () {
                launchCreateAdventurePopup(context);
              },
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Join Adventure',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Tile(
              color: Colors.black,
              onTap: () {
                launchCreateAdventurePopup(context);
              },
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Create Adventure',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
