import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
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
              orElse: () => Trade(amount: 0.0, isProfit: false))
          .amount;
      _lastLoss = _trades
          .lastWhere((trade) => !trade.isProfit,
              orElse: () => Trade(amount: 0.0, isProfit: true))
          .amount;
    }

    // Profit va loss foizlarini hisoblash
    if (_won > 0) {
      _profitPercentage = (_won / (_won + _loss)) * 100;
    }
    if (_loss > 0) {
      _lossPercentage = (_loss / (_won + _loss)) * 100;
    }

    // Eng yuqori profit va loss miqdorlarini aniqlash
    if (_trades.isNotEmpty) {
      _highestProfit = _trades
          .where((trade) => trade.isProfit)
          .map((trade) => trade.amount)
          .reduce((value, element) => value > element ? value : element);
      _highestLoss = _trades
          .where((trade) => !trade.isProfit)
          .map((trade) => trade.amount)
          .reduce((value, element) => value > element ? value : element);
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
      final trade = Trade(amount: amount, isProfit: isProfit);
      setState(() {
        _trades.add(trade);
        _storage.writeTrades(_trades);
        _calculateWinRate();
        _calculateBalance();
        _calculateStatistics();
        _controller.clear();
      });
    }
  }

  void _addTrade2(bool isProfit) {
    final amount = double.tryParse(_controller2.text);
    if (amount != null) {
      final trade = Trade(amount: amount, isProfit: isProfit);
      setState(() {
        _trades.add(trade);
        _storage.writeTrades(_trades);
        _calculateWinRate();
        _calculateBalance();
        _calculateStatistics();
        _controller2.clear();
      });
    }
  }

  // List<PnL> getPnLData() {
  //   return [
  //     PnL(DateTime(2023, 6, 1), 100),
  //     PnL(DateTime(2023, 6, 2), -50),
  //     PnL(DateTime(2023, 6, 3), 200),
  //     PnL(DateTime(2023, 6, 4), -100),
  //     PnL(DateTime(2023, 6, 5), 150),
  //     PnL(DateTime(2023, 6, 6), 67),
  //     PnL(DateTime(2023, 6, 6), -15),
  //     PnL(DateTime(2023, 6, 6), 124),
  //     PnL(DateTime(2023, 6, 6), 87),
  //     PnL(DateTime(2023, 6, 6), -56),
  //     PnL(DateTime(2023, 6, 6), 100),
  //     PnL(DateTime(2023, 6, 6), 16),
  //     PnL(DateTime(2023, 6, 6), 56),
  //     PnL(DateTime(2023, 6, 6), -23),
  //     PnL(DateTime(2023, 6, 6), 44),
  //     PnL(DateTime(2023, 6, 6), 10),
  //     PnL(DateTime(2023, 6, 6), 7),
  //     PnL(DateTime(2023, 6, 6), 20),
  //     PnL(DateTime(2023, 6, 6), 300),
  //     PnL(DateTime(2023, 6, 6), 300),
  //     PnL(DateTime(2023, 6, 6), 20),
  //   ];
  // }

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
              child: Center(
                child: Text(
                  'Win rate: $_winRate%',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
            //No of trades widget
            Container(
              decoration: BoxDecoration(
                  color: bgPrimaryDark,
                  borderRadius: BorderRadius.circular(10)),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(right: 8, left: 8, top: 8),
                    width: double.infinity,
                    decoration: BoxDecoration(
                        color: bgSecondaryDark,
                        borderRadius: BorderRadius.circular(10)),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Total No. of trades: ${_trades.length}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              color: bgSecondaryDark,
                              borderRadius: BorderRadius.circular(10)),
                          child: Column(
                            children: [
                              const Text(
                                'WON',
                                style: TextStyle(color: Colors.white),
                              ),
                              Text(
                                ' $_won',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              color: bgSecondaryDark,
                              borderRadius: BorderRadius.circular(10)),
                          child: Column(
                            children: [
                              const Text(
                                'LOST',
                                style: TextStyle(color: Colors.white),
                              ),
                              Text(
                                '$_loss',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
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
                            TextField(
                              controller: _controller,
                              decoration:
                                  const InputDecoration(labelText: 'Amount'),
                              keyboardType: TextInputType.number,
                            ),
                            ElevatedButton(
                                onPressed: () => _addTrade(true),
                                child: const Text('Add Profit'))
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
                            TextField(
                              controller: _controller2,
                              decoration:
                                  const InputDecoration(labelText: 'Amount'),
                              keyboardType: TextInputType.number,
                            ),
                            ElevatedButton(
                                onPressed: () => _addTrade2(false),
                                child: const Text('Add Profit'))
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
                              "Starting balance: $_balance",
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Current balance: $_balance",
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Current profit: $_lastProfit",
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Profit percentage: ${_profitPercentage.toStringAsFixed(1)}%",
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
                              "Max WON in a row: $_won",
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Max LOST in a row: $_loss",
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Highest profit: $_highestProfit",
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Highest Loss: $_highestLoss ",
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
              child: FutureBuilder<List<PnLData>>(
                future: getPnLDataFromJson(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Center(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SizedBox(
                          width: snapshot.data!.length * 40.0,
                          child: PnLBarChart(data: snapshot.data!),
                        ),
                      ),
                    );
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
                  borderRadius: BorderRadius.circular(10)),
              child: ListView.builder(
                shrinkWrap: true,
                reverse: true,
                // physics: const NeverScrollableScrollPhysics(),
                itemCount: _trades.length,
                itemBuilder: (context, index) {
                  final trade = _trades[index];
                  final tradeNumber = index + 1;
                  final tradeType = trade.isProfit ? 'Profit' : 'Loss';
                  return Card(
                    color: bgSecondaryDark,
                    child: ListTile(
                      title: Text(
                        'Trade $tradeNumber',
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                          '$tradeType: ${trade.amount.toStringAsFixed(2)}',
                          style: TextStyle(
                              color: tradeType == "Profit" ? clGreen : clRed)),
                      trailing: Text(
                          'Win rate: ${trade.isProfit ? _profitPercentage.toStringAsFixed(1) : _lossPercentage.toStringAsFixed(1)}%',
                          style: const TextStyle(color: Colors.white)),
                    ),
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
                      onPressed: () => _copyJsonToClipboard(),
                      child: const Text('RESET'),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      child: const Text('Edit Balance'),
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
