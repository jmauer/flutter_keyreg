import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:kontrolle_keyreg/localization/app_localizations.dart';
import 'package:kontrolle_keyreg/pages/home/screens/settings/dsgvo.dart';
import 'package:flutter/material.dart';
import 'package:kontrolle_keyreg/pages/home/screens/settings/impressum.dart';
import 'package:kontrolle_keyreg/pages/login/screens/login.dart';
import 'package:path_provider/path_provider.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:kontrolle_keyreg/globals.dart' as globals;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  Future<void>? _launched;
  String pathPDF = "";

  @override
  void initState() {
    super.initState();
    fromAsset('assets/dsgvo.pdf', 'dsgvo.pdf').then((f) {
      setState(() {
        pathPDF = f.path;
        print(f.path);
      });
    });
  }

  Future<File> fromAsset(String asset, String filename) async {
    // To open from assets, you can copy them to the app storage folder, and the access them "locally"z
    Completer<File> completer = Completer();

    try {
      var dir = await getApplicationDocumentsDirectory();
      File file = File("${dir.path}/$filename");
      var data = await rootBundle.load(asset);
      var bytes = data.buffer.asUint8List();
      await file.writeAsBytes(bytes, flush: true);
      completer.complete(file);
    } catch (e) {
      throw Exception('Error parsing asset file!');
    }

    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate('settings')),
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
      body: Center(
        child: SettingsList(
          sections: [
            SettingsSection(
              title: Text(AppLocalizations.of(context).translate('overview')),
              tiles: <SettingsTile>[
                // SettingsTile(
                //   leading: const Icon(Icons.language),
                //   title:
                //       Text(AppLocalizations.of(context).translate('language')),
                //   value: const Text('Deutsch'),
                // ),
                SettingsTile(
                  leading: const Icon(Icons.info_outline_rounded),
                  title: Text(
                      AppLocalizations.of(context).translate('api_version')),
                  value: FutureBuilder(
                    future: getVersion(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        String? data = snapshot.data;
                        return Text(data.toString());
                      } else if (snapshot.hasError) {
                        return const Text("");
                      }
                      return const Text("");
                    },
                  ),
                ),
                SettingsTile(
                  leading: const Icon(Icons.cloud_outlined),
                  title: Text(
                      AppLocalizations.of(context).translate('environment')),
                  value: const Text('Produktion'),
                ),
              ],
            ),
            SettingsSection(
                title: Text(AppLocalizations.of(context).translate('rights')),
                tiles: <SettingsTile>[
                  SettingsTile.navigation(
                    leading: const Icon(Icons.verified_user_outlined),
                    title:
                        Text(AppLocalizations.of(context).translate('dsgvo')),
                    onPressed: (context) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PDFScreen(
                            path: pathPDF,
                          ),
                        ),
                      );
                    },
                  ),
                  SettingsTile.navigation(
                    leading: const Icon(Icons.info_outline_rounded),
                    title: Text(
                        AppLocalizations.of(context).translate('impressum')),
                    onPressed: (context) {
                      _launchInWebView();

                      FutureBuilder<void>(
                          future: _launched, builder: _launchStatus);
                    },
                  ),
                ]),
            SettingsSection(
              title: Text(AppLocalizations.of(context).translate('account')),
              tiles: <SettingsTile>[
                SettingsTile(
                  leading: const Icon(Icons.person),
                  title: Text(globals.username),
                ),
                SettingsTile.navigation(
                  leading: const Icon(Icons.logout_rounded),
                  title:
                      Text(AppLocalizations.of(context).translate('log_out')),
                  onPressed: (context) {
                    logout();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _launchStatus(BuildContext context, AsyncSnapshot<void> snapshot) {
    if (snapshot.hasError) {
      return Text('Error: ${snapshot.error}');
    } else {
      return const Text('');
    }
  }

  Future<void> _launchInWebView() async {
    final Uri toLaunch =
        Uri(scheme: 'https', host: 'arfidex.de', path: 'index.php/impressum');
    if (!await launchUrl(toLaunch, mode: LaunchMode.inAppBrowserView)) {
      throw Exception('Could not launch $toLaunch');
    }
  }

  Future<String> getVersion() async {
    http.Response response = await http.get(
      Uri.parse('https://keyreg.arfidex.de/getApiVersion'),
      headers: {"Authorization": globals.api_key},
    );

    print(response.body.split(" ")[4]);

    var version =
        response.body.split(" ")[4].replaceAll("}", "").replaceAll("\"", "");

    if (response.statusCode == 200) {
      return version.trimRight();
    } else {}

    return "";
  }

  logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setBool("isLoggedIn", false);
    prefs.setString('apiKey', "");
    prefs.setString('userName', "");

    globals.api_key = "";
    globals.username = "";

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const LoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return child;
        },
        transitionDuration: const Duration(seconds: 0),
      ),
    );
  }
}
