import '../model/booking_service.dart';
import '../util/booking_util.dart';
import 'package:flutter/material.dart';

class BookingController extends ChangeNotifier {
  Booking_Service bookingService;

  BookingController({required this.bookingService, this.pauseSlots}) {
    serviceOpening = bookingService.bookingStart;
    serviceClosing = bookingService.bookingEnd;
    pauseSlots = pauseSlots;
    if (serviceOpening!.isAfter(serviceClosing!)) {
      throw "Service closing must be after opening";
    }
    base = serviceOpening!;
    _generateBookingSlots();
  }

  late DateTime base;

  DateTime? serviceOpening;
  DateTime? serviceClosing;

  List<DateTime> _allBookingSlots = [];
  List<DateTime> get allBookingSlots => _allBookingSlots;

  List<DateTime> _allMorningSlots = [];
  List<DateTime> get allMorningSlots => _allMorningSlots;

  List<DateTime> _allEveningSlots = [];
  List<DateTime> get allEveningSlots => _allEveningSlots;

  List<DateTimeRange> bookedSlots = [];
  List<DateTimeRange>? pauseSlots = [];

  int _selectedMorningSlot = (-1);
  int _selectedEveningSlot = (-1);
  DateTime _slot = DateTime(2017, 9, 7, 8, 30);
  bool _isUploading = false;

  DateTime get slot => _slot;
  int get selectedMorningSlot => _selectedMorningSlot;
  int get selectedEveningSlot => _selectedEveningSlot;
  bool get isUploading => _isUploading;

  bool _successfullUploaded = false;
  bool get isSuccessfullUploaded => _successfullUploaded;

  bool isAfter(DateTime d, TimeOfDay t) {
    if (d.hour > t.hour) {
      return true;
    } else if (d.hour == t.hour && d.minute >= t.minute) {
      return true;
    } else {
      return false;
    }
  }

  bool isBefore(DateTime d, TimeOfDay t) {
    if (d.hour < t.hour) {
      return true;
    } else if (d.hour == t.hour && d.minute < t.minute) {
      return true;
    } else {
      return false;
    }
  }

  List<DateTime> filterMorningPauseSlots(
      TimeOfDay startMorningTime, TimeOfDay endMorningTime) {
    List<DateTime> filteredList = [];

    for (DateTime d in _allBookingSlots) {
      if (!isSlotInPauseTime(d) &&
          isAfter(d, startMorningTime) &&
          isBefore(d, endMorningTime)) {
        filteredList.add(d);
      }
    }

    return filteredList;
  }

  List<DateTime> filtereveningPauseSlots(
      TimeOfDay startEveningTime, TimeOfDay endEveningTime) {
    List<DateTime> filteredListevening = [];

    for (DateTime d in _allBookingSlots) {
      if (!isSlotInPauseTime(d) &&
          isAfter(d, startEveningTime) &&
          isBefore(d, endEveningTime)) {
        filteredListevening.add(d);
      }
    }

    return filteredListevening;
  }

  void initBack() {
    _isUploading = false;
    _successfullUploaded = false;
  }

  void selectFirstDayByHoliday(DateTime first, DateTime firstEnd) {
    serviceOpening = first;
    serviceClosing = firstEnd;
    base = first;
    _generateBookingSlots();
  }

  void _generateBookingSlots() async {
    allBookingSlots.clear();
    _allBookingSlots = List.generate(
        _maxServiceFitInADay(),
        (index) => base
            .add(Duration(minutes: bookingService.serviceDuration) * index));
    allMorningSlots.clear();
    //!!!!!!!!!!!!!!!!! don't forget to change the filters parameters and fetch the data from mongodb !!!!!!!!!!!!!!!!!
    _allMorningSlots = filterMorningPauseSlots(
        TimeOfDay(hour: 8, minute: 0), TimeOfDay(hour: 12, minute: 0));
    allEveningSlots.clear();
    _allEveningSlots = filtereveningPauseSlots(
        TimeOfDay(hour: 14, minute: 0), TimeOfDay(hour: 17, minute: 0));
  }

  bool isWholeDayBooked() {
    bool isBooked = true;
    for (var i = 0; i < allMorningSlots.length; i++) {
      if (!isMorningSlotBooked(i)) {
        isBooked = false;
        break;
      }
    }
    for (var i = 0; i < allEveningSlots.length; i++) {
      if (!isEveningSlotBooked(i)) {
        isBooked = false;
        break;
      }
    }
    return isBooked;
  }

  int _maxServiceFitInADay() {
    ///if no serviceOpening and closing was provided we will calculate with 00:00-24:00
    int openingHours = 24;
    if (serviceOpening != null && serviceClosing != null) {
      openingHours = DateTimeRange(start: serviceOpening!, end: serviceClosing!)
          .duration
          .inHours;
    }

    ///round down if not the whole service would fit in the last hours
    return ((openingHours * 60) / bookingService.serviceDuration).floor();
  }

  bool isMorningSlotBooked(int index) {
    DateTime checkSlot = allMorningSlots.elementAt(index);
    bool result = false;
    for (var slot in bookedSlots) {
      if (BookingUtil.isOverLapping(slot.start, slot.end, checkSlot,
          checkSlot.add(Duration(minutes: bookingService.serviceDuration)))) {
        result = true;
        break;
      }
    }
    return result;
  }

  bool isEveningSlotBooked(int index) {
    DateTime checkSlot = allEveningSlots.elementAt(index);
    bool result = false;
    for (var slot in bookedSlots) {
      if (BookingUtil.isOverLapping(slot.start, slot.end, checkSlot,
          checkSlot.add(Duration(minutes: bookingService.serviceDuration)))) {
        result = true;
        break;
      }
    }
    return result;
  }

  void selectMorningSlot(int idx, DateTime slot) {
    _selectedMorningSlot = idx;
    _selectedEveningSlot = -1;
    _slot = slot;
    notifyListeners();
  }

  void selectEveningSlot(int idx, DateTime slot) {
    _selectedEveningSlot = idx;
    _selectedMorningSlot = -1;
    _slot = slot;
    notifyListeners();
  }

  void resetSelectedSlot() {
    _selectedMorningSlot = -1;
    _selectedEveningSlot = -1;
    notifyListeners();
  }

  void toggleUploading() {
    _isUploading = !_isUploading;
    notifyListeners();
  }

  void toggleSlotChanging(DateTime slot) async {
    _slot = slot;
    notifyListeners();
  }

  Future<void> generateBookedSlots(List<DateTimeRange> data) async {
    bookedSlots.clear();
    _generateBookingSlots();

    for (var i = 0; i < data.length; i++) {
      final item = data[i];
      bookedSlots.add(item);
    }
  }

  Booking_Service generateNewBookingForUploading(DateTime datetime) {
    final bookingDate = allBookingSlots.firstWhere((d) => d == datetime);

    bookingService
      ..bookingStart = (bookingDate)
      ..bookingEnd =
          (bookingDate.add(Duration(minutes: bookingService.serviceDuration)));
    return bookingService;
  }

  bool isSlotInPauseTime(DateTime slot) {
    bool result = false;
    if (pauseSlots == null) {
      return result;
    }
    for (var pauseSlot in pauseSlots!) {
      if (BookingUtil.isOverLapping(pauseSlot.start, pauseSlot.end, slot,
          slot.add(Duration(minutes: bookingService.serviceDuration)))) {
        result = true;
        break;
      }
    }
    return result;
  }
}
