import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kontrolle_keyreg/globals.dart' as globals;
import 'package:kontrolle_keyreg/pages/home/screens/dashboard/dashboard.dart';

class ListPage extends StatefulWidget {
  const ListPage({Key? key}) : super(key: key);

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Datenbank'),
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
      body: FutureBuilder<List<Item>>(
        future: _fetchJobs(),
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
    );
  }

  Future<List<Item>> _fetchJobs() async {
    http.Response response = await http.get(
      Uri.parse('https://keyreg.arfidex.de/getAllObjects'),
      headers: {"Authorization": globals.api_key},
      // body: body,
    );
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
      itemCount: data.length,
      itemBuilder: (context, index) {
        return _tile(
          data[index].id.toString(),
          data[index].category,
        );
      },
    );
  }

  ListTile _tile(String id, String title) => ListTile(
        title: Text("$id - $title",
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 20,
            )),
        leading: const Icon(
          Icons.check_box_outline_blank,
          color: Color(0xff008AB3),
        ),
      );
}
