import 'dart:convert';
import 'dart:io';

import 'package:flutter_custom_cards/flutter_custom_cards.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:intl/intl.dart';
import 'package:kontrolle_keyreg/pages/home/localization/app_localizations.dart';
import 'package:kontrolle_keyreg/pages/home/screens/dashboard/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kontrolle_keyreg/globals.dart' as globals;
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:kontrolle_keyreg/pages/home/screens/dashboard/view/digital_Signature.dart';
import 'package:pull_down_button/pull_down_button.dart';
import 'package:vibration/vibration.dart';

class KeychainDetailsPage extends StatefulWidget {
  KeychainDetailsPage({super.key, required this.scannedTag});

  final String scannedTag;

  @override
  State<KeychainDetailsPage> createState() => _KeychainDetailsPageState();
}

class _KeychainDetailsPageState extends State<KeychainDetailsPage> {
  String placeholder = "\"\"";

  String category = "";

  String description = "";

  String group = "";

  String examinationDate = "";

  Color myColor = Color(0xffFD5E3D);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${AppLocalizations.of(context).translate('keychain')}: " +
            widget.scannedTag),
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.bottomLeft,
                end: Alignment.bottomRight,
                colors: <Color>[Color(0xffE8761E), Color(0xffFE9879)]),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SizedBox(
              child: FutureBuilder<List<Item>>(
                future: _fetchTag(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center();
                  } else if (snapshot.hasError) {
                    return Text("Fehler: ${snapshot.error}");
                  } else if (!snapshot.hasData || snapshot.hasError) {
                    return Text("Keine Daten verfügbar.");
                  } else {
                    var data = snapshot.data;

                    return Column(
                      children: [
                        // Jobs ListView
                        Expanded(
                          child: _jobsListView(data),
                        ),
                        Text(AppLocalizations.of(context)
                            .translate('included_keys')),
                        // Keys ListView
                      ],
                    );
                  }
                },
              ),
            ),
          ),
          Expanded(
            child: SizedBox(
              child: FutureBuilder<List<Item>>(
                future: _fetchJobs(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center();
                  } else if (snapshot.hasError) {
                    return Text("Fehler: ${snapshot.error}");
                  } else if (!snapshot.hasData || snapshot.hasError) {
                    return Text("Keine Daten verfügbar.");
                  } else {
                    var data = snapshot.data;

                    return Column(
                      children: [
                        // Jobs ListView
                        Expanded(
                          child: _keysListView(data),
                        ),
                      ],
                    );
                  }
                },
              ),
            ),
          ),
          const Spacer(),
          Padding(
            padding: EdgeInsets.only(bottom: 45),
            child: FutureBuilder<List<Item>>(
              future: _fetchTag(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<Item>? data = snapshot.data;
                  if (data != null &&
                      data.isNotEmpty &&
                      data[0].timestamp == null) {
                    return CustomCard(
                      height: 50,
                      width: MediaQuery.of(context).size.width * 0.98,
                      elevation: 2,
                      borderRadius: 10,
                      color: Color.fromARGB(209, 247, 129, 40),
                      onTap: () {
                        takeKey();
                      },
                      child: Center(
                        child: Text(
                          AppLocalizations.of(context)
                              .translate('take_keychain'),
                          style: TextStyle(
                            fontSize: 21,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    );
                  } else {
                    return PullDownButton(
                      itemBuilder: (context) => [
                        PullDownMenuItem(
                          title: AppLocalizations.of(context)
                              .translate('return_key'),
                          onTap: () {
                            _readNdef(widget.scannedTag);
                          },
                        ),
                        PullDownMenuItem(
                          title: AppLocalizations.of(context)
                              .translate('give_key_to_employee'),
                          onTap: () {
                            _readNdef(widget.scannedTag);
                          },
                        ),
                        PullDownMenuItem(
                          title: AppLocalizations.of(context)
                              .translate('give_key_to_customer'),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (context) => DigitalSignature(
                                        scannedTag: widget.scannedTag,
                                      )),
                            );
                          },
                        ),
                      ],
                      buttonBuilder: (context, showMenu) => CustomCard(
                        height: 50,
                        width: MediaQuery.of(context).size.width * 0.98,
                        elevation: 2,
                        borderRadius: 10,
                        color: Color.fromARGB(209, 247, 129, 40),
                        onTap: () {
                          // _readNdef(widget.scannedTag);
                          showMenu();
                        },
                        child: Center(
                          child: Text(
                            AppLocalizations.of(context)
                                .translate('give_keychain'),
                            style: TextStyle(
                              fontSize: 21,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                } else if (snapshot.hasError) {
                  return Text("${snapshot.error}");
                }
                return Container(); // Placeholder for loading state
              },
            ),
          ),
        ],
      ),
    );
  }

  takeKey() async {
    Map data = {'KeychainID': widget.scannedTag};
    String body = json.encode(data);
    print(body);
    http.Response response = await http.post(
      Uri.parse('https://keyreg.arfidex.de/giveKeychainToUser'),
      headers: {
        "Authorization": globals.api_key,
        "Content-Type": "application/json"
      },
      body: body,
    );

    if (response.statusCode == 200) {
      topToast(AppLocalizations.of(context).translate('success'));
      setState(() {});
    } else {
      topToast(AppLocalizations.of(context).translate('error'));
    }
  }

  Future<List<Item>>? _fetchJobs() async {
    String getUsername = globals.username;
    Map data = {
      'KeychainID': widget.scannedTag,
    };
    String body = json.encode(data);
    print(body);
    http.Response response = await http.post(
      Uri.parse('https://keyreg.arfidex.de/getAllKeysFromKeychain'),
      headers: {
        "Accept": "application/json",
        "content-type": "application/json",
        "Authorization": globals.api_key
      },
      body: body,
    );
    print(response.statusCode);
    if (response.statusCode == 200) {
      String receivedJson = response.body;
      // print(receivedJson);
      if (receivedJson.isNotEmpty) {
        final List<dynamic> jsonArray = json.decode(receivedJson);
        print("🍅");
        print(jsonArray);
        final List<Item> items =
            jsonArray.map((json) => Item.fromJson(json)).toList();
        print(items[0].keyNumber);
        return items;
      } else {
        return List.empty();
      }
    } else {
      throw Exception('Verbidnung zum Server verloren.');
    }
  }

  ListView _keysListView(data) {
    return ListView.builder(
      itemCount: data.length,
      itemBuilder: (context, index) {
        return _keyTile(
            data[index].loanPeriod, data[index].keyNumber, data[index].name);
      },
    );
  }

  Card _keyTile(String date, String itemID, String name) => Card(
      elevation: 2,
      child: Column(
        children: [
          ListTile(
            leading: Image.asset("assets/key.png"),
            title: Text(
                "${AppLocalizations.of(context).translate('key')}: " +
                    itemID +
                    " (" +
                    name +
                    ")",
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 20,
                )),
          ),
        ],
      ));

  Future<List<Item>> _fetchTag() async {
    // Map data = {'KeychainID': widget.scannedTag};
    // String body = json.encode(data);
    // print(body);
    http.Response response = await http.get(
      Uri.parse('https://keyreg.arfidex.de/getKeychainID/${widget.scannedTag}'),
      headers: {
        "Authorization": globals.api_key,
        "Content-Type": "application/json"
      },
      // body: body,
    );
    print(response.body);
    // const ListAPIUrl = 'https://keyreg.arfidex.de/getAllObjects';
    // final response = await http.get(Uri.parse(ListAPIUrl));
    if (response.statusCode == 200) {
      String receivedJson = response.body;
      print(receivedJson);
      if (receivedJson != '()') {
        List<dynamic> list = json.decode(receivedJson);
        return list.map((item) => Item.fromJson(item)).toList();
      } else {
        return List.empty();
      }
    } else {
      throw Exception('Failed to load jobs from API');
    }
  }

  ListView _jobsListView(data) {
    return ListView.builder(
      itemCount: 1,
      itemBuilder: (context, index) {
        return _tile(
            data[0].name,
            data[0].misc,
            data[0].id,
            data[0].loanPeriod.toString(),
            data[0].id,
            data[0].timestamp.toString());
      },
    );
  }

  Card _tile(String title, String description, String group, String date,
          String itemID, String lastCheckedDate) =>
      Card(
          elevation: 2,
          child: Column(
            children: [
              ListTile(
                title: Text("$title",
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 20,
                    )),
                subtitle: Text.rich(
                  TextSpan(text: "$group - ", children: <TextSpan>[
                    TextSpan(
                        text: lastCheckedDate,
                        style: TextStyle(fontWeight: FontWeight.bold))
                  ]),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 16.0, right: 16.0, bottom: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [Text(description)],
                ),
              )
            ],
          ));

  Future<void> _deleteObject() async {
    http.Response response = await http.get(
      Uri.parse('https://keyreg.arfidex.de/deleteItem/${widget.scannedTag}'),
      headers: {"Authorization": globals.api_key},
      // body: body,
    );

    if (response.statusCode == 200) {
      String receivedJson = response.body;
      print(receivedJson);
    } else {
      throw Exception('Failed to load jobs from API');
    }
  }

  Future<void> _updateExaminationDate(String scannedTag) async {
    getIntervall();

    Map data = {
      'KeychainID': scannedTag,
    };
    String body = json.encode(data);
    print(body);
    http.Response response = await http.post(
      Uri.parse('https://keyreg.arfidex.de/returnKeychain'),
      headers: {
        "Authorization": globals.api_key,
        "Content-Type": "application/json"
      },
      body: body,
    );

    if (response.statusCode == 200) {
      topToast(AppLocalizations.of(context).translate('success'));
      setState(() {});
    } else {
      topToast(AppLocalizations.of(context).translate('error'));
    }
  }

  Future _readNdef(String scannedTag) async {
    if (Platform.isAndroid) {
      topToast(AppLocalizations.of(context).translate('hold_near'));
    }

    var tag = await FlutterNfcKit.poll(timeout: const Duration(seconds: 10));
    print(tag.id);
    if (tag.id == scannedTag) {
      _updateExaminationDate(tag.id);
      if (Platform.isIOS) {
        await FlutterNfcKit.finish(
            iosAlertMessage: AppLocalizations.of(context).translate('success'));
      }
    } else {
      topToast(AppLocalizations.of(context).translate('wrong_key'));
      if (Platform.isIOS) {
        await FlutterNfcKit.finish();
      }
    }

    if (Platform.isIOS) {
      await FlutterNfcKit.finish();
    }
  }

  parseDate<String>(String input) {
    var inputFormat = DateFormat('yyyy-MM-dd');
    var date1 = inputFormat.parse(input.toString());
    var outputFormat = DateFormat('dd.MM.yyyy');
    var date2 = outputFormat.format(date1);
    return date2;
  }

  topToast(String message) {
    Vibration.vibrate();
    showToast(message,
        context: context,
        animation: StyledToastAnimation.slideFromTopFade,
        reverseAnimation: StyledToastAnimation.slideToTopFade,
        position: StyledToastPosition(align: Alignment.topCenter, offset: 0.0),
        startOffset: Offset(0.0, -3.0),
        reverseEndOffset: Offset(0.0, -3.0),
        duration: Duration(seconds: 4),
        //Animation duration   animDuration * 2 <= duration
        animDuration: Duration(seconds: 1),
        curve: Curves.fastLinearToSlowEaseIn,
        reverseCurve: Curves.fastOutSlowIn);
  }

  Future getIntervall() async {
    http.Response response = await http.get(
      Uri.parse('https://keyreg.arfidex.de/getIntervall'),
      headers: {"Authorization": globals.api_key},
    );

    print(response.body.split(" ")[3]);

    var version = response.body.split(" ")[3].replaceAll("}", "");

    print(version);

    if (response.statusCode == 200) {
      globals.checkIntervall = version as int;
    } else {}
  }
}

class DeleteDialog extends StatelessWidget {
  const DeleteDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Objekt löschen?'),
          content: const Text('AlertDialog description'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, 'Cancel'),
              child: Text(AppLocalizations.of(context).translate('cancel')),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, 'OK'),
              child: Text(AppLocalizations.of(context).translate('ok')),
            ),
          ],
        ),
      ),
      child: const Text('Show Dialog'),
    );
  }
}

class SuccessDialog extends StatelessWidget {
  const SuccessDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('AlertDialog Title'),
          content: const Text('AlertDialog description'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, 'Cancel'),
              child: Text(AppLocalizations.of(context).translate('cancel')),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, 'OK'),
              child: Text(AppLocalizations.of(context).translate('ok')),
            ),
          ],
        ),
      ),
      child: const Text('Show Dialog'),
    );
  }
}
