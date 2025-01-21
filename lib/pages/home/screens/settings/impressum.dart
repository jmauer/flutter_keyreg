import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:url_launcher/url_launcher.dart';

class WebScreen extends StatefulWidget {
  final String? path;

  WebScreen({Key? key, this.path}) : super(key: key);

  _WebScreenState createState() => _WebScreenState();
}

class _WebScreenState extends State<WebScreen> with WidgetsBindingObserver {
  Future<void>? _launched;

  @override
  void initState() {
    _launchInWebView();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Impressum"),
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
        body: Center(
          child: Column(
            children: [
              const Padding(padding: EdgeInsets.all(16.0)),
              FutureBuilder<void>(future: _launched, builder: _launchStatus),
            ],
          ),
        ));
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
}
