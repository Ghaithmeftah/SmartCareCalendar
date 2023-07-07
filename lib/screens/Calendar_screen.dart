import 'dart:async';

import 'package:flutter/material.dart';
import 'package:booking_calendar/booking_calendar.dart';
import 'package:smartcare_calender/models/Calendar.dart';
import '../mongodb.dart';

import './DoctorFormularScreen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final now = DateTime.now();
  late BookingService mockBookingService;
  List<Map<String, dynamic>> data = [];
  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    fetchData();
  }

  @override
  void initState() {
    super.initState();
    //Future<Calendar> cal = MongoDatabase.getData();
    // DateTime.now().startOfDay
    // DateTime.now().endOfDay

    // Fetch data initially when the screen loads
    fetchData();
    // Schedule periodic data refresh every 1 minute
    //Timer.periodic(Duration(minutes: 1), (_) => fetchData());
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
      List<Map<String, dynamic>> newData = await MongoDatabase.getDocument();
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
      {required BookingService newBooking}) async {
    await Future.delayed(const Duration(seconds: 1));
    converted.add(DateTimeRange(
        start: newBooking.bookingStart, end: newBooking.bookingEnd));
    print('${newBooking.toJson()} has been uploaded');
  }

  List<DateTimeRange> converted = [];

  List<DateTimeRange> convertStreamResultMock({required dynamic streamResult}) {
    ///here you can parse the streamresult and convert to [List<DateTimeRange>]
    ///take care this is only mock, so if you add today as disabledDays it will still be visible on the first load
    ///disabledDays will properly work with real data
    DateTime first = now;
    DateTime tomorrow = now.add(Duration(days: 1));
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
        end: DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 23, 0)));
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
    ;
    return l;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendrier de réservation'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.settings,
              color: Colors.white,
            ),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DoctorFormularScreen(),
              ),
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
          future: MongoDatabase.getDocument(),
          builder:
              (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // While waiting for data to load
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              // If an error occurred while fetching the data
              return Text('Error: ${snapshot.error}');
            } else {
              Calendar cal = Calendar(
                snapshot.data![0]['id'],
                snapshot.data![0]['startTime'],
                snapshot.data![0]['endTime'],
                snapshot.data![0]['debut_pause'],
                snapshot.data![0]['fin_pause'],
                snapshot.data![0]['duration'],
                snapshot.data![0]['weekend'],
              );
              mockBookingService = BookingService(
                  serviceName: 'Mock Service',
                  //La durée du consultaion !!!!! exemple (30 min) ( this line get it's value from MongoDb )
                  serviceDuration: int.parse(cal.duration),
                  //18h est le temps dont le médecin vas retourner à la maison
                  bookingEnd: DateTime(now.year, now.month, now.day,
                      getHour(cal.endTime), getMinutes(cal.endTime)),
                  //8h est l'heure de début de travail
                  bookingStart: DateTime(now.year, now.month, now.day,
                      getHour(cal.startTime), getMinutes(cal.startTime)));
              return Center(
                child: BookingCalendar(
                  bookingService: mockBookingService,
                  convertStreamResultToDateTimeRanges: convertStreamResultMock,
                  getBookingStream: getBookingStreamMock,
                  uploadBooking: uploadBookingMock,
                  pauseSlots: generatePauseSlots(cal.debutPause, cal.finPause),
                  availableSlotText: 'Disponible',
                  selectedSlotText: 'sélectionnée',
                  bookedSlotText: 'réservée',
                  pauseSlotText: 'DÉJEUNER',
                  hideBreakTime: false,
                  loadingWidget: const Text('Récupération des données...'),
                  uploadingWidget: const CircularProgressIndicator(),
                  locale: 'fr',
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  wholeDayIsBookedWidget:
                      const Text('Désolé, pour ce jour tout est réservé'),
                  //disabledDates: [DateTime(2023, 1, 20)],
                  disabledDays: getWeekendDays(cal.weekend),
                ),
              );
            }
          }),
    );
  }
}
