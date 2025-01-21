import 'dart:convert';

import 'package:flutter_custom_cards/flutter_custom_cards.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:kontrolle_keyreg/models/models.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:http/http.dart' as http;
import 'package:kontrolle_keyreg/globals.dart' as globals;

class NfcSuccessPage extends StatefulWidget {
  NfcSuccessPage({super.key, required this.scannedTag});

  final String scannedTag;

  @override
  State<NfcSuccessPage> createState() => _NfcDetailsPageState();
}

class _NfcDetailsPageState extends State<NfcSuccessPage> {
  String placeholder = "\"\"";

  String category = "";

  String description = "";

  String group = "";

  String examinationDate = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Tag: " + widget.scannedTag),
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
              height: 300,
              child: FutureBuilder<List<Item>>(
                future: _fetchTag(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    List<Item>? data = snapshot.data;
                    return _jobsListView(data);
                  } else if (snapshot.hasError) {
                    return Text("${snapshot.error}");
                  }
                  return Center();
                },
              ),
            )),
            const Spacer(),
            LottieBuilder.asset('assets/lottie/success.json'),
            CustomCard(
              height: 50,
              width: MediaQuery.of(context).size.width * 0.98,
              elevation: 2,
              borderRadius: 10,
              color: Color.fromARGB(255, 235, 45, 64),
              onTap: () {
                _deleteObject();
              },
              child: const Center(
                child: Text(
                  'Dokument löschen',
                  style: TextStyle(
                    fontSize: 21,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 45),
              child: CustomCard(
                height: 50,
                width: MediaQuery.of(context).size.width * 0.98,
                elevation: 2,
                borderRadius: 10,
                color: Color(0xff008AB3),
                onTap: () {
                  _readNdef();
                },
                child: const Center(
                  child: Text(
                    'Dokument kontrollieren',
                    style: TextStyle(
                      fontSize: 21,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            )
          ],
        ));
  }

  Future<List<Item>> _fetchTag() async {
    http.Response response = await http.get(
      Uri.parse('https://keyreg.arfidex.de/getID/${widget.scannedTag}'),
      headers: {"Authorization": globals.api_key},
      // body: body,
    );
    if (response.statusCode == 200) {
      String receivedJson = response.body;
      if (receivedJson == "()") {
        String emptyJson =
            "[{\"ID\": ${widget.scannedTag}, \"Category\": $placeholder, \"Description\": $placeholder, \"Groups\": $placeholder, \"ExaminationDate\": $placeholder}]";

        List<dynamic> emptyList = json.decode(emptyJson);
        return emptyList.map((item) => Item.fromJson(item)).toList();
      } else {
        List<dynamic> list = json.decode(receivedJson);
        return list.map((item) => Item.fromJson(item)).toList();
      }
    } else {
      throw Exception('Failed to load jobs from API');
    }
  }

  ListView _jobsListView(data) {
    return ListView.builder(
      itemCount: data.length,
      itemBuilder: (context, index) {
        return _tile(data[0].category, data[0].description, data[0].groups,
            data[0].examinationDate, widget.scannedTag);
      },
    );
  }

  Card _tile(String title, String description, String group, String date,
          String itemID) =>
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
                        text: "$date",
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
    } else {
      throw Exception('Failed to load jobs from API');
    }
  }

  Future _readNdef() async {
    var availability = await FlutterNfcKit.nfcAvailability;
    if (availability != NFCAvailability.available) return;

    NFCTag tag = await FlutterNfcKit.poll(iosAlertMessage: 'Reading');

    if (tag.ndefAvailable == true) {
      for (var record in await FlutterNfcKit.readNDEFRecords(cached: false)) {
        List<String> scannedTagPayload = record.toString().split("text=");
      }
    }
    FlutterNfcKit.finish();
  }
}
