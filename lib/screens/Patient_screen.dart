import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartcare_calender/models/RangeSliderModel.dart';
import 'package:smartcare_calender/widgets/booked_widget.dart';

import '../Calendar_package/model/booking_service.dart';
import '../Calendar_package/model/enums.dart';
import '../colors.dart';
import '../models/Calendar.dart';
import '../widgets/bottom_navigation_bar_widget.dart';

import 'dart:async';
//import 'package:booking_calendar/booking_calendar.dart';
import '../Calendar_package/core/booking_calendar.dart';
import '../db/MongoWithFastApi.dart';
import '../mongodb.dart';

class PatientScreen extends StatefulWidget {
  const PatientScreen({super.key});

  @override
  State<PatientScreen> createState() => _PatientScreenState();
}

class _PatientScreenState extends State<PatientScreen> {
  final now = DateTime.now();
  late Booking_Service mockBookingService;
  Map<String, dynamic> data = {};
  late List<DateTime> fetchDoctorsbusyDates = [];
  late List<Map<String, dynamic>> fetchDoctorAppointmentsDates = [];
  late List<DateTime> fetchDoctorsBookedDates = [];

  /*
  TimeOfDay _startMorningTime = TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endMorningTime = TimeOfDay(hour: 11, minute: 0);
  TimeOfDay _startAfternoonTime = TimeOfDay(hour: 15, minute: 0);
  TimeOfDay _endAfternoonTime = TimeOfDay(hour: 17, minute: 0);
  */

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
  void initState() {
    super.initState();
    //Future<Calendar> cal = MongoDatabase.getData();
    // DateTime.now().startOfDay
    // DateTime.now().endOfDay

    // Fetch data initially when the screen loads
    fetchData();
    getBusyDates();
    getBookedDates();
    getAppointmentsDates();
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
      });
      print(data);
    } catch (error) {
      // Handle any errors that occurred during data fetch
      print('Error: $error');
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

  Future<void> getAppointmentsDates() async {
    List<Map<String, dynamic>> listofappointmentsDates =
        await FastApi.getAllDoctorsAppointments();

    setState(() {
      fetchDoctorAppointmentsDates = listofappointmentsDates;
    });
  }

  List<DateTimeRange> converted = [];

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

    /* DateTime first = now;
    DateTime tomorrow = now.add(const Duration(days: 1));
    DateTime second = now.add(const Duration(minutes: 55));
    DateTime third = now.subtract(const Duration(minutes: 240));
    DateTime fourth = now.subtract(const Duration(minutes: 500));
    converted.add(
        DateTimeRange(start: first, end: now.add(const Duration(minutes: 30))));
    converted.add(DateTimeRange(
        start: second, end: second.add(const Duration(minutes: 23))));
    converted.add(DateTimeRange(
        start: third, end: third.add(const Duration(minutes: 15))));
    converted.add(DateTimeRange(
        start: fourth, end: fourth.add(const Duration(minutes: 50))));

    //book whole day example
    converted.add(DateTimeRange(
        start: DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 5, 0),
        end: DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 23, 0)));*/

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

  Future<void> getBusyDates() async {
    int maxNb = 0;
    maxNb = await FastApi.getNumberOfDailyAppointments();
    List<DateTime> listofbusyDates = await FastApi.getDoctorBusyDates(maxNb);

    setState(() {
      fetchDoctorsbusyDates = listofbusyDates;
    });
  }

  Future<void> getBookedDates() async {
    int maxNb = 0;
    maxNb = await FastApi.getNumberOfDailyAppointments();
    List<DateTime> listofbookedDates =
        await FastApi.getDoctorBookedDates(maxNb);

    setState(() {
      fetchDoctorsBookedDates = listofbookedDates;
    });
  }

  @override
  Widget build(BuildContext context) {
    final sliderModelNotifier = Provider.of<RangeSliderModelNotifier>(context);
    return Scaffold(
      bottomNavigationBar: const BottomNavigationBarWidget(),
      backgroundColor: AppColors.white,
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Color.fromARGB(255, 253, 4, 87),
            ),
            onPressed: () => Navigator.of(context).pop()),
        toolbarHeight: 40,
        backgroundColor: const Color(0xffffffff),
        title: const Text("Sélectionner Rendez-vous",
            style: TextStyle(
                fontSize: 20,
                color: AppColors.black,
                fontWeight: FontWeight.w700)),
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
        ],
      ),
      body: Column(children: [
        Stack(children: [
          Container(
            height: 100,
            margin: const EdgeInsets.only(right: 20, left: 20, top: 20),
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
                  child: RangeSlider(
                    inactiveColor: AppColors.softGrey,
                    activeColor: AppColors.pink,
                    min: _timeToDouble(const TimeOfDay(hour: 8, minute: 0)),
                    max: _timeToDouble(const TimeOfDay(hour: 12, minute: 0)),
                    divisions:
                        8, // One division for every 30 minutes (8 divisions in total)
                    labels: RangeLabels(
                      _timeToString(
                          sliderModelNotifier.sliderModel.startMorningTime),
                      _timeToString(
                          sliderModelNotifier.sliderModel.endMorningTime),
                    ),
                    values: RangeValues(
                      _timeToDouble(
                          sliderModelNotifier.sliderModel.startMorningTime),
                      _timeToDouble(
                          sliderModelNotifier.sliderModel.endMorningTime),
                    ),
                    onChanged: (values) {
                      setState(() {
                        sliderModelNotifier.sliderModel.startMorningTime =
                            _doubleToTime(values.start);
                        sliderModelNotifier.sliderModel.endMorningTime =
                            _doubleToTime(values.end);
                        sliderModelNotifier.notifyListeners();
                      });
                    },
                  ),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Text(
                            _timeToString(const TimeOfDay(hour: 8, minute: 0)),
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Text(
                            _timeToString(const TimeOfDay(hour: 12, minute: 0)),
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
                const Padding(padding: EdgeInsets.symmetric(vertical: 3)),
                Expanded(
                  child: RangeSlider(
                    inactiveColor: AppColors.softGrey,
                    activeColor: AppColors.pink,
                    min: _timeToDouble(const TimeOfDay(hour: 14, minute: 0)),
                    max: _timeToDouble(const TimeOfDay(hour: 17, minute: 0)),
                    divisions:
                        6, // One division for every 30 minutes (6 divisions in total)
                    labels: RangeLabels(
                      _timeToString(
                          sliderModelNotifier.sliderModel.startAfternoonTime),
                      _timeToString(
                          sliderModelNotifier.sliderModel.endAfternoonTime),
                    ),
                    values: RangeValues(
                      _timeToDouble(
                          sliderModelNotifier.sliderModel.startAfternoonTime),
                      _timeToDouble(
                          sliderModelNotifier.sliderModel.endAfternoonTime),
                    ),
                    onChanged: (values) {
                      setState(() {
                        sliderModelNotifier.sliderModel.startAfternoonTime =
                            _doubleToTime(values.start);
                        sliderModelNotifier.sliderModel.endAfternoonTime =
                            _doubleToTime(values.end);
                        sliderModelNotifier.notifyListeners();
                      });
                    },
                  ),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Text(
                          _timeToString(const TimeOfDay(hour: 14, minute: 0)),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Text(
                            _timeToString(const TimeOfDay(hour: 17, minute: 0)),
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
                const Padding(padding: EdgeInsets.symmetric(vertical: 8)),
              ],
            ),
          ),
          Positioned(
            left: 30,
            top: 6,
            child: Container(
              color: Colors.white,
              child: const Text(
                'Préférences horaires',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkgrey,
                ),
              ),
            ),
          ),
        ]),
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
                );
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
                  child: BookingCalendar(
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
                    disabledDates: [
                      DateTime(2023, 9, 7),
                      DateTime(2023, 9, 12)
                    ],
                    busyDates: fetchDoctorsbusyDates,
                    bookedDates:
                        fetchDoctorsBookedDates, //!!!!!!!! create the api that gets the bookedDates from the backend!!!
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
