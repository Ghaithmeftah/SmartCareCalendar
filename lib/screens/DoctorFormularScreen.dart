import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/DayPicker.dart';
import './Calendar_screen.dart';

import 'package:datetime_picker_formfield_new/datetime_picker_formfield.dart';

import '../mongodb.dart';

class DoctorFormularScreen extends StatefulWidget {
  const DoctorFormularScreen({Key? key}) : super(key: key);

  @override
  State<DoctorFormularScreen> createState() => _DoctorFormularScreenState();
}

class _DoctorFormularScreenState extends State<DoctorFormularScreen> {
  final format = DateFormat("HH:mm");

  //create a key for the Form widget
  final _formkey = GlobalKey<FormState>();
  //create the texfield controller
  final heure_debut_Controller = TextEditingController();
  final heure_fin_Controller = TextEditingController();
  final duree_consultation_controller = TextEditingController();
  final date_weekend_controller = TextEditingController();
  final debut_pause_controller = TextEditingController();
  final fin_pause_controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    String? _requiredValidator(String? text) {
      if (text == null || text.trim().isEmpty) {
        return 'this field is required';
      }
      return null;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("mise à jour du calendrier"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Center(
                child: Form(
              key: _formkey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 40, vertical: 7),
                    height: 70,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: Colors.transparent),
                    child: DateTimeField(
                      format: format,
                      maxLength: 5,
                      onShowPicker: (context, currentValue) async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(
                              currentValue ?? DateTime.now()),
                        );
                        return DateTimeField.convert(time);
                      },
                      controller: heure_debut_Controller,
                      decoration: const InputDecoration(
                          hintText: "Heure de début travail (8:00am)",
                          hintStyle: TextStyle(color: Colors.blueGrey)),
                      autocorrect: true,
                    ),
                  ),
                  Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 40, vertical: 7),
                    height: 70,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: Colors.transparent),
                    child: Center(
                      child: DateTimeField(
                        format: format,
                        maxLength: 5,
                        onShowPicker: (context, currentValue) async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.fromDateTime(
                                currentValue ?? DateTime.now()),
                          );
                          return DateTimeField.convert(time);
                        },
                        controller: heure_fin_Controller,
                        decoration: const InputDecoration(
                            hintText: "Heure de fin travail (5:00pm)",
                            hintStyle: TextStyle(color: Colors.blueGrey)),
                        autocorrect: true,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 300,
                    height: 70,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 7),
                          height: 70,
                          width: 100,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              color: Colors.transparent),
                          child: Center(
                            child: DateTimeField(
                              format: format,
                              maxLength: 5,
                              onShowPicker: (context, currentValue) async {
                                final time = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.fromDateTime(
                                      currentValue ?? DateTime.now()),
                                );
                                return DateTimeField.convert(time);
                              },
                              controller: debut_pause_controller,
                              decoration: const InputDecoration(
                                  hintText: "De 12:00",
                                  hintStyle: TextStyle(color: Colors.blueGrey)),
                              autocorrect: true,
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 7),
                          height: 70,
                          width: 100,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              color: Colors.transparent),
                          child: Center(
                            child: DateTimeField(
                              format: format,
                              maxLength: 5,
                              onShowPicker: (context, currentValue) async {
                                final time = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.fromDateTime(
                                      currentValue ?? DateTime.now()),
                                );
                                return DateTimeField.convert(time);
                              },
                              controller: fin_pause_controller,
                              decoration: const InputDecoration(
                                  hintText: "vers 13:00",
                                  hintStyle: TextStyle(color: Colors.blueGrey)),
                              autocorrect: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 40, vertical: 7),
                    height: 70,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: Colors.transparent),
                    child: Center(
                      child: TextFormField(
                        validator: _requiredValidator,
                        controller: duree_consultation_controller,
                        keyboardType: TextInputType.number,
                        maxLength: 2,
                        decoration: const InputDecoration(
                            hintText: "Durée d'une Consultation (en min)",
                            hintStyle: TextStyle(color: Colors.blueGrey)),
                        autocorrect: true,
                        autofillHints: ["30min"],
                      ),
                    ),
                  ),
                  Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 40, vertical: 7),
                    height: 70,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: Colors.transparent),
                    child: const Center(child: DayPicker()),
                  ),
                ],
              ),
            )),
            const SizedBox(
              height: 5,
            ),
            Container(
              height: 70,
              width: 200,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: Colors.lightBlueAccent),
              child: MaterialButton(
                  child: Text("Sauvegarder"),
                  onPressed: () {
                    if (_formkey.currentState != null &&
                        _formkey.currentState!.validate()) {
                      //insert the calendar data in mongodb
                      MongoDatabase.UpdateCalendar(
                          heure_debut_Controller.text,
                          heure_fin_Controller.text,
                          debut_pause_controller.text,
                          fin_pause_controller.text,
                          duree_consultation_controller.text,
                          date_weekend_controller.text);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CalendarScreen(),
                        ),
                      );
                    }
                  }),
            ),
          ],
        ),
      ),
    );
  }
}
