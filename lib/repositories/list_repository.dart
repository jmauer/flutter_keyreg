import 'dart:math';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ListRepository {
  final _random = Random();

  int _randomRange(int min, int max) => min + _random.nextInt(max - min);

  Future<void> deleteItem(String id) async {
    await Future<void>.delayed(Duration(seconds: _randomRange(1, 5)));
  }
}
