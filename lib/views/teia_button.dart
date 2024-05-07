import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TeiaButton extends StatelessWidget {
  TeiaButton({
    this.text,
    this.widget,
    this.locked = false,
    this.borderRadius = 16,
    this.borderColor,
    this.padding,
    this.expand = true,
    super.key,
    this.color,
    this.onTap,
    this.textStyle,
  }) : assert(
          text != null || widget != null,
          'Text or widget must be provided',
        );

  final RxBool loading = false.obs;
  final bool locked;
  final String? text;
  final Widget? widget;
  final double borderRadius;
  final Color? borderColor;
  final EdgeInsets? padding;
  final Color? color;
  final dynamic Function()? onTap;
  final bool expand;

  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    Text getText() => Text(
          text!,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          maxLines: 1,
          style: textStyle ??
              const TextStyle(
                color: Colors.white,
              ),
        );
    final EdgeInsets padding_ = padding ??
        const EdgeInsets.fromLTRB(
          18,
          22,
          18,
          22,
        );
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        padding: padding_,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        backgroundColor: locked ? Colors.grey : (color ?? Colors.black),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          side: borderColor == null
              ? BorderSide.none
              : BorderSide(
                  color: borderColor!,
                ),
        ),
      ),
      onPressed: loading.value || locked
          ? null
          : () async {
              if (onTap != null) {
                loading.value = true;
                await onTap!.call();
                loading.value = false;
              }
            },
      child: Obx(
        () => Row(
          mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (loading.value && expand)
              const SizedBox(
                height: 16,
                width: 16,
              ),
            if (expand)
              Expanded(
                child: widget ?? getText(),
              )
            else
              widget ?? getText(),
            if (loading.value && expand)
              const SizedBox(
                height: 16,
                width: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 1.5,
                  color: Colors.white,
                ),
              )
            else
              const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}
