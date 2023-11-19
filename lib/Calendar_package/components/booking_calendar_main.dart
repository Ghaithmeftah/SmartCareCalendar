import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:smartcare_calender/colors.dart';
import '../../table_calendar_package/table_calendar.dart';
//import 'package:table_calendar/table_calendar.dart';
import '../../table_calendar_package/table_calendar.dart' as tc
    show StartingDayOfWeek;

import '../../db/MongoWithFastApi.dart';
import '../../models/RangeSliderModel.dart';
import '../core/booking_controller.dart';
import '../model/booking_service.dart';
import '../model/enums.dart' as bc;
import '../util/booking_util.dart';
import 'booking_dialog.dart';
import 'booking_explanation.dart';
import 'booking_slot.dart';
import 'common_button.dart';
import 'common_card.dart';

class BookingCalendarMain extends StatefulWidget {
  const BookingCalendarMain({
    Key? key,
    required this.getBookingStream,
    required this.convertStreamResultToDateTimeRanges,
    required this.uploadBooking,
    this.bookingExplanation,
    this.bookingGridCrossAxisCount,
    this.bookingGridChildAspectRatio,
    this.formatDateTime,
    this.bookingButtonText,
    this.bookingButtonColor,
    this.bookedSlotColor,
    this.selectedSlotColor,
    this.availableSlotColor,
    this.bookedSlotText,
    this.bookedSlotTextStyle,
    this.selectedSlotText,
    this.selectedSlotTextStyle,
    this.availableSlotText,
    this.availableSlotTextStyle,
    this.gridScrollPhysics,
    this.loadingWidget,
    this.errorWidget,
    this.uploadingWidget,
    this.wholeDayIsBookedWidget,
    this.pauseSlotColor,
    this.pauseSlotText,
    this.hideBreakTime = false,
    this.locale,
    this.startingDayOfWeek,
    this.disabledDays,
    this.disabledDates,
    this.busyDates,
    this.bookedDates,
    this.lastDay,
  }) : super(key: key);

  final Stream<dynamic>? Function(
      {required DateTime start, required DateTime end}) getBookingStream;
  final Future<dynamic> Function({required Booking_Service newBooking})
      uploadBooking;
  final List<DateTimeRange> Function({required dynamic streamResult})
      convertStreamResultToDateTimeRanges;

  ///Customizable
  final Widget? bookingExplanation;
  final int? bookingGridCrossAxisCount;
  final double? bookingGridChildAspectRatio;
  final String Function(DateTime dt)? formatDateTime;
  final String? bookingButtonText;
  final Color? bookingButtonColor;
  final Color? bookedSlotColor;
  final Color? selectedSlotColor;
  final Color? availableSlotColor;
  final Color? pauseSlotColor;

//Added optional TextStyle to available, booked and selected cards.
  final String? bookedSlotText;
  final String? selectedSlotText;
  final String? availableSlotText;
  final String? pauseSlotText;

  final TextStyle? bookedSlotTextStyle;
  final TextStyle? availableSlotTextStyle;
  final TextStyle? selectedSlotTextStyle;

  final ScrollPhysics? gridScrollPhysics;
  final Widget? loadingWidget;
  final Widget? errorWidget;
  final Widget? uploadingWidget;

  final bool? hideBreakTime;
  final DateTime? lastDay;
  final String? locale;
  final bc.StartingDayOfWeek? startingDayOfWeek;
  final List<int>? disabledDays;
  final List<DateTime>? disabledDates;
  final List<DateTime>? busyDates;
  final List<DateTime>? bookedDates;

  final Widget? wholeDayIsBookedWidget;

  @override
  State<BookingCalendarMain> createState() => _BookingCalendarMainState();
}

class _BookingCalendarMainState extends State<BookingCalendarMain>
    with SingleTickerProviderStateMixin {
  late BookingController controller;
  final now = DateTime.now();
  late AnimationController _animationController;
  final textFieldMotifController = TextEditingController();

  @override
  void initState() {
    super.initState();

    controller = context.read<BookingController>();
    final firstDay = calculateFirstDay();

    startOfDay = firstDay.startOfDayService(controller.serviceOpening!);
    endOfDay = firstDay.endOfDayService(controller.serviceClosing!);
    _focusedDay = firstDay;
    _selectedDay = firstDay;
    controller.selectFirstDayByHoliday(startOfDay, endOfDay);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  CalendarFormat _calendarFormat = CalendarFormat.twoWeeks;

  late DateTime _selectedDay;
  late DateTime _focusedDay;
  late DateTime startOfDay;
  late DateTime endOfDay;

  void selectNewDateRange() {
    startOfDay = _selectedDay.startOfDayService(controller.serviceOpening!);
    endOfDay = _selectedDay
        .add(const Duration(days: 1))
        .endOfDayService(controller.serviceClosing!);

    controller.base = startOfDay;
    controller.resetSelectedSlot();
  }

  DateTime calculateFirstDay() {
    final now = DateTime.now();
    if (widget.disabledDays != null) {
      return widget.disabledDays!.contains(now.weekday)
          ? now.add(Duration(days: getFirstMissingDay(now.weekday)))
          : now;
    } else {
      return DateTime.now();
    }
  }

  int getFirstMissingDay(int now) {
    for (var i = 1; i <= 7; i++) {
      if (!widget.disabledDays!.contains(now + i)) {
        return i;
      }
    }
    return -1;
  }

  @override
  void dispose() {
    _animationController.dispose();
    //textFieldController.dispose();
    super.dispose();
  }

  String formatDateTime(DateTime dateTime) {
    final frenchDateFormat = DateFormat('EEEE dd/MM/yyyy', 'fr_FR');
    String day = frenchDateFormat.format(dateTime)[0].toUpperCase() +
        frenchDateFormat.format(dateTime).substring(1);
    return day;
  }

  @override
  Widget build(BuildContext context) {
    controller = context.watch<BookingController>();
    final sliderModelNotifier = Provider.of<RangeSliderModelNotifier>(context);
    Future openDialog() => showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Motif de consultation du patient :'),
              content: TextField(
                autofocus: true,
                controller: textFieldMotifController,
                decoration:
                    const InputDecoration(hintText: 'Décrivez votre état ...'),
              ),
              actions: [
                TextButton(
                    onPressed: () async {
                      controller.toggleUploading();
                      controller.toggleSlotChanging(controller.slot);
                      await widget.uploadBooking(
                          newBooking: controller
                              .generateNewBookingForUploading(controller.slot));
                      FastApi.takeAppointment(
                          controller.slot,
                          "647e8660ae87a55a026142b7",
                          "65491b0ea69b1e4f790fbca5",
                          textFieldMotifController.text);
                      controller.toggleUploading();
                      controller.resetSelectedSlot();

                      Navigator.of(context).pop();
                      textFieldMotifController.clear();
                    },
                    child: const Text(
                      'Confirmer',
                      style: TextStyle(color: AppColors.darkgrey),
                    ))
              ],
            ));

    return Consumer<BookingController>(
      builder: (_, controller, __) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: (controller.isUploading)
            ? widget.uploadingWidget ?? const BookingDialog()
            : ListView(
                children: [
                  CommonCard(
                    child: TableCalendar(
                      startingDayOfWeek: tc.StartingDayOfWeek.monday,
                      busydayPredicate: (day) {
                        if (widget.busyDates == null) return false;
                        bool isBusyDay = false;
                        for (var busyday in widget.busyDates!) {
                          if (isSameDay(day, busyday)) {
                            isBusyDay = true;
                          }
                        }
                        return isBusyDay;
                      },
                      wholeDayBookedPredicate: (day) {
                        if (widget.bookedDates == null) return false;
                        bool isBookedDate = false;
                        for (var bookedDate in widget.bookedDates!) {
                          if (isSameDay(day, bookedDate)) {
                            isBookedDate = true;
                          }
                        }
                        return isBookedDate;
                      },
                      holidayPredicate: (day) {
                        if (widget.disabledDates == null) return false;

                        bool isHoliday = false;
                        for (var holiday in widget.disabledDates!) {
                          if (isSameDay(day, holiday)) {
                            isHoliday = true;
                          }
                        }
                        return isHoliday;
                      },
                      enabledDayPredicate: (day) {
                        if (widget.disabledDays == null &&
                            widget.disabledDates == null) return true;

                        bool isEnabled = true;
                        if (widget.disabledDates != null) {
                          for (var holiday in widget.disabledDates!) {
                            if (isSameDay(day, holiday)) {
                              isEnabled = false;
                            }
                          }
                          if (!isEnabled) return false;
                        }
                        if (widget.disabledDays != null) {
                          isEnabled =
                              !widget.disabledDays!.contains(day.weekday);
                        }
                        return isEnabled;
                      },
                      locale: widget.locale,
                      firstDay: calculateFirstDay(),
                      lastDay: widget.lastDay ??
                          DateTime.now().add(const Duration(days: 1000)),
                      focusedDay: _focusedDay,
                      calendarFormat: _calendarFormat,
                      calendarStyle: const CalendarStyle(
                        isTodayHighlighted: true,
                        defaultTextStyle: TextStyle(color: AppColors.black),
                        weekendTextStyle: TextStyle(color: AppColors.black),
                        disabledTextStyle: TextStyle(color: Color(0xFFBFBFBF)),
                      ),
                      selectedDayPredicate: (day) {
                        return isSameDay(_selectedDay, day);
                      },
                      onDaySelected: (selectedDay, focusedDay) {
                        if (!isSameDay(_selectedDay, selectedDay)) {
                          setState(() {
                            _selectedDay = selectedDay;
                            _focusedDay = focusedDay;
                          });
                          selectNewDateRange();
                        }
                      },
                      onFormatChanged: (format) {
                        if (_calendarFormat != format) {
                          setState(() {
                            _calendarFormat = format;
                          });
                        }
                      },
                      onPageChanged: (focusedDay) {
                        _focusedDay = focusedDay;
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  Stack(
                    children: [
                      widget.bookingExplanation ??
                          Container(
                            width: double.infinity,
                            height: 36,
                            padding: const EdgeInsets.only(
                                right: 10, left: 10, top: 10, bottom: 10),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(10)),
                              border: Border.all(
                                color: AppColors.softGrey,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                BookingExplanation(
                                  color: AppColors.orangeaccent,
                                  text: widget.availableSlotText ??
                                      "Journée Chargée",
                                  explanationIconSize: 12,
                                ),
                                BookingExplanation(
                                  color: AppColors.pink,
                                  text: widget.selectedSlotText ??
                                      "Pas de Créneaux",
                                  explanationIconSize: 12,
                                ),
                                BookingExplanation(
                                  color: AppColors.softGrey,
                                  text:
                                      widget.bookedSlotText ?? "Jours de congé",
                                  explanationIconSize: 12,
                                ),
                              ],
                            ),
                          ),
                      Positioned(
                        left: 0,
                        top: -2,
                        child: Container(
                            color: Colors.white,
                            child: const Icon(
                              Icons.info,
                              color: AppColors.lightgrey,
                              size: 15,
                            )),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  StreamBuilder<dynamic>(
                    stream: widget.getBookingStream(
                        start: startOfDay, end: endOfDay),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return widget.errorWidget ??
                            Center(
                              child: Text(snapshot.error.toString()),
                            );
                      }

                      if (!snapshot.hasData) {
                        return widget.loadingWidget ??
                            const Center(child: CircularProgressIndicator());
                      }

                      ///this snapshot should be converted to List<DateTimeRange>
                      final data = snapshot.requireData;
                      controller.generateBookedSlots(
                          widget.convertStreamResultToDateTimeRanges(
                              streamResult: data));

                      return (widget.wholeDayIsBookedWidget != null &&
                              controller.isWholeDayBooked())
                          ? SingleChildScrollView(
                              child: widget.wholeDayIsBookedWidget!)
                          : SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    height: 35,
                                    decoration: BoxDecoration(
                                      color: Colors
                                          .white, // Background color of the container
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(
                                            10), // Top-left corner radius
                                        topRight: Radius.circular(
                                            10), // Top-right corner radius
                                      ), // Rounded corners, adjust the value as needed
                                      border: Border.all(
                                        color:
                                            AppColors.softGrey, // Border color
                                        width: 1, // Border width
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        const Padding(
                                            padding: EdgeInsets.only(left: 20)),
                                        const FaIcon(
                                          FontAwesomeIcons.calendarDay,
                                          size: 18,
                                        ),
                                        const Padding(
                                            padding: EdgeInsets.only(left: 10)),
                                        Text(formatDateTime(controller.base)),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: const BorderRadius.only(
                                            bottomLeft: Radius.circular(10),
                                            bottomRight: Radius.circular(10),
                                          ),
                                          border: Border.all(
                                            color: Colors.grey, // Border color
                                            width: 1, // Border width
                                          ),
                                        ),
                                        height: 180,
                                        // Set the desired height of the GridView here
                                        child: SingleChildScrollView(
                                          child: Column(children: [
                                            GridView.builder(
                                              shrinkWrap: true,
                                              physics: widget
                                                      .gridScrollPhysics ??
                                                  const BouncingScrollPhysics(),
                                              itemCount: controller
                                                  .filterMorningPauseSlots(
                                                      sliderModelNotifier
                                                          .sliderModel
                                                          .startMorningTime!,
                                                      sliderModelNotifier
                                                          .sliderModel
                                                          .endMorningTime!)
                                                  .length,
                                              itemBuilder: (context, index) {
                                                List<DateTime> morningSlots =
                                                    controller
                                                        .filterMorningPauseSlots(
                                                            sliderModelNotifier
                                                                .sliderModel
                                                                .startMorningTime!,
                                                            sliderModelNotifier
                                                                .sliderModel
                                                                .endMorningTime!);

                                                TextStyle? getTextStyle() {
                                                  if (controller
                                                      .isMorningSlotBooked(
                                                          index,
                                                          morningSlots)) {
                                                    return widget
                                                        .bookedSlotTextStyle;
                                                  } else if (index ==
                                                      controller
                                                          .selectedMorningSlot) {
                                                    return widget
                                                        .selectedSlotTextStyle;
                                                  } else {
                                                    return widget
                                                        .availableSlotTextStyle;
                                                  }
                                                }

                                                final morningslot = morningSlots
                                                    .elementAt(index);
                                                return BookingSlot(
                                                  hideBreakSlot:
                                                      widget.hideBreakTime,
                                                  pauseSlotColor:
                                                      widget.pauseSlotColor,
                                                  availableSlotColor:
                                                      widget.availableSlotColor,
                                                  bookedSlotColor:
                                                      widget.bookedSlotColor,
                                                  selectedSlotColor:
                                                      widget.selectedSlotColor,
                                                  isPauseTime: controller
                                                      .isSlotInPauseTime(
                                                          morningslot),
                                                  isBooked: controller
                                                      .isMorningSlotBooked(
                                                          index, morningSlots),
                                                  isSelected: index ==
                                                      controller
                                                          .selectedMorningSlot,
                                                  onTap: () => controller
                                                      .selectMorningSlot(
                                                          index, morningslot),
                                                  child: Center(
                                                    child: Text(
                                                      widget.formatDateTime
                                                              ?.call(
                                                                  morningslot) ??
                                                          BookingUtil
                                                              .formatDateTime(
                                                                  morningslot),
                                                      style: getTextStyle(),
                                                    ),
                                                  ),
                                                );
                                              },
                                              gridDelegate:
                                                  SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: widget
                                                        .bookingGridCrossAxisCount ??
                                                    4,
                                                childAspectRatio: widget
                                                        .bookingGridChildAspectRatio ??
                                                    2,
                                              ),
                                            ),
                                            const Padding(
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 5)),
                                            const Divider(
                                              height: 6,
                                              color: Colors.black,
                                            ),
                                            GridView.builder(
                                              shrinkWrap: true,
                                              physics: widget
                                                      .gridScrollPhysics ??
                                                  const BouncingScrollPhysics(),
                                              itemCount: controller
                                                  .filtereveningPauseSlots(
                                                      sliderModelNotifier
                                                          .sliderModel
                                                          .startAfternoonTime!,
                                                      sliderModelNotifier
                                                          .sliderModel
                                                          .endAfternoonTime!)
                                                  .length,
                                              itemBuilder: (context, index) {
                                                List<DateTime> eveningSlots =
                                                    controller.filtereveningPauseSlots(
                                                        sliderModelNotifier
                                                            .sliderModel
                                                            .startAfternoonTime!,
                                                        sliderModelNotifier
                                                            .sliderModel
                                                            .endAfternoonTime!);
                                                TextStyle? getTextStyle() {
                                                  if (controller
                                                      .isEveningSlotBooked(
                                                          index,
                                                          eveningSlots)) {
                                                    return widget
                                                        .bookedSlotTextStyle;
                                                  } else if (index ==
                                                      controller
                                                          .selectedEveningSlot) {
                                                    return widget
                                                        .selectedSlotTextStyle;
                                                  } else {
                                                    return widget
                                                        .availableSlotTextStyle;
                                                  }
                                                }

                                                final eveningSlot = eveningSlots
                                                    .elementAt(index);

                                                return BookingSlot(
                                                  hideBreakSlot:
                                                      widget.hideBreakTime,
                                                  pauseSlotColor:
                                                      widget.pauseSlotColor,
                                                  availableSlotColor:
                                                      widget.availableSlotColor,
                                                  bookedSlotColor:
                                                      widget.bookedSlotColor,
                                                  selectedSlotColor:
                                                      widget.selectedSlotColor,
                                                  isPauseTime: controller
                                                      .isSlotInPauseTime(
                                                          eveningSlot),
                                                  isBooked: controller
                                                      .isEveningSlotBooked(
                                                          index, eveningSlots),
                                                  isSelected: index ==
                                                      controller
                                                          .selectedEveningSlot,
                                                  onTap: () => controller
                                                      .selectEveningSlot(
                                                          index, eveningSlot),
                                                  child: Center(
                                                    child: Text(
                                                      widget.formatDateTime
                                                              ?.call(
                                                                  eveningSlot) ??
                                                          BookingUtil
                                                              .formatDateTime(
                                                                  eveningSlot),
                                                      style: getTextStyle(),
                                                    ),
                                                  ),
                                                );
                                              },
                                              gridDelegate:
                                                  SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: widget
                                                        .bookingGridCrossAxisCount ??
                                                    4,
                                                childAspectRatio: widget
                                                        .bookingGridChildAspectRatio ??
                                                    2,
                                              ),
                                            ),
                                            const Padding(
                                                padding: EdgeInsets.all(10))
                                          ]),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                    },
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  CommonButton(
                    width: 80,
                    text: widget.bookingButtonText ?? 'BOOK',
                    onTap: openDialog,
                    isDisabled: controller.selectedMorningSlot == -1 &&
                        controller.selectedEveningSlot == -1,
                    // isDesabled: controller.selectedSlot == -1,
                    buttonActiveColor: widget.bookingButtonColor,
                  ),
                ],
              ),
      ),
    );
  }
}
