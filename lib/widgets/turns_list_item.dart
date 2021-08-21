import 'package:flutter/material.dart';
import 'package:iltempo/models/turn.dart';
import 'package:iltempo/utils/constants.dart';

class TurnsListItem extends StatelessWidget {
  TurnsListItem(this.turn, this.color, this.deleteFunction);
  final Turn turn;
  final Color color;
  final Function deleteFunction;
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
          Container(
            height: 45,
            width: 45,
            margin: EdgeInsets.symmetric(horizontal: 2.5),
            child: IconButton(
              onPressed: deleteFunction,
              icon: Icon(Icons.delete, size: 25,),
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}
