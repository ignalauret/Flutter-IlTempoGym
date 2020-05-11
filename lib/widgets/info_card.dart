import 'package:flutter/material.dart';
import 'package:iltempo/utils/constants.dart';

class InfoCard extends StatelessWidget {
  InfoCard(this.hint, this.value);
  final String hint;
  final String value;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.06,
      margin: const EdgeInsets.symmetric(
        vertical: 5,
        horizontal: 15,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(BORDER_RADIUS),
        color: CARD_COLOR,
      ),
      child: Row(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.only(left: 15),
            width: MediaQuery.of(context).size.width * 0.30 - 30,
            child: FittedBox(
              alignment: Alignment.centerLeft,
              fit: BoxFit.scaleDown,
              child: Text(
                hint,
                style: TextStyle(
                  color: MAIN_COLOR,
                  fontSize: 15,
                ),
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.7,
            padding: const EdgeInsets.only(left: 8, right: 8),
            child: FittedBox(
              alignment: Alignment.centerLeft,
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: TextStyle(
                  color: Colors.white,
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
