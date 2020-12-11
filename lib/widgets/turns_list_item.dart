import 'package:flutter/material.dart';
import 'package:iltempo/models/turn.dart';
import 'package:iltempo/utils/constants.dart';

class TurnsListItem extends StatelessWidget {
  TurnsListItem(this.turn, this.color);
  final Turn turn;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45,
      margin: const EdgeInsets.symmetric(
        vertical: 5,
        horizontal: 15,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(kBorderRadius),
        color: kCardColor,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                turn.training,
                style: TextStyle(
                  color: color,
                  fontSize: 15,
                ),
              ),
            ),
          ),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                "${turn.date}",
                style: TextStyle(
                  color: color,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                turn.hour,
                style: TextStyle(
                  color: color,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
