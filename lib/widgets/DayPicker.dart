import 'package:flutter/material.dart';
import 'package:day_picker/day_picker.dart';

class DayPicker extends StatelessWidget {
  const DayPicker({super.key});

  @override
  Widget build(BuildContext context) {
    List<DayInWeek> _days = [
      DayInWeek(
        "lun",
        dayKey: 'lundi',
      ),
      DayInWeek(
        "mar",
        dayKey: 'mardi',
      ),
      DayInWeek("mer", dayKey: 'mercredi', isSelected: true),
      DayInWeek(
        "jeu",
        dayKey: 'jeudi',
      ),
      DayInWeek(
        "ven",
        dayKey: 'vendredi',
      ),
      DayInWeek(
        "sam",
        dayKey: 'samedi',
      ),
      DayInWeek(
        "dim",
        dayKey: 'dimanche',
      ),
    ];

    return SelectWeekDays(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      days: _days,
      border: false,
      boxDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30.0),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          colors: [Color(0xFFE55CE4), Color(0xFFBB75FB)],
          tileMode: TileMode.repeated, // repeats the gradient over the canvas
        ),
      ),
      onSelect: (values) {
        String Weekend = "";
        for (String s in values) {
          Weekend += "$s,";
        }

        //to do !!!! store the values in mongoDb
        // <== Callback to handle the selected days (values is a list of strings)
        print(values);
        print("ch =$Weekend");
      },
    );
  }
}
