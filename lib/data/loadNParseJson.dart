import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:trade_rush/model/pnlmodel.dart';

Future<List<PnLData>> getPnLDataFromJson() async {
  try {
    // Get the temporary directory where the JSON file is saved
    var directory = await getTemporaryDirectory();
    var path = '${directory.path}/trades.json';

    // Read the file
    var file = await File(path).readAsString();

    // Parse JSON
    List<dynamic> jsonList = jsonDecode(file);
    List<PnLData> dataList =
        jsonList.map((json) => PnLData.fromJson(json)).toList();

    return dataList;
  } catch (e) {
    print('Error reading JSON file: $e');
    return [];
  }
}
