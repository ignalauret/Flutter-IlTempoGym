import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:iltempo/utils/constants.dart';

class SelectHourCard extends StatelessWidget {
  SelectHourCard(this.day, this.selected, this.onTap, this.size);
  final String day;
  final bool selected;
  final Function onTap;
  final Size size;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: selected ? MAIN_COLOR : Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(BORDER_RADIUS),
        side: BorderSide(
          color: MAIN_COLOR,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: () => onTap(day),
        splashColor: MAIN_COLOR,
        customBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(BORDER_RADIUS),
        ),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.01, vertical: size.height * 0.005),
          width: size.width * 0.15,
          height: size.height * 0.05,
          child: FittedBox(
            alignment: Alignment.center,
            fit: BoxFit.scaleDown,
            child: Text(
              day,
              style: TextStyle(color: selected ? Colors.black : MAIN_COLOR),
            ),
          ),
        ),
      ),
    );
  }
}
