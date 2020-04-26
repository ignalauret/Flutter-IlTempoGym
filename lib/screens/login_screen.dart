import 'package:flutter/material.dart';
import 'package:iltempo/providers/auth.dart';
import 'package:iltempo/screens/menu_dashboard_screen.dart';
import 'package:iltempo/utils/constants.dart';
import 'package:provider/provider.dart';
import '../models/http_exception.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  void _showErrorMessage(String message) {
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              title: Text("Error en la autenticación"),
              content: Text(message),
              actions: <Widget>[
                FlatButton(
                  child: Text("Ok"),
                  onPressed: () => Navigator.of(ctx).pop(),
                )
              ],
            ));
  }

  Widget _buildInputText(
      TextEditingController controller, String hint, TextInputType type) {
    return Container(
      height: 45,
      margin: const EdgeInsets.symmetric(
        vertical: 5,
        horizontal: 15,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: CARD_COLOR,
      ),
      child: Row(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.only(left: 15),
            width: MediaQuery.of(context).size.width * 0.35 - 30,
            child: Text(
              hint,
              style: TextStyle(
                color: MAIN_COLOR,
                fontSize: 15,
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.65,
            child: TextField(
              style: TextStyle(color: Colors.white),
              keyboardType: type,
              cursorColor: MAIN_COLOR,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.all(8),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.transparent),
                ),
                border: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.transparent),
                ),
                hintText: "Ingrese su $hint",
                fillColor: Colors.transparent,
                filled: true,
                hintStyle: TextStyle(color: Colors.white70),
              ),
              controller: controller,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        height: size.height,
        width: size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset("assets/img/logo_il_tempo.png"),
            _buildInputText(_usernameController, "Usuario", TextInputType.text),
            _buildInputText(_passwordController, "Contraseña",
                TextInputType.visiblePassword),
            SizedBox(
              height: 35,
            ),
            FlatButton(
              child: Text("Ingresar"),
              padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.25,
                  vertical: 10),
              onPressed: (_usernameController.text.isEmpty)
                  ? null
                  : () async {
                      String result = await Provider.of<Auth>(context, listen: false)
                          .logIn(_usernameController.text,
                              _passwordController.text);
                      if(result.isEmpty) return;
                      var errorMessage =
                          "Lo sentimos hubo un problema, intentelo denuevo mas tarde";
                      if (result.contains("INVALID_PASSWORD")) {
                        errorMessage = "Contraseña incorrecta";
                      } else if (result.contains("EMAIL_NOT_FOUND")) {
                        errorMessage = "Usuario no encontrado";
                      } else if (result.contains("INVALID_EMAIL")) {
                        errorMessage = "Usuario invalido";
                      }
                      _showErrorMessage(errorMessage);
                    },
              textColor: Colors.white,
              color: MAIN_COLOR,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              disabledColor: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
