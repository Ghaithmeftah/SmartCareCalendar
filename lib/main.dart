import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../screens/Calendar_screen.dart';
import './mongodb.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MongoDatabase.connect();
  initializeDateFormatting()
      .then((_) => runApp(const BookingCalendarDemoApp()));
}

class BookingCalendarDemoApp extends StatelessWidget {
  const BookingCalendarDemoApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Calendrier de réservation',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: MyApp());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendrier de réservation'),
      ),
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 70,
            width: 200,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: Colors.lightBlueAccent),
            child: MaterialButton(
              child: Text("You're a Doctor"),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CalendarScreen(),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Container(
            height: 70,
            width: 200,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: Colors.lightBlueAccent),
            child: TextButton(
              child: Text("You're a Patient"),
              onPressed: null,
            ),
          ),
        ],
      )),
    );
  }
}
