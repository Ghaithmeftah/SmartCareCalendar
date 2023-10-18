import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:smartcare_calender/colors.dart';
import '../../db/MongoWithFastApi.dart';
import '../../table_calendar_package/table_calendar.dart';
//import 'package:table_calendar/table_calendar.dart';
import '../../table_calendar_package/table_calendar.dart' as tc
    show StartingDayOfWeek;

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

class BookingDoctorCalendarMain extends StatefulWidget {
  const BookingDoctorCalendarMain({
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
  State<BookingDoctorCalendarMain> createState() =>
      _BookingDoctorCalendarMainState();
}

class _BookingDoctorCalendarMainState extends State<BookingDoctorCalendarMain>
    with SingleTickerProviderStateMixin {
  bool isNewPatientSelected = false;
  String selectedPatient = 'Patient 1'; // Store the selected patient name
  TextEditingController patientMotifController = TextEditingController();
  TextEditingController newPatientMotifController = TextEditingController();
  TextEditingController patientNameController = TextEditingController();
  TextEditingController newPatientNameController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late BookingController controller;
  final PageController MyPageController = PageController();

  final now = DateTime.now();
  late AnimationController _animationController;
  final textFieldController = TextEditingController();

  bool nextPage = true;

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
    //controller.dispose();
    //textFieldController.dispose();
    super.dispose();
  }

  String formatDateTime(DateTime dateTime) {
    final frenchDateFormat = DateFormat('EEEE dd/MM/yyyy', 'fr_FR');
    String day = frenchDateFormat.format(dateTime)[0].toUpperCase() +
        frenchDateFormat.format(dateTime).substring(1);
    return day;
  }

  ValueNotifier<bool> isListViewVisibleNotifier = ValueNotifier<bool>(false);
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  bool isListViewVisible = false;

  Future openDialog() => showDialog(
        context: context,
        builder: (context) => StatefulBuilder(
          builder: (context, setState) {
            List<String> patientNames =
                List.generate(5, (index) => 'Patient $index');
            List<String> filteredPatientNames = List.from(patientNames);

            void filterPatientList(String query) {
              filteredPatientNames.clear();
              if (query.isNotEmpty) {
                for (String patientName in patientNames) {
                  if (patientName.toLowerCase().contains(query.toLowerCase())) {
                    filteredPatientNames.add(patientName);
                  }
                }
              } else {
                filteredPatientNames.addAll(patientNames);
              }
              setState(() {});
            }

            void hideListView() {
              setState(() {
                isListViewVisible = false;
              });
              isListViewVisibleNotifier.value = false;
            }

            void showListView() {
              setState(() {
                isListViewVisible = true;
              });
              isListViewVisibleNotifier.value = true;
            }

            return ValueListenableBuilder<bool>(
                valueListenable: isListViewVisibleNotifier,
                builder: (context, isListViewVisible, child) {
                  return AlertDialog(
                    title: const Text(
                      'Sélectionner ou ajouter un Patient :',
                      style: TextStyle(color: AppColors.black),
                    ),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Nouveau patient ?',
                              style: TextStyle(color: AppColors.darkgrey),
                            ),
                            Switch(
                              activeColor: AppColors.pink,
                              value: isNewPatientSelected,
                              onChanged: (value) {
                                setState(() {
                                  isNewPatientSelected = value;
                                });
                              },
                            ),
                          ],
                        ),
                        isNewPatientSelected
                            ? Form(
                                key: _formKey,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TextFormField(
                                      controller: newPatientNameController,
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return 'Veuillez entrer le nom du patient'; // Your error message
                                        }
                                        // You can add additional validation logic here.
                                        return null; // Return null if the input is valid.
                                      },
                                      decoration: const InputDecoration(
                                        hintText: 'Entrez le nom du patient...',
                                        hintStyle: TextStyle(
                                          color: AppColors.softGrey,
                                        ),
                                      ),
                                    ),
                                    TextField(
                                      controller: newPatientMotifController,
                                      decoration: const InputDecoration(
                                        hintText: 'Motif du Patient...',
                                        hintStyle: TextStyle(
                                          color: AppColors.softGrey,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    height: 60,
                                    width: 300,
                                    child: TextField(
                                      controller: patientNameController,
                                      decoration: InputDecoration(
                                        fillColor: AppColors.darkgrey,
                                        focusColor: AppColors.pink,
                                        hoverColor: AppColors.pink,
                                        prefixIcon: const Icon(Icons.search),
                                        hintText: 'Sélectionner un patient ...',
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                        suffixIcon: isListViewVisible
                                            ? IconButton(
                                                icon: const Icon(
                                                    Icons.keyboard_arrow_down),
                                                onPressed: hideListView,
                                              )
                                            : IconButton(
                                                icon: const Icon(
                                                    Icons.keyboard_arrow_left),
                                                onPressed: showListView,
                                              ),
                                      ),
                                      onChanged: (value) {
                                        // You can add your logic here to show/hide the ListView and filter the items
                                        filterPatientList(value);
                                        if (value.isNotEmpty) {
                                          // Text is not empty, show the ListView
                                          showListView();
                                        } else {
                                          // Text is empty, hide the ListView
                                          hideListView();
                                        }
                                      },
                                    ),
                                  ),
                                  if (isListViewVisible)
                                    SizedBox(
                                      width: 300,
                                      height: 94,
                                      child: Drawer(
                                        child: ListView.builder(
                                          itemCount:
                                              filteredPatientNames.length,
                                          itemBuilder: (context, index) {
                                            return ListTile(
                                              title: GestureDetector(
                                                onTap: () {
                                                  patientNameController.text =
                                                      filteredPatientNames[
                                                          index];
                                                  hideListView();
                                                },
                                                child: Text(
                                                    filteredPatientNames[
                                                        index]),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  TextFormField(
                                    controller: patientMotifController,
                                    decoration: const InputDecoration(
                                        hintText: 'Motif du patient...',
                                        hintStyle: TextStyle(
                                          color: AppColors.softGrey,
                                        )),
                                  ),
                                ],
                              ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Close the dialog
                        },
                        child: const Text(
                          'Annuler',
                          style: TextStyle(
                              color: AppColors.green,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          // Handle appointment scheduling logic here
                          if (isNewPatientSelected) {
                            if (_formKey.currentState!.validate()) {
                              // Add a new patient with newPatientController.text
                              print(
                                  'New Patient Name: ${newPatientMotifController.text}');
                              // Navigator.of(context).pop();
                              controller.toggleUploading();
                              controller.toggleSlotChanging(controller.slot);
                              await widget.uploadBooking(
                                newBooking:
                                    controller.generateNewBookingForUploading(
                                        controller.slot),
                              );
                              FastApi.takeAppointment(
                                controller.slot,
                                newPatientMotifController.text,
                                patientName: newPatientMotifController.text,
                              );

                              controller.toggleUploading();
                              controller.resetSelectedSlot();

                              newPatientMotifController.clear();
                              patientMotifController.clear();
                              newPatientNameController.clear();
                              Navigator.of(context).pop();
                            }
                          } else {
                            // Use the selected patient (selectedPatient)
                            print('Selected Patient: $selectedPatient');
                            // Navigator.of(context).pop();
                            controller.toggleUploading();
                            controller.toggleSlotChanging(controller.slot);
                            await widget.uploadBooking(
                              newBooking:
                                  controller.generateNewBookingForUploading(
                                      controller.slot),
                            );
                            FastApi.takeAppointment(
                              controller.slot,
                              patientMotifController.text,
                              patientName: selectedPatient,
                            );
                            controller.toggleUploading();
                            controller.resetSelectedSlot();

                            newPatientMotifController.clear();
                            patientMotifController.clear();
                            newPatientNameController.clear();
                            Navigator.of(context).pop();
                          }
                          // Close the dialog
                        },
                        child: const Text(
                          'Prendre rendez-vous',
                          style: TextStyle(
                              color: AppColors.green,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  );
                });
          },
        ),
      );

  @override
  Widget build(BuildContext context) {
    controller = context.watch<BookingController>();
    final sliderModelNotifier = Provider.of<RangeSliderModelNotifier>(context);

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
                        weekNumberTextStyle: TextStyle(color: AppColors.black),
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
                  SizedBox(
                    height: 20,
                    width: double.infinity,
                    child: Center(
                      child: Visibility(
                        visible: nextPage,
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 50,
                                child: Transform.scale(
                                  scaleX: 3.0,
                                  child: IconButton(
                                      iconSize: 15,
                                      alignment: Alignment.topCenter,
                                      hoverColor: AppColors.black,
                                      onPressed: () {},
                                      icon: const FaIcon(
                                        FontAwesomeIcons.arrowLeftLong,
                                        size: 15,
                                        color: AppColors.pink,
                                      )),
                                ),
                              ),
                              SizedBox(
                                width: 50,
                                child: Transform.scale(
                                  scaleX: 3.0,
                                  child: IconButton(
                                      iconSize: 15,
                                      onPressed: () {},
                                      icon: const FaIcon(
                                        FontAwesomeIcons.arrowRightLong,
                                        size: 15,
                                        color: AppColors.pink,
                                      )),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
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
                          : SizedBox(
                              height: 220,
                              child: PageView(
                                controller: MyPageController,
                                children: [
                                  SingleChildScrollView(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Container(
                                          height: 35,
                                          decoration: BoxDecoration(
                                            color: Colors
                                                .white, // Background color of the container
                                            borderRadius:
                                                const BorderRadius.only(
                                              topLeft: Radius.circular(
                                                  10), // Top-left corner radius
                                              topRight: Radius.circular(
                                                  10), // Top-right corner radius
                                            ), // Rounded corners, adjust the value as needed
                                            border: Border.all(
                                              color: AppColors
                                                  .softGrey, // Border color
                                              width: 1, // Border width
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  const Padding(
                                                      padding: EdgeInsets.only(
                                                          left: 20)),
                                                  const FaIcon(
                                                    FontAwesomeIcons
                                                        .calendarDay,
                                                    size: 18,
                                                  ),
                                                  const Padding(
                                                      padding: EdgeInsets.only(
                                                          left: 10)),
                                                  Text(formatDateTime(
                                                      controller.base)),
                                                ],
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 5),
                                                child: TextButton(
                                                    onPressed: () {
                                                      nextPage = !nextPage;
                                                      MyPageController.nextPage(
                                                        duration:
                                                            const Duration(
                                                                milliseconds:
                                                                    300),
                                                        curve: Curves.ease,
                                                      );
                                                    },
                                                    child: const Text(
                                                      'Mes Rendez-Vous >>>',
                                                      style: TextStyle(
                                                          fontSize: 14,
                                                          color: AppColors.pink,
                                                          fontWeight:
                                                              FontWeight.w500),
                                                    )),
                                              )
                                            ],
                                          ),
                                        ),
                                        Column(
                                          children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 20),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    const BorderRadius.only(
                                                  bottomLeft:
                                                      Radius.circular(10),
                                                  bottomRight:
                                                      Radius.circular(10),
                                                ),
                                                border: Border.all(
                                                  color: Colors
                                                      .grey, // Border color
                                                  width: 1, // Border width
                                                ),
                                              ),
                                              height: 185,
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
                                                    itemBuilder:
                                                        (context, index) {
                                                      List<DateTime>
                                                          morningSlots =
                                                          controller.filterMorningPauseSlots(
                                                              sliderModelNotifier
                                                                  .sliderModel
                                                                  .startMorningTime!,
                                                              sliderModelNotifier
                                                                  .sliderModel
                                                                  .endMorningTime!);
                                                      TextStyle?
                                                          getTextStyle() {
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

                                                      final Morningslot =
                                                          morningSlots
                                                              .elementAt(index);
                                                      return BookingSlot(
                                                        hideBreakSlot: widget
                                                            .hideBreakTime,
                                                        pauseSlotColor: widget
                                                            .pauseSlotColor,
                                                        availableSlotColor: widget
                                                            .availableSlotColor,
                                                        bookedSlotColor: widget
                                                            .bookedSlotColor,
                                                        selectedSlotColor: widget
                                                            .selectedSlotColor,
                                                        isPauseTime: controller
                                                            .isSlotInPauseTime(
                                                                Morningslot),
                                                        isBooked: controller
                                                            .isMorningSlotBooked(
                                                                index,
                                                                morningSlots),
                                                        isSelected: index ==
                                                            controller
                                                                .selectedMorningSlot,
                                                        onTap: () => controller
                                                            .selectMorningSlot(
                                                                index,
                                                                Morningslot),
                                                        child: Center(
                                                          child: Text(
                                                            widget.formatDateTime
                                                                    ?.call(
                                                                        Morningslot) ??
                                                                BookingUtil
                                                                    .formatDateTime(
                                                                        Morningslot),
                                                            style:
                                                                getTextStyle(),
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
                                                      padding:
                                                          EdgeInsets.symmetric(
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
                                                    itemBuilder:
                                                        (context, index) {
                                                      List<DateTime>
                                                          eveningSlots =
                                                          controller.filtereveningPauseSlots(
                                                              sliderModelNotifier
                                                                  .sliderModel
                                                                  .startAfternoonTime!,
                                                              sliderModelNotifier
                                                                  .sliderModel
                                                                  .endAfternoonTime!);
                                                      TextStyle?
                                                          getTextStyle() {
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

                                                      final eveningSlot =
                                                          eveningSlots
                                                              .elementAt(index);

                                                      return BookingSlot(
                                                        hideBreakSlot: widget
                                                            .hideBreakTime,
                                                        pauseSlotColor: widget
                                                            .pauseSlotColor,
                                                        availableSlotColor: widget
                                                            .availableSlotColor,
                                                        bookedSlotColor: widget
                                                            .bookedSlotColor,
                                                        selectedSlotColor: widget
                                                            .selectedSlotColor,
                                                        isPauseTime: controller
                                                            .isSlotInPauseTime(
                                                                eveningSlot),
                                                        isBooked: controller
                                                            .isEveningSlotBooked(
                                                                index,
                                                                eveningSlots),
                                                        isSelected: index ==
                                                            controller
                                                                .selectedEveningSlot,
                                                        onTap: () => controller
                                                            .selectEveningSlot(
                                                                index,
                                                                eveningSlot),
                                                        child: Center(
                                                          child: Text(
                                                            widget.formatDateTime
                                                                    ?.call(
                                                                        eveningSlot) ??
                                                                BookingUtil
                                                                    .formatDateTime(
                                                                        eveningSlot),
                                                            style:
                                                                getTextStyle(),
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
                                                      padding:
                                                          EdgeInsets.all(10))
                                                ]),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  SingleChildScrollView(
                                    child: Column(
                                      children: [
                                        SizedBox(
                                          height: 200,
                                          child: ListView(
                                            children: const [
                                              /*CommonCard(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(20)),
                                                color: AppColors.pink,
                                                margin: EdgeInsets.all(10),
                                                child: SizedBox(
                                                    height: 40,
                                                    child: Center(
                                                        child:
                                                            Text('patient 1'))),
                                              ),*/
                                              ListTile(
                                                leading: FaIcon(
                                                  FontAwesomeIcons
                                                      .solidCircleUser,
                                                  size: 50,
                                                ),
                                                title: Text(
                                                    "Mohamed el Kosdoghli"),
                                                subtitle: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  children: [
                                                    Text("Age:  54 ans"),
                                                    SizedBox(
                                                      width: 50,
                                                    ),
                                                    FaIcon(
                                                      FontAwesomeIcons
                                                          .userClock,
                                                      size: 20,
                                                    ),
                                                    Text("oui"),
                                                  ],
                                                ),
                                                trailing: FaIcon(
                                                  FontAwesomeIcons
                                                      .clipboardQuestion,
                                                  size: 25,
                                                ),
                                              ),
                                              CommonCard(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(20)),
                                                color: AppColors.pink,
                                                margin: EdgeInsets.all(10),
                                                child: ListTile(
                                                  leading: FaIcon(
                                                    FontAwesomeIcons
                                                        .solidCircleUser,
                                                    size: 40,
                                                  ),
                                                  title: Text(
                                                      "Mohamed el Kosdoghli"),
                                                  subtitle: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    children: [
                                                      Text("Age:  54 ans"),
                                                      SizedBox(
                                                        width: 50,
                                                      ),
                                                      FaIcon(
                                                        FontAwesomeIcons
                                                            .userClock,
                                                        size: 20,
                                                      ),
                                                      Text("oui"),
                                                    ],
                                                  ),
                                                  trailing: FaIcon(
                                                    FontAwesomeIcons
                                                        .clipboardQuestion,
                                                    size: 25,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
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
