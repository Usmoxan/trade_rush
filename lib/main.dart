import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

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
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1F1B1B),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(18),
                width: double.infinity,
                decoration: BoxDecoration(
                    color: const Color(0xFF383737),
                    borderRadius: BorderRadius.circular(10)),
                child: const Center(
                  child: Text(
                    'Win rate: 50%',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const Text(
                'Total No. of trades: 100',
                style: TextStyle(color: Colors.white),
              ),
              const Row(
                children: [
                  Column(
                    children: [
                      Text(
                        'WON',
                        style: TextStyle(color: Colors.white),
                      ),
                      Text(
                        '27',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        'LOST',
                        style: TextStyle(color: Colors.white),
                      ),
                      Text(
                        '23',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  )
                ],
              )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.remove),
      ),
    );
  }
}
