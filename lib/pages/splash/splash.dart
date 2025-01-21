import 'dart:async';

import 'package:kontrolle_keyreg/globals.dart' as globals;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kontrolle_keyreg/pages/home/screens/home_screen.dart';
import 'package:kontrolle_keyreg/pages/login/screens/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../home/localization/app_localizations.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    // init();
    super.initState();
    startTimer();
  }

  init() async {
    WidgetsFlutterBinding.ensureInitialized();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
        body: Container(
      alignment: Alignment.center,
      width: size.width,
      height: size.height,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(children: [
          const Expanded(flex: 2, child: Center()),
          logo(size.height / 2, size.height / 2),
          const Expanded(flex: 2, child: Center()),
          Expanded(flex: 1, child: buildFooter(size)),
        ]),
      ),
    ));
  }

  Widget logo(double height_, double width_) {
    return Image.asset(
      'assets/logo_transparent.png',
      height: height_,
      width: width_,
    );
  }

  Widget buildFooter(Size size) {
    return Center(
      child: Text.rich(
        TextSpan(
          style: GoogleFonts.inter(
            fontSize: 12.0,
            color: Colors.black,
          ),
          children: [
            TextSpan(
              text: AppLocalizations.of(context).translate('product_from'),
              style: TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
            TextSpan(
              text: 'arfidex GmbH.',
              style: TextStyle(
                color: Color(0xFFFF7248),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  void startTimer() {
    Timer(Duration(seconds: 2), () {
      navigateUser(); //It will redirect  after 2 seconds
    });
  }

  void navigateUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var status = prefs.getBool('isLoggedIn') ?? false;
    if (status) {
      globals.api_key = prefs.getString('apiKey') ?? "";
      globals.username = prefs.getString('userName') ?? "";

      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => Home(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return child;
          },
          transitionDuration: Duration(seconds: 0),
        ),
      );
    } else {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              LoginScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return child;
          },
          transitionDuration: Duration(seconds: 0),
        ),
      );
    }
  }
}
