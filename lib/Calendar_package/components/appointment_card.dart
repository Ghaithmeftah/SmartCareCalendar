import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:smartcare_calender/db/MongoWithFastApi.dart';

import '../../colors.dart';
import 'common_button.dart';

class AppointmentCard extends StatefulWidget {
  const AppointmentCard({
    Key? key,
    required this.appointment,
    required this.showAcceptAndDeclineRequestButtons,
    required this.onAccept,
    required this.onCanceled,
    required this.onDeclined,
  }) : super(key: key);
  final Map<String, dynamic> appointment;
  final bool showAcceptAndDeclineRequestButtons;
  final VoidCallback onAccept;
  final VoidCallback onCanceled;
  final VoidCallback onDeclined;

  @override
  State<AppointmentCard> createState() => _AppointmentCardState();
}

class _AppointmentCardState extends State<AppointmentCard> {
  bool isExpanded = false;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              isExpanded = !isExpanded;
            });
          },
          child: ListTile(
            leading: const FaIcon(
              FontAwesomeIcons.solidCircleUser,
              size: 50,
            ),
            title: Text(
                "${widget.appointment["firstname"]} ${widget.appointment["lastname"]}"),
            subtitle: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                    "Age:  ${getAge(widget.appointment["birth_date"].toString())} ans"),
                const SizedBox(
                  width: 50,
                ),
                const FaIcon(
                  FontAwesomeIcons.userClock,
                  size: 20,
                ),
                Text(
                  widget.appointment["time"].toString().substring(0, 5),
                ),
              ],
            ),
            trailing: Icon(
              isExpanded
                  ? Icons.keyboard_arrow_down_sharp
                  : Icons.keyboard_arrow_up_sharp,
              size: 36.0,
              color: AppColors.green,
            ),
          ),
        ),
        if (isExpanded)
          Center(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: const FaIcon(
                        FontAwesomeIcons.solidUser,
                        size: 25,
                        color: AppColors.green,
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const FaIcon(
                        FontAwesomeIcons.phone,
                        size: 25,
                        color: AppColors.green,
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const FaIcon(
                        FontAwesomeIcons.solidMessage,
                        size: 25,
                        color: AppColors.green,
                      ),
                    ),
                    (widget.showAcceptAndDeclineRequestButtons)
                        ? IconButton(
                            onPressed: () {},
                            icon: const FaIcon(
                              FontAwesomeIcons.solidPenToSquare,
                              size: 25,
                              color: AppColors.green,
                            ),
                          )
                        : IconButton(
                            onPressed: () => widget.onCanceled(),
                            icon: const FaIcon(
                              FontAwesomeIcons.xmark,
                              size: 25,
                              color: AppColors.pink,
                            ),
                          ),
                  ],
                ),
                (widget.showAcceptAndDeclineRequestButtons)
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          CommonButton(
                            width: 150,
                            text: "Accepter",
                            onTap: () => widget.onAccept(),

                            // isDesabled: controller.selectedSlot == -1,
                            buttonActiveColor: AppColors.green,
                          ),
                          CommonButton(
                            width: 150,
                            text: "Rejeter",
                            onTap: () => widget.onDeclined(),
                            // isDesabled: controller.selectedSlot == -1,
                            buttonActiveColor: AppColors.pink,
                          ),
                        ],
                      )
                    : const SizedBox(),
              ],
            ),
          )
      ],
    );
  }

  int getAge(String birthDate) {
    final birthDateYear = int.parse(birthDate.substring(0, 4));
    final now = DateTime.now().year;
    return now - birthDateYear;
  }
}
