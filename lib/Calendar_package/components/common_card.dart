import 'package:flutter/material.dart';

class CommonCard extends StatelessWidget {
  const CommonCard(
      {Key? key,
      required this.child,
      this.padding,
      this.margin,
      this.color,
      this.borderRadius,
      this.boxShadow})
      : super(key: key);

  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final BorderRadius? borderRadius;
  final BoxShadow? boxShadow;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: margin,
        padding: padding ?? const EdgeInsets.only(left: 8, right: 8),
        decoration: BoxDecoration(
          color: color ?? Colors.white,
          borderRadius:
              borderRadius ?? const BorderRadius.all(Radius.circular(6)),
          /*boxShadow: [
            boxShadow ??
                BoxShadow(
                    blurRadius: 10.0,
                    offset: const Offset(0, 5),
                    color: const Color(0xff666666).withOpacity(0.1))
          ],*/
        ),
        child: child);
  }
}
