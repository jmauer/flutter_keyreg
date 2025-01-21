// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_custom_cards/flutter_custom_cards.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kontrolle_keyreg/pages/home/localization/app_localizations.dart';
import 'package:kontrolle_keyreg/pages/home/screens/dashboard/view/digital_Signature.dart';
import 'package:kontrolle_keyreg/pages/home/screens/dashboard/view/keychain_details.dart';
import 'package:pull_down_button/pull_down_button.dart';
import 'package:kontrolle_keyreg/globals.dart' as globals;
import 'package:kontrolle_keyreg/pages/home/screens/dashboard/dashboard.dart';
import 'package:intl/intl.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'dart:io' show Platform;
import 'package:vibration/vibration.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  late final Future<List<Item>>? keys;
  late final Future<List<Item>>? keychains;

  @override
  void initState() {
    keys = _fetchJobs();
    keychains = _fetchKeychains();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context).translate('dashboard')),
          automaticallyImplyLeading: false,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.bottomLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[Color(0xffE8761E), Color(0xffFE9879)]),
            ),
          ),
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize:
                const Size.fromHeight(30.0), // Höhe der TabBar + Padding
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  child: Container(
                    height: 30,
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      color: Colors.white,
                    ),
                    child: TabBar(
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      indicator: BoxDecoration(
                        color: Color.fromARGB(91, 232, 118, 30),
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      labelColor: Colors.black87,
                      unselectedLabelColor: Colors.black54,
                      tabs: [
                        Tab(
                          child: AutoSizeText(
                            AppLocalizations.of(context).translate('key'),
                            style: TextStyle(fontSize: 14),
                            maxLines: 1,
                            minFontSize: 8,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Tab(
                          child: AutoSizeText(
                            AppLocalizations.of(context).translate('keychains'),
                            style: TextStyle(fontSize: 14),
                            maxLines: 1,
                            minFontSize: 8,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Padding(
                  padding:
                      EdgeInsets.only(top: 10.0), // Padding unter der TabBar
                ),
              ],
            ),
          ),
        ),
        body: TabBarView(
          children: [
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/background.png"),
                  fit: BoxFit.cover,
                ),
              ),
              child: FutureBuilder<List<Item>>(
                future: keys,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    List<Item>? data = snapshot.data;
                    return _jobsListView(data);
                  } else if (snapshot.hasError) {
                    return Center(
                        child: Text(
                            AppLocalizations.of(context).translate('no_data')));
                  }
                  return Center();
                },
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/background.png"),
                  fit: BoxFit.cover,
                ),
              ),
              child: FutureBuilder<List<Item>>(
                future: keychains,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    List<Item>? data = snapshot.data;
                    return _KeychainsListView(data);
                  } else if (snapshot.hasError) {
                    return Center(
                        child: Text(
                            AppLocalizations.of(context).translate('no_data')));
                  }
                  return Center();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<List<Item>>? _fetchJobs() async {
    String getUsername = globals.username;
    Map data = {
      'EMail': getUsername,
    };
    String body = json.encode(data);
    print(body);
    http.Response response = await http.post(
      Uri.parse('https://keyreg.arfidex.de/getCurrentKeysFromUser'),
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
        print("🥦");
        print(jsonArray);
        final List<Item> items =
            jsonArray.map((json) => Item.fromJson(json)).toList();
        return items;
      } else {
        return List.empty();
      }
    } else {
      throw Exception('Verbidnung zum Server verloren.');
    }
  }

  Future<List<Item>>? _fetchKeychains() async {
    String getUsername = globals.username;
    Map data = {
      'EMail': getUsername,
    };
    String body = json.encode(data);
    print(body);
    http.Response response = await http.post(
      Uri.parse('https://keyreg.arfidex.de/getCurrentKeychainsFromUser'),
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
        print("🍊");

        final List<Item> keychains =
            jsonArray.map((json) => Item.fromJson(json)).toList();

        return keychains;
      } else {
        return List.empty();
      }
    } else {
      throw Exception('Verbidnung zum Server verloren.');
    }
  }

  ListView _jobsListView(data) {
    return ListView.builder(
      itemCount: data.length,
      itemBuilder: (context, index) {
        return _tile(data[index].loanDate, data[index].id, data[index].name,
            data[index].id);
      },
    );
  }

  ListView _KeychainsListView(data) {
    return ListView.builder(
      itemCount: data.length,
      itemBuilder: (context, index) {
        return _keychaintile(
            data[index].loanDate, data[index].keychainName, data[index].id);
      },
    );
  }

  Card _tile(String date, String itemID, String name, String realID) => Card(
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
            subtitle: Text.rich(
              TextSpan(
                  text:
                      "${AppLocalizations.of(context).translate('borrowed_when')}: ",
                  children: <TextSpan>[
                    TextSpan(
                        text: date,
                        style: const TextStyle(fontWeight: FontWeight.bold))
                  ]),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              PullDownButton(
                itemBuilder: (context) => [
                  PullDownMenuItem(
                    title: AppLocalizations.of(context).translate('return_key'),
                    onTap: () {
                      _readNdef(realID);
                    },
                  ),
                  PullDownMenuItem(
                    title: AppLocalizations.of(context)
                        .translate('give_key_to_employee'),
                    onTap: () {
                      _readNdef(realID);
                    },
                  ),
                  PullDownMenuItem(
                    title: AppLocalizations.of(context)
                        .translate('give_key_to_customer'),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) =>
                                DigitalSignature(scannedTag: realID)),
                      );
                    },
                  ),
                ],
                buttonBuilder: (context, showMenu) => CustomCard(
                    height: 40,
                    width: MediaQuery.of(context).size.width * 0.95,
                    elevation: 3,
                    borderRadius: 10,
                    color: Color.fromARGB(209, 247, 129, 40),
                    onTap: () {
                      // _readNdef(widget.scannedTag);
                      showMenu();
                    },
                    child: Center(
                      child: Text(
                        AppLocalizations.of(context).translate('return_key'),
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                    )),
              ),
              CustomCard(
                height: 40,
                width: MediaQuery.of(context).size.width * 0.95,
                elevation: 3,
                borderRadius: 10,
                color: const Color(0xffE8761E),
                child: Center(
                  child: Text(
                    AppLocalizations.of(context).translate('show_key'),
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (context) =>
                            NfcDetailsPage(scannedTag: realID)),
                  );
                },
              ),
            ],
          )
        ],
      ));

  Card _keychaintile(
    String date,
    String name,
    String id,
  ) =>
      Card(
          elevation: 2,
          child: Column(
            children: [
              ListTile(
                leading: Image.asset("assets/keychain.png"),
                title: Text(
                    "${AppLocalizations.of(context).translate('keychain')}: " +
                        name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 20,
                    )),
                subtitle: Text.rich(
                  TextSpan(
                      text:
                          "${AppLocalizations.of(context).translate('borrowed_when')}: ",
                      children: <TextSpan>[
                        TextSpan(
                            text: date,
                            style: const TextStyle(fontWeight: FontWeight.bold))
                      ]),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  PullDownButton(
                    itemBuilder: (context) => [
                      PullDownMenuItem(
                        title: AppLocalizations.of(context)
                            .translate('return_keychain'),
                        onTap: () {
                          _readNdefKeychain(id);
                        },
                      ),
                      PullDownMenuItem(
                        title: AppLocalizations.of(context)
                            .translate('give_key_to_employee'),
                        onTap: () {
                          _readNdefKeychain(id);
                        },
                      ),
                      PullDownMenuItem(
                        title: AppLocalizations.of(context)
                            .translate('give_key_to_customer'),
                        onTap: () {
                          // handle option 3
                        },
                      ),
                    ],
                    buttonBuilder: (context, showMenu) => CustomCard(
                        height: 40,
                        width: MediaQuery.of(context).size.width * 0.95,
                        elevation: 3,
                        borderRadius: 10,
                        color: Color.fromARGB(209, 247, 129, 40),
                        onTap: () {
                          // _readNdef(widget.scannedTag);
                          showMenu();
                        },
                        child: Center(
                          child: Text(
                            AppLocalizations.of(context)
                                .translate('return_keychain'),
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                        )),
                  ),
                  CustomCard(
                    height: 40,
                    width: MediaQuery.of(context).size.width * 0.95,
                    elevation: 3,
                    borderRadius: 10,
                    color: const Color(0xffE8761E),
                    child: Center(
                      child: Text(
                        AppLocalizations.of(context).translate('show_keychain'),
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) =>
                                KeychainDetailsPage(scannedTag: id)),
                      );
                    },
                  ),
                ],
              )
            ],
          ));

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

  Future _readNdefKeychain(String scannedTag) async {
    if (Platform.isAndroid) {
      topToast(AppLocalizations.of(context)
          .translate(AppLocalizations.of(context).translate('hold_near')));
    }

    var tag = await FlutterNfcKit.poll(timeout: const Duration(seconds: 10));
    print(tag.id);
    if (tag.id == scannedTag) {
      _returnKeychain(tag.id);
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
  }

  Future<void> _updateExaminationDate(String scannedTag) async {
    getIntervall();

    Map data = {'KeyID': scannedTag};
    String body = json.encode(data);
    print(body);
    http.Response response = await http.post(
      Uri.parse('https://keyreg.arfidex.de/returnKey'),
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
      topToast(AppLocalizations.of(context).translate('wrong_keychain'));
    }
  }

  Future<void> _returnKeychain(String scannedTag) async {
    getIntervall();

    Map data = {'KeychainID': scannedTag};
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
      topToast(AppLocalizations.of(context).translate('wrong_keychain'));
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
