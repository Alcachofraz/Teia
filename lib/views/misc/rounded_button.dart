import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

class RoundedButton extends StatelessWidget {
  final Color? color;
  final Widget? leading;
  final String text;
  final Function()? onTap;
  final bool strokeOnly;
  final bool matchParent;
  final double padding;
  final List<Color>? gradient;
  final TextStyle? textStyle;
  final double? height;
  final double borderRadius;
  final Color? borderColor;
  final bool enabled;
  final bool expand;

  RoundedButton({
    super.key,
    this.color,
    this.leading,
    required this.text,
    required this.onTap,
    this.strokeOnly = false,
    this.matchParent = true,
    this.padding = 12,
    this.gradient,
    this.textStyle,
    this.height,
    this.borderRadius = 8.0,
    this.borderColor,
    this.enabled = true,
    this.expand = false,
  });

  final RxBool loading = false.obs;

  @override
  Widget build(BuildContext context) {
    Text getText() => Text(
          text,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: textStyle ?? const TextStyle(color: Colors.white),
          maxLines: 1,
        );

    return SizedBox(
      height: height,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.all(padding),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          backgroundColor: color ?? Colors.black,
          disabledBackgroundColor: Colors.grey[600],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            side: borderColor != null
                ? BorderSide(
                    color: borderColor!,
                    width: 2,
                  )
                : BorderSide.none,
          ),
        ),
        onPressed: loading.value || !enabled
            ? null
            : () async {
                if (onTap != null) {
                  loading.value = true;
                  await onTap!.call();
                  loading.value = false;
                }
              },
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Obx(
            () => Row(
              mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                if (loading.value) const Gap(4),
                if (loading.value)
                  const SizedBox(
                    height: 16,
                    width: 16,
                  ),
                if (expand)
                  Expanded(
                    child: getText(),
                  )
                else
                  getText(),
                if (loading.value) const Gap(4),
                if (loading.value)
                  SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.5,
                      color: enabled ? Colors.white : Colors.grey[400],
                    ),
                  )
                else
                  const SizedBox.shrink(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
