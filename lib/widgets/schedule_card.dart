import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:iltempo/utils/constants.dart';

class ScheduleCard extends StatelessWidget {
  ScheduleCard({this.day, this.hours});

  final String day;
  final List<String> hours;

  List<Widget> _buildBody(BuildContext context) {
    List<Widget> body = [
      Text(
        day,
        style: TextStyle(
          color: MAIN_COLOR,
          fontWeight: FontWeight.bold,
        ),
      ),
    ];
    if(hours.isEmpty || hours.length < 2)
      body.add(SizedBox(height: MediaQuery.of(context).size.height * 0.020,));
    else body.add(SizedBox(height: MediaQuery.of(context).size.height * 0.012,));
    if (hours.isEmpty)
      body.add(
        Text(
          "-",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      );
    else
      body.addAll(
        hours
            .map((h) => Text(
                  h,
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ))
            .toList(),
      );
    return body;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Container(
      margin: EdgeInsets.all(width * 0.025),
      padding: const EdgeInsets.only(left: 5, right: 5, top: 5, bottom: 15),
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
