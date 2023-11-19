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
        "$endpoint/doctor/get_doctor_appointments?doctor_id=647e8660ae87a55a026142b7&date=$date"));
    if (response.statusCode == 200) {
      // Handle the successful response
      final decodedData = json.decode(response.body);

      final List<Map<String, dynamic>> appointments =
          List<Map<String, dynamic>>.from(decodedData);

      return appointments;
    } else {
      print('Request failed with status: ${response.statusCode}');
      return [];
    }
  }

  static Future<Map<String, dynamic>> getDoctorsPatientsNames() async {
    final response = await http
        //don't forget to change your ip address (ipconfig) in the endpoint !!!!!!!!!!!!!!!!!!!!!
        //dont forget to change the id of the doctor in a dynamic way
        .get(Uri.parse(
            '$endpoint/doctor/get_doctor_local_and_shared_patients_info?doctor_id=647e8660ae87a55a026142b7'));
    if (response.statusCode == 200) {
      // Handle the successful response
      final decodedData = json.decode(response.body);

      final Map<String, dynamic> patientsNames =
          Map<String, dynamic>.from(decodedData);

      print(patientsNames);
      return patientsNames;
    } else {
      print('Request failed with status: ${response.statusCode}');
      return {};
    }
  }

  static Future<void> updateAppointmentStatus(
      String appointmentId, String status) async {
    //don't forget to change the doctor_id IN THE URL !!!!!!!!!
    final response = await http.post(Uri.parse(
        "$endpoint/doctor/update_appointment_status?appointment_id=$appointmentId&requestStatusType=$status"));
    if (response.statusCode == 200) {
      // Handle the successful response
      final decodedData = json.decode(response.body);

      return decodedData;
    } else {
      print('Request failed with status: ${response.statusCode}');
    }
  }

  static Future<List<Map<String, dynamic>>> getAllDoctorsAppointments(
      {String? date}) async {
    const doctorId = "647e8660ae87a55a026142b7";
    const baseUrl =
        "$endpoint/doctor/get_doctor_appointments?doctor_id=$doctorId";

    // Conditionally add the date query parameter if date is not null
    final url = (date != null) ? "$baseUrl&date=$date" : baseUrl;

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      // Handle the successful response
      final decodedData = json.decode(response.body);
      final List<Map<String, dynamic>> appointments =
          List<Map<String, dynamic>>.from(decodedData);

      return appointments;
    } else {
      print('Request failed with status: ${response.statusCode}');
      return []; // You can return null or an empty list based on your error handling strategy
    }
  }

  static Future<List<Map<String, dynamic>>> getDoctorDailyAppointments(
      DateTime? date, String? requestStatusType) async {
    const doctorId = "647e8660ae87a55a026142b7";
    String formattedDate = DateFormat('yyyy-MM-dd').format(date!);
    const baseUrl =
        "$endpoint/doctor/get_doctor_patients_who_has_appointment?doctor_id=$doctorId";

    // Conditionally add the date query parameter if date is not null
    final url =
        "$baseUrl&date=$formattedDate&request_status_type=$requestStatusType";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      // Handle the successful response
      final decodedData = json.decode(response.body);
      final List<Map<String, dynamic>> appointments =
          List<Map<String, dynamic>>.from(decodedData);

      return appointments;
    } else {
      print('Request failed with status: ${response.statusCode}');
      return []; // You can return null or an empty list based on your error handling strategy
    }
  }

  static Future<List<DateTime>> getDoctorBusyDates(int maxNb) async {
    //don't forget to change the doctor_id IN THE URL !!!!!!!!!
    final response = await http.get(Uri.parse(
        "$endpoint/doctor/get_doctor_busy_dates?doctor_id=647e8660ae87a55a026142b7&max_nb=$maxNb"));
    if (response.statusCode == 200) {
      // Handle the successful response
      final decodedData = json.decode(response.body) as List<dynamic>;
      final List<DateTime> busyDates =
          decodedData.map((dateString) => DateTime.parse(dateString)).toList();

      return busyDates;
    } else {
      print('Request failed with status: ${response.statusCode}');
      return [];
    }
  }

  static Future<List<DateTime>> getDoctorBookedDates(int maxNb) async {
    //don't forget to change the doctor_id IN THE URL !!!!!!!!!
    final response = await http.get(Uri.parse(
        "$endpoint/doctor/get_doctor_booked_dates?doctor_id=647e8660ae87a55a026142b7&max_nb=$maxNb"));
    if (response.statusCode == 200) {
      // Handle the successful response
      final decodedData = json.decode(response.body) as List<dynamic>;
      final List<DateTime> bookedDates =
          decodedData.map((dateString) => DateTime.parse(dateString)).toList();

      return bookedDates;
    } else {
      print('Request failed with status: ${response.statusCode}');
      return [];
    }
  }

  static Future<int> getNumberOfDailyAppointments() async {
    final response = await http.get(Uri.parse(
        "$endpoint/doctor/get_doctor_max_number_of_appointments_per_day?doctor_id=647e8660ae87a55a026142b7"));
    if (response.statusCode == 200) {
      // Handle the successful response
      final decodedData = json.decode(response.body) as int;
      final int maxNb = decodedData.toInt();

      return maxNb;
    } else {
      print('Request failed with status: ${response.statusCode}');
      return 0;
    }
  }

  static Future<http.Response> takeAppointment(
    DateTime datetime,
    String? doctorId,
    String? patientId,
    String? motiv,
  ) async {
    String formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(datetime);
    final date = formattedDate.substring(0, 11).trim();
    final time = formattedDate.substring(11, 19).trim();

    var data = {
      "date": date,
      "time": time,
      "patient_id": patientId,
      "sender_id":
          doctorId, //don't forget to change the doctor_id here using the currrent!!!!!!!!!
      "doctor_id": doctorId,
      "motiv": motiv
    };
    final response =
        await http.post(Uri.parse("$endpoint/appointment/take_appointment"),
            headers: {
              'Content-Type': 'application/json',
              //'Authorization': 'Bearer $authToken',
            },
            body: json.encode(data));
    return response;
  }

  static Future<http.Response> takeAppointmentForNewPatient(
    DateTime datetime,
    String? doctorId,
    String? firstName,
    String? secondName,
    String? note,
  ) async {
    String formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(datetime);
    final date = formattedDate.substring(0, 11).trim();
    final time = formattedDate.substring(11, 19).trim();

    var newPatientdata = {
      "firstname": firstName,
      "secondname": secondName,
      "note": note,
    };
    final patientResponse = await http.post(
        Uri.parse("$endpoint/doctor/add-patient?referenced_patient=false"),
        headers: {
          'Content-Type': 'application/json',
          //'Authorization': 'Bearer $authToken',
        },
        body: json.encode(newPatientdata));

    // Check if the patient request was successful (status code 200)
    if (patientResponse.statusCode == 200) {
      // Parse the response body
      Map<String, dynamic> responseData = json.decode(patientResponse.body);

      // Now you can use the data as needed
      // For example, assuming the API returns a JSON object with a key '_id'
      var patientId = responseData['_id'];

      // Continue with the rest of the logic...

      var appointmentdata = {
        "date": date,
        "time": time,
        "patient_id":
            patientId, //here we passed the new patient Id Created by the doctor
        "sender_id": doctorId,
        "doctor_id": doctorId,
        "motiv": note
      };

      final response =
          await http.post(Uri.parse("$endpoint/appointment/take_appointment"),
              headers: {
                'Content-Type': 'application/json',
                //'Authorization': 'Bearer $authToken',
              },
              body: json.encode(appointmentdata));

      return response;
    } else {
      // If the patient request was not successful, handle the error
      print('Error: ${patientResponse.statusCode}');
      print('Response: ${patientResponse.body}');

      // Return an appropriate response or throw an exception based on your requirements
      return http.Response(
          'Patient request failed', patientResponse.statusCode);
    }
  }

  static Future<Map<String, dynamic>> fetchCalendar() async {
    final response = await http
        //don't forget to change your ip address (ipconfig) in the endpoint !!!!!!!!!!!!!!!!!!!!!
        //dont forget to change the id of the doctor in a dynamic way
        .get(Uri.parse(
            '$endpoint/doctor/get_doctor_calendar_by_id?doctor_id=647e8660ae87a55a026142b7'));
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
      String startWorkTime,
      String endWorkTime,
      String startPauseTime,
      String endPauseTime,
      String appointmentDuration,
      String weekendDays,
      List<String?> freeDates) async {
    // First, try to fetch the doctor's calendar using his ID.
    final existingCalendarResponse = await http.get(
      Uri.parse(
          "$endpoint/doctor/get_doctor_calendar_by_id?doctor_id=647e8660ae87a55a026142b7"),
    );

    if (existingCalendarResponse.statusCode == 200) {
      // Parse the JSON response into a Dart object
      final Map<String, dynamic> calendarData =
          json.decode(existingCalendarResponse.body);

      // Access the 'free_dates' attribute from the parsed object
      final List<String?> olderDates =
          List<String?>.from(calendarData['free_dates']);
      olderDates.addAll(freeDates);
      final List<String?> allFreeDates = olderDates;
      // The calendar already exists, so we need to update it.
      final response = await http.post(
        Uri.parse(
            '$endpoint/doctor/create_or_update_doctor_calendar?owner_id=647e8660ae87a55a026142b7'),
        body: json.encode({
          "start_work_time": startWorkTime,
          "end_work_time": endWorkTime,
          "start_pause_time": startPauseTime,
          "end_pause_time": endPauseTime,
          "appointment_duration": appointmentDuration,
          "weekend_days": weekendDays,
          "free_dates": allFreeDates,
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
