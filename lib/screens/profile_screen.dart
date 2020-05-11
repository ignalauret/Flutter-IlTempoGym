import 'package:flutter/material.dart';
import 'package:iltempo/utils/constants.dart';
import 'package:iltempo/widgets/info_card.dart';
import 'package:iltempo/widgets/turns_list.dart';
import 'package:provider/provider.dart';
import '../providers/auth.dart';

class ProfileScreen extends StatelessWidget {
  static const routeName = "/profile";
  @override
  Widget build(BuildContext context) {
    final authData = Provider.of<Auth>(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        child: Column(
          children: <Widget>[
            Stack(
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.all(10),
                  height: MediaQuery.of(context).size.height * 0.3,
                  width: double.infinity,
                  child: Icon(
                    Icons.account_circle,
                    size: 150,
                    color: Colors.white70,
                  ),
                ),
                Positioned(
                  child: Text(
                    "Mi Perfil",
                    style: TextStyle(
                      fontSize: 35,
                      color: Colors.white,
                    ),
                  ),
                  bottom: 15,
                  right: 20,
                ),
                Positioned(
                  top: 30,
                  left: 5,
                  child: FlatButton(
                    padding: const EdgeInsets.only(left: 0, right: 10),
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.chevron_left,
                          size: 25,
                          color: MAIN_COLOR,
                        ),
                        Text(
                          "Volver",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 15),
                        ),
                      ],
                    ),
                    color: Colors.white70,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(BORDER_RADIUS),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                Positioned(
                  top: 30,
                  right: 5,
                  child: IconButton(
                    tooltip: "Salir",
                    icon: Icon(
                      Icons.exit_to_app,
                      color: Colors.white,
                      size: 30,
                    ),
                    padding: const EdgeInsets.all(8),
                    onPressed: () {
                      authData.logOut();
                      Navigator.of(context).pop();
                      Navigator.of(context).pushReplacementNamed("/");
                    },
                  ),
                ),
              ],
            ),
            InfoCard("Nombre", authData.userName),
            InfoCard("Dni", authData.userDni),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.only(
                    left: 20,
                    top: 15,
                    bottom: 10,
                  ),
                  child: Text(
                    "Mis turnos",
                    textAlign: TextAlign.center,
                    style: TITLE_STYLE,
                  ),
                ),
              ],
            ),
            Expanded(
              child: TurnsList(authData.userDni),
            ),
          ],
        ),
      ),
    );
  }
}
