import 'package:kontrolle_keyreg/localization/app_localizations.dart';
import 'package:kontrolle_keyreg/pages/home/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:kontrolle_keyreg/globals.dart' as globals;
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late TextEditingController emailController;
  late TextEditingController passwordController;

  var rememberMe = false;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    passwordController = TextEditingController();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        width: size.width,
        height: size.height,
        decoration: const BoxDecoration(
            gradient: LinearGradient(
          colors: [
            Color(0xffE8761E),
            Colors.white,
            Colors.white,
            Colors.white,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        )),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const Expanded(flex: 1, child: Center()),

              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    richText(24),
                    const SizedBox(
                      height: 15,
                    ),
                  ],
                ),
              ),

              Expanded(
                flex: 5,
                child: Column(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "${AppLocalizations.of(context).translate('email')} / ${AppLocalizations.of(context).translate('user')}",
                          style: GoogleFonts.inter(
                            fontSize: 14.0,
                            color: Colors.black,
                            height: 1.0,
                          ),
                        ),
                        const SizedBox(
                          height: 6,
                        ),
                        emailTextField(size)
                      ],
                    ),

                    const SizedBox(
                      height: 6,
                    ),

                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          AppLocalizations.of(context).translate('password'),
                          style: GoogleFonts.inter(
                            fontSize: 14.0,
                            color: Colors.black,
                            height: 1.0,
                          ),
                        ),
                        const SizedBox(
                          height: 6,
                        ),
                        passwordTextField(size),
                      ],
                    ),

                    const SizedBox(
                      height: 6,
                    ),

                    //keep signed in and forget password section

                    rememberMe ? buildRemember() : keepSignedSection(),
                  ],
                ),
              ),

              Expanded(flex: 1, child: signInButton(size)),
              const SizedBox(
                height: 26,
              ),
              // const Expanded(flex: 1, child: Center()),
            ],
          ),
        ),
      ),
    );
  }

  Widget logo(double height_, double width_) {
    return Image.asset(
      'assets/logo_white_transparent.png',
      height: height_,
      width: width_,
    );
  }

  Widget richText(double fontSize) {
    return Text.rich(
      TextSpan(
        style: GoogleFonts.inter(
          fontSize: 24.0,
          color: const Color(0xFFFE9879),
          letterSpacing: 2.000000061035156,
        ),
        children: [
          TextSpan(
            text: AppLocalizations.of(context).translate('key_title'),
            style: TextStyle(
              color: Color.fromARGB(255, 255, 255, 255),
              fontWeight: FontWeight.w800,
            ),
          ),
          TextSpan(
            text: AppLocalizations.of(context).translate('reg_title'),
            style: TextStyle(
              color: Color.fromARGB(255, 110, 66, 52),
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget emailTextField(Size size) {
    return SizedBox(
      height: size.height / 13,
      child: TextField(
        controller: emailController,
        style: GoogleFonts.inter(
          fontSize: 18.0,
          color: const Color(0xFF151624),
        ),
        maxLines: 1,
        keyboardType: TextInputType.emailAddress,
        cursorColor: const Color(0xFF151624),
        decoration: InputDecoration(
          hintText: AppLocalizations.of(context).translate('enter_name'),
          hintStyle: GoogleFonts.inter(
            fontSize: 14.0,
            color: const Color(0xFFABB3BB),
            height: 1.0,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(width: 3, color: Color(0xffFE9879)),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          prefixIcon: Icon(
            Icons.mail_outline_rounded,
            color: emailController.text.isEmpty
                ? const Color(0xFF151624).withOpacity(0.5)
                : const Color(0xffE8761E),
            size: 16,
          ),
        ),
      ),
    );
  }

  Widget passwordTextField(Size size) {
    return SizedBox(
      height: size.height / 13,
      child: TextField(
        controller: passwordController,
        obscureText: true,
        style: GoogleFonts.inter(
          fontSize: 18.0,
          color: const Color(0xFF151624),
        ),
        maxLines: 1,
        cursorColor: const Color(0xFF151624),
        decoration: InputDecoration(
          hintText: AppLocalizations.of(context).translate('enter_password'),
          hintStyle: GoogleFonts.inter(
            fontSize: 14.0,
            color: const Color(0xFFABB3BB),
            height: 1.0,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(width: 3, color: Color(0xffFE9879)),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          prefixIcon: Icon(
            Icons.lock_outline_rounded,
            color: passwordController.text.isEmpty
                ? const Color(0xFF151624).withOpacity(0.5)
                : const Color(0xffE8761E),
            size: 16,
          ),
        ),
      ),
    );
  }

  Widget keepSignedSection() {
    return GestureDetector(
      onTap: () {
        rememberMe = true;
        setState(() {});
      },
      child: Row(
        children: <Widget>[
          Container(
            width: 24.0,
            height: 24.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4.0),
              border: Border.all(
                width: 0.7,
                color: const Color(0xFFD0D0D0),
              ),
            ),
          ),
          const SizedBox(
            width: 8,
          ),
          Text(
            AppLocalizations.of(context).translate('remember_me'),
            style: GoogleFonts.inter(
              fontSize: 12.0,
              color: const Color(0xFFABB3BB),
              height: 1.17,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildRemember() {
    return GestureDetector(
      onTap: () {
        rememberMe = false;
        setState(() {});
      },
      child: Row(
        children: <Widget>[
          Container(
            alignment: Alignment.center,
            width: 24.0,
            height: 24.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4.0),
              gradient: const LinearGradient(
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
                colors: [Color(0xffE8761E), Color(0xffFE9879)],
              ),
            ),
            child: SvgPicture.string(
              // Vector 5
              '<svg viewBox="47.0 470.0 7.0 4.0" ><path transform="translate(47.0, 470.0)" d="M 0 1.5 L 2.692307710647583 4 L 7 0" fill="none" stroke="#ffffff" stroke-width="1" stroke-linecap="round" stroke-linejoin="round" /></svg>',
              width: 13.0,
              height: 10.0,
            ),
          ),
          const SizedBox(
            width: 8,
          ),
          Text(
            AppLocalizations.of(context).translate('remember_me'),
            style: GoogleFonts.inter(
              fontSize: 12.0,
              color: const Color(0xFFABB3BB),
              height: 1.17,
            ),
          ),
        ],
      ),
    );
  }

  Widget signInButton(Size size) {
    return Material(
      // Verwenden Sie Material Widget um den Ripple-Effekt zu aktivieren
      borderRadius: BorderRadius.circular(15.0),
      color: const Color(0xffE8761E),
      child: InkWell(
        onTap: () async {
          // Werte aus den Controllern abrufen
          String email = emailController.text;
          String password = passwordController.text;
          if (email != "" && password != "") {
            // _authenticate-Methode aufrufen und Werte übergeben
            _authenticate(email, password);
          } else {
            showError(
                AppLocalizations.of(context).translate('wrong_credentials'));
          }
        },
        borderRadius: BorderRadius.circular(15.0),
        child: Container(
          alignment: Alignment.center,
          height: size.height / 13,
          child: Text(
            AppLocalizations.of(context).translate('log_in'),
            style: GoogleFonts.inter(
              fontSize: 14.0,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget buildContinueText() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        const Expanded(
            child: Divider(
          color: Colors.white,
        )),
        Expanded(
          child: Text(
            'Or Continue with',
            style: GoogleFonts.inter(
              fontSize: 12.0,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const Expanded(
            child: Divider(
          color: Colors.white,
        )),
      ],
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

  showError(String message) {
    Vibration.vibrate();
    showToast(message,
        context: context,
        animation: StyledToastAnimation.slideFromTopFade,
        reverseAnimation: StyledToastAnimation.slideToTopFade,
        position:
            const StyledToastPosition(align: Alignment.topCenter, offset: 0.0),
        startOffset: const Offset(0.0, -3.0),
        reverseEndOffset: const Offset(0.0, -3.0),
        duration: const Duration(seconds: 4),
        //Animation duration   animDuration * 2 <= duration
        animDuration: const Duration(seconds: 1),
        curve: Curves.fastLinearToSlowEaseIn,
        reverseCurve: Curves.fastOutSlowIn);
  }

  Future _authenticate(String username, String password) async {
    // String? token = await FirebaseMessaging.instance.getToken();
    // print("Device Token: $token");

    Map data = {'EMail': username, 'Password': password, 'DeviceID': "null"};

    String body = json.encode(data);

    http.Response response = await http.post(
      Uri.parse('https://keyreg.arfidex.de/authentication'),
      headers: {"Content-Type": "application/json"},
      body: body,
    );

    if (response.statusCode == 500) {
      showError("Bitte gültige Login Daten eingeben");
    } else if (response.statusCode == 200) {
      String receivedJson = response.body;

      // Parse the JSON response
      Map<String, dynamic> jsonData = json.decode(receivedJson);

      // Access the value of "api_key" and store it in a variable
      String apiKey = jsonData["api_key"];

      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (rememberMe) {
        prefs.setBool("isLoggedIn", true);
        prefs.setString('apiKey', apiKey);
        prefs.setString('userName', username);
      }

      globals.api_key = apiKey;
      globals.username = username;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const Home(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return child;
          },
          transitionDuration: const Duration(seconds: 0),
        ),
      );
    }
  }
}
