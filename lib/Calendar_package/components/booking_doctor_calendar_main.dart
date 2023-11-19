import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:smartcare_calender/Calendar_package/components/Accepted_waiting_doctor_appointments.dart';
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
  TextEditingController newPatientFirstNameController = TextEditingController();
  TextEditingController newPatientSecondNameController =
      TextEditingController();

  late BookingController controller;
  final PageController myPageController = PageController();

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

  void updateBookingState() {
    setState(() {
      ///reload page !!!
    });
  }

  ValueNotifier<bool> isListViewVisibleNotifier = ValueNotifier<bool>(false);
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  bool isListViewVisible = false;

  Future<void> openDialog(BuildContext context) async {
    Map<String, dynamic> patientNames = await FastApi.getDoctorsPatientsNames();

    //sort the map by the boolean values Local patient on top and shared on bottom!!
    // Convert the map to a list of entries (key-value pairs)
    List<MapEntry<String, dynamic>> patientList = patientNames.entries.toList();
    // Custom comparator function to sort by the boolean values in descending order
    patientList.sort((a, b) {
      // Sort in descending order so that true values come first
      return (b.value['is_local'] ? 1 : 0) - (a.value['is_local'] ? 1 : 0);
    });
    // Convert the sorted list back to a map
    patientNames = Map.fromEntries(patientList);
    List<String> patientIds = List.from(patientNames.keys.map((e) => e));

    List<String> filteredPatientNames =
        List.from(patientNames.values.map((e) => e['fullname'] as String));
    List<bool> filteredPatientIsLocalList =
        List.from(patientNames.values.map((e) => e['is_local'] as bool));

    bool isNewPatientSelected = false;
    final _formKey = GlobalKey<FormState>();
    // Capture the context before entering the async block
    BuildContext currentContext = context;

    // ignore: use_build_context_synchronously
    return showDialog(
      context: currentContext,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          void filterPatientList(String query) {
            filteredPatientNames.clear();
            if (query.isNotEmpty) {
              for (String patientName in patientNames.keys) {
                if (patientName.toLowerCase().contains(query.toLowerCase())) {
                  filteredPatientNames.add(patientName);
                }
              }
            } else {
              filteredPatientNames.addAll(patientNames.keys);
            }
            setState(() {});
          }

          void hideListView() {
            setState(() {
              isListViewVisible = false;
            });
          }

          void showListView() {
            setState(() {
              isListViewVisible = true;
            });
          }

          return FutureBuilder(
            future: Future
                .value(), // You can replace this with the actual future you are waiting for.
            builder: (context, snapshot) {
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
                                  controller: newPatientSecondNameController,
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Veuillez entrer le nom du patient';
                                    }
                                    return null;
                                  },
                                  decoration: const InputDecoration(
                                    hintText: 'Entrez le nom du patient...',
                                    hintStyle: TextStyle(
                                      color: AppColors.softGrey,
                                    ),
                                  ),
                                ),
                                TextFormField(
                                  controller: newPatientFirstNameController,
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Veuillez entrer le prénom du patient';
                                    }
                                    return null;
                                  },
                                  decoration: const InputDecoration(
                                    hintText: 'Entrez le prénom du patient...',
                                    hintStyle: TextStyle(
                                      color: AppColors.softGrey,
                                    ),
                                  ),
                                ),
                                TextFormField(
                                  controller: newPatientMotifController,
                                  decoration: const InputDecoration(
                                    hintText: 'Note',
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
                                      borderRadius: BorderRadius.circular(15),
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
                                    filterPatientList(value);
                                    if (value.isNotEmpty) {
                                      showListView();
                                    } else {
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
                                      itemCount: filteredPatientNames.length,
                                      itemBuilder: (context, index) {
                                        return ListTile(
                                          title: GestureDetector(
                                            onTap: () {
                                              patientNameController.text =
                                                  filteredPatientNames[index];
                                              hideListView();
                                            },
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 15.0),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(filteredPatientNames[
                                                      index]),
                                                  filteredPatientIsLocalList[
                                                          index]
                                                      ? const Row(
                                                          children: [
                                                            FaIcon(
                                                              FontAwesomeIcons
                                                                  .houseChimneyUser,
                                                              size: 15,
                                                            ),
                                                            SizedBox(
                                                              width: 10,
                                                            ),
                                                          ],
                                                        )
                                                      : const Text(''),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              TextFormField(
                                onTap: () => hideListView(),
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
                          color: AppColors.green, fontWeight: FontWeight.bold),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      if (isNewPatientSelected) {
                        if (_formKey.currentState!.validate()) {
                          controller.toggleUploading();
                          controller.toggleSlotChanging(controller.slot);
                          await widget.uploadBooking(
                              newBooking:
                                  controller.generateNewBookingForUploading(
                                      controller.slot));
                          //don't forget to change the doctor_id =currentuser here and patientId is the patientSelelected from the ListView Above
                          await FastApi.takeAppointmentForNewPatient(
                              controller.base,
                              '647e8660ae87a55a026142b7',
                              newPatientFirstNameController.text,
                              newPatientSecondNameController.text,
                              patientMotifController.text);

                          controller.toggleUploading();
                          controller.resetSelectedSlot();

                          Navigator.of(context).pop();
                          patientMotifController.clear();
                          print(
                              'New Patient Name: ${newPatientFirstNameController.text}');
                        }
                      } else {
                        controller.toggleUploading();
                        controller.toggleSlotChanging(controller.slot);
                        await widget.uploadBooking(
                            newBooking:
                                controller.generateNewBookingForUploading(
                                    controller.slot));
                        //don't forget to change the doctor_id =currentuser here and patientId is the patientSelelected from the ListView Above
                        FastApi.takeAppointment(
                            controller.base,
                            '647e8660ae87a55a026142b7',
                            patientIds[filteredPatientNames.indexOf(
                                patientNameController
                                    .text)], //this is the I d of the patient selected from the list
                            patientMotifController.text);
                        controller.toggleUploading();
                        controller.resetSelectedSlot();

                        Navigator.of(context).pop();
                        patientMotifController.clear();
                        print(
                            'Selected Patient: ${patientNameController.text}');
                      }
                    },
                    child: const Text(
                      'Prendre rendez-vous',
                      style: TextStyle(
                          color: AppColors.green, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

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
                  const SizedBox(
                    height: 20,
                    width: double.infinity,
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
                              height: 400,
                              child: PageView(
                                controller: myPageController,
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
                                                child: Container(
                                                  width:
                                                      180, // Adjust the width as needed
                                                  decoration: BoxDecoration(
                                                    color: AppColors.green,
                                                    borderRadius:
                                                        const BorderRadius.all(
                                                            Radius.circular(
                                                                24)),
                                                    border: Border.all(
                                                        color: AppColors
                                                            .greySoligth,
                                                        width: 2),
                                                  ),
                                                  child: TextButton(
                                                    onPressed: () {
                                                      nextPage = !nextPage;
                                                      myPageController.nextPage(
                                                        duration:
                                                            const Duration(
                                                                milliseconds:
                                                                    300),
                                                        curve: Curves.ease,
                                                      );
                                                    },
                                                    style: ButtonStyle(
                                                      padding:
                                                          MaterialStateProperty
                                                              .all(
                                                        const EdgeInsets
                                                                .symmetric(
                                                            horizontal: 5),
                                                      ),
                                                    ),
                                                    child: const Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceEvenly,
                                                      children: [
                                                        FaIcon(
                                                          FontAwesomeIcons
                                                              .arrowsRotate,
                                                          color: AppColors.pink,
                                                        ),
                                                        Text(
                                                          'Mes Rendez-Vous',
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            color:
                                                                AppColors.white,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
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
                                              height: 200,
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

                                                      final morningslot =
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
                                                                morningslot),
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
                                                                morningslot),
                                                        child: Center(
                                                          child: Text(
                                                            widget.formatDateTime
                                                                    ?.call(
                                                                        morningslot) ??
                                                                BookingUtil
                                                                    .formatDateTime(
                                                                        morningslot),
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
                                        const SizedBox(
                                          height: 20,
                                        ),
                                        CommonButton(
                                          width: 200,
                                          text: widget.bookingButtonText ??
                                              'BOOK',
                                          onTap: () => openDialog(context),
                                          isDisabled: controller
                                                      .selectedMorningSlot ==
                                                  -1 &&
                                              controller.selectedEveningSlot ==
                                                  -1,
                                          // isDesabled: controller.selectedSlot == -1,
                                          buttonActiveColor:
                                              widget.bookingButtonColor,
                                        ),
                                      ],
                                    ),
                                  ),
                                  AcceptedAndWaitingDoctorAppointments(
                                      controller: controller,
                                      onChanged: () {
                                        setState(() {
                                          updateBookingState();
                                        });
                                      }),
                                ],
                              ),
                            );
                    },
                  ),
                ],
              ),
      ),
    );
  }
}
