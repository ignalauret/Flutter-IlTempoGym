import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:iltempo/utils/constants.dart';

class ScheduleCard extends StatelessWidget {
  ScheduleCard({this.day, this.hours, this.size});

  final String day;
  final List<String> hours;
  final Size size;

  List<Widget> _buildBody(BuildContext context) {
    List<Widget> hoursWidgets = [];
    List<Widget> body = [
      Text(
        day,
        style: TextStyle(
          color: MAIN_COLOR,
          fontWeight: FontWeight.bold,
        ),
      ),
    ];
    if (hours.isEmpty)
      hoursWidgets.add(
        FittedBox(
          alignment: Alignment.center,
          fit: BoxFit.scaleDown,
          child: Text(
            "-",
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      );
    else
      hoursWidgets.addAll(
        hours
            .map((h) => Text(
                  h,
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ))
            .toList(),
      );

    body.add(
      Expanded(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            children: hoursWidgets,
            mainAxisAlignment: MainAxisAlignment.center,
          ),
        ),
      ),
    );
    return body;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Container(
      margin: EdgeInsets.all(width * 0.025),
      padding: EdgeInsets.only(
          left: size.height * 0.006,
          right: size.height * 0.006,
          top: size.height * 0.006,
          bottom: size.height * 0.015),
      width: width * 0.15,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.transparent,
        border: Border.all(
          color: MAIN_COLOR,
          width: 2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: _buildBody(context),
      ),
    );
  }
}
