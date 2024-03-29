import 'package:flutter/material.dart';
import 'package:iltempo/providers/auth.dart';
import 'package:iltempo/utils/constants.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _loadingNotifier = ValueNotifier<bool>(false);

  void _showErrorMessage(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: kCardColor,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(kBorderRadius)),
        contentPadding: const EdgeInsets.only(
          top: 20,
          left: 20,
          right: 20,
          bottom: 0,
        ),
        titlePadding: const EdgeInsets.only(
          top: 20,
          bottom: 0,
          left: 20,
          right: 20,
        ),
        title: Text(
          "Error en la autenticación",
          style: TextStyle(color: Colors.red),
        ),
        content: Text(
          message,
          style: TextStyle(color: Colors.white),
        ),
        actions: <Widget>[
          FlatButton(
            child: Text(
              "Ok",
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () => Navigator.of(ctx).pop(),
          )
        ],
      ),
    ).then((_) {
      _passwordController.clear();
    });
  }

  Widget _buildInputText(
      TextEditingController controller, String hint, bool obscure) {
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.only(left: 15),
            width: MediaQuery.of(context).size.width * 0.35 - 30,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                hint,
                style: TextStyle(
                  color: kMainColor,
                  fontSize: 15,
                ),
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.65,
            child: TextField(
              style: TextStyle(color: Colors.white),
              obscureText: obscure,
              keyboardType: TextInputType.visiblePassword,
              cursorColor: kMainColor,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.only(left: 8, bottom: 3),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.transparent),
                ),
                border: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.transparent),
                ),
                hintText: "Ingrese su $hint",
                fillColor: Colors.transparent,
                alignLabelWithHint: true,
                hintStyle: TextStyle(
                  color: Colors.white70,
                  fontSize: 15,
                ),
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
      body: SingleChildScrollView(
        child: Container(
          height: size.height,
          width: size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(32.0),
                child: Image.asset("assets/img/logo_il_tempo_new.jpg"),
              ),
              _buildInputText(_usernameController, "Usuario", false),
              _buildInputText(_passwordController, "Contraseña", true),
              SizedBox(height: 35),
              ValueListenableBuilder<bool>(
                  valueListenable: _loadingNotifier,
                  builder: (context, loading, _) {
                    return TextButton(
                      style: ButtonStyle(
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              kBorderRadius,
                            ),
                          ),
                        ),
                        backgroundColor: MaterialStateProperty.all(kMainColor),
                        padding: MaterialStateProperty.all(
                          const EdgeInsets.symmetric(
                            horizontal: 38,
                            vertical: 12,
                          ),
                        ),
                      ),
                      onPressed: () async {
                        _loadingNotifier.value = true;
                        String result =
                            await Provider.of<Auth>(context, listen: false)
                                .logIn(_usernameController.text,
                                    _passwordController.text);
                        _loadingNotifier.value = false;
                        if (result.isEmpty) return;
                        var errorMessage =
                            "Lo sentimos hubo un problema, inténtelo de nuevo más tarde";
                        if (result.contains("INVALID_PASSWORD")) {
                          errorMessage = "Contraseña incorrecta";
                        } else if (result.contains("EMAIL_NOT_FOUND")) {
                          errorMessage = "Usuario no encontrado";
                        } else if (result.contains("INVALID_EMAIL")) {
                          errorMessage = "Usuario invalido";
                        }
                        _showErrorMessage(errorMessage);
                      },
                      child: Container(
                        width: 100,
                        height: 30,
                        alignment: Alignment.center,
                        child: loading
                            ? const SizedBox(
                                height: 30,
                                width: 30,
                                child: CircularProgressIndicator(),
                              )
                            : const Text(
                                'Ingresar',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    );
                  })
            ],
          ),
        ),
      ),
    );
  }
}
