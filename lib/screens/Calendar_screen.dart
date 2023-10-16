import 'dart:async';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

import '../Calendar_package/core/booking_doctor_calendar.dart';
import '../colors.dart';
import 'package:flutter/material.dart';
import '../db/MongoWithFastApi.dart';
import '../models/Calendar.dart';
import '../models/RangeSliderModel.dart';
import '../widgets/bottom_navigation_bar_widget.dart';
import '../mongodb.dart';

import '../Calendar_package/model/booking_service.dart';
import '../Calendar_package/model/enums.dart';
import './DoctorFormularScreenFastApi.dart';

import 'package:smartcare_calender/widgets/booked_widget.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  List<DateTime>? freeDates = [];
  final now = DateTime.now();
  late Booking_Service mockBookingService;
  late List<DateTime> fetchDoctorsbusyDates = [];
  late List<DateTime> fetchDoctorsBookedDates = [];

  late List<Map<String, dynamic>> fetchDoctorAppointmentsDates = [];
  Map<String, dynamic> data = {};
  int startWorkTime = 2;
  bool isExpanded = false;

  @override
  void initState() {
    super.initState();
    //Future<Calendar> cal = MongoDatabase.getData();
    // DateTime.now().startOfDay
    // DateTime.now().endOfDay

    // Fetch data initially when the screen loads
    fetchData();
    getAppointmentsDates();

    getBusyDates();
    getBookedDates();
    /*mockBookingService = BookingService(
        serviceName: 'Mock Service',
        //La durée du consultaion !!!!! est 30 min
        serviceDuration: 30,
        //18h est le temps dont le médecin vas retourner à la maison
        bookingEnd: DateTime(now.year, now.month, now.day, 18, 0),
        //8h est l'heure de début de travail
        bookingStart: DateTime(now.year, now.month, now.day, 8, 0));*/
  }

  Future<void> fetchData() async {
    try {
      //List<Map<String, dynamic>> newData = await MongoDatabase.getDocument();
      Map<String, dynamic> newData = await FastApi.fetchCalendar();
      setState(() {
        data = newData;
        startWorkTime = getHour(data["start_work_time"]);
      });
      print(data);
    } catch (error) {
      // Handle any errors that occurred during data fetch
      print('Error: $error');
    }
  }

  void setFreeDates(List<DateTime>? list) {
    freeDates = list;
  }

  Future<void> getBusyDates() async {
    int maxNb = 0;
    maxNb = await FastApi.getNumberOfDailyAppointments();
    List<DateTime> listofbusyDates = await FastApi.getDoctorBusyDates(maxNb);

    if (mounted) {
      setState(() {
        fetchDoctorsbusyDates = listofbusyDates;
      });
    }
  }

  Future<void> getBookedDates() async {
    int maxNb = 0;
    maxNb = await FastApi.getNumberOfDailyAppointments();
    List<DateTime> listofbookedDates =
        await FastApi.getDoctorBookedDates(maxNb);
    if (mounted) {
      setState(() {
        fetchDoctorsBookedDates = listofbookedDates;
      });
    }
  }

  Stream<dynamic>? getBookingStreamMock(
      {required DateTime end, required DateTime start}) {
    return Stream.value([]);
  }

  Future<dynamic> uploadBookingMock(
      {required Booking_Service newBooking}) async {
    await Future.delayed(const Duration(seconds: 1));
    converted.add(DateTimeRange(
        start: newBooking.bookingStart, end: newBooking.bookingEnd));
    print('${newBooking.toJson()} has been uploaded');
  }

  List<DateTimeRange> converted = [];
  Future<void> getAppointmentsDates() async {
    List<Map<String, dynamic>> listofappointmentsDates =
        await FastApi.getAllDoctorsAppointments();
    if (mounted) {
      setState(() {
        fetchDoctorAppointmentsDates = listofappointmentsDates;
      });
    }
  }

  List<DateTimeRange> convertStreamResultMock({required dynamic streamResult}) {
    ///here you can parse the streamresult and convert to [List<DateTimeRange>]
    ///take care this is only mock, so if you add today as disabledDays it will still be visible on the first load
    ///disabledDays will properly work with real data
    List<Map<String, dynamic>> list = fetchDoctorAppointmentsDates;
    for (Map<String, dynamic> app in list) {
      DateTime date = DateTime.parse(app["date"]);
      String time = app["time"].toString();
      String duration = data["appointment_duration"].toString();
      DateTimeRange datetimeRange = DateTimeRange(
          start: DateTime(date.year, date.month, date.day,
              int.parse(time.split(":")[0]), int.parse(time.split(":")[1])),
          end: DateTime(
              date.year,
              date.month,
              date.day,
              int.parse(time.split(":")[0]),
              int.parse(time.split(":")[1]) + int.parse(duration)));
      if (!converted.contains(datetimeRange)) converted.add(datetimeRange);
    }
    return converted;
  }

  List<DateTimeRange> generatePauseSlots(String debutPause, String finPause) {
    return [
      DateTimeRange(
          //la pause déjeuner est de 12H à 13h !!!!
          start: DateTime(now.year, now.month, now.day, getHour(debutPause),
              getMinutes(debutPause)),
          end: DateTime(now.year, now.month, now.day, getHour(finPause),
              getMinutes(finPause)))
    ];
  }

  int getHour(String ch) =>
      MongoDatabase.getHourAndMinutesFromMongo(ch).values.first;
  int getMinutes(String ch) =>
      MongoDatabase.getHourAndMinutesFromMongo(ch).values.last;
  List<int> getWeekendDays(String weekend) {
    List<int> l = [];
    if (weekend.contains('lundi')) {
      l.add(1);
    }
    if (weekend.contains('mardi')) {
      l.add(2);
    }
    if (weekend.contains('mercredi')) {
      l.add(3);
    }
    if (weekend.contains('jeudi')) {
      l.add(4);
    }
    if (weekend.contains('vendredi')) {
      l.add(5);
    }
    if (weekend.contains('samedi')) {
      l.add(6);
    }
    if (weekend.contains('dimanche')) {
      l.add(7);
    }

    return l;
  }

  // Function to convert TimeOfDay to a formatted time string (e.g., 12:00 AM)
  String _timeToString(TimeOfDay time) {
    int hour = time.hour;
    String minute = time.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }

  // Function to convert TimeOfDay to double value based on 30-minute intervals
  double _timeToDouble(TimeOfDay time) {
    return time.hour.toDouble() + (time.minute.toDouble() / 60.0);
  }

  // Function to convert double value to TimeOfDay based on 30-minute intervals
  TimeOfDay _doubleToTime(double value) {
    int hour = value.floor();
    int minute = ((value - hour) * 60).round();

    return TimeOfDay(hour: hour, minute: minute);
  }

  @override
  Widget build(BuildContext context) {
    final sliderModelNotifier = Provider.of<RangeSliderModelNotifier>(context);

    // Set the initial slider values here
    sliderModelNotifier.sliderModel.startMorningTime ??=
        TimeOfDay(hour: 8, minute: 0);
    sliderModelNotifier.sliderModel.endMorningTime ??=
        const TimeOfDay(hour: 12, minute: 0);
    sliderModelNotifier.sliderModel.endAfternoonTime ??=
        const TimeOfDay(hour: 17, minute: 0);
    sliderModelNotifier.sliderModel.startAfternoonTime ??=
        const TimeOfDay(hour: 14, minute: 0);

    return Scaffold(
      bottomNavigationBar: const BottomNavigationBarWidget(),
      appBar: AppBar(
        toolbarHeight: 40,
        backgroundColor: const Color(0xffffffff),
        title: Row(
          children: <Widget>[
            Image.asset(
              'lib/assets/logo-symbol.png',
              width: 40,
              height: 40,
            ),
            const SizedBox(width: 8),
            const Text("Calendrier de réservation",
                style: TextStyle(
                    fontSize: 20,
                    color: AppColors.black,
                    fontWeight: FontWeight.bold)),
          ],
        ),
        automaticallyImplyLeading: false,
        actions: <Widget>[
          Ink(
            child: InkWell(
              onTap: () {},
              child: Image.asset(
                "lib/assets/icons/profile.png",
                height: 45,
                width: 45,
                color: const Color(0xff686868),
              ),
            ),
          ),
          Ink(
            child: InkWell(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  //    FastAPI   !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
                  builder: (context) => DoctorFormularScreenFastAPI(freeDates),
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.only(right: 8.0, left: 8.0),
                child: Icon(
                  Icons.settings,
                  size: 35,
                  color: Color(0xff686868),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(children: [
        Column(
          children: [
            Stack(children: [
              Positioned(
                left: 30,
                top: 6,
                child: Container(
                  color: Colors.white,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.0),
                    child: Text(
                      'Préférences horaires :',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkgrey,
                      ),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    isExpanded = !isExpanded;
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_down_sharp
                          : Icons.keyboard_arrow_up_sharp,
                      size: 36.0,
                      color: AppColors.pink,
                    ),
                    const SizedBox(
                      width: 30,
                      height: 5,
                    )
                  ],
                ),
              ),
              if (isExpanded)
                Container(
                  height: 100,
                  margin: const EdgeInsets.only(right: 20, left: 20, top: 25),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    border: Border.all(
                      color: AppColors.softGrey,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      const Padding(padding: EdgeInsets.symmetric(vertical: 8)),
                      Expanded(
                        child: SfRangeSliderTheme(
                          data: SfRangeSliderThemeData(
                            thumbRadius: 16,
                            inactiveTrackHeight: 10,
                            activeTrackHeight: 12,
                            activeDividerColor: AppColors.black,
                            inactiveDividerColor: AppColors.black,
                            activeDividerRadius: 2,
                            inactiveDividerRadius: 2,
                          ),
                          child: SfRangeSlider(
                            min: _timeToDouble(
                                const TimeOfDay(hour: 8, minute: 0)),
                            max: _timeToDouble(
                                const TimeOfDay(hour: 12, minute: 0)),
                            values: SfRangeValues(
                              _timeToDouble(sliderModelNotifier
                                  .sliderModel.startMorningTime!),
                              _timeToDouble(sliderModelNotifier
                                  .sliderModel.endMorningTime!),
                            ),
                            interval: 1,
                            inactiveColor: AppColors.softGrey,
                            activeColor: AppColors.pink,
                            showTicks: true,
                            //showLabels: true,
                            showDividers: true,
                            stepSize: 0.5,
                            startThumbIcon: Center(
                              child: Text(
                                _timeToString(sliderModelNotifier
                                    .sliderModel.startMorningTime!),
                                style: const TextStyle(
                                    color:
                                        AppColors.white, // Set the text color
                                    fontSize: 12.0,
                                    fontWeight: FontWeight
                                        .w500 // Adjust the font size as needed
                                    ),
                              ),
                            ),
                            endThumbIcon: Center(
                              child: Text(
                                _timeToString(sliderModelNotifier
                                    .sliderModel.endMorningTime!),
                                style: const TextStyle(
                                    color:
                                        AppColors.white, // Set the text color
                                    fontSize:
                                        12.0, // Adjust the font size as needed
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                            minorTicksPerInterval: 1,
                            onChanged: (SfRangeValues values) {
                              setState(() {
                                sliderModelNotifier
                                        .sliderModel.startMorningTime =
                                    _doubleToTime(values.start);
                                sliderModelNotifier.sliderModel.endMorningTime =
                                    _doubleToTime(values.end);
                                sliderModelNotifier.notifyListeners();
                              });
                            },
                          ),
                        ),
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10.0),
                              child: Text(
                                  _timeToString(
                                      const TimeOfDay(hour: 8, minute: 0)),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10.0),
                              child: Text(
                                  _timeToString(
                                      const TimeOfDay(hour: 12, minute: 0)),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Expanded(
                        child: SfRangeSliderTheme(
                          data: SfRangeSliderThemeData(
                            thumbRadius: 16,
                            inactiveTrackHeight: 10,
                            activeTrackHeight: 12,
                            activeDividerColor: AppColors.black,
                            inactiveDividerColor: AppColors.black,
                            activeDividerRadius: 2,
                            inactiveDividerRadius: 2,
                          ),
                          child: SfRangeSlider(
                            min: _timeToDouble(
                                const TimeOfDay(hour: 14, minute: 0)),
                            max: _timeToDouble(
                                const TimeOfDay(hour: 17, minute: 0)),
                            values: SfRangeValues(
                              _timeToDouble(sliderModelNotifier
                                  .sliderModel.startAfternoonTime!),
                              _timeToDouble(sliderModelNotifier
                                  .sliderModel.endAfternoonTime!),
                            ),
                            interval: 1,
                            inactiveColor: AppColors.softGrey,
                            activeColor: AppColors.pink,
                            showTicks: true,
                            //showLabels: true,
                            showDividers: true,
                            stepSize: 0.5,
                            startThumbIcon: Center(
                              child: Text(
                                _timeToString(sliderModelNotifier
                                    .sliderModel.startAfternoonTime!),
                                style: const TextStyle(
                                    color:
                                        AppColors.white, // Set the text color
                                    fontSize: 12.0,
                                    fontWeight: FontWeight
                                        .w500 // Adjust the font size as needed
                                    ),
                              ),
                            ),
                            endThumbIcon: Center(
                              child: Text(
                                _timeToString(sliderModelNotifier
                                    .sliderModel.endAfternoonTime!),
                                style: const TextStyle(
                                    color:
                                        AppColors.white, // Set the text color
                                    fontSize:
                                        12.0, // Adjust the font size as needed
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                            minorTicksPerInterval: 1,
                            onChanged: (SfRangeValues values) {
                              setState(() {
                                sliderModelNotifier
                                        .sliderModel.startAfternoonTime =
                                    _doubleToTime(values.start);
                                sliderModelNotifier
                                        .sliderModel.endAfternoonTime =
                                    _doubleToTime(values.end);
                                sliderModelNotifier.notifyListeners();
                              });
                            },
                          ),
                        ),
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10.0),
                              child: Text(
                                _timeToString(const TimeOfDay(
                                    hour: 14,
                                    minute:
                                        0)), //you need to change this accordingly to the database
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10.0),
                              child: Text(
                                  _timeToString(const TimeOfDay(
                                      hour: 17,
                                      minute:
                                          0)), //you need to change this accordingly to the database
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ),
                      const Padding(padding: EdgeInsets.symmetric(vertical: 8)),
                    ],
                  ),
                ),
            ]),
          ],
        ),
        FutureBuilder<Map<String, dynamic>>(
            // future: MongoDatabase.getDocument(),
            future: FastApi.fetchCalendar(),
            builder: (context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                // While waiting for data to load
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                // If an error occurred while fetching the data
                return Text('Error: ${snapshot.error}');
              } else {
                Calendar cal = Calendar(
                    snapshot.data!['start_work_time'],
                    snapshot.data!['end_work_time'],
                    snapshot.data!['start_pause_time'],
                    snapshot.data!['end_pause_time'],
                    snapshot.data!['appointment_duration'],
                    snapshot.data!['weekend_days'],
                    snapshot.data!['free_dates']);
                //covert the List<dynamic> returned from the calendar to a List<DateTime>
                freeDates =
                    cal.freeDates.map((item) => DateTime.parse(item)).toList();
                setFreeDates(freeDates);
                print(freeDates);
                mockBookingService = Booking_Service(
                    serviceName: 'Mock Service',
                    //La durée du consultaion !!!!! exemple (30 min) ( this line get it's value from MongoDb )
                    serviceDuration: int.parse(cal.duration),
                    //18h est le temps dont le médecin vas retourner à la maison
                    bookingEnd: DateTime(now.year, now.month, now.day,
                        getHour(cal.endTime), getMinutes(cal.endTime)),
                    //8h est l'heure de début de travail
                    bookingStart: DateTime(now.year, now.month, now.day,
                        getHour(cal.startTime), getMinutes(cal.startTime)));
                return Expanded(
                  child: BookingDoctorCalendar(
                    bookingService: mockBookingService,
                    convertStreamResultToDateTimeRanges:
                        convertStreamResultMock,
                    getBookingStream: getBookingStreamMock,
                    uploadBooking: uploadBookingMock,
                    pauseSlots:
                        generatePauseSlots(cal.debutPause, cal.finPause),
                    availableSlotText: 'Journée Chargée',
                    selectedSlotText: 'Pas de Créneaux',
                    bookedSlotText: 'Jours de congé',
                    pauseSlotText: 'DÉJEUNER',
                    hideBreakTime: true,
                    loadingWidget: const Text('Récupération des données...'),
                    uploadingWidget: const CircularProgressIndicator(),
                    locale: 'fr',
                    startingDayOfWeek: StartingDayOfWeek.monday,
                    wholeDayIsBookedWidget: const BookedWidget(
                        'Désolé, pour ce jour tout est réservé'),
                    disabledDates: freeDates,
                    busyDates: fetchDoctorsbusyDates,
                    bookedDates: fetchDoctorsBookedDates,
                    bookingButtonText: "Confirmer",
                    bookingButtonColor: AppColors.green,
                    disabledDays: getWeekendDays(cal.weekend),
                    pauseSlotColor: AppColors.white,
                    bookedSlotColor: AppColors.greySoligth,
                    availableSlotColor: AppColors.lightgrey,
                    selectedSlotColor: AppColors.pink,
                    availableSlotTextStyle: const TextStyle(
                      color: AppColors.white,
                    ),
                    selectedSlotTextStyle:
                        const TextStyle(color: AppColors.white),
                    bookedSlotTextStyle:
                        const TextStyle(color: AppColors.white),
                  ),
                );
              }
            }),
      ]),
    );
  }
}
