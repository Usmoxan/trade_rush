
import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class FileStorage {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/balance.json'); // Using JSON file for balance storage
  }

  Future<double?> readBalance() async {
    try {
      final file = await _localFile;
      if (await file.exists()) {
        final contents = await file.readAsString();
        final Map<String, dynamic> json = jsonDecode(contents);
        return json['balance'] as double?;
      }
    } catch (e) {
      print('Error reading balance: $e');
    }
    return null; // Return null if there's an error or the file doesn't exist
  }

  Future<void> writeBalance(double balance) async {
    final file = await _localFile;
    final Map<String, dynamic> json = {'balance': balance};
    await file.writeAsString(jsonEncode(json));
  }
}
