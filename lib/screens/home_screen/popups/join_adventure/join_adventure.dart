import 'package:flutter/material.dart';

launchCreateAdventurePopup(BuildContext context) {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Join adventure'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
                'Enter the name and password of the adventure you want to join:'),
            SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Adventure name',
              ),
            ),
            SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Adventure password',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Join'),
          ),
        ],
      );
    },
  );
}
