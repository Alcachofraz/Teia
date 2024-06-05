import 'package:flutter/material.dart';

class Header extends StatelessWidget {
  const Header({
    required this.text,
    this.width = double.infinity,
    super.key,
    this.color = Colors.black,
  });

  final String text;
  final Color? color;
  final double width;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: SizedBox(
        width: width,
        child: Row(
          children: <Widget>[
            Expanded(
              child: Divider(
                color: color,
                height: 0.75,
                thickness: 0.75,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(text,
                  style: TextStyle(
                    color: color,
                    fontSize: 13,
                  )),
            ),
            Expanded(
              child: Divider(
                color: color,
                height: 0.75,
                thickness: 0.75,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
