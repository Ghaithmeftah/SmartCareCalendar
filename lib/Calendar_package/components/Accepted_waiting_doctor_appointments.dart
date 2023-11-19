import 'package:flutter/material.dart';

import '../../colors.dart';
import '../../db/MongoWithFastApi.dart';
import '../core/booking_controller.dart';
import 'appointment_card.dart';

enum Decision {
  accepted,
  pending,
}

extension DecisionToString on Decision {
  String toShortString() {
    return this.toString().split('.').last;
  }
}

class AcceptedAndWaitingDoctorAppointments extends StatefulWidget {
  final BookingController controller;
  final VoidCallback onChanged;
  const AcceptedAndWaitingDoctorAppointments({
    Key? key,
    required this.controller,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<AcceptedAndWaitingDoctorAppointments> createState() =>
      _AcceptedAndWaitingDoctorAppointmentsState();
}

class _AcceptedAndWaitingDoctorAppointmentsState
    extends State<AcceptedAndWaitingDoctorAppointments> {
  Set<int> expandedAppointments = Set<int>();
  bool isExpanded = false;
  Decision calendarView = Decision.accepted;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.0),
            child: SegmentedButton<Decision>(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                    (Set<MaterialState> states) {
                  if (states.contains(MaterialState.pressed)) {
                    return AppColors.white;
                  }
                  return AppColors.green;
                }),
                overlayColor: MaterialStateProperty.resolveWith<Color?>(
                  (Set<MaterialState> states) {
                    if (states.contains(MaterialState.pressed)) {
                      // Color for pressed state
                      return AppColors.pink; // Replace with your desired color
                    }
                    // Default color for other states
                    return AppColors.white; // Replace with your desired color
                  },
                ),
              ),
              segments: const <ButtonSegment<Decision>>[
                ButtonSegment<Decision>(
                    value: Decision.accepted,
                    label: Text('Confirmés'),
                    icon: Icon(Icons.calendar_view_day)),
                ButtonSegment<Decision>(
                    value: Decision.pending,
                    label: Text('En Attente'),
                    icon: Icon(Icons.calendar_view_week)),
              ],
              selected: <Decision>{calendarView},
              onSelectionChanged: (Set<Decision> newSelection) {
                setState(() {
                  calendarView = newSelection.first;
                });
              },
            ),
          ),
          SizedBox(
            height: 250,
            child: FutureBuilder<List<Map<String, dynamic>>>(
                future: FastApi.getDoctorDailyAppointments(
                  widget.controller.base,
                  calendarView.toShortString(),
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                        child: Text('No appointments available.'));
                  } else {
                    // Build the ListView using the fetched data
                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final appointment = snapshot.data![index];
                        return AppointmentCard(
                          key: UniqueKey(),
                          appointment: appointment,
                          showAcceptAndDeclineRequestButtons:
                              calendarView.toShortString() == "pending",
                          onAccept: () {
                            widget.onChanged();
                            setState(() {
                              // Handle Accept button press
                              FastApi.updateAppointmentStatus(
                                  appointment["appointment_id"], "accepted");
                            });
                          },
                          onCanceled: () {
                            setState(() {
                              FastApi.updateAppointmentStatus(
                                  appointment["appointment_id"], "pending");
                            });
                          },
                          onDeclined: () {
                            setState(() {
                              FastApi.updateAppointmentStatus(
                                  appointment["appointment_id"], "declined");
                            });
                          },
                        );
                      },
                    );
                  }
                }),
          ),
        ],
      ),
    );
  }

  int getAge(String birthDate) {
    final birthDateYear = int.parse(birthDate.substring(0, 4));
    final now = DateTime.now().year;
    return now - birthDateYear;
  }
}
