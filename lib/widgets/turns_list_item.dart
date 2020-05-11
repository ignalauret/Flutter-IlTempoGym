import 'package:flutter/material.dart';
import 'package:iltempo/models/turn.dart';
import 'package:iltempo/utils/constants.dart';

class TurnsListItem extends StatelessWidget {
  TurnsListItem(this.turn, this.color);
  final Turn turn;
  final Color color;
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Container(
      height: 45,
      margin: const EdgeInsets.symmetric(
        vertical: 5,
        horizontal: 15,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(BORDER_RADIUS),
        color: CARD_COLOR,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(left: 15),
            alignment: Alignment.center,
            width: (width - 60) * 0.3,
            child: Text(
              turn.training,
              style: TextStyle(
                color: color,
                fontSize: 15,
              ),
            ),
          ),
          Container(
            width: (width - 60) * 0.3,
            alignment: Alignment.center,

            child: Text(
              "${turn.day} ${turn.date}",
              style: TextStyle(
                color: color,
                fontSize: 16,
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 15),
            alignment: Alignment.center,
            width: (width - 60) * 0.3,
            child: Text(
              turn.hour,
              style: TextStyle(
                color: color,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
