import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:iltempo/utils/constants.dart';

class SelectDayCard extends StatelessWidget {
  SelectDayCard(this.day, this.selected, this.onTap);
  final String day;
  final bool selected;
  final Function onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: selected ? MAIN_COLOR : Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: MAIN_COLOR,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: () => onTap(day),
        splashColor: MAIN_COLOR,
        customBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Text(
            day,
            style: TextStyle(color: selected ? Colors.black : MAIN_COLOR),
          ),
        ),
      ),
    );
  }
}
