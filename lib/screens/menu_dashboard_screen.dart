import 'package:flutter/material.dart';
import 'package:iltempo/screens/home_page.dart';

class MenuDashboardPage extends StatefulWidget {
  static const routeName = "/dashboard";

  @override
  _MenuDashboardPageState createState() => _MenuDashboardPageState();
}

class _MenuDashboardPageState extends State<MenuDashboardPage>
    with SingleTickerProviderStateMixin {
  bool isCollapsed = true;
  double screenWidth, screenHeight;
  final Duration duration = const Duration(milliseconds: 300);
  AnimationController _controller;
  Animation<double> _scaleAnimation;
  Animation<double> _menuScaleAnimation;
  Animation<Offset> _slideAnimation;
  int _selectedScreenIndex = 0;

  List<Widget> _screens;

  Widget buildMenuButton() {
    return InkWell(
      child: Icon(Icons.menu, color: Colors.white),
      onTap: () {
        setState(() {
          if (isCollapsed)
            _controller.forward();
          else
            _controller.reverse();

          isCollapsed = !isCollapsed;
        });
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _screens = [HomePage(buildMenuButton)];
    _controller = AnimationController(vsync: this, duration: duration);
    _scaleAnimation = Tween<double>(begin: 1, end: 0.8).animate(_controller);
    _menuScaleAnimation =
        Tween<double>(begin: 0.5, end: 1).animate(_controller);
    _slideAnimation = Tween<Offset>(begin: Offset(-1, 0), end: Offset(0, 0))
        .animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    screenHeight = size.height;
    screenWidth = size.width;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: <Widget>[
          menu(context),
          dashboard(context),
        ],
      ),
    );
  }

  Widget menu(context) {
    return SlideTransition(
      position: _slideAnimation,
      child: ScaleTransition(
        scale: _menuScaleAnimation,
        child: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Align(
            alignment: Alignment.topLeft,
            child: Container(
              width: MediaQuery.of(context).size.width / 2,
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Image(
                      image: AssetImage("assets/img/logo_il_tempo.png"),
                      height: 300,
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedScreenIndex = 0;
                          _controller.reverse();
                          isCollapsed = true;
                        });
                      },
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: Text("Nuestras clases",
                            style:
                                TextStyle(color: Colors.white, fontSize: 22)),
                      ),
                    ),
                    SizedBox(height: 10),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedScreenIndex = 1;
                          _controller.reverse();
                          isCollapsed = true;
                        });
                      },
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: Text("Mi perfil",
                            style:
                                TextStyle(color: Colors.white, fontSize: 22)),
                      ),
                    ),
                    SizedBox(height: 10),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedScreenIndex = 2;
                          _controller.reverse();
                          isCollapsed = true;
                        });
                      },
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: Text("Mis turnos",
                            style:
                                TextStyle(color: Colors.white, fontSize: 22)),
                      ),
                    ),
                    SizedBox(height: 10),
                  ]),
            ),
          ),
        ),
      ),
    );
  }

  Widget dashboard(context) {
    return AnimatedPositioned(
      duration: duration,
      top: 0,
      bottom: 0,
      left: isCollapsed ? 0 : 0.50 * screenWidth,
      right: isCollapsed ? 0 : -0.5 * screenWidth,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: GestureDetector(
          onTap: () => setState(() {
            _controller.reverse();
            isCollapsed = true;
          }),
          child: Material(
            animationDuration: duration,
            borderRadius: BorderRadius.all(Radius.circular(40)),
            elevation: 12,
            color: Colors.black,
            child: _screens[_selectedScreenIndex],
          ),
        ),
      ),
    );
  }
}
