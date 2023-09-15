import 'package:flutter/material.dart';

class RangeSliderModel {
  TimeOfDay startMorningTime;
  TimeOfDay endMorningTime;
  TimeOfDay startAfternoonTime;
  TimeOfDay endAfternoonTime;

  RangeSliderModel(
      {this.startMorningTime = const TimeOfDay(hour: 9, minute: 0),
      this.endMorningTime = const TimeOfDay(hour: 11, minute: 0),
      this.startAfternoonTime = const TimeOfDay(hour: 15, minute: 0),
      this.endAfternoonTime = const TimeOfDay(hour: 17, minute: 0)});
}

class RangeSliderModelNotifier extends ChangeNotifier {
  RangeSliderModel _sliderModel;

  RangeSliderModelNotifier(
      {TimeOfDay startMorningTime = const TimeOfDay(hour: 9, minute: 0),
      TimeOfDay endMorningTime = const TimeOfDay(hour: 11, minute: 0),
      TimeOfDay startAfternoonTime = const TimeOfDay(hour: 15, minute: 0),
      TimeOfDay endAfternoonTime = const TimeOfDay(hour: 17, minute: 0)})
      : _sliderModel = RangeSliderModel(
            startMorningTime: startMorningTime,
            endMorningTime: endMorningTime,
            startAfternoonTime: startAfternoonTime,
            endAfternoonTime: endAfternoonTime);

  RangeSliderModel get sliderModel => _sliderModel;

  set sliderModel(RangeSliderModel newModel) {
    _sliderModel = newModel;
    notifyListeners();
  }
}
