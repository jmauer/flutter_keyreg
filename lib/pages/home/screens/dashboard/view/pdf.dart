import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:kontrolle_keyreg/localization/app_localizations.dart';
import 'package:kontrolle_keyreg/pages/home/screens/home_screen.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:kontrolle_keyreg/globals.dart' as globals;
import 'package:vibration/vibration.dart';

class PDFScreen extends StatefulWidget {
  final String? path;
  final String? tag;

  PDFScreen({Key? key, this.path, this.tag}) : super(key: key);

  _PDFScreenState createState() => _PDFScreenState();
}

class _PDFScreenState extends State<PDFScreen> with WidgetsBindingObserver {
  final Completer<PDFViewController> _controller =
      Completer<PDFViewController>();
  int? pages = 0;
  int? currentPage = 0;
  bool isReady = false;
  String errorMessage = '';
  final pdf = pw.Document();

  @override
  void initState() {
    if (widget.path != null) {
      updloadPdf();
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate('protocol')),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.ios_share, color: Colors.white),
            onPressed: () => share(),
          )
        ],
        leading: IconButton(
          icon: const Icon(Icons.cancel, color: Colors.white),
          onPressed: () => Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const Home(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return child;
              },
              transitionDuration: const Duration(seconds: 0),
            ),
          ),
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
      body: Stack(
        children: <Widget>[
          PDFView(
            filePath: widget.path,
            enableSwipe: false,
            swipeHorizontal: false,
            autoSpacing: false,
            pageFling: true,
            pageSnap: true,
            defaultPage: currentPage!,
            fitPolicy: FitPolicy.BOTH,
            preventLinkNavigation:
                false, // if set to true the link is handled in flutter
            onRender: (_pages) {
              setState(() {
                pages = _pages;
                isReady = true;
              });
            },
            onError: (error) {
              setState(() {
                errorMessage = error.toString();
              });
            },
            onPageError: (page, error) {
              setState(() {
                errorMessage = '$page: ${error.toString()}';
              });
            },
            onViewCreated: (PDFViewController pdfViewController) {
              _controller.complete(pdfViewController);
            },
            onLinkHandler: (String? uri) {},
            onPageChanged: (int? page, int? total) {
              setState(() {
                currentPage = page;
              });
            },
          ),
          errorMessage.isEmpty
              ? !isReady
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : Container()
              : Center(
                  child: Text(errorMessage),
                )
        ],
      ),
    );
  }

  share() async {
    final result = await Share.shareXFiles([XFile(widget.path!)]);

    if (result.status == ShareResultStatus.dismissed) {}
  }

  Future<void> updloadPdf() async {
    String fileName = widget.tag!; // Example file name
    Map<String, String> jsonData = {'Name': fileName};

    var request = http.MultipartRequest(
        'POST', Uri.parse('https://keyreg.arfidex.de/storePDF'));
    request.files.add(await http.MultipartFile.fromPath(
      'file',
      widget.path!,
      contentType: MediaType('application', 'pdf'),
    ));
    request.fields['data'] = json.encode(jsonData);

    final response = await request.send();

    if (response.statusCode == 200) {
      print('PDF erfolgreich hochgeladen');
      deleteKey();
    } else {
      print('PDF-Upload fehlgeschlagen: ${response.statusCode}');
    }
  }

  Future<void> deleteKey() async {
    Map data = {
      'Message': 'Schlüssel an Kunden zurückgegeben.',
      'ID': widget.tag
    };

    String body = json.encode(data);

    http.Response response = await http.post(
      Uri.parse('https://keyreg.arfidex.de/deleteItems'),
      headers: {
        "Accept": "application/json",
        "content-type": "application/json",
        "Authorization": globals.api_key
      },
      body: body,
    );

    if (response.statusCode == 200) {
      topToast('Erfolgreich zurückgegeben');
      print('Key erfolgreich gelöscht');
    } else {
      print('PDF löschen fehlgeschlagen: ${response.statusCode}');
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
}
