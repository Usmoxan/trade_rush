import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:trade_rush/data/loadNParseJson.dart';
import 'package:trade_rush/style/colors.dart';
import 'package:trade_rush/widgets/pnl_chart.dart';

import 'data/readNsavedata.dart';
import 'model/data_model.dart';
import 'model/pnlmodel.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _controller2 = TextEditingController();
  final FileStorage _storage = FileStorage();
  List<Trade> _trades = [];
  int _won = 0;
  int _loss = 0;
  double _winRate = 0.0;
  double _balance = 0.0; // Balance o'zgaruvchisi
  double _lastProfit = 0.0; // Oxirgi profit miqdori
  double _lastLoss = 0.0; // Oxirgi loss miqdori
  double _profitPercentage = 0.0; // Profit foiz
  double _lossPercentage = 0.0; // Loss foiz
  double _highestProfit = 0.0; // Eng yuqori profit miqdori
  double _highestLoss = 0.0; // Eng yuqori loss miqdori

  @override
  void initState() {
    super.initState();
    _loadTrades();
  }

  Future<void> _loadTrades() async {
    final trades = await _storage.readTrades();
    setState(() {
      _trades = trades;
      _calculateWinRate();
      _calculateBalance();
      _calculateStatistics();
    });
  }

  void _calculateBalance() {
    _balance = _trades.fold(
        0.0,
        (double balance, trade) =>
            trade.isProfit ? balance + trade.amount : balance - trade.amount);
  }

  Future<String> get _localPath async {
    final directory = await getTemporaryDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/trades.json');
  }

  void _copyJsonToClipboard() {
    print(0);
    final jsonString =
        json.encode(_trades.map((trade) => trade.toJson()).toList());
    Clipboard.setData(ClipboardData(text: jsonString));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('JSON copied to clipboard')),
    );
  }

  void _calculateStatistics() {
    // Oxirgi profit va loss miqdorlarini aniqlash
    if (_trades.isNotEmpty) {
      _lastProfit = _trades
          .lastWhere((trade) => trade.isProfit,
              orElse: () =>
                  Trade(amount: 0.0, isProfit: false, date: DateTime.now()))
          .amount;
      _lastLoss = _trades
          .lastWhere((trade) => !trade.isProfit,
              orElse: () =>
                  Trade(amount: 0.0, isProfit: true, date: DateTime.now()))
          .amount;

      // Profit va loss foizlarini hisoblash
      _won = _trades.where((trade) => trade.isProfit).length;
      _loss = _trades.where((trade) => !trade.isProfit).length;
      int totalTrades = _won + _loss;
      _winRate = totalTrades > 0 ? (_won / totalTrades) * 100 : 0.0;

      if (_won > 0) {
        _profitPercentage = (_won / totalTrades) * 100;
      }
      if (_loss > 0) {
        _lossPercentage = (_loss / totalTrades) * 100;
      }

      // Eng yuqori profit va loss miqdorlarini aniqlash
      _highestProfit = _trades
          .where((trade) => trade.isProfit)
          .map((trade) => trade.amount)
          .fold(0.0, (max, current) => current > max ? current : max);

      _highestLoss = _trades
          .where((trade) => !trade.isProfit)
          .map((trade) => trade.amount)
          .fold(0.0, (max, current) => current > max ? current : max);
    } else {
      // If _trades is empty, reset all statistics variables
      _won = 0;
      _loss = 0;
      _winRate = 0.0;
      _profitPercentage = 0.0;
      _lossPercentage = 0.0;
      _highestProfit = 0.0;
      _highestLoss = 0.0;
    }
  }

  void _calculateWinRate() {
    _won = _trades.where((trade) => trade.isProfit).length;
    _loss = _trades.where((trade) => !trade.isProfit).length;
    int totalTrades = _won + _loss;
    _winRate = totalTrades > 0 ? (_won / totalTrades) * 100 : 0.0;
  }

  void _addTrade(bool isProfit) {
    final amount = double.tryParse(_controller.text);
    if (amount != null) {
      final trade =
          Trade(amount: amount, isProfit: isProfit, date: DateTime.now());
      setState(() {
        _trades.add(trade);
        _storage.writeTrades(_trades);

        // Update balance after adding trade
        if (isProfit) {
          _balance += amount;
        } else {
          _balance -= amount;
        }

        _calculateWinRate();
        _calculateStatistics();
        _controller.clear();
      });
    }
  }

  void _addTrade2(bool isProfit) {
    final amount = double.tryParse(_controller2.text);
    if (amount != null) {
      final trade =
          Trade(amount: -amount, isProfit: isProfit, date: DateTime.now());
      setState(() {
        _trades.add(trade);
        _storage.writeTrades(_trades);

        // Update balance after adding trade
        if (isProfit) {
          _balance += amount;
        } else {
          _balance -= amount;
        }

        _calculateWinRate();
        _calculateStatistics();
        _controller2.clear();
      });
    }
  }

  Future<void> _resetTrades() async {
    final path = await _localFile;
    await path.delete();
    setState(() {
      _trades = [];
      _balance = 0;
      _won = 0;
      _loss = 0;
      _winRate = 0.0;
      _lastProfit = 0.0;
      _lastLoss = 0.0;
      _profitPercentage = 0.0;
      _lossPercentage = 0.0;
      _highestProfit = 0.0;
      _highestLoss = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColorDark,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            //Win rate widget
            Container(
              margin: const EdgeInsets.only(top: 8, bottom: 8),
              padding: const EdgeInsets.all(18),
              width: double.infinity,
              decoration: BoxDecoration(
                  color: bgPrimaryDark,
                  borderRadius: BorderRadius.circular(10)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Yutish koeffitsiendi:',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  Text(
                    '${_winRate.toStringAsFixed(1)}%',
                    style: const TextStyle(
                        color: clGreen,
                        fontSize: 30,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            //No of trades widget
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: bgPrimaryDark,
                  borderRadius: BorderRadius.circular(10)),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Barcha tradelar soni:',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                        Text(
                          '${_trades.length}',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 30),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: clGreen.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10)),
                        child: Row(
                          children: [
                            Text(
                              ' $_won',
                              style: const TextStyle(color: clGreen),
                            ),
                            const Text(
                              ' ta',
                              style: TextStyle(color: clGreen),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 5),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: clRed.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10)),
                        child: Row(
                          children: [
                            Text(
                              '$_loss',
                              style: const TextStyle(color: clRed),
                            ),
                            const Text(
                              ' ta',
                              style: TextStyle(color: clRed),
                            ),
                          ],
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),

            //add profit & loss widget
            Container(
              margin: const EdgeInsets.only(top: 8, bottom: 8),
              decoration: BoxDecoration(
                  color: bgPrimaryDark,
                  borderRadius: BorderRadius.circular(10)),
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                            color: bgSecondaryDark,
                            borderRadius: BorderRadius.circular(10)),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextField(
                                style: const TextStyle(color: Colors.white),
                                controller: _controller,
                                decoration: const InputDecoration(
                                    labelText: 'Qiymati',
                                    labelStyle: TextStyle(color: Colors.white)),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                    onPressed: () => _addTrade(true),
                                    style: ButtonStyle(
                                      backgroundColor: WidgetStateProperty.all<
                                              Color>(
                                          clGreen), // Example background color
                                      // Other customizations like foregroundColor, padding, etc. can be added here
                                    ),
                                    child: const Text('+ Profit')),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                            color: bgSecondaryDark,
                            borderRadius: BorderRadius.circular(10)),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextField(
                                controller: _controller2,
                                style: const TextStyle(color: Colors.white),
                                decoration: const InputDecoration(
                                    labelText: 'Qiymati',
                                    labelStyle: TextStyle(color: Colors.white)),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                    style: ButtonStyle(
                                      backgroundColor: WidgetStateProperty.all<
                                              Color>(
                                          clRed), // Example background color
                                      // Other customizations like foregroundColor, padding, etc. can be added here
                                    ),
                                    onPressed: () => _addTrade2(false),
                                    child: const Text('- Loss')),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            //stats widget
            Container(
              margin: const EdgeInsets.only(top: 8, bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: bgSecondaryDark,
                          borderRadius: BorderRadius.circular(10)),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Boshlang'ich balans: $_balance",
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Hozirgi balans: $_balance",
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Oxirgi profit: $_lastProfit",
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Profit koeffitsienti: ${_profitPercentage.toStringAsFixed(1)}%",
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: bgSecondaryDark,
                          borderRadius: BorderRadius.circular(10)),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "G'alabalar soni: $_won",
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Yutqazishlar soni: $_loss",
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Eng katta profit: $_highestProfit",
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Eng katta Loss: $_highestLoss ",
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            //graphic
            SizedBox(
              height: 350,
              width: double.infinity,
              child: FutureBuilder<List<PnLData>>(
                future: getPnLDataFromJson(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SizedBox(
                            width: snapshot.data!.length * 45.0,
                            child: PnLBarChart(data: snapshot.data!)));
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ),

            //trade history list widget
            Container(
              margin: const EdgeInsets.only(top: 8, bottom: 8),
              padding: const EdgeInsets.all(10),
              height: 400,
              width: double.infinity,
              decoration: BoxDecoration(
                color: bgPrimaryDark,
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListView.builder(
                itemCount: _trades.length,
                itemBuilder: (context, index) {
                  final trade = _trades[index];
                  final tradeNumber = index + 1;
                  final tradeType = trade.isProfit ? 'Profit' : 'Loss';

                  // Format date for current trade
                  String formattedDate = _formatDate(trade.date);

                  // Check if current date is different from previous date
                  bool showDateHeader = index == 0 ||
                      _trades[index - 1].date.day != trade.date.day;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (showDateHeader)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  formattedDate,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Text(
                               'Balans: ${_balance.toString()} \$',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      Card(
                        color: bgSecondaryDark,
                        child: ListTile(
                          title: Text(
                            'Trade $tradeNumber',
                            style: const TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            '$tradeType: ${tradeType == "Profit" ? "+" : ""}${trade.amount.toStringAsFixed(2)} \$',
                            style: TextStyle(
                              color: trade.isProfit ? clGreen : clRed,
                            ),
                          ),
                          trailing: Text(
                            formattedDate,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            //settings widget reset & edit balance
            Container(
              margin: const EdgeInsets.only(top: 8, bottom: 8),
              padding: const EdgeInsets.all(18),
              width: double.infinity,
              decoration: BoxDecoration(
                  color: bgPrimaryDark,
                  borderRadius: BorderRadius.circular(10)),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _resetTrades(),
                      child: const Text('YANGILASH'),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {},
                            child: const Text('Update Balance'),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

String _formatDate(DateTime date) {
  return '${date.day} ${_getMonthName(date.month)} ${date.year}';
}

String _getMonthName(int month) {
  switch (month) {
    case 1:
      return 'January';
    case 2:
      return 'February';
    case 3:
      return 'March';
    case 4:
      return 'April';
    case 5:
      return 'May';
    case 6:
      return 'June';
    case 7:
      return 'July';
    case 8:
      return 'August';
    case 9:
      return 'September';
    case 10:
      return 'October';
    case 11:
      return 'November';
    case 12:
      return 'December';
    default:
      return '';
  }
}
