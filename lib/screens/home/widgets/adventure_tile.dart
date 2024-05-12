import 'package:flutter/material.dart';
import 'package:teia/models/group.dart';
import 'package:teia/services/art_service.dart';

class AdventureTile extends StatelessWidget {
  const AdventureTile({
    super.key,
    this.onTap,
    this.adventure,
  });

  final Group? adventure;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    Color color = ArtService.value.pastel();
    Color textColor = ArtService.value.darken(color, 54);
    return Material(
      color: color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: adventure != null
            ? BorderSide.none
            : BorderSide(
                color: textColor,
                width: 2,
              ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 300,
          height: 200,
          child: adventure != null
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    adventure!.name,
                    style: const TextStyle(color: Colors.black),
                  ),
                )
              : Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, color: textColor, size: 48),
                      Text(
                        'Create a new adventure',
                        style: TextStyle(color: textColor),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
