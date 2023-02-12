import 'package:flutter/cupertino.dart';
import 'package:teia/views/misc/animated_dialog.dart';
import 'package:teia/views/misc/rounded_button.dart';

class ConfirmUpwardOverlay extends StatefulWidget {
  final String title;
  final String message;
  final String buttonText;
  final dynamic Function()? onConfirm;
  final dynamic Function()? onCancel;

  const ConfirmUpwardOverlay({
    Key? key,
    required this.title,
    required this.message,
    required this.buttonText,
    this.onConfirm,
    this.onCancel,
  }) : super(key: key);

  @override
  State<ConfirmUpwardOverlay> createState() => _ConfirmUpwardOverlayState();
}

class _ConfirmUpwardOverlayState extends State<ConfirmUpwardOverlay> {
  @override
  Widget build(BuildContext context) {
    return AnimatedDialog(
      title: widget.title,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(widget.message),
            ),
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 4.0),
                    child: RoundedButton(
                      matchParent: true,
                      text: Text(widget.buttonText),
                      onTap: widget.onConfirm,
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 4.0),
                    child: RoundedButton(matchParent: true, text: const Text('Cancel'), onTap: widget.onCancel),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
