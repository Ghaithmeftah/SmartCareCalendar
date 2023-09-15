import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../colors.dart';

class BookedWidget extends StatefulWidget {
  final String text;
  const BookedWidget(this.text, {super.key});

  @override
  State<BookedWidget> createState() => _BookedWidgetState();
}

class _BookedWidgetState extends State<BookedWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      margin: const EdgeInsets.only(right: 20, left: 20, top: 20),
      decoration: BoxDecoration(
        color: Colors.pink.shade100,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        border: Border.all(
          color: AppColors.pink,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Center(
            child:
                FaIcon(FontAwesomeIcons.calendarXmark, color: AppColors.pink),
          ),
          Text(
            widget.text,
            style: const TextStyle(
              fontFamily: "Inter",
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: AppColors.pink,
              height: 57 / 16,
            ),
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }
}
