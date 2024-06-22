import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:trade_rush/model/data_model.dart';

class FileStorage {
  Future<String> get _localPath async {
    final directory = await getTemporaryDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/trades.json');
  }

  Future<List<Trade>> readTrades() async {
    try {
      final file = await _localFile;
      final contents = await file.readAsString();
      final List<dynamic> jsonData = json.decode(contents);
      return jsonData.map((e) => Trade.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<File> writeTrades(List<Trade> trades) async {
    final file = await _localFile;
    return file
        .writeAsString(json.encode(trades.map((e) => e.toJson()).toList()));
  }
}
