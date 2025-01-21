import 'dart:io';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:http/http.dart' as http;
import 'package:kontrolle_keyreg/localization/app_localizations.dart';
import 'package:kontrolle_keyreg/pages/home/screens/dashboard/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_cards/flutter_custom_cards.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:kontrolle_keyreg/pages/home/screens/dashboard/view/keychain_details.dart';
import 'package:vibration/vibration.dart';
import 'package:kontrolle_keyreg/globals.dart' as globals;
import 'scanner_details.dart';

class Scanner extends StatefulWidget {
  const Scanner({super.key});

  @override
  State<Scanner> createState() => _ScannerState();
}

class _ScannerState extends State<Scanner> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate('scanner')),
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.bottomLeft,
                end: Alignment.bottomRight,
                colors: <Color>[Color(0xffE8761E), Color(0xffFE9879)]),
          ),
        ),
      ),
      body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/background.png"),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Spacer(),
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: CustomCard(
                  height: 120,
                  width: MediaQuery.of(context).size.width * 0.95,
                  elevation: 3,
                  borderRadius: 10,
                  color: const Color.fromARGB(209, 247, 129, 40),
                  onTap: () {
                    _readNdef();
                  },
                  child: Center(
                    child: Text(
                      AppLocalizations.of(context).translate('scan_tag'),
                      style: TextStyle(
                        fontSize: 21,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              // Padding(
              //   padding: const EdgeInsets.only(top: 10.0),
              //   child: CustomCard(
              //     height: 120,
              //     width: MediaQuery.of(context).size.width * 0.95,
              //     elevation: 3,
              //     borderRadius: 10,
              //     color: const Color.fromARGB(209, 247, 129, 40),
              //     onTap: () {
              //       _readKeychainNdef();
              //     },
              //     child: Center(
              //       child: Text(
              //         AppLocalizations.of(context).translate('scan_keychain'),
              //         style: TextStyle(
              //           fontSize: 21,
              //           color: Colors.white,
              //         ),
              //       ),
              //     ),
              //   ),
              // ),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [],
              ),
              const Spacer(),
            ],
          )),
    );
  }

  Future _readNdef() async {
    if (Platform.isAndroid) {
      topToast(AppLocalizations.of(context).translate('hold_near'));
    }

    var tag = await FlutterNfcKit.poll(timeout: const Duration(seconds: 10));

    if (tag.id != "") {
      _fetchTag(tag.id);
    } else {
      topToast(AppLocalizations.of(context).translate('wrong_key'));
      if (Platform.isIOS) {
        await FlutterNfcKit.finish();
      }
    }

    if (Platform.isIOS) {
      await FlutterNfcKit.finish();
    }

    if (Platform.isAndroid) {
      topToast(AppLocalizations.of(context).translate('hold_near'));
    }
  }

  Future _readKeychainNdef() async {
    if (Platform.isAndroid) {
      topToast(AppLocalizations.of(context).translate('scan_keychain'));
    }

    var tag = await FlutterNfcKit.poll(timeout: const Duration(seconds: 10));

    if (tag.id != "") {
      Navigator.of(context).push(
        MaterialPageRoute(
            builder: (context) => KeychainDetailsPage(scannedTag: tag.id)),
      );
      if (Platform.isIOS) {
        await FlutterNfcKit.finish(
            iosAlertMessage: AppLocalizations.of(context).translate('success'));
      }
    } else {
      topToast(AppLocalizations.of(context).translate('wrong_keychain'));
      if (Platform.isIOS) {
        await FlutterNfcKit.finish();
      }
    }

    if (Platform.isIOS) {
      await FlutterNfcKit.finish();
    }

    if (Platform.isAndroid) {
      topToast(AppLocalizations.of(context).translate('hold_near'));
    }
  }

  topToast(String message) {
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

  Future _fetchTag(String tag) async {
    http.Response response = await http.get(
      Uri.parse('https://keyreg.arfidex.de/getID/${tag}'),
      headers: {
        "Authorization": globals.api_key,
        "Content-Type": "application/json"
      },
    );
    if (response.statusCode == 200) {
      String receivedJson = response.body;

      if (receivedJson.contains("k.ID")) {
        Navigator.of(context).push(
          MaterialPageRoute(
              builder: (context) => NfcDetailsPage(scannedTag: tag)),
        );
      } else {
        Navigator.of(context).push(
          MaterialPageRoute(
              builder: (context) => KeychainDetailsPage(scannedTag: tag)),
        );
      }
    } else {
      throw Exception('Failed to load jobs from API');
    }
  }
}
