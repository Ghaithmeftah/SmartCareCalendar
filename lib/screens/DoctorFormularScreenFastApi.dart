import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../db/MongoWithFastApi.dart';
import '../widgets/bottom_navigation_bar_widget.dart';
import '../widgets/date_picker.dart';
import './Calendar_screen.dart';
import 'package:day_picker/day_picker.dart';

import 'package:datetime_picker_formfield_new/datetime_picker_formfield.dart';

class DoctorFormularScreenFastAPI extends StatefulWidget {
  const DoctorFormularScreenFastAPI({Key? key}) : super(key: key);

  @override
  State<DoctorFormularScreenFastAPI> createState() =>
      _DoctorFormularScreenFastAPIState();
}

class _DoctorFormularScreenFastAPIState
    extends State<DoctorFormularScreenFastAPI> {
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
  String Weekend = "dimanche";
  DateTime? startDate;
  DateTime? endDate;

  @override
  Widget build(BuildContext context) {
    List<DayInWeek> _days = [
      DayInWeek(
        "lun",
        dayKey: 'lundi',
      ),
      DayInWeek(
        "mar",
        dayKey: 'mardi',
      ),
      DayInWeek("mer", dayKey: 'mercredi'),
      DayInWeek(
        "jeu",
        dayKey: 'jeudi',
      ),
      DayInWeek(
        "ven",
        dayKey: 'vendredi',
      ),
      DayInWeek(
        "sam",
        dayKey: 'samedi',
      ),
      DayInWeek("dim", dayKey: 'dimanche', isSelected: true),
    ];
    String? _requiredValidator(String? text) {
      if (text == null || text.trim().isEmpty) {
        return 'this field is required';
      }
      return null;
    }

    return Scaffold(
      bottomNavigationBar: const BottomNavigationBarWidget(),
      appBar: AppBar(
        toolbarHeight: 40,
        backgroundColor: const Color(0xffffffff),
        leading: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
          Expanded(
            child: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: Colors.pinkAccent,
                ),
                onPressed: () => Navigator.of(context).pop()),
          ),
          const Expanded(
            child: Image(
              image: AssetImage("lib/assets/logo-symbol.png"),
              color: null,
            ),
          ),
        ]),
        title: const Padding(
          padding: EdgeInsets.only(left: 15.0),
          child: Text(
            "mise à jour du calendrier",
            style: TextStyle(
              color: Color(0xff1b1b1b),
            ),
          ),
        ),
        actions: [
          Ink(
            child: InkWell(
              onTap: () {},
              child: const Padding(
                padding: EdgeInsets.only(right: 8.0),
                child: Icon(
                  Icons.account_circle_sharp,
                  color: Color(0xff686868),
                  size: 30,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
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
                  const Text("Pause Déjeuner :"),
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
                        autofillHints: const ["30min"],
                      ),
                    ),
                  ),
                  const Text("Votre Week-end :"),
                  Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 40, vertical: 7),
                    height: 70,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: Colors.transparent),
                    child: Center(
                      child: SelectWeekDays(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        days: _days,
                        border: false,
                        boxDecoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30.0),
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            colors: [Color(0xFF4d6466), Color(0xFFadf3d1)],
                            tileMode: TileMode
                                .repeated, // repeats the gradient over the canvas
                          ),
                        ),
                        onSelect: (values) {
                          Weekend = "";
                          for (String s in values) {
                            Weekend += "$s,";
                          }

                          // <== Callback to handle the selected days (values is a list of strings)
                          print(values);
                          print("ch =$Weekend");
                        },
                      ),
                    ),
                  ),
                  const Text("Les jours du congé :"),
                  FloatingActionButton(
                    backgroundColor: const Color(0xFF789e9e),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                          scrollable: true,
                          title: const Text("Congé :"),
                          content: DatePicker(),
                          actions: [
                            TextButton(
                              child: const Text("ok"),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        ),
                      );

                      /*showCustomDateRangePicker(
                        context,
                        dismissible: true,
                        minimumDate:
                            DateTime.now().subtract(const Duration(days: 30)),
                        maximumDate:
                            DateTime.now().add(const Duration(days: 30)),
                        endDate: endDate,
                        startDate: startDate,

                        backgroundColor: Colors.white,
                        primaryColor: Colors.green,
                        onApplyClick: (start, end) {
                          setState(() {
                            endDate = end;
                            startDate = start;
                            print("startDate= $startDate , endDate= $endDate");
                          });
                        },
                        onCancelClick: () {
                          setState(() {
                            endDate = null;
                            startDate = null;
                          });
                        },
                      );*/
                    },
                    tooltip: 'choose date Range',
                    child: const Icon(Icons.calendar_today_outlined,
                        color: Color(0xFF1b1b1b)),
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
                  color: const Color(0xFFadf3d1)),
              child: MaterialButton(
                  child: const Text("Sauvegarder"),
                  onPressed: () {
                    if (_formkey.currentState != null &&
                        _formkey.currentState!.validate()) {
                      //insert the calendar data in mongodb
                      FastApi.createOrUpdateCalendar(
                        heure_debut_Controller.text,
                        heure_fin_Controller.text,
                        debut_pause_controller.text,
                        fin_pause_controller.text,
                        duree_consultation_controller.text,
                        Weekend,
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CalendarScreen(),
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
