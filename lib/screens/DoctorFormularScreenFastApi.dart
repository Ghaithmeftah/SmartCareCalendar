import 'package:awesome_calendar/awesome_calendar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smartcare_calender/colors.dart';
import '../db/MongoWithFastApi.dart';
import '../widgets/bottom_navigation_bar_widget.dart';
import './Calendar_screen.dart';
import 'package:day_picker/day_picker.dart';

import 'package:datetime_picker_formfield_new/datetime_picker_formfield.dart';

class DoctorFormularScreenFastAPI extends StatefulWidget {
  final List<DateTime>? oldFreeDates;
  const DoctorFormularScreenFastAPI(this.oldFreeDates, {Key? key})
      : super(key: key);

  @override
  State<DoctorFormularScreenFastAPI> createState() =>
      _DoctorFormularScreenFastAPIState();
}

class _DoctorFormularScreenFastAPIState
    extends State<DoctorFormularScreenFastAPI> {
  final format = DateFormat("HH:mm");
  List<DateTime?> selectedDate = [];
  List<DateTime>? oldFreeDates = [];

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
        backgroundColor: AppColors.white,
        leading: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
          Expanded(
            child: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: AppColors.pink,
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
              color: AppColors.black,
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
                  color: AppColors.darkgrey,
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
                        color: AppColors.white),
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
                          hintStyle: TextStyle(color: AppColors.darkgrey)),
                      autocorrect: true,
                    ),
                  ),
                  Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 40, vertical: 7),
                    height: 70,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: AppColors.white),
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
                              color: AppColors.white),
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
                                  hintStyle:
                                      TextStyle(color: AppColors.darkgrey)),
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
                              color: AppColors.white),
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
                                  hintStyle:
                                      TextStyle(color: AppColors.darkgrey)),
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
                            hintStyle: TextStyle(color: AppColors.darkgrey)),
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
                            colors: [AppColors.softGrey, AppColors.darkgrey],
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
                  const SizedBox(
                    height: 10,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FloatingActionButton(
                        backgroundColor: AppColors.lightgrey,
                        onPressed: () async {
                          List<DateTime?>? selectedDates =
                              await showDialog<List<DateTime>>(
                            context: context,
                            builder: (BuildContext context) {
                              return AwesomeCalendarDialog(
                                selectionMode: SelectionMode.multi,
                                canToggleRangeSelection: true,
                                selectedDates:
                                    oldFreeDates, // return the list of old free dates from the database
                              );
                            },
                          );

                          if (selectedDates != null) {
                            setState(() {
                              selectedDate = selectedDates;
                            });
                          }
                        },
                        tooltip: 'Choose date Range',
                        child: const Icon(
                          Icons.calendar_today_outlined,
                          color: AppColors.black,
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      if (selectedDate.isNotEmpty)
                        Column(
                          children: selectedDate.map((date) {
                            return Text(
                              DateFormat('MMM dd, yyyy').format(date!),
                              style: const TextStyle(
                                fontSize: 16,
                              ),
                            );
                          }).toList(),
                        )
                      else
                        const Text("pas de date sélectionnée"),
                    ],
                  ),
                ],
              ),
            )),
            const SizedBox(
              height: 20,
            ),
            Container(
              height: 70,
              width: 200,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: AppColors.green),
              child: MaterialButton(
                  child: const Text("Sauvegarder"),
                  onPressed: () {
                    if (_formkey.currentState != null &&
                        _formkey.currentState!.validate()) {
                      //prepare the selectedDate to be a list of Strings in order to pass it
                      List<String> freedates = selectedDate.map((dateTime) {
                        // Format the DateTime as a string in the desired format.
                        return DateFormat('yyyy-MM-dd').format(dateTime!);
                      }).toList();
                      //insert the calendar data in mongodb
                      FastApi.createOrUpdateCalendar(
                        heure_debut_Controller.text,
                        heure_fin_Controller.text,
                        debut_pause_controller.text,
                        fin_pause_controller.text,
                        duree_consultation_controller.text,
                        Weekend,
                        freedates,
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
