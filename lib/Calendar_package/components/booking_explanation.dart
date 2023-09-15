import 'package:flutter/material.dart';

class BookingExplanation extends StatelessWidget {
  const BookingExplanation(
      {Key? key,
      required this.color,
      required this.text,
      this.explanationIconSize})
      : super(key: key);

  final Color color;
  final String text;
  final double? explanationIconSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: explanationIconSize ?? 16,
          width: explanationIconSize ?? 16,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            fontFamily: "Inter",
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: Color(0xff1b1b1b),
            height: 15 / 12,
          ),
          textAlign: TextAlign.center,
        )
      ],
    );
  }
}
