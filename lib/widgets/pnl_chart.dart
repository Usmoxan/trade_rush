// import 'package:flutter/material.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:trade_rush/style/colors.dart';
// import '../model/pnlmodel.dart';

// class PnLBarChart extends StatelessWidget {
//   final List<PnL> data;

//   const PnLBarChart({super.key, required this.data});

//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       scrollDirection: Axis.horizontal,
//       child: SizedBox(
//         width: data.length * 30.0, // Adjust the width based on data length
//         child: Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: BarChart(
//             BarChartData(
//               alignment: BarChartAlignment.spaceBetween,
//               barTouchData: BarTouchData(enabled: false),
//               titlesData: FlTitlesData(
//                 leftTitles: AxisTitles(
//                   sideTitles: SideTitles(
//                     reservedSize: 50,
//                     showTitles: true,
//                     getTitlesWidget: (value, meta) {
//                       return Text('${value.toStringAsFixed(0)}%',
//                           style: const TextStyle(
//                               fontSize: 12, color: Colors.white));
//                     },
//                   ),
//                 ),
//                 topTitles: const AxisTitles(
//                   sideTitles: SideTitles(
//                     showTitles: false,
//                   ),
//                 ),
//                 rightTitles: const AxisTitles(
//                   sideTitles: SideTitles(
//                     showTitles: false,
//                   ),
//                 ),
//                 bottomTitles: AxisTitles(
//                   sideTitles: SideTitles(
//                     showTitles: true,
//                     getTitlesWidget: (value, meta) {
//                       DateTime date =
//                           DateTime.fromMillisecondsSinceEpoch(value.toInt());
//                       return Text('${date.day}/${date.month}',
//                           style: const TextStyle(
//                               fontSize: 10, color: Colors.white));
//                     },
//                   ),
//                 ),
//               ),
//               gridData: const FlGridData(show: true),
//               borderData: FlBorderData(show: true),
//               barGroups: data.map((pnl) {
//                 return BarChartGroupData(
//                   x: pnl.date.millisecondsSinceEpoch,
//                   barRods: [
//                     BarChartRodData(
//                       toY: pnl.value,
//                       color: pnl.value >= 0 ? clGreen : clRed,
//                       width: 20,
//                       borderRadius: const BorderRadius.all(Radius.zero),
//                     ),
//                   ],
//                 );
//               }).toList(),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:trade_rush/model/pnlmodel.dart';

class PnLBarChart extends StatelessWidget {
  final List<PnLData> data;

  const PnLBarChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: data.length * 30.0,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceBetween,
              barTouchData: BarTouchData(enabled: false),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    return Text(value.toStringAsFixed(0),
                        style:
                            const TextStyle(fontSize: 12, color: Colors.white));
                  },
                  reservedSize: 30,
                )),
                bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    return Text('${(value + 1).toInt()}',
                        style:
                            const TextStyle(fontSize: 12, color: Colors.white));
                  },
                )),
              ),
              gridData: const FlGridData(show: true),
              borderData: FlBorderData(show: true),
              barGroups: data.map((pnl) {
                return BarChartGroupData(
                  x: data.indexOf(pnl),
                  barRods: [
                    BarChartRodData(
                      color: pnl.isProfit ? Colors.green : Colors.red,
                      width: 20,
                      borderRadius: const BorderRadius.all(Radius.zero),
                      toY: pnl.amount,
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
