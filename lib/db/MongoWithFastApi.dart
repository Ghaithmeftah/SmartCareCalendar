import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

//don't forget to change your ip address (ipconfig)!!!!!!!!!!!!!!!!!!!!!
const endpoint = 'http://192.168.17.1:8080/api';

class FastApi {
  static Future<List<Map<String, dynamic>>> getDoctorAppointments(
      DateTime datetime) async {
    String formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(datetime);
    final date = formattedDate.substring(0, 11).trim();
    //don't forget to change the doctor_id IN THE URL !!!!!!!!!
    final response = await http.get(Uri.parse(
        "$endpoint/doctor/get_doctor_appointments?doctor_id=6532a2698b4180a0cb73cf24&date=$date"));
    if (response.statusCode == 200) {
      // Handle the successful response
      final decodedData = json.decode(response.body);

      final List<Map<String, dynamic>> appointments =
          List<Map<String, dynamic>>.from(decodedData);

      print(appointments);
      return appointments;
    } else {
      print('Request failed with status: ${response.statusCode}');
      return [];
    }
  }

  /*static Future<List<Map<String, dynamic>>> getAllDoctorsAppointments(
      {String? date}) async {
    //don't forget to change the doctor_id IN THE URL !!!!!!!!!
    final response = await http.get(Uri.parse(
        "$endpoint/doctor/get_doctor_appointments?doctor_id=6532a2698b4180a0cb73cf24&date=$date"));
    if (response.statusCode == 200) {
      // Handle the successful response
      final decodedData = json.decode(response.body);

      final List<Map<String, dynamic>> appointments =
          List<Map<String, dynamic>>.from(decodedData);

      print(appointments);
      return appointments;
    } else {
      print('Request failed with status: ${response.statusCode}');
      return [];
    }
  }*/
  static Future<List<Map<String, dynamic>>> getAllDoctorsAppointments(
      {String? date}) async {
    final doctorId = "6532a2698b4180a0cb73cf24";
    final baseUrl =
        "$endpoint/doctor/get_doctor_appointments?doctor_id=$doctorId";

    // Conditionally add the date query parameter if date is not null
    final url = (date != null) ? "$baseUrl&date=$date" : baseUrl;

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      // Handle the successful response
      final decodedData = json.decode(response.body);
      final List<Map<String, dynamic>> appointments =
          List<Map<String, dynamic>>.from(decodedData);
      print(appointments);
      return appointments;
    } else {
      print('Request failed with status: ${response.statusCode}');
      return []; // You can return null or an empty list based on your error handling strategy
    }
  }

  static Future<List<DateTime>> getDoctorBusyDates(int maxNb) async {
    //don't forget to change the doctor_id IN THE URL !!!!!!!!!
    final response = await http.get(Uri.parse(
        "$endpoint/doctor/get_doctor_busy_dates?doctor_id=6532a2698b4180a0cb73cf24&max_nb=$maxNb"));
    if (response.statusCode == 200) {
      // Handle the successful response
      final decodedData = json.decode(response.body) as List<dynamic>;
      final List<DateTime> busy_dates =
          decodedData.map((dateString) => DateTime.parse(dateString)).toList();

      return busy_dates;
    } else {
      print('Request failed with status: ${response.statusCode}');
      return [];
    }
  }

  static Future<List<DateTime>> getDoctorBookedDates(int maxNb) async {
    //don't forget to change the doctor_id IN THE URL !!!!!!!!!
    final response = await http.get(Uri.parse(
        "$endpoint/doctor/get_doctor_booked_dates?doctor_id=6532a2698b4180a0cb73cf24&max_nb=$maxNb"));
    if (response.statusCode == 200) {
      // Handle the successful response
      final decodedData = json.decode(response.body) as List<dynamic>;
      final List<DateTime> booked_dates =
          decodedData.map((dateString) => DateTime.parse(dateString)).toList();

      return booked_dates;
    } else {
      print('Request failed with status: ${response.statusCode}');
      return [];
    }
  }

  static Future<int> getNumberOfDailyAppointments() async {
    final response = await http.get(Uri.parse(
        "$endpoint/doctor/get_doctor_max_number_of_appointments_per_day?doctor_id=6532a2698b4180a0cb73cf24"));
    if (response.statusCode == 200) {
      // Handle the successful response
      final decodedData = json.decode(response.body) as int;
      final int max_nb = decodedData.toInt();
      print(max_nb);

      return max_nb;
    } else {
      print('Request failed with status: ${response.statusCode}');
      return 0;
    }
  }

  static Future<http.Response> takeAppointment(DateTime datetime, String motiv,
      {String? patientName}) async {
    String formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(datetime);
    final date = formattedDate.substring(0, 11).trim();
    final time = formattedDate.substring(11, 19).trim();
    //don't forget to change the doctor_id IN THE URL !!!!!!!!!
    final response = await http.post(
      Uri.parse(
          "$endpoint/appointment/take_appointment?date=$date&time=$time&doctor_id=6532a2698b4180a0cb73cf24&motiv=$motiv&patient_name=$patientName"),
      headers: {'Content-Type': 'application/json'},
    );
    return response;
  }

  static Future<Map<String, dynamic>> fetchCalendar() async {
    final response = await http
        //don't forget to change your ip address (ipconfig) in the endpoint !!!!!!!!!!!!!!!!!!!!!
        //dont forget to change the id of the doctor in a dynamic way
        .get(Uri.parse(
            '$endpoint/doctor/get_doctor_calendar_by_id?doctor_id=6532a2698b4180a0cb73cf24'));
    if (response.statusCode == 200) {
      // Handle the successful response
      final decodedData = json.decode(response.body);

      final Map<String, dynamic> calendar =
          Map<String, dynamic>.from(decodedData);

      print(calendar);
      return calendar;
    } else {
      print('Request failed with status: ${response.statusCode}');
      return {};
    }
  }

  static Future<http.Response> createOrUpdateCalendar(
      String start_work_time,
      String end_work_time,
      String start_pause_time,
      String end_pause_time,
      String appointment_duration,
      String weekend_days,
      List<String?> free_dates) async {
    // First, try to fetch the doctor's calendar using his ID.
    final existingCalendarResponse = await http.get(
      Uri.parse(
          "$endpoint/doctor/get_doctor_calendar_by_id?doctor_id=6532a2698b4180a0cb73cf24"),
    );

    if (existingCalendarResponse.statusCode == 200) {
      // Parse the JSON response into a Dart object
      final Map<String, dynamic> calendarData =
          json.decode(existingCalendarResponse.body);

      // Access the 'free_dates' attribute from the parsed object
      final List<String?> olderDates =
          List<String?>.from(calendarData['free_dates']);
      olderDates.addAll(free_dates);
      final List<String?> all_free_dates = olderDates;
      // The calendar already exists, so we need to update it.
      final response = await http.post(
        Uri.parse(
            '$endpoint/doctor/create_or_update_doctor_calendar?owner_id=6532a2698b4180a0cb73cf24'),
        body: json.encode({
          "start_work_time": start_work_time,
          "end_work_time": end_work_time,
          "start_pause_time": start_pause_time,
          "end_pause_time": end_pause_time,
          "appointment_duration": appointment_duration,
          "weekend_days": weekend_days,
          "free_dates": all_free_dates,
        }),
        headers: {'Content-Type': 'application/json'},
      );
      return response;
    } else {
      // Raise an exception indicating the issue with the request
      throw Exception(
          'Failed to fetch existing calendar: ${existingCalendarResponse.statusCode}');
    }
  }

  static Map<String, int> getHourAndMinutesFromMongo(String ch) {
    if (ch.length == 5) {
      String h = ch[0] + ch[1];
      String min = ch[3] + ch[4];
      return {"hour": int.parse(h), "minites": int.parse(min)};
    } else if (ch.length == 4) {
      String h = ch[0];
      String min = ch[2] + ch[3];
      return {"hour": int.parse(h), "minites": int.parse(min)};
    } else {
      return {};
    }
  }
}
